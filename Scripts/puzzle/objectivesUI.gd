extends CanvasLayer

@onready var objetivo_label: Label = $VBoxContainer/objetivo
@onready var objetivos_aberto: Panel = $objetivos_aberto
@onready var title_label: Label = $VBoxContainer/title

# Ajuste os caminhos conforme a posição dos botões na sua cena
@onready var botao_fechar: Button = $fechar_objetivo
@onready var botao_abrir: Button = $abrir_objetivo
@onready var vbox: VBoxContainer = $VBoxContainer


func _ready() -> void:
	GameManager.objetivo_atualizado.connect(atualizar_objetivo)
	atualizar_objetivo()

	# Começa com os objetivos abertos
	objetivos_aberto.visible = true
	botao_abrir.visible = false


func atualizar_objetivo() -> void:
	var objetivo = GameManager.obter_objetivo_atual()

	if objetivo == null:
		objetivo_label.text = "Todos os objetivos concluídos!"
		return

	objetivo_label.text = "☐ " + objetivo["texto"]


func _on_fechar_objetivo_pressed() -> void:
	botao_fechar.hide()
	objetivos_aberto.hide()
	vbox.hide()
	botao_abrir.show()
	
func _on_abrir_objetivo_pressed() -> void:
	objetivos_aberto.show()
	vbox.show()
	botao_abrir.hide()
	botao_fechar.show()
