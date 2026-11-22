// Adapted from YouTube tutorial:
// Ben Cloward - Blur and Sharpen Filter - Shader Graph Basics - Episode 51

shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest, repeat_disable;
//Blur Sharp
uniform float blur_sharp: hint_range(-5.0, 5.0, 0.1) = 0.0;
uniform float pixel: hint_range(1.0, 5.0, 1.0) = 1.0;
uniform float factor: hint_range(0.0, 1.0, 0.01) = 0.7;
uniform int iterations: hint_range(2, 12, 2) = 4;

vec2 rotate(vec2 uv, float angle){
	mat2 rotation = mat2(vec2(sin(angle), cos(angle)), vec2(cos(angle), -sin(angle)));
	uv *= rotation;
	return uv;
}


void fragment() {
	// Screen Coordinates
	vec2 coord = (1.0 / FRAGCOORD.xy) * SCREEN_UV;
	// Screen Sample
	vec3 screen = texture(screen_tex, SCREEN_UV).rgb;
	//Blur Sharp Sample
	vec3 sample_loop = vec3(0.0);
	for (int i = 1; i <= iterations; i++) {
		vec3 i_sample = texture(screen_tex, SCREEN_UV + (coord * rotate(vec2(0.0, pixel), TAU * (1.0 / float(iterations) * float(i))))).rgb;
		sample_loop += i_sample;
	}

	//Combined Samples
	sample_loop /= float(iterations);
	vec3 combined_sample = clamp((screen * (1.0 - factor)) + (sample_loop * factor), 0.0, 1.0);
	//Final COLOR
	vec3 mix_blur_sharp = mix(screen, combined_sample, blur_sharp);
	COLOR.rgb = mix_blur_sharp ;
}
