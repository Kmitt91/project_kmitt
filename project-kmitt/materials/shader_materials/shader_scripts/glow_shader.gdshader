//simple glow shader, written by me Kmitt91 :))

shader_type spatial;

render_mode unshaded, shadows_disabled;

uniform vec4 color : source_color;
uniform float emission_strength = 16.0;

void fragment() {
	ALBEDO = color.rgb * emission_strength;
}
