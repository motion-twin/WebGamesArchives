import DefaultImport;
import flash.text.TextField;
import mt.deepnight.Tweenie;
import mt.fx.Blink;
import mt.fx.Sleep;
import mt.fx.Vanish;
import mt.gx.Debug;
import mt.gx.time.FTimer;
using mt.gx.Ex;

class Bonus extends Entity
{
	var disapear = false; 
	public var isPow = false;
	public function new(n) 
	{
		super();
		page = n;
		
		if( mc == null) mc = Ui.makePow(null);
		
		flags.unset(GRAVITY);
		flags.set(FLY);
		ry = 1.0;
		#if debug
		mc.filters = [ new flash.filters.GlowFilter(0x00FF00, 1, 25, 25, 10) ];
		#end
		
		//trace("gen bon "+mc.y+" "+n);
		name = "bonus";
	}
	
	
	public function getValue() return 1000
	
	public function kill()
	{
		if( mc != null && !disapear)
		{
			var v = new mt.fx.Vanish(mc);
			v.setFadeBlur(0, 2);
			v.setFadeScale( -1, 1);
			v.fadeAlpha = true;
			v.timer = 10;
			disapear = true;
		}
	}
	
	public function kill2()
	{
		if( mc != null && !disapear)
		{
			var v = new mt.fx.Vanish(mc);
			v.fadeAlpha = true;
			v.timer = 10;
			disapear = true;
		}
	}
	
	public function getHitLabel()
	{
		return "+1000";
	}
	
	public override function onProc()
	{
		var bv = 1000;
		game.fixScore += bv;
		var txt = getHitLabel();
		
		var b = 0;
		function gtf(txt)
		{
			var t = Lib.getTf( txt, 10); 
			
			t.textColor = 0xFFffFF;
			t.multiline = true;
			t.y = b += 20;
			var b =  10;
			t.width = t.textWidth + b;
			t.x = - t.width * 0.5 + b * 0.5;
			return t;
		}
		var char = game.char;
		var sc =  new fx.Score( txt, gtf );
		sc.x = Std.int( game.char.mc.x );
		sc.y = char.mc.y - char.mc.height - 50;
		
		char.mc.parent.addChild( sc );
		
		game.tweenie.create(sc, "y", sc.y - 35, TType.TEaseIn, 500  );
		var v = new mt.fx.Vanish( sc, 80 );
		v.fadeAlpha = true;
		
		var rem = game.level.others.remove(this);
		kill2();
	}
}