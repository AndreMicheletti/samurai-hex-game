extends Node2D

var HexCell = preload("res://HexCell.gd")

var hex_pos = Vector2()

signal character_moved
signal character_died
signal character_damaged

export var DamageLimit = 4
var damage_counter = 0

var turn_atk = 0
var turn_def = 0
var turn_mov = 0
export var moved = 0

onready var anim_player = $AnimPlayer
onready var hitEffect = $HitEffect

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Character")
	self.damage_counter = 0

func get_world():
	return get_tree().get_nodes_in_group("World")[0]

func get_game_match():
	return get_tree().get_nodes_in_group("GameMatch")[0]

func move_to(x, y):
	get_game_match().set_ctr_process(false)
	var target_hex = Vector2(x, y)
	var target_pos = get_world().get_grid().get_hex_center(target_hex)
	var start_pos = self.position
	var path = get_world().find_path(hex_pos, target_hex)
	
	hex_pos = target_hex
	
	for hex in path:
		start_pos = self.position
		var goto_pos = get_world().get_grid().get_hex_center(hex)
		$Tween.interpolate_property(self, "position", start_pos, goto_pos, 0.2)
		$Tween.start()
		yield($Tween, "tween_completed")
	
	get_game_match().set_ctr_process(true)
	emit_signal("character_moved")


func hit(atk):
	print(self.name, " GOT ATTACKED WITH ", atk, "atk. HAS ", turn_def, " DEFENSE ")
	turn_def -= atk
	var damage = 0
	if turn_def <= 0:
		damage = abs(turn_def)
		turn_def = 0

	if damage > 0:
		damage_counter += damage
		$AnimPlayer.play("hit")
		emit_signal("character_damaged")
		#yield($AnimPlayer, "animation_finished")
	print(" // SUFFERED (", damage, ")")
	if damage_counter >= DamageLimit:
		print("CHARACTER ", self.name, " DIED")
		emit_signal("character_died")


func teleport_to(x, y):
	hex_pos = Vector2(x, y)
	self.position = get_world().get_grid().get_hex_center(hex_pos)


func get_cell():
	return HexCell.new(hex_pos)


func set_turn_stats(card : CardResource):
	print("SET TURN STATS ", card.card_title)
	turn_mov = card.card_mov
	turn_atk = card.card_atk
	turn_def = card.card_def
	moved = 0
