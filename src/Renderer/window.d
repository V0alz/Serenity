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
	
	public static bool ShouldClose()
	{
		if( glfwWindowShouldClose( m_window ) )
		{
			return true;
		}
		else
		{
			return false;
		}
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
