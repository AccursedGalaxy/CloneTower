extends Resource
class_name BasicTowerType

static func create_stats() -> TowerStats:
	var stats = TowerStats.new()
	stats.damage = 10.0
	stats.attack_speed = 1.0
	stats.attack_range = 800.0
	stats.cost = 100
	stats.tower_name = "Basic Tower"
	stats.tower_description = "A reliable defense tower that shoots projectiles at enemies"
	stats.upgrade_costs = PackedInt32Array([150, 300, 500])
	return stats

static func apply_upgrade_effects(stats: TowerStats) -> void:
	match stats.upgrade_level:
		1:  # First upgrade
			stats.damage *= 1.5
			stats.tower_description = "Enhanced damage output"
		2:  # Second upgrade
			stats.attack_speed *= 1.2
			stats.tower_description = "Faster attack speed"
		3:  # Third upgrade
			stats.attack_range *= 1.3
			stats.tower_description = "Extended attack range"
