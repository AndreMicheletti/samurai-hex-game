extends Area2D

signal move_hint_clicked

export var hex_pos = Vector2()
export(int) var move_cost = 1
var has_mouse = false
var emitted_once = false

func _ready():
	for cell in get_tree().get_nodes_in_group("Character"):
		if cell.hex_pos == hex_pos:
			queue_free()

func on_clicked():
	if not emitted_once:
		emit_signal("move_hint_clicked", self.hex_pos, self.move_cost)
		emitted_once = true

func _on_MoveHint_mouse_entered():
	has_mouse = true


func _on_MoveHint_mouse_exited():
	has_mouse = false

func _on_MoveHint_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		print("CLICKED ALSOOO")
		on_clicked()
