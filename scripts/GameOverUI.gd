extends Panel

onready var winner_label = $VBox/Top/VBox/Winner
onready var message_label = $VBox/Top/VBox/Message

signal play_again
signal exit

func _ready():
	visible = false

func set_message(message):
	message_label.text = message

func set_winner(winner):
	winner_label.text = winner

func _on_PlayAgain_pressed():
	emit_signal("play_again")

func _on_Exit_pressed():
	emit_signal("exit")
