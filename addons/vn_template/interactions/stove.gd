extends "res://addons/vn_template/interactions/interactable.gd"

const ItemPickerScene = preload("res://scenes/ui/ItemPicker.tscn")

func interact(player) -> void:
	interact(player)
	_open_picker()

func _open_picker() -> void:
	if Game.ui_root == null:
		return
	var picker := ItemPickerScene.instantiate()
	picker.setup([
		{"id": "bacon", "label": "Fry Bacon"},
		{"id": "egg", "label": "Cook Egg"},
		{"id": "plate", "label": "Plate Meal"}
	])
	picker.closed.connect(_on_choice)
	Game.add_ui_child(picker)

func _on_choice(choice: Dictionary) -> void:
	var option := choice.get("id", "")
	match option:
		"bacon":
			if not Game.has_item("bacon_raw"):
				Game.show_lines(["No raw bacon left."])
				return
			Game.request_minigame("res://scenes/minigames/BaconFry.tscn", {})
		"egg":
			if not Game.has_item("egg_raw"):
				Game.show_lines(["Need an egg from the fridge first."])
				return
			Game.request_minigame("res://scenes/minigames/EggSunnySide.tscn", {})
		"plate":
			if not Game.has_item("plate") or not Game.has_item("bacon_cooked") or not Game.has_item("egg_cooked"):
				Game.show_lines(["Prepare bacon, eggs, and plate before plating."])
				return
			Game.request_minigame("res://scenes/minigames/Plating.tscn", {})
		_:
			pass
