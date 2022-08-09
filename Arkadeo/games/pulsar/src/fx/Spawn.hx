package fx;
import Protocol;
import mt.bumdum9.Lib;
import mt.kiroukou.math.MLib;

class Spawn extends mt.fx.Fx {

	public static var ALL:Array<Spawn> = [];

	var type:BadType;
	var timer:Int;
	public var trg:gfx.Spawn;
	var di:Null<Int>;
	public var borderPos: { di:Int, n:Float };
	
	public function new(type:BadType,x:Float,y:Float) {
		super();

		ALL.push(this);
		this.type = type;
		
		trg = new gfx.Spawn();
		Game.me.dm.add(trg, Game.DP_UFX);
		trg.x = x;
		trg.y = y;
		trg.blendMode = flash.display.BlendMode.ADD;
		//Filt.glow(trg, 4, 1, 0xFF00FF);
		trg.scaleX = trg.scaleY = 0.75;
		
		#if sound
		Sfx.play(12,0.5);
		#end
	}

	override function update() {
		super.update();
		timer++;
		var lim = 80;
		if( Game.me.have(SPAWN_SPEED) ) lim >>= 1;
		if( timer > lim ) {
			var bad = Bad.get(type);
			bad.setPos(trg.x, trg.y);
			if( borderPos != null ) bad.setBorderPos(borderPos.di, borderPos.n );
			kill();
			#if sound
			Sfx.play(11,0.5);
			#end
		}
	}
	
	override function kill() {
		if(dead) return;
		super.kill();
		ALL.remove(this);
		trg.parent.removeChild(trg);
	}
	
	inline static var RECAL_MIN_BORDER_X = Game.BORDER_X + 8;
	inline static var RECAL_MIN_BORDER_Y = Game.BORDER_Y + 8;
	
	inline static var RECAL_MAX_BORDER_X = Game.WIDTH - RECAL_MIN_BORDER_X;
	inline static var RECAL_MAX_BORDER_Y = Game.HEIGHT - RECAL_MIN_BORDER_Y;
	
	//SOME MODIFS HERE BY THOMAS : maybe some bugs appearing
	public static function recal() {
		var l = ALL.length;
		for ( i in 0...l ) {
			var a = ALL[i];
			for ( k in i + 1...l ) {
				var b = ALL[k];
				
				var dx = a.trg.x - b.trg.x;
				var dy = a.trg.y - b.trg.y;
				var lim = 16;
				
				if ( MLib.fabs(dx) < lim && MLib.fabs(dy) < lim ) {

					var dist = Math.sqrt(dx * dx + dy * dy);
					var dif = lim - dist;
					if ( dif > 0 ) {
						var an = Math.atan2(dy, dx);
						dx = Math.cos(an) * dif * 0.5;
						dy = Math.sin(an) * dif * 0.5;
						a.trg.x += dx;
						a.trg.y += dy;
						b.trg.x -= dx;
						b.trg.y -= dy;
					}
				}
			}
			
			// RECAL BORDER
			if ( a.trg.x < RECAL_MIN_BORDER_X || a.trg.x > RECAL_MAX_BORDER_X ) 	a.trg.x = MLib.fclamp( a.trg.x, RECAL_MIN_BORDER_X, RECAL_MAX_BORDER_X);
			if ( a.trg.y < RECAL_MIN_BORDER_Y || a.trg.y > RECAL_MAX_BORDER_Y ) 	a.trg.y = MLib.fclamp( a.trg.y, RECAL_MIN_BORDER_Y, RECAL_MAX_BORDER_Y);
		}
	}
}
