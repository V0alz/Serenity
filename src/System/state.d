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
