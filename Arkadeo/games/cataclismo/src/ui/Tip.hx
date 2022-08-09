package ui;

/**
 * ...
 */

class Tip extends gfx.Tip
{

	public function new(text:String,mode:Int)
	{
		super();
		gotoAndStop(mode);
 		_txt.text = text;
	}
	
}