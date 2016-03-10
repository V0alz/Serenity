/*
*	Serenity - A personal voxel game.
*	Copyright(C) 2015-2016 Dennis Walsh
*
*	This program is free software : you can redistribute it and / or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.If not, see <http://www.gnu.org/licenses/>.
*/
module s.renderer.blocks.blockDirt;
import s.renderer.blocks.blockBase;

class BlockDirt : BlockBase
{
	public this()
	{
		super( true, BlockBase.BlockType.DIRT );
		color( vec3( 0.701960f, 0.419607f, 0.188235f ) );
	}
	
	public ~this()
	{
		
	}
};
