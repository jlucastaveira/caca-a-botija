extends Control

const IMG_ALMA := preload("res://assets/alma.png")
const IMG_BOTIJA := preload("res://assets/botija.png")
const IMG_TERRA_FECHADA := preload("res://assets/terra_fechada.png")
const IMG_TERRA_CAVADA := preload("res://assets/terra_cavada.png")
const IMG_BILHO := preload("res://assets/brilho.png")

const LINHAS := 6
const COLUNAS := 6
const TOTAL_ALMAS := 6
const ALMAS_PARA_PERDER := 3
const CAVADAS_ATE_AMANHECER := 12

@onready var grade: GridContainer = $VBoxContainer/Grade
@onready var status: Label = $VBoxContainer/Status

var botoes := {}
var almas := []
var botija: Vector2i
var almas_despertadas := 0
var fim_de_jogo := false
var cavadas_restantes := CAVADAS_ATE_AMANHECER


func _ready():
	grade.columns = COLUNAS
	
	var estilo_fechado := _criar_estilo(IMG_TERRA_FECHADA)
	var estilo_cavado := _criar_estilo(IMG_TERRA_CAVADA)
	
	# Basicamente esse for cria todos os botoes (36), em vez de criar todos manualmente
	for y in LINHAS:
		for x in COLUNAS:
			var pos := Vector2i(x,y)
			var botao := Button.new()
			botao.custom_minimum_size = Vector2(64, 64)
			botao.expand_icon = true
			botao.add_theme_color_override('icon_disabled_color', Color.WHITE)
			botao.add_theme_color_override('font_disabled_color', Color.WHITE)
			botao.add_theme_stylebox_override('normal', estilo_fechado)
			botao.add_theme_stylebox_override('hover', estilo_fechado)
			botao.add_theme_stylebox_override('pressed', estilo_fechado)
			botao.add_theme_stylebox_override('disabled', estilo_cavado)
			botao.focus_mode = Control.FOCUS_NONE
			botao.pressed.connect(_ao_cavar.bind(pos))
			grade.add_child(botao)
			botoes[pos] = botao
	_esconder_tesouros()
	_atualizar_status('Cave com cuidado...')

func _esconder_tesouros():
	var posicoes = botoes.keys()
	posicoes.shuffle()
	botija = posicoes[0]
	almas = posicoes.slice(1, 1 + TOTAL_ALMAS)

func _vizinhos(pos: Vector2i) -> Array:
	var lista := []
	for dy in range (-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var v := pos + Vector2i(dx, dy)
			if botoes.has(v):
				lista.append(v)
	return lista

func _ao_cavar(pos: Vector2i):
	if fim_de_jogo:
		return
	var botao: Button = botoes[pos]
	botao.disabled = true
	cavadas_restantes -= 1
	
	if pos == botija:
		botao.icon = IMG_BOTIJA
		fim_de_jogo = true
		status.text = 'Você encontrou a BOTIJA! VITORIA!'

	elif pos in almas:
		botao.icon = IMG_ALMA
		almas_despertadas += 1
		if almas_despertadas >= ALMAS_PARA_PERDER:
			fim_de_jogo = true
			_revelar_tudo()
			status.text = 'As almas te levaram... DERROTA!'
		else:
			_atualizar_status('Uma Alma despertou!!')
	else:
		var qtd := 0 
		for v in _vizinhos(pos):
			if v in almas:
				qtd += 1
		var texto := ''
		if qtd > 0:
			texto = str(qtd)
		if botija in _vizinhos(pos):
			botao.icon = IMG_BILHO
		botao.text = texto
		_atualizar_status('Continue cavando...')
		
	if not fim_de_jogo and cavadas_restantes <= 0:
		fim_de_jogo = true
		_revelar_tudo()
		status.text = 'O galo cantou... a alma levou a botija de volta. DERROTA!'

func _revelar_tudo():
	for a in almas:
		botoes[a].icon = IMG_ALMA
	botoes[botija].icon = IMG_BOTIJA
	for b in botoes.values():
		b.disabled = true	

func _atualizar_status(mensagem: String):
	status.text = '%s\nAlmas despertadas: %d/%d | Cavadas até o amanhecer: %d' % [mensagem, almas_despertadas, ALMAS_PARA_PERDER, cavadas_restantes]

func _on_button_reiniciar_pressed() -> void:
	get_tree().reload_current_scene()

func _on_button_comecar_pressed() -> void:
	$Intro.visible = false
	_atualizar_status('Cave com cuidado...')

func _criar_estilo(textura: Texture2D) -> StyleBoxTexture:
	var estilo := StyleBoxTexture.new()
	estilo.texture = textura
	return estilo
