extends Node

const VNItemResource = preload("res://addons/vn_template/inventory/item_resource.gd")
const VNQuestResource = preload("res://addons/vn_template/quests/quest_resource.gd")

const INVENTORY_COLUMNS := 6
const INVENTORY_ROWS := 4
const SLOT_COUNT := INVENTORY_COLUMNS * INVENTORY_ROWS

signal inventory_changed
signal quest_started(quest_id)
signal quest_step_completed(quest_id, step_id)
signal quest_updated(quest_id)
signal vn_line_shown(text)
signal prompt_updated(text)
signal minigame_requested(scene_path, metadata)
signal minigame_finished(result)

var item_db: Dictionary = {}
var quest_db: Dictionary = {}
var inventory: Array = []
var active_quests: Dictionary = {}
var journal_entries: Dictionary = {}
var player_reference: Node = null
var ui_root: Node = null
var prompt_text: String = ""

func _ready() -> void:
	_build_inventory()
	_register_default_items()
	_register_default_quests()

func register_player(player: Node) -> void:
	player_reference = player

func register_ui(ui_node: Node) -> void:
	ui_root = ui_node

func add_ui_child(node: Node) -> void:
	if ui_root:
		ui_root.add_child(node)

func _build_inventory() -> void:
	inventory.clear()
	for i in range(SLOT_COUNT):
		inventory.append({"item": null, "quantity": 0})

func register_item(item: VNItemResource) -> void:
	item_db[item.item_id] = item

func get_item(item_id: String) -> VNItemResource:
	var item: VNItemResource = item_db.get(item_id)
	if item:
		return item
	return null

func register_quest(quest: VNQuestResource) -> void:
	quest_db[quest.quest_id] = quest

func get_quest(quest_id: String) -> VNQuestResource:
	return quest_db.get(quest_id)

func start_quest(quest_id: String) -> void:
	if active_quests.has(quest_id):
		return
	var quest := get_quest(quest_id)
	if quest == null:
		return
	var step_state := {}
	for step in quest.steps:
		step_state[step.get("id")] = false
	active_quests[quest_id] = {
		"resource": quest,
		"steps": step_state
	}
	journal_entries[quest_id] = step_state.duplicate(true)
	emit_signal("quest_started", quest_id)
	emit_signal("quest_updated", quest_id)

func complete_quest_step(quest_id: String, step_id: String) -> void:
	if not active_quests.has(quest_id):
		return
	var state: Dictionary = active_quests[quest_id]
	if not state["steps"].has(step_id):
		return
	if state["steps"][step_id]:
		return
	state["steps"][step_id] = true
	journal_entries[quest_id][step_id] = true
	emit_signal("quest_step_completed", quest_id, step_id)
	emit_signal("quest_updated", quest_id)

func is_quest_complete(quest_id: String) -> bool:
	if not active_quests.has(quest_id):
		return false
	for step_complete in active_quests[quest_id]["steps"].values():
		if not step_complete:
			return false
	return true

func add_item_to_inventory(item_id: String, quantity: int = 1) -> bool:
	var item_template := get_item(item_id)
	if item_template == null:
		return false
	var remaining := quantity
	for slot in inventory:
		if slot["item"] != null and slot["item"].item_id == item_id:
			var available: Array = slot["item"].max_stacks - slot["quantity"]
			if available.size() > 0:
				var to_add := min(available, remaining)
				slot["quantity"] += to_add
				remaining -= to_add
				if remaining <= 0:
					emit_signal("inventory_changed")
					return true
	for slot in inventory:
		if slot["item"] == null:
			slot["item"] = item_template.duplicate_for_stack()
			var to_place := min(item_template.max_stacks, remaining)
			slot["quantity"] = to_place
			remaining -= to_place
			if remaining <= 0:
				emit_signal("inventory_changed")
				return true
	emit_signal("inventory_changed")
	if remaining < quantity:
		_check_gather_step()
	return remaining == 0

func remove_item_from_inventory(item_id: String, quantity: int = 1) -> bool:
	var remaining := quantity
	for slot in inventory:
		if slot["item"] != null and slot["item"].item_id == item_id:
			var to_remove := min(slot["quantity"], remaining)
			slot["quantity"] -= to_remove
			remaining -= to_remove
			if slot["quantity"] <= 0:
				slot["item"] = null
				slot["quantity"] = 0
			if remaining <= 0:
				emit_signal("inventory_changed")
				return true
	emit_signal("inventory_changed")
	return remaining == 0

