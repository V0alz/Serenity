module s.renderer.blocks.blockDirt;
import s.renderer.block;

class BlockDirt : Block
{
	public this()
	{
		super( true, Block.BlockType.DIRT );
		SetColor( vec3( 0.701960f, 0.419607f, 0.188235f ) );
	}
	
	public ~this()
	{
		
	}
};
