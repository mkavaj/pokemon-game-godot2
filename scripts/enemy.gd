extends CharacterBody2D
## Independent patrol: solid-world collision and a separate player contact sensor.
@export var patrol_offset := Vector2(150, 0)
@export var speed := 62.0
var origin := Vector2.ZERO
var outbound := true
var defeated := false
var fade_time := 0.0
var elapsed := 0.0
@onready var level: Node2D = get_parent().get_parent()
@onready var visual: Sprite2D = $Visual

func _ready() -> void:
	origin = position
	add_to_group("enemies")

func defeat() -> void:
	if defeated:
		return
	defeated = true
	velocity = Vector2.ZERO
	$Contact.set_deferred("monitoring", false)

func _physics_process(delta: float) -> void:
	if level.paused or level.player.dead:
		return
	if defeated:
		fade_time += delta
		visual.rotation += delta * 5.0
		visual.scale = Vector2.ONE * 2.0 * maxf(0.0, 1.0 - fade_time / 0.5)
		visual.modulate.a = maxf(0.0, 1.0 - fade_time / 0.5)
		queue_redraw()
		return
	# Attack is resolved before contact, so a well-timed shock defeats the enemy.
	if level.player.can_hit(global_position):
		defeat()
		return
	var target := origin + patrol_offset if outbound else origin
	if position.distance_to(target) < 5.0:
		outbound = not outbound
	velocity = position.direction_to(target) * speed
	move_and_slide()
	if get_slide_collision_count() > 0:
		outbound = not outbound
	elapsed += delta * 7.0
	visual.position.y = -28 - absf(sin(elapsed)) * 4
	visual.flip_h = velocity.x < 0
	for body in $Contact.get_overlapping_bodies():
		if body == level.player:
			level.player.die()
	queue_redraw()

func _draw() -> void:
	if defeated:
		return
	draw_arc(Vector2(0, -2), 23, 0, TAU, 24, Color("e67c84"), 2)
