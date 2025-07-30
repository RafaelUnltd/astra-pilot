extends RigidBody2D

enum AsteroidSize {BIG, MEDIUM, SMALL}

signal shard_generated(pos: Vector2, rot: float, lin_velocity: Vector2, size: AsteroidSize)

const MIN_SHARDS := 2
const MAX_SHARDS := 4

@export var asteroid_scene: PackedScene
var _current_size := AsteroidSize.BIG

func _ready() -> void:
	var asteroid_variations = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = asteroid_variations.pick_random()
	$AnimatedSprite2D.play()

func _on_screen_exit() -> void:
	queue_free()

func set_asteroid_size(value: AsteroidSize):
	_current_size = value
	# TODO: fix this shit
	if _current_size == AsteroidSize.BIG:
		$AnimatedSprite2D.scale = Vector2(2, 1.8)
		$CollisionShape2D.scale = Vector2(2, 2)
	elif _current_size == AsteroidSize.MEDIUM:
		$AnimatedSprite2D.scale = Vector2(1, 0.9)
		$CollisionShape2D.scale = Vector2(1, 1)
	elif _current_size == AsteroidSize.SMALL:
		$AnimatedSprite2D.scale = Vector2(0.5, 0.45)
		$CollisionShape2D.scale = Vector2(0.5, 0.5)

func take_damage():
	hide()
	
	if !(_current_size == AsteroidSize.SMALL):
		var total_shards := randi_range(MIN_SHARDS, MAX_SHARDS)
		for i in total_shards:
			_generate_shard()
	
	queue_free()

func get_damage() -> float:
	if _current_size == AsteroidSize.BIG:
		return 45.0
	if _current_size == AsteroidSize.MEDIUM:
		return 15.0
	return 5.0

func get_score() -> float:
	if _current_size == AsteroidSize.BIG:
		return 50.0
	if _current_size == AsteroidSize.MEDIUM:
		return 30.0
	return 10.0

func _generate_shard():
	var new_size := AsteroidSize.BIG
	
	if _current_size == AsteroidSize.BIG:
		new_size = AsteroidSize.MEDIUM
	elif _current_size == AsteroidSize.MEDIUM:
		new_size = AsteroidSize.SMALL
	
	var shard_rotation := rotation + randf_range(-PI / 8, PI / 8)
	shard_generated.emit(position, shard_rotation, linear_velocity.rotated(shard_rotation), new_size)
