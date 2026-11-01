class_name CurseData
extends Resource

@export var id: String = "curse_eclipse"
@export var name: String = "Solar Eclipse"
@export_multiline var description: String = "-35% Torch Radius, but +100% Souls Harvested"
@export var flavor: String = "Deep darkness shrouds the ruins, but fallen souls burn twice as bright."

# Modifiers
@export var torch_radius_mult: float = 1.0
@export var soul_gain_mult: float = 0.0
@export var zombie_speed_mult: float = 1.0
@export var zombie_hp_mult: float = 1.0
@export var zombie_damage_mult: float = 1.0
@export var airdrop_interval_mult: float = 1.0
@export var player_damage_mult: float = 0.0
@export var player_speed_mult: float = 0.0
@export var player_hp_mult: float = 1.0

static func get_daily_curse(curses: Array) -> CurseData:
	if curses.is_empty():
		return null
	var dt = Time.get_date_dict_from_system()
	var day_seed = dt.year * 10000 + dt.month * 100 + dt.day
	var idx = abs(day_seed) % curses.size()
	return curses[idx]
