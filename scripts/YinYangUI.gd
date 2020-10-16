extends CanvasLayer

var selected_yin_node = null
var selected_yang_node = null

onready var health_bar = $Bottom/Health
onready var energy_bar = $Bottom/Energy

onready var play_button = $Bottom/AcceptTurn

signal accepted_stats

# Called when the node enters the scene tree for the first time.
func _ready():
	update_play_visible()

func init():
	pass

func show():
	yield(get_tree().create_timer(0.5), "timeout")

func hide():
	yield(get_tree().create_timer(0.5), "timeout")

func reset():
	if selected_yin_node:
		selected_yin_node.unselect()
	if selected_yang_node:
		selected_yang_node.unselect()
	yield(get_tree().create_timer(0.5), "timeout")

func update_play_visible():
	if selected_yin_node and selected_yang_node:
		play_button.visible = true
	else:
		play_button.visible = false

func _on_YinSlot_dropped_node(dropped_node):
	if selected_yin_node:
		selected_yin_node.return_to_position()
	selected_yin_node = dropped_node
	update_play_visible()

func _on_YangSlot_dropped_node(dropped_node):
	if selected_yang_node:
		selected_yang_node.return_to_position()
	selected_yang_node = dropped_node
	update_play_visible()

func _on_YinSlot_removed_node():
	selected_yin_node = null
	update_play_visible()

func _on_YangSlot_removed_node():
	selected_yang_node = null
	update_play_visible()

func _on_AcceptTurn_pressed():
	var stats = {
		"atk": selected_yin_node.attack,
		"def": selected_yin_node.defense,
		"mov": selected_yang_node.movement,
		"spd": selected_yang_node.speed,
	}
	emit_signal("accepted_stats", stats)
