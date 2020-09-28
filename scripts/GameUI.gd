extends CanvasLayer


onready var tween = $Tween
onready var Player1 = $Player1
onready var Player2 = $Player2

onready var top_deal = $TopDeal
onready var bottom_deal = $BottomDeal

onready var player1_center_cards = $Player1/Center/HBox/Cards/Container

onready var player1_left_cards = $Player1/Left/Split/CardsMargin/CardsContainer

onready var card = preload("res://scenes/gui/Card.tscn")

export(Array, Resource) var card_list

signal card_selected
signal card_deselected

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in card_list:
		yield(player1_deal(x), "completed")


func player1_deal(card_res : CardResource):
	
	var new_card = card.instance()
	var target_index = get_player1_center_cards_count()
	var offset_pos = player1_center_cards.get_child(target_index).get_global_transform()[2]
	var start_pos = bottom_deal.get_global_transform()[2]
	start_pos.x -= offset_pos.x
	var target_pos = Vector2(0, 0)

	player1_center_cards.get_child(target_index).add_child(new_card)
	new_card.set_resource(card_res)
	new_card.connect("card_selected", self, "on_card_selected")
	new_card.rect_position = start_pos
	
	$Tween.interpolate_property(
		new_card, "rect_position", start_pos, target_pos, 0.6,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.0
	)
	$Tween.start()
	yield($Tween, "tween_completed")


func move_card_to_slot(center_index, left_index):
	var left_slot : ReferenceRect = get_player1_side_slot(left_index)
	var center_slot = player1_center_cards.get_child(center_index)
	var card_node = center_slot.get_child(0)
	
	var offset_pos = left_slot.get_global_transform()[2]
	var card_pos = card_node.get_parent().get_global_transform()[2]
	var start_pos = Vector2(
		card_pos.x,
		card_pos.y - offset_pos.y
	)
	var target_pos = Vector2(0, 0)
	
	center_slot.remove_child(card_node)
	# card_node.queue_free()
	left_slot.add_child(card_node)
	card_node.rect_position = Vector2(0, 0)
	
	$Tween.interpolate_property(
		card_node, "rect_position", start_pos, target_pos, 0.8,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.0
	)
	$Tween.start()
	yield($Tween, "tween_completed")


func return_card_to_slot(center_index, left_index):
	var left_slot : ReferenceRect = get_player1_side_slot(left_index)
	var center_slot = player1_center_cards.get_child(center_index)
	var card_node = left_slot.get_child(0)
	
	left_slot.remove_child(card_node)
	# card_node.queue_free()
	center_slot.add_child(card_node)
	card_node.rect_position = Vector2(0,0)


func get_player1_center_cards_count():
	var count = 0
	for child in player1_center_cards.get_children():
		count += child.get_child_count()
	return count

func get_player1_left_cards_count():
	var count = 0
	for child in player1_left_cards.get_children():
		count += child.get_child_count()
	return count

func get_player1_side_slot(index):
	return player1_left_cards.get_child(index)

func on_card_selected(card_node : Card):
	var left_count = get_player1_left_cards_count()
	if card_node.selected:
		# Remove selection
		var left_index = int(card_node.get_parent().name)
		var center_index = 0
		return_card_to_slot(center_index, left_index)
		card_node.selected = false
	elif left_count < 3:
		# Add selection
		var center_index = int(card_node.get_parent().name)
		var left_index = left_count
		move_card_to_slot(center_index, left_index)
		card_node.selected = true
