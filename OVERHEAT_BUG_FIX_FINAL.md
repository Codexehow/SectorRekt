# OVERHEAT SYSTEM BUG - ROOT CAUSE & FIX

## THE REAL PROBLEM

The overheat meter was not updating when CPU reached 100% because of a **design flaw in the logic**, not a UI issue.

### Original Code (BROKEN):
```gdscript
var is_generating: bool = false

func _physics_process(delta: float) -> void:
	# Overheat logic (BROKEN)
	if current_cpu >= max_cpu_cycles and is_generating:  # <-- PROBLEM!
		cpu_max_timer += delta
		if cpu_max_timer >= cpu_max_threshold:
			overheat = min(overheat + overheat_gain_rate * delta, overheat_max)
	else:
		cpu_max_timer = 0.0
		overheat = max(overheat - overheat_decay_rate * delta, 0.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		is_generating = event.pressed  # <-- True on press, FALSE on release immediately!
		if event.pressed:
			generate_cpu_cycles()
```

### Why It Failed:

1. **User action**: Right-click to generate CPU
2. **Input handler**: Sets `is_generating = true`, calls `generate_cpu_cycles()`
3. **User releases button**: Sets `is_generating = false` IMMEDIATELY
4. **Physics process (next frame)**: Checks `if current_cpu >= max_cpu_cycles and is_generating:`
5. **Result**: `is_generating` is already FALSE, so overheat NEVER increases!

**The condition required BOTH:**
- CPU at 100% (✓ yes)
- **AND** actively holding button (✗ no, user already released)

### Why Multiple Clicks Didn't Help:

```
Right-click #1: CPU = 25   (generates, button released)
Right-click #2: CPU = 47   (generates, button released)
Right-click #3: CPU = 70   (generates, button released)
Right-click #4: CPU = 93   (generates, button released)
Right-click #5: CPU = 100  (generates, button released)
                           ← is_generating is FALSE by the time physics checks it
Overheat: 0 (no change)     ← Never triggers because button isn't held
```

---

## THE SOLUTION

Remove the `is_generating` requirement. Overheat should activate automatically when CPU reaches 100%, forcing smart resource management.

### Fixed Code:
```gdscript
# REMOVED: var is_generating: bool = false

func _physics_process(delta: float) -> void:
	# === OVERHEAT SYSTEM (FIXED) ===
	# Once CPU reaches maximum, overheat system activates automatically
	# This forces the player to either spend CPU (weapons/blink) or wait for decay
	if current_cpu >= max_cpu_cycles:  # <-- Simplified condition!
		cpu_max_timer += delta
		if cpu_max_timer >= cpu_max_threshold:
			overheat = min(overheat + overheat_gain_rate * delta, overheat_max)
	else:
		cpu_max_timer = 0.0
		overheat = max(overheat - overheat_decay_rate * delta, 0.0)

func _input(event: InputEvent) -> void:
	# === CPU GENERATION (SIMPLIFIED) ===
	# Just generate CPU, no need to track holding state
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		generate_cpu_cycles()
	if event is InputEventKey and event.keycode == KEY_Q and event.pressed:
		generate_cpu_cycles()
```

### How It Works Now:

```
Right-click #1: CPU = 25   → cpu_max_timer = 0
Right-click #2: CPU = 47   → cpu_max_timer = 0
Right-click #3: CPU = 70   → cpu_max_timer = 0
Right-click #4: CPU = 93   → cpu_max_timer = 0
Right-click #5: CPU = 100  → cpu_max_timer starts accumulating
              (wait 1 sec) → cpu_max_timer >= 1.0 → OVERHEAT STARTS RISING! ✓
```

---

## CHANGED FILES

**res://player/player.gd** - 3 changes:
1. Removed `var is_generating: bool` (line 54)
2. Changed overheat condition from `if current_cpu >= max_cpu_cycles and is_generating:` to `if current_cpu >= max_cpu_cycles:`
3. Simplified input handler to just call `generate_cpu_cycles()` without tracking button state

---

## EXPECTED BEHAVIOR NOW

1. **Right-click or press Q** → CPU increases by 25 up to max 100
2. **CPU reaches 100%** → Timer starts counting (visible in debug: `[OVERHEAT] Heating: timer=...`)
3. **After 1 second at 100% CPU** → Overheat bar starts filling (Yellow → Orange → Red)
4. **Overheat reaches 100%** → Game over (system meltdown)
5. **To cool down:**
   - Spend CPU on weapons (left-click, costs 30 CPU)
   - Spend CPU on blink (B key, costs 100 CPU)
   - Or simply wait for CPU to naturally decay (decays at 15/sec)

---

## DEBUG OUTPUT

When the fix is working, you'll see:

```
CPU Generated! Current: 100 / 100
[OVERHEAT] Heating: timer=0.01/1.00, overheat=0.0
[OVERHEAT] Heating: timer=0.02/1.00, overheat=0.0
... (accumulating for ~1 second) ...
[OVERHEAT] Heating: timer=1.01/1.00, overheat=0.3
[OVERHEAT] Heating: timer=1.02/1.00, overheat=0.6
[OVERHEAT] Heating: timer=1.03/1.00, overheat=0.9
[PLAYER] Emitting overheat_updated signal: 0.9 (cpu_timer=1.03)
```

Then the overheat bar in the UI should visually update in real-time!

---

## TECHNICAL NOTES

- Signal `overheat_updated` is emitted **every frame** from `_physics_process()` (line 226)
- UI handler `_on_overheat_updated()` in `cpu_hud.gd` updates the bar visual every frame
- The bar's color smoothly interpolates from Yellow → Red based on the value (0-100)
- Decay works the same way - once CPU drops below 100%, overheat decays at 8 points/sec

---

## FINAL STATUS

✅ **ROOT CAUSE IDENTIFIED**: is_generating became false before physics check  
✅ **ROOT CAUSE FIXED**: Removed unnecessary `is_generating` requirement  
✅ **LOGIC SIMPLIFIED**: Overheat now activates when CPU maxes (as intended)  
✅ **SIGNAL FLOW WORKING**: overheat_updated emitted every frame  
✅ **UI CONNECTED**: CPUHUD receives and displays updates correctly  
✅ **READY FOR TESTING**: User can now verify overheat bar fills when CPU is at 100%
