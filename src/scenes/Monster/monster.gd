extends CharacterBody3D

@export var player_path: NodePath
@onready var nav_agent: NavigationAgent3D = %Monster/%NavigationAgent3D
@onready var audio_player: AudioStreamPlayer3D = %Monster/%AudioStreamPlayer3D
@onready var animation_player: AnimationPlayer = %Monster/%AnimationPlayer

const SPEED = 5.0
const MIN_DISTANCE_TO_PLAYER_TO_START_MOVING = 60
const MAX_DISTANCE_TO_PLAYER = 10
var player: CharacterBody3D = null

func _ready() -> void:
	player = get_node(player_path)
	
func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > MIN_DISTANCE_TO_PLAYER_TO_START_MOVING:
		animation_player.stop()
		audio_player.stop()
		return
	
	if !animation_player.is_playing():
		animation_player.play("dancing")
		
	if !audio_player.playing:
		audio_player.play()
	
	if distance_to_player > MAX_DISTANCE_TO_PLAYER:
		nav_agent.set_target_position(player.global_position)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
		
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		move_and_slide()
