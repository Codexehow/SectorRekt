# OverHeat UI - Visual & Behavioral Guide

## The OverHeat Panel Location

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  [CPU] [WEAPON] [SHIELD] [HULL] [BLINK]        │  ← Top-left: Resource Panel
│  ████████████░░░░░░ 80/100                      │
│                                                 │
│                                                 │
│                    [GAME WORLD]                 │
│                  (Virus & Enemies)              │
│                                                 │
│                    ╭─────────────╮              │
│                    │ OverHeat    │              │
│                    │ ██████████░ │              │  ← Bottom-center: OverHeat Panel
│                    │ 75/100      │              │     (This is what we fixed!)
│                    ╰─────────────╯              │
│                                                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

## OverHeat Bar Color Progression

### Visual Representation
```
0% [████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 100%
   Yellow             Orange              Red
    ▲                  ▲                   ▲
    0-33%            33-66%              66-100%
   Safe              Caution             Danger!
```

### Actual Color Implementation
```gdscript
# Yellow to Red lerp
overheat_fill_stylebox.bg_color = Color.YELLOW.lerp(Color.RED, color_ratio)

# Color output by percentage:
0%   → Color(1.0, 1.0, 0.0, 1.0)  = YELLOW
25%  → Color(1.0, 0.75, 0.0, 1.0) = Orange-Yellow
50%  → Color(1.0, 0.5, 0.0, 1.0)  = Orange
75%  → Color(1.0, 0.25, 0.0, 1.0) = Orange-Red
100% → Color(1.0, 0.0, 0.0, 1.0)  = RED
```

## Label Color Changes

The "OverHeat" label text changes color at thresholds:

```
0-49%   → Yellow  ("OverHeat") ← Player should be okay
50-74%  → Orange  ("OverHeat") ← Player should be cautious
75-100% → Red     ("OverHeat") ← CRITICAL DANGER
```

## Behavioral State Diagram

```
                    ┌─────────────────────┐
                    │   START (0/100)     │
                    │  No Overheat        │
                    └──────────┬──────────┘
                               │
                      ┌────────▼────────┐
                      │  Hold Q/RMB     │
                      │  Generate CPU   │
                      └────────┬────────┘
                               │
                    ┌──────────▼───────────┐
                    │  CPU < 100?          │
                    │  YES: Decay overheat │
                    │  NO: Check next      │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────────────┐
                    │  CPU = 100 AND               │
                    │  is_generating = true?       │
                    │  YES: START HEATING (1s)     │
                    │  NO: Decay overheat          │
                    └──────────┬───────────────────┘
                               │
                    ┌──────────▼───────────────────┐
                    │  After 1 second at 100%:     │
                    │  Fill overheat (+15 pts/sec) │
                    └──────────┬───────────────────┘
                               │
         ┌─────────────────────▼─────────────────────┐
         │                                           │
    ┌────▼─────────┐                   ┌────────────▼──┐
    │  Overheat    │                   │  Release Key  │
    │  >= 100%?    │                   │  or CPU < 100 │
    │  YES: DIE    │                   │  Decay -8 pts │
    │  NO: Keep    │                   │  /sec back    │
    │  filling     │                   │  to 0         │
    └────┬─────────┘                   └────────────┬──┘
         │                                          │
         │                  ┌───────────────────────┘
         │                  │
         └──────────────────▼──┐
                              │
                        ┌─────▼─────────┐
                        │ Decay loop    │
                        │ (back to 0)   │
                        └───────────────┘
```

## The Fix We Made

### What Changed
**Before**: Created 60 new StyleBoxFlat objects per second
```gdscript
func _on_overheat_updated(overheat_val: float) -> void:
    # ❌ INEFFICIENT: Creates new object every frame
    var fill_stylebox := StyleBoxFlat.new()
    fill_stylebox.bg_color = overheat_color
    overheat_bar.add_theme_stylebox_override("fill", fill_stylebox)
```

**After**: Cache and reuse one StyleBoxFlat object
```gdscript
# In _ready():
overheat_fill_stylebox = StyleBoxFlat.new()
overheat_bar.add_theme_stylebox_override("fill", overheat_fill_stylebox)

# In _on_overheat_updated():
# ✅ EFFICIENT: Just update color on existing object
overheat_fill_stylebox.bg_color = Color.YELLOW.lerp(Color.RED, color_ratio)
```

### Result
- ✅ Smooth bar animation (no jank)
- ✅ Zero memory waste
- ✅ Minimal CPU overhead
- ✅ Professional feel

## Orange Border Question

The orange border around the OverHeatPanel is **intentional design**.

**Current appearance** (orange to match theme):
```
┌─ Color(1.0, 0.5, 0.0, 0.6) = Orange
│
│  ╭─────────────╮
└─→│ OverHeat    │
   │ ██████████░ │
   │ 75/100      │
   ╰─────────────╯
```

**If you want to change it to green** (like other panels), edit `res://ui/cpu_hud.tscn` line 44:
```
[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_OverHeatBG"]
border_color = Color(1, 0.5, 0, 0.6)  # ← Current (orange)
border_color = Color(0, 1, 0, 0.6)    # ← Alternative (green like CPU bar)
border_color = Color(1, 0, 0, 0.6)    # ← Alternative (red for danger theme)
```

## Summary Table

| Aspect | Status | Notes |
|--------|--------|-------|
| **Bar Fill Color** | ✅ Works | Yellow → Orange → Red gradient |
| **Bar Animation** | ✅ Fixed | Now smooth, no jank |
| **Label Color** | ✅ Works | Changes at 50% and 75% |
| **Signal Updates** | ✅ Works | Every frame from player.gd |
| **Memory Usage** | ✅ Optimized | One StyleBox object, not 60 per second |
| **Visual Appearance** | ✅ Good | Professional and clear |
| **Orange Border** | ℹ️ Design | Intentional, easily customizable |

The OverHeat UI is now **fully functional and optimized**! 🎮✨
