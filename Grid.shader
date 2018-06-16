shader_type spatial;

uniform vec2 scale = vec2(1.0, 1.0);

void fragment() {
	vec2 tens = mod(UV * 10.0 * scale, 1.0);
	vec2 hundreds = mod(UV * 100.0 * scale, 1.0);
	
	if (tens.x < 0.005 || tens.x > 0.995 || hundreds.x < 0.01 || hundreds.x > 0.98) {
		ALBEDO = vec3(1.0, 1.0, 1.0);
	} else if (tens.y < 0.005 || tens.y > 0.995 || hundreds.y < 0.01 || hundreds.y > 0.98) {
		ALBEDO = vec3(1.0, 1.0, 1.0);
	} else {
		ALBEDO = vec3(0.2, 0.2, 0.2);
	}
}