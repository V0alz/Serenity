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
module s.renderer.camera;
import derelict.glfw3.glfw3;
import gl3n.frustum, gl3n.linalg;
import s.system.input;

class Camera
{
	private vec3 m_position;
	private vec3 m_forward;
	private vec3 m_up;
	
	private mat4 m_perspective;
	
	public this( vec3 position = vec3( 0.0f, 0.0f, 0.0f ), vec3 forward = vec3( 0.0f, 0.0f, -1.0f ), vec3 up = vec3( 0.0f, 1.0f, 0.0f ) )
	{
		m_position = position;
		m_forward = forward;
		m_up = up;
	}
	
	public ~this()
	{
		
	}
	
	public void Update( double delta )
	{
		if( Input.GetKey( GLFW_KEY_W ) )
		{
			Move( m_forward, cast(float)(0.5f * delta) );
		}
		if( Input.GetKey( GLFW_KEY_S ) )
		{
			Move( -m_forward, cast(float)(0.5f * delta) );
		}
		if( Input.GetKey( GLFW_KEY_A ) )
		{
			Move( cross( m_up, m_forward ), cast(float)(0.5f * delta) );
		}
		if( Input.GetKey( GLFW_KEY_D ) )
		{
			Move( cross( m_forward, m_up ), cast(float)(0.5f * delta) );
		}
		
		if( Input.GetKey( GLFW_KEY_UP ) )
		{
			Move( m_up, cast(float)(0.5f * delta) );
		}
		if( Input.GetKey( GLFW_KEY_DOWN ) )
		{
			Move( -m_up, cast(float)(0.5f * delta) );
		}
	}
	
	public void Move( const vec3 direction, float speed )
	{
		m_position += (direction * speed );
	}
	
	public void SetProjection( float fov, float width, float height, float zNear, float zFar )
	{
		m_perspective = mat4.perspective( width, height, fov, zNear, zFar );
	}
	
	public mat4 GetProjection()
	{
		return m_perspective;
	}
	
	public mat4 GetView()
	{
		return mat4.look_at( m_position, m_position + m_forward, m_up );
	}
};
