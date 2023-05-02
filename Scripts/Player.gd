extends KinematicBody2D

enum {IDLE, RUN, AIR, WALL, ATTACK, DODGE, DODGE_RUN, PUSH_IDLE, PUSH_ACTIVE}

const MAX_SPEED = 600
const ACCELERATION = 5000
const GRAVITY = 5000
const JUMP_STRENGHT = -1800
const FLOOR_NORMAL = Vector2.UP
const SNAP_DIRECTION = Vector2.DOWN
const SNAP_LENGHT = 64.0
const FLOOR_MAX_ANGLE = deg2rad(50)

var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO
var snap_vector = SNAP_DIRECTION * SNAP_LENGHT

var state = IDLE
var is_climb :bool

var can_jump = true
var can_push = false
var can_take_damage = false


var offest = Vector2.ZERO

signal player_hit

onready var animationplayer = $AnimationPlayer
onready var coyotetimer = $CoyoteTimer

var pickup_red_patricles = preload("res://Scenes/ParticlesRED.tscn")
var pickup_green_patricles = preload("res://Scenes/ParticlesGREEN.tscn")

var lives = 9

func _ready() -> void:
	yield(get_tree().create_timer(0.2), "timeout")
	can_take_damage = true

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
		

#tillämpar basic movement

func _apply_basic_movement(delta) -> void:
	if direction.x != 0:
		velocity = velocity.move_toward(direction*MAX_SPEED, ACCELERATION*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION*delta)
	
	velocity.y += GRAVITY*delta
	#velocity = move_and_slide(velocity, Vector2.UP)
	velocity.y = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, true, 4, FLOOR_MAX_ANGLE).y 

 

#Uppdaterar riktning 

func _get_input_x_update_direction() -> float:
	var input_x = Input.get_axis("move_left", "move_right")
	if input_x > 0:
		direction_x = "RIGHT"
	elif input_x < 0:
		direction_x = "LEFT"
	$Sprite.flip_h = direction_x != "RIGHT"
	return input_x


#Idle state koden som ändrar karaktärens beteende beroende på vilekn input den får
func _idle_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	
	if Input.is_action_just_pressed("jump") and can_jump:
		_enter_air_state(true)
		return
		
		
	_apply_basic_movement(delta)
	
	if velocity.x != 0:
		_enter_run_state()
		return
	
	if Input.is_mouse_button_pressed(1):
		state = ATTACK
		return
	
	if Input.is_action_just_pressed("dodge"):
		animationplayer.play("Start_Dodge")
		yield(get_tree().create_timer(0.25), "timeout")
		_enter_dodge_IDLE_state()
		return
		
	if can_push and Input.is_action_just_pressed("push"):
		_enter_push_IDLE_state()



#Run state svarar för att karaktären kan springa och ändrar karaktärens beteende beroende på vilekn input den får efter
func _run_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	can_jump = true
	if Input.is_action_just_pressed("jump") and can_jump:
		_enter_air_state(true)
		return
	

	_apply_basic_movement(delta)
	
	if not is_on_floor():
		_enter_air_state(false)
		return
	elif velocity.length() == 0 or is_on_wall():
		_enter_idle_state()
		
	
	if Input.is_mouse_button_pressed(1):
		state = ATTACK
		return
		
	if Input.is_action_just_pressed("dodge"):
		animationplayer.play("Start_Dodge")
		yield(get_tree().create_timer(0.25), "timeout")
		_enter_dodge_IDLE_state()
		return
		
	if can_push and Input.is_action_just_pressed("push"):
		_enter_push_IDLE_state()


#Run state svarar för karatärens beteende i luften när den hoppar samt kontrollerar möjligheten för wallhang
func _air_state(delta) -> void:
	
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_STRENGHT
		can_jump = false
		coyotetimer.stop()
	
	elif Input.is_action_just_pressed("jump") and not can_jump:
		pass

	velocity.y = velocity.y + GRAVITY * delta if velocity.y + GRAVITY * delta < 500 else 500 
	direction.x = _get_input_x_update_direction()
	if direction.x != 0:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if direction.x == 1: 
		$DW.enabled = false
		$UP.enabled = false
		$Dw.enabled = true
		$Up.enabled = true
	elif direction.x == -1:
		$DW.enabled = true
		$UP.enabled = true
		$Dw.enabled = false
		$Up.enabled = false
	
	
	
	
	is_climb = ($Dw.is_colliding() == true and $Up.is_colliding() == false) or ($DW.is_colliding() == true and $UP.is_colliding() == false)
	
	
	#yield(get_tree().create_timer(0.25), "timeout")
	
	if is_climb == true and velocity.y > 0:
		_enter_wallhang_state()
		
		
	
	
	if is_on_floor():
		can_jump = true
		_enter_idle_state()
		

# Karaktären hänger stilla
func _wall_state(delta) -> void:
	GRAVITY == 0
	
	can_jump = true
	
	if Input.is_action_just_pressed("jump") and can_jump:
		_enter_air_state(true)
		return
	
# Karaktären attackerar, har ingen funktion i spelet så den är egentligen onödig
func _attack_state(delta) -> void:
		animationplayer.play("Attack")
		
		yield(get_tree().create_timer(0.15), "timeout")
		
		if not animationplayer.play("Attack"):
			_enter_idle_state()
			
			
		if Input.is_action_just_pressed("dodge"):
			animationplayer.play("Start_Dodge")
			yield(get_tree().create_timer(0.25), "timeout")
			_enter_dodge_IDLE_state()
			return

