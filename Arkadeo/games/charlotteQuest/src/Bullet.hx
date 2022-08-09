import mt.flash.Volatile;
class Bullet extends Entity {
	public var range		: Volatile<Float>;
	public var power(default,setPower)	: Volatile<Float>;
	public var hitPlayer	: Bool;
	var trailWid			: Int;
	
	public function new() {
		super();
		range = 150;
		game.bullets.add(this);
		game.sdm.add(spr, Game.DP_BULLET);
		trailWid = 1;
		
		autoKill = Entity.KillCond.LeaveScreen;
		autoKillOutsider = true;
		radius = 5;
		power = 1;
		followScroll = true;
		hitPlayer = true;
	}
	
	public function setPower(p:Float) {
		power = p;
		return power;
	}
	
	public override function toString() { return "Bullet#"+uid; }
	
	public override function unregister() {
		super.unregister();
		game.bullets.remove(this);
	}
	
	public function hitTarget(e:Entity) {
		var pt1 = getPoint();
		var pt2 = e.getPoint();
		fx.hit(pt1.x + (pt2.x-pt1.x)*0.5, pt1.y + (pt2.y-pt1.y)*0.5, color);
		
		if(!e.hasCD("uber"))
			e.hit(power, this);
		destroy();
	}
	
	public override function update() {
		super.update();
		
		// limite de portée
		if( range>0 )
			range -= Math.sqrt( Room.GRID * dx * Room.GRID * dx + Room.GRID * dy * Room.GRID * dy );
		if( !deleted && range<=0 ) {
			if( hitPlayer )
				fx.popCircle(this);
			destroy();
			return;
		}
		
		// Hit
		if( hitPlayer ) {
			if( checkHit(game.player, true) ) {
				hitTarget(game.player);
				return;
			}
		}
		else
			for(e in game.enemies)
				if( checkHit(e, true) ) {
					hitTarget(e);
					return;
				}
				
		// Trainée
		if( trailWid>0 && game.perf>=0.8 && !dead() ) {
			var pt = getScreenPoint();
			var s = Game.RAINBOW_SCALE;
			pt.x = Std.int(pt.x/s);
			pt.y = Std.int(pt.y/s);
			game.rainbow.bitmapData.fillRect( new flash.geom.Rectangle(pt.x, pt.y, trailWid,trailWid), mt.deepnight.Color.addAlphaF(color) );
		}
	}
}
