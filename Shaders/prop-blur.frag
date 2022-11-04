#version 120

uniform sampler2D gradient_texture;
uniform int num_blades;
uniform float diameter;
uniform float rpm;
uniform float pitch;
uniform int sense;
uniform float blade_width_0;
uniform float blade_width_1;
uniform float blade_width_2;
uniform float blade_width_3;
uniform float blur_onset_rpm;
uniform float blur_full_rpm;
uniform float osg_DeltaFrameTime;

varying vec4 vertex;

float calc_blur_alpha(float pixel_angle, float angle, float noblur_angle, float blur_angle, float alpha_factor) {
	return clamp((1 - abs((pixel_angle - angle - noblur_angle) / blur_angle)) * alpha_factor, 0.0, alpha_factor);
}

void main() {
	float rpm = clamp(rpm - blur_onset_rpm, 0.0, blur_full_rpm);
	float noblur_angle = clamp((rpm - blur_onset_rpm) / 5, 0.0, 360.0) * sense;
	float blur_angle = clamp(rpm / 5, 0.0, 360.0) * sense;
	float d = length(vertex.yz) / diameter * 2.0;
	vec4 base = texture2D(gradient_texture, vec2(d, 0));
	base.a = 0;
	float pixel_angle = degrees(atan(vertex.z, vertex.y)) + 180;
	if (sense == -1) {
		pixel_angle = -360 + pixel_angle;
	}
	
	float angle = 0.0;
	float alpha_factor = 0.6;
	float blade_width = 0.0;
	if (d <= 0.25) {
		blade_width = mix(0.0, blade_width_0, d * 4);
	} else if (d <= 0.5) {
		blade_width = mix(blade_width_0, blade_width_1, (d - 0.25) * 4);
	} else if (d <= 0.75) {
		blade_width = mix(blade_width_1, blade_width_2, (d - 0.5) * 4);
	} else if (d <= 1.0) {
		blade_width = mix(blade_width_2, blade_width_3, (d - 0.75) * 4);
	}
	alpha_factor = blade_width * num_blades / (2 * 3.14159265359 * d * (rpm / 60) * 0.04);

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
	if (base.a < 0.01) {
		discard;
	}
	
	base = base * gl_Color;
	gl_FragColor = base;
}

