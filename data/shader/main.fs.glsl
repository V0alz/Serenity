#version 330 core

in vec3 frag_color;
in vec3 frag_normal;
in float frag_light;
out vec4 out_color;

void main()
{
	float sunlightIntensity = max( 26 * 0.96f + 0.6f, 0.02f);
	float lightIntensity = frag_light * sunlightIntensity;
    
	out_color = vec4( frag_color, 1.0f );
}
