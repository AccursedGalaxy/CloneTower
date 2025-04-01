extends Node2D
class_name DefenseTower

# Constants for tower behavior
const HOVER_SCALE := 1.1
const NORMAL_SCALE := 1.0
const DRAG_LIFT_HEIGHT := -5.0

# Constants for bounce animation
const BOUNCE_HEIGHT := 15.0
const BOUNCE_DURATION := 0.5
const DROP_DURATION := 0.2
const BOUNCE_SECONDARY_SCALE := 0.4
const BOUNCE_TERTIARY_SCALE := 0.15

# Node references
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Sprite2D/Area2D
@onready var shoot_timer: Timer = $ShootTimer

# Tower properties
@export var projectile_scene: PackedScene
var stats: TowerStats

# State tracking
var is_mouse_over := false
var is_dragging := false
var drag_offset: Vector2
var original_position: Vector2
var bounce_tween: Tween
var last_target_pos: Vector2
var last_target_time: float

signal tower_selected(tower: DefenseTower)

func _ready() -> void:
	_initialize_tower()
	_setup_signals()

func _process(_delta: float) -> void:
	_handle_mouse_interaction()
	_handle_dragging()

# Initialization methods
func _initialize_tower() -> void:
	stats = BasicTowerType.create_stats()
	shoot_timer.wait_time = 1.0 / stats.attack_speed
	shoot_timer.start()

func _setup_signals() -> void:
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

# Mouse interaction handling
func _handle_mouse_interaction() -> void:
	var mouse_pos = get_local_mouse_position()
	var is_over_sprite = sprite_2d.get_rect().has_point(mouse_pos)

	if is_over_sprite and not is_mouse_over:
		is_mouse_over = true
		_on_mouse_enter()
	elif not is_over_sprite and is_mouse_over:
		is_mouse_over = false
		_on_mouse_exit()

	if is_over_sprite and Input.is_action_just_pressed("click"):
		_on_click()
		start_drag()

func _handle_dragging() -> void:
	if is_dragging:
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() + drag_offset
		else:
			stop_drag()

# Combat methods
func _on_shoot_timer_timeout() -> void:
	var nearest_enemy = find_nearest_enemy()
	if nearest_enemy:
		shoot_at(nearest_enemy)

func find_nearest_enemy() -> Node2D:
	var nearest_distance = stats.attack_range
	var nearest_enemy = null
	var best_prediction_score := INF

	for enemy in get_tree().get_nodes_in_group("enemies"):
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			# Calculate how good this target would be based on their position and movement
			var prediction_score = _calculate_prediction_score(enemy)
			if prediction_score < best_prediction_score:
				best_prediction_score = prediction_score
				nearest_enemy = enemy
				nearest_distance = distance

	return nearest_enemy

func _calculate_prediction_score(enemy: Node2D) -> float:
	# Lower score is better
	var distance = global_position.distance_to(enemy.global_position)

	# Prefer enemies that are further along in their path (more x progress)
	var progress_weight = 1.0 - (enemy.position.x / get_viewport_rect().size.x)

	# Combine factors - distance is primary, progress is secondary
	return distance * 0.8 + progress_weight * 0.2

func shoot_at(target: Node2D) -> void:
	if not projectile_scene or not target:
		return

	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)

	if projectile.has_method("set_damage"):
		projectile.set_damage(stats.damage)

	var spawn_offset = Vector2(0, -sprite_2d.texture.get_height() * sprite_2d.scale.y / 2)
	projectile.global_position = global_position + spawn_offset

	# Calculate target velocity
	var target_velocity := Vector2.ZERO
	var current_time := Time.get_ticks_msec() / 1000.0

	if target.has_method("get_velocity"):
		target_velocity = target.get_velocity()
	else:
		# Estimate velocity if the target doesn't provide it
		if last_target_time > 0:
			var dt = current_time - last_target_time
			if dt > 0:
				target_velocity = (target.global_position - last_target_pos) / dt

	# Store current position and time for next velocity calculation
	last_target_pos = target.global_position
	last_target_time = current_time

	# Calculate intercept point
	var _direction_to_target = (target.global_position - projectile.global_position).normalized()
	var distance_to_target = projectile.global_position.distance_to(target.global_position)
	var projectile_speed = projectile.speed
	var time_to_target = distance_to_target / projectile_speed

	# Predict where the target will be
	var predicted_pos = target.global_position + target_velocity * time_to_target

	# Calculate final aim direction
	var aim_direction = (predicted_pos - projectile.global_position).normalized()
	projectile.rotation = aim_direction.angle()

# Drag and drop methods
func start_drag() -> void:
	is_dragging = true
	drag_offset = global_position - get_global_mouse_position()
	original_position = global_position

	if bounce_tween:
		bounce_tween.kill()
	sprite_2d.position.y = DRAG_LIFT_HEIGHT

func stop_drag() -> void:
	is_dragging = false

	if has_overlapping_areas():
		var return_tween = create_tween()
		return_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		return_tween.tween_property(self, "global_position", original_position, DROP_DURATION)
		return_tween.tween_callback(func(): start_bounce())
	else:
		start_bounce(BOUNCE_HEIGHT * 0.7)

# Visual feedback methods
func start_bounce(height: float = BOUNCE_HEIGHT) -> void:
	if bounce_tween:
		bounce_tween.kill()

	bounce_tween = create_tween()
	bounce_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Main bounce
	bounce_tween.tween_property(sprite_2d, "position:y", -height, BOUNCE_DURATION * 0.2)
	bounce_tween.tween_property(sprite_2d, "position:y", 0.0, BOUNCE_DURATION * 0.3)

	# Secondary bounce
	bounce_tween.tween_property(sprite_2d, "position:y", -height * BOUNCE_SECONDARY_SCALE, BOUNCE_DURATION * 0.15)
	bounce_tween.tween_property(sprite_2d, "position:y", 0.0, BOUNCE_DURATION * 0.2)

	# Tertiary bounce
	bounce_tween.tween_property(sprite_2d, "position:y", -height * BOUNCE_TERTIARY_SCALE, BOUNCE_DURATION * 0.1)
	bounce_tween.tween_property(sprite_2d, "position:y", 0.0, BOUNCE_DURATION * 0.15)

func _on_mouse_enter() -> void:
	sprite_2d.scale = Vector2(HOVER_SCALE, HOVER_SCALE)

func _on_mouse_exit() -> void:
	sprite_2d.scale = Vector2(NORMAL_SCALE, NORMAL_SCALE)

func _on_click() -> void:
	tower_selected.emit(self)

func _on_area_entered(_area: Area2D) -> void:
	if is_dragging:
		sprite_2d.modulate = Color(1, 0.5, 0.5)
		start_bounce(BOUNCE_HEIGHT * 0.3)

func _on_area_exited(_area: Area2D) -> void:
	sprite_2d.modulate = Color.WHITE

func has_overlapping_areas() -> bool:
	for area in area_2d.get_overlapping_areas():
		if area.get_parent().get_parent() != self:
			return true
	return false

# Upgrade handling
func upgrade_tower() -> bool:
	if stats.can_upgrade():
		stats.apply_upgrade()
		shoot_timer.wait_time = 1.0 / stats.attack_speed
		return true
	return false
