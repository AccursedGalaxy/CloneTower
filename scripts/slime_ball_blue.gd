extends Node2D
class_name SlimeBallBlue

# Constants
const LIFETIME := 5.0
const DEFAULT_DAMAGE := 10.0

# Node references
@onready var area_2d: Area2D = $Area2D

# Projectile properties
@export var speed: float = 400.0
var damage: float = DEFAULT_DAMAGE

func _ready() -> void:
	# Add to projectiles group for cleanup
	add_to_group("projectiles")

	# Connect to area entered signal
	area_2d.area_entered.connect(_on_area_entered)
	# Set up a timer to delete the projectile if it goes off screen
	_setup_lifetime_timer()

func _process(delta: float) -> void:
	# Move in the direction we're rotated
	_move(delta)
	_check_bounds()

func _move(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _check_bounds() -> void:
	if not get_viewport_rect().has_point(position):
		queue_free()

func _setup_lifetime_timer() -> void:
	await get_tree().create_timer(LIFETIME).timeout
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Check if we hit an enemy
	var enemy = area.get_parent()
	if enemy.is_in_group("enemies") and enemy.has_method("take_damage"):
		enemy.take_damage(damage)
		queue_free()

func set_damage(new_damage: float) -> void:
	damage = new_damage
