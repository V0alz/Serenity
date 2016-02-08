module s.renderer.blocks.blockStand;
import s.renderer.block;

class BlockSand : Block
{
	public this()
	{
		super( true, Block.BlockType.SAND );
		SetColor( vec3( 0.858823f, 0.858823f, 0.337254f ) );
	}
	
	public ~this()
	{
		
	}
};
