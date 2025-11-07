extends "res://addons/vn_template/interactions/interactable.gd"

const ItemPickerScene = preload("res://scenes/ui/ItemPicker.tscn")

func interact(player) -> void:
	interact(player)
	if Game.ui_root == null:
		return
	var picker := ItemPickerScene.instantiate()
	picker.setup([
		{"id": "plate", "label": "Take Plate"},
		{"id": "utensils", "label": "Take Utensils"},
		{"id": "empty_glass", "label": "Take Glass"}
	])
	picker.closed.connect(_on_choice)
	Game.add_ui_child(picker)

func _on_choice(choice: Dictionary) -> void:
	var item_id := choice.get("id", "")
	if item_id == "":
		return
	Game.add_item_to_inventory(item_id, 1)
