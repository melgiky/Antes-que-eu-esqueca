extends Node2D

@onready var interaction_area: Area2D = $InteractionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D

var is_open := false
var is_animating := false


func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	animated_sprite.play("closed")


func _on_interact() -> void:
	if is_animating:
		return

	is_animating = true

	if is_open:
		# FECHAR — toca a animação ao contrário
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
		collision_shape.disabled = true
		is_open = true

	is_animating = false
