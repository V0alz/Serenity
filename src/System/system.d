module s.system.system;
import std.stdio;
import s.renderer.renderer;
import s.renderer.window;
import s.system.state;
import s.system.logger;

// temp import
import derelict.glfw3.glfw3;
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
			if( glfwWindowShouldClose( Window.GetWindow() ) )
			{
				// state = final
				Stop();
			}
			
			m_renderer.Clear();
			switch( State.GetMode() )
			{
				case State.EngineStates.INIT:
					m_renderer.GetShader().Bind();
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
			writeln( "Y U START TWICE!" );
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
			writeln( "Y U NO RUN" );
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
