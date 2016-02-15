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
module s.renderer.chunk;
import s.system.logger;
import std.stdio;
import derelict.opengl3.gl3;
import gl3n.linalg : vec3, vec3i;
import s.renderer.transformation;
import s.renderer.renderer;
import s.renderer.chunkData;
import s.renderer.blocks.main;

class Chunk
{
	public static enum BufferObjects
	{
		VERTEX,
		NORMAL,
		COLOR,
		NUM
	};
	
	public static enum Neighbour
	{
		NEGX,
		POSX,
		NEGY,
		POSY,
		NEGZ,
		POSZ,
		NUM_NEIGHBOURS
	};
	
	private uint m_vao;
	private uint[BufferObjects.NUM] m_vbo;
	private uint m_ibo;
	private Transformation m_transform;
	
	private bool m_updated;
	private int m_size;
	public static const uint m_chunkSize = 16;
	public BlockBase[m_chunkSize][m_chunkSize][m_chunkSize] m_blocks;
	public Chunk*[Neighbour.NUM_NEIGHBOURS] m_neighbours;
	
	public this( float world_x, float world_y, float world_z )
	{
		glGenVertexArrays( 1, &m_vao );
		glGenBuffers( cast(int)BufferObjects.NUM, m_vbo.ptr );
		glGenBuffers( 1, &m_ibo );
		m_transform = new Transformation( vec3( world_x * m_chunkSize, world_y * m_chunkSize, world_z * m_chunkSize ) );
		
		// allows build of mesh data
		m_updated = true;
		
		for( int x = 0; x < m_chunkSize; x++ )
		{
			for( int y = 0; y < m_chunkSize; y++ )
			{
				for( int z = 0; z < m_chunkSize; z++ )
				{
					if( x != 3 && y != 3 )
					{
						m_blocks[x][y][z] = new BlockStone();
						m_blocks[x][y][z].SetActive( true );
					}
					else
					{
						m_blocks[x][y][z] = new BlockDirt();
						m_blocks[x][y][z].SetActive( false );
					}
				}
			}
		}
		
		m_neighbours = new Chunk*[Neighbour.NUM_NEIGHBOURS];
		for( int i = 0; i < Neighbour.NUM_NEIGHBOURS; i++ )
		{
			m_neighbours[i] = null;
		}
	}
	
	public ~this()
	{
		glDeleteBuffers( 1, &m_ibo );
		glDeleteBuffers( cast(int)BufferObjects.NUM, m_vbo.ptr );
		glDeleteVertexArrays( 1, &m_vao );
		delete m_transform;
	}
	
