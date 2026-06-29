shader_type canvas_item;

uniform float corruption_x = 0.0;
uniform float edge_width = 50.0;
uniform mat4 screen_to_world;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

	float gray = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 bw = vec3(gray);

	vec4 world_pos = screen_to_world * vec4(FRAGCOORD.xy, 0.0, 1.0);

	float dist = world_pos.x - corruption_x;
	float t = smoothstep(-edge_width, edge_width, dist);

	COLOR.rgb = mix(bw, screen_color.rgb, t);
	COLOR.a = screen_color.a;
}
