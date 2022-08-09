package fx;

import mt.gx.time.FTimer;

import flash.text.TextFormat;
import flash.text.TextField;

using mt.gx.Ex;

class Init 
{
	public var arrows : Array<flash.display.Sprite>;
	public var word : flash.text.TextField;
	public static var ALL = [];
	
	public function new( ?msg:String)
	{
		FTimer.tick( function(r) tick(r), 200 );
		
		function nspr () return new flash.display.Sprite();
		arrows = [ nspr(), nspr(), nspr(), nspr()];
		
		var arrWidth = 64;
		
		var i = 0;
		
		var p = [0.2, 0.4, 0.6, 0.8];
		for ( a in arrows)
		{
			var gfx = a.graphics; 
			gfx.beginFill(0xff8200);
			gfx.lineTo(arrWidth * 0.5, 0);
			gfx.lineTo(arrWidth , arrWidth);
			gfx.lineTo(0, arrWidth);
			gfx.lineTo(arrWidth * 0.5, 0);
			gfx.endFill();
			a.y = 0;
			a.x = p[i] * Lib.w() - arrWidth * 0.5;
			Game.me.view.parent.addChild( a );
			a.toFront();
			
			a.filters = [Data.getOrangeFilter(),Data.getOuterBlackFilter()];
			a.cacheAsBitmap = true;
			i++;
		}
		
		word = new TextField();
		word.text = msg!=null?msg:Text.jump;
		
		var tf = new TextFormat("galaxy", 50);
		tf.color = 0xff8200;
		word.embedFonts = true;
		word.setTextFormat( word.defaultTextFormat = tf );
		word.y = 200;
		word.x = (Lib.w() >> 1) - (word.textWidth *0.5);
		word.width = 600;
		
		word.filters = [Data.getOrangeFilter(),Data.getOuterBlackFilter()];
		//word.cacheAsBitmap = true;
		word.selectable  = false;
		
		Game.me.view.parent.addChild( word );
		word.toFront();
	}
	
	public function tick(r:Float )
	{
		for ( a in arrows)
			a.y = Std.int(Math.abs( Math.sin( Game.me.time.ufr * 0.1 )) * 50); 
		word.alpha = Math.round(Math.abs( Math.sin( Game.me.time.ufr * 0.2)) * (1-r)); 
		
		if ( r >= 1.0) kill();
	}
	
	public function kill()
	{
		for ( a in arrows)
		{
			a.filters = [];
			a.detach();
		}
		arrows = null;
		word.filters = [];
		word.detach();
		word = null;
		ALL.remove(this);
	}
}