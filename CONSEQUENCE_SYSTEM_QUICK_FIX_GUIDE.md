# Consequence System - Quick Fix Reference

## What Was Broken
**Symptom**: Game pauses at 100% overheat, but no UI popup appears. Game appears frozen.

## Root Cause
5 interconnected issues:
1. Popup instantiated from bare class instead of scene
2. Popup added to wrong parent (scene root instead of canvas layer)  
3. Buttons couldn't receive input while game paused
4. CPU HUD not discoverable by consequence engine
5. Missing scene file for proper UI management

## 5 Fixes Applied

### Fix #1: Created Scene File
**File**: `res://ui/consequence_popup.tscn` ✅ NEW
```
[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://ui/consequence_popup.gd" id="1_2abcd"]
[node name="ConsequencePopup" type="Control"]
```

### Fix #2: Enabled Input During Pause
**File**: `res://ui/consequence_popup.gd` (lines 26, 116, 133)
```gdscript
mouse_filter = Control.MOUSE_FILTER_STOP  # On popup container
movement_button.mouse_filter = Control.MOUSE_FILTER_STOP  # On buttons
blink_button.mouse_filter = Control.MOUSE_FILTER_STOP    # On buttons
focus_mode = Control.FOCUS_ALL  # Enable keyboard/gamepad
```

### Fix #3: Scene-Based Instantiation
**File**: `res://ui/consequence_engine.gd` (lines 9, 66)
```gdscript
# BEFORE (broken):
consequence_popup = ConsequencePopup.new()

# AFTER (fixed):
consequence_popup_scene: PackedScene = preload("res://ui/consequence_popup.tscn")
consequence_popup = consequence_popup_scene.instantiate() as ConsequencePopup
```

### Fix #4: Correct Parenting
**File**: `res://ui/consequence_engine.gd` (lines 72-74)
```gdscript
# BEFORE (broken):
get_tree().root.add_child(consequence_popup)

# AFTER (fixed):
if cpu_hud:
    cpu_hud.add_child(consequence_popup)  # Proper canvas layer parenting
```

### Fix #5: CPU HUD Discovery
**Files**: 
- `res://ui/cpu_hud.gd` (line 38)
```gdscript
add_to_group("cpuhud")  # Make discoverable
```

- `res://ui/consequence_engine.gd` (lines 20-26)
```gdscript
var hud_candidates: Array = get_tree().get_nodes_in_group("cpuhud")
if hud_candidates.size() > 0:
    cpu_hud = hud_candidates[0] as CanvasLayer
```

---

## Verification Checklist

### In Console Logs
```
✓ [CONSEQUENCE ENGINE] Successfully connected to overheat_critical signal!
✓ [CONSEQUENCE ENGINE] CPU HUD found: true
✓ [CONSEQUENCE ENGINE] Scene available: true
✓ [CONSEQUENCE ENGINE] Popup added to CPU HUD canvas layer
✓ [CONSEQUENCE POPUP] Movement button created and connected
✓ [CONSEQUENCE POPUP] Blink button created and connected
```

### In Game
```
✓ Meter fills to 100%
✓ Game pauses (no movement, enemies freeze)
✓ Dark red overlay appears on screen
✓ Popup with title and buttons appears
✓ Click buttons works (or gamepad selection)
✓ Game unpauses after selection
✓ Consequence applies (movement frozen or blink charged)
```

---

## If Still Broken

### Check 1: Scene File Exists
```gdscript
# In editor or script
var scene = preload("res://ui/consequence_popup.tscn")
if scene == null:
    print("ERROR: Scene file missing or invalid path!")
```

### Check 2: CPU HUD Group Membership
```gdscript
# Run in console or script
var huds = get_tree().get_nodes_in_group("cpuhud")
print("CPUHUDs found: ", huds.size())
for hud in huds:
    print("  - ", hud.name)
```

### Check 3: Process Modes
```gdscript
# Check popup node in running game
if get_tree().paused:
    var popup = get_node_or_null("path/to/popup")
    if popup:
        print("Popup process_mode: ", popup.process_mode)
        print("Popup mouse_filter: ", popup.mouse_filter)
```

### Check 4: Signal Connections
```gdscript
# Check in player node
var connections = overheat_critical.get_signal_connection_list()
print("Overheat critical connections: ", connections.size())
```

---

## Files to Check

| File | What It Does | Status |
|------|-------------|--------|
| `res://ui/consequence_popup.tscn` | Scene file | ✅ NEW |
| `res://ui/consequence_popup.gd` | Popup script | ✅ UPDATED |
| `res://ui/consequence_engine.gd` | Logic controller | ✅ UPDATED |
| `res://ui/cpu_hud.gd` | HUD container | ✅ UPDATED |
| `res://main.gd` | Scene setup | ⚠️ No change needed |

---

## Expected Behavior Timeline

1. **Game Running**: Overheat meter fills, game runs normally
2. **Meter → 99%**: Still playable
3. **Meter → 100%**: 
   - Game PAUSES immediately
   - Popup APPEARS on screen
   - Buttons RESPOND to input
4. **Button Click**: 
   - Popup DISAPPEARS
   - Consequence APPLIES
   - Game UNPAUSES
5. **Continue**: Overheat resets to 0%, can fill again

---

## Godot 4 Concepts Used

| Concept | Used For | Godot Docs |
|---------|----------|-----------|
| Process Modes | Execute during pause | [Docs](https://docs.godotengine.org/en/4.6/classes/class_node.html#property-process-mode) |
| Mouse Filter | Input during pause | [Docs](https://docs.godotengine.org/en/4.6/classes/class_control.html#property-mouse-filter) |
| Canvas Layers | UI rendering order | [Docs](https://docs.godotengine.org/en/4.6/tutorials/2d/canvas_layers.html) |
| Groups | Service discovery | [Docs](https://docs.godotengine.org/en/4.6/tutorials/scripting/groups.html) |
| Signals | Event system | [Docs](https://docs.godotengine.org/en/4.6/tutorials/scripting/gdscript/signals.html) |

---

## Support

### Questions?
- Check `CONSEQUENCE_SYSTEM_IMPLEMENTATION_SUMMARY.md` for detailed explanation
- Check `CONSEQUENCE_SYSTEM_FIXES.md` for before/after code
- Run `res://test_consequence_audit.gd` to validate setup

### Still Have Issues?
1. Enable verbose logging (already in place)
2. Check console output for error messages
3. Use debugging checklist above
4. Verify all 5 files have been updated
