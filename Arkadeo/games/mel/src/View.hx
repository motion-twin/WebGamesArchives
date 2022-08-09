using mt.gx.Ex;

class View extends flash.display.Sprite
{
	var fc : flash.text.TextField;

	public function new()
	{
		super();
		
		fc  = Lib.getTf("SAPIN", 10);
		fc.x = 50;
		fc.y = 300;
		
		#if debug
		Game.me.addChild( fc );
		#end
	}
	
	public function destroy()
	{
		fc.detach();
		fc = null;
		detach();
	}
	
	public function scrollPix(x : Float,y:Float)
	{
		this.x = Std.int(x);
		this.y = Std.int(y);
	}
	
	public function update()
	{
		#if debug
		fc.text = Std.string(Game.me.time.ufr);
		fc.toFront();
		#end
	}
}