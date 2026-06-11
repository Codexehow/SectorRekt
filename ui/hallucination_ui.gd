extends CanvasLayer
class_name HallucinationUI

@onready var texture_rect: TextureRect = $TextureRect
@onready var overlay: ColorRect = $Overlay

func _ready() -> void:
	hide()
	overlay.color.a = 0

func trigger_hallucination(type: String, duration: float = 3.0) -> void:
	var texture_path: String = ""
	match type:
		"eyes":
			texture_path = "res://assets/hallucination_eyes.png"
		"shadow":
			texture_path = "res://assets/hallucination_shadow.png"
		_:
			texture_path = "res://assets/hallucination_eyes.png" # Default
	
	var tex: Texture2D = load(texture_path)
	if tex:
		texture_rect.texture = tex
	
	show()
	
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "color:a", 0.7, 0.5)
	tween.tween_property(texture_rect, "modulate:a", 1.0, 0.5).from(0.0)
	
	await get_tree().create_timer(duration).timeout
	
	var tween_out: Tween = create_tween()
	tween_out.set_parallel(true)
	tween_out.tween_property(overlay, "color:a", 0.0, 0.5)
	tween_out.tween_property(texture_rect, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	hide()
