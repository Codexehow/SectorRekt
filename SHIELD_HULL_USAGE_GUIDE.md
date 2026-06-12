# Shield + Hull Damage System - Usage Guide

## Overview

The Shield + Hull Damage System provides a two-tier health system where:
1. **Shields** absorb all incoming damage first
2. **Hull** takes damage only after shields are depleted
3. **Visual Feedback** shows as a cyan glitch effect when shields absorb damage
4. **UI Tracking** displays both health bars dynamically

---

## How to Use

### Basic Damage Dealing

Call `take_damage()` on the player to deal damage:

```gdscript
var player = get_tree().get_first_node_in_group("player") as Player

# Deal 30 damage from a wall
player.take_damage(30.0, "wall")

# Deal 25 damage from an enemy
player.take_damage(25.0, "enemy")

# Deal custom damage from any source
player.take_damage(50.0, "boss_attack")
```

### Available Damage Sources

The system tracks damage sources as a string parameter. Current sources include:
- `"wall"` - Wall collisions
- `"enemy"` - Enemy contact
- Any custom string for other sources

---

## Game Behavior

### Damage Absorption Priority

```
Incoming Damage
      ↓
    Shield absorbs what it can
      ↓
    Remaining goes to Hull
      ↓
    If Hull ≤ 0, Player dies
```

### Visual Feedback

**When Shields Absorb Damage:**
- Cyan/blue glitch flash appears over the player tank
- Effect lasts 0.15 seconds
- Flash flickers 8 times while fading out
- Creates a "sci-fi shield taking impact" effect

**When Hull Takes Damage:**
- No visual effect on the tank
- Hull bar decreases in the UI
- Label turns bright red if hull drops below 25%

### UI Display

Shield and Hull bars appear in the top-left corner:

```
┌─────────────────────┐
│ CPU: 85/100         │
├─────────────────────┤
│ Weapon: 45/100      Shield: 70/100
│ Hull: 55/100        Blink: 100/100
└─────────────────────┘
```

- **Weapon Bar**: Orange color
- **Shield Bar**: Cyan color  
- **Hull Bar**: Red (bright red when critical < 25%)
- **Blink Bar**: Magenta color

---

## Configuration

### Player Stats (in `player.gd`)

```gdscript
@export var max_hull: float = 100.0      # Maximum hull health
@export var max_shield: float = 100.0    # Maximum shield capacity
```

Change these exports in the Inspector to adjust player durability.

### Effect Settings (in `impact_glimmer.gd`)

```gdscript
@export var glimmer_duration: float = 0.15   # How long effect lasts
@export var glimmer_intensity: float = 0.8   # Effect brightness
@export var glimmer_color: Color = Color(0.0, 1.0, 1.0, 1.0)  # Cyan
```

Adjust these in the Inspector to customize the glimmer effect:
- **Duration**: Increase for longer effect, decrease for quick flash
- **Intensity**: 0.0 = invisible, 1.0 = full brightness
- **Color**: Change to red/blue/purple for different effects

---

## Damage Scenarios

### Scenario 1: Shields Taking All Damage
**Before:**
- Shield: 100/100
- Hull: 100/100

**Action:** Take 40 damage from wall

**After:**
- Shield: 60/100
- Hull: 100/100
- **Effect:** Cyan glimmer shown

### Scenario 2: Shields Break During Damage
**Before:**
- Shield: 30/100
- Hull: 100/100

**Action:** Take 50 damage from boss

**Calculation:**
- Shield absorbs: 30
- Remaining: 20
- Hull takes: 20

**After:**
- Shield: 0/100
- Hull: 80/100
- **Effect:** Cyan glimmer shown once (when shield absorbed the 30)

### Scenario 3: Hull Taking Damage Directly
**Before:**
- Shield: 0/100
- Hull: 100/100

**Action:** Take 25 damage from wall

**After:**
- Shield: 0/100
- Hull: 75/100
- **Effect:** None (no glimmer, shields already gone)

