extends Control

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
	original_pos = self.rect_global_position
	self.rect_size = smallSize
	target = get_tree().get_nodes_in_group(targetName).pop_front()

func on_grab():
	$Tween.interpolate_property(self, "rect_size", smallSize, normalSize, 0.2, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	$Tween.start()

func on_release():
	if on_spot:
		selected = true
		on_spot_effect.emitting = true
		self.rect_global_position = target.get_parent().rect_global_position
	else:
		$Tween.interpolate_property(self, "rect_size", normalSize, smallSize, 0.1)
		$Tween.start()
		self.rect_global_position = original_pos
		on_spot_effect.emitting = false

func _physics_process(_delta):
	if not grabbed or selected:
		return
	on_spot = $Area2D.overlaps_area(target)
	on_spot_effect.emitting = bool(on_spot)

func _on_gui_input(event):
	if selected:
		if event is InputEventScreenTouch:
			selected = false
			on_spot = false
			on_release()
	else:
		if grabbed:
			if event is InputEventMouseMotion or event is InputEventScreenDrag:
				var target = get_global_mouse_position()
				target.x -= 100
				target.y -= 65
				self.rect_global_position = target
		if event is InputEventScreenTouch:
			if grabbed:
				on_release()
			else:
				on_grab()
			grabbed = event.pressed
