extends Area2D

signal move_hint_clicked

export var hex_pos = Vector2()
var has_mouse = false
var emitted_once = false

func _ready():
	for cell in get_tree().get_nodes_in_group("Character"):
		if cell.hex_pos == hex_pos:
			queue_free()

func _process(_delta):
	if has_mouse and Input.is_mouse_button_pressed(BUTTON_LEFT) and not emitted_once:
		emit_signal("move_hint_clicked", self.hex_pos)
		emitted_once = true

func _on_MoveHint_mouse_entered():
	has_mouse = true

func _on_MoveHint_mouse_exited():
	has_mouse = false
