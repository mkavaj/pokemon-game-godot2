extends SceneTree
## Real physics tests: godot --headless --path . --script tests/test_forest.gd
var failures := 0
var checks := 0
var level: Node2D
var player: CharacterBody2D

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
	else:
		print("PASS: " + message)

func move_from(start: Vector2, direction: Vector2, frames: int) -> Vector2:
	player.input_override = Vector2.ZERO
	player.position = start
	player.velocity = Vector2.ZERO
	await physics_frame
	player.input_override = direction
	for i in frames:
		await physics_frame
	player.input_override = Vector2.ZERO
	await physics_frame
	return player.position

func run() -> void:
	level = load("res://scenes/forest.tscn").instantiate()
	root.add_child(level)
	await process_frame
	player = level.get_node("World/Player")
	player.test_input = true
	check(player.position == Vector2(320,1180), "Player starts in the opening clearing")
	check(player.get_node("Visual").texture.get_image().get_pixel(0,0).a == 0.0, "Sprite backdrop is transparent")
	check(level.get_node("World").y_sort_enabled, "Player and obstacles share the Y-sorted world")
	var horizontal := await move_from(Vector2(320,1180),Vector2.RIGHT,30)
	var diagonal := await move_from(Vector2(320,1180),Vector2.ONE,30)
	check(absf(horizontal.distance_to(Vector2(320,1180))-diagonal.distance_to(Vector2(320,1180)))<0.5,"Diagonal input does not increase speed")
	var wall := await move_from(Vector2(180,1180),Vector2.LEFT,40)
	check(wall.x >= 140 and wall.x < 145, "Forest boundary blocks the player's feet")
	var tree := await move_from(Vector2(250,1040),Vector2.UP,60)
	check(tree.y > 970 and tree.y < 990, "Solid tree trunk blocks movement")
	var rock := await move_from(Vector2(670,1340),Vector2.UP,60)
	check(rock.y > 1274 and rock.y < 1290, "Rock blocks movement")
	var log_pos := await move_from(Vector2(300,920),Vector2.UP,50)
	check(log_pos.y > 860 and log_pos.y < 875, "Fallen log blocks movement")
	var corridor := await move_from(Vector2(710,960),Vector2.RIGHT,100)
	check(corridor.x > 1000,"First corridor connects clearing and forest passage")
	var second := await move_from(Vector2(1480,640),Vector2.RIGHT,80)
	check(second.x > 1700,"Second corridor connects passage and sanctuary")
	# Follow the designed route with real physics and ensure all markers are reachable.
	player.position=Vector2(320,1180)
	await physics_frame
	for target in [Vector2(576,1180),Vector2(576,960),Vector2(1216,960),Vector2(1216,900),Vector2(1216,640),Vector2(1920,640),Vector2(1920,384)]:
		var frames := 0
		while player.position.distance_to(target)>5 and frames<400:
			player.input_override=(target-player.position).normalized()
			await physics_frame
			frames+=1
		player.input_override=Vector2.ZERO
		check(frames<400,"Reach route waypoint %s" % target)
	await process_frame
	check(level.visited.count(true)==3,"All three exploration markers can be collected")
	player.controls_enabled=false
	var before: Vector2 = player.position
	player.input_override=Vector2.RIGHT
	for i in 10:
		await physics_frame
	check(player.position.distance_to(before)<0.1,"Paused character cannot move")
	print("RESULT: %d checks, %d failures" % [checks,failures])
	level.queue_free()
	await process_frame
	quit(1 if failures else 0)
