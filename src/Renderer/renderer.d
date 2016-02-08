module s.renderer.renderer;
import std.stdio;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import gl3n.linalg : vec3;
private import s.renderer.window;
import s.renderer.shader;
import s.renderer.camera;
import s.system.logger;

class Renderer
{
	private bool m_initalized;
	private Camera m_camera;
	private Shader m_shader;
	
	public this()
	{
		m_initalized = false;
		m_shader = null;
	}
	
	public ~this()
	{
		Logger.Write( "Finalizing renderer" );
		if( m_shader !is null )
		{
			delete m_shader;
		}
	}
	
	public bool Init()
	{
		if( !m_initalized )
		{
			if( Window.Init() )
			{
				if( !Window.Create() )
				{
					return false;
				}
			}
			
			glClearColor( 0.0f, 0.0f, 0.0f, 1.0f );
			glEnable( GL_DEPTH_TEST );
			glDepthFunc( GL_LESS );
			
			glFrontFace( GL_CCW );
			glCullFace( GL_BACK );
			glEnable( GL_CULL_FACE );
			
			m_camera = new Camera( vec3( 0.0f, 0.0f, -4.0f ) );
			int width, height;
			glfwGetWindowSize( Window.GetWindow(), &width, &height );
			m_camera.SetProjection( 45.0f, width, height, 0.1f, 10.0000f );
			
			bool result;
			m_shader = new Shader( "main", result );
			if( !result )
			{
				Logger.Write( "Shader not initalized corrently.", Logger.MSGTypes.ERROR );
				delete m_shader;
				Logger.Write( "Exiting renderer initalization", Logger.MSGTypes.WARNING );
				return false;
			}
			
			m_shader.AddUniform( "_transform_model" );
			m_shader.AddUniform( "_transform_view" );
			m_shader.AddUniform( "_transform_perspective" );
			
			m_initalized = true;
			Logger.Write( "Renderer initalized succesfully" );
			return true;
		}
		else
		{
			Logger.Write( "Renderer attempted to initalize twice!", Logger.MSGTypes.WARNING );
			return false;
		}
		
		//return true;
	}
	
	public void Clean()
	{
		Window.Close();
	}
	
	public void Clear()
	{
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	}
	
	public void Swap()
	{
		Window.Swap();	
	}
	
	public Shader* GetShader()
	{
		return &m_shader;
	}
	
	public Camera* GetCamera()
	{
		return &m_camera;
	}
};
