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
module s.renderer.shader;
import s.system.logger;
import derelict.opengl3.gl3;
import gl3n.linalg : mat4;
import std.container, std.stdio, std.conv, std.string;

class Shader
{
	private int m_program;
	private Array!int m_shaders;
	private int[string] m_uniforms;
	
	public this()
	{
		m_program = 0;
		m_shaders.clear();
	}
	
	public this( string filename, out bool result )
	{
		this();
		result = Init( filename );
	}
	
	public ~this()
	{
		Logger.Write( "Deconstructing shader" );
		for( int i = 0; i < m_shaders.length(); i++ )
		{
			glDetachShader( m_program, m_shaders[i] );
			glDeleteShader( m_shaders[i] );
		}
		
		glDeleteProgram( m_program );
	}
	
	public bool Init( string filename )
	{
		Logger.Write( "Initalizing shader: " ~ filename );
		m_program = glCreateProgram();
		m_shaders.insertBack( Create( SourceFromFile( "data/shader/" ~ filename ~ ".vs.glsl" ), GL_VERTEX_SHADER ) );
		m_shaders.insertBack( Create( SourceFromFile( "data/shader/" ~ filename ~ ".fs.glsl" ), GL_FRAGMENT_SHADER ) );
		
		for( int i = 0; i < m_shaders.length(); i++ )
		{
			if( m_shaders[i] == -1 )
			{
				Logger.Write( "Failed shader found!", Logger.MSGTypes.ERROR );
				return false;
			}
			glAttachShader( m_program, m_shaders[i] );
		}

		int result = 0;
		glLinkProgram( m_program );
		glGetProgramiv( m_program, GL_LINK_STATUS, &result );
		if( result == GL_FALSE )
		{
			int len = 0;
			glGetProgramiv( m_program, GL_INFO_LOG_LENGTH, &len );
			char[] error = new char[len];
			glGetProgramInfoLog( m_program, len, null, cast(char*)error );
			string err = to!string( error );
			Logger.Write( "Program failed to link!\n" ~ err, Logger.MSGTypes.ERROR );
			return false;
		}
		
		glValidateProgram( m_program );
		glGetProgramiv( m_program, GL_LINK_STATUS, &result );
		if( result == GL_FALSE )
		{
			int len = 0;
			glGetProgramiv( m_program, GL_INFO_LOG_LENGTH, &len );
			char[] error = new char[len];
			glGetProgramInfoLog( m_program, len, null, cast(char*)error );
			string err = to!string( error );
			Logger.Write( "Program failed to validate!\n" ~ err, Logger.MSGTypes.ERROR );
			return false;
		}
		
		Logger.Write( "Shader initalized successfully!" );
		return true;
	}
	
	public void Bind()
	{
		glUseProgram( m_program );
	}
	
	private int Create( string source, uint type )
	{
		uint shader = glCreateShader( type );
		if( !shader )
		{
			Logger.Write( "Failed to create shader", Logger.MSGTypes.ERROR );
			return -1;
		}
		
		auto src = toStringz(source);
		int length = source.length;
		
		glShaderSource( shader, 1, &src, &length );
		glCompileShader( shader );
		
		int result = 0;
		glGetShaderiv( shader, GL_COMPILE_STATUS, &result );
		if( result == GL_FALSE )
		{
			int len = 0;
			glGetShaderiv( shader, GL_INFO_LOG_LENGTH, &len );
			char[] error = new char[len];
			glGetShaderInfoLog( shader, len, null, cast(char*)error );
			string err = to!string( error );
			Logger.Write( "Shader compilation failed!\n\n" ~ err, Logger.MSGTypes.ERROR );
			return -1;
		}
		
		Logger.Write( "Shader creation succesfull" );
		return shader;
	}
	
	private string SourceFromFile( string filename )
	{
		try
		{
			File f = File( filename, "r" );
			
			string source;
			while( !f.eof )
			{
				source ~= f.readln();
			}
			
			return source;
		}
		catch( Exception e )
		{
			throw( e );
		}
	}
	
	public void AddUniform( const string name )
	{
		
		int loc = glGetUniformLocation( m_program, cast(char*)name );
		m_uniforms[name] = loc;
		
		// if you cant work out if uniforms are found uncomment below.
		//writeln( name );
		//writeln(  m_uniforms[name]);
		//writeln( loc );
	}
	
	public void SetUniform( const string name, mat4 value )
	{
		glUniformMatrix4fv( m_uniforms[name], 1, GL_TRUE, &value[0][0] );
	}
};
