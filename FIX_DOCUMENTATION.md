# Parse Error Fix: Undeclared Identifiers in main.gd

## Error Summary

**Error:** `Identifier "cpu_hud_scene" not declared in the current scope`  
**File:** `res://main.gd`, lines 26–28  
**Impact:** Game would not run — GDScript parse error prevented script loading entirely.

---

## Root Cause

The variables `cpu_hud_scene` and `cpu_hud` were **used before being declared** in the script. GDScript requires all member variables to be declared before they are referenced.

### The Problematic Code (Before Fix)

```gdscript
var h_ui: CanvasLayer
var status_ui: CanvasLayer
# ❌ cpu_hud_scene and cpu_hud are NOT declared here

func _ready() -> void:
    # ...
    if cpu_hud_scene:                          # Line 26: ❌ undeclared
        cpu_hud = cpu_hud_scene.instantiate()  # Line 27: ❌ undeclared
        add_child(cpu_hud)                     # Line 28: ❌ undeclared
```

The developer likely planned to add a CPU HUD scene but forgot to declare the variables that hold the scene reference (`cpu_hud_scene`) and the instantiated node (`cpu_hud`).

---

## The Fix

### After Fix

```gdscript
var h_ui: CanvasLayer
var status_ui: CanvasLayer
var cpu_hud_scene: PackedScene   # ✅ Declared (defaults to null)
var cpu_hud: CanvasLayer         # ✅ Declared (defaults to null)

func _ready() -> void:
    # ...
    if cpu_hud_scene:                          # ✅ Works — null check
        cpu_hud = cpu_hud_scene.instantiate()  # ✅ Variable exists
        add_child(cpu_hud)                     # ✅ Variable exists
```

Two lines were added (lines 10–11) to declare the missing variables:

| Variable | Type | Purpose |
|---|---|---|
| `cpu_hud_scene` | `PackedScene` | Holds a reference to a CPU HUD scene (to be preloaded/preloaded in the future) |
| `cpu_hud` | `CanvasLayer` | Holds the instantiated CPU HUD node after instantiation |

**Note:** Since `cpu_hud_scene` defaults to `null` (never assigned a `preload`), the `if cpu_hud_scene:` block will always evaluate to `false`, meaning the CPU HUD code is effectively dormant. This preserves the intent of the code for a future CPU HUD feature while eliminating the parse error.

---

## How to Prevent This Error

### 1. Always Declare Variables Before Use

In GDScript, every variable must be declared. A "use" includes reading, assigning, or checking the variable:

```gdscript
# ❌ WRONG — using an undeclared variable
func _ready() -> void:
    if my_var:               # ERROR: "my_var" not declared
        print("hello")

# ✅ CORRECT — declared first
var my_var: bool

func _ready() -> void:
    if my_var:
        print("hello")
```

### 2. Use Type Annotations Consistently

Always type-hint every `var` declaration. This catches type mismatches early:

```gdscript
var cpu_hud_scene: PackedScene   # ✅ typed
var cpu_hud: CanvasLayer         # ✅ typed
```

### 3. Check the Error Panel Frequently

The Godot editor shows parse errors in the **Output** panel. Check it:
- After writing new code
- After refactoring
- Before running the game

### 4. Use the Script Editor's Focus to Refresh Errors

If errors seem stale, click into the script editor — this forces GDScript to re-parse and update the error list.

### 5. For Planned Features, Use Stubs

When scaffolding code for a feature that isn't ready yet, declare the variables upfront even if they'll be `null`:

```gdscript
# Planned feature stub — safe because declarations exist
var future_scene: PackedScene   # null until feature is ready
var future_node: Node           # null until feature is ready

func _ready() -> void:
    if future_scene:  # This null check is safe
        future_node = future_scene.instantiate()
        add_child(future_node)
```

### 6. CI / Pre-Commit Hooks

If using version control, consider adding a GDScript validation step:
```bash
godot --headless --check-only --script res://main.gd
```
This can catch parse errors before they reach `main`.

---

## Checklist

- [x] Identified the parse error in `res://main.gd`
- [x] Declared missing variables `cpu_hud_scene` and `cpu_hud` with correct types
- [x] Verified the file is syntactically correct
- [x] Documented the fix and prevention strategies

---

*Document created by Ziva Agent — fix applied to `res://main.gd`*