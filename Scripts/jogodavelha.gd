
extends Node2D

@onready var grid: Node2D = $grid
@onready var circle_template: Node2D = $Circle
@onready var cross_template: Node2D = $Cross

@onready var restart_button = $restart
@onready var sair_button = $sair

const BOARD_SIZE := 400.0
const CELL_SIZE := BOARD_SIZE / 3.0

# 1 = jogador
# -1 = IA
var board: Array = []
var game_over := false
var ai_thinking := false


func _ready() -> void:
	randomize()

	# Esconde os modelos dos marcadores
	circle_template.hide()
	cross_template.hide()

	# Conecta os botões
	restart_button.pressed.connect(_on_restart_pressed)
	sair_button.pressed.connect(_on_sair_pressed)

	new_game()


func _unhandled_input(event: InputEvent) -> void:
	if game_over or ai_thinking:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			# Converte a posição do mouse para a posição local da grid
			var mouse_position = grid.to_local(get_global_mouse_position())

			# Verifica se clicou dentro do tabuleiro
			if mouse_position.x < -200 or mouse_position.x >= 200:
				return

			if mouse_position.y < -200 or mouse_position.y >= 200:
				return

			# Descobre a célula clicada
			var col = int((mouse_position.x + 200) / CELL_SIZE)
			var row = int((mouse_position.y + 200) / CELL_SIZE)

			# Não permite jogar em uma célula ocupada
			if board[row][col] != 0:
				return

			# Jogada do jogador
			make_move(row, col, 1)

			if check_game_result():
				return

			# Vez da IA
			ai_move()

func make_move(row: int, col: int, player: int) -> void:
	board[row][col] = player

	var marker: Node2D

	if player == 1:
		marker = circle_template.duplicate()
		marker.add_to_group("circles")
	else:
		marker = cross_template.duplicate()
		marker.add_to_group("crosses")

	grid.add_child(marker)
	marker.show()

	marker.position = Vector2(
		-200 + (col + 0.5) * CELL_SIZE,
		-200 + (row + 0.5) * CELL_SIZE
	)


func ai_move() -> void:
	ai_thinking = true

	await get_tree().create_timer(0.4).timeout

	if game_over:
		ai_thinking = false
		return

	var empty_cells: Array[Vector2i] = []

	for row in range(3):
		for col in range(3):
			if board[row][col] == 0:
				empty_cells.append(Vector2i(row, col))

	# Escolhe uma posição aleatória disponível
	if empty_cells.size() > 0:
		var chosen_cell = empty_cells.pick_random()

		make_move(chosen_cell.x, chosen_cell.y, -1)

		check_game_result()

	ai_thinking = false


func check_game_result() -> bool:
	var lines = [
		# Linhas
		[board[0][0], board[0][1], board[0][2]],
		[board[1][0], board[1][1], board[1][2]],
		[board[2][0], board[2][1], board[2][2]],

		# Colunas
		[board[0][0], board[1][0], board[2][0]],
		[board[0][1], board[1][1], board[2][1]],
		[board[0][2], board[1][2], board[2][2]],

		# Diagonais
		[board[0][0], board[1][1], board[2][2]],
		[board[0][2], board[1][1], board[2][0]]
	]

	for line in lines:
		var total = line[0] + line[1] + line[2]

		if total == 3:
			finish_game("Você venceu!")
			return true

		if total == -3:
			finish_game("A IA venceu!")
			return true

	# Verifica empate
	for row in board:
		if row.has(0):
			return false

	finish_game("Empate!")
	return true


func finish_game(message: String) -> void:
	game_over = true
	print(message)

func new_game() -> void:
	board = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]

	game_over = false
	ai_thinking = false

	# Remove somente os marcadores
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")

func _on_restart_pressed() -> void:
	new_game()


func _on_sair_pressed() -> void:
	get_tree().quit()
