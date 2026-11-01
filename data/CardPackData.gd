class_name CardPackData
extends Resource

@export var pack_price: int = 150
@export var cards_per_pack: int = 3
@export var rarity_weights: Dictionary = {
	"Common": 65.0,
	"Rare": 25.0,
	"Epic": 10.0
}
@export var boss_card_drop_chance: float = 0.50
@export var pack_sound: AudioStream
@export var reveal_sound: AudioStream

func roll_rarity() -> String:
	var total_w = 0.0
	for r in rarity_weights:
		total_w += rarity_weights[r]
	if total_w <= 0.0:
		return "Common"
	var roll = randf() * total_w
	var cur = 0.0
	for r in rarity_weights:
		cur += rarity_weights[r]
		if roll <= cur:
			return r
	return "Common"
