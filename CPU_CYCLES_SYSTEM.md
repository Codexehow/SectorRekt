# CPU Cycles System - SectorRekt Player Resource Management

## Overview
The CPU Cycles System is a core mechanic where the player actively generates "CPU Cycles" during gameplay by holding the **Q key** or **Right Mouse Button (RMB)**. These cycles represent computational resources that power the player's abilities and are automatically distributed across five subsystems.

---

## Core Mechanics

### CPU Generation
- **Trigger**: Hold Q key or Right Mouse Button
- **Generation Rate**: 35 cycles per second while actively held
- **Max Capacity**: 100 cycles
- **Decay Rate**: 15 cycles per second when not generating
- **Gameplay Impact**: Active resource management increases difficulty and splits player attention

### CPU Distribution
When the player holds Q/RMB to generate CPU, the cycles are automatically distributed among five subsystems:

| Subsystem | Allocation | Effect |
|-----------|-----------|--------|
| **Main Weapon (Thunderbolt)** | 50% | Speeds up weapon charging |
| **Shields** | 30% | Charges protective shield |
| **Movement** | 10% | Increases movement speed bonus |
| **Life Support** | 10% | Reserved for future use (survival mechanics) |
| **Blink Drive** | 10% | Charges teleportation ability |

---

## Player Abilities

### 1. Thunderbolt (Main Weapon)
- **Input**: Left Mouse Button (click to fire)
- **Charge Requirement**: 30 CPU cycles minimum
- **Cost**: 30 cycles per shot
- **Behavior**: Fires a projectile toward the mouse cursor
- **Code**: `fire_thunderbolt()` function

**Status**: ✅ Fully Implemented

### 2. Shield
- **Charge Requirement**: Continuous CPU allocation (30% of generation)
- **Max Capacity**: 100 cycles
- **Behavior**: Absorbs incoming damage
- **Code**: `shield_charge` variable tracked in signals

**Status**: ⏳ Charge system ready, impact mechanics pending

### 3. Blink Drive (Teleport)
- **Input**: B key
- **Charge Requirement**: 100 cycles (fully charged)
- **Cost**: Full charge consumed on use
- **Behavior**: Teleports player forward in the direction of travel by 150 pixels
- **Feature**: Allows teleporting through walls
- **Code**: `blink_drive()` function

**Status**: ✅ Fully Implemented

### 4. Movement Speed Bonus
- **Effect**: 10% of CPU generation increases movement speed
- **Formula**: `velocity * (1.0 + 0.10 * (current_cpu / max_cpu))`
- **Max Bonus**: +10% speed when CPU is full

**Status**: ✅ Fully Implemented

### 5. Life Support (Reserved)
- **Allocation**: 10% of CPU cycles
- **Purpose**: Future implementation for health/survival mechanics
- **Current Status**: Tracked but not yet used in gameplay

---

## Signals for UI Integration

The player emits the following signal for UI updates:

```gdscript
signal cpu_updated(current: float, weapon: float, shield: float, blink: float)
```

**Usage in UI Manager**:
```gdscript
func _on_cpu_updated(current: float, weapon: float, shield: float, blink: float) -> void:
    update_weapon_bar(weapon)
    update_shield_bar(shield)
    update_blink_bar(blink)
    update_cpu_bar(current)
```

---

## Tank Movement System (Preserved)

The player retains the original tank movement mechanics:

### Basic Controls
- **Forward Movement**: Always moving forward
- **Turn Right**: D key or Right Arrow
- **Turn Left**: A key or Left Arrow
- **Accelerate**: W key or Up Arrow
- **Decelerate**: S key or Down Arrow

### Speed Presets
- **Key 1**: 50% base speed (45 units/sec)
- **Key 2**: 75% base speed (67.5 units/sec)
- **Key 3**: 100% base speed (90 units/sec) - Default
- **Key 4**: 135% base speed (121.5 units/sec)
- **Key 5**: 180% base speed (162 units/sec) - Max

### Weapon Aiming
- Mouse position determines weapon pivot direction
- Projectiles fire toward mouse cursor

---

## Debug & Corrupted Mode

### Toggle Corrupted Mode
- **Key**: G
- **Effect**: Switches between normal and corrupted visual state
- **Signal**: `hallucination_triggered` (emitted when in corrupted mode)

---

## Implementation Details

### File Location
`res://player/player.gd` - Main player script (151 lines)

### Key Variables
```gdscript
# CPU System
@export var max_cpu_cycles: float = 100.0
var current_cpu: float = 0.0
var cpu_generation_rate: float = 35.0

# Charge Tracking
var weapon_charge: float = 0.0
var shield_charge: float = 0.0
var blink_charge: float = 0.0

# Allocation Constants
const WEAPON_ALLOC: float = 0.50
const SHIELD_ALLOC: float = 0.30
const MOVEMENT_ALLOC: float = 0.10
const LIFE_SUPPORT_ALLOC: float = 0.10
const BLINK_ALLOC: float = 0.10
```

### Key Methods

#### `_physics_process(delta: float)`
- Handles CPU generation/decay
- Distributes CPU across subsystems
- Manages tank movement
- Emits `cpu_updated` signal each frame

#### `fire_thunderbolt()`
- Spawns projectile at weapon muzzle
- Fires toward mouse position
- Requires 30 cycles minimum

#### `blink_drive()`
- Teleports player 150 pixels forward
- Requires full 100 cycles
- Resets blink charge to 0

#### `_input(event: InputEvent)`
- Handles left-click weapon firing
- Handles B key for blink
- Handles G key for corruption toggle

---

## Gameplay Flow

1. **Player holds Q/RMB** → CPU cycles generate at 35/sec
2. **CPU distributed automatically**:
   - 50% → Weapon charges (fills at variable rate)
   - 30% → Shield charges
   - 10% → Movement bonus applied
   - 10% → Blink charges
   - 10% → Life Support (reserved)
3. **Player can:**
   - Click to fire when weapon ≥ 30 cycles
   - Press B to blink when blink = 100 cycles
4. **Player releases Q/RMB** → CPU decays at 15/sec
5. **Difficulty scales** with CPU management demands

---

## Future Expansions

### Shield Impact Mechanics
- Implement shield absorption system
- Visual feedback when shield blocks damage
- Shield break visual effect

### Life Support System
- Health bar powered by Life Support CPU
- Regeneration while generating CPU
- Damage reduction mechanics

### Advanced CPU Management
- Tactical allocation UI (manual distribution override)
- CPU burst mode (brief max generation for high cost)
- Subsystem failure penalties (low CPU = reduced efficiency)

### Hallucination Integration
- Enhanced visual glitches when corrupted
- CPU manipulation tricks
- Audio distortion effects

---

## Testing Checklist

- [x] CPU generates when Q is held
- [x] CPU decays when Q is released
- [x] CPU distributes correctly to all subsystems
- [x] Weapon fires when fully charged (≥30)
- [x] Weapon cost is 30 cycles
- [x] Blink activates when fully charged (100)
- [x] Blink resets on use
- [x] Movement speed increases with CPU
- [x] Tank movement works (A/D turning, W/S speed)
- [x] Weapon aiming follows mouse
- [x] Corrupted mode toggles with G
- [x] Signals emit correctly for UI

---

## Integration with UI System

Connect player signals to UIManager:

```gdscript
# In world.tscn or main scene setup
player.cpu_updated.connect(ui_manager._on_cpu_updated)
player.hallucination_triggered.connect(hallucination_manager._on_hallucination)
```

---

**System Status**: ✅ **FULLY IMPLEMENTED & READY**

All core mechanics are functional and tested. Ready for UI integration and additional features.
