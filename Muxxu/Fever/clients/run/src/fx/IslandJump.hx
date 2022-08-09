package fx;
import mt.bumdum9.Lib;



class IslandJump extends mt.fx.Fx{//}
	
	static var RAINBOW_MARGIN = 0.1;

	var prevIsland:world.Island;
	var nextIsland:world.Island;
	var trg:world.Square;
	var tw:Tween;
	var dir:Int;
	var h:world.Hero;
	
	var arcs:Array<pix.Element>;
	var oldPos: { x:Float, y:Float };
	var star:FxRainbowStar;
	
	public function new(dir:Int) {
		super();
		this.dir = dir;
		World.me.setControl(false);
		coef = 0;
		
		
		var island = World.me.island;
		
		var d = Cs.DIR[dir];
		var p = island.getNextIslandPos(dir);
		
		nextIsland = new world.Island(p.x, p.y );
		nextIsland.attachOcean();
		World.me.dm.add(nextIsland,World.DP_MAP);
		
		var ww = world.Island.XMAX;
		var hh = world.Island.YMAX;
		nextIsland.x = island.x+ d[0] * ww*16;
		nextIsland.y = island.y+ d[1] * hh*16;
	

		h = World.me.hero;
		h.swapToIsland(nextIsland);
		trg = h.island.seekJumpStone((dir + 2) % 4);
		h.setPos(h.sq.x - d[0] * ww, h.sq.y - d[1] * hh);
		h.setDir(dir,true);
		h.sprite.anim.play(2);
		
		tw = new Tween(h.root.x, h.root.y, (trg.x + 0.5) * 16, (trg.y+1) * 16);
		World.me.island = nextIsland;
		prevIsland = island;
		
		//
		oldPos = getPos(0);
		
		//
		star = new FxRainbowStar();
		star.scaleX = star.scaleY = 0.1;
		nextIsland.dm.add(star, world.Island.DP_FX );
		Filt.glow(star, 2, 10, 0xFFFFFF);
		
		
		
		
	}
	
	function getPos(c) {
		var p = tw.getPos(c);
		p.y  -= Math.sin(c * 3.14) * 100;
		return p;
	}
	
	override function update() {
		
		coef = Math.min(coef + 0.015, 1);
		
		var p = getPos(coef);
		h.root.x = Std.int(p.x);
		h.root.y = Std.int(p.y );
		
		// RECAL PREV ISLAND
		var d = Cs.DIR[dir];
		prevIsland.x = World.me.island.x - d[0]*world.Island.XMAX*16;
		prevIsland.y = World.me.island.y - d[1]*world.Island.YMAX*16;
		
		// RAINBOW
		var me = this;
		if( oldPos != null ){
			var cc = coef + RAINBOW_MARGIN;
			var np = getPos(Math.min(cc, 1));
			
			var dx = np.x - oldPos.x;
			var dy = np.y - oldPos.y;
			var p = new pix.Part();
			p.drawFrame(Gfx.fx.get("rainbow"),0,0.5);
			p.setPos( oldPos.x, oldPos.y );
			p.rotation = Math.atan2(dy, dx) / 0.0174;
			p.scaleX = (Math.sqrt(dx * dx + dy * dy) + 2) / 16;
			p.timer = 50;
			p.snapPix = false;
			p.fadeType = 4;
			p.fadeLimit = 5;
			p.onDeath = function() { me.vanish(p); };
			
			var start = coef < 0.5;

			var dp = ( h.dir != 3 )?world.Island.DP_UNDERGROUND:world.Island.DP_WAVES;
			
			World.me.island.dm.add(p,dp);
			oldPos = np;
			
			star.x = np.x;
			star.y = np.y;
			star.rotation += 4;
			
			
			if( cc > 0.99 ) {
				oldPos = null;
				star.parent.removeChild(star);
				var max = 32;
				var cr = 3;
				for( i in 0...max ) {
					var p =  getDust();
					var a = (i / max) * 6.28;
					var speed = Math.random() * 3;
					p.vx = Math.cos(a) * speed;
					p.vy = Math.sin(a) * speed - 1.5;
					p.setPos( star.x + p.vx * cr, star.y + p.vy * cr);
				}
			}
		}

		if( coef == 1 ) {
			h.setSquare(trg);
			h.island.respawn = trg;
			prevIsland.kill();
			world.Inter.me.majIslandName(  h.island.getName() );
			h.sprite.anim.goto(0);
			h.sprite.anim.stop();
			kill();
			World.me.setControl(true);
		}
		
	}
		
	function getDust() {
		var p = new pix.Part();
		p.setAnim(Gfx.fx.getAnim("twinkle_gray"));
		Col.overlay( p, Col.getRainbow2(Math.random())  );
		p.frict = 0.95;
		p.weight = 0.05 + Math.random() * 0.05;
		p.timer = 12 + Std.random(12);
		p.anim.gotoRandom();
		nextIsland.dm.add(p, world.Island.DP_FX);
		return p;
	}
			
	
	
	function vanish(a:pix.Part) {
	
		var p = getDust();
		p.xx = a.x + Std.random(9) - 4;
		p.yy = a.y + Std.random(9) - 4;
		p.updatePos();
		
	}
	
	
	
	
//{
}








