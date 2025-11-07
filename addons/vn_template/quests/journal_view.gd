extends Control

const VNQuestResource = preload("res://addons/vn_template/quests/quest_resource.gd")

@onready var quest_list := $Panel/Margin/VBox/Scroll/QuestList
@onready var title_label := $Panel/Margin/VBox/Header

func _ready() -> void:
    Game.quest_updated.connect(_refresh)
    Game.quest_started.connect(_refresh)
    _refresh()

func _refresh(_quest_id := "") -> void:
    for child in quest_list.get_children():
        child.queue_free()
    if Game.active_quests.is_empty():
        title_label.text = "Journal (no quests)"
        return
    title_label.text = "Journal"
    for quest_id in Game.active_quests.keys():
        _add_quest(Game.active_quests[quest_id])

func _add_quest(data: Dictionary) -> void:
    var quest: VNQuestResource = data["resource"]
    var quest_box := VBoxContainer.new()
    quest_box.custom_minimum_size = Vector2(0, 32)
    var header := Label.new()
    header.text = quest.title
    quest_box.add_child(header)
    var desc := Label.new()
    desc.text = quest.description
    desc.autowrap = true
    quest_box.add_child(desc)
    for step in quest.steps:
        var hbox := HBoxContainer.new()
        hbox.custom_minimum_size = Vector2(0, 24)
        var checkbox := CheckBox.new()
        checkbox.disabled = true
        checkbox.button_pressed = data["steps"].get(step.get("id"), false)
        hbox.add_child(checkbox)
        var label := Label.new()
        label.text = step.get("text")
        label.autowrap = true
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        hbox.add_child(label)
        quest_box.add_child(hbox)
    quest_list.add_child(quest_box)
