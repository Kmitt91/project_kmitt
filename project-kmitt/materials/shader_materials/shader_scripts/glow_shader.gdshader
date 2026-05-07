//simple glow shader, written by me Kmitt91 :))

shader_type spatial;

render_mode unshaded, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0);
uniform sampler2D color_gradient_texture : hint_default_white;
uniform float emission_strength = 16.0;
uniform float alpha_multiply = 1.0;

uniform sampler2D noise_tex : hint_default_black, repeat_enable;
uniform float strengh = 0.1;
uniform float frequency = 0.2;
uniform float time_factor = 0.1;

void vertex() {
	float texture_based_offset = texture(noise_tex, UV * frequency + TIME * time_factor).x * 2.0 - 1.0;
	VERTEX.yx += texture_based_offset * strengh * (1.0 - UV.y);
}

void fragment() {
	vec4 color_gradient = texture(color_gradient_texture, vec2(1.0 - UV.y, 0.0));
	ALBEDO = color.rgb * color_gradient.rgb * emission_strength;
	ALPHA = color_gradient.r * alpha_multiply;
}
