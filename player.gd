extends CharacterBody2D

@export var movement_data : playermovementdata

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyotejumptimer = $coyotejumptimer
@onready var cshape = $CollisionShape2D
@onready var crouch_raycast_1 = $RayCast2D
@onready var crouch_raycast_2 = $RayCast2D2
@onready var slidetimer = $slidetimer
@onready var slowdownslidetimer = $slowdownslidetimer

var is_crouching = false
var underneath_tile = false
var is_sliding = false
var is_wall_sliding = false

var standing_cshape = preload("res://Assets/standing.tres")
var crouching_cshape = preload("res://Assets/crouching.tres")
var sliding_cshape = preload("res://Assets/sliding.tres")

func _physics_process(delta):
	print(slidetimer.time_left)
	apply_gravity(delta)
	handle_jump()
	wall_slide(delta)
	var input_axis = Input.get_axis("ui_left", "ui_right")
	if !is_crouching and Input.is_action_pressed("ui_down") and velocity.x * input_axis >= 100:
		slidetimer.start()
		slowdownslidetimer.start()
		slide()
	if Input.is_action_just_pressed("ui_down"):
		crouch()
	elif Input.is_action_just_released("ui_down"):
		if empty_above_head():
			stand()
		else:
			if underneath_tile != true:
				underneath_tile = true
				
	if underneath_tile && empty_above_head():
#		if Input.is_action_just_pressed("ui_down"):
		stand()
		underneath_tile = false
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyotejumptimer.start()
	if input_axis != 0:
		switch_direction(input_axis)
	cshape.position.x = 0

func empty_above_head() -> bool:
	var result = !crouch_raycast_1.is_colliding() && !crouch_raycast_2.is_colliding()
	return result;

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.GRAVITY_SCALE * delta 

func handle_jump():
	if is_on_floor() or coyotejumptimer.time_left > 0.0:
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = movement_data.JUMP_VELOCITY
		if is_on_wall() and Input.is_action_just_pressed("ui_up") and Input.is_action_pressed("ui_left"):
			velocity.y = movement_data.JUMP_VELOCITY
			velocity.x = movement_data.WALL_JUMP_PUSHBACK
		if is_on_wall() and Input.is_action_just_pressed("ui_up") and Input.is_action_pressed("ui_right"):
			velocity.y = movement_data.JUMP_VELOCITY
			velocity.x = -movement_data.WALL_JUMP_PUSHBACK
			
	if not is_on_floor():
		if Input.is_action_just_released("ui_up") and velocity.y < movement_data.JUMP_VELOCITY / 2:
			velocity.y = movement_data.JUMP_VELOCITY / 2
		if is_on_wall() and Input.is_action_just_pressed("ui_up") and Input.is_action_pressed("ui_left"):
			velocity.y = movement_data.JUMP_VELOCITY
			velocity.x = movement_data.WALL_JUMP_PUSHBACK
		if is_on_wall() and Input.is_action_just_pressed("ui_up") and Input.is_action_pressed("ui_right"):
			velocity.y = movement_data.JUMP_VELOCITY
			velocity.x = -movement_data.WALL_JUMP_PUSHBACK

func handle_acceleration(input_axis, delta):
	if input_axis != 0:
		if velocity.x * input_axis < movement_data.SPEED:
			velocity.x = move_toward(velocity.x, input_axis * movement_data.SPEED, movement_data.ACCELERATION * delta)
		if velocity.x * input_axis > movement_data.SPEED * input_axis or velocity.x == movement_data.SPEED * input_axis:
			movement_data.ACCELERATION == 0 and movement_data.SPEED == 1000

func apply_friction(input_axis, delta):
	if input_axis == 0:
		if velocity.x != 0 and is_on_floor():
			velocity.x = move_toward(velocity.x, 0, movement_data.FRICTION * delta)
		else:
			pass
func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.AIR_RESISTANCE * delta)

func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
		
	if is_wall_sliding:
		velocity.y += (movement_data.WALL_SLIDE_GRAVITY * delta)
		velocity.y = min(velocity.y, movement_data.WALL_SLIDE_GRAVITY)
		
		


func update_animations(input_axis):
	if is_on_floor():
		if input_axis == 0:
			is_sliding = false
			if is_crouching and velocity.x * input_axis < 100:
				animated_sprite_2d.play("crouch")
			else:
				animated_sprite_2d.play("idle")
		else:
			if is_crouching and !is_sliding and velocity.x * input_axis < 100:
				animated_sprite_2d.play("crouch_walk")
				velocity.x = movement_data.CROUCH_SPEED * input_axis
			if !is_crouching and !is_sliding:
				animated_sprite_2d.play("run")
			if is_sliding and (slidetimer.time_left > 0.1):
				if velocity.x * input_axis < 150:
					animated_sprite_2d.play("slide")
					velocity.x = move_toward(velocity.x, velocity.x + 20 * input_axis, movement_data.SPEED * movement_data.ACCELERATION)
					is_sliding = false
				if is_sliding and (slidetimer.time_left > 0.1) and (velocity.x * input_axis > 149):
					animated_sprite_2d.play("slide")
					velocity.x = move_toward(velocity.x, velocity.x + 10 * input_axis, movement_data.SPEED * movement_data.ACCELERATION)
					is_sliding = false
			if slowdownslidetimer.time_left < 0.1 and Input.is_action_pressed("ui_down"):
				velocity.x = move_toward(velocity.x, velocity.x + movement_data.DECELERATION * input_axis, movement_data.SPEED * movement_data.ACCELERATION)
		if Input.is_action_just_released("ui_down"):
			is_sliding = false
			slidetimer.time_left == 0.0
			animated_sprite_2d.play("run")
	else:
		if is_crouching == false:
			if velocity.y < 0:
				is_sliding = false
				animated_sprite_2d.play("jump")
			elif velocity.y > 0:
				animated_sprite_2d.play("fall")
	if is_wall_sliding == true:
		animated_sprite_2d.play("wall_slide")
		
func switch_direction(input_axis):
	animated_sprite_2d.flip_h = (input_axis == -1)
	animated_sprite_2d.position.x = input_axis * 4

func crouch():
	if is_crouching:
		return
	is_crouching = true
	cshape.shape = crouching_cshape
	cshape.position.y = -14
	
func slide():
	if is_sliding:
		return
	is_sliding = true
	cshape.shape = sliding_cshape
	cshape.position.y = 10

	
func stand():
	if is_crouching == false:
		return
	is_crouching = false
	cshape.shape = standing_cshape
	cshape.position.y = -18.5
