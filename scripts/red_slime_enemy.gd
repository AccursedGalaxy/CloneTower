extends Node2D
class_name RedSlimeEnemy

# Constants
const SPAWN_OFFSET := -50.0
const DESPAWN_OFFSET := 50.0
const HIT_FLASH_DURATION := 0.1
const HIT_FLASH_COLOR := Color(1, 0.5, 0.5)

# Node references
@onready var area_2d: Area2D = $Area2D

# Enemy properties
var stats: EnemyStats
var current_health: float

signal enemy_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_enemy()
	add_to_group("enemies")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += stats.speed * delta

	if position.x > get_viewport_rect().size.x + DESPAWN_OFFSET:
		queue_free()

func _initialize_enemy() -> void:
	stats = BasicEnemyType.create_stats()
	current_health = stats.health

	position.x = SPAWN_OFFSET
	position.y = randf_range(50, get_viewport_rect().size.y - 50)

func take_damage(amount: float) -> void:
	var actual_damage = stats.calculate_damage_taken(amount)
	current_health -= actual_damage

	_show_damage_feedback()

	if current_health <= 0:
		enemy_died.emit()
		queue_free()

func _show_damage_feedback() -> void:
	modulate = HIT_FLASH_COLOR
	await get_tree().create_timer(HIT_FLASH_DURATION).timeout
	modulate = Color.WHITE

func get_reward() -> int:
	return stats.reward
