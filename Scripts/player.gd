extends CharacterBody2D

@export var speed := 80.0
@export var acceleration := 900.0
@export var friction := 1100.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var ground: TileMapLayer = $"../../piso"

@export var intervalo_passos: float = 0.35

var tempo_passo: float = 0.0
var can_move := true

var last_direction := Vector2.DOWN
var sprite_base_position := Vector2.ZERO
var bob_time := 0.0


func _ready() -> void:
	sprite_base_position = animated_sprite.position


func _physics_process(delta: float) -> void:

	if not can_move:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
		update_animation(Vector2.ZERO, delta)
		return

	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	# Movimento com aceleração
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(
			input_direction * speed,
			acceleration * delta
		)

		last_direction = input_direction

	else:
		# Desaceleração
		velocity = velocity.move_toward(
			Vector2.ZERO,
			friction * delta
		)

	move_and_slide()

	update_animation(input_direction, delta)
	atualizar_passos(delta)
	


func update_animation(direction: Vector2, delta: float) -> void:

	# -------------------------
	# PARADO
	# -------------------------

	if velocity.length() < 5.0:

		bob_time = 0.0

		# Volta suavemente para a posição original
		animated_sprite.position = animated_sprite.position.lerp(
			sprite_base_position,
			12.0 * delta
		)

		if last_direction.y > 0:
			animated_sprite.play("idle_down")

		elif last_direction.y < 0:
			animated_sprite.play("idle_up")

		else:
			animated_sprite.play("idle_side")

		return


	# -------------------------
	# ANDANDO
	# -------------------------

	# Decide qual eixo tem prioridade
	if abs(velocity.x) > abs(velocity.y):

		animated_sprite.play("walk_side")

		if velocity.x > 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true

	else:

		if velocity.y > 0:
			animated_sprite.play("walk_down")
		else:
			animated_sprite.play("walk_up")


	# -------------------------
	# BOBBING
	# -------------------------

	bob_time += delta * 10.0

	var bob := sin(bob_time) * 0.3

	animated_sprite.position = sprite_base_position + Vector2(
		0,
		bob
	)
	

func atualizar_passos(_delta: float) -> void:
	if not can_move or velocity.length() < 5.0:
		AudioManager.stop_audio("walkingWood")
		return

	if ground == null:
		return

	var pos_pes = global_position + Vector2(0, 12)
	var local_pes = ground.to_local(pos_pes)
	var coordenada = ground.local_to_map(local_pes)
	var dados = ground.get_cell_tile_data(coordenada)

	if dados == null:
		AudioManager.stop_audio("walkingWood")
		return

	var superficie = str(dados.get_custom_data("surface"))

	match superficie:
		"wood":
			AudioManager.play_loop("walkingWood")
		_:
			AudioManager.stop_audio("walkingWood")
