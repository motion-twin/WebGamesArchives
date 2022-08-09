import Common;
import mt.bumdum.Phys;
import mt.bumdum.Lib;

class Ball {

	var game : Game;
	var targetX : Float;
	var targetY : Float;
	var yf : Float;
	var xf : Float;
	var speed : Float;
	var glow : flash.filters.GradientGlowFilter;

	public var bonus : Bool;
	public var moveLeft : Bool;
	public var mc : EMC;
	public var type : Int;

	public function new( g : Game, x : Float, y : Float, target : Canon ) {
		game = g;
		mc = cast game.dm.attach( "mcBall", Const.DP_BALL );
		mc.x = mc._x = x;
		mc.y = mc._y = y;

		var s = KKApi.val( Const.LEARN_STEP );

		if( s > 1 && Std.random( 100 ) < KKApi.val( Const.BONUS_BALL_PROBA ) ) {
			mc.gotoAndPlay(1);
			type = 4;
			bonus = true;
		}
		else {
			var rand = Std.random( 100 );
			var type = 0;
			if( rand < KKApi.val( Const.BALL3_PROBA  ) ) {
				type = 2;
			}
			else if( rand < KKApi.val( Const.BALL2_PROBA ) ) {
				type = 1;
			}

			if( s < 3 && s < type ){
				this.type = s;
			}else {
				this.type = type;
			}

			mc.gotoAndStop( this.type +1 );
		}
		targetX = target.mc._x;
		targetY = target.mc._y;
		speed = ( type + 1 ) * 0.5 * KKApi.val( Const.BALL_SPEED ) / 100;

		var r = Math.atan2( targetY - y, targetX - x);
		yf = Math.sin( r ) * speed; 
		xf = Math.cos( r ) * speed; 
		moveLeft = xf < 0;
		
		var color = Const.COLORS[type];
		glow = new flash.filters.GradientGlowFilter( 0, 45, [color, color], [0, 1], [0, 255], 8, 8 , 1, 3, "outer" );		
	}

	public function move(tmod : Float ) {
//		mc.filters = [glow];
		mc.x += xf * tmod;
		mc._x = mc.x;
		mc.y += yf * tmod;
		mc._y = mc.y;

		if( mc.x <=  -mc._width / 2 ) clean();
		if( mc.x >=  Const.HEIGHT + mc._width / 2 ) clean();
	}

	public function destroy( score : Int ) {
		if( score > 0 ){
			var s : {>flash.MovieClip,s:flash.TextField} = cast game.dm.attach("mcScore", Const.DP_CANON );
			s._x = mc.x;
			s._y = mc.y - 5;
			s.s.textColor = Const.COLORS[ type ];
			s.s.text = Std.string( score );
			var p = new Phys( s );
			p.timer = 12;
			p.fadeLimit = 10;
			p.fadeType = 0;
			Filt.glow( p.root, 4, 2, 0x000000 );
		}

		if( bonus ) {
			for( i in 0...14 ) {

				var m = game.dm.attach( "mcBallPart", Const.DP_BALL );
				m.gotoAndStop( Std.random( Const.COLORS.length ) + 1 );
				m._x = mc.x;
				m._y = mc.y;
				m._rotation = Std.random( 360 );
				var p = new Phys( m );
				p.timer = 20;
				var s = KKApi.val( Const.BALL_SPEED );
				var rad = m._rotation * Math.PI / 180;
				p.vx = ( 0.5 ) * Math.cos( rad ) * s / 100 * ( if( Std.random(2) == 0 ) 2  else -2 );
				p.vy = ( 0.5 ) * Math.sin( rad ) * s / 100 * ( if( Std.random(2) == 0 ) 2 else -2 );
				p.sleep = if( i >  0 ) i * 3;
				p.frict = 1.1;
				p.vsc = 1.15;
				Filt.glow( p.root, 8,1, Const.COLORS[Std.random( Const.COLORS.length )] );

				/*
				var m = game.dm.attach( "mcBallPart", Const.DP_BALL );
				m.gotoAndStop( Std.random(3) );
				m._x = mc.x;
				m._y = mc.y;
				m._rotation = Std.random( 360 );
				var p = new Phys( m );
				p.fadeType = 4;
				p.timer = 20;
				p.vr = 1.2;
				p.vsc = 1.02;
				var s = KKApi.val( Const.BALL_SPEED );
				p.vx = ( type + 1 ) * Math.cos( m._rotation * Math.PI / 180 ) * s / 100 * 0.8;
				p.vy = ( type + 1 ) * Math.sin( m._rotation * Math.PI / 180 ) * s / 100 * 0.8 ;
				*/
			}
			clean();
			return;
		}

		for( i in 0...3 ) {
			for( j in 0...9 ) {
				var m = game.dm.attach( "mcBallPart", Const.DP_BALL );
				m.gotoAndStop( type + 1 );
				m._x = mc.x;
				m._y = mc.y;
				m._rotation = Std.random( 360 );
				var p = new Phys( m );
				p.timer = 20;
				var s = KKApi.val( Const.BALL_SPEED );
				var rad = m._rotation * Math.PI / 180;
				p.vx = ( 0.5 ) * Math.cos( rad ) * s / 100 * ( if( Std.random(2) == 0 ) 3  else -3 );
				p.vy = ( 0.5 ) * Math.sin( rad ) * s / 100 * ( if( Std.random(2) == 0 ) 3 else -3 );
				p.sleep = if( i >  0 ) i * 2;
				p.frict = 1.05;
				p.vsc = 1.05;
				Filt.glow( p.root, 8,1, Const.COLORS[type] );
//				game.plasmaPart.push( p );
//				p.fr = 20;
				//p.weight = if( Std.random( 2) == 0 ) -(1 + i / 30) else 1 + i / 30;
			}
		}

		clean( );
	}

	public function clean() {
		mc.removeMovieClip( );
		mc = null;
	}

	static var learnCycle : Float = KKApi.val( Const.LEARN_CYCLE );

	public static function update(tmod:Float) {
		if( KKApi.val( Const.LEARN_STEP ) > 2 ) return;
		learnCycle -= tmod;

		if( learnCycle <= 0 ) {
			Const.LEARN_STEP = KKApi.const( KKApi.val(Const.LEARN_STEP) + 1 );
			learnCycle = KKApi.val( Const.LEARN_CYCLE );
		}
	}
	
}
