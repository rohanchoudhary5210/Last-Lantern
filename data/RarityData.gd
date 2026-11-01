class_name RarityData
extends Resource

@export var common_name: String = "Common"
@export var common_color: Color = Color(0.8, 0.8, 0.8, 1.0)
@export var common_multiplier: float = 1.0

@export var rare_name: String = "Rare"
@export var rare_color: Color = Color(0.2, 0.75, 1.0, 1.0)
@export var rare_multiplier: float = 1.35

@export var epic_name: String = "Epic"
@export var epic_color: Color = Color(0.85, 0.3, 1.0, 1.0)
@export var epic_multiplier: float = 1.75

@export var rare_chance: float = 0.35
@export var epic_chance: float = 0.15

func roll_rarity() -> Dictionary:
	var roll = randf()
	if roll < epic_chance:
		return {"name": epic_name, "color": epic_color, "multiplier": epic_multiplier}
	elif roll < (epic_chance + rare_chance):
		return {"name": rare_name, "color": rare_color, "multiplier": rare_multiplier}
	else:
		return {"name": common_name, "color": common_color, "multiplier": common_multiplier}
