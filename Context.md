# CLAUDE.md — Wicked Whiskers: Lantern Wars

## Project Overview
Halloween co-op pumpkin carving game. Players grow pumpkins, bring them to colour-coded cats to carve an expression (default→happy, red→angry, green→surprised), then deliver them to customers before their order expires. 3 nights of increasing difficulty. Built in **Godot 4.4.1**, viewport **1920×1080**, no resizing.

---

## Architecture

### Autoloads (Global Singletons)
| Name | File | Purpose |
|---|---|---|
| `Enums` | `scripts/Global.gd` | All enums, global state (night, coins, score, difficulty, per-night stats), difficulty math helpers |
| `OrderManager` | `scripts/order_manager.gd` | Tracks active orders, order display nodes, highlights, urgency sorting |
| `MultiplayerManager` | `scripts/multiplayer_manager.gd` | Player registry (id, name, char) shared across peers |
| `ControlsGrid` | `scripts/controls_grid.gd` | Builds the 3-column controls table used in pause menu and how-to-play |

### Key Scenes
| Scene | Purpose |
|---|---|
| `main_menu.tscn` | Title screen — single player, multiplayer, how to play, character select |
| `game.tscn` | Main gameplay — `Node2D` root, spawns players/cats/patches via script |
| `pause_menu.tscn` | Pause overlay — must be added via `CanvasLayer` (game root is Node2D, not Control) |
| `night_intro.tscn` | Two-phase screen: stats recap (nights 2+) then pre-night intro. Fade in/out animation. |
| `difficulty_select.tscn` | Popup shown before starting — sets `Enums.difficulty` |
| `multiplayer_menu.tscn` | Host/join popup, separated from main menu |
| `how_to_play.tscn` | Scrollable reference dialog |
| `win_screen.tscn` | End-game win screen — shows final stats, Play Again / Main Menu buttons |
| `order.tscn` | Individual order card — has `SelectedIndicator` label for controller highlight, `patience_icon` TextureRect for customer mood |

### Popup Pattern
All popups (pause, how-to-play, difficulty, multiplayer, night intro) follow the same pattern:
- Full-screen `Control` with dark `ColorRect` overlay
- Centred `Panel` with pixel-art font and `buttons.tres` theme
- `queue_free()` on close; pause menu also frees its parent `CanvasLayer`
- `grab_focus()` on primary button in `_ready()` for controller support

---

## Style Guide

### UI
- **Font:** `assets/fonts/PixelOperator8-Bold.ttf` — use everywhere, including inline Label overrides via `theme_override_fonts/font`
- **Buttons:** always use `themes/buttons.tres` — never raw StyleBox overrides on buttons
- **Input theme:** `themes/input.tres` for `LineEdit`
- **Title colour:** `Color(1, 0.85, 0.2, 1)` — gold/yellow
- **Body colour:** `Color(0.92, 0.92, 0.92, 1)` — off-white
- **Overlay colour:** `Color(0, 0, 0, 0.75)` — semi-transparent black
- **Success colour:** `Color(0.4, 0.9, 0.4, 1)` — green (used for completed orders)
- **Failure colour:** `Color(0.9, 0.35, 0.35, 1)` — red (used for failed orders / wrong feedback)
- **Warning colour:** `Color(1, 0.1, 0.1, 1)` — bright red (urgent pulse)
- Buttons should never stretch full-width — wrap in `CenterContainer` with `custom_minimum_size`
- Font UID for scene files: `uid://b8h3xbkd7ubfc` path `res://assets/fonts/PixelOperator8-Bold.ttf`

### GDScript
- Use `@onready` for all node references
- Use `Enums.X` (not `Global.X`) — the autoload is named `Enums`
- Game actions use `_unhandled_input`, not `_input` — UI consumes events first
- RPCs follow the pattern: `@rpc("any_peer", "call_local")` for actions that all peers run
- Score/coins are global state on `Enums` — update only on the multiplayer authority
- Use `_notification(NOTIFICATION_PAUSED/UNPAUSED)` to track paused wall-clock time — never rely on `Time.get_unix_time_from_system()` alone for game timers

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

## Per-Night Stats (`Enums` / `Global.gd`)
Tracked each night, reset at the start of every new night via `Enums.reset_night_stats()` (called in `game.gd` → `new_night()`). `reset_night_stats()` also accumulates into the cumulative totals before zeroing.

| Variable | Incremented in | When |
|---|---|---|
| `orders_completed` | `customer.gd` | Correct delivery confirmed |
| `orders_failed` | `customer.gd` | `wrong_order` set on remove timer timeout |
| `coins_earned_this_night` | `customer.gd` | Coins spawned on correct delivery |
| `score_earned_this_night` | `customer.gd` | Score awarded on correct delivery |
| `total_orders_completed` | `reset_night_stats()` + `day_end()` | Cumulative across all nights |
| `total_orders_failed` | `reset_night_stats()` + `day_end()` | Cumulative across all nights |

Note: Night 3 never calls `reset_night_stats()` (game ends). `day_end()` manually accumulates Night 3 stats into the totals before showing the win screen.

---

