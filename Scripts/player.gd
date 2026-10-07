extends CharacterBody2D

@export var speed := 100.0

var can_move := true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta):

	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation(Vector2.ZERO)
		return

	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed

	move_and_slide()

	update_animation(direction)


func update_animation(direction: Vector2):
	if direction == Vector2.ZERO:

		if animated_sprite.animation == "walk_down":
			animated_sprite.play("idle_down")

		elif animated_sprite.animation == "walk_up":
			animated_sprite.play("idle_up")

		elif animated_sprite.animation == "walk_side":
			animated_sprite.play("idle_side")

		return

	if direction.y > 0:
		animated_sprite.play("walk_down")

	elif direction.y < 0:
		animated_sprite.play("walk_up")

	elif direction.x != 0:
		animated_sprite.play("walk_side")

		if direction.x > 0:
			animated_sprite.flip_h = false

		elif direction.x < 0:
			animated_sprite.flip_h = true
