module s.system.logger;
private import std.stdio, std.string;
import std.exception;

class Logger
{
	private static File f;
	
	public static enum MSGTypes
	{
		MESSAGE,
		WARNING,
		ERROR
	};
	
	public static bool Init()
	{
		f = File( "out.txt", "w" );
		if( f.isOpen() )
		{
			Write( "Serenity." );
			Write( "Copyright(C) 2015-2016 Dennis Walsh" );
			Write( "Initalizing Log." );
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public static bool Terminate()
	{
		try
		{
			if( f.isOpen() )
			{
				Write( "Finalizing logger." );
				f.close();
				return true;
			}
		}
		catch( ErrnoException e )
		{
			throw( e );
		}
		
		return false;
	}
	
	public static void Write( string output, MSGTypes type = MSGTypes.MESSAGE )
	{
		try
		{
			if( f.isOpen() )
			{
				string finalOutput;
				switch( type )
				{
				default:
				case MSGTypes.MESSAGE:
					finalOutput = "[MESSAGE]\t" ~ output;
					break;
				case MSGTypes.WARNING:
					finalOutput = "[WARNING]\t" ~ output;
					break;
				case MSGTypes.ERROR:
					finalOutput = "[ERROR]\t" ~ output;
					break;
				}
				
				f.writeln( finalOutput );
				writeln( finalOutput );
			}
		}
		catch( ErrnoException e1 )
		{
			throw( e1 );
		}
		catch( Exception e )
		{
			throw( e );
		}
	}
};
