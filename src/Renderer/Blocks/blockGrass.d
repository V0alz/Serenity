module s.renderer.blocks.blockGrass;
import s.renderer.block;

class BlockGrass : Block
{
	public this()
	{
		super( true, Block.BlockType.GRASS );
		SetColor( vec3( 0.0f, 1.0f, 0.0f ) );
	}
	
	public ~this()
	{
		
	}
};
