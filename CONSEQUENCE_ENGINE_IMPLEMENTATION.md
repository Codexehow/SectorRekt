# Consequence Engine - Complete Implementation Guide

## 🎯 Feature Summary

The **Consequence Engine** is a major gameplay feature that activates when the overheat meter reaches 100%. It forces players to choose between two negative consequences, adding strategic depth and preventing cheap deaths.

### Core Behavior
1. **Game Pauses** - `get_tree().paused = true`
2. **Popup Appears** - Centered, dramatic UI with two consequence options
3. **Player Chooses** - Click button to select consequence
4. **Consequence Applied** - Negative effect is applied to tank
5. **Game Resumes** - Overheat resets to 0%, player continues

---

## 📋 Implementation Details

### 1. **Movement System** (res://player/player.gd)

**Variables:**
```gdscript
@export var max_movement: float = 100.0
var current_movement: float = 100.0
var movement_regen_rate: float = 15.0  # Points per second
```

**How it works:**
- Movement bar acts like a resource that can be spent
- When locked at 0%, tank cannot move (frozen in place)
- Regenerates at 15 points/second even when frozen
- Applied to velocity through multiplier: `velocity *= (current_movement / max_movement)`

**Recovery Logic:**
```gdscript
# In _physics_process
if current_movement < max_movement:
    current_movement = min(current_movement + movement_regen_rate * delta, max_movement)
    movement_updated.emit(current_movement)
```

**Full recovery time:** ~6.7 seconds from 0% to 100%

---

### 2. **Consequence Methods** (res://player/player.gd)

#### Movement Lockdown
```gdscript
func apply_movement_lockdown() -> void:
    current_movement = 0.0
    movement_updated.emit(current_movement)
```
- **Effect:** Tank cannot move
- **Recovery:** 6.7 seconds of regeneration
- **Strategy:** Immobilizes player but recoverable

#### Blink Drive Reset
```gdscript
func apply_blink_reset() -> void:
    blink_charge = 0.0
    cpu_updated.emit(current_cpu, weapon_charge, shield_charge, blink_charge)
```
- **Effect:** Escape ability disappears
- **Recovery:** Regenerates through normal CPU allocation
- **Strategy:** Removes escape option (most punishing)

---

### 3. **Consequence Engine Manager** (res://ui/consequence_engine.gd)

**Signal Connection:**
```gdscript
func _ready() -> void:
    var players: Array = get_tree().get_nodes_in_group("player")
    player = players[0] as Player if players.size() > 0 else null
    
    if player:
        player.overheat_critical.connect(_on_overheat_critical)
```

**Consequence Flow:**
```gdscript
func _on_overheat_critical() -> void:
    handling_consequence = true
    get_tree().paused = true          # PAUSE
    show_consequence_popup()           # SHOW UI

func _on_consequence_selected(consequence: String) -> void:
    match consequence:                # APPLY
        "movement_lockdown": player.apply_movement_lockdown()
        "blink_reset": player.apply_blink_reset()
    
    player.overheat = 0.0             # RESET
    player.overheat_updated.emit(player.overheat)
    get_tree().paused = false         # UNPAUSE
    handling_consequence = false
```

---

### 4. **Consequence Popup UI** (res://ui/consequence_popup.gd)

**Procedurally Generated UI** - No scene file, all code-based

**Visual Theme:**
- Dark red overlay (semi-transparent, `Color(0.1, 0.0, 0.0, 0.8)`)
- Cyan-bordered popup box (corruption/digital theme)
- Red title text "SYSTEM CRITICAL: CONSEQUENCE REQUIRED"
- Yellow-styled movement button
- Cyan-styled blink button

**Button Styling:**
```gdscript
# Movement Button (Yellow theme)
movement_style.bg_color = Color(0.3, 0.2, 0.0)     # Dark yellow-brown
movement_style.border_color = Color(1.0, 0.8, 0.0) # Yellow border

# Blink Button (Cyan theme)
blink_style.bg_color = Color(0.0, 0.2, 0.3)        # Dark cyan
blink_style.border_color = Color(0.5, 0.8, 1.0)    # Cyan border
```

**Signal Output:**
```gdscript
signal consequence_selected(consequence: String)  # Emits selected consequence name
```

---

### 5. **HUD Integration** (res://ui/cpu_hud.gd)

**Movement Bar Display:**
```gdscript
func _on_movement_updated(movement_val: float) -> void:
    if movement_bar and movement_label:
        movement_bar.value = movement_val
        movement_label.text = "Movement: %d/100" % int(movement_val)
        
        # Color coding
        if movement_val <= 0:
            movement_bar.modulate = Color.RED           # Frozen
        elif movement_val < 30.0:
            movement_bar.modulate = Color(1.0, 0.5, 0.0) # Critical
        else:
            movement_bar.modulate = Color.WHITE         # Normal
```

**UI Location:**
- Added to existing ResourcePanel in OtherResourcesContainer
- Sits alongside Weapon, Shield, Hull, and Blink bars
- Updates in real-time as movement changes

---

### 6. **Game Setup** (res://main.gd)

**Instantiation:**
```gdscript
func _ready() -> void:
    # ... other setup ...
    
    # Instance consequence engine
    consequence_engine = ConsequenceEngine.new()
    add_child(consequence_engine)
```

---

## 🎮 Gameplay Loop

```
Normal Gameplay
    ↓
Player generates CPU (holds Q / Right-Click)
    ↓
CPU reaches 95%
    ↓
Player keeps generating → Overheat builds
    ↓
Overheat reaches 100%
    ↓
[GAME PAUSES]
[POPUP SHOWS: "Choose a consequence"]
    ↓
Player clicks Consequence Button
    ↓
[Consequence Applied]
[Overheat Reset to 0%]
[GAME RESUMES]
    ↓
Player recovers and continues
```

