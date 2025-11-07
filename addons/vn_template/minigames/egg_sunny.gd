extends Control

func _ready() -> void:
    $Panel/Margin/VBox/Result.text = "Keep the yolk bright and sunny."

func _on_cook_pressed() -> void:
    if Game.remove_item_from_inventory("egg_raw", 1):
        Game.add_item_to_inventory("egg_cooked", 1)
        Game.finish_minigame({"success": true, "type": "egg"})
    else:
        Game.show_lines(["Out of eggs."])
    queue_free()

func _on_cancel_pressed() -> void:
    Game.finish_minigame({"success": false, "type": "egg"})
    queue_free()
