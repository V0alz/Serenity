module s.renderer.block;

import gl3n.linalg : vec3;

/*
public
{
import block types here
}
*/

class Block
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
	public static const float m_blockSize = 0.5f; // built as (size * 2)
	
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
