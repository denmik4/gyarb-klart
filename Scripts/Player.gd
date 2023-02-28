extends KinematicBody2D

enum {IDLE, RUN, AIR, WALL, ATTACK, DODGE, DODGE_RUN, PUSH_IDLE, PUSH_ACTIVE}

const MAX_SPEED = 600
const ACCELERATION = 1000
const GRAVITY = 2000
const JUMP_STRENGHT = -1250

var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var state = IDLE
var is_climb :bool

var can_jump = true
var can_push = false

var offest = Vector2.ZERO

onready var animationplayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		RUN:
			_run_state(delta)
		AIR:
			_air_state(delta)
		WALL:
			_wall_state(delta)
		ATTACK:
			_attack_state(delta)
		DODGE:
			_dodge_state(delta)
		DODGE_RUN:
			_dodge_run_state(delta)
		PUSH_ACTIVE:
			_push_state(delta)
		PUSH_IDLE:
			_push_idle_state(delta)
		


func _apply_basic_movement(delta) -> void:
	if direction.x != 0:
		velocity = velocity.move_toward(direction*MAX_SPEED, ACCELERATION*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION*delta)
	
	velocity.y += GRAVITY*delta
	velocity = move_and_slide(velocity, Vector2.UP)

func _get_input_x_update_direction() -> float:
	var input_x = Input.get_axis("move_left", "move_right")
	if input_x > 0:
		direction_x = "RIGHT"
	elif input_x < 0:
		direction_x = "LEFT"
	$Sprite.flip_h = direction_x != "RIGHT"
	return input_x



func _idle_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_STRENGHT
		can_jump = false
		state = AIR
		animationplayer.play("Jump_UP")
		return
		
	_apply_basic_movement(delta)
	
	if velocity.x != 0:
		state = RUN
		animationplayer.play("Run")
		return
	
	if Input.is_mouse_button_pressed(1):
		state = ATTACK
		return
	
	if Input.is_action_just_pressed("dodge"):
		animationplayer.play("Start_Dodge")
		yield(get_tree().create_timer(0.25), "timeout")
		state = DODGE
		return
		
	if can_push and Input.is_action_just_pressed("push"):
		state = PUSH_IDLE



	
func _run_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_STRENGHT
		can_jump = false
		state = AIR
		animationplayer.play("Jump_UP")
		return
	

	_apply_basic_movement(delta)
	
	if not is_on_floor():
		state = AIR
		can_jump = false
		animationplayer.play("Jump_UP")
	elif velocity.length() == 0 or is_on_wall():
		state = IDLE
		animationplayer.play("Idle")
		$Sprite.offset = Vector2(0, 0)
		return
	
	if Input.is_mouse_button_pressed(1):
		state = ATTACK
		return
		
	if Input.is_action_just_pressed("dodge"):
		animationplayer.play("Start_Dodge")
		yield(get_tree().create_timer(0.25), "timeout")
		state = DODGE
		return
		
	if can_push and Input.is_action_just_pressed("push"):
		state = PUSH_IDLE

func _air_state(delta) -> void:
	velocity.y = velocity.y + GRAVITY * delta if velocity.y + GRAVITY * delta < 500 else 500 
	direction.x = _get_input_x_update_direction()
	if direction.x != 0:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	is_climb = ($Dw.is_colliding() == true and $Up.is_colliding() == false) or ($DW.is_colliding() == true and $UP.is_colliding() == false)
	
	
	#yield(get_tree().create_timer(0.25), "timeout")
	
	if is_climb == true and velocity.y > 0:
		animationplayer.play("Climb")
		state = WALL
		
	
	
	if is_on_floor():
		state = IDLE
		animationplayer.play("Idle")
		can_jump = true
		return

func _wall_state(delta) -> void:
	GRAVITY == 0
	
	can_jump = true
	
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_STRENGHT
		GRAVITY == 1000
		can_jump = false
		state = AIR
		animationplayer.play("Jump_UP")
	
	

func _attack_state(delta) -> void:
		animationplayer.play("Attack")
		
		yield(get_tree().create_timer(0.15), "timeout")
		
		if not animationplayer.play("Attack"):
			state = IDLE
			animationplayer.play("Idle")
			return
			
		if Input.is_action_just_pressed("dodge"):
			animationplayer.play("Start_Dodge")
			yield(get_tree().create_timer(0.25), "timeout")
			state = DODGE
			return
		
func _dodge_state(delta) -> void:
	
	if Input.is_action_pressed("dodge") == true:
		animationplayer.play("idle_dodge")
	
	if Input.is_action_just_pressed("dodge_run_right") or Input.is_action_just_pressed("dodge_run_left"):
		animationplayer.play("dodge_run")
		state = DODGE_RUN
		return
	
	if Input.is_mouse_button_pressed(1):
		state = ATTACK
		return
	
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_STRENGHT
		can_jump = false
		state = AIR
		animationplayer.play("Jump_UP")
		return
		
	can_jump = true
	
	if not Input.is_action_pressed("dodge"):
		state = IDLE
		animationplayer.play("Idle")
		return
	
	if can_push and Input.is_action_just_pressed("push"):
		state = PUSH_IDLE
	
	
	
func _dodge_run_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	print(direction_x)
	
	if direction.x == 1:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED + 100, ACCELERATION*delta)
	elif direction.x == -1:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED - 100, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
		state = DODGE
		
		
	velocity = move_and_slide(velocity, Vector2.UP)
	print(velocity)
	
	if Input.is_action_just_released("dodge"):
		state = IDLE
		return
	
	if Input.is_mouse_button_pressed(1):
		state = ATTACK
		return
	
	can_jump = true
	
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_STRENGHT
		can_jump = false
		state = AIR
		animationplayer.play("Jump_UP")
		return
		
	if can_push and Input.is_action_just_pressed("push"):
		state = PUSH_IDLE
	

func _push_idle_state(delta) -> void:
	animationplayer.play("push_idle")
	
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		state = PUSH_ACTIVE
	
	if can_push == false or Input.is_action_just_pressed("push"):
		state = IDLE
	
	
	if Input.is_mouse_button_pressed(1):
		state = ATTACK
		return
	
	can_jump = true
	
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_STRENGHT
		can_jump = false
		state = AIR
		animationplayer.play("Jump_UP")
		return
	
	if Input.is_action_just_pressed("dodge"):
			animationplayer.play("Start_Dodge")
			yield(get_tree().create_timer(0.25), "timeout")
			state = DODGE
			return
		
	
	if Input.is_action_just_pressed("push"):
		animationplayer.play("Idle")
		state = IDLE
	
	
	
func _push_state(delta) -> void:
	animationplayer.play("Push")
	yield(get_tree().create_timer(0.20), "timeout")
	
	
	
	direction.x = _get_input_x_update_direction()
	
	if direction.x == 1:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED - 350, ACCELERATION*delta)
		$Sprite.offset = Vector2(1.3,0)
	elif direction.x == -1:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED + 350, ACCELERATION*delta)
		$Sprite.offset = Vector2(-1.3,0)
	else:
		state = PUSH_IDLE
		
	velocity = move_and_slide(velocity, Vector2.UP)
	
	can_jump = true
	
	if can_push == false or Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
		state = IDLE
		return
		
	if can_push and Input.is_action_just_pressed("push"):
		state = IDLE
		
		

