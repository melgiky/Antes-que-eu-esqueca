class_name PuzzlePiece
extends Area2D

@export var correct_position: Vector2

var dragging := false
var locked := false
var drag_offset := Vector2()


func _input_event(viewport, event, shape_idx):

	if locked:
		return

	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				dragging = true

				drag_offset = global_position - get_global_mouse_position()

			else:
				dragging = false
				check_position()


func _process(_delta):

	if dragging:
		global_position = get_global_mouse_position() + drag_offset


func check_position():

	var distance = global_position.distance_to(correct_position)

	print("Distância até o lugar correto: ", distance)

	if distance <= 50:

		global_position = correct_position

		locked = true

		print("PEÇA ENCAIXADA!")
