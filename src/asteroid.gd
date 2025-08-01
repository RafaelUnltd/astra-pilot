extends RigidBody2D

enum AsteroidSize {BIG, MEDIUM, SMALL}

signal shard_generated(pos: Vector2, rot: float, lin_velocity: Vector2, size: AsteroidSize)

const MIN_SHARDS := 2
const MAX_SHARDS := 4

const ASTEROID_SCALE := {
	AsteroidSize.BIG: 2,
	AsteroidSize.MEDIUM: 1,
	AsteroidSize.SMALL: 1
}

const ASTEROID_DAMAGE := {
	AsteroidSize.BIG: 45.0,
	AsteroidSize.MEDIUM: 15.0,
	AsteroidSize.SMALL: 5.0
}

const ASTEROID_SCORE := {
	AsteroidSize.BIG: 50.0,
	AsteroidSize.MEDIUM: 30.0,
	AsteroidSize.SMALL: 10.0
}

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
	var _asteroid_scale = ASTEROID_SCALE[_current_size]
	$AnimatedSprite2D.scale = Vector2(_asteroid_scale, _asteroid_scale * 0.9)
	$CollisionShape2D.scale = Vector2(_asteroid_scale, _asteroid_scale)

func take_damage():
	hide()
	
	if !(_current_size == AsteroidSize.SMALL):
		var total_shards := randi_range(MIN_SHARDS, MAX_SHARDS)
		for i in total_shards:
			_generate_shard()
	
	queue_free()

func get_damage() -> float:
	return ASTEROID_DAMAGE[_current_size]

func get_score() -> float:
	return ASTEROID_SCORE[_current_size]

func _generate_shard():
	var new_size := AsteroidSize.BIG
	
	if _current_size == AsteroidSize.BIG:
		new_size = AsteroidSize.MEDIUM
	elif _current_size == AsteroidSize.MEDIUM:
		new_size = AsteroidSize.SMALL
	
	var shard_rotation := rotation + randf_range(-PI / 8, PI / 8)
	shard_generated.emit(position, shard_rotation, linear_velocity.rotated(shard_rotation), new_size)
