module s.renderer.renderer;
private import std.stdio;
private import derelict.opengl3.gl3;
private import s.renderer.window;
import s.renderer.shader;
import s.system.logger;

class Renderer
{
	private bool m_initalized;
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
			
			/*glFrontFace( GL_CCW );
			glCullFace( GL_BACK );
			glEnable( GL_CULL_FACE );*/
			
			bool result;
			m_shader = new Shader( "main", result );
			if( !result )
			{
				Logger.Write( "Shader not initalized corrently.", Logger.MSGTypes.ERROR );
				delete m_shader;
				Logger.Write( "Exiting renderer initalization", Logger.MSGTypes.WARNING );
				return false;
			}
			
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
};
