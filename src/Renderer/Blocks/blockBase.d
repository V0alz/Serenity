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
module s.renderer.blocks.blockBase;

import gl3n.linalg : vec3, vec4;
import s.system.logger;

class BlockBase
{
	public static enum BlockType
	{
		// Standard blocks
		DEFAULT,
		AIR,
		GRASS,
		DIRT,
		STONE,
		WOOD,
		SAND,
		
		// Specials
		WATER,
		NUM_OF_TYPES
	};
	
	private bool m_opaque;
	private BlockType m_type;
	private vec3 m_color;
	private ubyte m_sunLight;
	private float m_light;
	private float m_blockSize = 0.5f; // built as (size * 2)(eg 0.5 * 2 = 1.0)
	
	public this()
	{
		m_opaque = true;
		m_type = BlockType.DEFAULT;
		m_color = vec3( 1.0f, 1.0f, 1.0f );
		m_sunLight = 0;
		m_light = 0.0f;
	}
	
	public this( bool opaque, BlockType type )
	{
		m_opaque = opaque;
		m_type = type;
		m_color = vec3( 1.0f, 1.0f, 1.0f );
		m_sunLight = 0;
		m_light = 0.0f;
	}
	
	public ~this()
	{
		
	}
	
	public @property bool opaque()
	{
		return m_opaque;
	}
	
	protected @property void opaque( bool o )
	{
		m_opaque = o;
	}
	
	public @property BlockType blockType()
	{
		return m_type;
	}	
	
	public @property void blockType( BlockType type = BlockType.DEFAULT )
	{
		m_type = type;
	}
	
	public @property vec3 color()
	{
		return m_color;
	}
	
	public @property void color( vec3 color )
	{
		m_color = color;
	}
	
	public @property ubyte sunLight()
	{
		return m_sunLight;
	}

	public @property void sunLight( ubyte light )
	{
		m_sunLight = light;
	}
	
	public @property float light()
	{
		return m_light;
	}

	public @property void light( float light )
	{
		Logger.Write( "light changed" );
		m_light = light;
	}
	
	public @property float blockSize()
	{
		return m_blockSize;
	}
	
	public @property void blockSize( float size )
	{
		m_blockSize = size;
	}
};
