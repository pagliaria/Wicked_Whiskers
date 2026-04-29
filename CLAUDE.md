# CLAUDE.md — Wicked Whiskers: Lantern Wars

## Project Overview
Halloween co-op pumpkin carving game. Players grow pumpkins, bring them to colour-coded cats to carve an expression (default→happy, red→angry, green→surprised), then deliver them to customers before their order expires. 3 nights of increasing difficulty. Built in **Godot 4.4.1**, viewport **1920×1080**, no resizing.

---

## Architecture

### Autoloads (Global Singletons)
| Name | File | Purpose |
|---|---|---|
| `Enums` | `scripts/Global.gd` | All enums, global state (night, coins, score, difficulty), difficulty math helpers |
| `OrderManager` | `scripts/order_manager.gd` | Tracks active orders, order display nodes, highlights, urgency sorting |
| `MultiplayerManager` | `scripts/multiplayer_manager.gd` | Player registry (id, name, char) shared across peers |
| `ControlsGrid` | `scripts/controls_grid.gd` | Builds the 3-column controls table used in pause menu and how-to-play |

### Key Scenes
| Scene | Purpose |
|---|---|
| `main_menu.tscn` | Title screen — single player, multiplayer, how to play, character select |
| `game.tscn` | Main gameplay — `Node2D` root, spawns players/cats/patches via script |
| `pause_menu.tscn` | Pause overlay — must be added via `CanvasLayer` (game root is Node2D, not Control) |
| `night_intro.tscn` | Pre-night splash screen with fade in/out animation |
| `difficulty_select.tscn` | Popup shown before starting — sets `Enums.difficulty` |
| `multiplayer_menu.tscn` | Host/join popup, separated from main menu |
| `how_to_play.tscn` | Scrollable reference dialog |
| `order.tscn` | Individual order card — has `SelectedIndicator` label for controller highlight |

### Popup Pattern
All popups (pause, how-to-play, difficulty, multiplayer, night intro) follow the same pattern:
- Full-screen `Control` with dark `ColorRect` overlay
- Centred `Panel` with pixel-art font and `buttons.tres` theme
- `queue_free()` on close; pause menu also frees its parent `CanvasLayer`
- `grab_focus()` on primary button in `_ready()` for controller support

---

## Style Guide

### UI
- **Font:** `assets/fonts/PixelOperator8-Bold.ttf` — use everywhere
- **Buttons:** always use `themes/buttons.tres` — never raw StyleBox overrides on buttons
- **Input theme:** `themes/input.tres` for `LineEdit`
- **Title colour:** `Color(1, 0.85, 0.2, 1)` — gold/yellow
- **Body colour:** `Color(0.92, 0.92, 0.92, 1)` — off-white
- **Overlay colour:** `Color(0, 0, 0, 0.75)` — semi-transparent black
- Buttons should never stretch full-width — wrap in `CenterContainer` with `custom_minimum_size`

### GDScript
- Use `@onready` for all node references
- Use `Enums.X` (not `Global.X`) — the autoload is named `Enums`
- Game actions use `_unhandled_input`, not `_input` — UI consumes events first
- RPCs follow the pattern: `@rpc("any_peer", "call_local")` for actions that all peers run
- Score/coins are global state on `Enums` — update only on the multiplayer authority

### Controller Support
- `ui_accept` (A button) confirms focused buttons — Godot handles this natively
- Always call `grab_focus()` in `_ready()` on the default button of any popup
- Always set `focus_neighbor_*` and `focus_next/previous` on all interactive nodes
- Game actions: A=interact, B=submit order, LB/RB=cycle orders, Start=pause

---

## Difficulty System
Defined in `Enums` — modifiers applied on top of per-night base values:

| | Easy | Normal | Hard |
|---|---|---|---|
| Order timeout mod | +5s | 0 | −5s |
| Spawn interval mod | +3s | 0 | −2s |

Call `Enums.get_order_timeout(night, player_count)` and `Enums.get_spawn_interval(night, player_count)` — never hardcode these values in game.gd.

---

## Scoring
- Awarded in `customer.gd` on confirmed delivery (pumpkin hits correct customer with correct expression + hat)
- Formula: `int(100 × time_ratio × dist_bonus)`
  - `time_ratio` = time remaining / ORDER_TIMEOUT_SEC (0.0–1.0)
  - `dist_bonus` = 1.0–2.0 based on throw distance (clamped at 400px max)
- Throw data captured in `player.gd` at submit time, consumed once via `consume_throw_score_data()`

---

## Things to Avoid
- **Don't add Control nodes directly to the game scene root** — it's a `Node2D`. Use a `CanvasLayer` wrapper
- **Don't add popups to `get_tree().root`** — use `get_tree().current_scene` or a `CanvasLayer`
- **Don't hardcode spawn rates or timeouts** — use the difficulty helper functions
- **Don't touch main_menu.tscn button positions/offsets** — layout is managed in the editor
- **Don't use `_input` for gameplay actions** — use `_unhandled_input` so UI gets priority
