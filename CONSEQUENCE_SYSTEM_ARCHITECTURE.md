# Consequence System Architecture

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          GAME RUNNING                           │
│                    (Normal Gameplay)                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Player uses weapon/takes damage
                              │
                              ▼
                    ┌────────────────────┐
                    │  Overheat Increases │
                    │  (via cpu system)   │
                    └────────────────────┘
                              │
                              │ meter < 100%
                              │
                              ▼
                    ┌────────────────────┐
                    │  Overheat Bar      │
                    │  Updates (CPUHUD)  │
                    │  Color: Yellow→Red │
                    └────────────────────┘
                              │
                              │ meter >= 100%
                              │
                              ▼
         ┌────────────────────────────────────────┐
         │   Player.overheat_critical.emit()      │
         │   (Signal fired at 100%)               │
         └────────────────────────────────────────┘
                              │
                              ▼
         ┌────────────────────────────────────────┐
         │  ConsequenceEngine._on_overheat_critical│
         │  1. Set handling_consequence = true    │
         │  2. Pause game (get_tree().paused=true)│
         │  3. Call show_consequence_popup()      │
         └────────────────────────────────────────┘
                              │
                              ▼
         ┌────────────────────────────────────────┐
         │  show_consequence_popup()              │
         │  1. Instantiate from scene             │
         │  2. Add to cpu_hud (CanvasLayer)       │
         │  3. Connect consequence_selected signal│
         └────────────────────────────────────────┘
                              │
         ┌────────────────────┴──────────────────┐
         │      POPUP NOW VISIBLE & ACTIVE       │
         │  (can receive input during pause)     │
         │                                       │
         │  ┌─────────────────────────────────┐ │
         │  │ SYSTEM CRITICAL: CONSEQUENCE... │ │
         │  ├─────────────────────────────────┤ │
         │  │                                 │ │
         │  │ ┌──────────────┐ ┌───────────┐ │ │
         │  │ │ Movement     │ │ Blink     │ │ │
         │  │ │ Lockdown     │ │ Drive     │ │ │
         │  │ │              │ │ Reset     │ │ │
         │  │ └──────────────┘ └───────────┘ │ │
         │  └─────────────────────────────────┘ │
         └──────────┬─────────────────┬─────────┘
                    │                 │
        Click/Press │                 │ Click/Press
                    │                 │
        ┌───────────▼──┐     ┌────────▼────────┐
        │  Movement    │     │   Blink Reset   │
        │  Lockdown    │     │                 │
        │  Selected    │     │   Selected      │
        └───────────┬──┘     └────────┬────────┘
                    │                 │
                    └────────┬────────┘
                             │
                             ▼
         ┌────────────────────────────────────────┐
         │ _on_consequence_selected(consequence)  │
         │ 1. Call player.apply_*()               │
         │ 2. Reset overheat = 0.0                │
         │ 3. Emit overheat_updated(0.0)          │
         │ 4. Unpause game                        │
         │ 5. Set handling_consequence = false    │
         │ 6. Popup freed                         │
         └────────────────────────────────────────┘
                              │
                              ▼
         ┌────────────────────────────────────────┐
         │        GAME UNPAUSED & RUNNING         │
         │   (Consequence effect applied)         │
         │    - Movement locked for X seconds, OR │
         │    - Blink charge reset to 0           │
         └────────────────────────────────────────┘
                              │
                              │ Continue playing
                              │ (overheat can build again)
                              │
                              ▼
                    ┌────────────────────┐
                    │  RETURN TO NORMAL   │
                    │  GAMEPLAY FLOW      │
                    └────────────────────┘
```

---

## Node Hierarchy - BEFORE Fix (Broken)

```
World (Node2D)
│
├── Player (CharacterBody2D)
│   └── ... (player components)
│
├── Level (Node2D)
│   └── ... (level components)
│
├── CPUHUD (CanvasLayer) ◄── Where it should go
│   ├── ResourcePanel
│   ├── ControlsPanel
│   ├── OptionsPanel
│   └── OverHeatPanel
│
├── StatusUI (CanvasLayer)
│   └── ... (status labels)
│
├── HallucinationUI (CanvasLayer)
│   └── ... (hallucination effects)
│
├── ConsequenceEngine (Node)
│   └── ... (consequence logic)
│
└── ConsequencePopup (Control) ◄── WRONG LOCATION!
    ├── Dark Overlay (Panel)
    ├── Popup Container (VBoxContainer)
    │   ├── Title (Label)
    │   ├── Description (Label)
    │   └── Buttons (HBoxContainer)
    │       ├── Movement Button
    │       └── Blink Button
