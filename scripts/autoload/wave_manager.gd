extends Node

signal wave_started(wave_number: int)
signal wave_completed
signal all_waves_completed
signal enemy_spawned(enemy: Node)
signal enemy_reached_end
signal enemy_defeated(reward: int)

var current_wave_data: Resource
var enemies_remaining: int = 0
var wave_in_progress: bool = false
var spawn_timer: Timer
var enemy_scene = preload("res://scenes/red_slime_enemy.tscn")

func _ready() -> void:
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func start_wave(wave_number: int) -> void:
	if wave_in_progress:
		return

	current_wave_data = generate_wave_data(wave_number)
	enemies_remaining = current_wave_data.get_total_enemies()
	wave_in_progress = true

	# Start spawning
	spawn_timer.wait_time = current_wave_data.enemy_spacing
	spawn_timer.start()

	wave_started.emit(wave_number)

func _on_spawn_timer_timeout() -> void:
	if enemies_remaining > 0:
		spawn_enemy()
		enemies_remaining -= 1
	else:
		spawn_timer.stop()

func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)

	# Connect signals
	enemy.enemy_died.connect(_on_enemy_defeated.bind(enemy))

	# Apply wave modifiers
	var enemy_type = load("res://scripts/resources/basic_enemy_type.gd")
	var base_stats = enemy_type.create_stats()
	base_stats.health *= current_wave_data.health_multiplier
	base_stats.speed *= current_wave_data.speed_multiplier

	# Set enemy stats
	enemy.stats = base_stats
	enemy.current_health = enemy.stats.health

	enemy_spawned.emit(enemy)

func _on_enemy_defeated(enemy: Node) -> void:
	var reward = enemy.get_reward()
	enemy_defeated.emit(reward)

	# Add currency and score
	GameStats.add_currency(reward)
	GameStats.add_score(reward)

	check_wave_completion()

func _on_enemy_reached_end() -> void:
	enemy_reached_end.emit()
	GameStats.take_damage(1)
	check_wave_completion()

func check_wave_completion() -> void:
	if enemies_remaining <= 0 and get_tree().get_nodes_in_group("enemies").is_empty():
		wave_completed.emit()
		wave_in_progress = false

func generate_wave_data(wave_number: int) -> Resource:
	var wave_data_script = load("res://scripts/resources/wave_data.gd")
	var data = wave_data_script.new()
	data.wave_number = wave_number
	data.enemy_types = ["Basic"] # Add more types as we create them
	data.enemy_counts = [5 + wave_number * 2] # Simple scaling for now
	data.spawn_intervals = [1.0]
	data.enemy_spacing = 1.0
	data.health_multiplier = 1.0 + (wave_number * 0.1)
	data.speed_multiplier = 1.0 + (wave_number * 0.05)
	data.reward_multiplier = 1.0 + (wave_number * 0.1)
	data.boss_wave = (wave_number % 5 == 0) # Boss every 5 waves
	return data
