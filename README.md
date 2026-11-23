# Last Lantern

A top-down, survivors-style horde shooter for mobile, built in **Godot 4.7** with GDScript. Hold back waves of zombies with your lantern until dawn breaks after 5 minutes.

## Gameplay

- **Move**, and your hero **aims and shoots automatically** at the nearest zombie.
- **Survive until dawn** (5 minutes) to win the run. A **boss** arrives every couple of minutes.
- **Enemies:** walkers, fast runners, tanks, spitters (ranged), exploders, chargers, summoners, ghosts and bosses, each defined as a data resource.
- **Collect souls** dropped by zombies and **airdrop crates**, then pick **upgrades**, **weapon evolutions** and **card packs** to build your run.
- **3 heroes** (Luka, Jax, Kora), **meta upgrades** between runs, a **daily curse** modifier, and a saved best time.

## Controls

| Platform | Move | Shoot |
| --- | --- | --- |
| Mobile | On-screen joystick | Automatic |
| Desktop | WASD or arrow keys | Automatic |

## Project structure

- **Root:** the main scenes and their scripts (`Main`, `Player`, `Zombie`, `Bullet`, `Crate`, `Soul`, `UI`, `MainMenu`, `DebugPanel`).
- **`data/`:** data-driven design with custom `Resource` classes (`EnemyData`, `WeaponData`, `WaveData`, `UpgradeData`, `HeroData`, `CardData`, `CurseData`…) and their `.tres` files, plus `SaveManager.gd`. Balancing a weapon or wave means editing a `.tres`, not code.
- **`assets/`:** sprites, UI and audio. See [README_ASSETS.md](README_ASSETS.md) for every file and how to replace it.

## Technical notes

- Auto-aim re-scans for the nearest zombie 10 times a second, not every physics frame, to keep large hordes cheap.
- Waves are rule-based (`WaveData` + `WaveRule`), so which enemies spawn, and when, is tuned in data.
- Portrait 720×1280 layout with a `SafeArea` script for phone notches.

## Run it

1. Install **Godot 4.7**.
2. Open `project.godot` and press **Play** (starts at `MainMenu.tscn`).
3. Android export presets are in `export_presets.cfg`.
