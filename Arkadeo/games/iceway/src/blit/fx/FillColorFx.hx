package blit.fx;

/**
 * ...
 * @author Thomas
 */

class FillColorFx implements ViewportFx
{

	var color : Null<Int>;
	public function new(?color:Null<Int>)
	{
		this.color = color;
	}
	
	public function before( viewport : blit.BitmapViewport )
	{
		viewport.bitmap.fillRect( viewport.rect, color == null ? viewport.backgroundColor : color );
	}
	
	public function after( viewport : blit.BitmapViewport )
	{
		//nothing
	}
	
}