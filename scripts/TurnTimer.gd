extends Control

const TIME = 5

onready var timer = $Timer
onready var progress = $ProgressBar

signal timeout

func _ready():
	progress.value = TIME
	progress.visible = false
	progress.max_value = TIME
	timer.wait_time = TIME

func start():
	timer.start()
	progress.visible = true

func stop():
	timer.stop()
	progress.value = TIME
	progress.visible = false

func _process(delta):
	if not timer.is_stopped():
		progress.value = timer.time_left

func _on_timeout():
	stop()
	emit_signal("timeout")
