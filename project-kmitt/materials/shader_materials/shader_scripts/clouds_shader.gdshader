shader_type spatial;
render_mode unshaded, shadows_disabled;

//fragment variables
uniform vec3 color : source_color;
uniform sampler2D noise_texture1;
uniform sampler2D noise_texture2;
uniform float mix_value: hint_range(0.0, 1.0, 0.2) = 0.2;
uniform vec2 direction = vec2(1.0, 0.0);
uniform float speed = 0.015;
uniform float scale = 1.6;

//waves variables: from my old yt tutorial: https://godotshaders.com/shader/stylized-water-shader/
uniform vec2 wave_strengh = vec2(1.0, 0.5);
uniform vec2 wave_frequency = vec2(12.0, 12.0);
uniform vec2 time_factor = vec2(1.0, 2.0);

//proximity fade variables from Standartmaterial
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform float proximity_fade_distance = 1.0;

//circle mask
float circle(vec2 position, float radius, float feather){
	return smoothstep(radius, radius - feather, length(position - vec2(0.5)));
}

//waves() + vertex(): from my old yt tutorial: https://godotshaders.com/shader/stylized-water-shader/
float waves(vec2 pos, float time){
	return (wave_strengh.y * sin(pos.y * wave_frequency.y + time * time_factor.y)) + (wave_strengh.x * sin(pos.x * wave_frequency.x + time * time_factor.x));
}
void vertex(){
	VERTEX.y += waves(VERTEX.xy, TIME);
}

//fragment, blending noise together
void fragment() {
	vec2 time = (TIME * direction) * speed;
	vec3 noise1 = texture(noise_texture1, UV * scale + time).rgb;
	vec3 noise2 = texture(noise_texture2, UV * scale - time).rgb;
	vec3 noise_mix = mix(noise1, noise2, mix_value);

	ALBEDO = color + (noise_mix.rgb * 0.7);
	ALPHA = noise_mix.r * vec3(circle(UV, 0.4, 0.33)).r;

//proximity fade code from Standartmaterial
	float depth_tex = textureLod(depth_texture,SCREEN_UV,0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth_tex,1.0);
	world_pos.xyz/=world_pos.w;
	ALPHA*=clamp(1.0-smoothstep(world_pos.z+proximity_fade_distance,world_pos.z,VERTEX.z),0.0,1.0);
}
