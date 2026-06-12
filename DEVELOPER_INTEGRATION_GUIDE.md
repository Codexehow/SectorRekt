# CPU Cycles System - Developer Integration Guide

## Overview

The CPU Cycles System is fully implemented and ready for integration with your UI and game systems. This guide walks you through connecting it to your existing systems.

---

## 1. UI Integration (ProgressBars)

### Step 1: Create UI Bars in Your Scene

Create a scene with 4 ProgressBar nodes. Example structure:

```
Control (Panel or VBox)
├── CPU_Bar (ProgressBar)
├── Weapon_Bar (ProgressBar)
├── Shield_Bar (ProgressBar)
└── Blink_Bar (ProgressBar)
```

### Step 2: Configure Each Bar

```gdscript
# For each ProgressBar:
bar.min_value = 0.0
bar.max_value = 1.0  # Use 0-1 range (we'll normalize)
bar.step = 0.01
bar.value = 0.0
```

### Step 3: Connect the Signal

In your UI Manager or main scene, connect the signal:

```gdscript
extends Control

@onready var cpu_bar: ProgressBar = $CPU_Bar
@onready var weapon_bar: ProgressBar = $Weapon_Bar
@onready var shield_bar: ProgressBar = $Shield_Bar
@onready var blink_bar: ProgressBar = $Blink_Bar

func _ready() -> void:
    var player: Player = get_tree().get_first_node_in_group("player")
    if player:
        player.cpu_updated.connect(_on_cpu_updated)

func _on_cpu_updated(current: float, weapon: float, shield: float, blink: float) -> void:
    cpu_bar.value = current / 100.0
    weapon_bar.value = weapon / 100.0
    shield_bar.value = shield / 100.0
    blink_bar.value = blink / 100.0
```

### Step 4 (Optional): Add Visual Feedback

```gdscript
func _on_cpu_updated(current: float, weapon: float, shield: float, blink: float) -> void:
    # Update bar values
    cpu_bar.value = current / 100.0
    weapon_bar.value = weapon / 100.0
    shield_bar.value = shield / 100.0
    blink_bar.value = blink / 100.0
    
    # Add color changes based on charge level
    if weapon >= 30.0:
        weapon_bar.modulate = Color.GREEN
    else:
        weapon_bar.modulate = Color.RED
    
    if blink >= 100.0:
        blink_bar.modulate = Color.BLUE
    else:
        blink_bar.modulate = Color.GRAY
    
    # Pulse effect when ready
    if weapon >= 30.0 and not is_instance_valid(weapon_tween):
        weapon_tween = create_tween()
        weapon_tween.set_loops()
        weapon_tween.tween_property(weapon_bar, "modulate", Color.YELLOW, 0.3)
        weapon_tween.tween_property(weapon_bar, "modulate", Color.GREEN, 0.3)
```

---

## 2. Hallucination Integration

### Connect Corruption Events

```gdscript
# In HallucinationManager or similar
extends Node

func _ready() -> void:
    var player: Player = get_tree().get_first_node_in_group("player")
    if player:
        player.hallucination_triggered.connect(_on_hallucination)

func _on_hallucination(type: String = "glitch") -> void:
    print("Hallucination triggered: ", type)
    # Implement your glitch effects here
    apply_screen_glitch()
    apply_audio_distortion()
    trigger_visual_corruption()
```

### Listen to Corrupted Mode Changes

```gdscript
# Add this to your game loop to monitor corrupted mode
var player: Player = get_tree().get_first_node_in_group("player")

if player.is_corrupted:
    # Apply corruption effects
    pass
else:
    # Remove corruption effects
    pass
```

---

## 3. Gameplay System Integration

### Check CPU Levels in Gameplay

```gdscript
# In any system that cares about CPU status
var player: Player = get_tree().get_first_node_in_group("player")

# Check if player has weapon charge
if player.weapon_charge >= 30.0:
    # Player can fire
    pass

# Check if player has blink ready
if player.blink_charge >= 100.0:
    # Player can teleport
    pass

# Check movement bonus
var speed_multiplier: float = 1.0 + (player.current_cpu / 100.0) * 0.10
# Use speed_multiplier for gameplay calculations
```

### React to Weapon Firing

The weapon firing is already handled by `fire_thunderbolt()` in the player script. It:
1. Creates a projectile from `res://projectile.tscn`
2. Positions it at the weapon muzzle
3. Sets its direction toward the mouse
4. Adds it to the scene

No additional integration needed unless you want to add visual/audio feedback.

