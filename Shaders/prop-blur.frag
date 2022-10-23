#version 120
uniform sampler2D gradient_texture;
uniform int num_blades;
uniform float rpm;
uniform int sense;
varying vec4 vertex;

float calc_blur_alpha(float pixel_angle, float angle, float noblur_angle, float blur_angle, float alpha_factor) {
	return clamp((1 - abs((pixel_angle - angle - noblur_angle) / blur_angle)) * alpha_factor, 0.0, alpha_factor);
}

void main() {
	float rpm = clamp(rpm - 250, 0.0, 5000.0);
	float noblur_angle = clamp((rpm - 250) / 5, 0.0, 360.0) * sense;
	float blur_angle = clamp(rpm / 5, 0.0, 360.0) * sense;
	float d = distance(vec2(0, 0), vertex.yz) * 2.0;
	vec4 base = texture2D(gradient_texture, vec2(d, 0));
	base.a = 0;
	float pixel_angle = degrees(atan(vertex.z, vertex.y)) + 180;
	if (sense == -1) {
		pixel_angle = -360 + pixel_angle;
	}
	float angle = 0.0;
	float alpha_factor = 0.6;
	while (angle * sense < 540.0) {
		if ((angle * sense <= pixel_angle * sense && pixel_angle * sense <= (angle + noblur_angle) * sense)) {
			base.a = alpha_factor;
		} else if (((angle + noblur_angle) * sense <= pixel_angle * sense) && (pixel_angle * sense <= (angle + noblur_angle + blur_angle) * sense)) {
			base.a = calc_blur_alpha(pixel_angle, angle, noblur_angle, blur_angle, alpha_factor);
		} else if (angle * sense - (360.0 * sense / num_blades) + noblur_angle * sense <= pixel_angle && angle * sense - min(blur_angle * sense, 10) * sense <= pixel_angle * sense && pixel_angle * sense <= angle * sense) {
			base.a = mix(alpha_factor, calc_blur_alpha(angle + (360.0 / num_blades - 10) * sense, angle, noblur_angle, blur_angle, alpha_factor), abs((pixel_angle - angle) / min(blur_angle * sense, 10)));
		}
		angle += sense * 360.0 / num_blades;
	}
	//base.a *= clamp(1 / clamp(rpm, 0.5, 999999) * 800, 0.4, 1);
	base.a = clamp(base.a * pow(1 - d / 1.5, 2) * 1.1, 0, 0.8);
	if (base.a < 0.01) {
		discard;
	}
	base = base * gl_Color;
	gl_FragColor = base;
}

