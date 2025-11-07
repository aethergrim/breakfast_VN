extends Control

const InventorySlotScene = preload("res://scenes/ui/InventorySlot.tscn")

@onready var grid := $Panel/MarginContainer/VBox/Grid
@onready var title_label := $Panel/MarginContainer/VBox/Title
var slots: Array = []

func _ready() -> void:
    Game.inventory_changed.connect(_refresh)
    _build_slots()
    _refresh()

func _build_slots() -> void:
    for child in grid.get_children():
        child.queue_free()
    slots.clear()
    var slot_total := Game.SLOT_COUNT
    if slot_total <= 0:
        slot_total = Game.inventory.size()
    for i in range(slot_total):
        var slot := InventorySlotScene.instantiate()
        slot.slot_index = i
        grid.add_child(slot)
        slots.append(slot)

func _refresh() -> void:
    title_label.text = "Inventory (%d/%d)" % [_count_items(), Game.SLOT_COUNT]
    for i in range(len(slots)):
        var data := Game.inventory[i]
        slots[i].item_data = data
        slots[i].update_slot()

func _count_items() -> int:
    var total := 0
    for entry in Game.inventory:
        total += entry["quantity"]
    return total
