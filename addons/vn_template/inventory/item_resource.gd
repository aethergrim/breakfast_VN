extends Resource
class_name VNItemResource

@export var item_id: String
@export var display_name: String
@export var stack_size: int = 1
@export var max_stacks: int = 99
@export var size: Vector2i = Vector2i.ONE
@export var cooked_variant: String = ""
@export var raw_variant: String = ""

func duplicate_for_stack() -> VNItemResource:
	var copy := VNItemResource.new()
	copy.item_id = item_id
	copy.display_name = display_name
	copy.stack_size = stack_size
	copy.max_stacks = max_stacks
	copy.size = size
	copy.cooked_variant = cooked_variant
	copy.raw_variant = raw_variant
	return copy
