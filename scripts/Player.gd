extends "res://scripts/MapObject.gd"


export(NodePath) var highlights_path = null

onready var highlights = get_node(highlights_path)

var move_hint = preload("res://scenes/tileset/MoveHint.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	move_to(1, 1)


func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		move_to(self.hex_pos.x + 1, self.hex_pos.y)
	if Input.is_action_just_pressed("ui_left"):
		move_to(self.hex_pos.x - 1, self.hex_pos.y)
	if Input.is_action_just_pressed("ui_down"):
		move_to(self.hex_pos.x, self.hex_pos.y - 1)
	if Input.is_action_just_pressed("ui_up"):
		move_to(self.hex_pos.x, self.hex_pos.y + 1)
		
	if Input.is_action_just_pressed("space"):
		clear_highlights()
		for cell in get_cell().get_all_within(2):
			if cell.get_axial_coords() == hex_pos:
				continue
			var instance = move_hint.instance()
			instance.hex_pos = cell.get_axial_coords()
			instance.position = HexGrid.get_hex_center(cell)
			instance.connect("move_hint_clicked", self, "move_hint_clicked")
			highlights.add_child(instance)

func clear_highlights():
	for node in highlights.get_children():
		node.queue_free()


func move_hint_clicked(move_hex_pos):
	move_to(move_hex_pos.x, move_hex_pos.y)
	clear_highlights()
