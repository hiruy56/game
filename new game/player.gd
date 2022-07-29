extends KinematicBody2D

const type = "Player"

signal health_updated(health)
signal killed()


const UP =  Vector2(0,-1)
const GRAVITY = 30
const MAXFALLSPEED = 5500
const MAXSPEED = 800
const jumpforce = 1675
const accel = 20

export var max_health = 10
onready var health = max_health setget _set_health
onready var invulnerability_timer = $invulnerabilityTimer

var motion = Vector2()
var facing_right = true
var isAttacking = false;
var is_dead = false



func _physics_process(delta):
	if is_dead == false:
		motion.y += GRAVITY
		if motion.y > MAXFALLSPEED:
			motion.y = MAXFALLSPEED
			
		if facing_right == true:
			$Sprite.scale.x = 10
		else:
			$Sprite.scale.x = -10
		motion.x = clamp(motion.x,-MAXSPEED,MAXSPEED)
		
		
		if Input.is_action_pressed("right") && isAttacking == false:
			motion.x += accel
			facing_right = true
			get_node("attackarea").position = Vector2(25, 1)
			$AnimationPlayer.play("run")
		elif Input.is_action_pressed("left") && isAttacking == false:
			motion.x -= accel
			get_node("attackarea").position = Vector2(-225, 1)
			facing_right = false
			$AnimationPlayer.play("run")
		else:
			motion.x = 0;
			if isAttacking == false:
				$AnimationPlayer.play("idle")
		if is_on_floor():
			if Input.is_action_just_pressed("jump"):
				motion.y = -jumpforce
		if !is_on_floor():
			if motion.y < 0:
				$AnimationPlayer.play("jump")
			elif motion.y > 0:
				$AnimationPlayer.play("fall")
		
		if Input.is_action_just_pressed("attack"):
			$AnimationPlayer.play("attack")
			isAttacking = true;
			$attackarea/attackcolision.disabled = false;
		motion = move_and_slide(motion, UP * delta)
		
	
func _set_health(value):
	if value > 0:
		emit_signal("health_updated", value)
	else:
		dead()
	var prev_health = health
	health = clamp(value, 1, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		
func damage(amount):
	_set_health(health - amount)
	$AnimationPlayer.play("damage")
	$AnimationPlayer.queue("flash")

func kill():
	pass

func dead():
	kill()
	is_dead = true
	Vector2(0, 0)
	$AnimationPlayer.play("dead")
	emit_signal("killed")
	$Timer.start()
	get_tree().reload_current_scene()
		
		
	
func heal(amount):
	if is_dead == false:
		health += amount
		health = min(health, max_health)
		emit_signal("health_updated", health)
		print("%s got healed by %s points. Health: %s/%s" % [get_name(), amount, health, max_health])
		
func _on_invulnerabilityTimer_timeout():
	$AnimationPlayer.play("rest")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		$attackarea/attackcolision.disabled = true
		isAttacking = false
	if anim_name == "damage":
		$AnimationPlayer.play("rest")
	


func _on_Timer_timeout():
	get_tree().reload_current_scene()

func _on_Area2D_body_entered(body):
	damage(1)
	print(health)
