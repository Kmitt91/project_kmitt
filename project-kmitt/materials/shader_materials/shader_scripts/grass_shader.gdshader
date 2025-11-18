shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha, depth_draw_opaque, diffuse_toon;

uniform vec4 color : source_color;
uniform sampler2D color_ramp : hint_default_white;
uniform sampler2D mask_texture : hint_default_white;
uniform float value = 1.0;

uniform float speed = 1.0;
uniform float minStrength : hint_range(0.0, 1.0) = 0.3;
uniform float maxStrength : hint_range(0.0, 1.0) = 0.5;
uniform float interval = 3.5;
uniform float detail = 2.0;
uniform float distortion = 0.75;

vec3 wind(mat4 matrix, vec3 vertex){
	vec4 pos = matrix * mix(vec4(1.0), vec4(vertex.x, 0.0, vertex.z, 1.0), distortion);
	float time = TIME * speed + pos.x + pos.z;
	float diff = (maxStrength - minStrength) * (maxStrength - minStrength);
	float strength = clamp(minStrength + diff + sin(time / interval) * diff, minStrength, maxStrength);
	float wind = (sin(time) + cos(time * detail)) * strength * max(0.0, vertex.y);
	
	return vec3(wind * normalize(vec2(1.0)).x, 0.0, wind * normalize(vec2(1.0)).y);
}


void vertex() {
	
	VERTEX += wind(MODEL_MATRIX, VERTEX);
}

void fragment() {
	//float side = FRONT_FACING ? 1.0 : -1.0;
	//NORMAL = NORMAL * side;
	//if (!FRONT_FACING){
		//NORMAL = -NORMAL;
	//}
	
	vec3 col = texture(color_ramp, vec2(1.0 - UV.y, 0.0)).rgb;
	vec4 mask = texture(mask_texture, UV + vec2(0.0, 0.01));
	
	ALBEDO = value * col * mask.rgb * color.rgb * COLOR.rgb;
	ALPHA *= mask.a;
	
	vec3 world_camera = (INV_VIEW_MATRIX * vec4(vec3(0.0), 1.0)).xyz;
	vec4 a = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	float world_distance = distance(a.xyz, world_camera);
	
	ALPHA_SCISSOR_THRESHOLD = mix(0.5, 0.2, smoothstep(1.0, 30.0, world_distance));
	//EMISSION = ALBEDO * 0.04;
}


