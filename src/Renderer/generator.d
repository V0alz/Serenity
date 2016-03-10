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
module s.renderer.generator;

import gl3n.linalg : vec2i;
import s.renderer.chunk;
import noise.noise;

class Generator
{	
	private Perlin perlinModule;
	private Perlin typeModule;
	
	public this( int seed )
	{
		perlinModule = new Perlin();
		perlinModule.SetSeed( seed );
		perlinModule.SetOctaveCount( 6 );
		perlinModule.SetPersistence( 0.8 );
		
		typeModule = new Perlin();
		typeModule.SetSeed( -seed );
		typeModule.SetOctaveCount( 2 );
		typeModule.SetPersistence( 1 );
	}
	
	public ~this()
	{
		// These caused invalid memory operations
		
		//delete perlinModule;
		//delete typeModule;
	}
	
	public void Noise( Chunk* c )
	{
		for( int x = 0; x < Chunk.m_chunkSize; x++ )
		{	
			for( int z = 0; z < Chunk.m_chunkSize; z++ )	
			{	
				double noise = perlinModule.GetValue( (x + c.position.x) / 512, (z + c.position.z) / 512, 0 ) * 4;
				double h = noise * 4;
				
				for( int y = 0; y < Chunk.m_chunkSize; y++ )
				{
					if( y + c.position.y >= h ) // above ground level
					{
						if( y + c.position.y < 2 ) // add sea
						{
							*c.FindBlock( vec3i( x, y, z ) ) = new BlockWater();
							continue;
						}
						else // else it stays air(default block is not BlockBase//BlockDefault)
						{
							break;
						}
					}
					
					double r = typeModule.GetValue( (x + c.position.x) / 16, (y + c.position.y) / 16, (z + c.position.z) / 16 );
					
					if( noise + r * 5 < 1.25 )
					{
						if( (h < 2+2) || y + c.position.y < h - 1 )
						{
							*c.FindBlock( vec3i( x, y, z ) ) = new BlockSand();
						}
						else
						{
							*c.FindBlock( vec3i( x, y, z ) ) = new BlockStone();
						}
					}
					else if( noise + r < 4 )
					{
						if( (h < 2) || y + c.position.y < h - 1 ) 
						{
							*c.FindBlock( vec3i( x, y, z ) ) = new BlockDirt();
						}
						else
						{
							*c.FindBlock( vec3i( x, y, z ) ) = new BlockGrass();
						}
					}
				}
			}
		}
		
		c.SetRebuild();
	}
};
