module s.renderer.chunk;
import s.system.logger;
import std.stdio;
import derelict.opengl3.gl3;
import gl3n.linalg : vec3;
import s.renderer.chunkData;
import s.renderer.block;
import s.renderer.blockGrass;

class Chunk
{
	public static enum BufferObjects
	{
		VERTEX,
		NORMAL,
		COLOR,
		NUM
	}
	private uint m_vao;
	private uint[BufferObjects.NUM] m_vbo;
	private uint m_ibo;
	
	private bool m_updated;
	private int m_size;
	private const uint m_chunkSize = 16;
	private Block[m_chunkSize][m_chunkSize][m_chunkSize] m_blocks;
	
	public this()
	{
		glGenVertexArrays( 1, &m_vao );
		glGenBuffers( cast(int)BufferObjects.NUM, m_vbo.ptr );
		glGenBuffers( 1, &m_ibo );
		
		// allows build of mesh data
		m_updated = true;
		
		for( int x = 0; x < m_chunkSize; x++ )
		{
			for( int y = 0; y < m_chunkSize; y++ )
			{
				for( int z = 0; z < m_chunkSize; z++ )
				{
					m_blocks[x][y][z] = new Block();
					m_blocks[x][y][z].SetActive( true );
				}
			}
		}
	}
	
	public ~this()
	{
		glDeleteBuffers( 1, &m_ibo );
		glDeleteBuffers( cast(int)BufferObjects.NUM, m_vbo.ptr );
		glDeleteVertexArrays( 1, &m_vao );
	}
	
	public void CreateMesh()
	{
		ChunkData data;
		for( int x = 0; x < m_chunkSize; x++ )
		{
			for( int y = 0; y < m_chunkSize; y++ )
			{
				for( int z = 0; z < m_chunkSize; z++ )
				{
					if( !m_blocks[x][y][z].IsActive() )
					{
						continue;
					}
					
					AddCube( data, x, y, z );
				}
			}
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
		
		m_size = data.m_indices.length();
		uint[] indices = new uint[m_size];
		for( int i = 0; i < m_size; i++ )
		{
			indices[i] = data.m_indices[i];
		}
		
		glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, m_ibo );
		glBufferData( GL_ELEMENT_ARRAY_BUFFER, m_size * uint.sizeof, &indices[0], GL_STATIC_DRAW );
		
		glBindBuffer( GL_ARRAY_BUFFER, 0 );
		glBindVertexArray( 0 );
		
		m_updated = false;
	}
	
	private void AddCube( ref ChunkData data, int x, int y, int z )
	{
		vec3 point1 = vec3( x - Block.GetBlockSize(), y - Block.GetBlockSize(), z + Block.GetBlockSize() );
		vec3 point2 = vec3( x + Block.GetBlockSize(), y - Block.GetBlockSize(), z + Block.GetBlockSize() );
		vec3 point3 = vec3( x + Block.GetBlockSize(), y + Block.GetBlockSize(), z + Block.GetBlockSize() );
		vec3 point4 = vec3( x - Block.GetBlockSize(), y + Block.GetBlockSize(), z + Block.GetBlockSize() );
		vec3 point5 = vec3( x + Block.GetBlockSize(), y - Block.GetBlockSize(), z - Block.GetBlockSize() );
		vec3 point6 = vec3( x - Block.GetBlockSize(), y - Block.GetBlockSize(), z - Block.GetBlockSize() );
		vec3 point7 = vec3( x - Block.GetBlockSize(), y + Block.GetBlockSize(), z - Block.GetBlockSize() );
		vec3 point8 = vec3( x + Block.GetBlockSize(), y + Block.GetBlockSize(), z - Block.GetBlockSize() );
		
		vec3 normal;
		vec3 tmpCol = vec3( 1.0f, 1.0f, 1.0f );
		
		uint v1, v2, v3, v4, v5, v6, v7, v8;
		
		// front
		normal = vec3( 0.0f, 0.0f, 1.0f );
		
		v1 = data.AddVertex( point1, normal, tmpCol );
		v2 = data.AddVertex( point2, normal, tmpCol );
		v3 = data.AddVertex( point3, normal, tmpCol );
		v4 = data.AddVertex( point4, normal, tmpCol );
		
		data.AddFace( vec3( v1, v2, v3 ) );
		data.AddFace( vec3( v1, v3, v4 ) );
		
		// back
		normal = vec3( 0.0f, 0.0f, -1.0f );
		
		v5 = data.AddVertex( point5, normal, tmpCol );
		v6 = data.AddVertex( point6, normal, tmpCol );
		v7 = data.AddVertex( point7, normal, tmpCol );
		v8 = data.AddVertex( point8, normal, tmpCol );
		
		data.AddFace( vec3( v5, v6, v7 ) );
		data.AddFace( vec3( v5, v7, v8 ) );
		
		// right
		normal = vec3( 1.0f, 0.0f, 0.0f );
		
		v2 = data.AddVertex( point2, normal, tmpCol );
		v5 = data.AddVertex( point5, normal, tmpCol );
		v8 = data.AddVertex( point8, normal, tmpCol );
		v3 = data.AddVertex( point3, normal, tmpCol );
		
		data.AddFace( vec3( v2, v5, v8 ) );
		data.AddFace( vec3( v2, v8, v3 ) );
		
		// left
		normal = vec3( -1.0f, 0.0f, 0.0f );
		
		v6 = data.AddVertex( point6, normal, tmpCol );
		v1 = data.AddVertex( point1, normal, tmpCol );
		v4 = data.AddVertex( point4, normal, tmpCol );
		v7 = data.AddVertex( point7, normal, tmpCol );
		
		data.AddFace( vec3( v6, v1, v4 ) );
		data.AddFace( vec3( v6, v4, v7 ) );
		
		// top
		normal = vec3( 0.0f, 1.0f, 0.0f );
		
		v4 = data.AddVertex( point4, normal, tmpCol );
		v3 = data.AddVertex( point3, normal, tmpCol );
		v8 = data.AddVertex( point8, normal, tmpCol );
		v7 = data.AddVertex( point7, normal, tmpCol );
		
		data.AddFace( vec3( v4, v3, v8 ) );
		data.AddFace( vec3( v4, v8, v7 ) );
		
		// bottom
		normal = vec3( 0.0f, -1.0f, 0.0f );
		
		v6 = data.AddVertex( point6, normal, tmpCol );
		v5 = data.AddVertex( point5, normal, tmpCol );
		v2 = data.AddVertex( point2, normal, tmpCol );
		v1 = data.AddVertex( point1, normal, tmpCol );
		
		data.AddFace( vec3( v6, v5, v2 ) );
		data.AddFace( vec3( v6, v2, v1 ) );
	}
	
	public void Render()
	{
		glBindVertexArray( m_vao );
		glDrawElements( GL_TRIANGLES, m_size, GL_UNSIGNED_INT, cast(void*)0 );
		glBindVertexArray( 0 );
	}
};