# Karaktären ställer sig i crawl idle state samt ändrar karaktärens beteende beroende på vilekn input den får
func _dodge_state(delta) -> void:
	
	if Input.is_action_pressed("dodge") == true:
		animationplayer.play("idle_dodge")
	
	if Input.is_action_just_pressed("dodge_run_right") or Input.is_action_just_pressed("dodge_run_left"):
		_enter_dodge_ACTIVE_state()
		return
	
	if Input.is_mouse_button_pressed(1):
		state = ATTACK
		return
	
	if Input.is_action_just_pressed("jump") and can_jump:
		_enter_air_state(true)
		return
		
	can_jump = true
	
	if not Input.is_action_pressed("dodge"):
		_enter_idle_state()
		
	
	if can_push and Input.is_action_just_pressed("push"):
		_enter_push_IDLE_state()
	
	
# Karaktären aktivt crawlar samt ändrar karaktärens beteende beroende på vilekn input den får
func _dodge_run_state(delta) -> void:
	direction.x = _get_input_x_update_direction()
	
	velocity.y += GRAVITY*delta
	
	if direction.x == 1:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED - 250, ACCELERATION*delta)
	elif direction.x == -1:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED + 250, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
		_enter_dodge_IDLE_state()
		
		
	velocity = move_and_slide(velocity, Vector2.UP)
	print(velocity)
	
	if Input.is_action_just_released("dodge"):
		_enter_idle_state()
		
	
	if Input.is_mouse_button_pressed(1):
		state = ATTACK
		return
	
	can_jump = true
	
	if Input.is_action_just_pressed("jump") and can_jump:
		_enter_air_state(true)
		return
		
	if can_push and Input.is_action_just_pressed("push"):
		_enter_push_IDLE_state()
	
# Push idle state då man inte aktivt pushar, har ingen tillämpning av detta i spelet så det är onödig
func _push_idle_state(delta) -> void:
	
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		_enter_push_ACTIVE_state()
	
	if can_push == false or Input.is_action_just_pressed("push"):
		_enter_idle_state()
	
	
	if Input.is_mouse_button_pressed(1):
		state = ATTACK
		return
	
	can_jump = true
	
	if Input.is_action_just_pressed("jump") and can_jump:
		_enter_air_state(true)
		return
	
	if Input.is_action_just_pressed("dodge"):
			animationplayer.play("Start_Dodge")
			yield(get_tree().create_timer(0.25), "timeout")
			_enter_dodge_IDLE_state()
			return
		
	
	if Input.is_action_just_pressed("push"):
		_enter_idle_state()
	
	

# Karaktären aktivt pushar, har ingen tillämpning av detta i spelet. 
func _push_state(delta) -> void:
	yield(get_tree().create_timer(0.20), "timeout")
	
	direction.x = _get_input_x_update_direction()
	
	if direction.x == 1:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED - 350, ACCELERATION*delta)
		$Sprite.offset = Vector2(1.3,0)
	elif direction.x == -1:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED + 350, ACCELERATION*delta)
		$Sprite.offset = Vector2(-1.3,0)
	else:
		_enter_push_IDLE_state()
		
	velocity = move_and_slide(velocity, Vector2.UP)
	
	can_jump = true
	
	if can_push == false or Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
		_enter_idle_state()
		
	if can_push and Input.is_action_just_pressed("push"):
		_enter_idle_state()
		
		


# Om karaktären kolliderar med zon den respawnar på position 0, 0 och tappar 1 liv, sedan kontrolleras om gubben har några liv kvar.
func _on_Respawn_body_entered(body):
	body.global_position = Vector2(0, 0)
	if can_take_damage:
		lives -= 1
	if lives == 0:
		get_tree().change_scene("res://Scenes/DeadScreen.tscn")


# Coyote timer
func _on_CoyoteTimer_timeout() -> void:
	can_jump = false
	
# Karaktären går in i idle state och får en jump
func _enter_idle_state() -> void:
	state = IDLE
	animationplayer.play("Idle")
	can_jump = true

# Karaktären får velocity i y led och går in i air state, samt startas coyotetimer
func _enter_air_state(jump: bool) -> void:
	if jump:
		velocity.y = JUMP_STRENGHT
		
	animationplayer.play("Jump_UP")	
	coyotetimer.start()
	state = AIR

	
# Går in i push idle state
func _enter_push_IDLE_state() -> void: 
	state = PUSH_IDLE
	animationplayer.play("push_idle")

# Går in i push active state
func _enter_push_ACTIVE_state() -> void:
	state = PUSH_ACTIVE
	animationplayer.play("Push")
	
# Går in i run state
func _enter_run_state() -> void:
	state = RUN
	animationplayer.play("Run")
	
# Går in i wall state
func _enter_wallhang_state() -> void:
	state = WALL
	animationplayer.play("Climb")
	
# Går in i dodge idle och ger en hopp
func _enter_dodge_IDLE_state() -> void:
	can_jump = true
	state = DODGE
	animationplayer.play("idle_dodge")

# Går in i dodge active
func _enter_dodge_ACTIVE_state() -> void:
	state = DODGE_RUN
	animationplayer.play("dodge_run")

# realeasar parktikalr 
func pick_up_red() -> void:
	var particles_red = pickup_red_patricles.instance()
	particles_red.emitting = true
	add_child(particles_red)
	
# realeasar parktikalr 
func pick_up_green() -> void:
	var particles_green = pickup_green_patricles.instance()
	particles_green.emitting = true
	add_child(particles_green)
