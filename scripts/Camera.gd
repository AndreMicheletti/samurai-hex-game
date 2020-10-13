extends Camera2D

onready var tween = $Tween
var tracked_characters = []
var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init_camera():
	tracked_characters = get_tree().get_nodes_in_group("Character")
	for charact in tracked_characters:
		print("camera connected to ", charact.name)
		charact.connect("move_ended", self, "move_to_middle")
	move_to_middle(null)

func find_middle():
	var size = tracked_characters.size()
	var x = 0
	var y = 0
	for charact in tracked_characters:
		x += charact.position.x
		y += charact.position.y
	return Vector2(x / size, y / size)
	
func move_to_middle(_charact):
	print("CAMERA MOVING TO MIDDLE")
	moving = true
	var initial = self.position
	var final = find_middle()
	tween.interpolate_property(self, "position", initial, final, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	moving = false
