shader_type canvas_item;

uniform vec4 glow_color = vec4(1.0, 1.0, 0.3, 1.0);
uniform float glow_size = 2.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // base alpha
    float base_a = tex_color.a;

    // expanded alpha for halo
    float step = glow_size * TEXTURE_PIXEL_SIZE.x;

    float a = base_a;
    a = max(a, texture(TEXTURE, UV + vec2(step, 0.0)).a);
    a = max(a, texture(TEXTURE, UV + vec2(-step, 0.0)).a);
    a = max(a, texture(TEXTURE, UV + vec2(0.0, step)).a);
    a = max(a, texture(TEXTURE, UV + vec2(0.0, -step)).a);

    float halo = max(0.0, a - base_a); // only outside

    vec4 halo_col = glow_color * halo;
    COLOR = tex_color + halo_col;
}