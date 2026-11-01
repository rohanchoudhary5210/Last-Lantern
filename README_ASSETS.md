# README_ASSETS.md — Last Lantern Asset Reference

This document lists all editable asset files in `res://assets/` and data resources in `res://data/`.
Every visual is rendered through a dedicated `Sprite2D` node in the corresponding scene and can be replaced with your own custom textures or audio files simply by dropping in a file with the same name.

---

## 1. Sprites (`res://assets/sprites/`)

All placeholder character and object sprites are 64x64 transparent PNGs with flat neon silhouettes.

| File Name | Dimensions / Format | Used In Scene / Node | Description & Replacement Notes |
| :--- | :--- | :--- | :--- |
| `player.png` | 64x64 PNG | `Player.tscn` (`Sprite2D`) | Survivor holding a warm golden lantern and sidearm. Swap with any 64x64 or higher resolution top-down survivor sprite. |
| `zombie_walker.png` | 64x64 PNG | `Zombie.tscn` (`Sprite2D`), `zombie_walker.tres` | Standard shambling zombie silhouette with toxic neon green eyes. |
| `zombie_fast.png` | 64x64 PNG | `zombie_fast.tres` | Agile, crouched runner zombie silhouette with emerald green neon eyes. |
| `zombie_tank.png` | 64x64 PNG | `zombie_tank.tres` | Heavy brute tank zombie silhouette with broad spiked shoulders and glowing eyes. |
| `bullet.png` | 64x64 PNG | `Bullet.tscn` (`Sprite2D`), `WeaponData` | Glowing neon projectile energy capsule (tinted dynamically per weapon). |
| `crate.png` | 64x64 PNG | `Crate.tscn` (`CrateSprite`, `ShadowSprite`) | High-tech airdrop supply crate with neon hazard stripes and corner brackets. |
| `ground_tile.png` | 64x64 PNG | `Main.tscn` (`Ground` Sprite2D) | Seamless dark stone pavement texture tiled across the entire arena. |
| `light_mask.png` | 256x256 PNG | `Player.tscn`, `Zombie.tscn`, `Crate.tscn`, `Bullet.tscn` (`PointLight2D`) | Smooth radial gradient falloff mask powering the 2D lighting and glowing eyes. |
| `particle_splat.png` | 16x16 PNG | `Zombie.tscn` (`DeathParticles` CPUParticles2D) | Neon toxic green bio-spark particle for zombie death burst. |
| `particle_dust.png` | 32x32 PNG | `Crate.tscn` (`LandingDust` CPUParticles2D) | Soft cyan smoke puff particle for airdrop crate landing impact. |
| `zombie_spitter.png` | 64x64 PNG | `zombie_spitter.tres` (`Sprite2D`) | Bloated acid spitter silhouette that halts at range to launch projectiles. |
| `zombie_boss.png` | 64x64 PNG | `zombie_boss.tres` (`Sprite2D`) | Massive horned demon abomination boss with crimson armor and power core. |
| `zombie_exploder.png` | 64x64 PNG | `zombie_exploder.tres` (`Sprite2D`) | Volatile bloated crimson zombie silhouette with radiating bio-hazard core. |
| `zombie_charger.png` | 64x64 PNG | `zombie_charger.tres` (`Sprite2D`) | Muscular horned brute runner silhouette with forward-tilted ramming stance. |
| `zombie_summoner.png` | 64x64 PNG | `zombie_summoner.tres` (`Sprite2D`) | Hooded occult necromancer silhouette clutching a dark summoning catalyst. |
| `zombie_ghost.png` | 64x64 PNG | `zombie_ghost.tres` (`Sprite2D`) | Ethereal cyan wraith silhouette invisible in darkness, phasing through hordes. |
| `spit.png` | 32x32 PNG | `Bullet.tscn` (Enemy Projectile) | Glowing acid spit projectile orb launched by ranged spitters and bosses. |
| `hero_luka.png` | 64x64 PNG | `hero_luka.tres` (`Sprite2D`) | Luka the Lanternkeeper with golden coat and high torch vision. |
| `hero_jax.png` | 64x64 PNG | `hero_jax.tres` (`Sprite2D`) | Jax the Outrunner with streamlined tech vest, cyan visor, and dual SMGs. |
| `hero_kora.png` | 64x64 PNG | `hero_kora.tres` (`Sprite2D`) | Kora the Enforcer with heavy orange reinforced armor and blast shotgun. |
| `soul.png` | 64x64 PNG | `Soul.tscn` (`Sprite2D`), drops | Ethereal glowing cyan wisp soul drop with radiant light aura attracted by player magnet. |
| `bullet_sunburst.png` | 64x64 PNG | `pistol_evolved.tres` (`Bullet.tscn`) | Radiant solar orb projectile with blazing golden corona and piercing trail. |
| `bullet_plasma.png` | 64x64 PNG | `smg_evolved.tres` (`Bullet.tscn`) | Electric cyan twin plasma energy bolts for rapid-fire stream. |
| `bullet_doom.png` | 64x64 PNG | `shotgun_evolved.tres` (`Bullet.tscn`) | Heavy incandescent molten flak cannon shard with jagged spikes. |
| `bullet_flame.png` | 64x64 PNG | `flamethrower.tres` (`Bullet.tscn`) | Glowing orange-yellow plasma cone flame burst. |
| `bullet_bolt.png` | 64x64 PNG | `crossbow.tres` (`Bullet.tscn`) | Heavy neon cyan crossbow bolt that sticks in the ground for 0.5s. |
| `bullet_grenade.png` | 64x64 PNG | `grenade_launcher.tres` (`Bullet.tscn`) | Arcing fragmentation canister grenade that detonates with radial blast. |
| `bullet_railgun.png` | 64x64 PNG | `rifle_evolved.tres` (`Bullet.tscn`) | Piercing azure relativistic particle beam projectile. |
| `bullet_inferno.png` | 64x64 PNG | `flamethrower_evolved.tres` (`Bullet.tscn`) | Incandescent cosmic hellfire plasma vortex. |

