extends Node2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var collision_open: CollisionShape2D = $open/collision_open

var is_open := false
var is_animating := false


func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	animated_sprite.play("closed")

	# Porta começa fechada
	collision_shape.disabled = false
	collision_open.disabled = true


func _on_interact() -> void:
	if is_animating:
		return

	is_animating = true

	if is_open:
		# FECHAR
		collision_open.disabled = true
		collision_shape.disabled = false

		animated_sprite.play_backwards("opening")
		await animated_sprite.animation_finished

		animated_sprite.play("closed")
		is_open = false

	else:
		# ABRIR
		animated_sprite.play("opening")
		await animated_sprite.animation_finished

		animated_sprite.play("open")

		# Desativa a colisão da porta fechada
		collision_shape.disabled = true

		# Ativa a colisão da porta aberta
		collision_open.disabled = false

		is_open = true

	is_animating = false
