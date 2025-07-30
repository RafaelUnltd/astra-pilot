extends Area2D

signal asteroid_hit(score: float)

@export var speed: float = 2500.0

func _process(delta: float) -> void:
	var direction = global_transform.basis_xform(Vector2.RIGHT)
	position += direction * speed * delta

func _on_exit_screen() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	var has_necessary_methods := body.has_method("take_damage") && body.has_method("get_score")
	if body.is_in_group("asteroids") && has_necessary_methods:
		asteroid_hit.emit(body.get_score())
		body.take_damage()
