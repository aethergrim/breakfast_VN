extends "res://addons/vn_template/interactions/interactable.gd"

const OUTRO_LINES := [
    "Breakfast is served.",
    "Time to enjoy the morning."
]

func interact(player) -> void:
    if Game.has_item("plate_with_food") and Game.has_item("glass_with_juice"):
        Game.complete_quest_step("q_breakfast", "serve")
        Game.show_lines(OUTRO_LINES)
    else:
        Game.show_lines(["Need the plated meal and juice here first."])
    .interact(player)
