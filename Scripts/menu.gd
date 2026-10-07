extends Control

@export var intensidade := 15.0


func _process(delta):
	var mouse_pos := get_viewport().get_mouse_position()
	var tamanho_tela := get_viewport_rect().size

	# Transforma a posição do mouse em valores de -1 até 1
	var mouse_normalizado := (mouse_pos / tamanho_tela) * 2.0 - Vector2.ONE

	# Move cada camada com uma intensidade diferente
	$ParallaxBg/Parallax2D.position = mouse_normalizado * 2.0
	$ParallaxBg/Parallax2D2.position = mouse_normalizado * 4.0
	$ParallaxBg/Parallax2D3.position = mouse_normalizado * 5.0
	$ParallaxBg/Parallax2D4.position = mouse_normalizado * 10.0
	$ParallaxBg/Parallax2D5.position = mouse_normalizado * 12.0
	$ParallaxBg/Parallax2D6.position = mouse_normalizado * 15.0


func _on_iniciar_pressed() -> void:
	Transitions.transition()
	await Transitions.on_transition_finished
	get_tree().change_scene_to_file("res://Cenas/Levels/segundoandar.tscn")


func _on_opcoes_pressed() -> void:
	pass # Replace with function body.


func _on_sair_pressed() -> void:
	Transitions.transition()
	await Transitions.on_transition_finished
	get_tree().quit()
