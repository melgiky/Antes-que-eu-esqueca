
extends Node2D

@onready var peca_branca: Sprite2D = $"PeçaBranca"
@onready var peca_preta: Sprite2D = $"PeçaPreta"
@onready var tabuleiro: Sprite2D = $Tabuleiro
@onready var sinal_movimento: ColorRect = $Sinal_movimento

const TAMANHO_TABULEIRO := 507
const TAMANHO_CASA := 63.37

# 1 = Branco (jogador)
# -1 = Preto (IA)
# 0 = Casa vazia

var casas: Array = []
var damas: Array = []

var pecas_visuais: Dictionary = {}

var turno := 1
var partida_encerrada := false
var pensando_ia := false

# Controle da captura múltipla do jogador
var movimentos_selecionados: Array = []
var movimentos_possiveis: Array = []
var passo_atual := 0
var posicao_selecionada := Vector2i(-1, -1)

var contador_damas := 0

var diagonais := [
	Vector2i(-1, -1),
	Vector2i(1, -1),
	Vector2i(-1, 1),
	Vector2i(1, 1)
]
const COR_MOVIMENTO := Color(0.2, 0.8, 0.4, 0.35)

var camada_movimentos: Node2D
var destaques: Array[ColorRect] = []

func _ready() -> void:
	randomize()

	# Esconde os modelos originais e o ColorRect usado como modelo dos sinais.
	peca_branca.hide()
	peca_preta.hide()
	sinal_movimento.hide()
	camada_movimentos = Node2D.new()
	camada_movimentos.name = "CamadaMovimentos"
	tabuleiro.add_child(camada_movimentos)

	iniciar_partida()


# ==================================================
# INÍCIO DA PARTIDA
# ==================================================

func iniciar_partida() -> void:
	casas.clear()
	damas.clear()
	pecas_visuais.clear()

	turno = 1
	partida_encerrada = false
	pensando_ia = false
	contador_damas = 0
	limpar_selecao()
	limpar_destaques()

	limpar_pecas()

	# Cria tabuleiro lógico
	for linha in range(8):
		var nova_linha = []
		var linha_damas = []

		for coluna in range(8):
			nova_linha.append(0)
			linha_damas.append(false)

		casas.append(nova_linha)
		damas.append(linha_damas)

	# Peças pretas: três primeiras linhas
	for linha in range(3):
		for coluna in range(8):
			if casa_escura(linha, coluna):
				criar_peca(Vector2i(coluna, linha), -1)

	# Peças brancas: três últimas linhas
	for linha in range(5, 8):
		for coluna in range(8):
			if casa_escura(linha, coluna):
				criar_peca(Vector2i(coluna, linha), 1)

	print("Partida iniciada! Sua vez.")


func limpar_pecas() -> void:
	for marcador in pecas_visuais.values():
		if is_instance_valid(marcador):
			marcador.queue_free()

	pecas_visuais.clear()


func casa_escura(linha: int, coluna: int) -> bool:
	return (linha + coluna) % 2 == 1


# ==================================================
# CRIAÇÃO DAS PEÇAS
# ==================================================

func criar_peca(posicao: Vector2i, jogador: int) -> void:
	casas[posicao.y][posicao.x] = jogador

	var modelo: Sprite2D

	if jogador == 1:
		modelo = peca_branca
	else:
		modelo = peca_preta

	var marcador := modelo.duplicate() as Sprite2D

	tabuleiro.add_child(marcador)

	marcador.show()
	marcador.position = posicao_para_pixel(posicao)

	pecas_visuais[posicao] = marcador


func posicao_para_pixel(posicao: Vector2i) -> Vector2:
	return Vector2(
		-TAMANHO_TABULEIRO / 2.0 + posicao.x * TAMANHO_CASA + TAMANHO_CASA / 2.0,
		-TAMANHO_TABULEIRO / 2.0 + posicao.y * TAMANHO_CASA + TAMANHO_CASA / 2.0
	)


func pixel_para_posicao(pixel: Vector2) -> Vector2i:
	return Vector2i(
		int(floor((pixel.x + TAMANHO_TABULEIRO / 2.0) / TAMANHO_CASA)),
		int(floor((pixel.y + TAMANHO_TABULEIRO / 2.0) / TAMANHO_CASA))
	)


func dentro_do_tabuleiro(posicao: Vector2i) -> bool:
	return (
		posicao.x >= 0 and posicao.x < 8
		and posicao.y >= 0 and posicao.y < 8
	)


# ==================================================
# CLIQUES DO JOGADOR
# ==================================================

