module s.renderer.blocks.blockWood;
import s.renderer.block;

class BlockWood : Block
{
	public this()
	{
		super( true, Block.BlockType.WOOD );
		SetColor( vec3( 0.380392f, 0.172549f, 0.0f ) );
	}
	
	public ~this()
	{
		
	}
};
