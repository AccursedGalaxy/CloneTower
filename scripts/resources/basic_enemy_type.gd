extends Resource
class_name BasicEnemyType

static func create_stats() -> EnemyStats:
	var stats = EnemyStats.new()
	stats.health = 30.0
	stats.speed = 100.0
	stats.damage = 1.0
	stats.reward = 50
	stats.type = "Basic"
	stats.enemy_name = "Red Slime"
	stats.enemy_description = "A basic slime enemy that moves towards the end"
	stats.resistance = 0.0
	stats.can_fly = false
	stats.is_boss = false
	stats.spawns_minions = false
	return stats
