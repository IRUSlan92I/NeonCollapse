shader_type canvas_item;

uniform float destruction_x = 0.0;
uniform float edge_width = 50.0;
uniform mat4 screen_to_world;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 world_pos = screen_to_world * vec4(FRAGCOORD.xy, 0.0, 1.0);
	float dist = destruction_x - world_pos.x;

	COLOR.a = smoothstep(-edge_width, edge_width, dist);
}