---

## 2. Audio (`res://assets/audio/`)

All audio files are clean synthesized sound effects and atmospheric looping music.

| File Name | Format / Sample Rate | Used By | Description |
| :--- | :--- | :--- | :--- |
| `shoot.wav` | WAV (44.1 kHz, 16-bit Mono, 0.12s) | `Player.tscn` / `WeaponData` | Punchy synth laser / gunshot with rapid pitch drop and crisp transient. |
| `hit.wav` | WAV (44.1 kHz, 16-bit Mono, 0.08s) | `Player.tscn` (`HurtAudio`) / `Bullet` | Fleshy impact thud on damage. |
| `zombie_die.wav` | WAV (44.1 kHz, 16-bit Mono, 0.25s) | `Zombie.tscn` (`AudioStreamPlayer2D`) | Crunchy defeat burst and dissipation hiss when a zombie is eliminated. |
| `crate_land.wav` | WAV (44.1 kHz, 16-bit Mono, 0.40s) | `Crate.tscn` (`AudioStreamPlayer2D`) | Heavy metallic thud and pneumatic pressure release when crate lands. |
| `explode.wav` | WAV (44.1 kHz, 16-bit Mono, 0.45s) | `zombie_exploder.tres` | Punchy concussive bio-chemical detonation boom with rumbling decay. |
| `charge.wav` | WAV (44.1 kHz, 16-bit Mono, 0.32s) | `zombie_charger.tres` | High-momentum rushing dash windup and stampede swoosh. |
| `summon.wav` | WAV (44.1 kHz, 16-bit Mono, 0.38s) | `zombie_summoner.tres` | Resonant dark magic occult bell chime and minion conjuration pulse. |
| `shoot_sunburst.wav` | WAV (44.1 kHz, 16-bit Mono, 0.22s) | `pistol_evolved.tres` | Resonant solar flare energy blast with deep harmonics. |
| `shoot_plasma.wav` | WAV (44.1 kHz, 16-bit Mono, 0.10s) | `smg_evolved.tres` | Ultra-rapid crisp electric plasma pulse. |
| `shoot_doom.wav` | WAV (44.1 kHz, 16-bit Mono, 0.35s) | `shotgun_evolved.tres` | Thunderous heavy concussive flak cannon blast. |
| `shoot_flame.wav` | WAV (44.1 kHz, 16-bit Mono, 0.22s) | `flamethrower.tres` | Roaring chemical flame stream whoosh with high-frequency hiss. |
| `shoot_crossbow.wav` | WAV (44.1 kHz, 16-bit Mono, 0.18s) | `crossbow.tres` | Sharp mechanical latch release and twanging bowstring snap. |
| `shoot_grenade.wav` | WAV (44.1 kHz, 16-bit Mono, 0.28s) | `grenade_launcher.tres` | Hollow pneumatic canister launch thump. |
| `shoot_railgun.wav` | WAV (44.1 kHz, 16-bit Mono, 0.35s) | `rifle_evolved.tres` | High-voltage capacitor discharge hum and sharp laser crack. |
| `shoot_inferno.wav` | WAV (44.1 kHz, 16-bit Mono, 0.32s) | `flamethrower_evolved.tres` | Deep resonant magma inferno roar. |
| `revive.wav` | WAV (44.1 kHz, 16-bit Mono, 0.55s) | `upgrade_revive.tres` | Harmonic crystalline second chance revival chord. |
| `card_pack_open.wav` | WAV (44.1 kHz, 16-bit Mono, 0.45s) | `CardShopModal` / `card_packs.tres` | Atmospheric mystical seal opening chime and celestial energy burst. |
| `card_reveal.wav` | WAV (44.1 kHz, 16-bit Mono, 0.30s) | `CardShopModal` / `card_packs.tres` / Boss Reward | Bright magical glockenspiel card flip and rarity reveal flourish. |
| `music.ogg` | Ogg Vorbis (44.1 kHz, Mono, 8.0s seamless loop) | `Main.tscn` (`MusicPlayer`) | Dark ambient pulsing synth bassline in C minor setting the tense survival tone. |

