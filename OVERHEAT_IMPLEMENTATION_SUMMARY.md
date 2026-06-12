# Overheating Anti-Spam System - Implementation Summary

## Overview
The overheating system is an anti-spam mechanic that prevents players from mindlessly spamming the right-click/Q buttons to generate CPU. Instead, it forces smart resource management decisions.

## How It Works

### Mechanics
1. **Generation Tracking**: Player generates CPU by holding Q or Right Mouse Button
   - `is_generating = true` when holding
   - `is_generating = false` when released

2. **Overheat Buildup**: When BOTH conditions are met:
   - CPU reaches 100% (`current_cpu >= max_cpu_cycles`)
   - AND player is actively generating (`is_generating == true`)
   - Overheat increases at 15 points/second (configurable)

3. **Overheat Decay**: When either condition is false:
   - Player stops holding Q/Right Mouse Button, OR
   - Player spends CPU on weapons/blink (CPU drops below 100%)
   - Overheat decreases at 8 points/second (configurable)

4. **Game Over**: If overheat reaches 100%:
   - System meltdown occurs
   - `player_died.emit()` is called
   - Player must restart

## Code Implementation

### Player Script (res://player/player.gd)

#### Variables (Lines 48-58)
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

#### Signal (Line 66)
```gdscript
signal overheat_updated(value: float)  # Emitted every frame to update UI
```

#### Input Handling (_input function, Lines 222-234)
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
	# ... other input handling ...
```

#### Physics Processing (_physics_process function, Lines 197-220)
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
	overheat_updated.emit(overheat)  # Signal UI to update every frame
```

### UI Script (res://ui/cpu_hud.gd)

#### Signal Handler (_on_overheat_updated, Lines 181-214)
```gdscript
func _on_overheat_updated(overheat_val: float) -> void:
	"""Update overheat bar with color gradient from yellow to red."""
	# Validate that UI elements are initialized
	if not overheat_bar or not overheat_value or not overheat_label:
		print("ERROR: Overheat UI elements not initialized!")
		return
	
	# Update bar value
	overheat_bar.value = overheat_val
	
	# Update value label text
	overheat_value.text = "%d/100" % int(overheat_val)
	
	# Color gradient: Yellow (0%) -> Orange -> Red (100%)
	var color_ratio: float = overheat_val / 100.0
	var overheat_color: Color = Color.YELLOW.lerp(Color.RED, color_ratio)
	
	# Update bar fill color
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

#### Signal Connection (_ready, Lines 40-48)
```gdscript
	if player:
		# ... other connections ...
		# Connect overheat signal
		player.overheat_updated.connect(_on_overheat_updated)
```

### Main Script (res://main.gd)

#### CPU HUD Instantiation (Lines 8, 28-30)
```gdscript
var cpu_hud_scene: PackedScene = preload("res://ui/cpu_hud.tscn")  # Line 8

# In _ready():
if cpu_hud_scene:
	cpu_hud = cpu_hud_scene.instantiate() as CanvasLayer
	add_child(cpu_hud)
```

## UI Layout

The OverHeat panel is located in the **bottom-center** of the screen with:
- **Label**: "OverHeat" (changes color: Yellow → Orange → Red)
- **ProgressBar**: Visual bar showing heat level (0-100)
- **Value**: Text showing "XX/100" percentage

The panel appears alongside other UI elements (CPU, Weapon, Shield, Hull, Blink).

## Configuration

All values are configurable in player.gd:

| Variable | Default | Effect |
|----------|---------|--------|
| `overheat_max` | 100.0 | Maximum overheat level before game over |
| `overheat_gain_rate` | 15.0 | Points per second when heating |
| `overheat_decay_rate` | 8.0 | Points per second when cooling |
| `cpu_max_threshold` | 1.0 | Seconds at max CPU before heat starts |

## Testing

Run the integration test to verify functionality:
```
res://test_overheat_integration.gd
```

Tests verify:
- ✓ Overheat does NOT increase without active generation
- ✓ Overheat DOES increase with active generation at max CPU
- ✓ Overheat decays when generation stops
- ✓ Signal emissions work correctly
- ✓ UI receives signal updates

## Design Philosophy

This anti-spam mechanic forces players to:
1. **Make strategic choices**: Generate or spend CPU wisely
2. **Manage heat**: Stop generating to cool down, or spend CPU to drop it below 100%
3. **Balance resources**: Use weapons/blink to prevent overheat
4. **Avoid mindless play**: Pure spam leads to inevitable defeat

The system rewards smart play while punishing lazy button mashing.
