extends HBoxContainer

export(Resource) var filledTexture
export(Resource) var emptyTexture

export(int) var current_value = 5
export(int) var max_value = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	upd_value(current_value)

func upd_value(new_val):
	current_value = new_val
	for i in range(max_value):
		var child = get_child(i).get_child(0)
		if i < new_val:
			child.texture = filledTexture
		else:
			child.texture = emptyTexture