---

## 3. UI Assets (`res://assets/ui/`)

| File Name | Dimensions / Format | Used In Scene / Node | Description |
| :--- | :--- | :--- | :--- |
| `card_bg.png` | 160x220 PNG | Legacy vertical card | Sleek dark translucent card panel with glowing cyan neon border. |
| `card_banner_bg.png` | 580x120 PNG | `UI.tscn` (Portrait Upgrade Cards) | Horizontal banner card panel for portrait mode with neon borders and icon bay. |
| `joystick_base.png` | 128x128 PNG | `UI.tscn` (`JoystickBase`) | Neon touch joystick outer ring for mobile / mouse touch controls. |
| `joystick_knob.png` | 64x64 PNG | `UI.tscn` (`JoystickKnob`) | Glowing neon touch joystick thumb knob. |
| `icon_fire_rate.png` | 48x48 PNG | `upgrade_fire_rate.tres` | Neon yellow dual lightning bolts icon for rapid fire rate. |
| `icon_damage.png` | 48x48 PNG | `upgrade_damage.tres` | Neon crimson cracked crosshair icon for hollow-point damage. |
| `icon_move_speed.png` | 48x48 PNG | `upgrade_move_speed.tres` | Neon cyan winged boot and speed trail icon for adrenaline boost. |
| `icon_torch_radius.png`| 48x48 PNG | `upgrade_torch_radius.tres` | Neon amber vintage lantern with radiating light rays for lantern radius. |
| `icon_max_hp.png` | 48x48 PNG | `upgrade_max_hp.tres` | Neon emerald medical vitality cross icon for max health & heal. |
| `icon_magnet.png` | 48x48 PNG | `meta_soul_magnet.tres` | Neon magnetic field arc icon for meta soul attraction radius. |
| `icon_evo_sunburst.png` | 48x48 PNG | `evo_pistol_torch.tres` | Radiant golden sunburst evolution card icon. |
| `icon_evo_plasma.png` | 48x48 PNG | `evo_smg_fire_rate.tres` | Neon electric twin lightning bolt evolution card icon. |
| `icon_evo_doom.png` | 48x48 PNG | `evo_shotgun_damage.tres` | Concussive doom flak explosion evolution card icon. |
| `icon_flamethrower.png` | 48x48 PNG | `flamethrower.tres` | Torch nozzle spraying orange flame tongue. |
| `icon_crossbow.png` | 48x48 PNG | `crossbow.tres` | Cyan crossed limbs mechanical crossbow. |
| `icon_grenade_launcher.png` | 48x48 PNG | `grenade_launcher.tres` | Heavy green canister grenade shell. |
| `icon_lifesteal.png` | 48x48 PNG | `upgrade_lifesteal.tres` | Crimson blood droplet pierced with vampire fangs. |
| `icon_armor.png` | 48x48 PNG | `upgrade_armor.tres` | Heavy hexagonal steel plate shield with cyan crest. |
| `icon_revive.png` | 48x48 PNG | `upgrade_revive.tres` | Golden winged phoenix halo revival sigil. |
| `icon_evo_railgun.png` | 48x48 PNG | `evo_rifle_armor.tres` | Electromagnetic accelerator crosshair with piercing rail beam. |
| `icon_evo_inferno.png` | 48x48 PNG | `evo_flamethrower_lifesteal.tres` | Cosmic purple-gold twin dragon fire vortex. |

