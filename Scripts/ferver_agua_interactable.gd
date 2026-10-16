extends Node2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var player: CharacterBody2D = $"../Ysort/Player"
@onready var barra_progresso: ProgressBar = $barra_progresso

@export var tempo_ferver: float = 10.0

var interagindo := false


func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	barra_progresso.value = 0
	barra_progresso.hide()


func _on_interact() -> void:
	if interagindo:
		return

	interagindo = true
	player.can_move = false

	barra_progresso.value = 0
	barra_progresso.show()

	AudioManager.play("waterBoil")

	var tempo_decorrido := 0.0

	while tempo_decorrido < tempo_ferver:
		await get_tree().process_frame

		if not is_instance_valid(player):
			AudioManager.stop_sfx("waterBoil")
			barra_progresso.hide()
			return

		tempo_decorrido += get_process_delta_time()

		barra_progresso.value = min(
			(tempo_decorrido / tempo_ferver) * 100.0,
			100.0
		)

	barra_progresso.value = 100

	AudioManager.stop("waterBoil")
	barra_progresso.hide()

	GameManager.completar_objetivo("ferver_agua")

	print("Água fervida!")

	player.can_move = true
	queue_free()
