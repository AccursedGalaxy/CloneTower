extends Node2D

@onready var area_2d: Area2D = $Area2D
@export var speed: float = 100.0  # Movement speed in pixels/sec
@export var max_health: float = 30.0  # Maximum health of the enemy
var current_health: float

signal enemy_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start at the left side of the screen, just outside view
	position.x = -50
	position.y = randf_range(50, get_viewport_rect().size.y - 50)

	# Initialize health
	current_health = max_health

	# Add to enemies group for targeting
	add_to_group("enemies")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move right
	position.x += speed * delta

	# If we're off screen to the right, queue for deletion
	if position.x > get_viewport_rect().size.x + 50:
		queue_free()

func take_damage(amount: float) -> void:
	current_health -= amount

	# Visual feedback when hit
	modulate = Color(1, 0.5, 0.5)  # Red tint
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)  # Normal color

	# Check if dead
	if current_health <= 0:
		enemy_died.emit()
		queue_free()