func _unhandled_input(event: InputEvent) -> void:
	if partida_encerrada or pensando_ia or turno != 1:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			var mouse = tabuleiro.to_local(get_global_mouse_position())

			if mouse.x < -256 or mouse.x >= 256:
				return

			if mouse.y < -256 or mouse.y >= 256:
				return

			var posicao = pixel_para_posicao(mouse)

			if not dentro_do_tabuleiro(posicao):
				return

			processar_clique(posicao)


func processar_clique(posicao: Vector2i) -> void:
	# Se uma peça já foi selecionada, ela fica travada até terminar o movimento.
	# Cliques em outras peças ou casas inválidas não cancelam a seleção.
	if not movimentos_selecionados.is_empty():
		var movimentos_validos: Array = []

		for movimento in movimentos_selecionados:
			var caminho: Array = movimento["caminho"]
			if passo_atual < caminho.size() and caminho[passo_atual] == posicao:
				movimentos_validos.append(movimento)

		if movimentos_validos.is_empty():
			return

		movimentos_selecionados = movimentos_validos
		var marcador: Sprite2D = pecas_visuais.get(posicao_selecionada)
		if is_instance_valid(marcador):
			marcador.position = posicao_para_pixel(posicao)

		passo_atual += 1

		# Todas as sequências restantes têm o mesmo número de capturas,
		# pois a regra da maioria já foi aplicada.
		var movimento_atual: Dictionary = movimentos_selecionados[0]
		if passo_atual >= movimento_atual["caminho"].size():
			executar_movimento(movimento_atual)
			limpar_selecao()
			finalizar_turno(1)
		else:
			atualizar_destaques(movimentos_selecionados)

		return

	# Só é possível iniciar a seleção em uma peça branca com movimento legal.
	if casas[posicao.y][posicao.x] == 1:
		selecionar_peca(posicao)


func selecionar_peca(posicao: Vector2i) -> void:
	if turno != 1 or partida_encerrada or pensando_ia:
		return

	var todos_movimentos: Array = obter_movimentos_validos(1)
	var movimentos_da_peca: Array = []

	for movimento in todos_movimentos:
		if movimento["origem"] == posicao:
			movimentos_da_peca.append(movimento)

	if movimentos_da_peca.is_empty():
		return

	movimentos_selecionados = movimentos_da_peca
	posicao_selecionada = posicao
	passo_atual = 0

	atualizar_destaques(movimentos_selecionados)
	print("Peça selecionada: ", posicao)


func obter_movimentos_validos(jogador: int) -> Array:
	var capturas: Array = []
	var movimentos: Array = []

	for linha in range(8):
		for coluna in range(8):

			if casas[linha][coluna] != jogador:
				continue

			var origem = Vector2i(coluna, linha)

			var caminhos = encontrar_capturas(
				casas.duplicate(true),
				damas.duplicate(true),
				origem,
				jogador,
				origem,
				[],
				[]
			)

			if not caminhos.is_empty():
				capturas.append_array(caminhos)
			else:
				movimentos.append_array(
					encontrar_movimentos_simples(origem, jogador)
				)

	# Captura é obrigatória
	if not capturas.is_empty():

		# Lei da Maioria
		var maior_captura := 0

		for movimento in capturas:
			maior_captura = max(
				maior_captura,
				movimento["capturas"].size()
			)

		var melhores: Array = []

		for movimento in capturas:
			if movimento["capturas"].size() == maior_captura:
				melhores.append(movimento)

		return melhores

	return movimentos


# ==================================================
# MOVIMENTOS SIMPLES
# ==================================================

func encontrar_movimentos_simples(
	origem: Vector2i,
	jogador: int
) -> Array:

	var resultado: Array = []

	var eh_dama = damas[origem.y][origem.x]

	if eh_dama:
		for direcao in diagonais:
			var destino = origem + direcao

			while dentro_do_tabuleiro(destino):
				if casas[destino.y][destino.x] != 0:
					break

				resultado.append({
					"origem": origem,
					"caminho": [destino],
					"capturas": []
				})

				destino += direcao

	else:
		var direcao = -1 if jogador == 1 else 1

		for dx in [-1, 1]:
			var destino = origem + Vector2i(dx, direcao)

			if dentro_do_tabuleiro(destino):
				if casas[destino.y][destino.x] == 0:
					resultado.append({
						"origem": origem,
						"caminho": [destino],
						"capturas": []
					})

	return resultado


# ==================================================
# CAPTURAS
# ==================================================