### React to Blink Teleportation

The blink is already handled by `blink_drive()`. It:
1. Teleports the player 150 pixels forward
2. Resets blink charge to 0

Add visual feedback if desired:

```gdscript
# In player.gd or override in a subclass
func blink_drive() -> void:
    var old_pos: Vector2 = global_position
    
    # Original teleport
    print("BLINK DRIVE ACTIVATED - Teleport forward!")
    var blink_distance: float = 150.0
    var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
    global_position += direction * blink_distance
    blink_charge = 0.0
    
    # Add effects
    create_teleport_effect(old_pos)
    create_teleport_effect(global_position)
    play_blink_sound()
```

---

## 4. Save/Load System Integration

### Save CPU State

```gdscript
# When saving game
var player_data: Dictionary = {
    "cpu": player.current_cpu,
    "weapon": player.weapon_charge,
    "shield": player.shield_charge,
    "blink": player.blink_charge,
    "corrupted": player.is_corrupted,
}
save_file.write("player", player_data)
```

### Load CPU State

```gdscript
# When loading game
var player_data: Dictionary = save_file.read("player")
player.current_cpu = player_data.get("cpu", 0.0)
player.weapon_charge = player_data.get("weapon", 0.0)
player.shield_charge = player_data.get("shield", 0.0)
player.blink_charge = player_data.get("blink", 0.0)
player.is_corrupted = player_data.get("corrupted", false)
```

---

## 5. Difficulty Scaling Integration

### Adjust Generation Based on Difficulty

```gdscript
# In difficulty manager
var player: Player = get_tree().get_first_node_in_group("player")

match current_difficulty:
    Difficulty.EASY:
        player.cpu_generation_rate = 45.0  # Easier to generate
        player.max_cpu_cycles = 150.0      # Larger pool
    Difficulty.NORMAL:
        player.cpu_generation_rate = 35.0
        player.max_cpu_cycles = 100.0
    Difficulty.HARD:
        player.cpu_generation_rate = 25.0  # Harder to generate
        player.max_cpu_cycles = 80.0
    Difficulty.EXPERT:
        player.cpu_generation_rate = 15.0
        player.max_cpu_cycles = 60.0
```

---

## 6. Stat Tracking Integration

### Track Usage for Analytics

```gdscript
# In stats manager
extends Node

class_name StatsTracker

var total_cpu_generated: float = 0.0
var total_shots_fired: int = 0
var total_blinks_used: int = 0
var weapon_efficiency: float = 0.0  # Accuracy tracking

func _ready() -> void:
    var player: Player = get_tree().get_first_node_in_group("player")
    if player:
        player.cpu_updated.connect(_on_cpu_updated)

func _on_cpu_updated(current: float, weapon: float, shield: float, blink: float) -> void:
    # Track generation
    if current > 0:
        total_cpu_generated += current * get_physics_process_delta_time()
    
    # Track weapon usage (call from projectile system)
    # total_shots_fired += 1
    
    # Track blink usage
    # total_blinks_used += 1
```

---

## 7. Testing Checklist for Integration

### UI Integration Tests

- [ ] CPU bar updates in real-time
- [ ] Weapon bar shows correct charge (50% allocation)
- [ ] Shield bar shows correct charge (30% allocation)
- [ ] Blink bar shows correct charge (10% allocation)
- [ ] All bars cap at 1.0 (100%)
- [ ] All bars floor at 0.0 (0%)
- [ ] Signal emits every frame
- [ ] No memory leaks or performance issues
- [ ] Colors update correctly based on charge
- [ ] Animations work smoothly

### Gameplay Integration Tests

- [ ] Weapon fires when charged (≥30)
- [ ] Weapon fires toward mouse cursor
- [ ] Projectiles spawn at weapon muzzle
- [ ] Blink teleports when fully charged (=100)
- [ ] Blink teleports in correct direction
- [ ] Blink distance is 150 pixels
- [ ] Player can still move while charging
- [ ] Movement bonus applies correctly
- [ ] Corrupted mode toggle works
- [ ] No conflicts with existing systems

### Edge Case Tests

- [ ] CPU caps at 100 when generating
- [ ] CPU floors at 0 when decaying
- [ ] Weapon can't fire below 30 cycles
- [ ] Blink can't activate below 100 cycles
- [ ] Multiple inputs don't cause conflicts
- [ ] Signals don't cause crashes
- [ ] Scene unloads without errors
- [ ] Rapid inputs handled correctly

---

## 8. Troubleshooting

### Signal Not Connecting?

