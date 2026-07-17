shader_type canvas_item;

render_mode light_only;
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    COLOR = texture(screen_texture, SCREEN_UV);
}