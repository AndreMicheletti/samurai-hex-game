extends Character

enum AIMode {RANDOM, BALANCED, AGRESSIVE, DEFENSIVE}

var ai_mode = AIMode.RANDOM

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()

func choose_card():
	match ai_mode:
		AIMode.RANDOM:
			randomize()
			select_card(randi() % hand.size())
		AIMode.BALANCED:
			pass
		AIMode.AGGRESSIVE:
			pass
		AIMode.DEFENSIVE:
			pass

func play_turn():
	print("ENEMY PLAY TURN!! ")
	yield(get_tree().create_timer(0.5), "timeout")
	end_turn()
	
func end_turn():
	if not active:
		return
	active = false
	moved = 0
	look_to_hex(game.player.hex_pos)
	emit_signal("turn_ended", self)
