shader_type canvas_item;
uniform vec2 mask_size = vec2(28.0, 28.0);
varying vec2 mask_position;
void vertex() {
 mask_position = VERTEX;
}
void fragment() {
 vec4 sample_color = texture(TEXTURE, UV) * COLOR;
 vec2 point = mask_position / mask_size;
 sample_color.a *= 1.0 - step(0.5, length(point - vec2(0.5)));
 COLOR = sample_color;
}
