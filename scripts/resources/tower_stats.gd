extends Resource
class_name TowerStats

@export var damage: float = 10.0
@export var attack_speed: float = 1.0
@export var attack_range: float = 800.0
@export var cost: int = 100
@export var upgrade_costs: PackedInt32Array = PackedInt32Array([200, 400, 800])
@export var tower_name: String = "Basic Tower"
@export var tower_description: String = "A basic defense tower"
@export var upgrade_level: int = 0
@export var max_upgrade_level: int = 3

func get_next_upgrade_cost() -> int:
	if upgrade_level >= max_upgrade_level:
		return -1
	return upgrade_costs[upgrade_level]

func can_upgrade() -> bool:
	return upgrade_level < max_upgrade_level

func apply_upgrade() -> void:
	if can_upgrade():
		upgrade_level += 1
		damage *= 1.5
		attack_speed *= 1.2
