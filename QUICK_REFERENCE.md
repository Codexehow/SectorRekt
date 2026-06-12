# Quick Reference Guide - New Features

## 🎮 Feature 1: CPU Drain System
**When CPU = 0, everything drains:**
- Weapon: -30 pts/sec
- Shield: -30 pts/sec
- Blink: -30 pts/sec
- Speed: -50 units/sec (min 30)

**Difficulty**: ⭐⭐⭐⭐⭐ (Critical)
**Fix**: Keep clicking Q or Right Mouse to generate CPU!

---

## 🛡️ Feature 2: Shield Buffer System
**Two Phases:**

### Phase 1: Accumulation (shields at 100%)
- CPU allocation → stored in buffer (not shields)
- Buffer max: 500 points
- Watch "Buffer: X" value in HUD

### Phase 2: Recovery (shields < 10%)
- Buffer automatically recharges shields
- Rate: 5 HP/second (slow!)
- Never instant - creates challenge

**Why?** Makes shields harder to recover. You must carefully manage both shield HP and buffer reserves. Shields can't just instantly refill after taking damage.

**Example:**
```
You: Generate 10 CPU clicks while shields full
→ Buffer: 100 (accumulated from CPU)

Enemy: Hits you
→ Your shields: 100 → 8%

You: Shields below 10% threshold!
→ Buffer: 100 → 0 (recharges shields)
→ Your shields: 8% → 100% (takes 20 seconds!)
```

---

## 🔧 Feature 3: Controls Toggle (C Key)
**Press C to:**
- Hide/show Controls Panel (bottom-left)
- Hide/show Options Panel (top-right)

**What you see:**
```
Controls Panel:                Options Panel:
┌─────────────────────┐        ┌──────────────────┐
│ [CONTROLS]          │        │ [OPTIONS]        │
│ Q/RMB: CPU          │        │ ☐ Fullscreen     │
│ LMB: Fire           │        │ Resolution:      │
│ B: Blink            │        │ [1920x1080 ▼]    │
│ A/D: Turn           │        └──────────────────┘
│ W/S: Speed          │
│ G: Corruption       │
└─────────────────────┘
```

---

## 🖥️ Feature 4: Fullscreen & Resolution
**Press C → Options Panel → :**

### Fullscreen Toggle
- Check box: Fullscreen ON
- Uncheck box: Windowed mode

### Resolution Dropdown
Select from:
- 1280x720 (720p)
- 1600x900
- 1920x1080 (default)
- 2560x1440 (1440p)
- 3840x2160 (4K)

**Tip**: Changes apply immediately!

---

## 📊 HUD Changes
New display in Shield section:
```
Shield: 85/100
Buffer: 42 ← Shows accumulated energy
```

---

## 🎯 Difficulty Impact
These features make the game **MUCH HARDER**:

| System | Before | After | Change |
|--------|--------|-------|--------|
| CPU Management | Casual | **Critical** | Must constantly click |
| Shield Recovery | Fast | **Slow** | 5 HP/sec when low |
| System Power | Never loses | **Drains rapidly** | If you stop clicking |
| Survival | Easy | **Hard** | Requires constant attention |

**Bottom Line**: The game is now a tower-defense style clicker where resource management is everything. Stop clicking = you lose.

---

## 🧪 Quick Test
1. **CPU Drain**: Don't click for 10 seconds → watch everything drain to 0
2. **Shield Buffer**: Click while shields full → take damage → shields recover slowly
3. **Toggle**: Press C → both panels hide/show
4. **Fullscreen**: Press C → check fullscreen → game goes fullscreen

---

## ⚙️ Technical Details
- **Files Modified**: 
  - `res://player/player.gd` (CPU drain + shield buffer)
  - `res://ui/cpu_hud.gd` (toggle + fullscreen/resolution)
  - `res://ui/cpu_hud.tscn` (UI additions)

- **New Signals**: 
  - `shield_buffer_updated(buffer: float)`

- **Performance**: 
  - Minimal impact (simple math each frame)
  - All systems respond instantly
  - No frame drops

---

## 📝 Notes
- Shield buffer works at ANY shield level, but only recharges when shields < 10%
- CPU drain is PERMANENT when CPU = 0 (no auto-recovery)
- Resolution changes apply to both windowed and fullscreen
- Controls panel explains all inputs for new players