### Collectible Card Icons (`res://assets/ui/card_icons/`)
| File Name | Dimensions / Format | Used By | Description |
| :--- | :--- | :--- | :--- |
| `damage.png` | 48x48 PNG | `card_damage.tres` | Radiant golden blade flame emblem (+Weapon Damage). |
| `fire_rate.png` | 48x48 PNG | `card_fire_rate.tres` | Triple neon yellow velocity arrows (+Fire Rate). |
| `max_hp.png` | 48x48 PNG | `card_max_hp.tres` | Emerald crystal vitality heart (+Max HP). |
| `move_speed.png` | 48x48 PNG | `card_move_speed.tres` | Cyan wind runner wing crest (+Move Speed). |
| `torch_radius.png` | 48x48 PNG | `card_torch_radius.tres` | Radiant sunburst lantern core (+Torch Radius). |
| `soul_gain.png` | 48x48 PNG | `card_soul_gain.tres` | Glowing cyan wisp reaper chalice (+Soul Harvest). |
| `magnet_radius.png` | 48x48 PNG | `card_magnet_radius.tres` | Concentric gravity pull rings (+Magnet Radius). |
| `crate_drop_chance.png`| 48x48 PNG | `card_crate_drop_chance.tres` | Antenna transmission crate signal (+Bonus Crate Chance). |
| `first_hit_shield.png` | 48x48 PNG | `card_first_hit_shield.tres` | Cyan luminous forcefield barrier shield (Absorbs Hit). |
| `boss_damage.png` | 48x48 PNG | `card_boss_damage.tres` | Spiked demon skull cleaved by energy ray (+Boss Damage). |
| `revive_once.png` | 48x48 PNG | `card_revive_once.tres` | Radiant golden ankh halo sigil (Second Chance Revive). |
| `lifesteal.png` | 48x48 PNG | `card_lifesteal.tres` | Crimson sanguine talisman with soul drain fang (+Lifesteal). |

---

## 4. Game Data Resources (`res://data/`)

Every stat is configurable through Godot Resource files (`.tres`). No gameplay numbers are hardcoded in code:

### Weapons (`res://data/weapons/`)
All weapons can level up from Level 1 to 5 with data-driven per-level increments:
- `pistol.tres`: Starting sidearm (25.0 dmg, 2.2 fire rate; +7.0 dmg/lvl, +0.5 rate/lvl).
- `smg.tres`: Rapid auto-fire (14.0 dmg, 6.5 fire rate, 8° spread; +3.5 dmg/lvl, +1.2 rate/lvl).
- `shotgun.tres`: Spread blast (18.0 dmg per pellet, 1.1 fire rate, 5 pellets; +4.0 dmg/lvl, +0.25 rate/lvl, +1 pellet/lvl).
- `rifle.tres`: High-velocity penetrator (45.0 dmg, 3.5 fire rate, 2 pierce; +12.0 dmg/lvl, +0.5 rate/lvl, +1 pierce/lvl).
- `flamethrower.tres`: Continuous short-range fiery cone (9.0 dmg/tick, 14.0/s rate, 340 speed, 0.55s lifetime, 32° cone, 999 pierce; +2.5 dmg/lvl, +2.0 rate/lvl).
- `crossbow.tres`: Heavy penetrator (95.0 dmg, 0.85/s rate, 880 speed, 5 pierce, sticks in ground 0.5s; +28.0 dmg/lvl, +0.15 rate/lvl, +1 pierce/lvl).
- `grenade_launcher.tres`: Cluster arcing bomb (70.0 dmg, 1.1/s rate, 460 speed, 125px explosion radius, 50px arc height; +20.0 dmg/lvl, +0.25 rate/lvl).

