# OverHeat UI Fix - Exact Line-by-Line Changes

## File: res://ui/cpu_hud.gd

### Change 1: Add Cached StyleBox Variable
**Location**: Line 21 (after line 20)

```gdscript
# ADDED THIS LINE:
var overheat_fill_stylebox: StyleBoxFlat = null  # Cache StyleBox to avoid creating new ones every frame
```

**Full context** (lines 17-27):
```gdscript
# OverHeat panel references - Will be initialized in _ready() to handle runtime instantiation
var overheat_label: Label = null
var overheat_bar: ProgressBar = null
var overheat_value: Label = null
var overheat_fill_stylebox: StyleBoxFlat = null  # ← NEW: Cache to avoid creating new ones every frame

# Controls panel references - Will be initialized in _ready() to handle runtime instantiation
var controls_panel: Control = null
var options_panel: Control = null
var fullscreen_button: CheckButton = null
var resolution_option: OptionButton = null
```

---

### Change 2: Initialize StyleBox in _ready()
**Location**: Lines 62-65 (within overheat bar initialization block)

**BEFORE** (original code):
```gdscript
# Initialize overheat bar (with null check)
if overheat_bar:
    overheat_bar.max_value = player.overheat_max
    overheat_bar.value = player.overheat
    print("Overheat bar initialized: max=", overheat_bar.max_value)
else:
    print("ERROR: overheat_bar is null!")
```

**AFTER** (with fix):
```gdscript
# Initialize overheat bar (with null check)
if overheat_bar:
    overheat_bar.max_value = player.overheat_max
    overheat_bar.value = player.overheat
    # Create the fill StyleBox once to avoid recreating it every frame
    overheat_fill_stylebox = StyleBoxFlat.new()
    overheat_fill_stylebox.bg_color = Color.YELLOW
    overheat_bar.add_theme_stylebox_override("fill", overheat_fill_stylebox)
    print("Overheat bar initialized: max=", overheat_bar.max_value)
else:
    print("ERROR: overheat_bar is null!")
```

**What changed**: Added 4 lines inside the if block to create and assign the StyleBox once.

---

### Change 3: Update _on_overheat_updated() Function
**Location**: Lines 185-213 (entire function replacement)

**BEFORE** (original code):
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
	var fill_stylebox := StyleBoxFlat.new()  # ❌ Creates new object every frame
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

**AFTER** (with fix):
```gdscript
func _on_overheat_updated(overheat_val: float) -> void:
	"""Update overheat bar with color gradient from yellow to red."""
	# Validate that UI elements are initialized
	if not overheat_bar or not overheat_value or not overheat_label or not overheat_fill_stylebox:
		print("ERROR: Overheat UI elements not initialized!")
		print("  overheat_bar: ", overheat_bar)
		print("  overheat_value: ", overheat_value)
		print("  overheat_label: ", overheat_label)
		print("  overheat_fill_stylebox: ", overheat_fill_stylebox)
		return
	
	# Update bar value
	overheat_bar.value = overheat_val
	
	# Update value label text
	overheat_value.text = "%d/100" % int(overheat_val)
	
	# Color gradient: Yellow (0%) -> Orange -> Red (100%)
	# Update the cached StyleBox color instead of creating a new one every frame
	var color_ratio: float = overheat_val / 100.0
	overheat_fill_stylebox.bg_color = Color.YELLOW.lerp(Color.RED, color_ratio)
	
	# Change label color intensity based on heat level
	if overheat_val >= 75.0:
		overheat_label.add_theme_color_override("font_color", Color.RED)
	elif overheat_val >= 50.0:
		overheat_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.0))  # Orange
	else:
		overheat_label.add_theme_color_override("font_color", Color.YELLOW)
```

**What changed**:
1. Line 188: Added `or not overheat_fill_stylebox` to validation check
2. Line 193: Added print statement for overheat_fill_stylebox debugging
3. Lines 201-205: Removed `var overheat_color` creation and direct `add_theme_stylebox_override()` call
4. Line 204-205: Just update the cached StyleBox's color property
5. Removed 2 lines that created and assigned the new StyleBoxFlat (lines 208-210 in original)

---

## Summary of Changes

| Change | Type | Lines | Impact |
|--------|------|-------|--------|
| 1. Add cached variable | Addition | +1 line | Enables caching strategy |
| 2. Initialize in _ready() | Addition | +4 lines | Creates StyleBox once |
| 3. Update function logic | Modification | -3 lines, +1 line | Just updates cached color |

**Net result**: +2 lines of code, 60 fewer StyleBoxFlat allocations per second at 60 FPS

---

## How to Apply These Changes

If you want to apply these manually:

1. **Open** `res://ui/cpu_hud.gd` in the editor
2. **Add** the variable at line 21
3. **Add** the initialization code in the overheat bar setup (around line 59)
4. **Replace** the `_on_overheat_updated()` function (around line 185)
5. **Save** the file
6. **Test** in game with Q or Right Mouse Button

## Verification Checklist

After applying changes, verify:

- [ ] File saves without syntax errors
- [ ] Game loads without errors
- [ ] CPUHUD prints initialization messages
- [ ] Overheat bar exists at bottom-center of screen
- [ ] Hold Q/RMB to generate CPU until 100%
- [ ] Keep holding - overheat bar fills smoothly
- [ ] Bar color changes: Yellow → Orange → Red
- [ ] Label text color changes: Yellow → Orange → Red
- [ ] Release key - overheat decays back to 0
- [ ] No jank or visual glitches
- [ ] Performance is smooth

All checks should pass! ✅
