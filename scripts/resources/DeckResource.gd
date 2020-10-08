extends Resource

class_name DeckResource

export(int) var id
export(String) var name
export(Array, Resource) var cards

func _init(p_deck_id = 0, p_deck_name = "", p_deck_cards = []):
	id = p_deck_id
	name = p_deck_name
	cards = p_deck_cards
