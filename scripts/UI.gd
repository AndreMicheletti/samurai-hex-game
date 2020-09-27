extends CanvasLayer

onready var BottomUI = $BottomUI
onready var LeftUI = $LeftUI
onready var PlayTurnUI = $PlayTurnUI

onready var cards_container = $BottomUI/SplitContainer/CardsContainer

export(NodePath) var playerControllerPath
onready var player_controller = get_node(playerControllerPath)

onready var Card = preload("res://scenes/Card.tscn")

func _ready():
	LeftUI.visible = true
	BottomUI.visible = false
	PlayTurnUI.visible = false
	clear_cards_container()
	player_controller.connect("cards_drawn", self, "_on_cards_drawn")

func _on_GameMatch_draw_state():
	PlayTurnUI.visible = false
	BottomUI.visible = true


func _on_GameMatch_choose_card_state():
	PlayTurnUI.visible = false
	BottomUI.visible = true


func _on_GameMatch_play_state():
	PlayTurnUI.visible = true
	BottomUI.visible = false
	clear_cards_container()


func _process(delta):
	# var GameMatch = get_tree().get_nodes_in_group("GameMatch")[0]
	if player_controller and PlayTurnUI.visible == true:
		var attack = player_controller.get_character().turn_atk
		var defense = player_controller.get_character().turn_def
		var move = player_controller.get_character().turn_mov - player_controller.get_character().moved
		set_top_hud_values(move, attack, defense)


func _on_cards_drawn():
	for card in player_controller.hand:
		var instance = Card.instance()
		cards_container.add_child(instance)
		instance.set_resource(card)
		instance.connect("card_selected", player_controller, "on_select_card")


func clear_cards_container():
	for c in cards_container.get_children():
		c.queue_free()


func set_top_hud_values(move, attack, defense):
	pass

