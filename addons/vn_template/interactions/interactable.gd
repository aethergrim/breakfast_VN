extends Area3D
class_name VNInteractable

@export var prompt_text: String = "Interact"
@export var interact_label: String = "E"
@export var once: bool = false
@export var available: bool = true

signal interacted(player)

func can_interact(player) -> bool:
    return available

func interact(player):
    if not can_interact(player):
        return
    emit_signal("interacted", player)
    if once:
        available = false
