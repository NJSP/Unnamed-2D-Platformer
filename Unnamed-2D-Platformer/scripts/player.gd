extends CharacterBody2D


@export var walk_speed = 150.0
@export var run_speed = 250.0
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1

@export var jump_force = -450
@export_range(0, 1) var decelerate_on_jump_release = .5

@export var dash_speed = 1000
@export var dash_max_distance = 300
@export var dash_curve : Curve
@export var dash_cooldown = 1

# Animation enumerator
enum States {idle, run, jump, roll, attack}

var state: States = States.idle
var is_attacking = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_dashing = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0

@onready var animated_sprite = $AnimatedSprite2D


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()):
		velocity.y = jump_force

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release 


	var speed
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed
	
	# Gets input direction (-1, 0, or 1) and handle the movement/deceleration
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
		animated_sprite.flip_h = direction == -1
		if is_on_floor():
			if Input.is_action_just_pressed("run"):
				animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
		if is_on_floor():
			animated_sprite.play("idle")
		
	# Dash activation
	if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		is_dashing = true
		dash_start_position = position.x
		dash_direction = direction
		dash_timer = dash_cooldown
		
	# Performs Dash
	if is_dashing:
		var current_distance = abs(position.x - dash_start_position)
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0
			
	# Reduce the Dash Timer
	if dash_timer > 0:
		dash_timer -= delta
		
	#Flip Sprite
	#if direction > 0:
	#	animated_sprite.flip_h = false
	#elif direction < 0:
	#	animated_sprite.flip_h = true
		
		
	# State Machine
	if is_on_floor() and direction != 0:
		state = States.run
	elif not is_on_floor():
		state = States.jump
	elif is_on_floor() and direction == 0:
		state = States.idle

	# Play animations
	if state == States.idle:
		animated_sprite.play("idle")
	elif state == States.run:
		animated_sprite.play("run")
	elif state == States.jump:
		animated_sprite.play("jump")
	elif state == States.roll:
		animated_sprite.play("roll")
	elif state == States.attack:
		animated_sprite.play("attack")
	
	move_and_slide()	
