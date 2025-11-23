shader_type spatial;

uniform vec4 mask_color : source_color;
uniform vec4 emission_color : source_color;
uniform sampler2D gradient_texture : hint_default_white;
uniform sampler2D mask;
uniform sampler2D noise;
uniform float emission_strength = 2.0;
uniform float speed = 0.03;

void fragment(){

	ALBEDO = mask_color.rgb;

	vec3 gradient_color = texture(gradient_texture, vec2((1.0 - UV.y), 0.0)).rgb;
	vec4 scrolling_noise = texture(noise, UV + vec2(TIME * speed)) * texture(noise, UV + vec2(-TIME * speed)) * 2.0;
	EMISSION = texture(mask,UV).rgb * (smoothstep(scrolling_noise.r, 1.0, 0.6) + 0.04);
	EMISSION *= emission_color.rgb * gradient_color * emission_strength;
}
