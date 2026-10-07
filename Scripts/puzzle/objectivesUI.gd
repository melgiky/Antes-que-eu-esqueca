extends CanvasLayer

@onready var objetivo_label: Label = $Panel/VBoxContainer/objetivo


func _ready():
	GameManager.objetivo_atualizado.connect(atualizar_objetivo)
	atualizar_objetivo()


func atualizar_objetivo():
	var objetivo = GameManager.obter_objetivo_atual()

	if objetivo == null:
		objetivo_label.text = "Todos os objetivos concluídos!"
		return

	objetivo_label.text = "☐ " + objetivo["texto"]
