extends Button

@export var slot_index: int = 0
var item_data: Dictionary = {}

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS
    update_slot()

func update_slot() -> void:
    if item_data.get("item"):
        text = "%s x%d" % [item_data["item"].display_name, item_data["quantity"]]
    else:
        text = "--"

func get_drag_data(_at_position: Vector2) -> Variant:
    if item_data.get("item") == null:
        return null
    var preview := Label.new()
    preview.text = text
    set_drag_preview(preview)
    return {"slot": slot_index}

func can_drop_data(_pos: Vector2, data: Variant) -> bool:
    return typeof(data) == TYPE_DICTIONARY and data.has("slot")

func drop_data(_pos: Vector2, data: Variant) -> void:
    if not can_drop_data(_pos, data):
        return
    Game.swap_inventory_slots(data["slot"], slot_index)
