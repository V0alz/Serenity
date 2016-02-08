module s.renderer.blocks.blockStone;
import s.renderer.block;

class BlockStone : Block
{
	public this()
	{
		super( true, Block.BlockType.STONE );
		SetColor( vec3( 0.811764f, 0.811764f, 0.811764f ) );
	}
	
	public ~this()
	{
		
	}
};
