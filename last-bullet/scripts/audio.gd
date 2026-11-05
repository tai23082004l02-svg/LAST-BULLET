extends Node
# Local ElevenLabs samples reused from Game-create. No API calls at runtime.
const STREAMS := {
 "ui_click": preload("res://audio/ui_click.tres"),
 "xp_pickup": preload("res://audio/xp_pickup.tres"),
 "level_up": preload("res://audio/level_up.tres"),
 "player_hit": preload("res://audio/player_hit.tres"),
 "enemy_hit": preload("res://audio/enemy_hit.tres"),
 "enemy_death": preload("res://audio/enemy_death.tres"),
 "boss_warning": preload("res://audio/boss_warning.tres"),
 "defeat": preload("res://audio/defeat.tres"),
 "skill": preload("res://audio/lightning.tres")}
const GAINS := {"ui_click":-0.06,"xp_pickup":-7.21,"level_up":-8.19,"player_hit":-3.14,"enemy_hit":-17.29,"enemy_death":0.02,"boss_warning":-4.29,"defeat":8.35,"skill":1.75,"bounce":-27.0,"shoot":-16.0,"enemy_shoot":-22.0}
var enabled := true
var voices: Array[AudioStreamPlayer] = []
var last_events: Dictionary = {}
var cursor := 0
var priority_cursor := 0
var bounce_stream: AudioStreamWAV
var shoot_stream: AudioStreamWAV

func _ready() -> void:
	var bus := AudioServer.get_bus_index("LastBulletSFX")
	if bus < 0:
		AudioServer.add_bus()
		bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus,"LastBulletSFX")
		var limiter := AudioEffectLimiter.new()
		limiter.ceiling_db = -2
		limiter.threshold_db = -2
		AudioServer.add_bus_effect(bus,limiter)
	for i in range(8):
		var voice := AudioStreamPlayer.new()
		voice.bus = "LastBulletSFX"
		add_child(voice)
		voices.append(voice)
	bounce_stream = AudioStreamWAV.new()
	bounce_stream.format = AudioStreamWAV.FORMAT_16_BITS
	bounce_stream.mix_rate = 22050
	var data := PackedByteArray()
	data.resize(2206)
	for i in range(1103):
		var t := float(i)/22050
		data.encode_s16(i*2,int(sin(TAU*880*t)*exp(-t*95)*22000))
	bounce_stream.data = data
	shoot_stream = AudioStreamWAV.new()
	shoot_stream.format = AudioStreamWAV.FORMAT_16_BITS
	shoot_stream.mix_rate = 22050
	var shot := PackedByteArray()
	shot.resize(2646)
	var noise := RandomNumberGenerator.new()
	noise.seed = 803
	for i in range(1323):
		var t := float(i)/22050
		var sample := (sin(TAU*(630*t-2200*t*t))*0.6+noise.randf_range(-1,1)*0.4)*exp(-t*90)
		shot.encode_s16(i*2,int(sample*18000))
	shoot_stream.data = shot

func play_event(event: String, pitch: float = 1.0) -> void:
	if not enabled or voices.is_empty():
		return
	var now := Time.get_ticks_msec()
	var interval := 100 if event in ["enemy_hit","enemy_death","xp_pickup","bounce"] else 60
	if now - int(last_events.get(event,-10000)) < interval:
		return
	var important := event in ["skill","level_up","player_hit","boss_warning","defeat","ui_click"]
	var index := 5+priority_cursor if important else cursor
	if important:
		priority_cursor = (priority_cursor+1)%3
	else:
		cursor = (cursor+1)%5
	var voice := voices[index]
	voice.stop()
	voice.stream = shoot_stream if event in ["shoot","enemy_shoot"] else bounce_stream if event == "bounce" else STREAMS.get(event)
	if voice.stream == null:
		return
	voice.volume_db = float(GAINS.get(event,-10)) - 4.0
	voice.pitch_scale = clampf(pitch,0.75,1.4)
	voice.play()
	last_events[event] = now

func stop_all() -> void:
	for voice in voices:
		voice.stop()
	last_events.clear()

func shutdown() -> void:
	stop_all()
	for voice in voices:
		voice.stream = null
	voices.clear()
	bounce_stream = null
	shoot_stream = null

func _exit_tree() -> void:
	shutdown()
