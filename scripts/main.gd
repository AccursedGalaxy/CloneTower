extends Node2D

const DEFENSE_TOWER = preload("res://scenes/defense_tower.tscn")
const RED_SLIME = preload("res://scenes/red_slime_enemy.tscn")
const SLIME_BALL = preload("res://scenes/slime_ball_blue.tscn")
const SPAWN_MARGIN := 50.0  # Margin from viewport edges
const MAX_SPAWN_ATTEMPTS := 10  # Maximum number of attempts to find a valid spawn position
const MAX_TOWERS := 5  # Maximum number of towers allowed
const RESPAWN_DELAY := 2.0  # Seconds to wait before respawning when below max
const MIN_TOWER_DISTANCE := 100.0  # Minimum distance between towers

@onready var tower_spawn_timer: Timer = $TowerSpawnTimer
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
var current_tower_count := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("[Main] Scene initialized")
	print("[Main] Viewport size: ", get_viewport_rect().size)
	# Start spawning towers when the scene loads
	tower_spawn_timer.start(4)
	enemy_spawn_timer.start(2)  # Spawn enemy every 2 seconds
	print("[Main] Tower spawn timer started with interval: 4 seconds")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func is_valid_spawn_position(pos: Vector2, tower: Node2D) -> bool:
	# Temporarily position the tower to check for collisions
	var original_pos = tower.position
	tower.position = pos

	# Check if the tower's area overlaps with any other towers
	var area = tower.get_node("Sprite2D/Area2D")
	var overlapping_areas = area.get_overlapping_areas()

	# Check distance from other towers
	var towers = get_tree().get_nodes_in_group("towers")
	for other_tower in towers:
		if other_tower != tower:
			var distance = pos.distance_to(other_tower.position)
			if distance < MIN_TOWER_DISTANCE:
				tower.position = original_pos
				return false

	# Restore original position
	tower.position = original_pos

	# If there are any overlapping areas, the position is invalid
	return overlapping_areas.is_empty()

func spawn_tower() -> void:
	# Check if we've reached the maximum number of towers
	if current_tower_count >= MAX_TOWERS:
		print("[Main] Maximum number of towers reached (", MAX_TOWERS, ")")
		tower_spawn_timer.stop()
		return

	var tower = DEFENSE_TOWER.instantiate()
	add_child(tower)
	tower.add_to_group("towers")  # Add tower to group for easy access

	# Set up the projectile scene for the tower
	tower.projectile_scene = SLIME_BALL

	# Connect to the tree_exiting signal to track when towers are removed
	tower.tree_exiting.connect(_on_tower_removed)

	var spawn_area = get_spawn_area()
	var valid_position_found = false
	var spawn_position = Vector2.ZERO

	# Try to find a valid spawn position
	for _i in range(MAX_SPAWN_ATTEMPTS):
		spawn_position = Vector2(
			randf_range(spawn_area.position.x, spawn_area.end.x),
			randf_range(spawn_area.position.y, spawn_area.end.y)
		)

		if is_valid_spawn_position(spawn_position, tower):
			valid_position_found = true
			break

	if valid_position_found:
		tower.position = spawn_position
		current_tower_count += 1
		print("[Main] Spawned tower at position: ", tower.position, " (", current_tower_count, "/", MAX_TOWERS, " towers)")
	else:
		print("[Main] Could not find valid spawn position after ", MAX_SPAWN_ATTEMPTS, " attempts")
		tower.queue_free()  # Remove the tower if we couldn't place it

func get_spawn_area() -> Rect2:
	# get random position within the viewport (with margin)
	var viewport_size = get_viewport_rect().size
	var spawn_area = Rect2(
		SPAWN_MARGIN,
		SPAWN_MARGIN,
		viewport_size.x - (SPAWN_MARGIN * 2),
		viewport_size.y - (SPAWN_MARGIN * 2))
	return spawn_area

func _on_tower_spawn_timer_timeout() -> void:
	print("[Main] Timer timeout - spawning new tower")
	spawn_tower()

func _on_tower_removed() -> void:
	current_tower_count -= 1
	print("[Main] Tower removed. Current count: ", current_tower_count, "/", MAX_TOWERS)

	# If we're below the maximum, start the respawn timer
	if current_tower_count < MAX_TOWERS:
		if not tower_spawn_timer.is_stopped():
			return  # Timer is already running

		print("[Main] Starting respawn timer (", RESPAWN_DELAY, " seconds)")
		tower_spawn_timer.start(RESPAWN_DELAY)

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	var enemy = RED_SLIME.instantiate()
	add_child(enemy)
