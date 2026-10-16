
extends Node

@onready var clips: Node = $Clips

var active_music_streams: Dictionary = {}


func play(audio_name: String, from_position: float = 0.0) -> void:
	var audio = clips.get_node_or_null(audio_name)

	if audio == null:
		push_warning("Áudio não encontrado: " + audio_name)
		return

	if not audio is AudioStreamPlayer:
		push_warning(audio_name + " não é um AudioStreamPlayer")
		return

	audio.play(from_position)
	active_music_streams[audio_name] = audio


func stop(audio_name: String) -> void:
	if active_music_streams.has(audio_name):
		active_music_streams[audio_name].stop()
		active_music_streams.erase(audio_name)


func stop_all() -> void:
	for audio in active_music_streams.values():
		audio.stop()

	active_music_streams.clear()

func play_loop(audio_name: String) -> void:
	var audio = clips.get_node_or_null(audio_name)

	if audio == null or not audio is AudioStreamPlayer:
		return

	if not audio.playing:
		audio.play()


func stop_audio(audio_name: String) -> void:
	var audio = clips.get_node_or_null(audio_name)

	if audio != null and audio is AudioStreamPlayer:
		audio.stop()
