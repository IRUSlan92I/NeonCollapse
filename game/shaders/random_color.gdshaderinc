const int MAX_PALETTE_SIZE = 8;

uniform vec3 palette[MAX_PALETTE_SIZE] : source_color;
uniform int palette_size : hint_range(1, MAX_PALETTE_SIZE) = 1;


float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec4 random_color(vec4 current_color, vec2 uv, float chance)
{
	vec2 seed = uv * fract(TIME);
	float random_value = hash(seed);
	if (chance != 0.0 && random_value < chance) {
		float index_rand = hash(seed + vec2(0.5, 0.5));
		int index = int(index_rand * float(palette_size)) % palette_size;
		current_color.rgb = palette[index];
	}
	return current_color;
}
