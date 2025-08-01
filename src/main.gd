extends Node2D

@export var asteroid_scene: PackedScene

const Asteroid = preload("res://src/asteroid.gd")

const MIN_ASTEROID_SPEED: float = 250.0
const MAX_ASTEROID_SPEED: float = 400.0
const GAME_OVER_TEXT_TIME: float = 5.0
const TIME_TO_MAX_DIFICULTY: float = 150.0
const INITIAL_WAIT_TIME: float = 0.5

var _total_time_elapsed: float = 0
var _dificulty_rate: float = 1

func _ready() -> void:
	$Player.start_at_position($PlayerSpawn.position)
	$AsteroidSpawnTimer.start()

func _process(delta: float) -> void:
	_total_time_elapsed += delta 
	_update_dificulty_rate()

func _update_dificulty_rate():
	# at TIME_TO_MAX_DIFICULTY seconds reach the max dificulty
	_dificulty_rate = 1 + clampf(_total_time_elapsed / TIME_TO_MAX_DIFICULTY, 0, 1)
	$AsteroidSpawnTimer.wait_time = INITIAL_WAIT_TIME / _dificulty_rate

func _on_asteroid_spawn_timeout() -> void:
	# Gets a random location around the path
	var spawn_location = $AsteroidPath/AsteroidSpawnLocation
	spawn_location.progress_ratio = randf()
	
	# Sets the correct rotation (pointing inside the screen)
	var spawn_rotation = spawn_location.rotation + (PI/2) + randf_range(-PI/4, PI/4)
	# Adds a random velocity
	var spawn_speed := randf_range(MIN_ASTEROID_SPEED * _dificulty_rate, MAX_ASTEROID_SPEED * _dificulty_rate)
	var velocity = Vector2(spawn_speed, 0.0).rotated(spawn_rotation)
	
	# Calls asteroid creation with the calculated values
	_create_asteroid(spawn_location.position, spawn_rotation, velocity, Asteroid.AsteroidSize.BIG)

func _on_asteroid_shard_generated(pos: Vector2, rot: float, lin_velocity: Vector2, size: Asteroid.AsteroidSize):
	_create_asteroid(pos, rot, lin_velocity, size)

func _create_asteroid(pos: Vector2, rot: float, lin_velocity: Vector2, size: Asteroid.AsteroidSize):
	var new_asteroid = asteroid_scene.instantiate()
	
	# Sets all needed variables for transform and movement
	new_asteroid.position = pos
	new_asteroid.rotation = rot
	new_asteroid.linear_velocity = lin_velocity
	new_asteroid.set_asteroid_size(size)
	
	# Connects the signal to shard the asteroid
	new_asteroid.connect("shard_generated", _on_asteroid_shard_generated)
	
	# Adds the new asteroid to the scene
	call_deferred("add_child", new_asteroid)

func _on_player_health_updated(value: float) -> void:
	$HUD.update_health(value)

func _on_player_score_updated(value: float) -> void:
	$HUD.update_score(value)

func _on_player_died(death_position: Vector2) -> void:
	$HUD.show_game_over()
	$GameOverSound.play()
	$PlayerExplosion.position = death_position
	$PlayerExplosion.emitting = true
	await get_tree().create_timer(GAME_OVER_TEXT_TIME).timeout
	get_tree().change_scene_to_file("res://scenes/levels/menu.tscn")
