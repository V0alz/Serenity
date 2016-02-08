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
module s.system.logger;
private import std.stdio, std.string;
import std.exception;

class Logger
{
	private static File f; // File handle
	
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
