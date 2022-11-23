#version 120

uniform sampler2D gradient_texture;
uniform int num_blades;
uniform float diameter;
uniform float rpm;
uniform float pitch;
uniform float blade_width_0;
uniform float blade_width_1;
uniform float blade_width_2;
uniform float blade_width_3;
uniform float blur_onset_rpm;
uniform float blur_full_rpm;
uniform float osg_DeltaFrameTime;
uniform int fogType;

varying vec4 vertex;
varying vec4 diffuse_term;
varying vec3 normal;


vec3 fog_Func(vec3 color, int type);
float getShadowing();
vec3 getClusteredLightsContribution(vec3 p, vec3 n, vec3 texel);

float luminance(vec3 color)
{
    return dot(vec3(0.212671, 0.715160, 0.072169), color);
}

float calc_blur_alpha(float pixel_angle, float angle, float blur_angle, float alpha_factor) {
	return clamp((abs((pixel_angle - angle - blur_angle) / blur_angle)) * alpha_factor, 0.0, alpha_factor);
}

void main() {
	float rpm = clamp(rpm - blur_onset_rpm, 0.0, blur_full_rpm - blur_onset_rpm);
	float noblur_angle = clamp(rpm / ((blur_full_rpm - blur_onset_rpm) / (180 / num_blades)), 0.0, 360.0);
	float blur_angle = noblur_angle * 0.25;
	float d = length(vertex.yz) / diameter * 2.0;
	vec4 base = texture2D(gradient_texture, vec2(d, 0));
	base.a = 0;
	float pixel_angle = degrees(atan(vertex.z, vertex.y)) + 180;
	
	float angle = 0.0;
	float alpha_factor = 0.6;
	float blade_width = 0.0;
	if (d <= 0.25) {
		alpha_factor = mix(1.0, blade_width_0 * num_blades / (2 * 3.14159265359 * d * (rpm / 60) * 0.06), d * 4);
	} else {
		if (d <= 0.5) {
			blade_width = mix(blade_width_0, blade_width_1, (d - 0.25) * 4);
		} else if (d <= 0.75) {
			blade_width = mix(blade_width_1, blade_width_2, (d - 0.5) * 4);
		} else if (d <= 1.0) {
			blade_width = mix(blade_width_2, blade_width_3, (d - 0.75) * 4);
		}
		alpha_factor = blade_width * num_blades / (2 * 3.14159265359 * d * (rpm / 60) * 0.06);
	}

	while (angle <= 360.0) {
		float pixel_angle_delta_blade = abs(pixel_angle - angle);
		if (pixel_angle_delta_blade <= 180.0 / num_blades) {
			if (pixel_angle_delta_blade < noblur_angle) {
				base.a = alpha_factor;
			} else if (pixel_angle_delta_blade < noblur_angle + blur_angle) {
				base.a = calc_blur_alpha(pixel_angle_delta_blade, noblur_angle, blur_angle, alpha_factor);
			}
		}
		angle += 360.0 / num_blades;
	}
	if (base.a < 0.01) {
		discard;
	}
	
	vec3 n;
	float NdotL, NdotHV, fogFactor;
	vec4 color = gl_Color;
	vec3 lightDir = gl_LightSource[0].position.xyz;
	vec3 halfVector = gl_LightSource[0].halfVector.xyz;
	vec4 fragColor;
	vec4 specular = vec4(0.0);

	// If gl_Color.a == 0, this is a back-facing polygon and the
	// normal should be reversed.
	n = (2.0 * gl_Color.a - 1.0) * normal;
	n = normalize(n);

	NdotL = dot(n, lightDir);
	if (NdotL > 0.0) {
		float shadowmap = getShadowing();
		color += diffuse_term * NdotL * shadowmap;
		NdotHV = max(dot(n, halfVector), 0.0);
		if (gl_FrontMaterial.shininess > 0.0) {
			specular.rgb = (gl_FrontMaterial.specular.rgb
						* gl_LightSource[0].specular.rgb
						* pow(NdotHV, gl_FrontMaterial.shininess)
						* shadowmap);
		}
	}
	color.a = diffuse_term.a;
	// This shouldn't be necessary, but our lighting becomes very
	// saturated. Clamping the color before modulating by the texture
	// is closer to what the OpenGL fixed function pipeline does.
	color = clamp(color, 0.0, 1.0);

	fragColor = color * base + specular;
	//fragColor.rgb += getClusteredLightsContribution(vertex.xyz, n, base.rgb);

	fragColor.rgb = fog_Func(fragColor.rgb, fogType);
	gl_FragColor = fragColor;
}

