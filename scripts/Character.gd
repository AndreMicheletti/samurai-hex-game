extends Node2D

class_name Character

enum CharacterClass {Samurai, Lancer, Wanderer}

export(String) var PlayerName = "Player"
export(int) var Health = 4
export(CharacterClass) var character_class

export(Resource) var deck

onready var world = get_parent()
onready var game = world.get_parent()

var hex_pos = Vector2()
var moving = false
var damage = 0
var moved = 0
var hand = []
var active = false
var defeated = false

var selected_card = null

# attack animations emit this to play the defense animation on target character
signal anim_hit
signal card_dealed
signal card_selected

signal move_ended
signal turn_started
signal turn_ended

signal character_hit
signal character_defeated

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Character")
	hex_pos = Vector2(0, 0)
	shuffle_deck()

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

func move_to(target : Vector2):
	if moving or not active:
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

func on_select_card(card_res : CardResource):
	var index = hand.find(card_res)
	if index >= 0:
		print("FOUND CARD IN HAND! INDEX ", index)
		select_card(index)
	else:
		print("NOT FOUND CARD ", card_res.title, " IN HAND ", hand)

func shuffle_deck():
	deck.shuffle()

func deal_cards(n):
	for i in range(n):
		var card = deck.deal()
		emit_signal("card_dealed", card)
		hand.append(card)

func select_card(index):
	selected_card = hand[index]
	hand.remove(index)
	emit_signal("card_selected", selected_card)

func play_turn():
	print("PLAYER PLAY TURN!! ")
	moved = 0
	emit_signal("turn_started", self)
	# yield(get_tree().create_timer(0.5), "timeout")
	# emit_signal("turn_ended")

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

func attacked():
	pass

func defended():
	pass

func hit(atk_damage):
	emit_signal("character_hit", self, atk_damage)
	self.damage += atk_damage
	if get_remaining_health() <= 0:
		defeated = true
		emit_signal("character_defeated", self)

func play(anim_name):
	$anim.stop(true)
	$anim.play(anim_name)

func play_attack(card_res : CardResource):
	match card_res.anim:
		CardResource.AttackAnim.SLASH:
			play("attack_slash")			
		CardResource.AttackAnim.PIERCE:
			play("attack_pierce")
		CardResource.AttackAnim.UPPER:
			play("attack_upper")

func play_dash():
	play("dash2")

func play_idle():
	play("idle")

func play_hit():
	play("hit")
	yield($anim, "animation_finished")

func play_defend():
	play("defend")
	yield($anim, "animation_finished")

func play_dodge():
	play("dodge")
	yield($anim, "animation_finished")

func emit_anim_hit():
	emit_signal("anim_hit", self)
