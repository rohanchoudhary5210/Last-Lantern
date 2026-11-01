class_name EvolutionData
extends Resource

@export var id: String = "evo_sunburst"
@export var name: String = "Sunburst"
@export_multiline var description: String = "Pistol Lv.5 + Lantern Radiance. Fires piercing radiant solar orbs that incinerate enemy hordes."
@export var base_weapon_id: String = "pistol"
@export var required_weapon_level: int = 5
@export var required_upgrade_id: String = "torch_radius"
@export var evolved_weapon: WeaponData
@export var icon: Texture2D
