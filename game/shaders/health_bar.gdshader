shader_type canvas_item;

uniform float max_value;
uniform float current_value;
uniform float old_value;

uniform vec4 health_color : source_color = vec4(0.0, 0.65, 0.0, 1.0);
uniform vec4 depletion_color : source_color = vec4(0.0, 0.3, 0.0, 1.0);
uniform vec4 restoration_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);

void fragment() {
	float fill = current_value / max_value;
	float old_fill = old_value / max_value;
	
	vec4 color;
	
	if (current_value <= old_value) {
		if (UV.x < fill) {
			color = health_color;
		} else if (UV.x < old_fill) {
			color = depletion_color;
		} else {
			color = background_color;
		}
	} else {
		if (UV.x < old_fill) {
			color = health_color;
		} else if (UV.x < fill) {
			color = restoration_color;
		} else {
			color = background_color;
		}
	}
	
	COLOR = vec4(color.rgb, color.a * COLOR.a);
}