### Evolved Weapons (`res://data/weapons/`)
Unlocked when max level weapon (Lv.5) and matching upgrade conditions are met:
- `pistol_evolved.tres`: **Sunburst** (85.0 dmg, 4.5 fire rate, 99 pierce; fires piercing solar orbs with `bullet_sunburst.png` and `shoot_sunburst.wav`).
- `smg_evolved.tres`: **Hyper-Storm** (32.0 dmg, 15.0 fire rate, 2 pellets dual-stream, 1 pierce; fires neon cyan plasma bolts with `bullet_plasma.png` and `shoot_plasma.wav`).
- `shotgun_evolved.tres`: **Doom Cannon** (45.0 dmg per pellet, 2.2 fire rate, 9 pellets, 2 pierce; fires molten flak shards with `bullet_doom.png` and `shoot_doom.wav`).
- `rifle_evolved.tres`: **Valkyrie Railgun** (160.0 dmg, 4.2 fire rate, 1200 speed, 999 pierce; fires relativistic particle beam with `bullet_railgun.png` and `shoot_railgun.wav`).
- `flamethrower_evolved.tres`: **Inferno Breath** (22.0 dmg, 18.0 fire rate, 420 speed, 45° cone, 999 pierce; fires cosmic hellfire vortex with `bullet_inferno.png` and `shoot_inferno.wav`).

### Weapon Evolutions (`res://data/evolutions/`)
Data-driven evolution rules (`EvolutionData.gd`):
- `evo_pistol_torch.tres`: Pistol Lv.5 + Lantern Radiance (`upgrade_torch_radius.tres`) -> Sunburst.
- `evo_smg_fire_rate.tres`: SMG Lv.5 + Rapid Trigger (`upgrade_fire_rate.tres`) -> Hyper-Storm.
- `evo_shotgun_damage.tres`: Shotgun Lv.5 + Hollow-Point (`upgrade_damage.tres`) -> Doom Cannon.
- `evo_rifle_armor.tres`: Rifle Lv.5 + Reinforced Plating (`upgrade_armor.tres`) -> Valkyrie Railgun.
- `evo_flamethrower_lifesteal.tres`: Flamethrower Lv.5 + Vampiric Leech (`upgrade_lifesteal.tres`) -> Inferno Breath.

### Enemies (`res://data/enemies/`)
- `zombie_walker.tres`: Base zombie (35 HP, 85 speed, 15 DPS, drops 1 soul).
- `zombie_fast.tres`: Agitated runner (22 HP, 150 speed, 12 DPS, drops 2 souls).
- `zombie_tank.tres`: Armored brute (110 HP, 55 speed, 30 DPS, drops 5 souls).
- `zombie_spitter.tres`: Acid spitter (45 HP, 70 speed, stops at 250px range and fires 15 dmg projectiles, drops 3 souls).
- `zombie_exploder.tres`: Volatile suicide bomber (28 HP, 125 speed, rushes player, explodes on death or proximity after 0.5s telegraph with 130px red warning circle dealing 40 area damage, drops 2 souls).
- `zombie_charger.tres`: Armored ram (65 HP, 90 speed, pauses 0.7s to telegraph with flashing red cue, dashes in straight line at 420 px/s dealing 25 contact damage, drops 3 souls).
- `zombie_summoner.tres`: Dark occultist (50 HP, 65 speed, flees within 320px, summons 2 walkers every 6s up to max 6, drops 4 souls).
- `zombie_ghost.tres`: Ethereal wraith (32 HP, 105 speed, invisible outside torchlight, phases through other zombies with collision mask 1, drops 3 souls).
- `zombie_boss.tres`: Abomination Boss (850 HP, 60 speed, 35 touch DPS, fires 25 dmg boss orbs, top HUD boss bar, drops free airdrop crate on death and 25 souls).

### Elite Zombies (`res://data/elite.tres`)
Controls elite roll parameters and multipliers across all non-boss enemy archetypes (`EliteData.gd`):
- Elite Chance: 12% (`elite_chance = 0.12`).
- HP Multiplier: 3.0x (`hp_multiplier = 3.0`).
- Speed Multiplier: 1.1x (`speed_multiplier = 1.1`).
- Souls Multiplier: 3x drop count (`souls_multiplier = 3`).
- Crate Drop Chance: 20% guaranteed airdrop crate on death (`crate_drop_chance = 0.20`).
- Elite Visual Cue: Radiant neon magenta glow/tint (`Color(1.0, 0.2, 0.85, 1.0)`) and 1.3x scale boost.

### Playable Heroes (`res://data/heroes/`)
- `hero_luka.tres`: Luka the Lanternkeeper (120 HP, 200 speed, Pistol, passive: +40% torch radius).
- `hero_jax.tres`: Jax the Outrunner (90 HP, 250 speed, SMG, passive: +25% move speed & +15% fire rate).
- `hero_kora.tres`: Kora the Enforcer (140 HP, 185 speed, Shotgun, passive: +30% damage & heavy armor).

