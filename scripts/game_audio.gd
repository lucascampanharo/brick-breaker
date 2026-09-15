extends Node

const LAUNCH_SOUND := preload("res://assets/audio/launch.wav")
const BRICK_SOUND := preload("res://assets/audio/brick_hit.wav")
const PADDLE_SOUND := preload("res://assets/audio/paddle_hit.wav")
const VOLUME_DB := -12.0

var launch_player: AudioStreamPlayer
var brick_player: AudioStreamPlayer
var paddle_player: AudioStreamPlayer


func _ready() -> void:
	# O autoload mantém os impactos tocando mesmo quando a fase é substituída.
	launch_player = _make_player(LAUNCH_SOUND)
	brick_player = _make_player(BRICK_SOUND)
	paddle_player = _make_player(PADDLE_SOUND)


func _make_player(stream: AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = VOLUME_DB
	player.max_polyphony = 4
	add_child(player)
	return player


func play_launch() -> void:
	launch_player.play()


func play_brick_hit() -> void:
	brick_player.play()


func play_paddle_hit() -> void:
	paddle_player.play()
