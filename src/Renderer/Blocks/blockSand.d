module s.renderer.blocks.blockStand;
import s.renderer.blocks.blockBase;

class BlockSand : BlockBase
{
	public this()
	{
		super( true, BlockBase.BlockType.SAND );
		SetColor( vec3( 0.858823f, 0.858823f, 0.337254f ) );
	}
	
	public ~this()
	{
		
	}
};
