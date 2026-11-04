extends SceneTree
## Run on a graphical display: godot --path . --script tests/capture.gd
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene: Node2D = load("res://scenes/forest.tscn").instantiate()
	scene.music_enabled = false
	root.add_child(scene)
	for i in 20:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/forest.png")
	scene.queue_free()
	await process_frame
	quit()
