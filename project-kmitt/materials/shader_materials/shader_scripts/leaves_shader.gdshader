//All written by me Kmitt91, hehe

shader_type spatial;
render_mode blend_mix, cull_disabled, diffuse_toon, specular_disabled;

uniform float strengh = 0.1;
uniform float frequency = 0.2;
uniform float time_factor = 0.1;

uniform vec4 color : source_color;
uniform sampler2D gradient : hint_default_black;
uniform sampler2D leaves_tex : hint_default_white;
uniform sampler2D noise_tex : hint_default_black, repeat_enable;

uniform float value = 1.0;

void vertex(){
	float texture_based_offset = texture(noise_tex, UV * frequency + TIME * time_factor).x * 2.0 - 1.0;
	VERTEX += texture_based_offset * strengh * (1.0 - UV.y);
}

void fragment(){
	vec4 albedo_tex = texture(leaves_tex, UV);
	vec4 grad_col = texture(gradient, UV);
	vec4 noise = texture(noise_tex, UV2 * frequency  * 2.0 + TIME * time_factor);

	ALBEDO = value * grad_col.rgb * albedo_tex.rgb * color.rgb;// * (noise.r + 0.5);

	ALPHA *= albedo_tex.a;

	//get distance to camera
	vec3 world_camera = (INV_VIEW_MATRIX * vec4(vec3(0.0), 1.0)).xyz;
	vec4 a = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	float world_distance = distance(a.xyz, world_camera);

	ALPHA_SCISSOR_THRESHOLD = mix(0.5, 0.3, smoothstep(1.0, 30.0, world_distance));
}