func obter_capturas_imediatas(
	estado: Array,
	estado_damas: Array,
	origem: Vector2i,
	jogador: int
) -> Array:

	var resultado: Array = []

	var eh_dama = estado_damas[origem.y][origem.x]

	if eh_dama:

		# Dama pode capturar em qualquer diagonal
		for direcao in diagonais:
			var cursor = origem + direcao
			var encontrou_inimigo := false
			var inimigo = Vector2i(-1, -1)

			while dentro_do_tabuleiro(cursor):
				var valor = estado[cursor.y][cursor.x]

				if valor != 0:

					if encontrou_inimigo:
						break

					if valor == -jogador:
						encontrou_inimigo = true
						inimigo = cursor
					else:
						break

				elif encontrou_inimigo:
					resultado.append({
						"destino": cursor,
						"inimigo": inimigo
					})

				cursor += direcao

	else:

		# Pedra captura para frente e para trás
		for direcao in diagonais:
			var inimigo = origem + direcao
			var destino = origem + direcao * 2

			if not dentro_do_tabuleiro(inimigo):
				continue

			if not dentro_do_tabuleiro(destino):
				continue

			if estado[inimigo.y][inimigo.x] == -jogador:
				if estado[destino.y][destino.x] == 0:
					resultado.append({
						"destino": destino,
						"inimigo": inimigo
					})

	return resultado


# ==================================================
# GERA SEQUÊNCIAS DE CAPTURA
# ==================================================

func encontrar_capturas(
	estado: Array,
	estado_damas: Array,
	posicao: Vector2i,
	jogador: int,
	origem: Vector2i,
	caminho: Array,
	capturas: Array
) -> Array:

	var opcoes = obter_capturas_imediatas(
		estado,
		estado_damas,
		posicao,
		jogador
	)

	if opcoes.is_empty():

		if caminho.is_empty():
			return []

		return [{
			"origem": origem,
			"caminho": caminho.duplicate(),
			"capturas": capturas.duplicate()
		}]

	var resultado: Array = []

	for opcao in opcoes:
		var destino: Vector2i = opcao["destino"]
		var inimigo: Vector2i = opcao["inimigo"]

		var era_dama = estado_damas[posicao.y][posicao.x]
		var valor_inimigo = estado[inimigo.y][inimigo.x]
		var inimigo_era_dama = estado_damas[inimigo.y][inimigo.x]

		# Simula a captura
		estado[posicao.y][posicao.x] = 0
		estado_damas[posicao.y][posicao.x] = false

		estado[inimigo.y][inimigo.x] = 0
		estado_damas[inimigo.y][inimigo.x] = false

		estado[destino.y][destino.x] = jogador
		estado_damas[destino.y][destino.x] = era_dama

		var novo_caminho = caminho.duplicate()
		novo_caminho.append(destino)

		var novas_capturas = capturas.duplicate()
		novas_capturas.append(inimigo)

		var sequencias = encontrar_capturas(
			estado,
			estado_damas,
			destino,
			jogador,
			origem,
			novo_caminho,
			novas_capturas
		)

		resultado.append_array(sequencias)

		# Restaura o tabuleiro para testar outra possibilidade
		estado[destino.y][destino.x] = 0
		estado_damas[destino.y][destino.x] = false

		estado[inimigo.y][inimigo.x] = valor_inimigo
		estado_damas[inimigo.y][inimigo.x] = inimigo_era_dama

		estado[posicao.y][posicao.x] = jogador
		estado_damas[posicao.y][posicao.x] = era_dama

	return resultado


# ==================================================
# EXECUÇÃO DOS MOVIMENTOS
# ==================================================

func executar_movimento(movimento: Dictionary) -> void:

	var origem: Vector2i = movimento["origem"]
	var caminho: Array = movimento["caminho"]
	var capturas: Array = movimento["capturas"]

	var destino: Vector2i = caminho[caminho.size() - 1]

	var jogador = casas[origem.y][origem.x]
	var era_dama = damas[origem.y][origem.x]

	var marcador: Sprite2D = pecas_visuais[origem]

	# Atualiza as casas de origem e destino
	casas[origem.y][origem.x] = 0
	damas[origem.y][origem.x] = false

	# Remove as peças capturadas logicamente e visualmente
	for inimigo in capturas:
		casas[inimigo.y][inimigo.x] = 0
		damas[inimigo.y][inimigo.x] = false

		var marcador_inimigo = pecas_visuais.get(inimigo)

		if marcador_inimigo != null:
			marcador_inimigo.queue_free()

		pecas_visuais.erase(inimigo)

	# Coloca a peça no destino final
	casas[destino.y][destino.x] = jogador
	damas[destino.y][destino.x] = era_dama

	pecas_visuais.erase(origem)
	pecas_visuais[destino] = marcador

	marcador.position = posicao_para_pixel(destino)

	# Promoção a dama
	if not era_dama:
		if jogador == 1 and destino.y == 0:
			promover_a_dama(destino, marcador)

		elif jogador == -1 and destino.y == 7:
			promover_a_dama(destino, marcador)

	# Contador de movimentos de damas sem captura
	if capturas.size() > 0 or not era_dama:
		contador_damas = 0
	else:
		contador_damas += 1


