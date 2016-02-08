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

import gl3n.linalg : vec3;

/*
public
{
import block types here
}
*/

class BlockBase
{
	public static enum BlockType
	{
		// Standard blocks
		DEFAULT,
		GRASS,
		DIRT,
		STONE,
		WOOD,
		SAND,
		
		// Specials
		WATER,
		NUM_OF_TYPES
	};
	
	private bool m_active;
	private BlockType m_type;
	private vec3 m_color;
	private static const float m_blockSize = 0.5f; // built as (size * 2)(eg 0.5 * 2 = 1.0)
	
	public this()
	{
		m_active = false;
		m_type = BlockType.DEFAULT;
		m_color = vec3( 1.0f, 1.0f, 1.0f );
	}
	
	public this( bool active, BlockType type )
	{
		m_active = active;
		m_type = type;
		m_color = vec3( 1.0f, 1.0f, 1.0f );
	}
	
	public ~this()
	{
		
	}
	
	public bool IsActive()
	{
		return m_active;
	}
	
	public void SetActive( bool state )
	{
		m_active = state;
	}
	
	public BlockType GetBlockType()
	{
		return m_type;
	}	
	
	public void SetBlockType( BlockType type = BlockType.DEFAULT )
	{
		m_type = type;
	}
	
	public vec3 GetColor()
	{
		return m_color;
	}
	
	public void SetColor( vec3 color )
	{
		m_color = color;
	}
	
	public static float GetBlockSize()
	{
		return m_blockSize;
	}
};
