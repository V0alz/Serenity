module s.renderer.blocks.blockWood;
import s.renderer.blocks.blockBase;

class BlockWood : BlockBase
{
	public this()
	{
		super( true, BlockBase.BlockType.WOOD );
		SetColor( vec3( 0.380392f, 0.172549f, 0.0f ) );
	}
	
	public ~this()
	{
		
	}
};
