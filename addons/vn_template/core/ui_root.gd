extends CanvasLayer

@onready var prompt_label := $Prompt
@onready var vn_label := $VNPanel/Margin/Text
@onready var vn_panel := $VNPanel

var vn_queue: Array = []
var vn_timer := 0.0
const VN_DISPLAY_TIME := 3.0

func _ready() -> void:
	Game.register_ui(self)
	Game.prompt_updated.connect(_on_prompt_updated)
	Game.vn_line_shown.connect(_on_vn_line)
	vn_panel.visible = false
	set_process(true)

func _process(delta: float) -> void:
	if vn_queue.is_empty():
		if vn_panel.visible:
			vn_timer -= delta
			if vn_timer <= 0:
				vn_panel.visible = false
		return
	vn_panel.visible = true
	vn_timer = VN_DISPLAY_TIME
	vn_label.text = vn_queue.pop_front()

func _on_prompt_updated(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = text != ""

func _on_vn_line(text: String) -> void:
	vn_queue.append(text)
