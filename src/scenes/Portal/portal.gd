extends GeometryInstance3D

@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("player")[0]

const MIN = 60
const MAX = 70

func _process(delta: float) -> void:
#	Something is messed up with distance (because of vector directions ???)
	var distance_to_player = self.position.distance_to(player.position)
	
	if distance_to_player <= MAX && distance_to_player >= MIN:
		var intensity: float = lerpf(1, 0, (MAX - distance_to_player) / (MAX - MIN))
		material_override.set("shader_parameter/intensity", intensity)
	elif distance_to_player < MIN:
		material_override.set("shader_parameter/intensity", 0.0)
	elif distance_to_player > MAX:
		material_override.set("shader_parameter/intensity", 1.0)
