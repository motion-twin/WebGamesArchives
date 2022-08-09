package fx;

import mt.gx.time.FTimer;

import flash.text.TextFormat;
import flash.text.TextField;
import flash.filters.GlowFilter;

using mt.gx.Ex;

enum SMS_STATE
{
	GROW;
	WRITE(n:Int);
	CLOSE;
}

class SMS extends mt.fx.Fx
{
	public var bg : flash.display.Sprite;
	public var label : TextField;
	public var msg : String;
	public var next : String;
	public var state:SMS_STATE;
	var v :flash.filters.GlowFilter;
	public var H = 32;
	
	public var game(get, null) : Game; function get_game() return Game.me
	
	
	public function new( msg : String  )  
	{
		super();
		
		this.msg = msg;
		
		bg = new flash.display.Sprite();
		var gfx = bg.graphics;
		gfx.beginFill( 0xFF000000 );
		gfx.drawRect(0, 0, Lib.w(), H);
		gfx.endFill();
		bg.y = Lib.h();
		game.view.parent.addChild( bg );
		state = GROW;
		bg.alpha = 0.8;
		
		var gl = new flash.filters.GlowFilter();
		gl.strength = 0.5;
		gl.blurX = gl.blurY = 10;
		gl.color = 0;
		bg.filters = [gl];
		
		var tf = new TextFormat( "trana", 24, 0xff8200,true );
		tf.align = flash.text.TextFormatAlign.LEFT;
		
		label = new TextField();
		label.text = msg;
		label.setTextFormat( label.defaultTextFormat = tf );
		label.x = 8;
		label.y = 0;
		label.width = Lib.w();
		label.embedFonts = true;
		label.selectable = false;
		label.mouseEnabled = false;
		
		var g = new flash.filters.GlowFilter();
		g.color = 0xff9900;
		g.blurX = g.blurY = 5;
		g.strength = 0.5;
		label.filters = [ g];
		label.cacheAsBitmap = true;
		bg.mouseEnabled = false;
		bg.addChild(label);
		bg.cacheAsBitmap = true;
	}
	
	public override function update()
	{
		if ( bg == null )
			return;
			
		switch(state)
		{
			case GROW:
			bg.y--;
			if ( bg.y <= Lib.h() - H)
			{
				bg.y = Lib.h() - H;
				state = WRITE(180);
			}
			case WRITE(n):
				if (n == 1) state = CLOSE;
				else state = WRITE(n - 1);
				
			case CLOSE:
				
				bg.y++;
				if ( bg.y >= Lib.h() )
					kill();
		}
	}
	
	public override  function kill()
	{
		super.kill();
		bg.detach();
		bg = null;
		
		label.detach();
		label = null;
	}
	
}