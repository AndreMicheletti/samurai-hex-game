extends Control

class_name DragAndDrop

export(String) var targetName
export(Vector2) var smallSize = Vector2(134, 87)
export(Vector2) var normalSize = Vector2(200, 130)

onready var area = $Area2D

onready var on_spot_effect = $Effects/OnSpot

var target
var grabbed = false
var on_spot = false
var selected = false
var original_pos

func _ready():
	add_to_group("DragAndDrop")
	original_pos = self.rect_position
	self.rect_size = smallSize
	target = get_tree().get_nodes_in_group(targetName).pop_front()

func _physics_process(_delta):
	if not grabbed or selected:
		return
	on_spot = $Area2D.overlaps_area(target)
	on_spot_effect.emitting = bool(on_spot)

func on_grab():
	$Tween.interpolate_property(self, "rect_size", smallSize, normalSize, 0.2, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	$Tween.start()

func on_release():
	if on_spot:
		select()
	else:
		return_to_position()

func select():
	selected = true
	on_spot_effect.emitting = true
	self.rect_global_position = target.get_parent().rect_global_position
	target.emit_signal("dropped_node", self)

func unselect():
	if not selected:
		return
	target.emit_signal("removed_node")
	return_to_position(false)

func return_to_position(interpolate = true):
	self.rect_position = original_pos
	on_spot_effect.emitting = false
	selected = false
	if interpolate:
		$Tween.interpolate_property(self, "rect_size", normalSize, smallSize, 0.1)
		$Tween.start()
	else:
		rect_size = smallSize

func _on_gui_input(event):
	if selected:
		if event is InputEventScreenTouch:
			unselect()
	else:
		if grabbed:
			if event is InputEventMouseMotion or event is InputEventScreenDrag:
				var target_pos= get_global_mouse_position()
				target_pos.x -= 100
				target_pos.y -= 65
				self.rect_global_position = target_pos
		if event is InputEventScreenTouch:
			if grabbed:
				on_release()
			else:
				on_grab()
			grabbed = event.pressed

func hide():
	if not selected:
		$Tween.interpolate_property(self, "modulate",  Color("#FFFFFFFF"),  Color("#00FFFFFF"), 0.3)
		$Tween.start()

func show():
	if not selected:
		$Tween.interpolate_property(self, "modulate",  Color("#00FFFFFF"),  Color("#FFFFFFFF"), 0.3)
		$Tween.start()
