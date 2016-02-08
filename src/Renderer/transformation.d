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
module s.renderer.transformation;

import gl3n.linalg;
import gl3n.math;

class Transformation
{
	vec3 m_position;
	vec3 m_rotation;
	vec3 m_scale;
	
	public this( vec3 position = vec3( 0.0f, 0.0f, 0.0f ), vec3 rotation = vec3( 0.0f, 0.0f, 0.0f ), vec3 scale = vec3( 1.0f, 1.0f, 1.0f ) )
	{
		m_position = position;
		m_rotation = rotation;
		m_scale = scale;
	}
	
	public ~this()
	{
		
	}
	
	public mat4 GetModelMatrix()
	{
		mat4 _x, _y, _z;
		_x = mat4.identity().rotate( m_rotation.x, vec3( 1.0f, 0.0f, 0.0f ) );
		_y = mat4.identity().rotate( m_rotation.y, vec3( 0.0f, 1.0f, 0.0f ) );
		_z = mat4.identity().rotate( m_rotation.z, vec3( 0.0f, 0.0f, 1.0f ) );
		
		mat4 t = mat4.identity().translate( m_position );
		mat4 r = _x * _y * _z;
		mat4 s = mat4.identity().scale( m_scale.x, m_scale.y, m_scale.z );
		
		return t * r * s;
	}
	
	public vec3* GetPosition()
	{
		return &m_position;
	}
	
	public vec3* GetRotation()
	{
		return &m_rotation;
	}
	
	public vec3* GetScale()
	{
		return &m_scale;
	}
};