### Scenario 4: Critical Hull State
**Before:**
- Shield: 0/100
- Hull: 20/100

**Action:** Take 10 damage

**After:**
- Shield: 0/100
- Hull: 10/100
- **UI Change:** Hull label turns bright red (critical state < 25%)

---

## Signals Used

### `player_damaged(hull: float, shield: float)`

Emitted whenever damage is applied to either shield or hull.

```gdscript
# In another script
var player = get_tree().get_first_node_in_group("player") as Player
player.player_damaged.connect(_on_player_took_damage)

func _on_player_took_damage(hull: float, shield: float):
    print("Player damaged! Hull: %d, Shield: %d" % [int(hull), int(shield)])
```

### `player_died`

Emitted when hull reaches 0.

```gdscript
player.player_died.connect(_on_player_died)

func _on_player_died():
    print("Game Over!")
```

---

## Implementation Details

### Call Stack When Damage Occurs

```
Other Script → player.take_damage()
                  ↓
             Check shield
                  ↓
             Shield > 0?
             /        \
           YES        NO
            ↓          ↓
        (absorb)   (skip to hull)
            ↓          ↓
        show_impact_glimmer()  Hull takes damage
            ↓
        Check for ImpactGlimmer node
            ↓
        trigger_glimmer()
            ↓
        Start cyan flash effect
            ↓
        Emit player_damaged signal
            ↓
        UI updates automatically
```

### Console Output

When damage is taken, the console shows:

```
Shield absorbed 30 damage from wall
Hull took 20 damage from enemy
```

This helps with debugging and understanding damage flow.

---

## Design Patterns

### Signal-Based UI Updates

The system uses Godot's signal system for UI updates:

1. Player takes damage → emits signal
2. UI script receives signal → updates bars
3. UI updates automatically without polling

This is efficient and keeps game logic separate from UI.

### Modulation-Based Visual Effects

The glimmer effect uses modulation (color overlay) rather than particle effects:

- **Advantage:** Light on performance, works at any zoom level
- **Effect:** Cyan color overlays the tank sprite with flickering animation
- **Duration:** Only 0.15 seconds per hit

---

## Troubleshooting

### No Glimmer Effect Showing

1. **Check shield value**: Glimmer only shows if shields > 0
2. **Check ImpactGlimmer node**: Must exist as child of Player
3. **Check script assignment**: impact_glimmer.gd must be assigned
4. **Check node name**: Must be exactly "ImpactGlimmer"

### Hull Bar Not Updating

1. **Check signal connection**: player.player_damaged must connect to UI
2. **Check UI scene loaded**: CPU HUD must be instantiated
3. **Check Player group**: Player must be in "player" group
4. **Check bar references**: Hull label and bar must be found by @onready

### Damage Not Being Applied

1. **Check take_damage() called**: Print statements should show in console
2. **Check source parameter**: Must be a valid string
3. **Check player exists**: Make sure player is added to scene

---

## Future Extensions

### Possible Enhancements

- **Shield Regeneration**: Add `regenerate_shield()` method
- **Hull Repair**: Add `repair_hull()` method
- **Damage Types**: Different glimmer colors for different damage types
- **Armor System**: Add armor that reduces damage before shields
- **Damage Multipliers**: Critical hits that do extra damage
- **Status Effects**: Burn damage, poison, etc.

---

## Performance Notes

- **Minimal overhead**: Glimmer effect only runs during 0.15s duration
- **No garbage collection**: Uses simple modulation, no object creation
- **No physics impact**: UI updates don't affect physics
- **Scalable**: Works with any number of enemies/walls

---

## Summary

The Shield + Hull Damage System is:
- ✅ Easy to use: Just call `take_damage(amount, source)`
- ✅ Visual feedback: Cyan glimmer on shield absorption
- ✅ Dynamic UI: Automatic bar updates and color changes
- ✅ Extensible: Easy to add new damage sources or effects
- ✅ Performant: Minimal overhead
