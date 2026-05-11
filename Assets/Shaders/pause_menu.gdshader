shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 8.0) = 3.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 px = SCREEN_PIXEL_SIZE * blur_strength;

    vec4 color = vec4(0.0);
    color += texture(SCREEN_TEXTURE, uv + vec2(-px.x, 0.0));
    color += texture(SCREEN_TEXTURE, uv + vec2(px.x, 0.0));
    color += texture(SCREEN_TEXTURE, uv + vec2(0.0, -px.y));
    color += texture(SCREEN_TEXTURE, uv + vec2(0.0, px.y));
    color += texture(SCREEN_TEXTURE, uv);

    color /= 5.0;
    COLOR = color;
}
