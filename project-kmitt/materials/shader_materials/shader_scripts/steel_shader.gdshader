//written by me
shader_type spatial;
render_mode blend_mix;

uniform float normal_scale = 1.0;
uniform float reflection_value : hint_range(0,1) = 0.8;

uniform vec4 color : source_color;
uniform sampler2D albedo_tex : hint_default_white;
uniform sampler2D noise_tex : hint_default_white;
uniform sampler2D normal_tex : hint_default_white;
uniform sampler2D roughness_tex : hint_default_white;

void fragment(){
	float noise = texture(noise_tex, UV).r;
	
	ALBEDO = texture(albedo_tex, UV).rgb * noise * color.rgb;
	ROUGHNESS = texture(roughness_tex, UV).r * 1.25;

	METALLIC = reflection_value;
	SPECULAR = reflection_value * 0.5;

	NORMAL_MAP = texture(normal_tex, UV).rgb;
	NORMAL_MAP_DEPTH = normal_scale * round(noise);
}