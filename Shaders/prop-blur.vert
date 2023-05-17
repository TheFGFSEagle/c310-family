#version 130
#define MODE_OFF 0
#define MODE_DIFFUSE 1
#define MODE_AMBIENT_AND_DIFFUSE 2

uniform float diameter;

varying vec4 vertex;
varying vec4 diffuse_term;
varying vec3 normal;

uniform int colorMode;

void setupShadows(vec4 eyeSpacePos);

void main() {
	vertex = gl_Vertex;
	vertex.yz *= diameter;
	gl_Position = gl_ModelViewProjectionMatrix * vertex;
	gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	normal = gl_NormalMatrix * gl_Normal;
	vec4 ambient_color, diffuse_color;
	if (colorMode == MODE_DIFFUSE) {
		diffuse_color = gl_Color;
		ambient_color = gl_FrontMaterial.ambient;
	} else if (colorMode == MODE_AMBIENT_AND_DIFFUSE) {
		diffuse_color = gl_Color;
		ambient_color = gl_Color;
	} else {
		diffuse_color = gl_FrontMaterial.diffuse;
		ambient_color = gl_FrontMaterial.ambient;
	}
	diffuse_term = diffuse_color * gl_LightSource[0].diffuse;
	vec4 constant_term = gl_FrontMaterial.emission + ambient_color *
						(gl_LightModel.ambient +  gl_LightSource[0].ambient);
	// Super hack: if diffuse material alpha is less than 1, assume a
	// transparency animation is at work
	if (gl_FrontMaterial.diffuse.a < 1.0) {
		diffuse_term.a = gl_FrontMaterial.diffuse.a;
	} else {
		diffuse_term.a = gl_Color.a;
	}
	// Another hack for supporting two-sided lighting without using
	// gl_FrontFacing in the fragment shader.
	gl_FrontColor.rgb = constant_term.rgb;  gl_FrontColor.a = 1.0;
	gl_BackColor.rgb = constant_term.rgb; gl_BackColor.a = 0.0;
	setupShadows(vertex);
}