func swap_inventory_slots(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= SLOT_COUNT:
		return
	if to_index < 0 or to_index >= SLOT_COUNT:
		return
	var temp: Dictionary = inventory[from_index]
	inventory[from_index] = inventory[to_index]
	inventory[to_index] = temp
	emit_signal("inventory_changed")

func set_prompt(text: String) -> void:
	prompt_text = text
	emit_signal("prompt_updated", prompt_text)

func request_minigame(scene_path: String, metadata: Dictionary = {}) -> void:
	emit_signal("minigame_requested", scene_path, metadata)

func finish_minigame(result: Dictionary) -> void:
	emit_signal("minigame_finished", result)
	_check_cook_step()

func show_lines(lines: Array) -> void:
	for line in lines:
		emit_signal("vn_line_shown", str(line))

func has_item(item_id: String) -> bool:
	for slot in inventory:
		if slot["item"] != null and slot["item"].item_id == item_id and slot["quantity"] > 0:
			return true
	return false

func _check_gather_step() -> void:
	if not active_quests.has("q_breakfast"):
		return
	if has_item("bacon_raw") and has_item("egg_raw") and has_item("glass_with_juice") and has_item("plate") and has_item("utensils"):
		complete_quest_step("q_breakfast", "gather")

func _check_cook_step() -> void:
	if not active_quests.has("q_breakfast"):
		return
	if has_item("bacon_cooked") and has_item("egg_cooked"):
		complete_quest_step("q_breakfast", "cook")

func _register_default_items() -> void:
	var bacon_raw := VNItemResource.new()
	bacon_raw.item_id = "bacon_raw"
	bacon_raw.display_name = "Raw Bacon"
	bacon_raw.max_stacks = 10
	bacon_raw.cooked_variant = "bacon_cooked"
	register_item(bacon_raw)

	var bacon_cooked := VNItemResource.new()
	bacon_cooked.item_id = "bacon_cooked"
	bacon_cooked.display_name = "Cooked Bacon"
	bacon_cooked.max_stacks = 10
	bacon_cooked.raw_variant = "bacon_raw"
	register_item(bacon_cooked)

	var egg_raw := VNItemResource.new()
	egg_raw.item_id = "egg_raw"
	egg_raw.display_name = "Egg"
	egg_raw.max_stacks = 12
	egg_raw.cooked_variant = "egg_cooked"
	register_item(egg_raw)

	var egg_cooked := VNItemResource.new()
	egg_cooked.item_id = "egg_cooked"
	egg_cooked.display_name = "Sunny Egg"
	egg_cooked.max_stacks = 12
	egg_cooked.raw_variant = "egg_raw"
	register_item(egg_cooked)

	var oj := VNItemResource.new()
	oj.item_id = "glass_with_juice"
	oj.display_name = "Orange Juice"
	oj.max_stacks = 4
	register_item(oj)

	var glass := VNItemResource.new()
	glass.item_id = "empty_glass"
	glass.display_name = "Empty Glass"
	glass.max_stacks = 4
	glass.cooked_variant = "glass_with_juice"
	register_item(glass)

	var plate := VNItemResource.new()
	plate.item_id = "plate"
	plate.display_name = "Plate"
	plate.max_stacks = 4
	register_item(plate)

	var utensils := VNItemResource.new()
	utensils.item_id = "utensils"
	utensils.display_name = "Utensils"
	utensils.max_stacks = 4
	register_item(utensils)

	var plate_with_food := VNItemResource.new()
	plate_with_food.item_id = "plate_with_food"
	plate_with_food.display_name = "Plated Breakfast"
	plate_with_food.max_stacks = 1
	register_item(plate_with_food)

func _register_default_quests() -> void:
	var quest := VNQuestResource.new()
	quest.quest_id = "q_breakfast"
	quest.title = "Breakfast Rush"
	quest.description = "Get ready for the day with a hot meal."
	quest.steps = [
		{"id": "gather", "text": "Gather ingredients and tools.", "auto_complete": false},
		{"id": "cook", "text": "Cook the bacon and eggs.", "auto_complete": false},
		{"id": "serve", "text": "Serve breakfast at the table.", "auto_complete": false}
	]
	register_quest(quest)
