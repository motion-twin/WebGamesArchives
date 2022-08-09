package en;

class Chest extends Enemy {
	public var onKill		: Chest->Void;
	//var bmp					: flash.display.Bitmap;
	
	public function new(r:Room, ?onKill:Chest->Void) {
		super();
		
		var containsMoney = onKill==null;
		
		radius = 25;
		initLife(1);
		fixed = true;
		color = containsMoney ? 0xDC98A3 : 0xFFB13E;
		score = api.AKApi.const(0);
		
		// Changement de depth
		spr.parent.removeChild(spr);
		game.sdm.add(spr, Game.DP_CHESTS);
		
		alertOutside = false;
		hasToBeKilled = true;
		autoKill = LeaveScreen;
		hitsPlayer = false;
		if( onKill!=null )
			this.onKill = onKill;
		else
			this.onKill = function(c) {
				// Contenu
				var pt = c.getScreenPoint();
				var coins = new mt.deepnight.RandList();
				if( game.diff<10 ) {
					coins.add(0, 10);
					coins.add(1, 3);
					coins.add(2, 1);
				}
				else {
					coins.add(0, 1);
					coins.add(1, 10);
					coins.add(2, 3);
				}
				var n = if( game.isProgression() ) rseed.irange(4,5) else rseed.irange(3, 8);
				for(i in 0...n) {
					var e = dropReward( coins.draw(rseed.random) );
					e.dx = rseed.range(0.02, 0.12, true);
					e.dy = -rseed.range(0.30, 0.50);
					if( pt.x<=170 ) e.dx = Math.abs(e.dx);
					if( pt.x>=Game.WID-170 ) e.dx = -Math.abs(e.dx);
				}
			}
		
		var mc = new lib.Coffre();
		spr.addChild( mc );
		
		animMC = cast mc;
		cacheAnims("chest");
		setAnim("on");
		
		// Placement
		var spots = r.getWallSpotsCopy();
		var ok = false;
		while( spots.length>0 ) {
			var pt = spots.splice( rseed.random(spots.length), 1 )[0];
			var x = pt.x;
			var y = pt.y;
			if( !r.hasMark(x,y) ) {
				var pt = r.localToGlobal(x,y);
				setPos(pt.cx, pt.cy);
				r.mark(x,y);
				r.mark(x,y+1);
				r.mark(x,y-1);
				r.mark(x+1,y);
				r.mark(x-1,y);
				ok = true;
				break;
			}
		}
		
		if( !ok ) {
			#if dev trace("chest failed in "+r); #end
			destroy();
		}
	}
	
	public override function toString() { return super.toString()+"[Chest]"; }
	
	public override function onDie() {
		onKill(this);
		fx.explodeLight(this, color);
		
		// Anim
		var mc = new lib.Ding();
		var pt = getPoint();
		fx.anim(mc, pt.x, pt.y).rotation = 0;
		
		// Reste au fond
		var r = getRoom();
		if( r!=null ) {
			setAnim("off");
			var m = new flash.geom.Matrix();
			var pt = getPoint();
			m.scale(0.9, 0.9);
			m.translate(pt.x - r.walls.x, pt.y - r.walls.y);
			spr.filters = [ mt.deepnight.Color.getColorizeMatrixFilter(game.bgColor, 0.7, 0.3) ];
			if( r.ready )
				r.walls.bitmapData.draw( spr, m, new flash.geom.ColorTransform(1,1,1,0.5) );
		}
		super.onDie();
	}
	
}
