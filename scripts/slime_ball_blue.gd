extends Node2D

@export var speed: float = 300.0
@export var damage: float = 10.0
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	# Connect to area entered signal
	area_2d.area_entered.connect(_on_area_entered)
	# Set up a timer to delete the projectile if it goes off screen
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _process(delta: float) -> void:
	# Move in the direction we're facing
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta

	# Delete if off screen
	if position.x < -50 or position.x > get_viewport_rect().size.x + 50 or \
	   position.y < -50 or position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Check if we hit an enemy
	if area.get_parent().is_in_group("enemies"):
		# Deal damage to the enemy
		area.get_parent().take_damage(damage)
		# Delete the projectile
		queue_free()
