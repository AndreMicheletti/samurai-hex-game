extends Node2D

class_name Character

export(String) var PlayerName = "Player"
export(int) var Health = 4
export(Resource) var characterClass

# export(Resource) var deck

onready var world = get_parent()
onready var game = world.get_parent()

var hex_pos = Vector2()
var gameplay_deck = []
var moving = false
var damage = 0
var moved = 0
var hand = []
var advantage = false # if true, will attack first on next turn
var active = false
var defeated = false

var selected_card = null

# attack animations emit this to play the defense animation on target character
signal anim_hit
signal card_dealed
signal card_selected
signal deck_depleted

signal move_ended
signal turn_started
signal turn_ended

signal character_hit
signal character_defeated

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Character")
	hex_pos = Vector2(0, 0)
	init_deck()
	$Pivot/character.texture = characterClass.characterTexture
	$Pivot/character/Position2D/hand.texture = characterClass.handTexture
	if characterClass.name == "Elite":
		$Pivot/character/Position2D/hand.offset = Vector2(-17, 0)

func init_deck():
	gameplay_deck = characterClass.deckResource.cards.duplicate(true)
	gameplay_deck.shuffle()

func teleport_to(pos : Vector2):
	position = world.get_grid().get_hex_center(pos)
	hex_pos = pos

func look_to_hex(target: Vector2):
	var hex_center = world.get_grid().get_hex_center(target)
	var result = hex_center - global_position
	global_rotation = atan2(result.y, result.x) - 30

func _process(delta):
	if not active:
		return
	if moved >= selected_card.mov:
		end_turn()

func move_to(target : Vector2, turn = true, ignore_flags = false):
	if not ignore_flags and (moving or not active):
		return
	var path = world.find_path(self.hex_pos, target)	
	if path.size() > 1 and (path.size() - 1) <= get_remaining_moves():
		self.moving = true
		# if has path
		play_dash()
		for hex in path:
			var hex_coords = hex.get_axial_coords()
			if hex_coords == self.hex_pos:
				continue
			if turn:
				look_to_hex(hex_coords)
			var start_pos = self.position
			var goto_pos = world.get_grid().get_hex_center(hex)
			$Tween.interpolate_property(self, "position", start_pos, goto_pos, 0.2)
			$Tween.start()
			yield($Tween, "tween_completed")
		# finally
		moved += path.size() - 1
		self.hex_pos = target
		self.moving = false
		play_idle()
	emit_signal("move_ended", self)

func get_pushed_from(attacker_hex_pos : Vector2):
	var dir = attacker_hex_pos - hex_pos
	print(hex_pos, " ATTACKED FROM ", attacker_hex_pos, "  // DIR IS ", dir)	
	var aux	
	if abs(dir.x) == 0 and abs(dir.y) != 0:
		aux = Vector2(0, dir.y)
	elif abs(dir.y) == 0 and abs(dir.x) != 0:
		aux = Vector2(dir.x, 0)
	elif abs(dir.x) != 0 and abs(dir.y) != 0:
		aux = Vector2(dir.x, dir.y)

	var dest = Vector2(hex_pos.x - aux.x, hex_pos.y - aux.y)
	var goto_pos = world.get_grid().get_hex_center(dest)
	print("BEING PUSHED TO ", dest)	
	$Tween.interpolate_property(self, "position", position, goto_pos, 0.2)
	$Tween.start()
	yield($Tween, "tween_completed")
	self.hex_pos = dest
	if world.is_obstacle(dest):
		# got pushed to an obstacle
		print(name, " PUSHED TO OBSTACLE")
		play("fall")
		yield($anim, "animation_finished")
		defeat()

func on_select_card(card_res : CardResource):
	var index = hand.find(card_res)
	if index >= 0:
		print("FOUND CARD IN HAND! INDEX ", index)
		select_card(index)
	else:
		print("NOT FOUND CARD ", card_res.title, " IN HAND ", hand)

func deal_cards(n):
	for i in range(n):
		var card = gameplay_deck.pop_back()
		if not card:
			if hand.size() == 0:
				emit_signal("deck_depleted", self)
			return
		emit_signal("card_dealed", card)
		hand.append(card)

func deck_count():
	return gameplay_deck.size()

func select_card(index):
	selected_card = hand[index]
	hand.remove(index)
	emit_signal("card_selected", selected_card)

func play_turn():
	print("PLAYER PLAY TURN!! ")
	moved = 0
	emit_signal("turn_started", self)

func end_turn():
	if not active:
		return
	active = false
	moved = 0
	look_to_hex(game.enemy.hex_pos)
	emit_signal("turn_ended", self)

func on_pressed_hex(hex):
	if active and not moving:
		move_to(hex.get_axial_coords())

func get_remaining_health():
	return Health - damage

func get_remaining_moves():
	return selected_card.mov - moved

func get_cell():
	return world.HexCell.new(hex_pos)

func attacked(defensor):
	set_attack_advantage(false)
	if characterClass.passiveHability == ClassResource.Passive.ATK_PUSH:
		yield(defensor.get_pushed_from(hex_pos), "completed")
	yield(get_tree().create_timer(0.1), "timeout")

func defended(attacked):
	if characterClass.passiveHability == ClassResource.Passive.DEF_COUNTER:
		set_speed_advantage(true)
	yield(get_tree().create_timer(0.1), "timeout")

func set_speed_advantage(value):
	advantage = value
	$AdvantageP.emitting = value

func set_attack_advantage(value):
	$Pivot/character/Position2D/FlamesP.emitting = value

func hit(atk_damage):
	emit_signal("character_hit", self, atk_damage)
	self.damage += atk_damage
	if get_remaining_health() <= 0:
		defeat()

func play(anim_name):
	$anim.stop(true)
	$anim.play(anim_name)

func play_attack(card_res : CardResource):
	play(card_res.anim)

func play_defend(card_res : CardResource):
	play(card_res.def_anim)
	yield($anim, "animation_finished")

func play_dash():
	play("dash2")

func play_idle():
	play("idle")

func play_hit():
	play("hit")
	yield($anim, "animation_finished")

func emit_anim_hit():
	emit_signal("anim_hit", self)

func defeat():
	defeated = true
	emit_signal("character_defeated", self)
