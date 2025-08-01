extends CanvasLayer

func update_health(health: float):
	$HealthContainer/HealthBar.value = health

func update_score(score: float):
	$ScoreContainer/ScoreText.text = str(score)
	
func show_game_over():
	$GameOverText.visible = true
