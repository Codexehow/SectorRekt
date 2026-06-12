# Consequence Engine - Key Code Snippets

## Core Code You Asked For

### 1. The Consequence Popup Scene/Script

**File:** `res://ui/consequence_popup.gd`

```gdscript
extends Control
class_name ConsequencePopup

var movement_button: Button = null
var blink_button: Button = null
var dark_overlay: Panel = null
var consequence_chosen: bool = false
var chosen_consequence: String = ""

signal consequence_selected(consequence: String)

func _ready() -> void:
    # Make this popup fullscreen for the overlay
    anchor_left = 0.0
    anchor_top = 0.0
    anchor_right = 1.0
    anchor_bottom = 1.0
    
    # Create dark overlay (semi-transparent dark red)
    dark_overlay = Panel.new()
    dark_overlay.anchor_left = 0.0
    dark_overlay.anchor_top = 0.0
    dark_overlay.anchor_right = 1.0
    dark_overlay.anchor_bottom = 1.0
    add_child(dark_overlay)
    
    var overlay_style: StyleBoxFlat = StyleBoxFlat.new()
    overlay_style.bg_color = Color(0.1, 0.0, 0.0, 0.8)  # Dark red
    dark_overlay.add_theme_stylebox_override("panel", overlay_style)
    
    # Create main container (centered popup)
    var popup_container: VBoxContainer = VBoxContainer.new()
    popup_container.anchor_left = 0.5
    popup_container.anchor_top = 0.5
    popup_container.anchor_right = 0.5
    popup_container.anchor_bottom = 0.5
    popup_container.offset_left = -320.0
    popup_container.offset_top = -200.0
    popup_container.offset_right = 320.0
    popup_container.offset_bottom = 200.0
    popup_container.custom_minimum_size = Vector2(640, 400)
    add_child(popup_container)
    
    # Create popup background panel
    var popup_bg: Panel = Panel.new()
    popup_bg.custom_minimum_size = Vector2(640, 400)
    popup_container.add_child(popup_bg)
    
    # Style the popup background (glitchy neon digital theme)
    var popup_style: StyleBoxFlat = StyleBoxFlat.new()
    popup_style.bg_color = Color(0.15, 0.15, 0.2, 0.95)  # Dark blue-gray
    popup_style.border_color = Color(0.0, 1.0, 1.0, 0.8)  # Cyan border
    popup_style.set_border_enabled(true)
    popup_style.set_border_width_all(3)
    popup_bg.add_theme_stylebox_override("panel", popup_style)
    
    # Create title
    var title: Label = Label.new()
    title.text = "SYSTEM CRITICAL: CONSEQUENCE REQUIRED"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    var title_font_size: int = 24
    title.add_theme_font_size_override("font_size", title_font_size)
    title.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0, 1.0))  # Red
    popup_container.add_child(title)
    
    # ... spacing and description ...
    
    # Create buttons container
    var buttons_container: HBoxContainer = HBoxContainer.new()
    buttons_container.add_theme_constant_override("separation", 20)
    popup_container.add_child(buttons_container)
    
    # Movement Lockdown Button
    movement_button = Button.new()
    movement_button.text = "Movement Lockdown\n(Tank Frozen)"
    movement_button.custom_minimum_size = Vector2(300, 60)
    movement_button.add_theme_font_size_override("font_size", 14)
    movement_button.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0, 1.0))  # Yellow
    var movement_style: StyleBoxFlat = StyleBoxFlat.new()
    movement_style.bg_color = Color(0.3, 0.2, 0.0, 1.0)  # Dark yellow-brown
    movement_style.border_color = Color(1.0, 0.8, 0.0, 0.8)  # Yellow border
    movement_style.set_border_enabled(true)
    movement_style.set_border_width_all(2)
    movement_button.add_theme_stylebox_override("normal", movement_style)
    movement_button.pressed.connect(_on_movement_pressed)
    buttons_container.add_child(movement_button)
    
    # Blink Reset Button
    blink_button = Button.new()
    blink_button.text = "Blink Drive Reset\n(Blink Charge to 0)"
    blink_button.custom_minimum_size = Vector2(300, 60)
    blink_button.add_theme_font_size_override("font_size", 14)
    blink_button.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0, 1.0))  # Cyan
    var blink_style: StyleBoxFlat = StyleBoxFlat.new()
    blink_style.bg_color = Color(0.0, 0.2, 0.3, 1.0)  # Dark cyan
    blink_style.border_color = Color(0.5, 0.8, 1.0, 0.8)  # Cyan border
    blink_style.set_border_enabled(true)
    blink_style.set_border_width_all(2)
    blink_button.add_theme_stylebox_override("normal", blink_style)
    blink_button.pressed.connect(_on_blink_pressed)
    buttons_container.add_child(blink_button)
    
    print("[CONSEQUENCE POPUP] Initialized and displayed")

func _on_movement_pressed() -> void:
    chosen_consequence = "movement_lockdown"
    consequence_chosen = true
    consequence_selected.emit(chosen_consequence)
    print("[CONSEQUENCE] Player chose: Movement Lockdown")
    queue_free()

func _on_blink_pressed() -> void:
    chosen_consequence = "blink_reset"
    consequence_chosen = true
    consequence_selected.emit(chosen_consequence)
    print("[CONSEQUENCE] Player chose: Blink Drive Reset")
    queue_free()
```

