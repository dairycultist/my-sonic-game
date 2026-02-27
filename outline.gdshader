shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

uniform vec3 color : source_color = vec3(1,0,0);
uniform float size : hint_range(0.0, 1.0, 0.01) = 0.01;

void vertex() {
	VERTEX += NORMAL * size;
}

void fragment() {
	ALBEDO = color;
}
