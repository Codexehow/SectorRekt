# OverHeat System Documentation

## Overview
The OverHeat system is a new mechanic that punishes the player for maintaining maximum CPU usage for extended periods. It adds a risk/reward element to CPU management.

## How It Works

### OverHeat Accumulation
- When player CPU reaches **100%** and stays at max for longer than **1 second**, the OverHeat bar begins to fill
- OverHeat accumulates at a rate of **15 points/second** while CPU remains at maximum
- OverHeat bar ranges from **0 to 100** (game over if it reaches 100)

### OverHeat Decay
- When CPU drops below 100%, OverHeat begins to decay
- Decay rate is **8 points/second** (slower than gain, so the player must actively manage it)
- OverHeat cannot go below 0

### Game Over Condition
- If OverHeat reaches **100**, the player dies immediately (triggers game over)
- This forces players to give their CPU a break periodically

## UI Elements

### OverHeat Panel
Located at the **bottom center** of the screen:
- **Label**: "OverHeat" text that changes color based on heat level
- **Bar**: Visual progress bar that fills from 0 to 100
- **Value Display**: Shows current heat as "X/100"

### Color Gradient
The OverHeat bar uses a smooth yellow-to-red gradient:
- **Yellow** (0-50%): Low heat - relatively safe
- **Orange** (50-75%): Medium heat - caution zone
- **Red** (75-100%): High heat - critical danger

The label also changes color:
- **Yellow** when below 50%
- **Orange** when 50-75%
- **Red** when above 75%

## Implementation Details

### Player Script Changes (`res://player/player.gd`)
Added variables:
```gdscript
var overheat: float = 0.0                    # Current overheat value
var overheat_max: float = 100.0              # Maximum before game over
var cpu_max_timer: float = 0.0               # Timer for time at 100% CPU
var cpu_max_threshold: float = 1.0           # 1 second before heating starts
var overheat_gain_rate: float = 15.0         # Points/sec when maxed
var overheat_decay_rate: float = 8.0         # Points/sec when not maxed
```

Added signal:
```gdscript
signal overheat_updated(value: float)
```

Logic in `_physics_process()`:
- Tracks how long CPU has been at 100%
- Once threshold is crossed, increments overheat
- When CPU drops below 100%, resets timer and starts decay
- Dies when overheat >= 100

### HUD Script Changes (`res://ui/cpu_hud.gd`)
Added references to OverHeat UI elements and connection to the signal.

Update handler `_on_overheat_updated()`:
- Updates bar value
- Updates text display
- Calculates color gradient (Yellow → Red)
- Updates label color based on heat level

### Scene Changes (`res://ui/cpu_hud.tscn`)
Added new panel at bottom center with:
- Background panels with orange/red borders
- Label displaying "OverHeat"
- ProgressBar for visual feedback
- Text label showing numeric value

## Gameplay Tips

1. **Spam clicking is dangerous**: Holding down RMB to continuously generate CPU will quickly overheat
2. **Management is key**: Players must release the CPU generation button periodically to let heat decay
3. **The 1-second grace period**: There's a 1-second window after CPU hits 100% before heating starts - use this!
4. **Decay is slower**: Overheat decays slower than it builds, so prevention is better than recovery
5. **Resource allocation matters**: Managing CPU means trading off between weapon, shield, and blink charges

## Balancing Notes

Current parameters:
- **Gain**: 15 points/sec (fills completely in ~6.7 seconds at max)
- **Decay**: 8 points/sec (clears completely in ~12.5 seconds)
- **Threshold**: 1 second at max CPU

These can be adjusted by editing the Player script if different difficulty is desired:
```gdscript
var overheat_gain_rate: float = 15.0   # Increase for harder, decrease for easier
var overheat_decay_rate: float = 8.0   # Decrease for harsher punishment
var cpu_max_threshold: float = 1.0     # Decrease to punish earlier
```

## Testing

A test script is available at `res://test_overheat.gd` that verifies:
1. OverHeat starts at 0
2. Signal exists
3. OverHeat increases when CPU is maxed
4. OverHeat decreases when CPU drops

Run it by executing it from the editor or from code.
