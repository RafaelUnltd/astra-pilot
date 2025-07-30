extends CanvasLayer

func _ready() -> void:
	$CTABlinkTimeout.start()
	$StartGameCTA.visible = true

func _process(delta: float) -> void:
	_check_game_start()

func _check_game_start():
	if Input.is_anything_pressed():
		get_tree().change_scene_to_file("res://scenes/levels/main.tscn")

func _on_cta_blink_timeout() -> void:
	$StartGameCTA.visible = !$StartGameCTA.visible
