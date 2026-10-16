extends Node

var fase_atual := "fase_1"
var indice_objetivo := 0

signal objetivo_atualizado

var objetivos = {
	"fase_1": [
		{
			"id": "escovar_dentes",
			"texto": "Escove os dentes",
			"completo": false
		},
		{
			"id": "descer_escada",
			"texto": "Desça as escadas",
			"completo": false
		},
		{
			"id": "ferver_agua",
			"texto": "Ligue a chaleira",
			"completo": false
		},
				{
			"id": "ir_jardim",
			"texto":"Procure pela marta.",
			"completo": false
		}
	],

	"fase_2": [
		{
			"id": "pegar_foto",
			"texto": "Encontre a fotografia",
			"completo": false
		}
	]
}


func completar_objetivo(id: String):
	var objetivos_atuais = objetivos[fase_atual]

	# Verifica se ainda existem objetivos
	if indice_objetivo >= objetivos_atuais.size():
		return

	var objetivo_atual = objetivos_atuais[indice_objetivo]

	# Só permite completar o objetivo atual
	if objetivo_atual["id"] != id:
		return

	# Completa o objetivo
	objetivo_atual["completo"] = true

	# Vai para o próximo objetivo
	indice_objetivo += 1

	# Avisa a UI
	objetivo_atualizado.emit()

func objetivo_completo(id: String) -> bool:
	for objetivo in objetivos[fase_atual]:
		if objetivo["id"] == id:
			return objetivo["completo"]

	return false


func obter_objetivo_atual():
	var objetivos_atuais = objetivos[fase_atual]

	if indice_objetivo >= objetivos_atuais.size():
		return null

	return objetivos_atuais[indice_objetivo]
