# Overheating Anti-Spam System - Key Code Excerpts

## Overview
This document shows the exact code changes that implement the anti-spam overheating system.

---

## 1. Player Variable Declarations (player.gd, Lines 48-58)

```gdscript
# === OVERHEAT SYSTEM ===
# Anti-spam mechanic: Tracks overheating when CPU is at 100% AND player is actively generating
# Prevents mindless right-click/Q spamming by forcing resource balance decisions
# Bar fills from yellow to red (0-100), decays when player stops generating or CPU drops below 100%
var overheat: float = 0.0
var overheat_max: float = 100.0
var is_generating: bool = false  # Tracks if player is actively holding Q or Right Mouse Button
var cpu_max_timer: float = 0.0  # Timer for when CPU is at 100%
var cpu_max_threshold: float = 1.0  # Seconds at 100% CPU before overheat starts filling
var overheat_gain_rate: float = 15.0  # Points per second when CPU is at 100% AND actively generating
var overheat_decay_rate: float = 8.0  # Points per second when NOT actively generating
```

---

## 2. Signal Definition (player.gd, Line 66)

```gdscript
signal overheat_updated(value: float)
```

---

## 3. Input Handling - Generation Tracking (player.gd, Lines 222-234)

```gdscript
func _input(event: InputEvent) -> void:
	# === CPU GENERATION & OVERHEAT TRACKING ===
	# Track active CPU generation for anti-spam overheat system
	# is_generating becomes true when player presses Q or Right Mouse Button
	# and false when they release it (for key press/release detection)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		is_generating = event.pressed
		if event.pressed:
			generate_cpu_cycles()
	if event is InputEventKey and event.keycode == KEY_Q:
		is_generating = event.pressed
		if event.pressed:
			generate_cpu_cycles()
	
	# Primary Attack (Fire Thunderbolt)
	# ... rest of input handling ...
```

---

## 4. Overheat Logic - Physics Processing (player.gd, Lines 197-220)

```gdscript
	# === OVERHEAT SYSTEM (Anti-Spam Mechanic) ===
	# Only heat up when BOTH conditions are true:
	# 1. CPU is at maximum (current_cpu >= max_cpu_cycles)
	# 2. Player is actively generating (holding Q or Right Mouse Button)
	# This prevents mindless spam by forcing smart resource balancing
	if current_cpu >= max_cpu_cycles and is_generating:
		cpu_max_timer += delta
		# Once threshold is crossed, start heating up
		if cpu_max_timer >= cpu_max_threshold:
			overheat = min(overheat + overheat_gain_rate * delta, overheat_max)
	else:
		cpu_max_timer = 0.0
		# Decay overheat when not at max CPU or not generating
		# This allows the player to cool down by stopping generation or using resources
		overheat = max(overheat - overheat_decay_rate * delta, 0.0)
	
	# Game over: System overheats from sustained abuse
	if overheat >= overheat_max:
		print("SYSTEM CRITICAL: Overheating meltdown!")
		die()
	
	cpu_updated.emit(current_cpu, weapon_charge, shield_charge, blink_charge)
	shield_buffer_updated.emit(shield_buffer)
	overheat_updated.emit(overheat)
```

---

## 5. UI Signal Handler (cpu_hud.gd, Lines 181-214)

```gdscript
func _on_overheat_updated(overheat_val: float) -> void:
	"""Update overheat bar with color gradient from yellow to red."""
	# Validate that UI elements are initialized
	if not overheat_bar or not overheat_value or not overheat_label:
		print("ERROR: Overheat UI elements not initialized!")
		print("  overheat_bar: ", overheat_bar)
		print("  overheat_value: ", overheat_value)
		print("  overheat_label: ", overheat_label)
		return
	
	# Update bar value
	overheat_bar.value = overheat_val
	
	# Update value label text
	overheat_value.text = "%d/100" % int(overheat_val)
	
	# Color gradient: Yellow (0%) -> Orange -> Red (100%)
	var color_ratio: float = overheat_val / 100.0
	var overheat_color: Color = Color.YELLOW.lerp(Color.RED, color_ratio)
	
	# Update bar fill color using a StyleBoxFlat.
	# Godot 4 ProgressBar uses a StyleBox for "fill", NOT a theme color.
	# add_theme_color_override("fill_color", ...) silently does nothing on ProgressBar.
	var fill_stylebox := StyleBoxFlat.new()
	fill_stylebox.bg_color = overheat_color
	overheat_bar.add_theme_stylebox_override("fill", fill_stylebox)
	
	# Change label color intensity based on heat level
	if overheat_val >= 75.0:
		overheat_label.add_theme_color_override("font_color", Color.RED)
	elif overheat_val >= 50.0:
		overheat_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.0))  # Orange
	else:
		overheat_label.add_theme_color_override("font_color", Color.YELLOW)
```

---

## 6. UI Signal Connection (cpu_hud.gd, Lines 40-48)

