#version 330 core

in vec3 frag_color;
in vec3 frag_normal;
out vec3 out_color;

void main()
{
	out_color = frag_color;
}
