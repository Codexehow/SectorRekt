# Consequence Engine - Testing Guide

## Quick Start

1. **Open** `res://world.tscn`
2. **Run** the game (Play button or F5)
3. **Follow instructions** below to test consequences

---

## Testing the Movement Bar

### Verify Movement Bar Appears in HUD
- Look at the top-left resource panel
- You should see: CPU, Weapon, Shield, Hull, **Movement**, Blink, Overheat
- Movement bar starts at **100%** (white/normal)
- Updates in real-time as you play

### Test Movement Bar Colors
- **100% Movement** = White (normal movement)
- **30-99% Movement** = White (normal movement) 
- **0-30% Movement** = Orange (critical - slow movement)
- **0% Movement** = Red (frozen - cannot move)

### Test Movement Speed
1. Start game - tank moves normally at full speed
2. Right-click repeatedly to generate CPU until overheat reaches 100%
3. Choose **Movement Lockdown** consequence
4. Tank becomes completely frozen (cannot move, cannot turn)
5. Wait ~7 seconds - tank gradually unfrozen as movement regenerates
6. After ~15 seconds total - movement returns to 100%

---

## Testing the Consequence System

### Trigger Overheat Critical

**Method 1: Spam Right-Click**
1. Hold **Right Mouse Button** (or press **Q** repeatedly)
2. Watch CPU bar rise to ~97-99%
3. Each click at high CPU adds heat
4. After ~25 clicks, Overheat reaches 100%

**Method 2: Fast CPU Generation**
1. Press **Q** rapidly (faster than mouse)
2. Each press: +25 CPU, triggers heat generation
3. 8 rapid presses = ~100 overheat

### Verify Game Pauses
- When overheat reaches 100%:
  - Game should **STOP** (no movement, no enemies move)
  - You should hear/see nothing moving
  - Input should be ignored (except popup buttons)

### Verify Popup Appears
- Large centered dialog should appear
- Title: "SYSTEM CRITICAL: CONSEQUENCE REQUIRED" (red text)
- Description: "Your tank has overheated from sustained abuse. Choose one consequence to continue:"
- Two buttons clearly visible with labels

---

## Testing Consequences

### Test Movement Lockdown

**Steps:**
1. Trigger overheat critical (see above)
2. Click **"Movement Lockdown (Tank Frozen)"** button
3. Game should **UNPAUSE**
4. Try to move with **W/A/S/D** - tank should NOT move
5. Try to turn with **A/D** - tank should NOT turn
6. Movement bar should be **RED and at 0%**
7. Wait 7 seconds - movement bar gradually fills (WHITE)
8. After full recovery - tank moves normally again

**Verification:**
- ✓ Game unpauses after consequence
- ✓ Tank is completely frozen
- ✓ Movement bar at 0% (red)
- ✓ Movement regenerates over time
- ✓ Full recovery takes ~7 seconds

### Test Blink Reset

**Steps:**
1. Fire a shot to build weapon charge
2. Build up Blink charge to 100% (hold Q briefly, spend CPU elsewhere)
3. Trigger overheat critical again
4. Click **"Blink Drive Reset (Blink Charge to 0)"** button
5. Game should **UNPAUSE**
6. Try to Blink with **B** key - message should say "Blink Drive not charged!"
7. Blink bar should be **at 0%** and **GRAY/DIM**
8. Blink charge will regenerate as you generate CPU again
9. After ~5-10 CPU generations, Blink will be ready again

**Verification:**
- ✓ Game unpauses after consequence
- ✓ Blink charge set to 0%
- ✓ Cannot use Blink ability
- ✓ Blink regenerates through normal play
- ✓ Recovery time ~30-40 seconds

---

## Testing Multiple Consequences

### Scenario: Chain Multiple Consequences

1. **First Consequence:** Movement Lockdown
   - Movement = 0%
   - Wait for 50% recovery (~3.5 sec)

2. **Second Consequence:** Blink Reset
   - Blink = 0%
   - Movement still recovering from first consequence

3. **Observe:**
   - ✓ Both consequences active simultaneously
   - ✓ Movement still recovering (30% red)
   - ✓ Blink at 0% (gray)
   - ✓ Each recovers independently

---

## Testing UI Integration

### Check HUD Updates

**Movement Bar:**
- Displays correct value (0-100)
- Updates every frame
- Color changes based on level
- Label shows "Movement: X/100"

**Overheat Bar:**
- Still shows correctly (yellow → orange → red)
- Resets to 0% after consequence chosen
- Doesn't interfere with movement bar

**Other Bars:**
- Weapon, Shield, Hull, Blink bars all still work
- No visual glitches or overlapping
- No performance issues

### Check Popup UI