### Data-Driven Spawn Waves (`res://data/waves.tres`)
Controls progressive enemy appearance milestones and frequencies over the 5-minute survival curve:
- Walkers (`zombie_walker.tres`): Active at 0s (1.6s interval, weight 1.0)
- Fast Runners (`zombie_fast.tres`): Active at 30s (2.2s interval, weight 0.8)
- Spitters (`zombie_spitter.tres`): Active at 60s (3.5s interval, weight 0.6)
- Exploders (`zombie_exploder.tres`): Active at 90s (3.8s interval, weight 0.5)
- Chargers (`zombie_charger.tres`): Active at 130s (4.5s interval, weight 0.45)
- Summoners (`zombie_summoner.tres`): Active at 170s (6.5s interval, weight 0.35)
- Ghosts (`zombie_ghost.tres`): Active at 210s (4.0s interval, weight 0.4)
- Tanks (`zombie_tank.tres`): Active at 250s (6.0s interval, weight 0.3)
- Boss (`zombie_boss.tres`): Appears every 120s with full-screen boss HUD and guaranteed crate drop.

### Weapon Rarities (`res://data/rarities.tres`)
Controls drop chances and damage scaling on airdrop weapons:
- Common (White, 1.0x damage)
- Rare (Cyan/Blue, 1.35x damage, 35% chance)
- Epic (Purple/Violet, 1.75x damage, 15% chance)

### Upgrades (`res://data/upgrades/`)
- `upgrade_fire_rate.tres`: +25% Fire Rate.
- `upgrade_damage.tres`: +30% Bullet Damage.
- `upgrade_move_speed.tres`: +20% Movement Speed.
### In-Run Crate Upgrades & Passives (`res://data/upgrades/`)
- `upgrade_fire_rate.tres`: +25% Fire Rate.
- `upgrade_damage.tres`: +30% Bullet Damage.
- `upgrade_move_speed.tres`: +20% Movement Speed.
- `upgrade_torch_radius.tres`: +35% Lantern Vision Radius.
- `upgrade_max_hp.tres`: +30 Max HP & Instant Heal.

#### Leveled Passive Items (Max Level 3)
- `upgrade_magnet.tres`: Attractor Sphere (+60px soul pickup radius at Lv.1, +40px per level).
- `upgrade_lifesteal.tres`: Vampiric Leech (+2.0 HP healed per zombie kill at Lv.1, +1.5 HP per level).
- `upgrade_armor.tres`: Reinforced Plating (+15% damage reduction at Lv.1, +10% per level).
- `upgrade_revive.tres`: Phoenix Sigil (+1 one-time second chance revive at Lv.1, +1 charge per level, restores 50% HP with invulnerability flash).

### Permanent Meta-Progression Upgrades (`res://data/meta/`)
Permanent rank upgrades purchased in the Soul Forge using harvested souls:
- `meta_max_hp.tres`: Vitality (+20 Max HP per rank, base 10 souls, 1.5x price growth, max rank 5).
- `meta_move_speed.tres`: Agility (+6% Movement Speed per rank, base 15 souls, 1.5x price growth, max rank 5).
- `meta_torch_radius.tres`: Lantern Radiance (+10% Torch Radius per rank, base 12 souls, 1.5x price growth, max rank 5).
- `meta_damage.tres`: Firepower (+8% Bullet Damage per rank, base 20 souls, 1.6x price growth, max rank 5).
- `meta_soul_magnet.tres`: Soul Magnet (+35px Soul Attraction Radius per rank, base 10 souls, 1.5x price growth, max rank 5).

### Player (`res://data/player_default.tres`)
- Default HP: 100, Base Speed: 210, Starting Damage Mult: 1.0, Fire Rate Mult: 1.0, Torch Radius: 1.0, Base Magnet Radius: 120.0.

