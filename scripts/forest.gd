extends Node2D
const MARKERS := [Vector2(576,1180),Vector2(1216,900),Vector2(1920,384)]
@export var music_enabled := true
var visited: Array[bool] = [false,false,false]
var paused := false
var muted := false
var restart_time := -1.0
var restarting := false
@onready var player: CharacterBody2D = $World/Player
@onready var music: AudioStreamPlayer = $Music
@onready var hud: Control = $HUD/Interface

func _ready() -> void:
	var bindings := {
		"move_left": [KEY_A,KEY_LEFT], "move_right": [KEY_D,KEY_RIGHT],
		"move_up": [KEY_W,KEY_UP], "move_down": [KEY_S,KEY_DOWN],
		"sprint": [KEY_SHIFT], "reset": [KEY_R], "pause_game": [KEY_ESCAPE],
		"mute": [KEY_M], "map": [KEY_TAB], "attack": [KEY_SPACE, KEY_J]
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			if not InputMap.action_has_event(action,event):
				InputMap.action_add_event(action,event)
	player.died.connect(_on_player_died)
	var track := music.stream as AudioStreamWAV
	track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	track.loop_end = int(track.get_length() * track.mix_rate)
	# Headless test runs have no audio output device.
	if music_enabled and DisplayServer.get_name() != "headless":
		music.play()

func _on_player_died() -> void:
	restart_time = 1.0
	paused = false

func restart_level() -> void:
	if restarting:
		return
	restarting = true
	get_tree().call_deferred("reload_current_scene")

func _physics_process(delta: float) -> void:
	if restart_time >= 0.0:
		restart_time -= delta
		if restart_time <= 0.0:
			restart_level()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		restart_level()
	if player.dead or restarting:
		hud.queue_redraw()
		return
	if Input.is_action_just_pressed("pause_game"):
		paused = not paused
		player.controls_enabled = not paused
		player.velocity = Vector2.ZERO
	if Input.is_action_just_pressed("mute"):
		muted = not muted
		music.volume_db = -80 if muted else -22
	if not paused:
		for i in MARKERS.size():
			if player.position.distance_to(MARKERS[i]) < 55:
				visited[i] = true
	hud.queue_redraw()
	queue_redraw()

func _draw() -> void:
	for i in MARKERS.size():
		var p: Vector2 = MARKERS[i]
		var c := Color("dfc27c") if not visited[i] else Color("94d1aa")
		draw_arc(p,24,0,TAU,32,Color(c,0.25),2)
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-12),p+Vector2(7,0),p+Vector2(0,12),p+Vector2(-7,0)]),c)

func _exit_tree() -> void:
	music.stop()
