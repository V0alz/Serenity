/*
*	Serenity - A personal voxel game.
*	Copyright(C) 2015-2016 Dennis Walsh
*
*	This program is free software : you can redistribute it and / or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.If not, see <http://www.gnu.org/licenses/>.
*/
module s.system.system;

import s.system.logger;
import std.stdio;
import s.renderer.renderer;
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
					c.Render( &m_renderer  );
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
		
		delete c;
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
