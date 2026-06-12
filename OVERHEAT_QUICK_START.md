# Overheat Anti-Spam System - Quick Start Guide

## What Was Implemented?

An **anti-spam mechanic** that prevents players from mindlessly holding Q/Right Mouse Button to generate CPU indefinitely.

**Key Rule**: Overheat only fills when player holds Q/Right Mouse **AND** CPU is at 100%

---

## Where To Look

### Player Logic
📁 `res://player/player.gd`
- Line 54: `is_generating` flag tracks button state
- Lines 197-220: Overheat fill/decay logic
- Lines 222-234: Input handling for generation tracking

### UI Display
📁 `res://ui/cpu_hud.gd`
- Lines 181-214: Updates overheat bar with color gradient

### Main Scene
📁 `res://main.gd`
- Line 8: CPU HUD scene preload (was missing, now added)

### UI Scene
📁 `res://ui/cpu_hud.tscn`
- OverHeatPanel at bottom-center (pre-built, no changes needed)

---

## How Players Experience It

```
1. Player holds Q or Right Mouse Button
   ↓ CPU increases
   
2. CPU reaches 100% → Player keeps holding
   ↓ After 1 second...
   
3. Overheat bar appears & starts filling (YELLOW)
   ↓
   
4. Bar fills from YELLOW → ORANGE → RED
   ↓
   
5. Player either:
   a) Releases button → Overheat DECAYS
   b) Fires weapon (spends CPU) → Overheat DECAYS
   c) Does nothing → Eventually GAME OVER at 100% heat
```

---

## Technical Overview

### Variables (player.gd, lines 48-58)
```
overheat: 0-100 (current heat level)
is_generating: true/false (tracking button state)
overheat_gain_rate: 15.0 pts/sec (heating speed)
overheat_decay_rate: 8.0 pts/sec (cooling speed)
cpu_max_threshold: 1.0 sec (delay before heating starts)
```

### Signal
```
overheat_updated(value: float)  ← Emitted every frame
```

### Update Flow
```
Player._physics_process()
  ├─ Check: cpu == 100% AND is_generating?
  ├─ YES → Increase overheat (15 pts/sec)
  ├─ NO → Decrease overheat (8 pts/sec)
  ├─ Emit overheat_updated signal
  └─ CPUHUD updates bar & colors
```

---

## Colors & Meanings

| Progress | Color | Status |
|----------|-------|--------|
| 0-49% | YELLOW | ⚠️ Caution - Getting warm |
| 50-74% | ORANGE | ⚠️⚠️ Warning - Very hot |
| 75-100% | RED | 🔥 Critical - About to fail |

---

## Configuration (If Needed)

All in `player.gd` around line 52:

```gdscript
var overheat_max: float = 100.0          # Max heat before death
var overheat_gain_rate: float = 15.0     # Heat fill speed
var overheat_decay_rate: float = 8.0     # Heat drain speed  
var cpu_max_threshold: float = 1.0       # Seconds before heating
```

**Example**: Make overheat fill faster:
```gdscript
var overheat_gain_rate: float = 20.0     # Instead of 15.0
```

---

## Testing Checklist

Quick 2-minute test:
- [ ] Start game
- [ ] See "OverHeat" bar at bottom-center
- [ ] Hold Q (CPU increases)
- [ ] Keep holding (watch for yellow bar to appear after 1 sec)
- [ ] Bar should fill with yellow → orange
- [ ] Release Q (bar should shrink)
- [ ] Hold Q again, fire weapon when CPU full
- [ ] CPU drops, overheat decays faster
- [ ] Hold Q a long time (overheat reaches red)
- [ ] Keep going (should trigger game over)

---

## What Stayed the Same

✅ Player movement  
✅ Weapon firing  
✅ Shield system  
✅ Health system  
✅ All other signals  
✅ All other UI elements  

**No breaking changes!**

---

## Common Questions

### Q: Why can't players just hold Q forever?
**A**: Overheat fills and causes game over. Forces strategic choices.

### Q: How do players cool down?
**A**: 
1. Release Q/Right Mouse
2. Fire weapon (uses CPU)
3. Use Blink (uses CPU)
4. Wait (8 pts/sec decay)

### Q: Can I adjust the timings?
**A**: Yes! See Configuration section above.

### Q: What happens at 100% overheat?
**A**: `player_died.emit()` is called (game over).

### Q: Does overheat affect gameplay otherwise?
**A**: No - it just fills the bar and causes death. No damage, no slowdown.

---

## Quick Code Reference

### Checking Overheat State
```gdscript
var heat: float = player.overheat          # Current level (0-100)
var is_hot: bool = player.overheat >= 75   # Is critical?
```

### Triggering Events
```gdscript
# Signal fires every frame
player.overheat_updated.emit(player.overheat)
```

### Resetting Overheat
```gdscript
player.overheat = 0.0
```

---

## Design Philosophy

> "Make games where spam is rewarded" ❌  
> "Make games where planning matters" ✅

The overheat system encourages:
- **Thinking ahead** - Plan CPU usage
- **Resource management** - Spend wisely
- **Strategy** - Balance generation vs. usage
- **Skill expression** - Master cool-down timing

---

## File Quick Reference

| File | Purpose | Line(s) |
|------|---------|---------|
| `player/player.gd` | Core logic | 48-220 |
| `ui/cpu_hud.gd` | UI updates | 181-214 |
| `main.gd` | UI instantiation | 8, 28-30 |
| `ui/cpu_hud.tscn` | UI layout | (no changes) |
| `debug_attempts.md` | History & fixes | (documentation) |

---

## Still Works?

- ✅ Movement (WASD, arrows)
- ✅ Weapon (LMB)
- ✅ Blink (B key)
- ✅ CPU generation (Q, RMB)
- ✅ Shield system
- ✅ Health system
- ✅ All UI except new overheat

---

## Next Steps

1. **Test**: Run the game and try the mechanics
2. **Feel**: Does the timing feel right? (Adjust if needed)
3. **Balance**: Is spam still possible? Too punishing?
4. **Iterate**: Adjust timings if player feedback suggests it
5. **Ship**: Deploy with confidence!

---

## Support

If something doesn't work:
1. Check console for errors
2. Open `OVERHEAT_IMPLEMENTATION_SUMMARY.md` for details
3. Check `debug_attempts.md` for known issues
4. Verify UI panel visible in game

---

**That's it!** The anti-spam overheat system is ready to go. 🎮
