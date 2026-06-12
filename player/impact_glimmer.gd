extends Node2D
class_name ImpactGlimmer

# === IMPACT GLIMMER EFFECT ===
# Cyan/blue neon sci-fi shield impact visual effect
# Shows a glitchy, rippling energy effect when shields absorb damage

@export var glimmer_duration: float = 0.15  # How long the effect lasts
@export var glimmer_intensity: float = 0.8  # Max opacity
@export var glimmer_color: Color = Color(0.0, 1.0, 1.0, 1.0)  # Cyan

var glimmer_timer: float = 0.0
var is_glimmering: bool = false
var base_modulate: Color = Color.WHITE
var visual_child: CanvasItem = null

func _ready() -> void:
	# Start invisible
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	base_modulate = modulate
	
	# Ensure we have a visual child (sprite, colorect, etc)
	visual_child = get_child(0) if get_child_count() > 0 else null
	if visual_child == null:
		push_error("ImpactGlimmer has no visual child! Add a Sprite2D or ColorRect.")

func _process(delta: float) -> void:
	if is_glimmering:
		glimmer_timer -= delta
		if glimmer_timer <= 0.0:
			is_glimmering = false
			modulate.a = 0.0
		else:
			# Fade out and flicker the glimmer with cyan color
			var progress: float = 1.0 - (glimmer_timer / glimmer_duration)
			var flicker: float = sin(progress * PI * 8.0) * 0.5 + 0.5
			var alpha: float = glimmer_intensity * flicker * (1.0 - progress)
			modulate = glimmer_color * Color(1.0, 1.0, 1.0, alpha)

func trigger_glimmer() -> void:
	"""Start a new glimmer effect - cyan/blue flash with glitch flicker."""
	if visual_child == null:
		push_error("Cannot trigger glimmer: ImpactGlimmer has no visual child!")
		return
	glimmer_timer = glimmer_duration
	is_glimmering = true
	modulate = glimmer_color
