extends Resource
class_name VNQuestResource

@export var quest_id: String
@export var title: String
@export var description: String
@export var steps: Array = [] # Array of dictionaries { id, text, auto_complete }

func get_step_by_id(step_id: String) -> Dictionary:
    for step in steps:
        if step.get("id", "") == step_id:
            return step
    return {}
