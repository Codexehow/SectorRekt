extends CanvasLayer

var texture_rect: TextureRect
var timer: Timer

var hallucinations: Array[Texture2D] = [
	preload("res://assets/generated/hallucination_digital_nightmare_frame_0.png")
]

func _ready() -> void:
	texture_rect = TextureRect.new()
	texture_rect.name = "TextureRect"
	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(texture_rect)
	
	timer = Timer.new()
	timer.name = "Timer"
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	texture_rect.hide()

func show_hallucination() -> void:
	var tex: Texture2D = hallucinations.pick_random()
	texture_rect.texture = tex
	texture_rect.show()
	timer.start(2.0)

func _on_timer_timeout() -> void:
	texture_rect.hide()
