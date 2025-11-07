extends Control

func _ready() -> void:
	$Panel/Margin/VBox/Result.text = "Fry the bacon to perfection."

func _on_cook_pressed() -> void:
	if Game.remove_item_from_inventory("bacon_raw", 1):
		Game.add_item_to_inventory("bacon_cooked", 1)
		Game.finish_minigame({"success": true, "type": "bacon"})
	else:
		Game.show_lines(["No bacon to fry."])
	queue_free()

func _on_cancel_pressed() -> void:
	Game.finish_minigame({"success": false, "type": "bacon"})
	queue_free()