```

**Problem**: Popup as sibling of CPUHUD, not child of canvas layer
- Z-index issues (may be behind game world)
- Input handling problems
- Not part of UI layer hierarchy

---

## Node Hierarchy - AFTER Fix (Correct)

```
World (Node2D)
│
├── Player (CharacterBody2D)
│   └── ... (player components)
│
├── Level (Node2D)
│   └── ... (level components)
│
├── CPUHUD (CanvasLayer) ◄── Canvas Layer for UI
│   ├── ResourcePanel
│   ├── ControlsPanel
│   ├── OptionsPanel
│   ├── OverHeatPanel
│   │
│   └── ConsequencePopup (Control) ✅ CORRECT LOCATION!
│       ├── Dark Overlay (Panel)
│       ├── Popup Container (VBoxContainer)
│       │   ├── Title (Label)
│       │   ├── Description (Label)
│       │   └── Buttons (HBoxContainer)
│       │       ├── Movement Button
│       │       └── Blink Button
│
├── StatusUI (CanvasLayer)
│   └── ... (status labels)
│
├── HallucinationUI (CanvasLayer)
│   └── ... (hallucination effects)
│
└── ConsequenceEngine (Node)
    └── ... (consequence logic)
```

**Solution**: Popup as child of CPUHUD (CanvasLayer)
- ✓ Correct Z-index (rendered on top)
- ✓ Part of UI layer system
- ✓ Proper input handling
- ✓ Inherits canvas layer properties

---

## Signal Flow Architecture

```
┌──────────────────────────────────────────────────┐
│                    PLAYER                        │
│  (res://player/player.gd)                        │
│                                                  │
│  signal overheat_critical  ◄── NEW in Godot 4   │
│  signal overheat_updated                        │
│  signal cpu_updated                             │
│  signal player_damaged                          │
│  signal hallucination_triggered                 │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ func _physics_process():                 │  │
│  │   overheat += delta * overheat_rate      │  │
│  │   if overheat >= 100:                    │  │
│  │     overheat_critical.emit() ◄── FIRES  │  │
│  │     overheat_consequence_triggered = true│  │
│  └──────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
                        │
                        │ Signal: overheat_critical
                        │
                        ▼
┌──────────────────────────────────────────────────┐
│            CONSEQUENCE ENGINE                    │
│  (res://ui/consequence_engine.gd)               │
│                                                  │
│  Signal connection (in _ready):                 │
│  player.overheat_critical.connect(              │
│    _on_overheat_critical)                      │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ func _on_overheat_critical():            │  │
│  │   get_tree().paused = true               │  │
│  │   show_consequence_popup()               │  │
│  └──────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ func show_consequence_popup():           │  │
│  │   popup = scene.instantiate()            │  │
│  │   cpu_hud.add_child(popup) ◄── KEY FIX  │  │
│  │   popup.consequence_selected.connect(    │  │
│  │     _on_consequence_selected)            │  │
│  └──────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
                        │
                        │ Creates & adds to tree
                        │
                        ▼
┌──────────────────────────────────────────────────┐
│            CONSEQUENCE POPUP                     │
│  (res://ui/consequence_popup.gd)                │
│                                                  │
│  Properties:                                    │
│  - process_mode = PROCESS_MODE_ALWAYS           │
│  - mouse_filter = MOUSE_FILTER_STOP ◄── KEY FIX│
│  - focus_mode = FOCUS_ALL ◄── KEY FIX           │
│                                                  │
│  Signal connection (in _ready):                 │
│  movement_button.pressed.connect(               │
│    _on_movement_pressed)                       │
│  blink_button.pressed.connect(                  │
│    _on_blink_pressed)                          │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ func _on_movement_pressed():             │  │
│  │   consequence_selected.emit(             │  │
│  │     "movement_lockdown")                 │  │
│  │   queue_free()                           │  │
│  └──────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
                        │
                        │ Signal: consequence_selected
                        │
                        ▼
┌──────────────────────────────────────────────────┐
│            CONSEQUENCE ENGINE                    │
│  (continued)                                     │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ func _on_consequence_selected(c: String):│  │
│  │   match c:                               │  │
│  │     "movement_lockdown":                 │  │
│  │       player.apply_movement_lockdown()   │  │
│  │     "blink_reset":                       │  │
│  │       player.apply_blink_reset()         │  │
│  │   player.overheat = 0.0                  │  │
│  │   player.overheat_updated.emit(0.0)      │  │
│  │   get_tree().paused = false              │  │
│  └──────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
                        │
                        │ Signals: overheat_updated
                        │ Pause: unpaused
                        │
                        ▼
┌──────────────────────────────────────────────────┐
│                   CPU HUD                        │
│  (res://ui/cpu_hud.gd)                          │
│                                                  │
│  Signal connection (in _ready):                 │
│  player.overheat_updated.connect(               │
│    _on_overheat_updated)                       │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ func _on_overheat_updated(val: float):   │  │
│  │   overheat_bar.value = val ◄── 0.0       │  │
│  │   overheat_bar.color = lerp(             │  │
│  │     YELLOW, RED, val/100) ◄── Back to Y  │  │
│  └──────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

---

## Data Flow - Overheat to Consequence

```
Player Action (fire weapon)
    │
    ├─ cpu_usage -= weapon_cost
    ├─ If cpu < 30: weapon_charge increments
    ├─ If cpu >= 90: overheat_rate *= 1.2 (accelerates)
    │
    ▼
overheat += delta * overheat_rate
    │
    ├─ Updates overheat value
    │
    ▼
overheat_updated.emit(overheat)
    │
    ├─► CPUHUD receives signal
    │   └─ Updates visual meter (yellow → red)
    │
    ├─► [Check gate] if overheat >= 100 AND not overheat_consequence_triggered
    │
    ▼ YES
overheat_critical.emit()
    │
    ├─► ConsequenceEngine receives signal
    │   └─ Pauses game
    │   └─ Shows popup
    │
    ▼
Player chooses consequence
    │
    ├─ Movement Lockdown
    │  └─ Freezes movement for 3 seconds
    │
    └─ Blink Drive Reset
       └─ Resets blink charge to 0
    │
    ▼
overheat = 0.0
overheat_updated.emit(0.0)
    │
    ├─► CPUHUD receives signal
    │   └─ Resets meter to yellow/0%
    │
    ▼
Game unpaused
    │
    └─► Resume normal gameplay
        (overheat can build again after cooldown)
```

---

## Process Mode Impact (Godot 4.1+)

```
                 GAME PAUSED (get_tree().paused = true)
                          │
                ┌─────────┼─────────┐
                │         │         │
                ▼         ▼         ▼
        INHERIT  ALWAYS   WHEN_PAUSED
        (default)(Fixed)  (Fixed)
        │         │       │
        ├─ ✗ Physics   ├─ ✓ Physics   ├─ ✓ Physics
        ├─ ✗ Input     ├─ ✓ Input     ├─ ✗ Input
        ├─ ✗ Render    ├─ ✓ Render    ├─ ✓ Render
        └─ ✗ _process └─ ✓ _process  └─ ✗ _process

        CPUHUD.ALWAYS          POPUP.ALWAYS
        ├─ Renders          ├─ Renders UI
        ├─ Shows bars       ├─ Displays popup
        └─ Updates on       └─ Accepts input
          signal input        (with mouse_filter)
```

For ConsequencePopup:
- ✓ Must render during pause → PROCESS_MODE_ALWAYS
- ✓ Must accept input during pause → MOUSE_FILTER_STOP
- ✓ Button interaction → FOCUS_ALL

---

## Group-Based Discovery (Godot 4.0+)

```
Scene Loading (_ready methods execute)
        │
        ├─► CPU HUD._ready()
        │   └─ add_to_group("cpuhud") ◄── KEY FIX
        │
        ├─► ConsequenceEngine._ready()
        │   └─ get_nodes_in_group("cpuhud") ◄── KEY FIX
        │      ├─ Returns: [CPUHUD]
        │      └─ cpu_hud = result[0]
        │
        └─ Service discovery complete!

Benefits:
✓ Loose coupling (engine doesn't know HUD class)
✓ Fallback search (tries multiple methods)
✓ Runtime flexibility (can add/remove dynamically)
✓ Debugging (can query group at any time)
```

---

## Input Handling During Pause (Godot 4.0+)

```
User Input Event (Mouse Click)
        │
        ├─ Game paused (get_tree().paused = true)
        │
        ├─ Event travels down tree from root
        │
        └─► ConsequencePopup (Control)
            │
            ├─ Check: process_mode == PROCESS_MODE_ALWAYS?
            │   └─ ✓ Yes, continues processing
            │
            ├─ Check: mouse_filter == MOUSE_FILTER_STOP?
            │   └─ ✓ Yes, accepts input
            │
            └─► Movement Button (Button)
                │
                ├─ Check: focused or hovered?
                │   └─ ✓ Yes (focus_mode = FOCUS_ALL)
                │
                ├─ Emit: pressed signal
                │
                └─► _on_movement_pressed()
                    └─► consequence_selected.emit()

If mouse_filter != MOUSE_FILTER_STOP:
✗ Input passes through to objects below
✗ Buttons appear unresponsive
✗ Game still paused, player confused
```

---

## Summary Table

| Component | Fix | Impact |
|-----------|-----|--------|
| Scene File | Created `consequence_popup.tscn` | Proper UI management |
| Popup Parent | Changed to `cpu_hud.add_child()` | Correct rendering order |
| Process Mode | PROCESS_MODE_ALWAYS | Renders during pause |
| Mouse Filter | MOUSE_FILTER_STOP | Accepts input during pause |
| Focus Mode | FOCUS_ALL | Keyboard/gamepad support |
| Discovery | Group `"cpuhud"` | Engine finds HUD |
| Instantiation | Scene `.instantiate()` | Proper object creation |
| Logging | Comprehensive debug prints | Easy troubleshooting |

All 8 elements work together to fix the system.
