extends CharacterBody2D
## The body's origin is at its feet, shared by its collider and Y-sort anchor.
@export var speed: float = 190.0
var elapsed := 0.0
var moving := false
var controls_enabled := true
var input_override := Vector2.ZERO
var test_input := false
@onready var visual: Sprite2D = $Visual

func _physics_process(delta: float) -> void:
	var direction := input_override if test_input else Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if not controls_enabled:
		direction = Vector2.ZERO
	var running := Input.is_action_pressed("sprint") and not test_input
	velocity = direction.limit_length() * speed * (1.5 if running else 1.0)
	var previous := position
	move_and_slide()
	moving = position.distance_to(previous) > 0.05
	if moving:
		elapsed += delta * (14.0 if running else 10.0)
		visual.position.y = -30.0 - absf(sin(elapsed)) * 3.0
		visual.rotation = sin(elapsed) * 0.025
		if absf(direction.x) > 0.01:
			visual.flip_h = direction.x < 0.0
	else:
		elapsed = 0.0
		visual.position.y = -30.0
		visual.rotation = 0.0
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(0, -2), 0.0, Vector2(1.0, 0.32))
	draw_circle(Vector2.ZERO, 21, Color(0.02, 0.06, 0.04, 0.36))
