shader_type spatial;

uniform sampler2D Albedo: source_color;
uniform vec3 Color: source_color = vec3(1.0);

void fragment() {
	ALBEDO = texture(Albedo, UV).rgb * Color;
}

void light() {
	DIFFUSE_LIGHT += mix(0.5, 1.0, smoothstep(-0.1, 0.1, dot(NORMAL, LIGHT))) * ATTENUATION * LIGHT_COLOR / PI;
}