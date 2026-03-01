shader_type spatial;

uniform sampler2D Albedo: source_color;
uniform float albedo_scale = 0.2;
uniform float contrast = 1.5;

uniform vec3 Color: source_color = vec3(1.0);
uniform vec3 ColorAlt: source_color = vec3(0.8);
uniform float checkerboard_scale = 0.1;
uniform float blur: hint_range(0.0, 0.5, 0.01) = 0.1;

uniform float wind_speed = 4;
uniform float wind_intensity: hint_range(0.0, 0.1, 0.005) = 0.01;

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	
	// doesn't appear at x=0 / z=0, might be a problem with mod
	float checkerboard_edge_wobble =
		  sin(world_position.x * 12.3) * 0.002
		+ sin(world_position.z * 12.3) * 0.002;
	
	// checkerboard pattern
	vec2 mod_pos_a = mod(
		  world_position.xz * checkerboard_scale
		+ checkerboard_edge_wobble,
	1.0);

	vec3 a = vec3(
		  smoothstep(0.5, 0.5 + blur, mod_pos_a.x)
		+ smoothstep(blur,       0.0, mod_pos_a.x)
	) * vec3(
		  smoothstep(0.5, 0.5 + blur, mod_pos_a.y)
		+ smoothstep(blur,       0.0, mod_pos_a.y)
	);
	
	vec2 mod_pos_b = mod(
		  world_position.xz * checkerboard_scale + vec2(0.5)
		+ checkerboard_edge_wobble,
	1.0);
	
	vec3 b = vec3(
		  smoothstep(0.5, 0.5 + blur, mod_pos_b.x)
		+ smoothstep(blur,       0.0, mod_pos_b.x)
	) * vec3(
		  smoothstep(0.5, 0.5 + blur, mod_pos_b.y)
		+ smoothstep(blur,       0.0, mod_pos_b.y)
	);
	
	// color and texture
	vec2 uv = world_position.xz * albedo_scale + sin(TIME * wind_speed + world_position.x) * wind_intensity;
	
	ALBEDO = pow(texture(Albedo, uv).rgb, vec3(contrast)) * mix(Color, ColorAlt, a + b);
}

void light() {
	DIFFUSE_LIGHT += mix(0.5, 1.0, smoothstep(-0.1, 0.1, dot(NORMAL, LIGHT))) * ATTENUATION * LIGHT_COLOR / PI;
}