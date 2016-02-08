module s.renderer.blocks.blockWater;
import s.renderer.block;

class BlockWater : Block
{
	public this()
	{
		super( true, Block.BlockType.WATER );
		SetColor( vec3( 0.133333f, 0.9254901f, 0.941176f ) );
	}
	
	public ~this()
	{
		
	}
};
