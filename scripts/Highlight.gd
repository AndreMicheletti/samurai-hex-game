extends Node2D

var hex_pos = Vector2()

var world
var game

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func init(p_world):
	world = p_world
	game = world.game
	position = world.get_grid().get_hex_center(hex_pos)
	for character in [game.player, game.enemy]:
		character.connect("move_ended", self, "update_visible")
		character.connect("turn_started", self, "update_visible")
		character.connect("turn_ended", self, "update_visible")
	game.connect("changed_state", self, "on_game_state_changed")

func _process(delta):
	pass

func on_game_state_changed(state):
	if state != game.Phase.PLAY:
		visible = false

func update_visible(character : Character):
	if (game.state != game.Phase.PLAY or
		hex_pos == game.player.hex_pos or
		hex_pos == game.enemy.hex_pos or
		world.is_obstacle(hex_pos)
		):
		visible = false
		return
	if character.active:
		var path = world.find_path(hex_pos, character.hex_pos)
		if (path.size()) <= character.get_remaining_moves():
			visible = true
		else:
			visible = false
