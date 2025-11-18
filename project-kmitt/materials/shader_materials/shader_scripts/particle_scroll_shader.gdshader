//Written by me Kmitt91, btw. this is by far the most useful vfx shader there is, nearly all my Effects use this simple shader;)

shader_type spatial;
render_mode blend_mix, cull_back, unshaded, shadows_disabled, depth_prepass_alpha, depth_draw_opaque;

uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D pattern_texture : hint_default_white;
uniform sampler2D mask_texture : hint_default_white;

uniform float emission_strength = 1.0;
uniform float speed = 1.0;


void vertex() {
	mat4 mat_world = mat4(normalize(INV_VIEW_MATRIX[0]) * length(MODEL_MATRIX[0]), normalize(INV_VIEW_MATRIX[1]) * length(MODEL_MATRIX[0]),normalize(INV_VIEW_MATRIX[2]) * length(MODEL_MATRIX[2]), MODEL_MATRIX[3]);
	mat_world = mat_world * mat4(vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}



void fragment() {
	vec4 pattern_front = texture(pattern_texture, UV + vec2(0.1, 0.5) * (- TIME * speed));
	vec4 pattern_back = texture(pattern_texture, UV + vec2(0.1, 0.5) * (TIME * speed));
	vec4 mask = texture(mask_texture, UV);

	float pattern_combined = 0.5 * (pattern_front.r + pattern_back.r);

	vec4 col = pattern_combined * mask.a * albedo * 2.0;
	col *= COLOR * COLOR;

	ALBEDO = col.rgb * emission_strength;
	ALPHA = col.a;
}
