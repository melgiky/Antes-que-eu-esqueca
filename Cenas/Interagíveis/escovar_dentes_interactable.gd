extends Node2D

@onready var interaction_area: Area2D = $InteractionArea

var interagindo := false

var minigame = preload("res://Cenas/Mecânicas/escovar_dentes.tscn")


func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


func _on_interact() -> void:
	if interagindo:
		return

	interagindo = true

	var player = get_tree().get_first_node_in_group("player")
	player.can_move = false

	var instancia = minigame.instantiate()
	get_tree().current_scene.add_child(instancia)

	instancia.minigame_finished.connect(
		_on_minigame_finished.bind(instancia, player)
	)


func _on_minigame_finished(instancia, player) -> void:
	GameManager.completar_objetivo("escovar_dentes")

	instancia.queue_free()

	player.can_move = true
	interagindo = false
