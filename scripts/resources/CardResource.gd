extends Resource

class_name CardResource

export(int) var id
export(String) var title
export(int) var mov
export(int) var atk
export(int) var def
export(int) var speed

func _init(p_card_id = 0, p_card_title = "", 
		p_card_mov = 0, p_card_atk = 0, p_card_def = 0, p_card_speed = 1):
	id = p_card_id
	title = p_card_title
	mov = p_card_mov
	atk = p_card_atk
	def = p_card_def
	speed = p_card_speed
