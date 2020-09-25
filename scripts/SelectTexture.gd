extends Sprite

export(Array, Texture) var allowedTextures

# Called when the node enters the scene tree for the first time.
func _ready():
	self.texture = allowedTextures[randi() % allowedTextures.size()]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
