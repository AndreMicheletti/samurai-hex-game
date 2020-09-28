extends CanvasLayer


onready var tween = $Tween
onready var Player1 = $Player1
onready var Player2 = $Player2

onready var top_deal = $TopDeal
onready var bottom_deal = $BottomDeal

onready var player1_play_button = $Player1/Center/Play/Button
onready var player1_center_cards = $Player1/Center/HBox/Cards/Container
onready var player1_left_cards = $Player1/Left/Split/CardsMargin/CardsContainer

onready var player2_center_cards = $Player2/Center/HBox/Cards/Container
onready var player2_right_cards = $Player2/Right/Split/CardsMargin/CardsContainer

onready var card = preload("res://scenes/gui/Card.tscn")

export(Array, Resource) var card_list

signal card_selected
signal card_deselected

signal accepted_cards

# Called when the node enters the scene tree for the first time.
func _ready():
	player1_play_button.visible = false
	for x in card_list:
		yield(player_deal(player1_center_cards, bottom_deal, x), "completed")
	for x in card_list:
		yield(player_deal(player2_center_cards, top_deal, x), "completed")


func player_deal(center_cards, deal_ref, card_res : CardResource):
	
	var new_card = card.instance()
	var target_index = get_player_center_cards_count(center_cards)
	var offset_pos = center_cards.get_child(target_index).get_global_transform()[2]
	var start_pos = deal_ref.get_global_transform()[2]
	start_pos.x -= offset_pos.x
	var target_pos = Vector2(0, 0)

	center_cards.get_child(target_index).add_child(new_card)
	new_card.set_resource(card_res)
	new_card.connect("card_selected", self, "on_card_selected")
	new_card.rect_position = start_pos
	
	$Tween.interpolate_property(
		new_card, "rect_position", start_pos, target_pos, 0.4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.0
	)
	$Tween.start()
	yield($Tween, "tween_completed")
	new_card.enable_interaction = true


func move_cards_to_slot():
	var selected_card_nodes = get_selected_cards()
	selected_card_nodes.sort_custom(self, "sort_by_card_index")
	var not_selected_card_nodes = get_not_selected_cards()
	
	# Bring down not used cards
	for node in not_selected_card_nodes:
		var target_pos = bottom_deal.get_global_transform()[2]
		var start_pos = Vector2(0, 0)
		target_pos.x -= node.get_global_transform()[2].x
		$Tween.interpolate_property(
			node, "rect_position", start_pos, target_pos, 0.3,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.0
		)
		$Tween.start()
		yield($Tween, "tween_completed")
		node.queue_free()
	
	# Send to left selected cards
	for i in range(0, 3):
		var left_slot : ReferenceRect = get_player1_side_slot(i)
		var card_node = selected_card_nodes[i]
		card_node.enable_interaction = false
		card_node.hide_index()
		
		var offset_pos = left_slot.get_global_transform()[2]
		var card_pos = card_node.get_parent().get_global_transform()[2]
		var start_pos = Vector2(
			card_pos.x,
			card_pos.y - offset_pos.y
		)
		var target_pos = Vector2(0, 0)
		
		card_node.get_parent().remove_child(card_node)
		# card_node.queue_free()
		left_slot.add_child(card_node)
		card_node.rect_position = start_pos
		
		$Tween.interpolate_property(
			card_node, "rect_position", start_pos, target_pos, 0.5,
			Tween.TRANS_BACK, Tween.EASE_OUT, 0.0
		)
		$Tween.start()
		yield($Tween, "tween_completed")

func get_player_center_cards_count(center_cards):
	var count = 0
	for child in center_cards.get_children():
		count += child.get_child_count()
	return count

func get_player1_left_cards_count():
	var count = 0
	for child in player1_left_cards.get_children():
		count += child.get_child_count()
	return count

func get_player1_side_slot(index):
	return player1_left_cards.get_child(index)

func get_selected_cards():
	var result = []
	for card_slot in player1_center_cards.get_children():
		if card_slot.get_child(0) and card_slot.get_child(0).selected:
			result.append(card_slot.get_child(0))
	return result

func get_not_selected_cards():
	var result = []
	for card_slot in player1_center_cards.get_children():
		if card_slot.get_child(0) and card_slot.get_child(0).selected == false:
			result.append(card_slot.get_child(0))
	return result

func on_card_selected(card_node : Card):
	# var left_count = get_player1_left_cards_count()
	if card_node.selected:
		# Remove selection
		for node in get_selected_cards():
			if node.card_index > card_node.card_index:
				node.card_index = node.card_index - 1
			node.show_index()
		card_node.rect_position.y = 0
		card_node.selected = false
		card_node.card_index = null
		card_node.hide_index()
	elif get_selected_cards().size() < 3:
		# Add selection
		card_node.rect_position.y = -30
		card_node.selected = true
		card_node.card_index = get_selected_cards().size()
		card_node.show_index()
	player1_play_button.visible = get_selected_cards().size() > 2

func _on_Button_pressed():
	var card_resources = []
	for card_node in get_selected_cards():
		card_resources.append(card_node.get_resource())
	emit_signal("accepted_cards", card_resources)
	print("ACCEPTED CARDS ", card_resources)
	move_cards_to_slot()

func sort_by_card_index(node1 : Card, node2 : Card):
	if node1.card_index < node2.card_index:
		return true
	return false

