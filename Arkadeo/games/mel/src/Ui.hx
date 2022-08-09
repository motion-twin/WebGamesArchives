package ;

import mt.deepnight.Color;
import DefaultImport;

using mt.gx.Ex;

class Ui implements haxe.Public
{
	var powers  : Array<SP>;
	var enabled : haxe.EnumFlags<CharPowers>;
	var tip : mt.deepnight.Tip;
	var bar : gfx.LifeBar;
	public var game(get, null) : Game; function get_game() return Game.me
	
	static var pal = [ 0xfff000,  0x00ff00, 0x0084ff, 0xf600ff, 0xff0066, 0x00ff0c, 0xff4200];
	
	public function new() {
		var mc = new flash.display.Sprite();
		
		powers = [];

		enabled = haxe.EnumFlags.ofInt(0);
		
		var border = new flash.display.Sprite();
		
		var by = 8;
		var bx = Lib.w() - 140;
		border.x = bx;
		border.y = by;
		mc.addChild( border );
		
		for ( p in Type.allEnums(CharPowers))
		{
			var pi = p.index();
			var sp  = makePow( p );
			var pos = pos( pi );
			sp.x = bx + 14 + pi * 26;
			sp.y = by + 26;
			
			powers.pushBack( sp );
			mc.addChild( sp );
			var pp = powers[p.index()];
			pp.filters = [ new fx.Greyscale().get()  ];
			sp.scaleX = sp.scaleY = 0.6;
		}
		
		var g = border.graphics;
		g.beginFill(/*0x5F1F1F */0xd3d4bf); 
		g.drawRoundRect(-1, -1, mc.width + 7, mc.height + 7,8);
		g.endFill();
		
		Game.me.addChild( mc  );
		mc.toFront();
		
		
		var tps = new mt.deepnight.Tip.TipSprite();
		var tf = new flash.text.TextFormat();
		tf.font = "galaxy";
		tps.stf.setFont( 0xffa000, "galaxy", 8);
		
		var bg = tps.bg;
		var g :flash.display.Graphics = bg.graphics;
		var tp = new mt.deepnight.Tip(tps);
		
		tp.bgFilters = [];
		g.clear();
		g.lineStyle(1.1, 0xffa000, 1, true, flash.display.LineScaleMode.NONE,flash.display.CapsStyle.ROUND);
		g.beginFill(0x0);
		g.drawRoundRect(0, 0, 300, 100, 4);
		g.endFill();
		
		var f = new flash.filters.GlowFilter();
		f.color = 0x100a00;
		f.blurX = 16;
		f.blurY = 16;
		f.inner = true;
		f.alpha = 0.56;
		
		var g = new flash.filters.GlowFilter();
		g.color = 0x0;
		g.blurX = 4;
		g.blurY = 4;
		g.alpha = 0.2;
		
		tp.bgFilters = [f,g];
		Game.me.addChild( (tip = tp).spr );
		
		Game.me.addChild( bar = new gfx.LifeBar() );
		bar.x += 8;
		bar.y += 12;
		bar.stop();
	}
	
	public static inline var b = 32;
	
	public static function makePow(p : Null<CharPowers>) : flash.display.Sprite
	{
		var sp = new lib.PowerUps();
		
		if( p == null )
			sp.gotoAndStop( CharPowers.length() + 1 );
		else 
		{
			var f = 
			switch( p ) 
			{
				case CP_DOUBLE_JUMP: 3;
				case CP_WALL_STICK: 1;
				case CP_SUPER_JUMP: 2;

				case CP_KICK: 4;
				case CP_CANCEL: 5;
			}
			sp.gotoAndStop( f );
		}
		
		var g = new flash.filters.GlowFilter();
		g.color = 0x0;
		g.alpha = 0.2;
		g.blurX = g.blurY = 4;
		sp.filters = [g];
		
		sp.scaleX = sp.scaleY = 0.8;
		sp.cacheAsBitmap = true;
		
		return sp;
	}
	
	public function pos(i)
	{
		return { x:b + i * 48, y:64 };
	}
	
	public function update() {
		bar.gotoAndStop( (2- game.char.pv) * 10 );
		for ( p in Type.allEnums(CharPowers))
			if ( game.char.powers.has(p) && !enabled.has(p) )
			{
				var pp = powers[p.index()];
				pp.filters = [];
				
				var t = Text.resolve('txt_cp' + p.index()).split('\r').join("");
				
				
				pp.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_){ 
					if( tip !=null )
						tip.show(t);
				});
				pp.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(_) {
					if( tip !=null)
						tip.hide();
				});
				
			}
		tip.update();
	
	}
	
	
}