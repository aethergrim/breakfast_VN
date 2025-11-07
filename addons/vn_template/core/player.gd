extends CharacterBody3D

const VNInteractable = preload("res://addons/vn_template/interactions/interactable.gd")

const MOUSE_SENSITIVITY := 0.002
const MOVE_SPEED := 4.0
const RAY_LENGTH := 3.0

@onready var camera := $Camera3D
var look_rotation := Vector2.ZERO
var current_interactable: VNInteractable = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Game.register_player(self)

func _physics_process(delta: float) -> void:
	_update_interaction()
	_handle_movement(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		look_rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		look_rotation.x = clamp(look_rotation.x, deg_to_rad(-80), deg_to_rad(80))
		rotation.y = look_rotation.y
		camera.rotation.x = look_rotation.x
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("interact"):
		_perform_interact()

func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction.y = 0
	direction = direction.normalized()
	velocity.x = direction.x * MOVE_SPEED
	velocity.z = direction.z * MOVE_SPEED
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0
	move_and_slide()

func _update_interaction() -> void:
	var space := get_world_3d().direct_space_state
	var origin:Vector3 = camera.global_transform.origin
	var target:Vector3 = origin + -camera.global_transform.basis.z * RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.collide_with_areas = true
	var result := space.intersect_ray(query)
	if result.has("collider") and result.collider is VNInteractable and result.collider.can_interact(self):
		current_interactable = result.collider
		Game.set_prompt("[E] %s" % current_interactable.prompt_text)
	else:
		current_interactable = null
		Game.set_prompt("")

func _perform_interact() -> void:
	if current_interactable == null:
		return
	current_interactable.interact(self)
