extends "res://addons/vn_template/interactions/interactable.gd"

const ItemPickerScene = preload("res://scenes/ui/ItemPicker.tscn")

var taken_bacon := false
var taken_egg := false
var taken_juice := false

func interact(player) -> void:
    .interact(player)
    _open_picker()

func _open_picker() -> void:
    if Game.ui_root == null:
        return
    var picker := ItemPickerScene.instantiate()
    picker.setup([
        {"id": "bacon_raw", "label": "Take Bacon"},
        {"id": "egg_raw", "label": "Take Eggs"},
        {"id": "glass_with_juice", "label": "Pour Orange Juice"}
    ])
    picker.closed.connect(_on_choice)
    Game.add_ui_child(picker)

func _on_choice(choice: Dictionary) -> void:
    var item_id := choice.get("id", "")
    if item_id == "":
        return
    if item_id == "glass_with_juice" and not Game.has_item("empty_glass"):
        Game.show_lines(["Need a clean glass from the cupboard first."])
        return
    if item_id == "glass_with_juice":
        Game.remove_item_from_inventory("empty_glass", 1)
    Game.add_item_to_inventory(item_id, 1)
    match item_id:
        "bacon_raw":
            taken_bacon = true
        "egg_raw":
            taken_egg = true
        "glass_with_juice":
            taken_juice = true
    if taken_bacon and taken_egg and taken_juice:
        Game.complete_quest_step("q_breakfast", "gather")
