module s.renderer.blocks.blockDirt;
import s.renderer.blocks.blockBase;

class BlockDirt : BlockBase
{
	public this()
	{
		super( true, BlockBase.BlockType.DIRT );
		SetColor( vec3( 0.701960f, 0.419607f, 0.188235f ) );
	}
	
	public ~this()
	{
		
	}
};
