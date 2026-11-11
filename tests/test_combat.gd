extends SceneTree
var checks := 0
var failures := 0
var level: Node2D
var player: CharacterBody2D

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, label: String) -> void:
	checks += 1
	if value:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
	await process_frame

func run() -> void:
	level = load("res://scenes/forest.tscn").instantiate()
	root.add_child(level)
	current_scene = level
	await frames(2)
	player = level.player
	player.test_input = true
	var enemy: CharacterBody2D = level.get_node("World/EkansClearing")
	check(get_nodes_in_group("enemies").size() == 3, "Three independent enemy instances load without shared-image hangs")
	var start: Vector2 = enemy.position
	await frames(30)
	check(enemy.position.distance_to(start) > 15, "Enemy patrol moves independently")
	level.paused = true
	player.controls_enabled = false
	start = enemy.position
	await frames(10)
	check(enemy.position == start, "Pause freezes enemies")
	check(not player.try_attack(), "Pause prevents attacking")
	level.paused = false
	player.controls_enabled = true
	player.position = Vector2(400, 1180)
	for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
		player.input_override = direction
		await frames(3)
		check(player.facing == direction and player.animation_state == "walk", "Directional walk animation %s" % direction)
	player.input_override = Vector2.ZERO
	await frames(2)
	check(player.animation_state == "idle", "Idle animation resumes when stopped")
	player.facing = Vector2.RIGHT
	check(player.try_attack(), "Shock attack starts")
	check(not player.try_attack(), "Cooldown prevents repeated attacks")
	check(player.can_hit(player.position + Vector2(70, 0)), "Shock hits in front")
	check(not player.can_hit(player.position - Vector2(70, 0)), "Shock cannot hit behind")
	check(not player.can_hit(player.position + Vector2(110, 0)), "Shock respects range")
	enemy.position = player.position + Vector2(65, 0)
	enemy.origin = enemy.position
	await frames(2)
	check(enemy.defeated and not player.dead, "Directional shock defeats enemy without killing player")
	check(player.animation_state == "attack", "Attack has its own animation")
	await frames(45)
	check(enemy.visual.modulate.a == 0, "Defeated enemy animates out")
	check(player.cooldown == 0.0 and player.try_attack(), "Attack becomes available after cooldown")
	await frames(45)
	check(not player.can_hit(player.position + Vector2(30, 0)), "Expired attack does not deal damage")
	# Verify collision with the actual forest boundary.
	var contact_enemy: CharacterBody2D = level.get_node("World/EkansPassage")
	contact_enemy.position = Vector2(170, 1200)
	contact_enemy.origin = Vector2(10, 1200)
	contact_enemy.patrol_offset = Vector2(-100, 0)
	await frames(40)
	check(contact_enemy.position.x >= 140, "Enemy body cannot pass through forest walls")
	# Camera clamp uses the viewport, including at opposite world corners.
	var camera: Camera2D = player.get_node("Camera2D")
	check(camera.position_smoothing_enabled, "Follow camera smoothing is enabled")
	for corner in [Vector2(0, 0), Vector2(2304, 1536)]:
		player.position = corner
		camera.reset_smoothing()
		camera.force_update_scroll()
		await process_frame
		var center := camera.get_screen_center_position()
		var half := root.get_visible_rect().size * 0.5
		check(center.x >= half.x and center.x <= 2304 - half.x and center.y >= half.y and center.y <= 1536 - half.y, "Camera stays inside level at %s" % corner)
	# An unprotected collision must trigger death, then a complete scene reload.
	level.visited.fill(true)
	player.position = Vector2(400, 1180)
	contact_enemy.position = player.position
	contact_enemy.origin = player.position
	contact_enemy.patrol_offset = Vector2.ZERO
	contact_enemy.speed = 0.0
	await frames(4)
	check(player.dead and player.animation_state == "death", "Enemy contact triggers death animation")
	check(not player.try_attack(), "Dead player cannot attack")
	start = player.position
	player.input_override = Vector2.RIGHT
	await frames(10)
	check(player.position == start and player.visual.modulate.a < 1, "Death locks movement and fades the sprite")
	await frames(65)
	check(is_instance_valid(current_scene) and current_scene != level, "Death automatically reloads the scene")
	level = current_scene
	player = level.player
	check(not player.dead and player.position == Vector2(320, 1180), "Restart restores living player at spawn")
	check(level.visited.count(true) == 0, "Restart clears collected markers")
	check(get_nodes_in_group("enemies").size() == 3 and not level.get_node("World/EkansClearing").defeated, "Restart restores defeated enemies")
	check(player.cooldown == 0 and not level.paused, "Restart clears combat and pause states")
	level.paused = true
	level.restart_level()
	await frames(3)
	check(current_scene != level and not current_scene.paused, "Manual restart also reloads the full level")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
