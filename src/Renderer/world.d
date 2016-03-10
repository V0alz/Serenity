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
module s.renderer.world;

import std.container.dlist;
import s.renderer.chunk;
import s.renderer.renderer;
import s.renderer.lightNode;
import s.system.logger;
import s.system.input;

import s.renderer.generator;
import gl3n.linalg;
import std.mathspecial;

/*----------------------------------------**
 * WORLD TODO:
 * 	-Only draw visible chunks.	(needs testing//untested as of 08/03/2016)
 *	-Only gen visible chunks.	(Done // Gen on fly)
 *	-Mesh more faces!
 *	-Reduce water faces
 *		and lower water block height by 0.1f
 *
 *	-If opaque faces are next to each other,
 *		merge them.
 *	-Tidy up chunk class
 *	-Use chunk flags
 *-----------------------------------------*/

class World
{
	private static const int m_maxChunks = 5;
	private static const int m_heightMax = 2;
	private DList!LightNode m_torchList;
	private Chunk[m_maxChunks][m_heightMax][m_maxChunks] m_chunks;
	private Generator m_generator;
	
	public this()
	{
		m_torchList.clear();
		for( int x = 0; x < m_maxChunks; x++ )
		{
			for( int y = 0; y < m_heightMax; y++ )
			{
				for( int z = 0; z < m_maxChunks; z++ ) 
				{
					m_chunks[x][y][z] = new Chunk( x - m_maxChunks / 2, y - m_heightMax / 2, z - m_maxChunks / 2 );
					//Logger.Write( "chunk added" );
				}
			}
		}
		
		for( int x = 0; x < m_maxChunks; x++ )
		{
			for( int y = 0; y < m_heightMax; y++ )
			{
				for( int z = 0; z < m_maxChunks; z++ ) 
				{
					if( x > 0 )
						m_chunks[x][y][z].m_neighbours[0] = &m_chunks[x - 1][y][z];
					if( x < m_maxChunks - 1 )
						m_chunks[x][y][z].m_neighbours[1] = &m_chunks[x + 1][y][z];
					if( y > 0 )
						m_chunks[x][y][z].m_neighbours[2] = &m_chunks[x][y - 1][z];
					if( y < m_heightMax - 1 )
						m_chunks[x][y][z].m_neighbours[3] = &m_chunks[x][y + 1][z];
					if( z > 0 )
						m_chunks[x][y][z].m_neighbours[4] = &m_chunks[x][y][z - 1];
					if( z < m_maxChunks - 1 )
						m_chunks[x][y][z].m_neighbours[5] = &m_chunks[x][y][z + 1];
				}
			}
		}
		
		m_generator = new Generator( 999 );
		
		//addTorch();
		Logger.Write( "Finsihed making world" );		
	}	
	
	public ~this()
	{
		for( int x = 0; x < m_maxChunks; x++ )
		{
			for( int y = 0; y < m_heightMax; y++ )
			{
				for( int z = 0; z < m_maxChunks; z++ ) 
				{
					delete m_chunks[x][y][z];
				}
			}
		}
	}

	public BlockBase* GetBlock( int x, int y, int z )
	{
		int csize = Chunk.m_chunkSize;
		int _x = (x + csize * (m_maxChunks / 2)) / csize;
		int _y = (y + csize * (m_heightMax / 2)) / csize;
		int _z = (z + csize * (m_maxChunks / 2)) / csize;
		
		if( _x < 0 || _x >= m_maxChunks || _y < 0 || _y >= m_heightMax || _z <= 0 || _z >= m_maxChunks )
		{
			return null;
		}
		
		return m_chunks[_x][_y][_z].FindBlock( vec3i( x & (csize-1), y & (csize-1), z & (csize-1) ) );
	}
	
	public void DoLight()
	{
		while( !m_torchList.empty() )
		{
			LightNode node = m_torchList.front();
			
			vec3i index = node.m_index;
			Chunk* chunk = node.m_chunk;
			
			float lightLevel = chunk.FindBlock( index ).light();
			
			vec3i n = vec3i( index.x - 1, index.y, index.z );
			if( index.x < 0 && chunk.m_neighbours[Chunk.Neighbour.NEGX] !is null )
			{
				if( chunk.FindBlock( n ).opaque == false &&
					chunk.FindBlock( n ).light() + 2 <= lightLevel )
				{
					chunk.FindBlock( n ).light( lightLevel - 2 );
					
					m_torchList.insertBack( new LightNode( n, chunk ) );
				}
			}
			
			n = vec3i( index.x + 1, index.y, index.z );
			if( index.x >= chunk.m_chunkSize && chunk.m_neighbours[Chunk.Neighbour.POSX] !is null )
			{
				if( chunk.FindBlock( n ).opaque == false &&
					chunk.FindBlock( n ).light() <= lightLevel )
				{
					chunk.FindBlock( n ).light( lightLevel - 2 );
					
					m_torchList.insertBack( new LightNode( n, chunk ) );
				}
			}
			
			n = vec3i( index.x, index.y - 1, index.z );
			if( index.y < 0 && chunk.m_neighbours[Chunk.Neighbour.NEGY] !is null )
			{
				if( chunk.FindBlock( n ).opaque == false &&
					chunk.FindBlock( n ).light() + 2 <= lightLevel )
				{
					chunk.FindBlock( n ).light( lightLevel - 2 );
					
					m_torchList.insertBack( new LightNode( n, chunk ) );
				}
			}
			
			n = vec3i( index.x, index.y + 1, index.z );
			if( index.y >= Chunk.m_chunkSize && chunk.m_neighbours[Chunk.Neighbour.POSY] !is null )
			{
				if( chunk.FindBlock( n ).opaque == false &&
					chunk.FindBlock( n ).light() + 2 <= lightLevel )
				{
					chunk.FindBlock( n ).light( lightLevel - 2 );
					
					m_torchList.insertBack( new LightNode( n, chunk ) );
				}
			}
			
			n = vec3i( index.x, index.y, index.z - 1 );
			if( index.z < 0 && chunk.m_neighbours[Chunk.Neighbour.NEGZ] !is null )
			{
				if( chunk.FindBlock( n ).opaque == false &&
					chunk.FindBlock( n ).light() + 2 <= lightLevel )
				{
					chunk.FindBlock( n ).light( lightLevel - 2 );
					
					m_torchList.insertBack( new LightNode( n, chunk ) );
				}
			}
			
			n = vec3i( index.x, index.y, index.z + 1 );
			if( index.z >= Chunk.m_chunkSize && chunk.m_neighbours[Chunk.Neighbour.POSZ] !is null )
			{
				if( chunk.FindBlock( n ).opaque == false &&
					chunk.FindBlock( n ).light() + 2 <= lightLevel )
				{
					chunk.FindBlock( n ).light( lightLevel - 2 );
					
					m_torchList.insertBack( new LightNode( n, chunk ) );
				}
			}
			
			m_torchList.removeFront();
		}
	}
	
