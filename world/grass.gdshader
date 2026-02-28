shader_type spatial;

uniform sampler2D Albedo: source_color;
uniform vec3 Color: source_color = vec3(1.0);
uniform float contrast = 1.5;
uniform float uv_scale = 0.2;

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	
	vec2 uv = world_position.xz * uv_scale + sin(TIME * 2.0 + world_position.x) * 0.01;
	
	ALBEDO = pow(texture(Albedo, uv).rgb, vec3(contrast)) * Color;
	
	// checkerboard pattern
	vec2 mod_pos_a = mod(world_position.xz * uv_scale, 1.0);

	vec3 a = vec3(
		smoothstep(0.55, 0.65, mod_pos_a.x)
		+ smoothstep(0.1, 0.0, mod_pos_a.x)
	) * vec3(
		smoothstep(0.55, 0.65, mod_pos_a.y)
		+ smoothstep(0.1, 0.0, mod_pos_a.y)
	);
	
	vec2 mod_pos_b = mod(world_position.xz * uv_scale + vec2(0.5), 1.0);
	
	vec3 b = vec3(
		smoothstep(0.55, 0.65, mod_pos_b.x)
		+ smoothstep(0.1, 0.0, mod_pos_b.x)
	) * vec3(
		smoothstep(0.55, 0.65, mod_pos_b.y)
		+ smoothstep(0.1, 0.0, mod_pos_b.y)
	);

	ALBEDO *= (a + b) * 0.2 + 0.8;
}

void light() {
	DIFFUSE_LIGHT += mix(0.5, 1.0, smoothstep(-0.1, 0.1, dot(NORMAL, LIGHT))) * ATTENUATION * LIGHT_COLOR / PI;
}