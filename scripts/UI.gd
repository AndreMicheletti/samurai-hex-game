extends CanvasLayer

onready var BottomUI = $BottomUI
onready var TopHUD = $TopHUD

func _ready():
	TopHUD.visible = false
	BottomUI.visible = false

func _on_GameMatch_draw_state():
	TopHUD.visible = false
	BottomUI.visible = true


func _on_GameMatch_choose_card_state():
	TopHUD.visible = false
	BottomUI.visible = true


func _on_GameMatch_play_state(card_info):
	TopHUD.visible = true
	BottomUI.visible = false


func _process(delta):
	var GameMatch = get_tree().get_nodes_in_group("GameMatch")[0]
	var attack = GameMatch.turn_atk
	var defense = GameMatch.turn_def
	var move = GameMatch.turn_mov
	set_top_hud_values(move, attack, defense)


func set_top_hud_values(move, attack, defense):
	
	TopHUD.get_node("HUD/AttackInfo/TextContainer/Label").text = str(attack)
	TopHUD.get_node("HUD/MoveInfo/TextContainer/Label").text = str(move)
	TopHUD.get_node("HUD/DefenseInfo/TextContainer/Label").text = str(defense)
