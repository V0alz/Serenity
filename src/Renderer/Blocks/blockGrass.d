module s.renderer.blocks.blockGrass;
import s.renderer.blocks.blockBase;

class BlockGrass : BlockBase
{
	public this()
	{
		super( true, BlockBase.BlockType.GRASS );
		SetColor( vec3( 0.0f, 1.0f, 0.0f ) );
	}
	
	public ~this()
	{
		
	}
};