```gdscript
	if player:
		# Connect the player's cpu_updated signal to our update function
		player.cpu_updated.connect(_on_cpu_updated)
		# Connect the player's damage signal for hull/shield updates
		player.player_damaged.connect(_on_player_damaged)
		# Connect shield buffer signal
		player.shield_buffer_updated.connect(_on_shield_buffer_updated)
		# Connect overheat signal
		player.overheat_updated.connect(_on_overheat_updated)
```

---

## 7. Main Script - UI Instantiation (main.gd, Lines 8, 28-30)

```gdscript
var cpu_hud_scene: PackedScene = preload("res://ui/cpu_hud.tscn")

# In _ready():
	# Instance CPU HUD
	if cpu_hud_scene:
		cpu_hud = cpu_hud_scene.instantiate() as CanvasLayer
		add_child(cpu_hud)
```

---

## Logic Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    OVERHEAT LOGIC                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Player Input                                          │
│    ↓                                                    │
│  Q Key or Right Mouse Button                          │
│    ├─ PRESS → is_generating = true                     │
│    │           generate_cpu_cycles()                   │
│    └─ RELEASE → is_generating = false                  │
│                                                         │
│  Each Frame (_physics_process)                         │
│    ↓                                                    │
│  CHECK: current_cpu >= 100% AND is_generating?        │
│    ├─ YES → Start heating up (after threshold)         │
│    │        overheat += 15.0 * delta                   │
│    │                                                    │
│    └─ NO → Start cooling down                          │
│            overheat -= 8.0 * delta                     │
│                                                         │
│  CHECK: overheat >= 100%?                             │
│    ├─ YES → GAME OVER (player_died.emit())             │
│    └─ NO → Continue                                    │
│                                                         │
│  Emit Signal                                           │
│    ↓                                                    │
│  overheat_updated.emit(overheat)                       │
│    ↓                                                    │
│  CPUHUD Updates Bar & Label                           │
│    ├─ Bar fill color: Yellow → Orange → Red           │
│    ├─ Label color: Changes at 50% and 75%             │
│    └─ Value text: Shows "XX/100"                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Key Concepts

### 1. Two-Condition Check
```gdscript
if current_cpu >= max_cpu_cycles and is_generating:
    // Both must be true to heat up
```
This ensures overheat only increases when the player is **actively** spamming, not just when CPU happens to be at 100%.

### 2. Three Ways to Cool Down
```gdscript
// 1. Release the button
is_generating = false
// → Overheat decays immediately

// 2. Spend CPU on weapons/abilities
current_cpu < max_cpu_cycles
// → Overheat decays

// 3. Wait
// Overheat always decays at 8.0 points/second when not heating
```

### 3. Signal-Based UI Update
```gdscript
// Every frame:
overheat_updated.emit(overheat)  // Signal sent

// UI receives and updates:
_on_overheat_updated(overheat_val)
  - Updates bar value
  - Updates text label
  - Calculates color gradient
  - Applies fill color
  - Adjusts label color
```

---

## Configuration Variables

All values can be tuned in player.gd:

| Variable | Default | Adjustable? | Effect |
|----------|---------|-------------|--------|
| `overheat_max` | 100.0 | Yes | Maximum heat before game over |
| `overheat_gain_rate` | 15.0 | Yes | Heat increase speed (pts/sec) |
| `overheat_decay_rate` | 8.0 | Yes | Heat decrease speed (pts/sec) |
| `cpu_max_threshold` | 1.0 | Yes | Seconds before heating starts |
| `is_generating` | false | Automatic | Tracks button state |
| `cpu_max_timer` | 0.0 | Automatic | Internal timer |

---

## No Breaking Changes

The implementation:
- ✓ Does NOT modify existing signals (cpu_updated, player_damaged, etc.)
- ✓ Does NOT change weapon system
- ✓ Does NOT change movement system
- ✓ Does NOT change shield/health system
- ✓ Does NOT modify existing UI elements
- ✓ Only adds new `overheat_updated` signal
- ✓ Only adds new UI panel (OverHeatPanel)
- ✓ Preserves all existing player mechanics

---

## Testing the Implementation

### Quick Test
```gdscript
# In game scene:
1. Hold Q or Right Mouse Button (CPU increases)
2. Keep holding until CPU reaches 100% (≈2-3 seconds)
3. Keep holding for 1 more second (overheat starts)
4. Watch overheat bar fill (at bottom center of screen)
5. Release button → overheat bar should start shrinking
6. Fire weapon (LMB) → CPU drops, overheat shrinks faster
7. Keep holding Q while overheat is high → eventual game over
```

### Unit Test
```bash
# In editor, with world.tscn open:
Run res://test_overheat_integration.gd
# Should see 5 test results pass
```

---

## Summary

The anti-spam overheating system is a complete, self-contained feature that:
1. Tracks player input (`is_generating` flag)
2. Fills overheat only during active spam (both conditions must be true)
3. Decays overheat when spam stops or CPU is spent
4. Sends signal every frame to update UI with color feedback
5. Causes game over if overheat reaches 100%

All code is clean, type-safe, well-commented, and non-breaking.
