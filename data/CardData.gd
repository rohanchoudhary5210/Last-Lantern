class_name CardData
extends Resource

@export var id: String = "damage"
@export var name: String = "Lantern Flame"
@export_multiline var description: String = "+10% Weapon Damage per level"
@export var rarity: String = "Common" # Common, Rare, Epic
@export var icon: Texture2D
@export var stat_modifiers: Dictionary = { "damage": 0.10 }
@export var max_level: int = 5
