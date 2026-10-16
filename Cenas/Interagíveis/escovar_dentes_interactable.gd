extends Node2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var player: CharacterBody2D = $"../Ysort/Player"

const CENA_ESCOVAR = preload("res://Cenas/Mecânicas/escovar_dentes.tscn")

var minigame_atual: Node = null
var interagindo := false


func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact() -> void:
	if interagindo:
		return

	interagindo = true

	player.can_move = false

	minigame_atual = CENA_ESCOVAR.instantiate()
	
	# Adiciona o minigame à cena principal, não à pia.
	get_tree().current_scene.add_child(minigame_atual)

	minigame_atual.minigame_finished.connect(
		_finalizar_minigame_escovar
	)

func _finalizar_minigame_escovar() -> void:
	GameManager.completar_objetivo("escovar_dentes")
	print ("você escovou os dentes!")
	if is_instance_valid(minigame_atual):
		minigame_atual.queue_free()

	minigame_atual = null
	player.can_move = true
	interagindo = false
