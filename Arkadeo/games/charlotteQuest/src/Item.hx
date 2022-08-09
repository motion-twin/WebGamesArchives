typedef ItemMC = { > flash.display.MovieClip, _smc : flash.display.MovieClip }
class Item extends Entity {
	var realGravity		: Float;
	var bubble			: Null<lib.Bubble>;
	var bubbleBmp		: Null<flash.display.Bitmap>;
	var hasBeenCaptured	: Bool;
	
	public function new() {
		super();
		radius = 25;
		realGravity = gravity;
		hasBeenCaptured = false;
		
		game.items.add(this);
		game.sdm.add(spr, Game.DP_ITEM);
		
		autoKill = Entity.KillCond.LeaveScreen;
	}
	
	public override function toString() { return "Item#"+uid; }
	
	public override function unregister() {
		super.unregister();
		game.items.remove(this);
	}
	
	public function pickUp() {
		var pt = getPoint();
		fx.popDots(pt.x, pt.y, color);
	}
	
	public override function update() {
		// Apparition bulle de capture
		var capture = game.player.build.capture;
		if( capture>0 && !hasBeenCaptured ) {
			hasBeenCaptured = true;
			realGravity = gravity;
			bubble = new lib.Bubble();
			spr.addChild(bubble);
			bubble.alpha = 0.5;
			bubble.blendMode = flash.display.BlendMode.ADD;
			setCD("capture", 15 + capture*12 + rseed.range(0,5));
			gravity = 0.01 * realGravity;
			if( capture<2 )
				dy*=0.5;
			else
				dy*=0.2;
		}
		
		// Aimant
		if( capture>0 && hasCD("capture") && game.time%3==0 && !game.player.dead() ) {
			var d = mt.deepnight.Lib.distance(rx,ry, game.player.rx, game.player.ry);
			var a = Math.atan2(game.player.ry-ry, game.player.rx-rx);
			var pow = (1 - Math.min(1, d/180)) * (capture/6);
			dx += Math.cos(a) * 0.1*pow;
			dy += Math.sin(a) * 0.1*pow;
		}
		
		if( bubble!=null || bubbleBmp!=null ) {
			if( game.perf<=0.85 && bubbleBmp==null ) {
				bubbleBmp = mt.deepnight.Lib.flatten(bubble, true);
				bubble.parent.addChild(bubbleBmp);
				bubble.parent.removeChild(bubble);
				bubble = null;
			}
			if( !hasCD("capture") ) {
				gravity = realGravity;
				if( bubble!=null ) {
					bubble.parent.removeChild(bubble);
					bubble = null;
				}
				if( bubbleBmp!=null ) {
					bubbleBmp.parent.removeChild(bubbleBmp);
					bubbleBmp.bitmapData.dispose();
					bubbleBmp = null;
				}
				var pt = getPoint();
				fx.anim( new lib.Pop(), pt.x, pt.y );
			}
		}
		
		var pt = getScreenPoint();
		if( pt.y<=5 )
			dy = 0.1;

		super.update();
		
		if( checkHit(game.player, true) ) {
			destroy();
			pickUp();
		}
	}
}

