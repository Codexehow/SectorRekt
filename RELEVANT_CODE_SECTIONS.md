# Relevant Code Sections - Overheating Anti-Spam System

This document shows the relevant parts of **player.gd** and **ui/cpu_hud.gd** for the implementation.

---

## player.gd - Relevant Sections

### Section 1: Variable Declarations (Lines 48-68)

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

@export var is_corrupted: bool = false

signal hallucination_triggered(type: String)
signal cpu_updated(current: float, weapon: float, shield: float, blink: float)
signal player_damaged(hull: float, shield: float)
signal shield_buffer_updated(buffer: float)
signal overheat_updated(value: float)
signal player_died
signal player_won
```

**Status**: ✅ IMPLEMENTED

---

### Section 2: Input Handling (Lines 224-236)

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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if weapon_charge >= 30.0:
			fire_thunderbolt()
			weapon_charge -= 30.0
		else:
			print("Weapon not charged! (", int(weapon_charge), "%)")
	
	# ... rest of input handling ...
```

**Status**: ✅ IMPLEMENTED

**Key Points**:
- Line 230: `is_generating = event.pressed` captures both press AND release
- Line 234: Same for Q key
- When player presses: `is_generating = true`
- When player releases: `is_generating = false`

---

### Section 3: Physics Processing - Overheat Logic (Lines 199-222)

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

**Status**: ✅ IMPLEMENTED

**Key Points**:
- Line 204: `if current_cpu >= max_cpu_cycles and is_generating:` - THE CRITICAL CONDITION
- Lines 205-208: Heat up logic (15 pts/sec after 1 sec threshold)
- Lines 209-213: Cool down logic (8 pts/sec)
- Lines 216-218: Game over condition
- Line 222: Signal emitted every frame

---

## ui/cpu_hud.gd - Relevant Sections

### Section 1: UI Element References (Lines 17-20)

```gdscript
# OverHeat panel references - Will be initialized in _ready() to handle runtime instantiation
var overheat_label: Label = null
var overheat_bar: ProgressBar = null
var overheat_value: Label = null
```

**Status**: ✅ ALREADY IMPLEMENTED

---

### Section 2: Signal Connection (Lines 40-48)

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

**Status**: ✅ ALREADY IMPLEMENTED

**Key Points**:
- Line 48: Connects the overheat signal to the update handler
- Type-safe: Signal passes `float`, handler receives `float`
- Happens in `_ready()` after player is found

---

### Section 3: UI Initialization (Lines 84-86)

```gdscript
	# OverHeat panel elements
	overheat_label = get_node_or_null("OverHeatPanel/VBoxContainer3/OverHeatLabel")
	overheat_bar = get_node_or_null("OverHeatPanel/VBoxContainer3/OverHeatBar")
	overheat_value = get_node_or_null("OverHeatPanel/VBoxContainer3/OverHeatValue")
```

**Status**: ✅ ALREADY IMPLEMENTED

**Key Points**:
- Gets references to the UI elements from the scene
- Uses `get_node_or_null()` for safety
- Elements are children of OverHeatPanel in the scene

---

### Section 4: Signal Handler (Lines 181-214)

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

**Status**: ✅ ALREADY IMPLEMENTED

**Key Points**:
- Lines 184-189: Null checks for safety
- Line 192: Updates bar value (0-100)
- Line 195: Updates text label "XX/100"
- Lines 198-206: Color gradient calculation and application
- Lines 209-214: Label color changes at heat thresholds

---

## main.gd - Critical Fix

### UI Preload (Line 8)

```gdscript
var enemy_scene: PackedScene = preload("res://basic_virus.tscn")
var ui_scene: PackedScene = preload("res://ui/hallucination_ui.tscn")
var cpu_hud_scene: PackedScene = preload("res://ui/cpu_hud.tscn")
var h_ui: CanvasLayer
var status_ui: CanvasLayer
var cpu_hud: CanvasLayer
```

**Status**: ✅ IMPLEMENTED (was missing, now added)

**Key Points**:
- Line 8: Preloads the CPU HUD scene
- Without this, the scene is never instantiated
- This is the critical fix that enables the entire UI

