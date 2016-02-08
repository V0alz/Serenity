module s.system.system;

import s.system.logger;
import std.stdio;
import s.renderer.renderer;
import s.renderer.window;
import s.system.state;

// temp import
import derelict.glfw3.glfw3;
import gl3n.linalg;
import s.renderer.chunk;

class System
{
	private bool m_running;
	private Renderer m_renderer;
	
	public this()
	{
		m_running = false;
		State.SetMode( State.EngineStates.INIT );
	}
	
	public ~this()
	{
		
	}
	
	public void Run()
	{
		Start();
		
		Chunk c = new Chunk();
		c.CreateMesh();
		
		do
		{
			if( Window.ShouldClose() )
			{
				Stop();
			}
			
			m_renderer.Clear();
			switch( State.GetMode() )
			{
				case State.EngineStates.INIT:
					m_renderer.GetShader().Bind();
					//m_renderer.GetShader().SetUniform( "_transform_view", m_renderer.GetCamera().GetView() );
					//m_renderer.GetShader().SetUniform( "_transform_perspective", m_renderer.GetCamera().GetProjection() );
					//m_renderer.GetShader().SetUniform( "_transform_model", mat4() );
					c.Render();
					break;
					// init game in this case
				case State.EngineStates.MAINMENU:
					// main menu here lol
				case State.EngineStates.PAUSED:
					// paused menu here
				case State.EngineStates.PLAYING:
					// game logic here
					//writeln( "playing" );
					break;
				default:
				case State.EngineStates.NUM_OF_MODES:
					// problem lol?
				break;
			}
			
			m_renderer.Swap();
			glfwPollEvents();
		}
		while( m_running );
		
		Clean();
	}
	
	private void Start()
	{
		if( m_running )
		{
			Logger.Write( "Y U START TWICE!", Logger.MSGTypes.WARNING );
			return;
		}
		
		m_running = true;
		Logger.Init();
		m_renderer = new Renderer();
		m_renderer.Init();
	}
	
	private void Stop()
	{
		if( !m_running )
		{
			Logger.Write( "Y U NO RUN", Logger.MSGTypes.WARNING );
			return;
		}
		
		m_running = false;
		m_renderer.Clean();
	}
	
	private void Clean()
	{
		if( !m_running )
		{
			if( m_renderer !is null )
			{
				delete m_renderer;
			}
		}
		
		Logger.Terminate();
	}
};