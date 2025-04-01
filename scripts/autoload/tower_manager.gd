extends Node

signal tower_purchased(tower_type: String)
signal tower_upgraded(tower: Node)
signal tower_sold(tower: Node)

var available_towers: Dictionary = {}
var tower_costs: Dictionary = {}
var active_towers: Array[Node] = []

func _ready() -> void:
	# Register basic tower
	register_tower_type("Basic", load("res://scripts/resources/basic_tower_type.gd"))
	# Register other towers as we add them

func register_tower_type(tower_name: String, tower_type: Resource) -> void:
	var stats = tower_type.create_stats()
	available_towers[tower_name] = tower_type
	tower_costs[tower_name] = stats.cost

func get_tower_stats(tower_name: String) -> Resource:
	if tower_name in available_towers:
		return available_towers[tower_name].create_stats()
	return null

func can_afford_tower(tower_name: String) -> bool:
	if tower_name in tower_costs:
		return GameStats.currency >= tower_costs[tower_name]
	return false

func purchase_tower(tower_name: String) -> bool:
	if can_afford_tower(tower_name):
		var cost = tower_costs[tower_name]
		if GameStats.spend_currency(cost):
			tower_purchased.emit(tower_name)
			return true
	return false

func register_active_tower(tower: Node) -> void:
	active_towers.append(tower)

func unregister_active_tower(tower: Node) -> void:
	active_towers.erase(tower)

func sell_tower(tower: Node) -> void:
	if tower.has_method("get_sell_value"):
		var value = tower.get_sell_value()
		GameStats.add_currency(value)
		unregister_active_tower(tower)
		tower_sold.emit(tower)
		tower.queue_free()

func upgrade_tower(tower: Node) -> bool:
	if not tower.has_method("get_upgrade_cost"):
		return false

	var cost = tower.get_upgrade_cost()
	if cost > 0 and GameStats.spend_currency(cost):
		if tower.has_method("upgrade_tower"):
			tower.upgrade_tower()
			tower_upgraded.emit(tower)
			return true
	return false

func get_towers_in_range(position: Vector2, detection_range: float) -> Array[Node]:
	var in_range: Array[Node] = []
	for tower in active_towers:
		if tower.global_position.distance_to(position) <= detection_range:
			in_range.append(tower)
	return in_range
