class_name CardLevelData
extends Resource

# Duplicate cards required to upgrade to the next level (index 0 = Lv.1->2, index 1 = Lv.2->3, etc.)
@export var duplicate_costs: Array[int] = [1, 2, 4, 8, 16]

func get_duplicate_cost(current_level: int) -> int:
	if current_level < 1:
		return 1
	var idx = current_level - 1
	if idx < duplicate_costs.size():
		return duplicate_costs[idx]
	return duplicate_costs[-1] * 2
