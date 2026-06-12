# Player Damage System Implementation

## Overview
A complete damage system has been added to the Player class, featuring dual-layer defense with **Shields** (absorb damage first) and **Hull** (main health). The system includes damage from walls and enemies.

---

## Features Implemented

### 1. **Health & Shield Variables** (player.gd, lines 31-36)
```gdscript
@export var max_hull: float = 100.0
@export var max_shield: float = 100.0

var current_hull: float = 100.0
var current_shield: float = 100.0
```
- **max_hull**: Maximum health points (default: 100)
- **max_shield**: Maximum shield points (default: 100)
- Both are initialized in `_ready()`

---

### 2. **Core Damage Function** (player.gd, lines 54-73)
```gdscript
func take_damage(amount: float, source: String = "unknown") -> void:
```

**Logic:**
1. Shields absorb damage FIRST
2. If damage exceeds shield capacity, remainder damages hull
3. If hull reaches 0, player dies
4. Emits `player_damaged` signal with current hull/shield values

**Example Behavior:**
- Shield 50 / Hull 100 + 30 damage → Shield 20 / Hull 100
- Shield 30 / Hull 100 + 50 damage → Shield 0 / Hull 80
- Shield 0 / Hull 100 + 50 damage → Shield 0 / Hull 50

---

### 3. **Wall Collision Damage** (player.gd, lines 128-137)
```gdscript
# === WALL DAMAGE (sliding against walls) ===
if get_slide_collision_count() > 0:
    for i in range(get_slide_collision_count()):
        var collision: KinematicCollision2D = get_slide_collision(i)
        var collider: Node = collision.get_collider()
        if collider is TileMapLayer or (collider is StaticBody2D):
            take_damage(0.5 * delta, "wall")
```

- **Detects**: Collisions with TileMapLayer (world walls) and StaticBody2D
- **Damage Rate**: 0.5 HP per second while sliding
- **Continuous**: Applies every physics frame while in contact

---

### 4. **Enemy Collision Damage** (player.gd, lines 172-178)
```gdscript
func _on_body_entered(body: Node2D) -> void:
    """Handle collision damage from enemies."""
    if body.is_in_group("enemies"):
        take_damage(25.0, "enemy")
        apply_shake(5.0)  # Visual feedback
        print("Player hit by enemy!")
```

- **Detection**: Area2D "DamageZone" node detects body_entered signals
- **Damage**: 25 HP per enemy touch
- **Feedback**: Triggers camera shake for visual impact
- **Requirements**: Enemy must be in "enemies" group

---

### 5. **Signals**
```gdscript
signal player_damaged(hull: float, shield: float)  # Emitted after any damage
signal player_died                                  # Emitted when hull <= 0
```

**Usage in UI:**
```gdscript
player.player_damaged.connect(func(hull, shield):
    update_health_ui(hull, shield)
)
```

---

## Scene Structure (player.tscn)

The Player scene now includes:
```
Player (CharacterBody2D)
├── AnimatedSprite2D
├── CollisionShape2D (movement/physics)
├── Camera2D
├── PointLight2D
├── WeaponPivot
│   ├── Sprite2D
│   └── Muzzle
└── DamageZone (Area2D) ← NEW
    └── CollisionShape2D (radius 30)
        └── [signal] body_entered → _on_body_entered()
```

**DamageZone Details:**
- Type: Area2D
- Collision Shape: Circle with radius 30
- Purpose: Detects when enemies touch the player
- Signal: `body_entered` → calls `_on_body_entered()`

---

## Integration Points

### For UI Systems
Listen to the `player_damaged` signal to update health bars:

```gdscript
func _ready() -> void:
    var player: Player = get_tree().get_first_node_in_group("player")
    player.player_damaged.connect(_on_player_damaged)

func _on_player_damaged(hull: float, shield: float) -> void:
    hull_bar.value = hull
    shield_bar.value = shield
```

### For Enemy AI
Enemies automatically deal damage when they touch the DamageZone. They just need:
1. To be in the "enemies" group (already done in enemy.gd)
2. To be a CharacterBody2D or PhysicsBody2D (already done)

### For Level Design
- Any TileMapLayer automatically damages the player while sliding
- Create walls using the existing TileMapLayer system
- Static walls should be StaticBody2D nodes with CollisionShape2D

---

## Testing

Run the validation script to test damage logic:
```gdscript
DamageSystemValidator.run_all_tests()
```

Or test manually:
1. Run the game
2. Enemy touches player → Player loses 25 HP
3. Player slides against walls → Gradual HP loss
4. Monitor console for debug prints

---

## Exportable Parameters

Adjust these in the Inspector for balance tuning:

| Parameter | Default | Purpose |
|-----------|---------|---------|
| `max_hull` | 100.0 | Player health |
| `max_shield` | 100.0 | Shield capacity |
| `base_speed` | 90.0 | Tank movement speed |
| (existing CPU, weapon, etc.) | - | - |

Wall damage rate: `0.5 * delta` (line 136) - Edit in code to adjust
Enemy damage: `25.0` (line 175) - Edit in code to adjust

---

## Debug Output

When damage is taken, the console prints:
```
Shield absorbed 30.0 damage from enemy
Hull took 15.0 damage from wall
Player hit by enemy!
```

---

## Next Steps

### Recommended Additions
1. **Shield Recharge**: Add CPU-based shield recovery
2. **Shield Visual**: Render shield bar separately from hull
3. **Death Screen**: Implement proper game-over flow
4. **Damage Numbers**: Floating damage indicators
5. **Invulnerability Frames**: Brief immunity after taking damage
6. **Different Enemy Damage**: Vary damage by enemy type

### Customization
- Wall damage is hardcoded at line 136 - can be a variable
- Enemy damage is hardcoded at line 175 - can be a variable
- Both can be made @export for balance tweaking in Inspector

---

## Files Modified

1. **res://player/player.gd**
   - Added health/shield variables
   - Added `take_damage()` function
   - Added `_on_body_entered()` function
   - Added wall damage detection in `_physics_process()`
   - Added signal `player_damaged`

2. **res://player/player.tscn**
   - Added DamageZone (Area2D)
   - Added collision shape for DamageZone
   - Connected `body_entered` signal

3. **res://validate_damage_system.gd** (NEW)
   - Validation script for testing damage logic

---

## Status
✅ **Implementation Complete**
- Shields absorb damage first
- Hull takes overflow damage
- Wall collision damage implemented
- Enemy collision damage implemented
- Signals working for UI integration
- Debug output implemented
