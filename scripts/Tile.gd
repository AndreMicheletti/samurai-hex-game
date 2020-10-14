extends Node2D

export(bool) var passable = false
export(Vector2) var hex_pos = Vector2(0, 0)
export(Array, Resource) var textures_random = []

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Tile")
	if passable:
		add_to_group("PassableTile")
	else:
		add_to_group("ObstacleTile")
	select_texture(textures_random)

func select_texture(res_list):
	if res_list.size() == 0:
		return
	var res = res_list[0]
	if res_list.size() > 1:
		randomize()
		res = res_list[randi() % res_list.size()]
	$Sprite.texture = res
