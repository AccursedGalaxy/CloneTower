extends Resource
class_name EnemyStats

@export var health: float = 30.0
@export var speed: float = 100.0
@export var damage: float = 1.0
@export var reward: int = 50
@export var type: String = "Basic"
@export var resistance: float = 0.0  # Damage reduction percentage (0-1)
@export var enemy_name: String = "Basic Enemy"
@export var enemy_description: String = "A basic enemy type"

# Special abilities or traits
@export var can_fly: bool = false
@export var is_boss: bool = false
@export var spawns_minions: bool = false
@export var minion_type: String = ""
@export var minion_count: int = 0

func calculate_damage_taken(raw_damage: float) -> float:
	return raw_damage * (1.0 - resistance)

func is_special_enemy() -> bool:
	return can_fly or is_boss or spawns_minions