## Night Intro / Stats Screen (`night_intro.tscn`)
Two-phase screen controlled by `night_intro.gd`. Shown between nights and before Night 1.

**Flow:**
- Night 1: skips stats, shows `IntroPanel` directly (no previous night to recap)
- Night 2+: shows `StatsPanel` first → player presses "NEXT NIGHT" → `IntroPanel` swaps in → player presses "BEGIN NIGHT" → `intro_finished` signal emits → game starts

**Node structure:**
- `StatsPanel` — recap panel with `GridContainer` (2-col key/value layout)
- `IntroPanel` — original night title, subtitle, tip, begin button
- Both are children of the root `Control`; only one visible at a time
- `setup(night_num)` must be called by `game.gd` before the scene is shown
- `intro_finished` signal is the only handshake back to `game.gd` — don't add more

**Pause safety:** The tree is paused while `night_intro` is shown. `night_start_time` is set in `new_night()` which runs *after* the intro finishes, so intro pause time is never counted against the night timer.

---

## Pause Timer Safety (`game.gd`)
The night progress bar uses wall-clock time (`Time.get_unix_time_from_system()`), which keeps ticking while paused. To compensate:
- `_paused_at` records wall time when `NOTIFICATION_PAUSED` fires
- `_total_paused_duration` accumulates each pause gap on `NOTIFICATION_UNPAUSED`
- Progress formula: `elapsed = (Time.get_unix_time_from_system() - night_start_time) - _total_paused_duration`
- Both vars reset in `new_night()` — do not reset them elsewhere

---

## Order Urgency & Auto-Select (`order_manager.gd`, `player.gd`)
- `get_most_urgent_order_number()` returns the order with least time remaining
- `get_most_urgent_order_number_excluding(num)` — same but skips `num`; use this after submitting an order because the submitted order is still in `OrderManager.orders` until the pumpkin physically hits the customer
- After a successful throw, `player.gd` calls `get_most_urgent_order_number_excluding(submitted_num)` to auto-select the next order

---

## Customer Feedback (`customer.gd`, `customer.tscn`)
Two inline Label nodes on each customer (both use `PixelOperator8-Bold.ttf`, start hidden, `z_index = 10`):

| Node | Text | Trigger | Behaviour |
|---|---|---|---|
| `wrong_label` | `WRONG!` | Wrong order delivered | Shakes left/right 6×, then fades out via Tween |
| `warn_indicator` | `!!!` | Order enters warning threshold (75% elapsed) | Visible while urgent; colour pulses gold→orange via sine wave in `_process` |

- `set_urgent(active: bool)` on customer shows/hides `warn_indicator` and resets pulse timer
- Called from `order_display.gd` via `_set_customer_warning()` when the order card crosses the warning threshold
- Must also call `set_urgent(false)` on correct delivery and on hell_dog kill — already done

---

## Order Card Warning Pulse (`order_display.gd`)
When order progress ≥ 75%:
- Panel background lerps to `COLOR_PANEL_WARN = Color(0.45, 0.08, 0.08, 1.0)` via sine wave
- Four StyleBox variants kept in sync: `_normal_style`, `_selected_style`, `_warning_style`, `_warning_selected_style`
- `set_selected()` must always check `_pulsing` to pick the right stylebox — never unconditionally apply `_selected_style`
- `_stop_pulse()` is the single cleanup path; also calls `_set_customer_warning(false)`

## Customer Patience Icon (`order_display.gd`, `order.tscn`)
Progress bar replaced with a `patience_icon` TextureRect that swaps through 4 emotion icons from `assets/emotion_icons/`:

| Progress elapsed | Icon |
|---|---|
| 0–25% | `happy.png` |
| 25–50% | `smile.png` |
| 50–75% | `sad.png` |
| 75–100% | `angry.png` |

- Icon only swaps on threshold change (`_last_emotion` guard) — no per-frame texture churn
- At 75%+ the panel pulse also kicks in, so angry face + red pulse happen together
- All 4 textures preloaded as constants in `order_display.gd`

---

## Things to Avoid
- **Don't add Control nodes directly to the game scene root** — it's a `Node2D`. Use a `CanvasLayer` wrapper
- **Don't add popups to `get_tree().root`** — use `get_tree().current_scene` or a `CanvasLayer`
- **Don't hardcode spawn rates or timeouts** — use the difficulty helper functions
- **Don't touch main_menu.tscn button positions/offsets** — layout is managed in the editor
- **Don't use `_input` for gameplay actions** — use `_unhandled_input` so UI gets priority
- **Don't use `Time.get_unix_time_from_system()` alone for in-game timers** — always subtract `_total_paused_duration`
- **Don't call `get_most_urgent_order_number()` immediately after submitting** — the submitted order is still in the dict; use the `_excluding` variant
- **Don't unconditionally apply `_selected_style` in `set_selected()`** — check `_pulsing` first or the warning pulse will be wiped
- **Don't forget `reset_night_stats()` when adding new per-night tracking** — it's called in `new_night()` in `game.gd`; also manually accumulate Night 3 stats in `day_end()` for any cumulative totals