### Game Feel Tunables (`res://data/game_feel.tres`)
Centralized tuning file for all juices and juice settings (no numbers hardcoded in scripts):
- `screen_shake_strength`: Camera shake amplitude on player hit (default: 14.0 px).
- `screen_shake_duration`: Camera shake duration on hit (default: 0.25 s).
- `hit_flash_duration`: White hit flash duration on zombie (default: 0.09 s).
- `hit_flash_color`: Color modulating the zombie on hit (default: intense white `Color(3, 3, 3, 1)`).
- `death_particle_count`: Number of spark particles on zombie elimination (default: 18).
- `death_particle_lifetime`: Duration of death particle burst (default: 0.4 s).
- `death_particle_speed`: Radial expulsion velocity (default: 160.0 px/s).
- `death_particle_texture`: Swappable particle texture (`res://assets/sprites/particle_splat.png`).
- `damage_number_lifetime`: Duration floating damage numbers persist (default: 0.65 s).
- `damage_number_float_speed`: Vertical rise speed of damage numbers (default: 75.0 px/s).
- `damage_number_color`: Text color for damage numbers (default: neon amber `Color(1, 0.95, 0.35, 1)`).
- `landing_dust_count`: Dust puff particles on crate impact (default: 14).
- `landing_dust_lifetime`: Duration of landing dust ring (default: 0.45 s).
- `landing_dust_speed`: Radial expansion velocity of dust (default: 120.0 px/s).
- `landing_dust_texture`: Swappable dust texture (`res://assets/sprites/particle_dust.png`).
- `music_volume_db`: Background music playback volume (default: -6.0 dB).
- `sfx_volume_db`: Sound effects volume (default: 0.0 dB).

### Collectible Card System (`res://data/cards/`, `res://data/card_packs.tres`, `res://data/card_levels.tres`)
Data-driven collectible cards empowering the player from the start of the run:
- **Card Schema** (`CardData.gd`): `id`, `name`, `description`, `rarity` (Common/Rare/Epic), `icon`, `stat_modifiers` (Dictionary mapping stat names to bonus per level), `max_level`.
- **Card Packs** (`card_packs.tres` / `CardPackData.gd`):
  - Pack Price: 150 souls (`pack_price = 150`).
  - Cards per pack: 3 (`cards_per_pack = 3`).
  - Rarity weights: Common 65.0%, Rare 25.0%, Epic 10.0%.
  - Boss Card Drop Chance: 50% (`boss_card_drop_chance = 0.50`) on boss elimination.
  - Sounds: `card_pack_open.wav` and `card_reveal.wav`.
- **Duplicate Level Costs** (`card_levels.tres` / `CardLevelData.gd`):
  - Duplicate costs array: `[1, 2, 4, 8, 16]` duplicates required for levels 2, 3, 4, 5+.
- **The 12 Collectible Cards**:
  1. `card_damage.tres`: **Lantern Flame** (Common, Max Lv.5, +10% Weapon Damage/lvl)
  2. `card_fire_rate.tres`: **Overclock** (Common, Max Lv.5, +8% Fire Rate/lvl)
  3. `card_max_hp.tres`: **Vitality Ward** (Common, Max Lv.5, +15 Max HP/lvl)
  4. `card_move_speed.tres`: **Windrunner** (Common, Max Lv.5, +6% Move Speed/lvl)
  5. `card_torch_radius.tres`: **Beacon Glow** (Rare, Max Lv.5, +12% Torch Radius/lvl)
  6. `card_soul_gain.tres`: **Soul Harvester** (Rare, Max Lv.5, +15% Souls Earned/lvl)
  7. `card_magnet_radius.tres`: **Vortex Core** (Rare, Max Lv.5, +25px Magnet Radius/lvl)
  8. `card_crate_drop_chance.tres`: **Airdrop Radio** (Rare, Max Lv.5, +3% Crate Drop Chance on kill/lvl)
  9. `card_first_hit_shield.tres`: **Aegis Barrier** (Epic, Max Lv.5, Absorbs first hit damage; recharges every 45s - (lvl-1)*6s)
  10. `card_boss_damage.tres`: **Boss Slayer** (Epic, Max Lv.5, +15% Damage dealt to Bosses/lvl)
  11. `card_revive_once.tres`: **Phoenix Halo** (Epic, Max Lv.5, +1 Free Second-Chance Revive with 50% HP restoration)
  12. `card_lifesteal.tres`: **Blood Rite** (Epic, Max Lv.5, +1.0 HP restored per enemy kill/lvl)

