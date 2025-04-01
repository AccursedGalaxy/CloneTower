extends Resource
class_name WaveData

# Wave configuration
@export var wave_number: int = 1
@export var enemy_types: Array[String] = []
@export var enemy_counts: Array[int] = []
@export var spawn_intervals: Array[float] = []
@export var wave_delay: float = 5.0  # Delay before wave starts
@export var enemy_spacing: float = 1.0  # Time between enemy spawns
@export var boss_wave: bool = false
@export var reward_multiplier: float = 1.0

# Special wave modifiers
@export var speed_multiplier: float = 1.0
@export var health_multiplier: float = 1.0
@export var spawn_paths: Array[NodePath] = []  # Different paths enemies can take

func get_total_enemies() -> int:
	var total := 0
	for count in enemy_counts:
		total += count
	return total

func is_final_wave() -> bool:
	return boss_wave

func get_wave_difficulty() -> float:
	return (wave_number * 0.5) * (1.0 + (0.1 * wave_number))

func calculate_enemy_stats(base_stats: EnemyStats) -> EnemyStats:
	var modified_stats := EnemyStats.new()
	modified_stats.health = base_stats.health * health_multiplier
	modified_stats.speed = base_stats.speed * speed_multiplier
	modified_stats.damage = base_stats.damage
	modified_stats.reward = int(base_stats.reward * reward_multiplier)
	modified_stats.type = base_stats.type
	modified_stats.resistance = base_stats.resistance
	return modified_stats