- Centered on screen
- Dark red overlay visible
- Text is readable
- Buttons are clickable
- Button text clear and descriptive

---

## Testing Recovery Systems

### Movement Recovery

**Locked Movement → 100% Recovery**
- Locked time: 0% movement
- Regen per second: +15%
- Total recovery: 100 / 15 = **6.67 seconds**
- Test: Use timer, confirm takes ~7 seconds

### Blink Recovery

**Reset Blink → 100% Recovery**
- Starting point: 0% blink charge
- Regen rate: Through CPU allocation
- Depends on: CPU generation frequency
- Fast recovery: If you generate CPU frequently
- Slow recovery: If you don't generate CPU

---

## Edge Cases to Test

### Test 1: Pause During Consequence Selection
- Pause game (don't press button yet)
- Game should stay paused until choice made
- Buttons should still work

### Test 2: Multiple Rapid Overheat Events
- Trigger consequence
- Choose consequence
- Immediately trigger another (before full recovery)
- Both consequences should apply correctly

### Test 3: Combat During Consequence
- Get into battle
- Trigger overheat consequence
- During popup: enemies should NOT attack (game paused)
- After choice: enemies resume immediately

### Test 4: Movement + Blink Interaction
- Get movement locked
- Get blink reset
- Try to move (locked) + try to blink (no charge)
- Both effects should work together

### Test 5: Recovery Under Fire
- Lock movement during enemy combat
- Tank is frozen but can still shoot
- Focus on fighting while frozen
- Wait for movement recovery
- Resume normal control

---

## Debug Output to Watch

**In the Console, you should see:**

```
[CONSEQUENCE ENGINE] Connected to player and ready!

[When Overheat Reaches 100%]
[CONSEQUENCE ENGINE] Overheat critical reached! Triggering consequence system...
[CONSEQUENCE ENGINE] Game paused
[CONSEQUENCE POPUP] Initialized and displayed

[When Player Clicks Button]
[CONSEQUENCE] Player chose: Movement Lockdown
[CONSEQUENCE] Movement Lockdown Applied - Tank frozen!
[CONSEQUENCE ENGINE] Player selected consequence: movement_lockdown
[CONSEQUENCE ENGINE] Overheat reset to 0
[CONSEQUENCE ENGINE] Game unpaused, consequence applied!
```

---

## Checklist for Full Validation

- [ ] Movement bar displays in HUD at 100%
- [ ] Movement bar color changes (white → orange → red)
- [ ] Movement bar updates in real-time
- [ ] Overheat reaches 100% after spam clicking
- [ ] Game pauses when overheat hits 100%
- [ ] Popup appears centered on screen
- [ ] Popup has readable title and description
- [ ] Popup has two clickable buttons
- [ ] Button 1: Movement Lockdown freezes tank
- [ ] Button 2: Blink Reset removes blink charge
- [ ] Game unpauses after choice
- [ ] Tank recovers movement over ~7 seconds
- [ ] Blink regenerates through normal play
- [ ] Overheat resets to 0% after consequence
- [ ] Can trigger multiple consequences in sequence
- [ ] No UI glitches or overlapping
- [ ] No performance issues
- [ ] Console shows proper debug messages

---

## Common Issues & Solutions

### Issue: Popup doesn't appear
**Solution:** Check ConsequenceEngine is added to main.gd (line 38-40)

### Issue: Game doesn't pause
**Solution:** Check `get_tree().paused = true` in ConsequenceEngine._on_overheat_critical()

### Issue: Movement bar doesn't show
**Solution:** Check cpu_hud.gd lines 109-110 for movement_bar initialization

### Issue: Consequence doesn't apply
**Solution:** Check player.gd lines 285-294 for apply_movement_lockdown() and apply_blink_reset()

### Issue: Tank not freezing
**Solution:** Check player.gd line 180 for movement_multiplier applied to velocity

### Issue: Overheat doesn't reset
**Solution:** Check ConsequenceEngine._on_consequence_selected() line 34 sets player.overheat = 0.0

---

## Performance Testing

1. **Trigger 10 consequences in a row** - No memory leaks
2. **Play for 10 minutes** - No FPS drop
3. **Check console** - No repeated error messages
4. **Monitor resources** - No increasing memory usage

---

## Feedback Notes

Take notes on:
- Consequence difficulty (too hard? too easy?)
- Recovery time (too long? too short?)
- UI clarity (is popup clear enough?)
- Gameflow (does pause feel natural?)
- Balance (are both choices equally viable?)

---

## Next Steps After Testing

If all tests pass:
1. ✓ Feature is ready
2. ✓ Can add more consequences
3. ✓ Can tune recovery rates
4. ✓ Can add visual effects to popup
5. ✓ Can add sound effects

**Ready to commit and document in debug_attempts.md!**
