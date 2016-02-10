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
module s.system.input;

import derelict.glfw3.glfw3;
import s.system.logger;
import s.renderer.window;

class Input
{
	private static bool[300] m_keys;
	
	public static void Init()
	{
		Logger.Write( "Initalzing input.", Logger.MSGTypes.MESSAGE );
		m_keys = new bool[300];
		for( int i = 0; i < 300; i++ )
		{
			m_keys[i] = false;
		}
		
		glfwSetKeyCallback( Window.GetWindow(), &callback );
	}
	
	public static bool GetKey( int keycode )
	{
		return m_keys[keycode];
	}
	
	private static void SetKey( int keycode, int action ) nothrow 
	{
		switch( action )
		{
		case GLFW_PRESS:
			m_keys[keycode] = true;
			break;
		case GLFW_RELEASE:
			m_keys[keycode] = false;
			break;	
		case GLFW_KEY_UNKNOWN:
		default:
			break;
		}
	}
	
	extern(C)
	private static void callback( GLFWwindow* window, int key, int scancode, int action, int mods ) nothrow 
	{
		SetKey( key, action );
	}
};
