extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Sprite2D/Area2D
@onready var shoot_timer: Timer = $ShootTimer

var hover_scale: float = 1.1
var normal_scale: float = 1.0
var is_mouse_over: bool = false
var is_dragging: bool = false
var drag_offset: Vector2
var original_position: Vector2

# Shooting parameters
@export var shoot_cooldown: float = 1.0  # Time between shots
@export var projectile_scene: PackedScene  # The slime ball scene to shoot
@export var detection_range: float = 500.0  # Maximum distance to detect enemies

# Bounce parameters
var bounce_height: float = 15.0
var bounce_duration: float = 0.5
var drop_duration: float = 0.2
var is_bouncing: bool = false
var bounce_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to area entered signal
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)

	# Set up shooting timer
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _process(_delta: float) -> void:
	# Get mouse position in local coordinates
	var mouse_pos = get_local_mouse_position()

	# Check if mouse is over the sprite
	if sprite_2d.get_rect().has_point(mouse_pos):
		if not is_mouse_over:
			is_mouse_over = true
			_on_mouse_enter()

		# Check for clicks while hovering
		if Input.is_action_just_pressed("click"):
			_on_click()
			start_drag()
	else:
		if is_mouse_over:
			is_mouse_over = false
			_on_mouse_exit()

	# Handle dragging
	if is_dragging:
		if Input.is_action_pressed("click"):
			# Move the tower with the mouse
			global_position = get_global_mouse_position() + drag_offset
		else:
			stop_drag()

func _on_shoot_timer_timeout() -> void:
	# Find nearest enemy
	var nearest_enemy = find_nearest_enemy()
	if nearest_enemy:
		shoot_at(nearest_enemy)

func find_nearest_enemy() -> Node2D:
	var nearest_distance = detection_range
	var nearest_enemy = null

	# Get all enemies in the scene
	var enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy

	return nearest_enemy

func shoot_at(target: Node2D) -> void:
	if not projectile_scene:
		return

	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position

	# Calculate direction to target
	var direction = (target.global_position - global_position).normalized()
	projectile.rotation = direction.angle()

func start_drag() -> void:
	is_dragging = true
	drag_offset = global_position - get_global_mouse_position()
	original_position = global_position

	# Stop any ongoing bounce when starting to drag
	if bounce_tween:
		bounce_tween.kill()
	sprite_2d.position.y = 0
	# Lift the tower slightly when dragging
	sprite_2d.position.y = -5

func stop_drag() -> void:
	is_dragging = false
	# Check if we're overlapping with any other towers
	if has_overlapping_areas():
		# If overlapping, return to original position with bounce
		var return_tween = create_tween()
		return_tween.set_trans(Tween.TRANS_QUINT)
		return_tween.set_ease(Tween.EASE_OUT)
		return_tween.tween_property(self, "global_position", original_position, drop_duration)
		return_tween.tween_callback(func(): start_bounce())
	else:
		# If valid position, just do a smooth drop and bounce
		start_bounce(bounce_height * 0.7)

func start_bounce(height: float = bounce_height) -> void:
	# Kill any existing bounce tween
	if bounce_tween:
		bounce_tween.kill()

	bounce_tween = create_tween()
	bounce_tween.set_trans(Tween.TRANS_CUBIC)  # Changed to cubic for smoother motion
	bounce_tween.set_ease(Tween.EASE_OUT)

	# First bounce (highest)
	bounce_tween.tween_property(sprite_2d, "position:y", -height, bounce_duration * 0.2)
	bounce_tween.tween_property(sprite_2d, "position:y", 0.0, bounce_duration * 0.3)

	# Second bounce (40% of height)
	bounce_tween.tween_property(sprite_2d, "position:y", -height * 0.4, bounce_duration * 0.15)
	bounce_tween.tween_property(sprite_2d, "position:y", 0.0, bounce_duration * 0.2)

	# Third bounce (15% of height)
	bounce_tween.tween_property(sprite_2d, "position:y", -height * 0.15, bounce_duration * 0.1)
	bounce_tween.tween_property(sprite_2d, "position:y", 0.0, bounce_duration * 0.15)

func _on_mouse_enter() -> void:
	# Make sprite bigger on hover
	sprite_2d.scale = Vector2(hover_scale, hover_scale)

func _on_mouse_exit() -> void:
	# Return to normal size
	sprite_2d.scale = Vector2(normal_scale, normal_scale)

func _on_click() -> void:
	print("TODO: Tower Stats UI")

func _on_area_entered(_area: Area2D) -> void:
	# If we're dragging and collide with another tower, show visual feedback
	if is_dragging:
		sprite_2d.modulate = Color(1, 0.5, 0.5)  # Red tint when overlapping
		start_bounce(bounce_height * 0.3)  # Small bounce on collision

func _on_area_exited(_area: Area2D) -> void:
	# Remove visual feedback when no longer overlapping
	sprite_2d.modulate = Color(1, 1, 1)  # Normal color

func has_overlapping_areas() -> bool:
	# Get all overlapping areas
	var overlapping_areas = area_2d.get_overlapping_areas()
	# Filter out our own area
	for area in overlapping_areas:
		if area.get_parent().get_parent() != self:
			return true
	return false
