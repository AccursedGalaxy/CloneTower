extends Node

signal currency_changed(new_amount: int)
signal wave_changed(new_wave: int)
signal score_changed(new_score: int)
signal health_changed(new_health: int)

var currency: int = 100
var current_wave: int = 0
var score: int = 0
var high_score: int = 0
var player_health: int = 10

func _ready() -> void:
	# Initialize signals
	currency_changed.emit(currency)
	wave_changed.emit(current_wave)
	score_changed.emit(score)
	health_changed.emit(player_health)

func add_currency(amount: int) -> void:
	currency += amount
	currency_changed.emit(currency)

func spend_currency(amount: int) -> bool:
	if currency >= amount:
		currency -= amount
		currency_changed.emit(currency)
		return true
	return false

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)
	if score > high_score:
		high_score = score

func take_damage(amount: int) -> void:
	player_health -= amount
	health_changed.emit(player_health)

func is_game_over() -> bool:
	return player_health <= 0

func start_new_wave() -> void:
	current_wave += 1
	wave_changed.emit(current_wave)

func reset_game() -> void:
	currency = 100
	current_wave = 0
	score = 0
	player_health = 10

	currency_changed.emit(currency)
	wave_changed.emit(current_wave)
	score_changed.emit(score)
	health_changed.emit(player_health)
