class_name MetaUpgradeData
extends Resource

@export var id: String = "max_hp"
@export var name: String = "Vitality"
@export_multiline var description: String = "+20 Max Health per rank"
@export var stat_type: String = "max_hp" # "max_hp", "move_speed", "torch_radius", "damage", "soul_magnet"
@export var max_level: int = 5
@export var base_price: int = 10
@export var price_growth: float = 1.5
@export var bonus_per_level: float = 20.0
@export var icon: Texture2D

func get_price(current_level: int) -> int:
	if current_level >= max_level:
		return -1
	return int(round(base_price * pow(price_growth, current_level)))
