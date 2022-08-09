import mt.bumdum9.Lib;
import mt.bumdum9.Lib.Num;

typedef Star = { > flash.display.MovieClip, sc:Float, bx:Float, by:Float };

class Level extends flash.display.Sprite{//}

	public static var WIDTH = 1600;
	public static var HEIGHT = 1600;
	
	public static var DP_BG = 0;
	public static var DP_CELLS = 1;
	
	
	public var tracer:flash.display.Sprite;
	public var focus:Cell;
	public var scale:Float;
	var tsc:Float;
	public var dm:mt.DepthManager;

	public function new() {
		
		super();

		
		dm = new mt.DepthManager(this);	
		scale = 2;
		tsc = 1;
		
		tracer = dm.empty(4);
		
		initStarfield();
	
	}
	
	public function setScale(n:Float) {
		
		
		for( sp in starfield ) {
			var dx = 150 - sp.x;
			var dy = 150 - sp.y;			
			var nx = 150 - (dx * n) / scale;
			var ny = 150 - (dy * n) / scale;
			
			var c = sp.sc;
			sp.x = nx * c + sp.x * (1 - c);
			sp.y = ny * c + sp.y * (1 - c);
			
		}
		
		
		
		scale = n;
		scaleX = n;
		scaleY = n;
		
		
		
	}

	public function scroll() {
		
		var min = Game.mcw / (WIDTH - 300);
		var max = 6;
		
		// ZOOM
		var sc = 16 / Game.me.hero.ray;		
		//sc *= 0.2;
		var dif = WIDTH * (sc - scale);
		
		if( Math.abs(dif) > 400 * scale ) {
			tsc = Num.mm(min,sc,max);
		}	
		if( tsc != scale ) {			
			var dif = (tsc - scale) * 0.1;
			setScale(scale + dif);			
		}
		
		Game.me.bgScroller.scaleX = 1+(scaleX-min)*1.5;
		Game.me.bgScroller.scaleY = 1+(scaleY-min)*1.5;

		// SCROLL
		if( focus != null ) {
			//x = Num.mm( -(WIDTH*scale - Game.mcw), Game.mcw*0.5-focus.x*scale, 0 );
			//y = Num.mm( -(HEIGHT*scale - Game.mch), Game.mch*0.5-focus.y*scale, 0 );
			x = Game.mcw * 0.5 - focus.x*scale;
			y = Game.mch * 0.5 - focus.y * scale;
			
		}
		
		//trace(x+", "+y);
		
		// STARS
		updateStarField();
		
		// 

		
	}
	
	public function kill() {
		parent.removeChild(this);
		while(starfield.length > 0) {
			var sp = starfield.pop();
			sp.parent.removeChild(sp);
		}
	}
	
	
	// STARFIELD
	public var starfield:Array<Star>;
	public function initStarfield() {
		
		starfield = [];
		var max = 100;
		for( i in 0...max ) {
			var c = i / max;
			var sp:Star = cast new flash.display.MovieClip();
			
			
			var bsc = Game.me.bgScroller.scaleX;
			
			sp.sc = c;
			var gfx = new McMicroCell();
			sp.addChild(gfx);
			sp.scaleX = sp.scaleY = 0.2 + c * 0.8;
			gfx.gotoAndStop(Std.random(gfx.totalFrames) + 1);
			gfx.rotation = Math.random() * 360;

			sp.alpha = 0.4;
			
			sp.x = Math.random() * Game.mcw * 4;
			sp.y = Math.random() * Game.mch * 4;
			starfield.push(sp);
			
			
			Game.me.dm.add(sp, 1 );
			
		}
	}
	public function updateStarField() {
		
		var h  = Game.me.hero;
		
		if( h == null || h.dead ) {
			for( sp in starfield ) if(sp.alpha > 0 ) sp.alpha -= 0.1;
			return;
		}
		
		
		var ray = 150;
		for( sp in starfield ) {
				

			
			/*
			var coef = 0.3 / scale;
			var sc = 1 * coef + sp.sc*(1 - coef);
						
			sp.x -= focus.vx * (sc*0.5)*scale;
			sp.y -= focus.vy * (sc*0.5)*scale;
			
			var c = Math.max(1, sc);
			var nx = Num.hMod(sp.x - ray, ray * c);
			var ny = Num.hMod(sp.y - ray, ray * c);
			sp.x = nx+ray;
			sp.y = ny + ray;
			*/
			
			var bsc = Game.me.bgScroller.scaleX * 0.2;
			
			var c = bsc * (1 - sp.sc) + sp.sc * scale;

			//var c = bsc;
	
			sp.x -= h.vx*c;
			sp.y -= h.vy*c;
		
			//trace(sp.x);
			
			//sp.x = Num.sMod(sp.x, 300);
			//sp.y = Num.sMod(sp.y, 300);
			
			
			var c = 1 + sp.sc*0.25;	//3
			
			var nx = Num.hMod(sp.x - ray, ray * c);
			var ny = Num.hMod(sp.y - ray, ray * c);
			sp.x = nx + ray;
			sp.y = ny + ray;
			
			sp.alpha = Num.mm(0, scale-0.25 , 1)*0.4;
			
			
			/*
			var inc = 0.01;
			var lim = 0.5;
			
			var trg  = 0;
			if( scale > 0.3 ) trg = 0.2;
			if( scale > 0.5 ) trg = 0.5;
			if( scale > 1 ) trg = 0.75;
			if( scale > 1 ) trg = 0.75;

			if( scale < lim && sp.alpha > 0 ) 	sp.alpha -= inc;
			if( scale > lim && sp.alpha < 1 ) 	sp.alpha += inc;
			*/
			
			/*
			sp.x = sp.bx + focus.x * sc;
			sp.y = sp.by + focus.y * sc;
			sp.x = sp.x % Game.mcw;
			sp.y = sp.y % Game.mch;
			*/
			
		}
		
	}
	
//{
}





















