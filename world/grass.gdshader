shader_type spatial;

uniform sampler2D Albedo: source_color;
uniform float albedo_scale = 0.2;
uniform float contrast = 1.5;
uniform vec3 Color: source_color = vec3(1.0);
uniform vec3 ColorAlt: source_color = vec3(0.8);
uniform float checkerboard_scale = 0.1;
uniform float blur: hint_range(0.0, 0.5, 0.01) = 0.1;

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	
	// checkerboard pattern
	vec2 mod_pos_a = mod(world_position.xz * checkerboard_scale, 1.0);

	vec3 a = vec3(
		  smoothstep(0.5, 0.5 + blur, mod_pos_a.x)
		+ smoothstep(blur,       0.0, mod_pos_a.x)
	) * vec3(
		  smoothstep(0.5, 0.5 + blur, mod_pos_a.y)
		+ smoothstep(blur,       0.0, mod_pos_a.y)
	);
	
	vec2 mod_pos_b = mod(world_position.xz * checkerboard_scale + vec2(0.5), 1.0);
	
	vec3 b = vec3(
		  smoothstep(0.5, 0.5 + blur, mod_pos_b.x)
		+ smoothstep(blur,       0.0, mod_pos_b.x)
	) * vec3(
		  smoothstep(0.5, 0.5 + blur, mod_pos_b.y)
		+ smoothstep(blur,       0.0, mod_pos_b.y)
	);
	
	// color and texture
	vec2 uv = world_position.xz * albedo_scale + sin(TIME * 2.0 + world_position.x) * 0.01;
	
	ALBEDO = pow(texture(Albedo, uv).rgb, vec3(contrast)) * mix(Color, ColorAlt, a + b);
}

void light() {
	DIFFUSE_LIGHT += mix(0.5, 1.0, smoothstep(-0.1, 0.1, dot(NORMAL, LIGHT))) * ATTENUATION * LIGHT_COLOR / PI;
}