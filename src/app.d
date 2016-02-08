import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;

import s.system.system;

void main() 
{
	DerelictGLFW3.load();
	DerelictGL3.load();
	
	System sys = new System();
	sys.Run();
}
