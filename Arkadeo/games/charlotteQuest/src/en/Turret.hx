package en;

class Turret extends Enemy {
	public static var MIN_DIFF = 0;
	
	var cadency		: Int;
	var mc			: lib.Tourelle;
	var baseAng		: Float;
	var basePtX		: Float;
	var basePtY		: Float;
	var level		: mt.flash.Volatile<Int>;
	
	public function new(r:Room, l:Int) {
		super();
		
		level = l;
		radius = 22;
		initLife(level==0 ? 1 : 2);
		fixed = true;
		
		cadency = 40*4;
		setCD("shoot", cadency + rseed.random(cadency));
		alertOutside = false;
		
		baseAng = 0;
		
		mc = new lib.Tourelle();
		mc.scaleX = mc.scaleY = level==0 ? 0.8 : 1;
		mc.stop();
		mc._smc.stop();
		spr.addChild(mc);
		basePtX = mc._smc.x;
		basePtY = mc._smc.y;
		animMC = cast mc;
		hasToBeKilled = false;
		if( level==0 )
			mc.filters = [ mt.deepnight.Color.getColorizeMatrixFilter(0xC8522B, 0.5, 0.5) ];
		
		// Placement
		var spots = r.getEmptySpotsCopy();
		var ok = false;
		while( spots.length>0 ) {
			var pt = spots.splice( rseed.random(spots.length), 1 )[0];
			var x = pt.x;
			var y = pt.y;
			if( !r.hasMark(x,y) )
				if( r.getCol(x-1,y) || r.getCol(x+1,y) || r.getCol(x,y-1) || r.getCol(x,y+1) ) {
					setPos(r.cx*Room.CWID + x, r.cy*Room.CHEI + y);
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
			#if dev trace("turret failed in "+r); #end
			destroy();
		}
	}
	
	public override function toString() { return super.toString()+"[Turret]"; }
	
	public override function onDie() {
		super.onDie();
		dropReward( level==0 ? 0 : 1 );
	}
	
	public override function setPos(x,y, ?xrr:Float,?yrr:Float) {
		super.setPos(x,y,xrr,yrr);
		if( getCol(cx,cy-1) ) {
			yr = 0.1;
			baseAng = 1.57;
		}
		else if( getCol(cx,cy+1) ) {
			yr = 0.9;
			baseAng = -1.57;
		}
		else if( getCol(cx-1,cy) ) {
			xr = 0.1;
			baseAng = 0;
		}
		else {
			xr = 0.9;
			baseAng = 3.14;
		}
		mc._smc.rotation = mt.deepnight.Lib.deg(baseAng);
	}
	
	public override function hit(d, ?from) {
		super.hit(d, from);
		setAnim();
		setAnim("hit", false);
	}
	
	override function setAnim(?a, ?loop=true) {
		super.setAnim(a, loop);
		updateAng();
	}
	
	function updateAng() {
		var a = getAngleTo(game.player);
		var d = a-baseAng;
		if( d>3.14 )
			d-=6.28;
		if( d<-3.14 )
			d+=6.28;
			
		var max = 1.8;
		if( d<-max )
			a = baseAng-max;
		if( d>max )
			a = baseAng+max;
			
		mc._smc.rotation = mt.deepnight.Lib.deg( a ) + 180;
		return a;
	}
	
	public override function update() {
		super.update();
		
		if( animDone() ) {
			if( anim=="shoot" )
				setAnim("wait");
			if( anim=="hit" )
				setAnim("wait");
		}
		
		var a = updateAng();
		
		// Tir
		var cd = getCD("shoot");
		if( cd>0 && cd<32 && mc.currentFrameLabel=="wait" )
			setAnim("charge");
			
		if( cd<=0 ) {
			setAnim("shoot", false);
			setCD("shoot", cadency);
			if( onScreen ) {
				var b = new bullet.Bad(this);
				b.followScroll = false;
				b.xr += Math.cos(a)*1;
				b.yr += Math.sin(a)*1-0.2;
				b.dx = Math.cos(a)*b.speed;
				b.dy = Math.sin(a)*b.speed;
			}
		}
		
		mc._smc.x = basePtX + Math.sin(uid + game.time*0.02*3.14) * 5;
		mc._smc.y = basePtY + Math.sin(uid + game.time*0.03*3.14) * 5;
	}
}
