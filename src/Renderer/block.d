module s.renderer.block;

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
	
	private BlockType m_type;
	private bool m_active;
	public static const float m_blockSize = 1.0f; 
	
	public this()
	{
		m_active = false;
		m_type = BlockType.DEFAULT;
	}
	
	public this( bool active, BlockType type )
	{
		m_active = active;
		m_type = type;
	}
	
	public ~this()
	{
		
	}
	
	public BlockType GetBlockType()
	{
		return m_type;
	}	
	
	public void SetBlockType( BlockType type = BlockType.DEFAULT )
	{
		m_type = type;
	}
	
	public bool IsActive()
	{
		return m_active;
	}
	
	public void SetActive( bool state )
	{
		m_active = state;
	}
	
	public static float GetBlockSize()
	{
		return m_blockSize;
	}
};
