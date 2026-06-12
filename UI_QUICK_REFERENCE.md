# Worm.exe UI - Quick Reference Guide

## Layout Overview

```
┌─────────────────────────────────────────────────────────────────┐
│ RESOURCE PANEL (Top-Left)                   [Rest of Screen]    │
│ ╔═══════════════════════════════════╗      [100% Gameplay Area] │
│ ║ CPU                               ║                           │
│ ║ ████████████████████░░░░░░ 42/100 ║                           │
│ ║ ─────────────────────────────     ║                           │
│ ║ Weapon    │ Shield                 ║                           │
│ ║ ████░░    │ ██░░░░░░               ║                           │
│ ║ Blink     │                        ║                           │
│ ║ ███████░░ │                        ║                           │
│ ╚═══════════════════════════════════╝                           │
│                                                                  │
│ CONTROLS PANEL (Bottom-Left, Toggleable)                        │
│ ╔═══════════════════════════════════╗                           │
│ ║ [CONTROLS] (Press Home to toggle)  ║                           │
│ ║ ─────────────────────────────     ║                           │
│ ║ Q/RMB: CPU | LMB: Fire            ║                           │
│ ║ B: Blink | A/D: Turn              ║                           │
│ ║ W/S: Speed | G: Corruption        ║                           │
│ ╚═══════════════════════════════════╝                           │
└─────────────────────────────────────────────────────────────────┘
```

## Resource Bar Colors

### CPU (Primary - Always Visible)
- **Red** (< 20%): Critical - Recharge ASAP
- **Orange** (20-50%): Low - Get to safety if possible
- **Yellow-Green** (50-80%): Good - Continue combat
- **Bright Green** (≥ 80%): Optimal - Full power!

### Secondary Resources
- **Weapon**: Orange - Charge for max damage
- **Shield**: Cyan - Protect yourself from hits
- **Blink**: Magenta - Escape or dodge attacks

## Control Panel

**Toggle Key**: Home (or 'C' on AZERTY keyboards)

### Keyboard Shortcuts
| Key(s) | Action |
|--------|--------|
| Q or RMB | Generate CPU (hold) |
| LMB | Fire Weapon |
| B | Blink/Teleport |
| A/D | Turn Left/Right |
| W/S | Increase/Decrease Speed |
| G | Toggle Corruption |
| Home | Toggle Controls Display |

## Sizing

### Resource Panel
- **Width**: 300px
- **Height**: 250px
- **Position**: Top-left corner
- **Opacity**: 80% (dark background with neon border)

### Controls Panel
- **Width**: 300px
- **Height**: 120px (when visible)
- **Position**: Bottom-left corner
- **Toggle**: Automatically hides/shows
- **Opacity**: 75% (slightly more transparent)

## UI Navigation Flow

1. **Launch Game**
   - See full Resource Panel with CPU + Secondary Resources
   - See Controls Panel at bottom-left

2. **During Gameplay**
   - Watch CPU bar for primary resource
   - Glance at secondary bars for status
   - Center screen remains clear for movement

3. **Need More Screen Space?**
   - Press Home key to hide Controls Panel
   - Resource Panel always visible
   - Regain ~120px vertical space

4. **In Action**
   - CPU bar color changes as you charge/spend energy
   - Bars update in real-time from player signals
   - No lag or performance impact

## Color Scheme Breakdown

### Accent Colors (Neon Green Theme)
- **Primary Green**: `#00FF00` (0, 1, 0)
- **Light Green**: `#B3FFB3` (0.7, 1, 0.7)
- **Borders**: 2px bright green
- **Glow**: Subtle green overlay effect

### Background Colors
- **Main BG**: `#0D0D14` (0.05, 0.05, 0.08)
- **Glow Effect**: Faint green tint
- **Border**: Hard green line for contrast

### Bar Colors
- **CPU**: Dynamic (Red → Orange → Yellow → Green)
- **Weapon**: Orange (`#FFA600`)
- **Shield**: Cyan (`#00B3FF`)
- **Blink**: Magenta (`#FF00FF`)

## Positioning Reference

### Resource Panel Anchors
```
Position: (0, 0)
Size: (300, 250)
Anchor: Top-Left
Offset: (0, 0) - No margin
```

### Controls Panel Anchors
```
Position: (0, screen_height - 120)
Size: (300, 120)
Anchor: Bottom-Left
Offset Top: -120 (from bottom)
```

## Styling Reference

### Panel Backgrounds
```gdscript
# Resource Panel (Main)
bg_color = Color(0.05, 0.05, 0.08, 0.8)      # Dark with 80% opacity
border_color = Color(0, 1, 0, 0.6)           # Green border
border_width = 2px                            # All sides

# Resource Panel (Glow)
bg_color = Color(0, 1, 0, 0.05)              # Subtle green
corner_radius = 2px                          # Slight rounding

# Controls Panel (Main)
bg_color = Color(0.05, 0.05, 0.08, 0.75)     # Dark with 75% opacity
border_color = Color(0, 1, 0, 0.4)           # Lighter green border
border_width = 1px                            # Thinner border

# Controls Panel (Glow)
bg_color = Color(0, 1, 0, 0.03)              # Barely visible glow
corner_radius = 2px                          # Slight rounding
```

## Performance Notes

- **Canvas Layer**: Layer 100 (renders on top of all game elements)
- **Refresh Rate**: Tied to player signal updates (60+ FPS typical)
- **Memory**: Minimal (~1MB for entire UI)
- **Rendering**: Uses standard 2D GUI nodes (GPU accelerated)

## Accessibility Features

1. **High Contrast**: Green text on dark background
2. **Color Coding**: Resource types have distinct colors
3. **Text Labels**: All bars clearly labeled
4. **Numeric Values**: CPU shows exact value (X/100)
5. **Toggleable Controls**: Can hide secondary info if needed

## Troubleshooting

### "UI looks pixelated or blurry"
- Check if your monitor is in integer scaling mode
- Ensure CanvasLayer stretch mode is correct in project settings

### "Controls key not working"
- Verify 'Home' key input action is mapped
- Check if other scripts are consuming the input
- Try pressing 'Home' key multiple times (toggle state)

### "Bars not updating"
- Check that Player is in the 'player' group
- Verify player.cpu_updated signal is firing
- Check console for connection errors

### "Colors look washed out"
- Adjust monitor color settings
- Check if game gamma correction is enabled
- Verify display is in correct color space (sRGB)

## Tips for Best Experience

1. **Don't Watch the Controls Panel**
   - Memorize the key bindings
   - Toggle it off after learning controls
   - Frees up 120px of vertical space

2. **Use CPU Color Changes**
   - Learn to react to bar color transitions
   - Don't just read the numbers
   - Colors provide faster feedback

3. **Manage Resources Efficiently**
   - Keep CPU charged for emergencies
   - Don't drain Blink without backup plan
   - Use Weapon when safe, save Shield for hits

4. **Use Corners Wisely**
   - Panels only occupy corners
   - Center 80% of screen is gameplay only
   - No UI overlap with action areas

## Customization Options (Future)

Future updates could include:
- Custom UI size/opacity settings
- Alternative color schemes
- UI animation toggles
- Compact/minimal mode options
- Language/localization support
