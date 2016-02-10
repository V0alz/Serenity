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
module s.renderer.chunkData;
import std.container, std.conv : to;
import gl3n.linalg : vec3;

struct ChunkData
{
	public Array!vec3 m_vertex;
	public Array!vec3 m_normal;
	public Array!vec3 m_color;
	public Array!int m_indices;
	
	public int AddVertex( vec3 v, vec3 n, vec3 c )
	{
		m_vertex.insertBack( v );
		m_normal.insertBack( n );
		m_color.insertBack( c );
		
		return m_vertex.length();
	}
	
	public void SetVertex( vec3 v, int offset )
	{
		m_vertex[m_vertex.length() - 1 - offset] = v;
	}
	
	public void AddFace( vec3 face )
	{
		m_indices.insertBack( to!uint(face.x) );
		m_indices.insertBack( to!uint(face.y) );
		m_indices.insertBack( to!uint(face.z) );
	}
};
