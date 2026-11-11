extends CharacterBody2D
## Feet anchor is shared by collisions, animation, and Y sorting.
signal died
@export var speed: float = 190.0
const ATTACK_DURATION := 0.28
const ATTACK_COOLDOWN := 0.65
const ATTACK_RANGE := 96.0
var elapsed := 0.0
var moving := false
var controls_enabled := true
var input_override := Vector2.ZERO
var test_input := false
var facing := Vector2.DOWN
var animation_state := "idle"
var dead := false
var death_time := 0.0
var attack_time := 0.0
var cooldown := 0.0
@onready var visual: Sprite2D = $Visual

func try_attack() -> bool:
	if dead or not controls_enabled or cooldown > 0.0:
		return false
	attack_time = ATTACK_DURATION
	cooldown = ATTACK_COOLDOWN
	return true

func can_hit(target: Vector2) -> bool:
	var offset := target - global_position
	return not dead and attack_time > 0.0 and offset.length() <= ATTACK_RANGE and (offset.length() < 1.0 or facing.dot(offset.normalized()) >= 0.25)

func die() -> void:
	if dead:
		return
	dead = true
	controls_enabled = false
	velocity = Vector2.ZERO
	attack_time = 0.0
	animation_state = "death"
	died.emit()

func _physics_process(delta: float) -> void:
	if dead:
		death_time += delta
		visual.rotation = minf(death_time * 3.0, PI / 2)
		visual.modulate = Color(1.0, 0.45, 0.35, maxf(0.0, 1.0 - death_time))
		visual.position.y = -30.0 + minf(death_time * 20.0, 20.0)
		queue_redraw()
		return
	if not controls_enabled:
		return
	cooldown = maxf(0.0, cooldown - delta)
	attack_time = maxf(0.0, attack_time - delta)
	if not test_input and Input.is_action_just_pressed("attack"):
		try_attack()
	var direction := input_override if test_input else Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0.01:
		facing = Vector2(signf(direction.x), 0) if absf(direction.x) > absf(direction.y) else Vector2(0, signf(direction.y))
	var running := Input.is_action_pressed("sprint") and not test_input
	velocity = direction.limit_length() * speed * (1.5 if running else 1.0) * (0.35 if attack_time > 0 else 1.0)
	var previous := position
	move_and_slide()
	moving = position.distance_to(previous) > 0.05
	elapsed += delta * (14.0 if running else 10.0) if moving else delta * 2.0
	animation_state = "attack" if attack_time > 0 else ("run" if running else "walk") if moving else "idle"
	visual.flip_h = facing.x < 0.0
	visual.modulate = Color("c1d2ec") if facing == Vector2.UP else Color.WHITE
	visual.position.y = -30.0 - absf(sin(elapsed)) * (4.0 if moving else 0.6)
	visual.rotation = sin(elapsed) * (0.06 if moving else 0.0) + facing.x * 0.08
	visual.scale = Vector2(2, 2) * Vector2(1.0 + sin(elapsed) * 0.035, 1.0 - sin(elapsed) * 0.035)
	if attack_time > 0:
		visual.modulate = Color("fff09c")
		visual.scale *= Vector2(1.15, 0.9)
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(0, -2), 0.0, Vector2(1.0, 0.32))
	draw_circle(Vector2.ZERO, 21, Color(0.02, 0.06, 0.04, 0.36))
	draw_set_transform(Vector2.ZERO)
	if not dead:
		# Facing indicator makes all four directions clear even with the supplied single sprite.
		var tip := facing * 27.0
		var side := facing.orthogonal() * 5.0
		draw_colored_polygon(PackedVector2Array([tip + facing * 8, tip + side, tip - side]), Color("f5df84"))
	if attack_time > 0:
		var strength := attack_time / ATTACK_DURATION
		var angle := facing.angle()
		draw_arc(Vector2.ZERO, ATTACK_RANGE, angle - 1.31, angle + 1.31, 24, Color(1, 0.88, 0.28, strength), 4)
		for i in 5:
			var ray := facing.rotated((i - 2) * 0.5)
			var points := PackedVector2Array([ray * 28, ray * 50 + ray.orthogonal() * 9, ray * 62 - ray.orthogonal() * 7, ray * ATTACK_RANGE])
			draw_polyline(points, Color(1, 0.95, 0.55, strength), 3)
