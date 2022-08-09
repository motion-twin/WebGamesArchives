import Common;
import mt.bumdum.Lib;

class Laser {
	var game : Game;
	var mc : EMC;
	var curtype : Int;
	var lastType : Int;
	var lastX : Float;
	var glowCycles : Int;
	var inter : {x1:Float,x2:Float};
	var pressTimer : Float;

	var glow : flash.filters.GradientGlowFilter;

	public function new( g : Game ) {
		game = g;
		mc = cast game.dm.attach("mcBar", Const.DP_BALL );
		mc.x = mc._x = Const.HEIGHT / 2;
		mc.gotoAndStop( 1 );
		curtype = 0;
		glowCycles = 0;
		pressTimer = 0.0;

		var color = 0x00FF99;
		glow = new flash.filters.GradientGlowFilter( 0, 45, [color, color], [0, 1], [0, 255], 8, 8 , 2, 3, "outer" );		
	}

	public function updatePos(fx : Float) {
		pressTimer++;

		if( game.gameOver ) {
			mc._visible = false;
			return;
		}

		if( curtype <= 0 )
			mc.filters = [];
		else
			mc.filters = [glow];

		if( fx - lastX <  0 )
			inter = {x1:fx,x2:lastX};
		else
			inter = {x1:lastX,x2:fx};

		if( Math.abs( fx - lastX ) > KKApi.val( Const.LASER_OFF ) ) {
			curtype = 0;
			mc.gotoAndStop( 1 );
		}

		if( fx < Const.CANON_WIDTH ) {
			move( Const.CANON_WIDTH );
			return;
		}

		if( fx > Const.HEIGHT - Const.CANON_WIDTH ) {
			move( Const.HEIGHT - Const.CANON_WIDTH );
			return;
		}
		
		move(fx); 
	}

	function move(v:Float) {
		mc.x = mc._x = lastX = v;
	}

	public function switchType() {
		pressTimer = 0.0;

		if( curtype > 2 ) {
			curtype = 0;
			var color : Float = cast 0x00FF99;
			var cl = glow.colors;
			cl = [color,color];
			glow.colors = cl;
		}
		else {
			curtype++;
		}

		mc.gotoAndStop( curtype + 1 );
		var cl = glow.colors;
		cl = [cast Const.COLORS[curtype - 1], cast Const.COLORS[curtype - 1]];
		glow.colors = cl;
	}

	public function testPress() {
		if( pressTimer > 20 ) {
			curtype = 0;
			mc.gotoAndStop( 1 );
			pressTimer = 0.0;
		}
	}

	public function hit( b : Ball ) {
		var r = Const.getRectangle( b.mc );
		if( b.bonus ) {
			if( curtype > 0) {
				return false;
			}
			if( b.mc.x > inter.x1 && b.mc.x < inter.x2 ) {
				return true;
			}

			if( r.contains( mc.x, b.mc.y ) ) {
				return true;
			}
		}

		if( b.type + 1 != curtype  ) {
			return false;
		}

		if( b.mc.x > inter.x1 && b.mc.x < inter.x2 ) {
			return true;
		}

		if( r.contains( mc.x, b.mc.y ) ) {
			return true;
		}
		return false;
	}

	public function hitCar( car : flash.MovieClip ) {
		if( curtype > 0 ) {
			if( car._y < car._height / 2 ) return false;

			var r = new flash.geom.Rectangle( car._x - car.smc._width / 2, car._y, car.smc._width, car.smc._height );
			if( r.contains( mc.x, car._y ) ) {
				return true;
			}
			return false;
		}
		return false;
	}
	
	public function hitAnim( b: Ball) {
		for( i in 0...10 ) {
			var m = game.dm.attach( "mcLaserPart", Const.DP_CANON );
			m._x = mc.x;
			m._y = b.mc.y;
			m._yscale = 100 * Std.random( 3 );
			m._rotation = Std.random( 360 );
			var p = new mt.bumdum.Phys(m);
			p.timer = 5;
			p.vx = Math.cos( m._rotation * Math.PI / 180 );
			p.vy = Math.cos( m._rotation * Math.PI / 180 );
			Filt.glow( p.root, 8,1, Const.COLORS[b.type] );
		}
	}
}
