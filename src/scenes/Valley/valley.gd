extends Node3D

func _ready() -> void:
	get_tree().get_nodes_in_group("player")[0].is_active = true
