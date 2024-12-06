extends CharacterBody3D

@onready var camera_mount: Node3D = $camera_mount
@onready var animation_player: AnimationPlayer = $visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $visuals

const JUMP_VELOCITY = 4.5
const RUNNING_SPEED = 5.4
const WALKING_SPEED = 1.6

@export var mouse_sensitivity := 0.5
var speed := WALKING_SPEED
var is_running := false
var is_locked := false
var movement_animation := "walking"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		visuals.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
	elif event is InputEventKey:
		if event.is_action_pressed("run"):
			is_running = true
			speed = RUNNING_SPEED
			movement_animation = "running"
		elif event.is_action_released("run"):
			is_running = false
			speed = WALKING_SPEED
			movement_animation = "walking"
			

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if is_locked and !animation_player.is_playing():
		is_locked = false
		
	if Input.is_action_just_pressed("kick"):
		is_locked = true
		animation_player.play("kick")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if animation_player.current_animation != movement_animation:
				animation_player.play(movement_animation)
			visuals.look_at(position + direction)

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if !is_locked and animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if !is_locked:
		move_and_slide()
