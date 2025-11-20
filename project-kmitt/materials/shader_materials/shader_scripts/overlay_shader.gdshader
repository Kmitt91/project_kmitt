//Shader writen by me "Kmitt91" as usual. I joinked the code for the triplanar mapping from the StandartMaterial Shader XD
//For more about triplanar mapping watch my YT-Tutorial: https://www.youtube.com/watch?v=yaxNGUf1FUs

shader_type spatial;
render_mode blend_mix, diffuse_toon;

uniform sampler2D noise_texture_overlay : hint_default_black;
uniform sampler2D albedo_texture : hint_default_white;
uniform sampler2D texture_normal : hint_default_white;

uniform vec4 color_modulate : source_color;
uniform float normal_strength = 1.0;
uniform float value = 1.0;

//triplanar variables
varying vec3 uv1_triplanar_pos;
uniform float uv1_blend_sharpness = 4.0;
varying vec3 uv1_power_normal;
uniform float uv1_scale = 0.01;


//uniform float min_dist = 0.0;
//uniform float max_dist = 50.0;

void vertex(){
	//could be mixed up with recalc but works;)
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);

	BINORMAL = vec3(0.0,-1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,-1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);

	uv1_power_normal = pow(abs(mat3(MODEL_MATRIX) * NORMAL),vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz * uv1_scale;
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	// I commented this out, since the level layout is mostly facing to the x-axis, meaning its going alnong the z-axis
	//samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

void fragment(){
	vec4 albedo_tex = triplanar_texture(albedo_texture, uv1_power_normal, uv1_triplanar_pos * 16.0);
	//get distance to camera
	vec3 world_camera = (INV_VIEW_MATRIX * vec4(vec3(0.0), 1.0)).xyz;
	vec4 a = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	float world_distance = distance(a.xyz, world_camera);

	ALBEDO = value * color_modulate.rgb * albedo_tex.rgb;//mix(color_a.rgb, color_b.rgb, albedo_tex.r);
	ALPHA = triplanar_texture(noise_texture_overlay, uv1_power_normal, uv1_triplanar_pos).r;
	//for more realism it's useful to unpack normal and recalc, but not needed here
	NORMAL_MAP = triplanar_texture(texture_normal, uv1_power_normal, uv1_triplanar_pos * 16.0).rgb;
	NORMAL_MAP_DEPTH = normal_strength;
	//ALPHA = mix(triplanar_texture(noise_texture_overlay, uv1_power_normal, uv1_triplanar_pos + TIME * speed).r,
				//0.0,
				//smoothstep(min_dist, max_dist, world_distance));
}