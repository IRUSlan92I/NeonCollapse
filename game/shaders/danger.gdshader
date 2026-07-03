shader_type canvas_item;

#include "res://game/shaders/random_color.gdshaderinc"

uniform float chance : hint_range(0.0, 1.0) = 0.3;
uniform float edge_width : hint_range(0, 100) = 4.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR = random_color(screen_color, UV, chance);
	
	float dist_left   = UV.x / fwidth(UV.x);
	float dist_right  = (1.0 - UV.x) / fwidth(UV.x);
	float dist_bottom = UV.y / fwidth(UV.y);
	float dist_top    = (1.0 - UV.y) / fwidth(UV.y);
	float pixel_dist = min(min(dist_left, dist_right), min(dist_bottom, dist_top));
	
	float fade = clamp(pixel_dist / edge_width, 0.0, 1.0);

	COLOR.a *= fade;
}
