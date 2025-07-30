extends Area2D

signal health_updated(value: float)
signal score_updated(value: float)
signal died()

@export var speed := 350.0
@export var projectile_scene: PackedScene

const SCALAR_PROJECTILE_OFFSET_X := 70.0
const SPEED_BOOST_RATE := 1.5
const BOOSTED_THRUSTER_LIFETIME := 0.4
const DEFAULT_THRUSTER_LIFETIME := 0.25
const MAX_HEALTH := 100.0

var health: float = MAX_HEALTH
var score: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	hide()
	health_updated.emit(health)

func _process(delta: float):
	_update_player_rotation()
	_update_player_position(delta)
	_update_thruster_particles()
	_fire_if_requested()

func _update_player_rotation():
	var joystick_vector := Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	if joystick_vector.length() > 0:
		rotation = joystick_vector.angle()
		return
	look_at(get_global_mouse_position())

func _update_player_position(delta: float):
	var velocity: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		velocity.y = -1
	if Input.is_action_pressed("move_down"):
		velocity.y = 1
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
	
	var current_speed := speed
	if Input.is_action_pressed("boost"):
		current_speed = speed * SPEED_BOOST_RATE
		
	velocity = velocity.normalized() * current_speed
	var deltaMovement = velocity * delta
	
	position += deltaMovement
	return

func _update_thruster_particles():
	if Input.is_action_pressed("boost") && !is_dead:
		$ThrusterParticles.lifetime = BOOSTED_THRUSTER_LIFETIME
		return
	$ThrusterParticles.lifetime = DEFAULT_THRUSTER_LIFETIME

func _fire_if_requested():
	
	if !Input.is_action_just_pressed("fire") || is_dead: return
	
	var projectile = projectile_scene.instantiate()
	var offset = global_transform.basis_xform(Vector2.RIGHT) * SCALAR_PROJECTILE_OFFSET_X
	projectile.position = position + offset
	projectile.rotation = rotation
	
	projectile.connect("asteroid_hit", _on_asteroid_hit)
	
	add_sibling(projectile)

func start_at_position(pos: Vector2):
	position = pos
	show()

func take_damage(damage: float):
	health = clampf(health - damage, 0, MAX_HEALTH) 
	health_updated.emit(health)
	$HitSound.play()
	if health == 0:
		# Play explosion particles
		is_dead = true
		$ThrusterSound.stop()
		died.emit()
		hide()

func _on_asteroid_hit(value: float):
	score += value
	score_updated.emit(score)

func _on_body_entered(body: Node2D) -> void:
	if is_dead: return
	if body.is_in_group("asteroids") && body.has_method("get_damage"):
		take_damage(body.get_damage())
		body.call("queue_free")
