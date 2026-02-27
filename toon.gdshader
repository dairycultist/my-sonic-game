shader_type spatial;

uniform sampler2D Albedo: source_color;

void fragment() {
	ALBEDO = texture(Albedo, UV).rgb;
}

void light() {
	DIFFUSE_LIGHT += mix(0.5, 1.0, smoothstep(-0.1, 0.1, dot(NORMAL, LIGHT))) * ATTENUATION * LIGHT_COLOR / PI;
}