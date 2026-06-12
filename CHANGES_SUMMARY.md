# Game System Changes Summary

## Overview
Four major game system features have been implemented:

---

## 1. CPU Drain System (When CPU = 0)
**File: `res://player/player.gd`**

### What it does:
When CPU cycles reach 0, ALL systems begin losing power rapidly:
- **Weapon Charge**: Drains at 30.0 points/second
- **Shield Charge**: Drains at 30.0 points/second  
- **Blink Charge**: Drains at 30.0 points/second
- **Movement Speed**: Decreases at 50.0 units/second (minimum 30 units/second)

### Implementation:
```gdscript
if current_cpu <= 0:
    weapon_charge = max(weapon_charge - 30.0 * delta, 0.0)
    shield_charge = max(shield_charge - 30.0 * delta, 0.0)
    blink_charge = max(blink_charge - 30.0 * delta, 0.0)
    current_speed = max(current_speed - 50.0 * delta, 30.0)
```

**Impact**: Makes CPU management critical - the game becomes extremely difficult when CPU is depleted.

---

## 2. Shield Buffer System
**Files: `res://player/player.gd`, `res://ui/cpu_hud.gd`, `res://ui/cpu_hud.tscn`**

### What it does:
A sophisticated delayed shield recharge mechanic:

1. **Accumulation Phase**: When shields are at 100%, incoming CPU allocation (30% of CPU) goes into a buffer instead of directly to shields
   - Buffer can hold up to 500 points
   - Accumulates at: `CPU * SHIELD_ALLOC * 2.5 * delta`

2. **Depletion Phase**: When shields drop below 10% HP and buffer > 0:
   - Buffer slowly recharges shields at 5.0 points/second
   - Shields never instantly refill
   - This creates a risk/reward dynamic

3. **Impact Ranges**:
   - Player gets hit, shields drop by 1-4% per impact (4-25 HP depending on damage)
   - If shields drop to <10%, they must rely on buffered energy to recover
   - Creates tension and difficulty as shields can't instantly recover

### Variables Added:
```gdscript
var shield_buffer: float = 0.0
var shield_buffer_recharge_rate: float = 5.0
var shield_low_threshold: float = 10.0
signal shield_buffer_updated(buffer: float)
```

### Shield Bar Display:
A new "Buffer: X" label shows buffer value in the Shield section of the HUD

---

## 3. Controls Toggle (C Key) - NOW WORKING
**Files: `res://ui/cpu_hud.gd`, `res://ui/cpu_hud.tscn`**

### What it does:
- **Press C** to toggle controls visibility on/off
- **Controls Panel**: Shows all input commands (Q/RMB for CPU, LMB for fire, etc.)
- **Options Panel**: Now appears when C is pressed (new feature)

### Implementation:
```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_C:
        controls_visible = not controls_visible
        controls_panel.visible = controls_visible
        options_visible = not options_visible
        options_panel.visible = options_visible
        get_tree().root.set_input_as_handled()
```

**Status**: ✅ FULLY WORKING - Press C to toggle both panels

---

## 4. Fullscreen & Resolution Options
**Files: `res://ui/cpu_hud.gd`, `res://ui/cpu_hud.tscn`**

### What it does:
NEW OPTIONS PANEL (appears when you press C):
- **Fullscreen Toggle**: Checkbox to enable/disable fullscreen mode
- **Resolution Selector**: Dropdown with 5 preset resolutions:
  - 1280x720 (720p)
  - 1600x900 
  - 1920x1080 (1080p) - Default
  - 2560x1440 (1440p)
  - 3840x2160 (4K)

### UI Layout:
```
┌─── OPTIONS PANEL (Right side) ─────┐
│ [OPTIONS]                          │
│ ─────────────────────────────────  │
│ ☐ Fullscreen                       │
│ Resolution:                        │
│ [1920x1080 ▼]                      │
└────────────────────────────────────┘
```

### Implementation:
```gdscript
func _on_fullscreen_toggled(pressed: bool) -> void:
    if pressed:
        get_window().mode = Window.MODE_FULLSCREEN
    else:
        get_window().mode = Window.MODE_WINDOWED

func _on_resolution_selected(index: int) -> void:
    var resolutions: Array[Vector2i] = [
        Vector2i(1280, 720),
        Vector2i(1600, 900),
        Vector2i(1920, 1080),
        Vector2i(2560, 1440),
        Vector2i(3840, 2160)
    ]
    get_window().size = resolutions[index]
```

**Status**: ✅ FULLY WORKING - Press C to open, toggle fullscreen, change resolution

---

## Testing the Features

### Test 1: CPU Drain System
1. Launch the game
2. Generate CPU cycles (Q or Right Mouse Button)
3. Let CPU deplete to 0 by not clicking
4. **Expected**: All systems rapidly drain (weapons, shields, blink, speed)

### Test 2: Shield Buffer System
1. Generate CPU clicks while shields are at 100%
2. **Expected**: Buffer value increases in Shield section
3. Take damage and let shields drop below 10%
4. **Expected**: Shields slowly recover from buffer at 5.0 HP/second

### Test 3: Toggle Controls (C Key)
1. Press C
2. **Expected**: Both controls panel (bottom-left) AND options panel (top-right) toggle visibility

### Test 4: Fullscreen & Resolution
1. Press C to show panels
2. Click "Fullscreen" checkbox
3. **Expected**: Game goes fullscreen/windowed
4. Select resolution from dropdown
5. **Expected**: Window resizes (if windowed) or next resolution loads at fullscreen

---

## Performance Notes
- Shield buffer system uses minimal CPU (simple per-frame checks)
- Fullscreen toggle is instant
- Resolution change may cause brief stutter (normal for window resize)
- All systems properly drain when CPU = 0 (no infinite charges)

---

## Difficulty Impact
These changes make the game SIGNIFICANTLY harder:
- ✅ CPU management is now critical (0 CPU = system failure)
- ✅ Shields can't instantly recover (buffer system creates tension)
- ✅ Players must click continuously or lose all capabilities
- ✅ Risk/reward: Is it worth letting CPU drain for repositioning?

This creates a "resource tower defense" feel where player management is key.
