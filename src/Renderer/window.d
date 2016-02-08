module s.renderer.window;
import std.stdio;
import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;
import s.system.logger;

class Window
{
	private static GLFWwindow* m_window;
	
	public static bool Init()
	{
		if( !glfwInit() )
		{
			Logger.Write( "Failed to init GLFW3.", Logger.MSGTypes.ERROR );
			return false;
		}
		
		glfwWindowHint( GLFW_SAMPLES, 4 );
		glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 3 );
		glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 3 );
		glfwWindowHint( GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE );
		return true;
	}
	
	public static bool Create()
	{
		m_window = glfwCreateWindow( 1024, 768, "Serenity", null, null );
		if( !m_window )
		{
			Logger.Write( "Unable to create GLFW window!", Logger.MSGTypes.ERROR );
			return false;
		}
		glfwMakeContextCurrent( m_window );
		DerelictGL3.reload();
		
		return true;
	}
	
	public static void Close()
	{
		glfwTerminate();
		Logger.Write( "Window closed" );
	}
	
	public static void Swap()
	{
		glfwSwapBuffers( m_window );
	}
	
	public static GLFWwindow* GetWindow()
	{
		return m_window;
	}
};
