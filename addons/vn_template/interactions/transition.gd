extends VNInteractable

@export var target_location: String
@export var spawn_position: Vector3 = Vector3.ZERO

signal transition_requested(target_location, spawn_position)

func _ready() -> void:
	prompt_text = prompt_text if prompt_text != "" else "Move"
	add_to_group("vn_transitions")

func interact(player) -> void:
	interact(player)
	emit_signal("transition_requested", target_location, spawn_position)
