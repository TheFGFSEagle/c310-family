#version 120
uniform sampler2D gradient_texture;
uniform int num_blades;
uniform float rpm;
uniform int sense;
varying vec4 vertex;

void main() {
	float noblur_angle = clamp((rpm - 500) / 10, 0.0, 360.0) * sense;
	float blur_angle = clamp(rpm / 16, 0.0, 360.0) * sense;
	float d = distance(vec2(0, 0), vertex.yz) * 2.0;
	vec4 base = texture2D(gradient_texture, vec2(d, 0));
	base.a = 0;
	float pixel_angle = degrees(atan(vertex.z, vertex.y)) + 180;
	if (sense == -1) {
		pixel_angle = -360 + pixel_angle;
	}
	float angle = 0.0;
	float alpha_factor = 0.5;
	while (angle * sense < 360.0) {
		if ((angle * sense <= pixel_angle * sense && pixel_angle * sense <= (angle + noblur_angle) * sense)) {
			base.a = alpha_factor;
		} else if (((angle + noblur_angle) * sense <= pixel_angle * sense) && (pixel_angle * sense <= (angle + noblur_angle + blur_angle) * sense)) {
			base.a = clamp((1 - abs((pixel_angle - angle - noblur_angle) / blur_angle)) * alpha_factor, 0.0, alpha_factor);
		}
		angle += sense * 360.0 / num_blades;
	}
	base.a *= clamp(1 / clamp(rpm, 0.5, 999999) * 800, 0.4, 1);
	base.a = clamp(base.a, 0, 0.8);
	if (base.a < 0.01) {
		discard;
	}
	base = base * gl_Color;
	gl_FragColor = base;
};

