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
var hand = []

# attack animations emit this to play the defense animation on target character
signal anim_hit

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Character")
	hex_pos = Vector2(0, 0)

func teleport_to(pos : Vector2):
	position = world.get_grid().get_hex_center(pos)
	hex_pos = pos

func look_to_hex(target: Vector2):
	var hex_center = world.get_grid().get_hex_center(target)
	var result = hex_center - global_position
	global_rotation = atan2(result.y, result.x) - 30

func move_to(target : Vector2):
	if moving:
		return
	self.moving = true
	var path = world.find_path(self.hex_pos, target)
	
	if path.size() > 1:
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
		self.hex_pos = target
	# finally
	play_idle()
	self.moving = false

func deal_cards(n):
	for i in range(n):
		var card = deck.deal()
		hand.append(card)

func play(anim_name):
	$anim.stop(true)
	$anim.play(anim_name)

func play_dash():
	play("dash2")

func play_idle():
	play("idle")

func play_hit():
	play("hit")

func play_defend():
	play("defend")

func play_dodge():
	play("dodge")

func emit_anim_hit():
	emit_signal("anim_hit", self)
