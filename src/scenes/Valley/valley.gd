extends Node3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var player: MovementController = get_tree().get_nodes_in_group("player")[0]
	player.is_active = true
