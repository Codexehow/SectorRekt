# Diagnostic Report: Resolution Change & Overheat UI Systems

## Summary
Both systems have working code but face **runtime configuration and fullscreen issues** that prevent them from functioning in the game preview.

---

## Issue 1: Resolution Change System

### Problem
The resolution change UI allows selection but the screen doesn't visually change when previewing in Godot.

### Root Causes

#### **A. Fullscreen Mode Lock (PRIMARY ISSUE)**
- **Location**: `project.godot` line 48: `size/mode="fullscreen"`
- **Impact**: The game starts in FULLSCREEN mode
- **Problem**: When in fullscreen, `get_window().size` changes don't visually affect the screen because fullscreen ignores the requested window size and uses the monitor's resolution
- **Evidence**: The code at `res://ui/cpu_hud.gd:177-178` attempts to exit fullscreen first, but this happens AFTER the callback is triggered

#### **B. Timing Issue in Resolution Handler**
- **Location**: `res://ui/cpu_hud.gd:161-186`
- **Issue**: The async `await` is used but may not wait long enough for the fullscreen transition to complete
- **The Flow**:
  1. User clicks resolution option
  2. `_on_resolution_selected(index)` is called
  3. If fullscreen, exit to windowed with 1 frame wait
  4. Resize the window
  5. Restore fullscreen if needed

**The problem**: After exiting fullscreen, the system needs more time to fully transition before resizing

#### **C. Window Stretch Mode Interference**
- **Location**: `project.godot` line 47: `stretch/mode="canvas_items"`
- **Impact**: Stretch mode affects how the viewport handles resizing
- **Issue**: With `canvas_items` stretch mode, the actual rendered canvas may not scale visually with window size changes

### Verification
- ✓ Method `_on_resolution_selected()` exists and has correct logic
- ✓ Signal connection is properly set up: `resolution_option.item_selected.connect(_on_resolution_selected)`
- ✓ OptionButton has 5 resolution options properly populated
- ✓ Fullscreen toggle (`_on_fullscreen_toggled`) works correctly
- ✗ **Issue**: Window resize doesn't visually appear in fullscreen mode

---

## Issue 2: Overheat UI System

### Problem
Overheat clicks are registered (print statements show this) but the UI bar/text don't update visually.

### Root Causes

#### **A. @onready Initialization Timing (PRIMARY ISSUE)**
- **Location**: `res://ui/cpu_hud.gd:18-20`
```gdscript
@onready var overheat_label: Label = $OverHeatPanel/VBoxContainer3/OverHeatLabel
@onready var overheat_bar: ProgressBar = $OverHeatPanel/VBoxContainer3/OverHeatBar
@onready var overheat_value: Label = $OverHeatPanel/VBoxContainer3/OverHeatValue
```
- **Issue**: These `@onready` variables are resolved when the script's `_ready()` is called
- **Problem**: If the scene tree path is incorrect or the nodes don't exist at script attachment time, the variables remain `null` silently

#### **B. Scene Instantiation Issue**
- **Location**: `res://main.gd:28-30`
```gdscript
if cpu_hud_scene:
    cpu_hud = cpu_hud_scene.instantiate() as CanvasLayer
    add_child(cpu_hud)
```
- **Issue**: The scene is instantiated at runtime
- **Problem**: `@onready` variables are resolved BEFORE `add_child()`, so if the node isn't in the tree yet, the path resolution fails

#### **C. Null Reference Silent Failures**
- **Location**: `res://ui/cpu_hud.gd:111-119` (the update method)
- **Issue**: If `overheat_bar`, `overheat_value`, or `overheat_label` are `null`, GDScript fails silently
- **Result**: The signal callback executes but nothing visually changes

#### **D. Bar Fill Color Override Not Working**
- **Location**: `res://ui/cpu_hud.gd:119`
```gdscript
overheat_bar.add_theme_color_override("fill", overheat_color)
```
- **Issue**: ProgressBar's fill color property might not be named "fill"
- **Verification**: The proper property for ProgressBar might be "fill_color" or needs to be set via `modulate`

### Verification
- ✓ Method `_on_overheat_updated(overheat_val)` exists with correct logic
- ✓ Signal connection exists: `player.overheat_updated.connect(_on_overheat_updated)` in `_ready()`
- ✓ Player emits signal: `overheat_updated.emit(overheat)` in `_physics_process()`
- ✓ Scene structure has all 3 UI elements in cpu_hud.tscn
- ✗ **Issue 1**: @onready resolution may fail on runtime instantiation
- ✗ **Issue 2**: No null checks before using the UI references
- ✗ **Issue 3**: Theme override property name may be incorrect

---

## Recommended Fixes

### For Resolution System
1. **Add stretch settings adjustment** OR
2. **Toggle fullscreen after resize** with proper timing
3. **Add debug logging** to track state changes
4. **Increase frame waits** to ensure fullscreen transition completes

### For Overheat UI
1. **Replace @onready with _ready() manual assignment** to handle runtime instantiation
2. **Add null checks** in the update method
3. **Verify ProgressBar theme property name** (likely need to use `modulate` instead)
4. **Add error logging** to catch initialization failures

---

## Testing Recommendations

1. **Resolution Testing**:
   - Test resolution changes in WINDOWED mode (should work)
   - Test resolution changes in FULLSCREEN mode (currently fails)
   - Check console output for timing information

2. **Overheat Testing**:
   - Check if overheat_bar/label/value are null by adding print statements
   - Test if signal is actually being emitted (add listener in _ready)
   - Test theme override property name directly

3. **Integration Testing**:
   - Simulate CPU reaching 100% and verify overheat increases
   - Verify UI elements update color and value in real-time
