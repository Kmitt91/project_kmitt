shader_type spatial;

uniform sampler2D noise_texture : hint_default_white;
uniform sampler2D caustics_mask : hint_default_white;
uniform sampler2D normal_noise_texture : hint_default_white;

uniform vec4 color : source_color;
uniform vec4 color2 : source_color;

uniform float speed = 0.001;
uniform float strength = 0.025;

void fragment() {

	vec4 n1 = texture(noise_texture, UV + TIME * speed);
	vec4 n2 = texture(noise_texture, UV - TIME * speed * 0.5);
	vec2 displ = 0.5 * (n1.xy + n2.xy) * strength;

	vec4 mask = texture(caustics_mask, UV + vec2(0.0, TIME * speed * 4.0) + displ * 4.0);
	vec4 normal_noise = texture(normal_noise_texture, UV * 4.0);

	ALBEDO = 2.0 * mix(color.rgb, color2.rgb,mask.rgb);
	ROUGHNESS = mask.r;
	NORMAL_MAP = mix( color.rgb, color2.rgb,mask.rgb);
}