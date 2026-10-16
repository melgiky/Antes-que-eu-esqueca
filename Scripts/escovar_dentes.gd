extends CanvasLayer

signal minigame_finished

@onready var boca: Sprite2D = $Conteudo/boca
@onready var escova: Sprite2D = $Conteudo/escova
@onready var area_escova: Area2D = $Conteudo/escova/area_escova
@onready var area_dentes: Area2D = $Conteudo/area_dentes
@onready var barra_progresso: ProgressBar = $Conteudo/barra_progresso
@onready var conteudo: Node2D = $Conteudo
@export var velocidade_escovacao: float = 25.0
@export var movimento_minimo: float = 10.0

var arrastando := false
var offset_mouse := Vector2.ZERO
var terminou := false
var movimento_valido := false


func _ready() -> void:
	barra_progresso.min_value = 0
	barra_progresso.max_value = 100
	barra_progresso.value = 0


func _process(delta: float) -> void:
	if terminou:
		return

	if arrastando and movimento_valido:
		if area_escova.overlaps_area(area_dentes):
			barra_progresso.value += velocidade_escovacao * delta

	if barra_progresso.value >= 100:
		barra_progresso.value = 100
		terminou = true
		arrastando = false

		await get_tree().create_timer(0.5).timeout

		minigame_finished.emit()


func _input(event: InputEvent) -> void:
	if terminou:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_local = escova.to_local(
					conteudo.get_global_mouse_position()
				)

				if escova.get_rect().has_point(mouse_local):
					arrastando = true
					movimento_valido = false
					offset_mouse = (
						escova.global_position
						- conteudo.get_global_mouse_position()
					)
			else:
				arrastando = false
				movimento_valido = false

	if event is InputEventMouseMotion and arrastando:
		var nova_posicao = (
			conteudo.get_global_mouse_position() + offset_mouse
		)

		var distancia = escova.global_position.distance_to(
			nova_posicao
		)

		if distancia >= movimento_minimo:
			movimento_valido = true

		escova.global_position = nova_posicao
