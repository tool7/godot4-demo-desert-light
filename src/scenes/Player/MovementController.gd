extends CharacterBody3D
class_name MovementController

@export var gravity_multiplier := 3.0
@export var speed := 10
@export var acceleration := 8
@export var deceleration := 10
@export_range(0.0, 1.0, 0.05) var air_control := 0.3
@export var jump_height := 10

@onready var gate_lever_animation_player: AnimationPlayer = get_node("%TempleScene/%GateLever/AnimationPlayer")
@onready var gate_lever_audio_player: AudioStreamPlayer3D = get_node("%TempleScene/%GateLeverAudioPlayer")
@onready var door_open_animation_player: AnimationPlayer = get_node("%TempleScene/%DoorOpenAnimationPlayer")
@onready var door_open_audio_player: AudioStreamPlayer3D = get_node("%TempleScene/%TempleDoorAudioPlayer")

var direction := Vector3()
var input_axis := Vector2()
var is_active := false:
	set(val):
		is_active = val
		$Head.is_active = is_active
		set_physics_process(is_active)
	get:
		return is_active


# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") 
		* gravity_multiplier)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()

# Called every physics tick. 'delta' is constant
func _physics_process(delta: float) -> void:
	input_axis = Input.get_vector(&"move_back", &"move_forward",
			&"move_left", &"move_right")
	
	direction_input()
	
	if is_on_floor():
		if Input.is_action_just_pressed(&"jump"):
			velocity.y = jump_height
	else:
		velocity.y -= gravity * delta
	
	accelerate(delta)
	
	move_and_slide()


func direction_input() -> void:
	direction = Vector3()
	var aim: Basis = get_global_transform().basis
	direction = aim.z * -input_axis.x + aim.x * input_axis.y


func accelerate(delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity
	temp_vel.y = 0
	
	var temp_accel: float
	var target: Vector3 = direction * speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	if not is_on_floor():
		temp_accel *= air_control
	
	temp_vel = temp_vel.lerp(target, temp_accel * delta)
	
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z

func interact():
	gate_lever_animation_player.play("Take 001")
	gate_lever_audio_player.play()
	
	await get_tree().create_timer(1.5).timeout
	
	door_open_animation_player.play("door_open_animation")
	door_open_audio_player.play()
