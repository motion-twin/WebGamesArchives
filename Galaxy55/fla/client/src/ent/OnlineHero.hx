package ent;

class OnlineHero extends net.RealTime.Entity {

	var game : Game;
	
	public var id : Int;
	public var name : String;
	public var x : Float;
	public var y : Float;
	public var z : Float;
	public var angle : Float;
	public var camera : Bool;
	
	public var bmp : h3d.mat.PngBytes;
	public var select : Null<r3d.AbstractGame.GameEffectsSelect>;
	
	public function new(g, i, s) {
		var e : r3d.AbstractGame.GameEffectsEntity = this;
		super(i, s);
		id = i.uid;
		name = i.name;
		game = g;
		x = s.x;
		y = s.y;
		z = s.z;
		angle = s.a;
		camera = i.camera;
		bmp = game.cloneTex;
		game.userMap.set( i.uid, i.name);
	}
	
	inline function collide(x, y, z:Float) {
		return game.level.collide(x, y, z);
	}
	
	override function sync( s : net.RealTime.State ) {
		state = s;
		var dx = x - s.x;
		var dy = y - s.y;
		if( dx*dx+dy*dy > 2 ) {
			x = s.x;
			y = s.y;
		}		
		z = s.z;
		angle = s.a;
		select = s.select;
	}
	
	public function update( tmod : Float ) {
		var viewZ = 1.5;
		var a = angle;
		var gravity = state.g;

		var p = Math.pow(0.5, tmod);
		x = x * p + (1 - p) * state.x;
		y = y * p + (1 - p) * state.y;
		
		z -= gravity * tmod;
		
		// foot collide points
		var foots = new Array();
		for( da in [0,Math.PI*2/3,-Math.PI*2/3] )
			foots.push({ px : x + Math.cos(a+da)*0.1, py : y + Math.sin(a+da)*0.1 });

		// foot collision
		var col = false;
		for( f in foots )
			if( collide(f.px,f.py,z-0.01) ) {
				col = true;
				break;
			}

		// head collision
		if( gravity < 0 && !col ) {
			var found = false;
			var d = viewZ + 0.13;
			var recal = 0.;
			for( f in foots )
				while( recal < 0.5 && collide(f.px, f.py, z + d) ) {
					z -= 0.01;
					recal += 0.01;
				}
			if( recal > 0 && recal < 0.5 )
				gravity = 0;
		}

		if( !col )
			gravity += 0.014 * tmod;
		else {
			if( gravity >= 0 ) {
				var h = Std.int(z * 32) / 32;
				game.level.collideEmpty = false;
				while( true ) {
					var found = false;
					for( f in foots )
						if( collide(f.px, f.py, h) ) {
							found = true;
							break;
						}
					if( !found ) break;
					h += 1/32;
				}
				game.level.collideEmpty = true;
				z = h;
			}
		}
		
		state.g = gravity;
	}
	
}