	public void Update()
	{
		for( int x = 0; x < m_maxChunks; x++ )
		{
			for( int y = 0; y < m_heightMax; y++ )
			{
				for( int z = 0; z < m_maxChunks; z++ ) 
				{
					//DoLight();
					m_chunks[x][y][z].CreateMesh();
				}
			}
		}
	}
	
	public void Render( Renderer* renderer )
	{
		renderer.shader.SetUniform( "_transform_view", renderer.camera.view() );
		renderer.shader.SetUniform( "_transform_perspective", renderer.camera.projection() );
		
		float ud = 1.0 / 0.0f;
		int ux = -1;
		int uy = -1;
		int uz = -1;
		
		for( int x = 0; x < m_maxChunks; x++ )
		{
			for( int y = 0; y < m_heightMax; y++ )
			{
				for( int z = 0; z < m_maxChunks; z++ ) 
				{
					mat4 model = mat4.identity().translate( *m_chunks[x][y][z].position );
					mat4 mvp = renderer.camera.projection() * renderer.camera.view() * model;
					vec4 center = mvp * vec4( Chunk.m_chunkSize / 2, Chunk.m_chunkSize / 2 , Chunk.m_chunkSize / 2 , 1 );
					
					float diameter = center.length();
					center.x /= center.w;
					center.y /= center.w;
					
					if( center.z < -diameter )
					{
						continue;
					}
					
					if( fabs( center.x ) > 1 + fabs( Chunk.m_chunkSize * 2 / center.w ) || fabs( center.y ) > 1 + fabs( Chunk.m_chunkSize * 2 / center.w ) )
					{
						continue;
					}
					
					if( !m_chunks[x][y][z].initalized )
					{
						Logger.Write( "noninit" );
						if( ux < 0 || diameter < ud ) 
						{
							ud = diameter;
							ux = x;
							uy = y;
							uz = z;
						}
						continue;
					}
					
					m_chunks[x][y][z].Render( renderer );
					m_chunks[x][y][z].RenderW( renderer );
				}
			}
		}
		
		if( ux >= 0 )
		{
			m_generator.Noise( &m_chunks[ux][uy][uz] );
			if( m_chunks[ux][uy][uz].m_neighbours[0] )
			{
				m_generator.Noise( m_chunks[ux][uy][uz].m_neighbours[0] );
			}
			if( m_chunks[ux][uy][uz].m_neighbours[1] )
			{
				m_generator.Noise( m_chunks[ux][uy][uz].m_neighbours[1] );
			}
			if( m_chunks[ux][uy][uz].m_neighbours[2] )
			{
				m_generator.Noise( m_chunks[ux][uy][uz].m_neighbours[2] );
			}
			if( m_chunks[ux][uy][uz].m_neighbours[3] )
			{
				m_generator.Noise( m_chunks[ux][uy][uz].m_neighbours[3] );
			}
			if( m_chunks[ux][uy][uz].m_neighbours[4] )
			{
				m_generator.Noise( m_chunks[ux][uy][uz].m_neighbours[4] );
			}
			if( m_chunks[ux][uy][uz].m_neighbours[5] )
			{
				m_generator.Noise( m_chunks[ux][uy][uz].m_neighbours[5] );
			}
			m_chunks[ux][uy][uz].initalize;
		}
	}
	
	public void addTorch()
	{
		for( int x = 0; x < m_maxChunks; x++ )
		{
			for( int y = 0; y < m_heightMax; y++ )
			{
				for( int z = 0; z < m_maxChunks; z++ ) 
				{
					*m_chunks[x][y][z].FindBlock( vec3i( 3, 1, 3 ) ) = new BlockBase();
					m_chunks[x][y][z].FindBlock( vec3i( 3, 1, 3 ) ).light( 15.0f );
					m_chunks[x][y][z].FindBlock( vec3i( 3, 1, 3 ) ).color( vec3( 1.0f, 0.0f, 0.0f ) );
					
					m_torchList.insertBack( new LightNode( vec3i( 3, 1, 3 ), &m_chunks[x][y][z] ) );
				}
			}
		}
	}
};
