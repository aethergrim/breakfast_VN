extends Control

signal closed
var options: Array = []

func setup(option_data: Array) -> void:
    options = option_data
    var container := $Panel/Margin/VBox/Buttons
    for child in container.get_children():
        child.queue_free()
    for entry in options:
        var button := Button.new()
        button.text = entry.get("label", entry.get("id"))
        button.pressed.connect(Callable(self, "_on_option_pressed").bind(entry))
        container.add_child(button)

func _on_option_pressed(entry: Dictionary) -> void:
    emit_signal("closed", entry)
    queue_free()

func _on_close_pressed() -> void:
    emit_signal("closed", {})
    queue_free()
