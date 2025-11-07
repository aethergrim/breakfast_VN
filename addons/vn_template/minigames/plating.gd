extends Control

func _ready() -> void:
    $Panel/Margin/VBox/Result.text = "Arrange everything neatly on the plate."

func _on_finish_pressed() -> void:
    if Game.has_item("bacon_cooked") and Game.has_item("egg_cooked") and Game.has_item("plate"):
        Game.remove_item_from_inventory("bacon_cooked", 1)
        Game.remove_item_from_inventory("egg_cooked", 1)
        Game.remove_item_from_inventory("plate", 1)
        Game.add_item_to_inventory("plate_with_food", 1)
        Game.finish_minigame({"success": true, "type": "plating"})
    else:
        Game.show_lines(["Need cooked food and a plate ready."])
        Game.finish_minigame({"success": false, "type": "plating"})
    queue_free()

func _on_cancel_pressed() -> void:
    Game.finish_minigame({"success": false, "type": "plating"})
    queue_free()
