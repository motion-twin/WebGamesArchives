import Common;
import Anim;
import mt.bumdum.Phys;
import mt.bumdum.Lib;

class Canon {
	
	public var mc : EMC;
	public var invert : Bool;
	public var cycles : Float;
	public var idx : Int;
	public var destroyed : Bool;
	public var startAnim : Bool;
	public var init : Bool;
	public var shield : Int;

	var glow : flash.filters.GradientGlowFilter;
	var ds : flash.filters.DropShadowFilter;
	var ds2 : flash.filters.DropShadowFilter;
	var game : Game;
	var locked : Bool;

	public function new(g: Game, y = 0.0, invert = false, idx : Int, shield = -1) {		
		this.shield = shield;
		startAnim = false;
		init = false;
		locked = false;
		game = g;
		this.idx = idx;
		mc = cast game.dm.attach( "mcCanon", Const.DP_CANON );
		mc._visible = false;
		mc.y = mc._y = y;
		if( shield > 0 ) {
			mc.gotoAndStop( shield + 1);
			mc.smc.gotoAndStop( shield + 1);
		}
		else {
			mc.gotoAndStop( 1 );
			mc.smc.gotoAndStop( 1 );
		}

		this.invert = invert;
		if( invert ) {
			mc._rotation = -180;
			mc.x = mc._x = Const.HEIGHT + mc._width;
		} else {
			mc.x = mc._x = -mc._width;
		}

		cycles = 0;
		var color = 0x00FF99;
		glow = new flash.filters.GradientGlowFilter( 0, 45, [color, color], [0, 1], [0, 255], 4, 4 , 1, 3, "outer" );		
		ds = new flash.filters.DropShadowFilter( 0 );
		ds.blurX = 4;
		ds.blurY = 4;
		ds.strength = 2;
		ds2 = new flash.filters.DropShadowFilter(0);
		ds2.blurX = 2;
		ds2.blurY = 2;
	}

	public function initFire( target : Canon ) {
		if( locked )  return;
		if( destroyed ) true;

		cycles -= mt.Timer.tmod;
		if( cycles <= 0 ){
			locked = true;
			var a = new MoveFireAnim( this, target );
			var me = this;
			a.onEnd = function() {
				var b = new FireAnim( me );
				b.onEnd = function() {
					me.locked = false;
					var f = KKApi.val( Const.FIRE_CYCLE ) / 10;
					me.cycles = f + Std.random( Math.ceil( f / 2 ) );
					if( !target.destroyed ) { // Si le canon ennemi n'a pas encore été détruit entre temps
						var c = new Ball( me.game, me.getFireX(), me.getFireY(), target );
						me.game.balls.push( c );					
						for( i in 0...15 ) {
							var m = me.game.dm.attach( "mcBallPart", Const.DP_CANON );
							m.gotoAndStop( c.type + 1 );
							m._x = me.getFireX();
							m._y = me.getFireY();
							m._rotation = me.mc.smc._rotation - 45;
							var p = new Phys( m );
							p.timer = 10;
							var s = KKApi.val( Const.BALL_SPEED );
							var rad = m._rotation * Math.PI / 180;
							p.vx = Math.cos( rad ) * s / 100 * ( if( me.invert ) -2 else 2 );
							p.vy = Math.sin( rad ) * ( if( Std.random(2) == 0 ) 2 else -2 );
							p.vsc = 1.02;
							p.frict = 1.02;
							p.sleep = Std.random( 3 );
							Filt.glow( p.root, 8,1, Const.COLORS[c.type] );										
						}
					}
				}
				me.game.anim.push( b );
			};
			game.anim.push( a );
		}
	}

	public function display() {
		mc._visible = true;
	}

	public function hasShield() {
		return shield >= 0;
	}

	public function update() {
		mc.filters = [glow,ds];
	}

	public function prepare() {
		var f = KKApi.val( Const.FIRE_CYCLE ) / 10;
		cycles = f + Std.random( Math.ceil( f / 2 ) );
		init = true;
	}

	function getFireX() {
		var rot = mc.smc._rotation * Math.PI / 180;
		if( invert )
			return mc.x - mc.smc._x - Math.cos( rot ) * mc.smc._width;

		return mc.x + mc.smc._x + Math.cos( rot ) * mc.smc._width;
	}

	function getFireY() {
		var y = 0.0;
		var rot = mc.smc._rotation * Math.PI / 180;
		if( mc.smc._rotation == 0 ) {
			return mc._y;
		}

		if( invert )
			return mc.y - Math.sin( rot ) * mc.smc._width;

		return mc.y + Math.sin( rot ) * mc.smc._width;
	}

	public function moveX( x = 0.0 ) {
		if( invert ) {
			mc.x -= x;
			mc._x = mc.x;
		} else {
			mc.x += x;
			mc._x = mc.x;
		}
	}

	public function canBeTouched() {
		if( !startAnim ) return false;
		if( !init ) return false;
		if( destroyed ) return false;
		return true;
	}

	public function destroy() {
		destroyed = true;

		if( shield-- >  0 ){
			if( invert) 
				game.canon2 = idx;
			else
				game.canon1 = idx;

				for( i in 0...10 ) {
					var m = game.dm.attach( "mcCanonPart", Const.DP_BALL );
					m.gotoAndStop( 3 + shield + 1 );
					m._x = mc.x;
					m._y = mc.y;
					m._rotation = Std.random( 360 );
					var p = new Phys( m );
					p.timer = 20;
					var rad = m._rotation * Math.PI / 180;
					var s = KKApi.val( Const.BALL_SPEED );			
					p.vx = Math.cos( rad ) * s / 100 * if( invert ) -3 else 3;
					p.vy = Math.sin( rad ) * s / 100 * 3;
					Filt.glow( p.root, 4,1, 0xFFFFFF );
				}
						
			return;
		}

		for( i in 0...20 ) {
			var m = game.dm.attach( "mcCanonPart", Const.DP_BALL );
			m.gotoAndStop( Std.random( 3 ) + 1 );
			m._x = mc.x;
			m._y = mc.y;
			m._rotation = Std.random( 360 );
			var p = new Phys( m );
			p.timer = 20;
			var rad = m._rotation * Math.PI / 180;
			var s = KKApi.val( Const.BALL_SPEED );			
			p.vx = Math.cos( rad ) * s / 100 * if( invert ) -3 else 3;
			p.vy = Math.sin( rad ) * s / 100 * if( invert ) -3 else 3;
			p.vr = 2;
			Filt.glow( p.root, 4,1, 0xFFFFFF );
		}
	}

	public function removeMe() {
		if( shield >= 0 ) return;
		game.removeCanon( idx, invert );
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
	}

}