### Playable Web Demo — Run Rules, Safety & Stats (`res://data/run.tres`, `res://data/curses/`)
- **Run Rules & Cap** (`run.tres` / `RunData.gd`):
  - `dawn_time = 300.0` (Dawn arrives at 5:00 / 300 seconds).
  - `dawn_souls_bonus = 50` (+50 bonus souls awarded on sunrise).
  - `dawn_title = "DAWN BREAKS"`
  - `dawn_subtitle = "You survived 5 minutes until sunrise!"`
  - `max_enemies = 150` (Caps live enemies simultaneously present in the arena for browser web performance and safety).
  - Win modal with "CONTINUE RUN" (endless survival mode) and "MAIN MENU".
- **Web Safety & Autoplay Compliance**:
  - `MainMenu.tscn` audio streams do not autoplay on scene load; background music initializes smoothly upon the player's first mouse click, touch, or key input.
  - All game saves strictly write to `user://` (`user://save.cfg` and `user://settings.cfg`), ensuring sandbox compliance for browser/Web exports.
  - Debug panel is strictly bounded to debug builds (`OS.is_debug_build()`), completely stripped and freed in production.
- **Run History & Log (Last 50 Runs)**:
  - Each finished run is logged safely through `SaveManager.log_run(...)` into `user://save.cfg` under `[history] runs`.
  - Captures run `duration` (seconds), `death_cause` (enemy type, projectile, or "Dawn (Survived)"), `hero`, `weapon` with level, `upgrades` chosen, and `souls` harvested.
  - Automatically bounded to the last 50 runs with corrupt-save fallbacks.
- **Main Menu Stats Modal**:
  - Accessible via "STATS" button on the Main Menu.
  - Displays Career Best Survival Time (`MM:SS`), Total Runs Completed, Average Run Length (`MM:SS`), and Most Picked Upgrade across all runs.
- **Enhanced Game Over Screen**:
  - Displays survived time, kills, souls earned, what killed you (`KILLED BY: [cause]`), final arsenal, and prominent `★ NEW BEST SURVIVAL TIME! ★` / `★ NEW BEST KILL RECORD! ★` badges when records are surpassed.
- **Daily Curse System** (`CurseData.gd` & `res://data/curses/`):
  - Deterministically selected from local system calendar date (`abs(year*10000 + month*100 + day) % curses.size()`).
  - Shown as a dedicated card on the Main Menu and an animated announcement banner at run start.
  - 5 Data-Driven Curses:
    1. `curse_eclipse.tres`: **Solar Eclipse** (-35% Torch Radius, but +100% Souls Harvested).
    2. `curse_bloodmoon.tres`: **Blood Moon** (+25% Zombie Movement Speed, but Airdrops arrive 40% faster).
    3. `curse_ironclad.tres`: **Ironclad Horde** (+35% Zombie Health, but Survivor deals +30% Bullet Damage).
    4. `curse_withering.tres`: **Withering Fog** (-25% Survivor Max HP, but +25% Movement Speed).
    5. `curse_frenzy.tres`: **Frenzy Swarm** (+30% Zombie Attack Damage, but +50% Souls and faster Airdrops).

### Configuration & Persistence Files
Persistent settings and save records are managed via `SaveManager.gd` with safe fallbacks:
- `user://settings.cfg`: Stores persistent `music_linear` and `sfx_linear` volumes (0.0 to 1.0).
- `user://save.cfg`: Stores high score records `best_time` (seconds), `best_kills` (count), `runs_completed` (count), `boss_kills` (count), persistent `total_souls` bank, meta upgrade ranks in `[meta_upgrades]`, card collection `[cards]` (level and duplicates), equipped deck in `[deck] equipped = [...]`, and run history in `[history] runs` (last 50 runs with duration, death cause, hero, weapon, upgrades, souls).
- `res://default_bus_layout.tres`: Master, Music, and SFX audio bus configuration.
- `res://MainMenu.tscn` / `res://MainMenu.gd`: Main menu scene (Play, Shop / Upgrades, Card Shop & Vault, Settings, Career Stats modal, Quit, Best Records, Soul Bank display, and Daily Curse announcement).
- `res://Soul.tscn` / `res://Soul.gd`: Glowing soul pickup attracted to player inside magnet radius.
- `res://data/debug_config.tres` (`DebugConfigData.gd`): Centralized tuning for debug overlay actions (+60s time increment, +1000 souls amount, level 5 target, spawn distances).
- `res://DebugPanel.tscn` / `res://DebugPanel.gd`: Debug overlay (toggled with F1 or [DBG] button), active exclusively in debug builds (`OS.is_debug_build()`) and automatically stripped/freed in release builds.