---

## Signal Flow Diagram

```
┌──────────────────────────────────────────────────────────┐
│                    SIGNAL FLOW                           │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Player._physics_process() (every frame)                │
│    ├─ Calculate: is_generating && current_cpu >= 100%   │
│    ├─ Update: overheat (fill or decay)                  │
│    ├─ Check: overheat >= 100% → die()                   │
│    └─ EMIT: overheat_updated.emit(overheat)             │
│           │                                              │
│           ↓ (Signal passes float value)                  │
│           │                                              │
│  CPUHUD._on_overheat_updated(overheat_val: float)       │
│    ├─ Update: overheat_bar.value = overheat_val         │
│    ├─ Update: overheat_value.text = "XX/100"            │
│    ├─ Calculate: color = Yellow.lerp(Red, ratio)        │
│    ├─ Apply: overheat_bar fill color                    │
│    └─ Apply: overheat_label text color                  │
│           │                                              │
│           ↓ (UI updated every frame)                     │
│           │                                              │
│  Screen Display Updates                                  │
│    ├─ Bar fills from Yellow → Orange → Red              │
│    ├─ Text shows "XX/100"                               │
│    └─ Label color matches heat level                    │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Type Safety Verification

### Signal Definition (player.gd, line 66)
```gdscript
signal overheat_updated(value: float)
```

### Signal Emission (player.gd, line 222)
```gdscript
overheat_updated.emit(overheat)  // overheat is float
```

### Signal Handler (cpu_hud.gd, line 181)
```gdscript
func _on_overheat_updated(overheat_val: float) -> void:
```

### Signal Connection (cpu_hud.gd, line 48)
```gdscript
player.overheat_updated.connect(_on_overheat_updated)
```

**Type Safety**: ✅ COMPLETE
- Signal emits `float`
- Handler receives `float`
- No type mismatches

---

## Summary Table

| Component | File | Lines | Status |
|-----------|------|-------|--------|
| Overheat Variables | player.gd | 48-58 | ✅ IMPLEMENTED |
| Overheat Signal | player.gd | 66 | ✅ IMPLEMENTED |
| Input Tracking | player.gd | 224-236 | ✅ IMPLEMENTED |
| Physics Logic | player.gd | 199-222 | ✅ IMPLEMENTED |
| Signal Connection | cpu_hud.gd | 48 | ✅ IMPLEMENTED |
| UI Initialization | cpu_hud.gd | 84-86 | ✅ IMPLEMENTED |
| Signal Handler | cpu_hud.gd | 181-214 | ✅ IMPLEMENTED |
| CPU HUD Preload | main.gd | 8 | ✅ IMPLEMENTED |

---

## Key Takeaways

1. **The Magic Condition** (player.gd line 204)
   ```gdscript
   if current_cpu >= max_cpu_cycles and is_generating:
   ```
   This is what makes it anti-spam!

2. **Input Tracking** (player.gd lines 230, 234)
   ```gdscript
   is_generating = event.pressed  // Track press AND release
   ```
   Captures both key down and key up events.

3. **Signal Every Frame** (player.gd line 222)
   ```gdscript
   overheat_updated.emit(overheat)  // Smooth updates
   ```
   Ensures UI updates smoothly every frame.

4. **Color Feedback** (cpu_hud.gd lines 199-206)
   ```gdscript
   var overheat_color: Color = Color.YELLOW.lerp(Color.RED, color_ratio)
   ```
   Clear visual indication of heat level.

5. **Critical Fix** (main.gd line 8)
   ```gdscript
   var cpu_hud_scene: PackedScene = preload("res://ui/cpu_hud.tscn")
   ```
   Ensures UI loads at startup.

---

## Verification Checklist

- [x] All code sections implemented
- [x] All signals defined and connected
- [x] All type hints in place
- [x] Error handling present
- [x] Comments explain intent
- [x] No breaking changes
- [x] Ready for deployment

---

**Implementation Status**: ✅ **COMPLETE**  
**All Relevant Code**: ✅ **SHOWN ABOVE**  
**Ready to Deploy**: ✅ **YES**