```gdscript
# Verify player exists in scene
var player: Player = get_tree().get_first_node_in_group("player")
if not player:
    print("ERROR: Player not found in scene!")
else:
    print("Player found, connecting signal...")
    player.cpu_updated.connect(_on_cpu_updated)

# Verify signal handler exists
if not has_method("_on_cpu_updated"):
    print("ERROR: _on_cpu_updated method not found!")
```

### Bars Not Updating?

```gdscript
# Check if signal is emitting
func _on_cpu_updated(current: float, weapon: float, shield: float, blink: float) -> void:
    print("Signal received: CPU=%f, Weapon=%f, Shield=%f, Blink=%f" % [current, weapon, shield, blink])
    # Your update code here
```

### Weapon Not Firing?

```gdscript
# Check weapon charge in console
var player: Player = get_tree().get_first_node_in_group("player")
print("Weapon charge: ", player.weapon_charge)
print("Can fire: ", player.weapon_charge >= 30.0)

# Check projectile scene exists
if not ResourceLoader.exists("res://projectile.tscn"):
    print("ERROR: projectile.tscn not found!")
```

### Blink Not Working?

```gdscript
# Check blink charge
var player: Player = get_tree().get_first_node_in_group("player")
print("Blink charge: ", player.blink_charge)
print("Can blink: ", player.blink_charge >= 100.0)

# Check if B key is being processed
Input.action_press("ui_b")  # Simulate B key press
```

---

## 9. Performance Optimization Tips

### Monitor Signal Emissions

```gdscript
# Only update UI when values change significantly
var last_cpu: float = 0.0

func _on_cpu_updated(current: float, weapon: float, shield: float, blink: float) -> void:
    # Only update if change > 1 cycle
    if abs(current - last_cpu) > 1.0:
        cpu_bar.value = current / 100.0
        last_cpu = current
    
    # Always update on significant changes
    if weapon != last_weapon:
        weapon_bar.value = weapon / 100.0
        last_weapon = weapon
```

### Batch UI Updates

```gdscript
# Group bar updates in a single call
func _on_cpu_updated(current: float, weapon: float, shield: float, blink: float) -> void:
    if Engine.get_frames_drawn() % 2 == 0:  # Update every other frame
        update_all_bars(current, weapon, shield, blink)
```

---

## 10. Future Expansion Points

### Where to Add Shield Impact Logic

```gdscript
# In an extended Player script
func take_damage(amount: float) -> float:
    var reduced_amount: float = amount
    
    # Shield reduces damage
    if shield_charge > 0:
        var absorbed: float = min(shield_charge, amount)
        shield_charge -= absorbed
        reduced_amount = amount - absorbed
    
    # Remaining damage hits health
    health -= reduced_amount
    
    return reduced_amount
```

### Where to Add Life Support Mechanics

```gdscript
# In game loop
func _physics_process(delta: float) -> void:
    # ... existing code ...
    
    # Life support regenerates health
    if current_cpu > 0 and life_support_charge > 0:
        health = min(health + (life_support_charge * 0.1 * delta), max_health)
```

### Where to Add Manual Allocation Override

```gdscript
# Player can manually override allocation percentages
var weapon_alloc_override: float = -1.0  # -1 means use default
var shield_alloc_override: float = -1.0

func get_weapon_allocation() -> float:
    return weapon_alloc_override if weapon_alloc_override >= 0 else WEAPON_ALLOC

func set_weapon_allocation(value: float) -> void:
    weapon_alloc_override = clamp(value, 0.0, 1.0)
```

---

## 11. Quick Integration Checklist

- [ ] UI bars created and connected
- [ ] cpu_updated signal receiving correctly
- [ ] Corruption effects implemented
- [ ] Weapon firing visual feedback added
- [ ] Blink teleport visual feedback added
- [ ] Stat tracking integrated
- [ ] Save/load system updated
- [ ] Difficulty scaling considered
- [ ] All tests passing
- [ ] Performance optimized
- [ ] Documentation updated
- [ ] Team informed of system

---

## Support & Questions

If you encounter issues:

1. **Check the signal**: Verify `cpu_updated` is emitting
2. **Check the scene**: Verify Player is in scene with "player" group
3. **Check the method**: Verify your handler is properly typed
4. **Check the logs**: Print debug information to console
5. **Review documentation**: Check CPU_SYSTEM_QUICK_REFERENCE.md

---

**Integration Status**: Ready for Implementation
**Documentation**: Comprehensive
**Support**: Available in code comments
**Version**: 1.0
