extends Resource

class_name CardResource

# enum AttackAnim {SLASH, UPPER, PIERCE}

export(int) var id
export(String) var title
export(int) var mov
export(int) var atk
export(int) var def
export(int) var speed
export(String) var anim
export(String) var def_anim
export(bool) var special

func _init(p_card_id = 0, p_card_title = "", 
		p_card_mov = 0, p_card_atk = 0, p_card_def = 0,
		p_card_speed = 1, p_anim = "attack_slash", p_def_anim = "defend",
		p_special = false):
	id = p_card_id
	title = p_card_title
	mov = p_card_mov
	atk = p_card_atk
	def = p_card_def
	speed = p_card_speed
	anim = p_anim
	def_anim = p_def_anim
	special = p_special