	public void CreateMesh()
	{
		ChunkData data;
		bool lastVisible = false;
		
		for( int x = 0; x < m_chunkSize; x++ )
		{
			for( int y = 0; y < m_chunkSize; y++ )
			{
				lastVisible = false;
				for( int z = 0; z < m_chunkSize; z++ )
				{
					if( IsFaceBlocked( vec3i( x, y, z ), vec3i( x - 1, y, z ) ) )
					{
						lastVisible = false;
						continue;
					}
					
					AddCubeFace( data, 0, lastVisible, x, y, z );
					lastVisible = true;
				}
			}
		}
		
		for( int x = 0; x < m_chunkSize; x++ )
		{
			for( int y = 0; y < m_chunkSize; y++ )
			{
				lastVisible = false;
				for( int z = 0; z < m_chunkSize; z++ )
				{
					if( IsFaceBlocked( vec3i( x, y, z ), vec3i( x + 1, y, z ) ) )
					{
						lastVisible = false;
						continue;
					}
					
					AddCubeFace( data, 1, lastVisible, x, y, z );
					lastVisible = true;
				}
			}
		}
		
		for( int x = 0; x < m_chunkSize; x++ )
		{
			for( int y = 0; y < m_chunkSize; y++ )
			{
				lastVisible = false;
				for( int z = 0; z < m_chunkSize; z++ )
				{
					if( IsFaceBlocked( vec3i( x, y, z ), vec3i( x, y, z - 1 ) ) )
					{
						lastVisible = false;
						continue;
					}
					
					AddCubeFace( data, 2, lastVisible, x, y, z );
					lastVisible = true;
				}
			}
		}
		
		for( int x = 0; x < m_chunkSize; x++ )
		{
			for( int y = 0; y < m_chunkSize; y++ )
			{
				lastVisible = false;
				for( int z = 0; z < m_chunkSize; z++ )
				{
					if( IsFaceBlocked( vec3i( x, y, z ), vec3i( x, y, z + 1 ) ) )
					{
						lastVisible = false;
						continue;
					}
					
					AddCubeFace( data, 3, lastVisible, x, y, z );
					lastVisible = true;
				}
			}
		}
		
		for( int x = 0; x < m_chunkSize; x++ )
		{
			for( int y = 0; y < m_chunkSize; y++ )
			{
				for( int z = 0; z < m_chunkSize; z++ )
				{
					if( IsFaceBlocked( vec3i( x, y, z ), vec3i( x, y - 1, z ) ) )
					{
						lastVisible = false;
						continue;
					}
					
					AddCubeFace( data, 4, lastVisible, x, y, z );
					lastVisible = true;
				}
			}
		}
		
		for( int x = 0; x < m_chunkSize; x++ )
		{
			for( int y = 0; y < m_chunkSize; y++ )
			{
				for( int z = 0; z < m_chunkSize; z++ )
				{
					if( IsFaceBlocked( vec3i( x, y, z ), vec3i( x, y + 1, z ) ) )
					{
						lastVisible = false;
						continue;
					}
					
					AddCubeFace( data, 5, lastVisible, x, y, z );
					lastVisible = true;
				}
			}
		}
		
		if( data.m_vertex.length() == 0 || data.m_indices.length() == 0 )
		{
			Logger.Write( "Empty chunk created", Logger.MSGTypes.WARNING );
			return;
		}
		
		glBindVertexArray( m_vao );
		
		glBindBuffer( GL_ARRAY_BUFFER, m_vbo[BufferObjects.VERTEX] );
		glBufferData( GL_ARRAY_BUFFER, data.m_vertex.length() * vec3.sizeof, &data.m_vertex[0], GL_STATIC_DRAW ); 
		glEnableVertexAttribArray( 0 );
		glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
		
		glBindBuffer( GL_ARRAY_BUFFER, m_vbo[BufferObjects.NORMAL] );
		glBufferData( GL_ARRAY_BUFFER, data.m_normal.length() * vec3.sizeof, &data.m_normal[0], GL_STATIC_DRAW ); 
		glEnableVertexAttribArray( 1 );
		glVertexAttribPointer( 1, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
		
		glBindBuffer( GL_ARRAY_BUFFER, m_vbo[BufferObjects.COLOR] );
		glBufferData( GL_ARRAY_BUFFER, data.m_color.length() * vec3.sizeof, &data.m_color[0], GL_STATIC_DRAW ); 
		glEnableVertexAttribArray( 2 );
		glVertexAttribPointer( 2, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
		
		// Arrays never like me when it comes to indices, so i play it safe lol
		m_size = data.m_indices.length();
		uint[] indices = new uint[m_size];
		for( int i = 0; i < m_size; i++ )
		{
			indices[i] = data.m_indices[i] - 1;
		}
		
		glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, m_ibo );
		glBufferData( GL_ELEMENT_ARRAY_BUFFER, m_size * uint.sizeof, &indices[0], GL_STATIC_DRAW );
		
		glBindBuffer( GL_ARRAY_BUFFER, 0 );
		glBindVertexArray( 0 );
		
		m_updated = false;
	}
	
	private void AddCubeFace( ref ChunkData data, int side, ref bool lastVisible, int x, int y, int z )
	{
		vec3 point1 = vec3( x - BlockBase.GetBlockSize(), y - BlockBase.GetBlockSize(), z + BlockBase.GetBlockSize() );
		vec3 point2 = vec3( x + BlockBase.GetBlockSize(), y - BlockBase.GetBlockSize(), z + BlockBase.GetBlockSize() );
		vec3 point3 = vec3( x + BlockBase.GetBlockSize(), y + BlockBase.GetBlockSize(), z + BlockBase.GetBlockSize() );
		vec3 point4 = vec3( x - BlockBase.GetBlockSize(), y + BlockBase.GetBlockSize(), z + BlockBase.GetBlockSize() );
		vec3 point5 = vec3( x + BlockBase.GetBlockSize(), y - BlockBase.GetBlockSize(), z - BlockBase.GetBlockSize() );
		vec3 point6 = vec3( x - BlockBase.GetBlockSize(), y - BlockBase.GetBlockSize(), z - BlockBase.GetBlockSize() );
		vec3 point7 = vec3( x - BlockBase.GetBlockSize(), y + BlockBase.GetBlockSize(), z - BlockBase.GetBlockSize() );
		vec3 point8 = vec3( x + BlockBase.GetBlockSize(), y + BlockBase.GetBlockSize(), z - BlockBase.GetBlockSize() );
		
		vec3 color = m_blocks[x][y][z].GetColor();
		
		uint v1, v2, v3, v4;
		
		switch( side )
		{
		case 0: // neg x
		{
			if( lastVisible && 
				m_blocks[x][y][z].GetBlockType() == FindBlockType( vec3i( x, y, z - 1 ) ) )
			{
				data.SetVertex( point1, 2 );
				data.SetVertex( point4, 0 );
			}
			else
			{
				v1 = data.AddVertex( point6, vec3( -1.0f, 0.0f, 1.0f ), color );
				v2 = data.AddVertex( point1, vec3( -1.0f, 0.0f, 1.0f ), color );
				v3 = data.AddVertex( point7, vec3( -1.0f, 0.0f, 1.0f ), color );
				v4 = data.AddVertex( point4, vec3( -1.0f, 0.0f, 1.0f ), color );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v3, v2, v4 ) );
			}
			break;
		}
		case 1: // pos x
		{
			if( lastVisible &&
				m_blocks[x][y][z].GetBlockType() == FindBlockType( vec3i( x, y, z - 1 ) ) )
			{
				data.SetVertex( point2, 1 );
				data.SetVertex( point3, 0 );
			}
			else
			{
				v1 = data.AddVertex( point5, vec3( 1.0f, 0.0f, 0.0f ), color );
				v2 = data.AddVertex( point8, vec3( 1.0f, 0.0f, 0.0f ), color );
				v3 = data.AddVertex( point2, vec3( 1.0f, 0.0f, 0.0f ), color );
				v4 = data.AddVertex( point3, vec3( 1.0f, 0.0f, 0.0f ), color );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v3, v2, v4 ) );
			}
			break;
		}
		case 2: // neg z
		{
			if( lastVisible &&
				m_blocks[x][y][z].GetBlockType() == FindBlockType( vec3i( x, y - 1, z ) ) )
			{
				data.SetVertex( point7, 2 );
				data.SetVertex( point8, 0 );
			}
			else
			{
				v1 = data.AddVertex( point6, vec3( 0.0f, 0.0f, -1.0f ), color );
				v2 = data.AddVertex( point7, vec3( 0.0f, 0.0f, -1.0f ), color );
				v3 = data.AddVertex( point5, vec3( 0.0f, 0.0f, -1.0f ), color );
				v4 = data.AddVertex( point8, vec3( 0.0f, 0.0f, -1.0f ), color );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v2, v4, v3 ) );
			}
			break;
		}	
		case 3: // pos z
		{
			if( lastVisible &&
				m_blocks[x][y][z].GetBlockType() == FindBlockType( vec3i( x, y - 1, z ) ) )
			{
				data.SetVertex( point7, 1 );
				data.SetVertex( point3, 0 );
			}
			else
			{
				v1 = data.AddVertex( point1, vec3( 0.0f, 0.0f, 1.0f ), color );
				v2 = data.AddVertex( point2, vec3( 0.0f, 0.0f, 1.0f ), color );
				v3 = data.AddVertex( point4, vec3( 0.0f, 0.0f, 1.0f ), color );
				v4 = data.AddVertex( point3, vec3( 0.0f, 0.0f, 1.0f ), color );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v2, v4, v3 ) );
			}
			break;
		}	
		case 4: // neg y
		{
			if( lastVisible &&
				m_blocks[x][y][z].GetBlockType() == FindBlockType( vec3i( x, y, z - 1 ) ) )
			{
				data.SetVertex( point1, 1 );
				data.SetVertex( point2, 0 );
			}
			else
			{
				v1 = data.AddVertex( point6, vec3( 0.0f, -1.0f, 0.0f ), color );
				v2 = data.AddVertex( point5, vec3( 0.0f, -1.0f, 0.0f ), color );
				v3 = data.AddVertex( point1, vec3( 0.0f, -1.0f, 0.0f ), color );
				v4 = data.AddVertex( point2, vec3( 0.0f, -1.0f, 0.0f ), color );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v2, v4, v3 ) );
			}
			break;
		}	
		case 5: // pos y
		{
			if( lastVisible &&
				m_blocks[x][y][z].GetBlockType() == FindBlockType( vec3i( x, y, z - 1 ) ) )
			{
				data.SetVertex( point4, 2 );
				data.SetVertex( point3, 0 );
			}
			else
			{
				v1 = data.AddVertex( point7, vec3( 0.0f, 1.0f, 0.0f ), color );
				v2 = data.AddVertex( point4, vec3( 0.0f, 1.0f, 0.0f ), color );
				v3 = data.AddVertex( point8, vec3( 0.0f, 1.0f, 0.0f ), color );
				v4 = data.AddVertex( point3, vec3( 0.0f, 1.0f, 0.0f ), color );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v2, v4, v3 ) );
			}
			break;
		}	
		default:
			break;
		}
	}
	
	private bool IsFaceBlocked( vec3i x, vec3i z )
	{
		if( !m_blocks[x.x][x.y][x.z].IsActive() )
		{
			return true;
		}
		
		return FindBlockActive( z );
	}
	
	private BlockBase.BlockType FindBlockType( vec3i at )
	{
		if( at.x < 0 )
		{
			if( m_neighbours[Neighbour.NEGX] !is null )
				return m_neighbours[Neighbour.NEGX].m_blocks[at.x + m_chunkSize][at.y][at.z].GetBlockType();
			else
				return BlockBase.BlockType.DEFAULT;
		}
		if( at.x >= m_chunkSize )
		{
			if( m_neighbours[Neighbour.POSX] !is null )
				return m_neighbours[Neighbour.POSX].m_blocks[at.x - m_chunkSize][at.y][at.z].GetBlockType();
			else
				return BlockBase.BlockType.DEFAULT;	
		}
		
		if( at.y < 0 )
		{
			if( m_neighbours[Neighbour.NEGY] !is null )
				return m_neighbours[Neighbour.NEGY].m_blocks[at.x][at.y + m_chunkSize][at.z].GetBlockType();
			else
				return BlockBase.BlockType.DEFAULT;	
		}
		if( at.y >= m_chunkSize )
		{
			if( m_neighbours[Neighbour.POSY] !is null )
				return m_neighbours[Neighbour.POSY].m_blocks[at.x][at.y - m_chunkSize][at.z].GetBlockType();
			else
				return BlockBase.BlockType.DEFAULT;	
		}
		
		if( at.z < 0 )
		{
			if( m_neighbours[Neighbour.NEGZ] !is null )
				return m_neighbours[Neighbour.NEGZ].m_blocks[at.x][at.y][at.z + m_chunkSize].GetBlockType();
			else
				return BlockBase.BlockType.DEFAULT;
		}
		if( at.z >= m_chunkSize )
		{
			if( m_neighbours[Neighbour.POSZ] !is null )
				return m_neighbours[Neighbour.POSZ].m_blocks[at.x][at.y][at.z - m_chunkSize].GetBlockType();
			else
				return BlockBase.BlockType.DEFAULT;
		}
		
		return m_blocks[at.x][at.y][at.z].GetBlockType();
	}
	
	private bool FindBlockActive( vec3i at )
	{
		if( at.x < 0 )
		{
			if( m_neighbours[Neighbour.NEGX] !is null )
				return m_neighbours[Neighbour.NEGX].m_blocks[at.x + m_chunkSize][at.y][at.z].IsActive();
			else
				return false;	
		}
		if( at.x >= m_chunkSize )
		{
			if( m_neighbours[Neighbour.POSX] !is null )
				return m_neighbours[Neighbour.POSX].m_blocks[at.x - m_chunkSize][at.y][at.z].IsActive();
			else
				return false;	
		}
		
		if( at.y < 0 )
		{
			if( m_neighbours[Neighbour.NEGY] !is null )
				return m_neighbours[Neighbour.NEGY].m_blocks[at.x][at.y + m_chunkSize][at.z].IsActive();
			else
				return false;	
		}
		if( at.y >= m_chunkSize )
		{
			if( m_neighbours[Neighbour.POSY] !is null )
				return m_neighbours[Neighbour.POSY].m_blocks[at.x][at.y - m_chunkSize][at.z].IsActive();
			else
				return false;	
		}
		
		if( at.z < 0 )
		{
			if( m_neighbours[Neighbour.NEGZ] !is null )
				return m_neighbours[Neighbour.NEGZ].m_blocks[at.x][at.y][at.z + m_chunkSize].IsActive();
			else
				return false;
		}
		if( at.z >= m_chunkSize )
		{
			if( m_neighbours[Neighbour.POSZ] !is null )
				return m_neighbours[Neighbour.POSZ].m_blocks[at.x][at.y][at.z - m_chunkSize].IsActive();
			else
				return false;
		}
		
		return m_blocks[at.x][at.y][at.z].IsActive();
	}
	
	public void Render( Renderer* renderer )
	{
		renderer.GetShader().SetUniform( "_transform_model", m_transform.GetModelMatrix() );
		glBindVertexArray( m_vao );
		glDrawElements( GL_TRIANGLES, m_size, GL_UNSIGNED_INT, cast(void*)0 );
		glBindVertexArray( 0 );
	}
};