func promover_a_dama(posicao: Vector2i, marcador: Sprite2D) -> void:
	damas[posicao.y][posicao.x] = true

	# Diferencia visualmente a dama
	marcador.scale = Vector2(0.2, 0.2)
	marcador.modulate = Color(1.0, 0.85, 0.3)

	print("Peça promovida a dama!")


# ==================================================
# TURNOS E IA
# ==================================================

func finalizar_turno(jogador: int) -> void:
	# O sinal some assim que o movimento termina, antes da vez da IA.
	limpar_destaques()
	limpar_selecao()

	if verificar_fim_de_jogo(jogador):
		return

	if contador_damas >= 20:
		encerrar_partida("Empate! 20 lances de damas sem captura.")
		return

	turno = -jogador

	if turno == -1:
		jogada_ia()
	else:
		# Os destinos só voltarão a aparecer quando o jogador selecionar
		# uma peça na sua vez.
		print("Sua vez!")


func jogada_ia() -> void:
	pensando_ia = true
	limpar_destaques()
	limpar_selecao()

	print("IA pensando...")
	await get_tree().create_timer(0.5).timeout

	# Segurança: a partida pode ter sido encerrada enquanto a IA aguardava.
	if partida_encerrada:
		pensando_ia = false
		return

	var movimentos: Array = obter_movimentos_validos(-1)
	if movimentos.is_empty():
		pensando_ia = false
		encerrar_partida("Você venceu! A IA não pode movimentar.")
		return

	var escolhido: Dictionary = movimentos.pick_random()
	executar_movimento(escolhido)

	pensando_ia = false

	if not verificar_fim_de_jogo(-1):
		turno = 1
		limpar_destaques()
		limpar_selecao()
		print("Sua vez!")


func verificar_fim_de_jogo(jogador: int) -> bool:

	var pecas_jogador := 0
	var pecas_adversario := 0

	for linha in range(8):
		for coluna in range(8):

			if casas[linha][coluna] == jogador:
				pecas_jogador += 1

			elif casas[linha][coluna] == -jogador:
				pecas_adversario += 1

	if pecas_adversario == 0:
		if jogador == 1:
			encerrar_partida("Você venceu!")
		else:
			encerrar_partida("A IA venceu!")

		return true

	if obter_movimentos_validos(-jogador).is_empty():
		if jogador == 1:
			encerrar_partida("Você venceu! A IA ficou sem movimentos.")
		else:
			encerrar_partida("A IA venceu! Você ficou sem movimentos.")

		return true

	return false


func encerrar_partida(mensagem: String) -> void:
	partida_encerrada = true
	print(mensagem)
	
func limpar_selecao() -> void:
	movimentos_selecionados.clear()
	passo_atual = 0
	posicao_selecionada = Vector2i(-1, -1)


func limpar_destaques() -> void:
	for destaque in destaques:
		if is_instance_valid(destaque):
			destaque.queue_free()
	destaques.clear()


func mostrar_destaque(posicao: Vector2i) -> void:
	# Duplica o ColorRect configurado na cena, preservando sua aparência.
	var destaque := sinal_movimento.duplicate() as ColorRect
	destaque.color = COR_MOVIMENTO
	destaque.size = Vector2(TAMANHO_CASA, TAMANHO_CASA)
	destaque.position = Vector2(
		-TAMANHO_TABULEIRO / 2.0 + posicao.x * TAMANHO_CASA,
		-TAMANHO_TABULEIRO / 2.0 + posicao.y * TAMANHO_CASA
	)
	destaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	destaque.show()
	camada_movimentos.add_child(destaque)
	destaques.append(destaque)


func atualizar_destaques(movimentos: Array) -> void:
	limpar_destaques()

	if turno != 1 or partida_encerrada or pensando_ia:
		return

	var destinos_mostrados: Array[Vector2i] = []
	for movimento in movimentos:
		var caminho: Array = movimento["caminho"]
		if passo_atual >= caminho.size():
			continue

		var destino: Vector2i = caminho[passo_atual]
		if destino not in destinos_mostrados:
			destinos_mostrados.append(destino)
			mostrar_destaque(destino)
