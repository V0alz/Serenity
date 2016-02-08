module s.renderer.blocks.blockStone;
import s.renderer.blocks.blockBase;

class BlockStone : BlockBase
{
	public this()
	{
		super( true, BlockBase.BlockType.STONE );
		SetColor( vec3( 0.811764f, 0.811764f, 0.811764f ) );
	}
	
	public ~this()
	{
		
	}
};
