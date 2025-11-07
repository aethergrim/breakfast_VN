extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://scenes/Player.tscn")
const UI_SCENE: PackedScene = preload("res://scenes/ui/TopBar.tscn")
const LOCATION_SCENES: Dictionary = {
	"Bedroom": preload("res://scenes/locations/Bedroom.tscn"),
	"Hall": preload("res://scenes/locations/Hall.tscn"),
	"LivingRoom": preload("res://scenes/locations/LivingRoom.tscn"),
	"Kitchen": preload("res://scenes/locations/Kitchen.tscn"),
}

@onready var location_root: Node = $Locations
@onready var ui_root_holder: Node = $UIHolder

var location_map: Dictionary = {}
var current_location: String = "Bedroom"

var player: CharacterBody3D = null
var ui_root: Node = null
var minigame_node: Node = null


func _ready() -> void:
	_ensure_locations()
	_spawn_player()
	_ensure_ui()


func _ensure_locations() -> void:
	# Instantiate all location scenes under `location_root` once.
	for name in LOCATION_SCENES.keys():
		if not location_map.has(name):
			var ps: PackedScene = LOCATION_SCENES[name]
			var inst: Node = ps.instantiate()
			inst.name = name
			location_root.add_child(inst)
			inst.visible = (name == current_location)
			location_map[name] = inst


func _spawn_player() -> void:
	if player == null:
		player = PLAYER_SCENE.instantiate()
		add_child(player)
		_place_player_at_location(current_location)


func _place_player_at_location(loc: String) -> void:
	var loc_node: Node = location_map.get(loc)
	if loc_node and loc_node.has_node("Spawn"):
		var spawn := loc_node.get_node("Spawn")
		if spawn is Node3D:
			var s3d := spawn as Node3D
			player.global_transform.origin = s3d.global_transform.origin
			player.velocity = Vector3.ZERO


func _ensure_ui() -> void:
	if ui_root == null:
		ui_root = UI_SCENE.instantiate()
		ui_root.name = "UIRoot"
		ui_root_holder.add_child(ui_root)

		# Hook optional minigame signals if present.
		if ui_root.has_signal("minigame_requested"):
			ui_root.connect("minigame_requested", Callable(self, "_on_minigame_requested"))
		if ui_root.has_signal("minigame_finished"):
			ui_root.connect("minigame_finished", Callable(self, "_on_minigame_finished"))


func change_location(to: String) -> void:
	if to == current_location:
		return
	if not location_map.has(to):
		push_error("Unknown location: %s" % to)
		return

	location_map[current_location].visible = false
	current_location = to
	location_map[current_location].visible = true
	_place_player_at_location(current_location)


func _on_minigame_requested(scene_path: String, _metadata: Dictionary) -> void:
	if minigame_node and is_instance_valid(minigame_node):
		minigame_node.queue_free()

	var packed := load(scene_path)
	if packed is PackedScene:
		minigame_node = (packed as PackedScene).instantiate()
		# Prefer autoload Game if available; otherwise attach locally.
		if Engine.has_singleton("Game") or (typeof(Game) != TYPE_NIL and Game.has_method("add_ui_child")):
			Game.add_ui_child(minigame_node)
		else:
			add_child(minigame_node)


func _on_minigame_finished(_result: Dictionary) -> void:
	if minigame_node and is_instance_valid(minigame_node):
		minigame_node.queue_free()
	minigame_node = null
