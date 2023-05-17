#version 130

uniform float diameter;

varying vec4 vertex;

void main() {
	vertex = gl_Vertex;
	vertex.yz *= diameter;
	
	gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	gl_Position = gl_ModelViewProjectionMatrix * vertex;
	gl_FrontColor = gl_Color;
	gl_BackColor = gl_Color;
}
