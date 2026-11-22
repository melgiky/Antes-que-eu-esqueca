extends CanvasLayer

@onready var animacoes_pausa: AnimationPlayer = $animacoes_pausa
@onready var animacoes_blur: AnimationPlayer = $animacoes_blur
@onready var blur: ColorRect = $blur

var menu_aberto := false
var animando := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	blur.visible = false
	get_tree().paused = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit") and not animando:
		get_viewport().set_input_as_handled()

		if menu_aberto:
			fechar_menu()
		else:
			abrir_menu()


func abrir_menu() -> void:
	if menu_aberto:
		return

	menu_aberto = true
	animando = true

	visible = true
	blur.visible = true

	animacoes_pausa.play("pausing")
	animacoes_blur.play("blur_in")

	await animacoes_pausa.animation_finished

	get_tree().paused = true
	animando = false


func fechar_menu() -> void:
	if not menu_aberto:
		return

	menu_aberto = false
	animando = true

	get_tree().paused = false

	animacoes_pausa.play("unpausing")
	animacoes_blur.play("blur_out")

	await animacoes_pausa.animation_finished

	visible = false
	blur.visible = false

	animando = false


func _on_continuar_pressed() -> void:
	if not animando:
		fechar_menu()


func _on_salvar_pressed() -> void:
	pass


func _on_opcoes_pressed() -> void:
	pass


func _on_sair_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
