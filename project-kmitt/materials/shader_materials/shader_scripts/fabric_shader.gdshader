//this shader was written by me a long time ago and extended by time, the original was from my cape shader tutorial on YT: https://youtu.be/H3fQbefqsu8
shader_type spatial;
render_mode cull_disabled, blend_mix;

uniform vec4 color : source_color;
uniform float col_value = 1.0;

uniform sampler2D fabric_albedo_tex : hint_default_white;
uniform sampler2D fabric_roughness_tex : hint_roughness_r;
uniform sampler2D fabric_normalmap_tex : hint_normal;

uniform sampler2D cape_texture : hint_default_white;
uniform sampler2D cape_normalmap_texture : hint_normal;
uniform sampler2D noise_texture : hint_default_black;

uniform float normal_strength = 1.0;
uniform float roughness : hint_range(0, 1) = 1.0;
uniform float strength = 0.15;
uniform float speed = 0.3;


void vertex() {

	vec2 scaled_uv = UV * vec2(0.3);
	float noise = texture(noise_texture, scaled_uv + vec2(TIME * speed, 0.0)).r;
//	float noise = texture(noise_texture, scaled_uv + vec2(1.0, 0.0),4.0).r;

	float displacement = (noise * 2.0 - 1.0) * strength;
	displacement *= UV.y;

	VERTEX += vec3(displacement, 0.0, 0.5 * -displacement);
}


void fragment() {
	float side = FRONT_FACING ? 1.0 : -1.0;
	NORMAL = NORMAL * side;

	vec4 cape = texture(cape_texture, UV);
	vec4 fabric = texture(fabric_albedo_tex, UV * 2.0);
	float noise = texture(noise_texture, UV * 0.3 + vec2(TIME * speed, 0.0)).r;

	ALBEDO = cape.rgb * fabric.rgb * clamp(noise, 0.5, 1.0) * color.rgb * col_value;
//	EMISSION = ALBEDO * 0.1;
	ROUGHNESS = texture(fabric_roughness_tex, UV*2.0).r * roughness;
	//ALPHA *= cape.a;
	//ALPHA_SCISSOR_THRESHOLD = 0.5;
	NORMAL_MAP = texture(cape_normalmap_texture, UV).rgb * texture(fabric_normalmap_tex, UV*2.0, 1.0).rgb;
	NORMAL_MAP_DEPTH = normal_strength;
}