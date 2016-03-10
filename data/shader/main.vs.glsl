#version 330 core

layout(location = 0) in vec3 vertex;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec3 color;
layout(location = 3) in float light;

uniform mat4 _transform_model;
uniform mat4 _transform_view;
uniform mat4 _transform_perspective;

out vec3 frag_color;
out vec3 frag_normal;
out float frag_light;

void main()
{
	frag_color = color;
	frag_light = light;
	frag_normal = (_transform_model * vec4( normal, 0.0 )).xyz;
	gl_Position = _transform_perspective * _transform_view * _transform_model * vec4( vertex.x, vertex.y, vertex.z, 1 );
}
