shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float scanline_count : hint_range(0, 1080) = 300.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 color = texture(screen_texture, uv);
	
	// Simple scanline effect
	float scanline = sin(uv.y * scanline_count * PI * 2.0);
	scanline = (scanline + 1.0) * 0.5;
	scanline = mix(0.9, 1.0, scanline);
	
	// Add a bit of blue tint for cyberpunk feel
	color.rgb *= vec3(0.9, 0.95, 1.0);
	color.rgb *= scanline;
	
	COLOR = color;
}