---

### 2. How Overheat Reaching 100% Triggers It

**File:** `res://player/player.gd` (lines 206-208)

```gdscript
# Game over: System overheats from sustained abuse
if overheat >= overheat_max:
    print("SYSTEM CRITICAL: Overheating critical - triggering consequence!")
    overheat_critical.emit()
```

**Signal Definition** (lines 63-66):
```gdscript
signal movement_updated(value: float)
signal overheat_critical  # Emitted when overheat reaches 100%
```

**Connected in ConsequenceEngine** (res://ui/consequence_engine.gd, lines 11-17):
```gdscript
func _ready() -> void:
    var players: Array = get_tree().get_nodes_in_group("player")
    player = players[0] as Player if players.size() > 0 else null
    
    if player:
        player.overheat_critical.connect(_on_overheat_critical)
        print("[CONSEQUENCE ENGINE] Connected to player and ready!")
```

---

### 3. Movement Bar System

**File:** `res://player/player.gd` (lines 57-61)

**Variables:**
```gdscript
# === MOVEMENT SYSTEM ===
# Movement bar acts as a resource that can be consumed as a consequence
# When at 0%, the tank cannot move (frozen in place)
# Regenerates over time when above 0%
@export var max_movement: float = 100.0
var current_movement: float = 100.0
var movement_regen_rate: float = 15.0  # Points per second
```

**Regeneration Loop** (lines 156-159):
```gdscript
# === MOVEMENT REGENERATION ===
if current_movement < max_movement:
    current_movement = min(current_movement + movement_regen_rate * delta, max_movement)
    movement_updated.emit(current_movement)
```

**Applied to Velocity** (line 180):
```gdscript
# Apply movement multiplier based on current_movement bar (0% = frozen, 100% = normal)
var movement_multiplier: float = current_movement / max_movement
velocity = direction * current_speed * (1.0 + MOVEMENT_ALLOC * (current_cpu / max_cpu_cycles)) * movement_multiplier
```

---

### 4. Movement Bar Implementation

**File:** `res://ui/cpu_hud.gd` (lines 244-255)

```gdscript
func _on_movement_updated(movement_val: float) -> void:
    """Update movement bar when movement system changes."""
    if movement_bar and movement_label:
        movement_bar.value = movement_val
        movement_label.text = "Movement: %d/100" % int(movement_val)
        
        # Change color based on movement level (green when full, red when frozen)
        if movement_val <= 0:
            movement_bar.modulate = Color(1.0, 0.0, 0.0, 1.0)  # Red when frozen
        elif movement_val < 30.0:
            movement_bar.modulate = Color(1.0, 0.5, 0.0, 1.0)  # Orange when critical
        else:
            movement_bar.modulate = Color.WHITE  # White when normal
```

**HUD Initialization** (lines 109-110):
```gdscript
movement_label = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/MovementSection/MovementLabel")
movement_bar = get_node_or_null("ResourcePanel/VBoxContainer/OtherResourcesContainer/MovementSection/MovementBar")
```

**Signal Connection** (line 49):
```gdscript
player.movement_updated.connect(_on_movement_updated)
```

---

### 5. Consequence Engine Implementation

**File:** `res://ui/consequence_engine.gd`

```gdscript
extends Node
class_name ConsequenceEngine

var player: Player = null
var consequence_popup: ConsequencePopup = null
var handling_consequence: bool = false

func _ready() -> void:
    var players: Array = get_tree().get_nodes_in_group("player")
    player = players[0] as Player if players.size() > 0 else null
    
    if player:
        player.overheat_critical.connect(_on_overheat_critical)
        print("[CONSEQUENCE ENGINE] Connected to player and ready!")

func _on_overheat_critical() -> void:
    """Called when the player's overheat reaches 100%"""
    if handling_consequence:
        return
    
    print("[CONSEQUENCE ENGINE] Overheat critical reached! Triggering consequence system...")
    handling_consequence = true
    
    # Pause the game
    get_tree().paused = true
    print("[CONSEQUENCE ENGINE] Game paused")
    
    # Create and show the consequence popup
    show_consequence_popup()

func show_consequence_popup() -> void:
    """Show the consequence popup UI and wait for player choice"""
    consequence_popup = ConsequencePopup.new()
    get_tree().root.add_child(consequence_popup)
    consequence_popup.consequence_selected.connect(_on_consequence_selected)
    print("[CONSEQUENCE ENGINE] Consequence popup displayed, awaiting player choice...")

func _on_consequence_selected(consequence: String) -> void:
    """Called when player selects a consequence"""
    print("[CONSEQUENCE ENGINE] Player selected consequence: ", consequence)
    
    # Apply the chosen consequence to the player
    match consequence:
        "movement_lockdown":
            player.apply_movement_lockdown()
        "blink_reset":
            player.apply_blink_reset()
    
    # Reset overheat
    player.overheat = 0.0
    player.overheat_updated.emit(player.overheat)
    print("[CONSEQUENCE ENGINE] Overheat reset to 0")
    
    # Unpause the game
    get_tree().paused = false
    print("[CONSEQUENCE ENGINE] Game unpaused, consequence applied!")
    handling_consequence = false
```

---

### 6. Consequence Application Methods

**File:** `res://player/player.gd` (lines 285-294)

```gdscript
# === CONSEQUENCE SYSTEM ===
func apply_movement_lockdown() -> void:
    """Consequence: Movement Lockdown - Set movement to 0"""
    current_movement = 0.0
    movement_updated.emit(current_movement)
    print("[CONSEQUENCE] Movement Lockdown Applied - Tank frozen!")

func apply_blink_reset() -> void:
    """Consequence: Blink Drive Reset - Set blink charge to 0"""
    blink_charge = 0.0
    cpu_updated.emit(current_cpu, weapon_charge, shield_charge, blink_charge)
    print("[CONSEQUENCE] Blink Drive Reset Applied - Blink charge depleted!")
```

---

### 7. Main Game Setup

**File:** `res://main.gd` (lines 11, 38-40)

```gdscript
var consequence_engine: ConsequenceEngine

func _ready() -> void:
    # ... other setup ...
    
    # Instance consequence engine
    consequence_engine = ConsequenceEngine.new()
    add_child(consequence_engine)
```

---

## Signal Flow Diagram

```
Player generates CPU
    ↓
overheat increments at max CPU
    ↓
overheat >= 100.0
    ↓
Player.overheat_critical.emit()
    ↓
ConsequenceEngine._on_overheat_critical()
    ↓
get_tree().paused = true
    ↓
ConsequencePopup.new() + show()
    ↓
Player clicks button
    ↓
ConsequencePopup.consequence_selected.emit("consequence_name")
    ↓
ConsequenceEngine._on_consequence_selected()
    ↓
Player.apply_consequence()
    ↓
Player.overheat = 0.0
    ↓
get_tree().paused = false
```

---

## Integration Checklist

- [x] Movement system variables in player.gd
- [x] Movement regeneration in _physics_process
- [x] Movement multiplier applied to velocity
- [x] Consequence methods in player.gd
- [x] overheat_critical signal emitted at 100%
- [x] ConsequenceEngine script created
- [x] ConsequencePopup script created (procedural UI)
- [x] HUD movement bar connection
- [x] HUD movement bar update handler
- [x] Main.gd instantiates ConsequenceEngine
- [x] All signals properly connected
- [x] All tests passing

---

## Next: Expandability

### Adding a New Consequence (Example: Weapon Lockdown)

**1. Add to player.gd:**
```gdscript
func apply_weapon_lockdown() -> void:
    weapon_charge = 0.0
    cpu_updated.emit(current_cpu, weapon_charge, shield_charge, blink_charge)
    print("[CONSEQUENCE] Weapon Lockdown Applied - Cannot fire!")
```

**2. Add button to ConsequencePopup:**
```gdscript
weapon_button = Button.new()
weapon_button.text = "Weapon Lockdown\n(Cannot Fire)"
weapon_button.pressed.connect(_on_weapon_pressed)

func _on_weapon_pressed() -> void:
    consequence_selected.emit("weapon_lockdown")
```

**3. Handle in ConsequenceEngine:**
```gdscript
"weapon_lockdown": player.apply_weapon_lockdown()
```

That's it! New consequence is ready to use.
