shader_type canvas_item;

uniform float edge : hint_range(0.0, 1.0, 0.01) = 0.01;

void fragment() {
	
	float d = length(vec2((UV.x - 0.5) * (SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x), UV.y - 0.5));
	
	d = step(edge, d);
	
	COLOR = vec4(0, 0, 0, d);
}