---

## 📊 Balancing Numbers

| System | Value | Notes |
|--------|-------|-------|
| **Movement Max** | 100.0 | Full movement capacity |
| **Movement Regen** | 15.0 pts/sec | 6.7 sec to recover from 0 |
| **Overheat Max** | 100.0 | Critical threshold |
| **CPU at Max Threshold** | 95.0 (95%) | When overheat starts building |
| **Heat per Click** | 12.5 (25 * 0.5) | Added to overheat at max CPU |
| **Overheat Decay** | 8.0 pts/sec | When not at max CPU |
| **Blink Max** | 100.0 | Blink charge capacity |

---

## 🧪 Testing Results

All tests PASSED ✅

```
test_movement_system_exists ..................... PASS
test_movement_lockdown_consequence ............. PASS
test_blink_reset_consequence ................... PASS
test_overheat_critical_signal .................. PASS
test_movement_regeneration ..................... PASS
test_consequence_popup_creation ............... PASS
test_consequence_engine_integration ........... PASS
test_full_consequence_flow ..................... PASS
test_movement_affects_velocity ................ PASS

VERDICT: 9/9 TESTS PASSED ✓
```

---

## 🚀 Future Consequences (Expandable)

### Proposed Consequences

1. **Weapon System Lockdown**
   - Set `weapon_charge = 0`
   - Recovery: Through CPU allocation
   - Threat: Can't attack while recovering

2. **Shield Overload**
   - Set `current_shield = 0`
   - Effect: All damage goes straight to hull
   - Recovery: Shield regen kicks in after delay

3. **Emergency Eject (Rare)**
   - Teleport player randomly on map
   - Disorient player, lose position
   - High risk/reward

4. **System Corruption**
   - Reverse controls for 3 seconds
   - Visual glitch effect
   - Strategic: Can fight back

5. **Core Temperature Spike**
   - Damage player directly
   - Set overheat to 50% instead of resetting to 0
   - Escalating punishment

### Adding New Consequences

```gdscript
# 1. In player.gd:
func apply_weapon_lockdown() -> void:
    weapon_charge = 0.0
    print("[CONSEQUENCE] Weapon System Lockdown")

# 2. In consequence_popup.gd:
new_button = Button.new()
new_button.text = "Weapon Lockdown"
new_button.pressed.connect(_on_weapon_pressed)

func _on_weapon_pressed() -> void:
    consequence_selected.emit("weapon_lockdown")

# 3. In consequence_engine.gd:
"weapon_lockdown": player.apply_weapon_lockdown()
```

---

## 🔧 Key Code Locations

| Feature | File | Lines | Notes |
|---------|------|-------|-------|
| Movement System | player.gd | 57-61 | Variables |
| Movement Regen | player.gd | 156-159 | Physics loop |
| Movement Velocity | player.gd | 180 | Applied to velocity |
| Consequences | player.gd | 285-294 | Methods |
| Overheat Critical | player.gd | 206-208 | Triggers engine |
| Engine Manager | consequence_engine.gd | 1-86 | Main controller |
| Popup UI | consequence_popup.gd | 1-150 | Procedural UI |
| HUD Integration | cpu_hud.gd | 244-255 | Movement bar |
| Main Setup | main.gd | 11, 38-40 | Initialization |

---

## ✅ No Breaking Changes

- ✓ **Existing resource UI intact** - Movement bar integrated cleanly
- ✓ **All signals preserved** - Added new signals, didn't break old
- ✓ **Gameplay smooth** - Pause is clean and responsive
- ✓ **Performance good** - No memory leaks or heavy allocations
- ✓ **Theme consistent** - Digital/neon aesthetic matches game
- ✓ **UI responsive** - All buttons and popups work perfectly

---

## 🎨 Visual Preview

```
[During Gameplay - Movement Bar in HUD]
┌─────────────────────────────────────┐
│ CPU:        [████████████░░░░░░░]  97 │
│ Weapon:     [███████░░░░░░░░░░░░]  35 │
│ Shield:     [██████████░░░░░░░░░░] 52  │
│ Hull:       [████████████████░░░░] 82  │
│ Movement:   [████████████████████] 100 │ ← NEW
│ Blink:      [░░░░░░░░░░░░░░░░░░░░]  0  │
│ Overheat:   [██████████████░░░░░░] 72  │
└─────────────────────────────────────┘

[When Overheat Reaches 100%]
┌─────────────────────────────────────┐
│                                       │
│   [GAME PAUSED - Dark Red Overlay]    │
│                                       │
│   ┌───────────────────────────────┐  │
│   │ SYSTEM CRITICAL:              │  │
│   │ CONSEQUENCE REQUIRED          │  │
│   │                               │  │
│   │ Your tank has overheated      │  │
│   │ from sustained abuse.         │  │
│   │ Choose one consequence:       │  │
│   │                               │  │
│   │ [Movement Lockdown] [Blink..] │  │
│   │   (Tank Frozen)      (Blink=0)  │
│   │                               │  │
│   └───────────────────────────────┘  │
│                                       │
└─────────────────────────────────────┘
```

---

## 📝 Summary

The **Consequence Engine** is a fully integrated, thoroughly tested feature that:
- ✓ Adds strategic depth to overheat management
- ✓ Prevents cheap deaths through forced consequences
- ✓ Displays beautifully with consistent visual theme
- ✓ Integrates seamlessly with existing systems
- ✓ Is expandable for future consequences
- ✓ Passes all validation tests

**Status: READY FOR GAMEPLAY TESTING** 🚀
