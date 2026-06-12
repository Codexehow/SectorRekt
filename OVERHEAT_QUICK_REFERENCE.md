# OverHeat System - Quick Reference

## At a Glance

| Aspect | Value | Notes |
|--------|-------|-------|
| **Max OverHeat** | 100 | Reaches 100 = Game Over |
| **Gain Rate** | 15 pts/sec | When CPU is at 100% |
| **Decay Rate** | 8 pts/sec | When CPU drops below 100% |
| **Grace Period** | 1 second | At 100% CPU before heating starts |
| **Time to Critical** | 6.7 seconds | At continuous max CPU |
| **Time to Cool Down** | 12.5 seconds | Full cool down from 100 to 0 |

## Player Strategy

### ✅ DO THIS (Safe)
```
1. Click RMB to generate CPU
2. Watch OverHeat bar
3. RELEASE RMB when approaching 75%
4. Let CPU decay naturally
5. Repeat when needed
```

### ❌ DON'T DO THIS (Dangerous)
```
1. Hold RMB continuously
2. Watch OverHeat climb
3. Ignore the red bar
4. Hit 100 OverHeat
5. GAME OVER
```

## Color Codes

```
🟨 Yellow    (0-50%)   → Safe, keep playing
🟧 Orange    (50-75%)  → Caution, release CPU soon
🔴 Red       (75-100%) → DANGER, release immediately
```

## UI Location

```
┌─────────────────────────────────────────────┐
│           GAME VIEWPORT                     │
│                                             │
│                                             │
│           [Your Tank Here]                  │
│                                             │
│                                             │
│                                             │
│                    [OverHeat Bar]           │
│                    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀  ← Bottom Center
└─────────────────────────────────────────────┘
```

## Key Mechanics

### Accumulation Phase
```
Right-click held (RMB)
         ↓
CPU reaches 100%
         ↓
Hold for > 1 second
         ↓
OverHeat bar starts filling
         ↓
Continues filling at 15 pts/sec
```

### Decay Phase
```
Release right-click (RMB)
         ↓
CPU drops below 100%
         ↓
OverHeat stops gaining
         ↓
OverHeat decays at 8 pts/sec
         ↓
Reaches 0 (fully cooled)
```

### Game Over Condition
```
OverHeat >= 100
         ↓
Player dies immediately
         ↓
Game over screen appears
         ↓
Restart/reload scene
```

## Tactical Tips

1. **Monitor the bar** - Always watch OverHeat position
2. **Preemptive release** - Release at 50-75%, don't wait for red
3. **Manage peaks** - Use heat windows during combat lulls
4. **Plan bursts** - Know when you'll need max CPU and manage accordingly
5. **Rhythm gameplay** - Develop a click-release rhythm for sustained play

## Examples

### Safe Spamming (Won't overheat)
```
1. Click 5 times quickly (CPU → 100)
2. Wait 0.5 sec (under grace period)
3. CPU decays back to ~70
4. Repeat as needed
```

### Dangerous Spamming (Will overheat)
```
1. Hold right-click continuously
2. CPU stays at 100%
3. After 1 second → OverHeat starts
4. After 6.7 seconds → OverHeat = 100
5. Game Over!
```

### Balanced Play (Optimal)
```
1. Generate CPU when needed (weapon/shield/blink)
2. Release after 1-2 seconds
3. Let CPU decay to safe level
4. Repeat cycle as combat demands
```

## If You're Overheating

**Immediate action:**
1. Stop clicking RMB immediately
2. OverHeat will start decaying (8 pts/sec)
3. At 75% OverHeat, CPU will be sub-max
4. Continue playing, manage other resources

**Recovery time:**
- From 75% → Safe: ~3.1 seconds
- From 100% → Safe: ~3.1 seconds (you'll die at 100)
- Full cool down: 12.5 seconds

## Related Systems

| System | Impact | Notes |
|--------|--------|-------|
| CPU Generation | Causes OverHeat | Core mechanic |
| Weapon Charge | Uses CPU | Creates demand |
| Shield Charge | Uses CPU | Creates demand |
| Blink Charge | Uses CPU | Creates demand |
| CPU Decay | Reduces heat | Happens naturally |

---

**Remember:** OverHeat is a resource management challenge. The more you spam CPU, the hotter you get. Plan your CPU use strategically!
