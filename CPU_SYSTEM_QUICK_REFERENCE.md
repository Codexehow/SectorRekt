# CPU Cycles System - Quick Reference Guide

## 🎮 Player Controls

| Input | Action | Requirement |
|-------|--------|-------------|
| **Q** or **RMB** | Generate CPU cycles | Hold to activate |
| **Left Click** | Fire Thunderbolt | Weapon ≥ 30 cycles |
| **B** | Activate Blink Drive | Blink = 100 cycles |
| **G** | Toggle Corrupted Mode | Anytime |
| **A/D** | Turn left/right | Always available |
| **W/S** | Speed up/down | Always available |
| **1-5** | Speed presets | Anytime |
| **Mouse** | Aim weapon | Always tracks |

---

## 📊 CPU Distribution (Automatic)

```
Player holds Q/RMB
         ↓
CPU generates at 35/sec
         ↓
Automatically split:
├─ 50% → Weapon Charge
├─ 30% → Shield Charge
├─ 10% → Movement Bonus
├─ 10% → Life Support (reserved)
└─ 10% → Blink Charge
```

---

## ⚡ Ability System

### Thunderbolt (Weapon)
- **Charge Required**: 30+ cycles
- **Cost**: 30 cycles per shot
- **Fire**: Left Mouse Button
- **Target**: Mouse cursor position
- **Effect**: Projectile spawns at weapon muzzle

### Blink Drive
- **Charge Required**: 100 cycles (FULL)
- **Cost**: 100 cycles (depletes completely)
- **Activate**: B key
- **Effect**: Teleport 150px forward
- **Feature**: Can pass through walls

---

## 📈 Charge Levels (0-100 Scale)

| System | Status | Charge |
|--------|--------|--------|
| **Weapon** | Ready to fire | ≥ 30 |
| **Shield** | Charging | 0-100 |
| **Blink** | Ready to use | = 100 |
| **Life Support** | Tracking | 0-100 |

---

## 🔄 CPU Lifecycle

1. **Generation**: Hold Q/RMB → +35/sec (max 100)
2. **Distribution**: Automatic split among 5 systems
3. **Usage**: Spend on weapon/blink when ready
4. **Decay**: Release Q/RMB → -15/sec (min 0)

---

## 🎛️ UI Integration Signal

```gdscript
# Connect this signal to display bars
player.cpu_updated.connect(func(current, weapon, shield, blink):
    cpu_bar.value = current / 100.0
    weapon_bar.value = weapon / 100.0
    shield_bar.value = shield / 100.0
    blink_bar.value = blink / 100.0
)
```

---

## 📋 Constants & Values

```gdscript
max_cpu_cycles = 100.0
cpu_generation_rate = 35.0      # cycles/sec
cpu_decay_rate = 15.0           # cycles/sec
base_speed = 90.0               # units/sec
blink_distance = 150.0          # pixels

# Allocations
WEAPON_ALLOC = 0.50   # 50%
SHIELD_ALLOC = 0.30   # 30%
MOVEMENT_ALLOC = 0.10 # 10%
LIFE_SUPPORT_ALLOC = 0.10 # 10%
BLINK_ALLOC = 0.10    # 10%
```

---

## 🧪 Testing Checklist

- [ ] CPU generates when holding Q
- [ ] CPU generates when holding RMB
- [ ] CPU decays when both released
- [ ] Weapon charges at correct rate (50% of generation)
- [ ] Shield charges at correct rate (30% of generation)
- [ ] Blink charges at correct rate (10% of generation)
- [ ] Weapon fires when ≥ 30 cycles
- [ ] Blink activates when = 100 cycles
- [ ] Movement speed increases with CPU
- [ ] Tank turning works (A/D)
- [ ] Speed control works (W/S)
- [ ] Speed presets work (1-5)
- [ ] Weapon aims at mouse
- [ ] G key toggles corrupted mode
- [ ] Signals emit correctly

---

## 🐛 Debug Tips

```gdscript
# Print current CPU levels
print("CPU: %.1f | Weapon: %.1f | Shield: %.1f | Blink: %.1f" % [
    player.current_cpu,
    player.weapon_charge,
    player.shield_charge,
    player.blink_charge
])

# Check if weapon is ready
if player.weapon_charge >= 30:
    print("Weapon ready to fire!")

# Check if blink is ready
if player.blink_charge >= 100:
    print("Blink drive ready!")

# Monitor generation
if Input.is_key_pressed(KEY_Q):
    print("Generating CPU...")
else:
    print("Decaying CPU...")
```

---

## 🎨 UI Bar Setup

Create a HBoxContainer with 4 ProgressBar nodes:

```
Panel (UI Root)
├── CPU_Bar (ProgressBar)
│   ├── min_value: 0
│   ├── max_value: 1.0
│   └── custom_colors/fill: Orange
├── Weapon_Bar (ProgressBar)
│   ├── min_value: 0
│   ├── max_value: 1.0
│   └── custom_colors/fill: Red
├── Shield_Bar (ProgressBar)
│   ├── min_value: 0
│   ├── max_value: 1.0
│   └── custom_colors/fill: Blue
└── Blink_Bar (ProgressBar)
    ├── min_value: 0
    ├── max_value: 1.0
    └── custom_colors/fill: Purple
```

---

## 🔌 File Locations

```
res://
├── player/
│   ├── player.gd (Main implementation - 151 lines)
│   └── player.tscn (Scene with nodes)
├── CPU_CYCLES_SYSTEM.md (Full documentation)
├── IMPLEMENTATION_SUMMARY.md (What was implemented)
├── CPU_SYSTEM_DIAGRAM.txt (Architecture diagram)
└── CPU_SYSTEM_QUICK_REFERENCE.md (This file)
```

---

## 🚀 Future Enhancements

- [ ] Implement shield absorption mechanics
- [ ] Add health/regeneration from Life Support
- [ ] Create visual shield effect
- [ ] Add audio feedback for CPU generation
- [ ] Implement manual allocation override UI
- [ ] Add CPU burst mode (temporary high generation)
- [ ] Create subsystem failure penalties
- [ ] Add glitch visual effects when corrupted
- [ ] Implement audio distortion effects

---

## ✅ Status

**System**: CPU Cycles Resource Management
**Status**: ✅ **FULLY IMPLEMENTED**
**Ready For**: UI Integration & Testing

---

## 📝 Notes

- All abilities use CPU from the shared pool
- Distribution is automatic and continuous
- Player focuses on other tasks while CPU charges
- Difficulty scales with CPU management demands
- Signals enable real-time UI feedback
- Tank movement always available (separate from CPU)

---

**Last Updated**: 2024
**Godot Version**: 4.6.3-stable
**Maintained By**: Development Team
