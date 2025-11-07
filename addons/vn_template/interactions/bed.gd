extends "res://addons/vn_template/interactions/interactable.gd"

var started := false
const INTRO_LINES := [
    "Morning already? Time to make breakfast.",
    "Let's grab everything we need."
]

func interact(player) -> void:
    if not started:
        Game.show_lines(INTRO_LINES)
        Game.start_quest("q_breakfast")
        started = true
    .interact(player)
