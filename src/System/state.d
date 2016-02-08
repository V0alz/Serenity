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
module s.system.state;

// Finite state machine.
class State
{
	public static enum EngineStates
	{
		INIT = 0,
		MAINMENU = 1,
		PAUSED = 2,
		PLAYING = 3,
		
		NUM_OF_MODES = 4 // there are 4 usable modes.
	};
	private static EngineStates m_currentMode = EngineStates.INIT;
	
	public static void SetMode( EngineStates state )
	{
		if( state > EngineStates.NUM_OF_MODES )
		{
			return;
		}
		else if( state < 0 )
		{
			return;
		}
		m_currentMode = state;
	}
	
	public static EngineStates GetMode()
	{
		return m_currentMode;
	}
};
