extends Control

@onready var inventory_button := $HBox/InventoryButton
@onready var journal_button := $HBox/JournalButton
@onready var menu_button := $HBox/MenuButton
@onready var inventory_panel := get_node("../InventoryLayer/Inventory")
@onready var journal_panel := get_node("../InventoryLayer/Journal")
@onready var menu_panel := $MenuPopup

func _ready() -> void:
    inventory_button.pressed.connect(_toggle_inventory)
    journal_button.pressed.connect(_toggle_journal)
    menu_button.pressed.connect(_toggle_menu)
    menu_panel.visible = false
    inventory_panel.visible = false
    journal_panel.visible = false

func _toggle_inventory() -> void:
    journal_panel.visible = false
    inventory_panel.visible = not inventory_panel.visible

func _toggle_journal() -> void:
    inventory_panel.visible = false
    journal_panel.visible = not journal_panel.visible

func _toggle_menu() -> void:
    menu_panel.visible = not menu_panel.visible

func _on_resume_pressed() -> void:
    menu_panel.visible = false

func _on_exit_pressed() -> void:
    get_tree().quit()
