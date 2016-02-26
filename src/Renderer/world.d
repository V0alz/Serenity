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

import s.renderer.chunk;
import s.renderer.renderer;
import s.system.logger;

class World
{
	private static const int m_maxChunks = 2;
	private static const int m_heightMax = 2;
	private Chunk[m_maxChunks][m_heightMax][m_maxChunks] m_chunks;
	
	public this()
	{
		for( int x = 0; x < m_maxChunks; x++ )
		{
			for( int y = 0; y < m_heightMax; y++ )
			{
				for( int z = 0; z < m_maxChunks; z++ ) 
				{
					m_chunks[x][y][z] = new Chunk( x - m_maxChunks / 2, y - m_heightMax / 2, z - m_maxChunks / 2 );
					m_chunks[x][y][z].CreateMesh();
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
	
	public void Update()
	{
		
	}
	
	public void Render( Renderer* renderer )
	{
		renderer.GetShader().SetUniform( "_transform_view", renderer.GetCamera().GetView() );
		renderer.GetShader().SetUniform( "_transform_perspective", renderer.GetCamera().GetProjection() );
		for( int x = 0; x < m_maxChunks; x++ )
		{
			for( int y = 0; y < m_heightMax; y++ )
			{
				for( int z = 0; z < m_maxChunks; z++ ) 
				{
					m_chunks[x][y][z].Render( renderer );
				}
			}
		}
	}
};
