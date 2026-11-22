
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform float blur_radius : hint_range(0.0, 8.0, 0.1) = 3.0;

void fragment() {
    vec2 pixel = SCREEN_PIXEL_SIZE * blur_radius;

    vec3 color = vec3(0.0);

    // Centro
    color += texture(screen_texture, SCREEN_UV).rgb * 0.227027;

    // Horizontal
    color += texture(screen_texture, SCREEN_UV + vec2(pixel.x * 1.384615, 0.0)).rgb * 0.158108;
    color += texture(screen_texture, SCREEN_UV - vec2(pixel.x * 1.384615, 0.0)).rgb * 0.158108;

    color += texture(screen_texture, SCREEN_UV + vec2(pixel.x * 3.230769, 0.0)).rgb * 0.070270;
    color += texture(screen_texture, SCREEN_UV - vec2(pixel.x * 3.230769, 0.0)).rgb * 0.070270;

    // Vertical
    color += texture(screen_texture, SCREEN_UV + vec2(0.0, pixel.y * 1.384615)).rgb * 0.158108;
    color += texture(screen_texture, SCREEN_UV - vec2(0.0, pixel.y * 1.384615)).rgb * 0.158108;

    color += texture(screen_texture, SCREEN_UV + vec2(0.0, pixel.y * 3.230769)).rgb * 0.070270;
    color += texture(screen_texture, SCREEN_UV - vec2(0.0, pixel.y * 3.230769)).rgb * 0.070270;

    COLOR = vec4(color, 1.0);
}
