#version 330 core

layout(location = 0) in vec3 vertex;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec3 color;

uniform mat4 _transform_model;
uniform mat4 _transform_view;
uniform mat4 _transform_perspective;

out vec3 frag_color;
out vec3 frag_normal;

void main()
{
	frag_color = color;
	frag_normal = normal;
	gl_Position = _transform_perspective * _transform_view * _transform_model * vec4( vertex.x, vertex.y, vertex.z, 1 );
}
