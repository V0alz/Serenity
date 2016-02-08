module s.renderer.blocks.blockWater;
import s.renderer.blocks.blockBase;

class BlockWater : BlockBase
{
	public this()
	{
		super( true, BlockBase.BlockType.WATER );
		SetColor( vec3( 0.133333f, 0.9254901f, 0.941176f ) );
	}
	
	public ~this()
	{
		
	}
};
