extends CanvasLayer

onready var game = get_parent()

var selected_yin_node = null
var selected_yang_node = null

onready var anim = $AnimationPlayer

onready var game_over = $Screen/GameOver
onready var health_bar = $Bottom/Health
onready var energy_bar = $Bottom/Energy

onready var play_button = $Bottom/AcceptTurn

signal accepted_stats

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	update_play_visible()

func init():
	player = game.player
	update_bars()

func show():
	for node in get_tree().get_nodes_in_group("DragAndDrop"):
		node.show()
	anim.play("show")
	yield(anim, "animation_finished")

func hide():
	for node in get_tree().get_nodes_in_group("DragAndDrop"):
		node.hide()
	play_button.visible = false
	anim.play("hide")
	yield(anim, "animation_finished")

func reset():
	yield(show(), "completed")
	if selected_yin_node:
		selected_yin_node.unselect()
	if selected_yang_node:
		selected_yang_node.unselect()

func update_play_visible():
	if selected_yin_node and selected_yang_node and can_afford_energy():
		play_button.visible = true
	else:
		play_button.visible = false

func can_afford_energy():
	if not player:
		return false
	return player.can_consume_energy(selected_cost())

func selected_cost():
	var total_cost = 0
	if selected_yin_node:
		total_cost += selected_yin_node.cost
	if selected_yang_node:
		total_cost += selected_yang_node.cost
	return total_cost

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
		"cost": selected_cost()
	}
	emit_signal("accepted_stats", stats)

func update_bars():
	if not player:
		print("GAME UI NOT FOUND PLAYER")
		return
	energy_bar.upd_value(player.energy)
	health_bar.upd_value(player.get_remaining_health())

func show_game_over(player_win, message):
	# show game over panel
	$Bottom.queue_free()
	game_over.visible = true
	game_over.set_message(message)
	if player_win:
		game_over.set_winner("YOU WIN")
	else:
		game_over.set_winner("YOU LOSE")

func show_turn(message):
	$Screen/TurnMessage.text = message
	anim.play("show_turn")
	yield(anim, "animation_finished")

func _on_GameOver_exit():
	var title_scene = load("res://scenes/TitleScreen.tscn")
	get_tree().change_scene_to(title_scene)

func _on_GameOver_play_again():
	game.delete_game()
	get_tree().reload_current_scene()
