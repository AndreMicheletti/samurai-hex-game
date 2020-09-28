extends Resource

class_name CardResource

export(int) var card_id
export(String) var card_title
export(int) var card_mov
export(int) var card_atk
export(int) var card_def
export(int) var card_speed

func _init(p_card_id = 0, p_card_title = "", 
		p_card_mov = 0, p_card_atk = 0, p_card_def = 0, p_card_speed = 1):
	card_id = p_card_id
	card_title = p_card_title
	card_mov = p_card_mov
	card_atk = p_card_atk
	card_def = p_card_def
	card_speed = p_card_speed
