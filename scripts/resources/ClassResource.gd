extends Resource

class_name ClassResource

enum Passive {IGNORE_DEF, ATK_PUSH, DEF_COUNTER}

export(int) var id
export(String) var name
export(Resource) var characterTexture
export(Resource) var handTexture
export(Passive) var passiveHability

func _init(p_class_id = 0, p_class_name = "",
			p_class_char_texture = null, p_class_hand_texture = null,
			p_passive = Passive.IGNORE_DEF):
	id = p_class_id
	name = p_class_name
	characterTexture = p_class_char_texture
	handTexture = p_class_hand_texture
	passiveHability = p_passive
