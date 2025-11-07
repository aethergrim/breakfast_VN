extends Node3D

const PLAYER_SCENE = preload("res://scenes/Player.tscn")
const UI_SCENE = preload("res://scenes/ui/TopBar.tscn")
const LOCATION_SCENES = {
    "Bedroom": preload("res://scenes/locations/Bedroom.tscn"),
    "Hall": preload("res://scenes/locations/Hall.tscn"),
    "LivingRoom": preload("res://scenes/locations/LivingRoom.tscn"),
    "Kitchen": preload("res://scenes/locations/Kitchen.tscn")
}

@onready var location_root := $Locations
@onready var ui_root_holder := $UIHolder
var location_map: Dictionary = {}
var current_location: String = "Bedroom"
var player: CharacterBody3D
var minigame_node: Node = null

func _ready() -> void:
    _spawn_ui()
    _load_locations()
    _spawn_player()
    Game.minigame_requested.connect(_on_minigame_requested)
    Game.minigame_finished.connect(_on_minigame_finished)
    _set_location(current_location, Vector3.ZERO)

func _spawn_ui() -> void:
    var ui := UI_SCENE.instantiate()
    ui_root_holder.add_child(ui)

func _load_locations() -> void:
    for key in LOCATION_SCENES.keys():
        var scene: PackedScene = LOCATION_SCENES[key]
        var instance := scene.instantiate()
        location_root.add_child(instance)
        location_map[key] = instance
        instance.visible = false
        _hook_transitions(instance)

func _hook_transitions(location: Node) -> void:
    var stack: Array = [location]
    while not stack.is_empty():
        var node: Node = stack.pop_back()
        if node.has_signal("transition_requested"):
            var signal := node.transition_requested
            if not signal.is_connected(_on_transition_requested):
                signal.connect(_on_transition_requested)
        for child in node.get_children():
            stack.append(child)

func _spawn_player() -> void:
    player = PLAYER_SCENE.instantiate()
    add_child(player)

func _on_transition_requested(target_location: String, spawn_position: Vector3) -> void:
    _set_location(target_location, spawn_position)

func _set_location(location_name: String, spawn_position: Vector3) -> void:
    if not location_map.has(location_name):
        return
    for value in location_map.values():
        value.visible = false
    var location := location_map[location_name]
    location.visible = true
    current_location = location_name
    var spawn_node := location.get_node_or_null("Spawn")
    var world_position := spawn_position
    if spawn_node:
        world_position = spawn_node.global_transform.origin
    elif spawn_position != Vector3.ZERO:
        world_position = location.global_transform.origin + spawn_position
    player.global_transform.origin = world_position
    player.velocity = Vector3.ZERO

func _on_minigame_requested(scene_path: String, _metadata: Dictionary) -> void:
    if minigame_node and is_instance_valid(minigame_node):
        minigame_node.queue_free()
    var packed := load(scene_path)
    if packed is PackedScene:
        minigame_node = packed.instantiate()
        Game.add_ui_child(minigame_node)

func _on_minigame_finished(_result: Dictionary) -> void:
    if minigame_node and is_instance_valid(minigame_node):
        minigame_node.queue_free()
    minigame_node = null
