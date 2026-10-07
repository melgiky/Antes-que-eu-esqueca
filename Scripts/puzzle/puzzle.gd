extends Node2D

const PIECE_SCENE = preload("res://Cenas/Mecânicas/puzzle_piece.tscn")

const GRID_SIZE := 3
const PIECE_SIZE := 128

# Onde o tabuleiro começa
const BOARD_POSITION := Vector2(200, 100)

var pieces := []


func _ready():
	create_puzzle()


func create_puzzle():

	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):

			var piece = PIECE_SCENE.instantiate()

			$Pieces.add_child(piece)

			# Calcula a posição correta no tabuleiro
			var correct_pos = BOARD_POSITION + Vector2(
				x * PIECE_SIZE,
				y * PIECE_SIZE
			)

			# Guarda a posição correta
			piece.correct_position = correct_pos

			# Coloca a peça em uma posição aleatória
			piece.global_position = Vector2(
				randf_range(500, 900),
				randf_range(100, 500)
			)

			pieces.append(piece)
