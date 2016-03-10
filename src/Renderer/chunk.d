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
public import s.renderer.blocks.main;

class Chunk
{
	public static enum BufferObjects
	{
		VERTEX,
		NORMAL,
		COLOR,
		LIGHT,
		NUM
	};
	
	public static enum ArrayObjects
	{
		OPAQUE,
		TRANSPARENT,
		NUM_LAYERS
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
	
	private uint[ArrayObjects.NUM_LAYERS] m_vao;
	private uint[BufferObjects.NUM] m_vboOpaque;
	private uint[BufferObjects.NUM] m_vboTransparent;
	private uint[ArrayObjects.NUM_LAYERS] m_ibo;
	private Transformation m_transform;
	
	private bool m_initalized;
	private bool m_updated;
	private int[ArrayObjects.NUM_LAYERS] m_size;
	public static const uint m_chunkSize = 16;
	public BlockBase[m_chunkSize][m_chunkSize][m_chunkSize] m_blocks;
	public Chunk*[Neighbour.NUM_NEIGHBOURS] m_neighbours;
	
	public this( float world_x, float world_y, float world_z )
	{
		m_initalized = false;
		
		glGenVertexArrays( cast(int)ArrayObjects.NUM_LAYERS, m_vao.ptr );
		glGenBuffers( cast(int)BufferObjects.NUM, m_vboOpaque.ptr );
		glGenBuffers( cast(int)BufferObjects.NUM, m_vboTransparent.ptr );
		glGenBuffers( cast(int)ArrayObjects.NUM_LAYERS, m_ibo.ptr );
		m_transform = new Transformation( vec3( world_x * m_chunkSize, world_y * m_chunkSize, world_z * m_chunkSize ) );
		
		// allows build of mesh dataOpaque
		m_updated = true;
		m_size[ArrayObjects.OPAQUE] = 0;
		m_size[ArrayObjects.TRANSPARENT] = 0;
		
		for( int x = 0; x < m_chunkSize; x++ )
		{
			for( int y = 0; y < m_chunkSize; y++ )
			{
				for( int z = 0; z < m_chunkSize; z++ )
				{
					m_blocks[x][y][z] = new BlockAir();
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
		glDeleteBuffers( cast(int)ArrayObjects.NUM_LAYERS, m_ibo.ptr );
		glDeleteBuffers( cast(int)BufferObjects.NUM, m_vboOpaque.ptr );
		glDeleteBuffers( cast(int)BufferObjects.NUM, m_vboTransparent.ptr );
		glDeleteVertexArrays( cast(int)ArrayObjects.NUM_LAYERS, m_vao.ptr );
		delete m_transform;
	}
	
	public void CreateMesh()
	{
		if( !m_updated )
			return;
			
		ChunkData dataOpaque, dataTrans;
		bool lastVisible = false;
		bool lastOpaque = false;
		
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
					
					if( m_blocks[x][y][z].opaque )
					{
						AddCubeFace( dataOpaque, 0, lastVisible, lastOpaque, x, y, z );
						lastOpaque = true;
					}
					else
					{
						AddCubeFace( dataTrans, 0, lastVisible, lastOpaque, x, y, z );
						lastOpaque = false;
					}
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
					
					if( m_blocks[x][y][z].opaque )
					{
						AddCubeFace( dataOpaque, 1, lastVisible, lastOpaque, x, y, z );
						lastOpaque = true;
					}
					else
					{
						AddCubeFace( dataTrans, 1, lastVisible, lastOpaque, x, y, z );
						lastOpaque = false;
					}
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
					
					if( m_blocks[x][y][z].opaque )
					{
						AddCubeFace( dataOpaque, 2, lastVisible, lastOpaque, x, y, z );
						lastOpaque = true;
					}
					else
					{
						AddCubeFace( dataTrans, 2, lastVisible, lastOpaque, x, y, z );
						lastOpaque = false;
					}
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
					
					if( m_blocks[x][y][z].opaque )
					{
						AddCubeFace( dataOpaque, 3, lastVisible, lastOpaque, x, y, z );
						lastOpaque = true;
					}
					else
					{
						AddCubeFace( dataTrans, 3, lastVisible, lastOpaque, x, y, z );
						lastOpaque = false;
					}
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
					if( IsFaceBlocked( vec3i( x, y, z ), vec3i( x, y - 1, z ) ) )
					{
						lastVisible = false;
						continue;
					}
					
					if( m_blocks[x][y][z].opaque )
					{
						AddCubeFace( dataOpaque, 4, lastVisible, lastOpaque, x, y, z );
						lastOpaque = true;
					}
					else
					{
						AddCubeFace( dataTrans, 4, lastVisible, lastOpaque, x, y, z );
						lastOpaque = false;
					}
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
					if( IsFaceBlocked( vec3i( x, y, z ), vec3i( x, y + 1, z ) ) )
					{
						lastVisible = false;
						continue;
					}
					
					if( m_blocks[x][y][z].opaque )
					{
						AddCubeFace( dataOpaque, 5, lastVisible, lastOpaque, x, y, z );
						lastOpaque = true;
					}
					else
					{
						AddCubeFace( dataTrans, 5, lastVisible, lastOpaque, x, y, z );
						lastOpaque = false;
					}
					lastVisible = true;
				}
			}
		}
		
		if( dataOpaque.m_vertex.length() != 0 || dataOpaque.m_indices.length() != 0 )
		{
			Logger.Write( "OPQAUE", Logger.MSGTypes.WARNING );
			
			glBindVertexArray( m_vao[ArrayObjects.OPAQUE] );
			
			glBindBuffer( GL_ARRAY_BUFFER, m_vboOpaque[BufferObjects.VERTEX] );
			glBufferData( GL_ARRAY_BUFFER, dataOpaque.m_vertex.length() * vec3.sizeof, &dataOpaque.m_vertex[0], GL_STATIC_DRAW ); 
			glEnableVertexAttribArray( 0 );
			glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
			
			glBindBuffer( GL_ARRAY_BUFFER, m_vboOpaque[BufferObjects.NORMAL] );
			glBufferData( GL_ARRAY_BUFFER, dataOpaque.m_normal.length() * vec3.sizeof, &dataOpaque.m_normal[0], GL_STATIC_DRAW ); 
			glEnableVertexAttribArray( 1 );
			glVertexAttribPointer( 1, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
			
			glBindBuffer( GL_ARRAY_BUFFER, m_vboOpaque[BufferObjects.COLOR] );
			glBufferData( GL_ARRAY_BUFFER, dataOpaque.m_color.length() * vec3.sizeof, &dataOpaque.m_color[0], GL_STATIC_DRAW ); 
			glEnableVertexAttribArray( 2 );
			glVertexAttribPointer( 2, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
			
			glBindBuffer( GL_ARRAY_BUFFER, m_vboOpaque[BufferObjects.LIGHT] );
			glBufferData( GL_ARRAY_BUFFER, dataOpaque.m_light.length() * float.sizeof, &dataOpaque.m_light[0], GL_STATIC_DRAW );
			glEnableVertexAttribArray( 3 );
			glVertexAttribPointer( 3, 1, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
			
			// Arrays never like me when it comes to indices, so i play it safe lol
			m_size[ArrayObjects.OPAQUE] = dataOpaque.m_indices.length();
			uint[] indices = new uint[m_size[ArrayObjects.OPAQUE]];
			for( int i = 0; i < m_size[ArrayObjects.OPAQUE]; i++ )
			{
				indices[i] = dataOpaque.m_indices[i] - 1;
			}
			
			glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, m_ibo[ArrayObjects.OPAQUE] );
			glBufferData( GL_ELEMENT_ARRAY_BUFFER, m_size[ArrayObjects.OPAQUE] * uint.sizeof, &indices[0], GL_STATIC_DRAW );
		}
		
		//////////////////////////////////////// LAYER 2 /////////////////////////////////////////
		
		if( dataTrans.m_vertex.length() != 0 || dataTrans.m_indices.length() != 0 )
		{
			Logger.Write( "TRANS" );
		
			glBindVertexArray( m_vao[ArrayObjects.TRANSPARENT] );
			
			glBindBuffer( GL_ARRAY_BUFFER, m_vboTransparent[BufferObjects.VERTEX] );
			glBufferData( GL_ARRAY_BUFFER, dataTrans.m_vertex.length() * vec3.sizeof, &dataTrans.m_vertex[0], GL_STATIC_DRAW ); 
			glEnableVertexAttribArray( 0 );
			glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
			
			glBindBuffer( GL_ARRAY_BUFFER, m_vboTransparent[BufferObjects.NORMAL] );
			glBufferData( GL_ARRAY_BUFFER, dataTrans.m_normal.length() * vec3.sizeof, &dataTrans.m_normal[0], GL_STATIC_DRAW ); 
			glEnableVertexAttribArray( 1 );
			glVertexAttribPointer( 1, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
			
			glBindBuffer( GL_ARRAY_BUFFER, m_vboTransparent[BufferObjects.COLOR] );
			glBufferData( GL_ARRAY_BUFFER, dataTrans.m_color.length() * vec3.sizeof, &dataTrans.m_color[0], GL_STATIC_DRAW ); 
			glEnableVertexAttribArray( 2 );
			glVertexAttribPointer( 2, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
			
			glBindBuffer( GL_ARRAY_BUFFER, m_vboTransparent[BufferObjects.LIGHT] );
			glBufferData( GL_ARRAY_BUFFER, dataTrans.m_light.length() * float.sizeof, &dataTrans.m_light[0], GL_STATIC_DRAW );
			glEnableVertexAttribArray( 3 );
			glVertexAttribPointer( 3, 1, GL_FLOAT, GL_FALSE, 0, cast(void*)0 );
			
			// Arrays never like me when it comes to indices, so i play it safe lol
			m_size[ArrayObjects.TRANSPARENT] = dataTrans.m_indices.length();
			uint[] indicesT = new uint[m_size[ArrayObjects.TRANSPARENT]];
			for( int i = 0; i < m_size[ArrayObjects.TRANSPARENT]; i++ )
			{
				indicesT[i] = dataTrans.m_indices[i] - 1;
			}
			
			glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, m_ibo[ArrayObjects.TRANSPARENT] );
			glBufferData( GL_ELEMENT_ARRAY_BUFFER, m_size[ArrayObjects.TRANSPARENT] * uint.sizeof, &indicesT[0], GL_STATIC_DRAW );
		}
		
		glBindBuffer( GL_ARRAY_BUFFER, 0 );
		glBindVertexArray( 0 );
		
		m_updated = false;
	}
	
	private void AddCubeFace( ref ChunkData data, int side, ref bool lastVisible, ref bool lastOpaque, int x, int y, int z )
	{
		vec3 point1 = vec3( x - 0.5f, y - 0.5f, z + 0.5f );
		vec3 point2 = vec3( x + 0.5f, y - 0.5f, z + 0.5f );
		vec3 point3 = vec3( x + 0.5f, y + m_blocks[x][y][z].blockSize, z + 0.5f );
		vec3 point4 = vec3( x - 0.5f, y + m_blocks[x][y][z].blockSize, z + 0.5f );
		vec3 point5 = vec3( x + 0.5f, y - 0.5f, z - 0.5f );
		vec3 point6 = vec3( x - 0.5f, y - 0.5f, z - 0.5f );
		vec3 point7 = vec3( x - 0.5f, y + m_blocks[x][y][z].blockSize, z - 0.5f );
		vec3 point8 = vec3( x + 0.5f, y + m_blocks[x][y][z].blockSize, z - 0.5f );
		
		vec3 color = m_blocks[x][y][z].color;
		float light = m_blocks[x][y][z].light;
		
		uint v1, v2, v3, v4;
		v1 = v2 = v3 = v4 = 0;
		
		// if last opaque is == current opaque merge
		
		switch( side )
		{
		case 0: // neg x
		{
			if( lastVisible && z != 0 &&
				m_blocks[x][y][z].blockType() == FindBlock( vec3i( x, y, z - 1 ) ).blockType() )
			{
				data.SetVertex( point1,  2 );
				data.SetVertex( point4,  0 );
			}
			else
			{
				v1 = data.AddVertex( point6, vec3( -1.0f, 0.0f, 1.0f ), color, light );
				v2 = data.AddVertex( point1, vec3( -1.0f, 0.0f, 1.0f ), color, light );
				v3 = data.AddVertex( point7, vec3( -1.0f, 0.0f, 1.0f ), color, light );
				v4 = data.AddVertex( point4, vec3( -1.0f, 0.0f, 1.0f ), color, light );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v3, v2, v4 ) );
			}
			break;
		}
		case 1: // pos x
		{
			if( lastVisible && z != 0 &&
				m_blocks[x][y][z].blockType() == FindBlock( vec3i( x, y, z - 1 ) ).blockType() )
			{
				data.SetVertex( point2,  1 );
				data.SetVertex( point3,  0 );
			}
			else
			{
				v1 = data.AddVertex( point5, vec3( 1.0f, 0.0f, 0.0f ), color, light );
				v2 = data.AddVertex( point8, vec3( 1.0f, 0.0f, 0.0f ), color, light );
				v3 = data.AddVertex( point2, vec3( 1.0f, 0.0f, 0.0f ), color, light );
				v4 = data.AddVertex( point3, vec3( 1.0f, 0.0f, 0.0f ), color, light );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v3, v2, v4 ) );
			}
			break;
		}
		case 2: // neg z
		{
			if( lastVisible && y != 0 &&
				m_blocks[x][y][z].blockType() == FindBlock( vec3i( x, y - 1, z ) ).blockType() )
			{
				data.SetVertex( point7,  2 );
				data.SetVertex( point8,  0 );
			}
			else
			{
				v1 = data.AddVertex( point6, vec3( 0.0f, 0.0f, -1.0f ), color, light );
				v2 = data.AddVertex( point7, vec3( 0.0f, 0.0f, -1.0f ), color, light );
				v3 = data.AddVertex( point5, vec3( 0.0f, 0.0f, -1.0f ), color, light );
				v4 = data.AddVertex( point8, vec3( 0.0f, 0.0f, -1.0f ), color, light );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v2, v4, v3 ) );
			}
			break;
		}	
		case 3: // pos z
		{
			if( lastVisible && y != 0 &&
				m_blocks[x][y][z].blockType() == FindBlock( vec3i( x, y - 1, z ) ).blockType() )
			{
				data.SetVertex( point7, 1 );
				data.SetVertex( point3, 0 );
			}
			else
			{
				v1 = data.AddVertex( point1, vec3( 0.0f, 0.0f, 1.0f ), color, light );
				v2 = data.AddVertex( point2, vec3( 0.0f, 0.0f, 1.0f ), color, light );
				v3 = data.AddVertex( point4, vec3( 0.0f, 0.0f, 1.0f ), color, light );
				v4 = data.AddVertex( point3, vec3( 0.0f, 0.0f, 1.0f ), color, light );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v2, v4, v3 ) );
			}
			break;
		}	
		case 4: // neg y
		{
			if( lastVisible && z != 0 &&
				m_blocks[x][y][z].blockType() == FindBlock( vec3i( x, y, z - 1 ) ).blockType() )
			{
				data.SetVertex( point1,  1 );
				data.SetVertex( point2,  0 );
			}
			else
			{
				v1 = data.AddVertex( point6, vec3( 0.0f, -1.0f, 0.0f ), color, light );
				v2 = data.AddVertex( point5, vec3( 0.0f, -1.0f, 0.0f ), color, light );
				v3 = data.AddVertex( point1, vec3( 0.0f, -1.0f, 0.0f ), color, light );
				v4 = data.AddVertex( point2, vec3( 0.0f, -1.0f, 0.0f ), color, light );
				
				data.AddFace( vec3( v1, v2, v3 ) );
				data.AddFace( vec3( v2, v4, v3 ) );
			}
			break;
		}	
		case 5: // pos y
		{
			if( lastVisible && z != 0 &&
				m_blocks[x][y][z].blockType() == FindBlock( vec3i( x, y, z - 1 ) ).blockType() )
			{
				data.SetVertex( point4, 2 );
				data.SetVertex( point3, 0 );
			}
			else
			{
				v1 = data.AddVertex( point7, vec3( 0.0f, 1.0f, 0.0f ), color, light );
				v2 = data.AddVertex( point4, vec3( 0.0f, 1.0f, 0.0f ), color, light );
				v3 = data.AddVertex( point8, vec3( 0.0f, 1.0f, 0.0f ), color, light );
				v4 = data.AddVertex( point3, vec3( 0.0f, 1.0f, 0.0f ), color, light );
				
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
		if( m_blocks[x.x][x.y][x.z].blockType == BlockBase.BlockType.AIR )
		{
			return true;
		}
		
		if( FindBlock( z ) !is null )
		{
			if( FindBlock( x ).blockType != BlockBase.BlockType.WATER &&
				FindBlock( z ).blockType == BlockBase.BlockType.WATER )
			{
				return false;
			}
			return FindBlock( z ).opaque; // opaque of neighbour == true then don't draw face
		}
		else if( FindBlock( z ) is null ) // stops drawing null blocks
		{
			return true;
		}
		
		return false;
	}
	
	public BlockBase* FindBlock( vec3i at  )
	{
		if( at.x < 0 )
		{
			return m_neighbours[Neighbour.NEGX] ? &m_neighbours[Neighbour.NEGX].m_blocks[at.x + m_chunkSize][at.y][at.z] : null;	
		}
		if( at.x >= m_chunkSize )
		{
			return m_neighbours[Neighbour.POSX] ? &m_neighbours[Neighbour.POSX].m_blocks[at.x - m_chunkSize][at.y][at.z] : null;	
		}
		
		if( at.y < 0 )
		{
			return m_neighbours[Neighbour.NEGY] ? &m_neighbours[Neighbour.NEGY].m_blocks[at.x][at.y + m_chunkSize][at.z] : null;	
		}
		if( at.y >= m_chunkSize )
		{
			return m_neighbours[Neighbour.POSY] ? &m_neighbours[Neighbour.POSY].m_blocks[at.x][at.y - m_chunkSize][at.z] : null;	
		}
		
		if( at.z < 0 )
		{
			return m_neighbours[Neighbour.NEGZ] ? &m_neighbours[Neighbour.NEGZ].m_blocks[at.x][at.y][at.z + m_chunkSize] : null;
		}
		if( at.z >= m_chunkSize )
		{
			return m_neighbours[Neighbour.POSZ] ? &m_neighbours[Neighbour.POSZ].m_blocks[at.x][at.y][at.z - m_chunkSize] : null;
		}
		
		return &m_blocks[at.x][at.y][at.z];
	}
	
	public void Render( Renderer* renderer )
	{
		renderer.shader.SetUniform( "_transform_model", m_transform.GetModelMatrix() );
		glBindVertexArray( m_vao[ArrayObjects.OPAQUE] );
		glDrawElements( GL_TRIANGLES, m_size[ArrayObjects.OPAQUE], GL_UNSIGNED_INT, cast(void*)0 );
		glBindVertexArray( 0 );
	}
	
	public void RenderW( Renderer* renderer )
	{
		renderer.shader.SetUniform( "_transform_model", m_transform.GetModelMatrix() );
		glBindVertexArray( m_vao[ArrayObjects.TRANSPARENT] );
		glDrawElements( GL_LINES, m_size[ArrayObjects.TRANSPARENT], GL_UNSIGNED_INT, cast(void*)0 );
		glBindVertexArray( 0 );
	}
	
	public @property bool initalized()
	{
		return m_initalized;
	}
	
	public @property void initalize()
	{
		Logger.Write( "init" );
		if( m_initalized == false )
		{
			m_initalized = true;
		}
	}
	
	public @property void SetRebuild()
	{
		m_updated = true;
	}
	
	public @property bool updated()
	{
		return m_updated;
	}
	
	public @property vec3* position()
	{
		return m_transform.position;
	}
};
