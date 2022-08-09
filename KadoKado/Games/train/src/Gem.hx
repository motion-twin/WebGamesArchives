import Common;
import mt.flash.PArray;

class Gem {
	
	static var lastX = 0.0;
	static var game  : Game;
	static var addObject : mt.flash.Volatile<Float>;
	static var factor = 1.0;

	public static var lock = false;

	public static function init(g) {
		game = g;
		addObject = KKApi.val( Const.ADD_GEM );
	}

	public static function update(scroll : Float) {
		if( lock ) return;
		if( scroll < 0 ) return;
		if( Const.SPEED <= 0 ) return;
		add(scroll);
	}

	public static function newFactor() {
		switch( Std.random( 3 ) ) {
			case 0 : factor = KKApi.val( Const.ADD_GEM_F1 );
			case 1 : factor = KKApi.val( Const.ADD_GEM_F2 );
			case 2 : factor = KKApi.val( Const.ADD_GEM_F3 );
		}
	}

	static function add(scroll : Float) {
		addObject -= scroll;

		if( addObject < 0 ) {
			var g = KKApi.val( Const.ADD_GEM );
			addObject =  ( g + Std.random( Std.int( g / 2 ) ) ) * factor;

			if( Std.random( KKApi.val( Const.PIOUZ_RANDOM ) ) == 1 ) {
				addPiouz();
				return;
			}
			addGem();
		}
	}

	static function addPiouz() {
		var mc : DOb = cast game.dm.attach("mcTresors", Const.DP_PIOUZ );
		mc.gotoAndStop(4);
		mc.piouz = true;
		mc.gem = true;
		lastX = mc._x = Const.CENTER_X;
		Scroller.addGem( mc, Scroller.cycles );
		Scroller.next( mc );
	}

	static function addGem() {
		var mc : DOb = cast game.dm.attach("mcTresors", Const.DP_GEM );
		mc.gotoAndStop( Const.Gems[Std.random(Const.Gems.length)] );
		mc.gem = true;
		lastX = mc._x = Scroller.getX( mc );
		mc.y = mc._y = Const.OBJECTS;
		if( Scroller.hitRoot( mc ) || Station.hitTest(mc) ) {
			mc.removeMovieClip();
			mc= null;
			return;
		}
		Scroller.addGem( mc );
		Scroller.next( mc );
	}

	public static function piouzCrash( mc : DOb ) {
		if( !mc.piouz ) return;

		mc.piouz = false;
		var p = new mt.bumdum.Phys( mc );
		p.timer = 20;
		p.fadeType = 4;
		p.vsc = 0.8;

		for( i in 0...50 ) {
			var m = game.dm.attach("mcPlume", Const.DP_GEM );
			m._x = mc._x;
			m._y = mc._y;
			m._rotation = Std.random(360);
			var p = new mt.bumdum.Phys( m );
			p.timer = 20;
			p.fadeType = 4;
			var s = Const.SPEED;
			p.vx = if( Std.random(2) == 1 ) -(Std.random( Math.ceil( Const.SPEED ) ) + 2) else Std.random( Math.ceil( Const.SPEED ) ) + 2;
			p.vy = if( Std.random(2) == 1 ) -(Std.random( Math.ceil( Const.SPEED ) ) + 2) else Std.random( Math.ceil( Const.SPEED ) ) + 2;
		}
		
	}

	public static function bonus(mc : DOb ) {
		if( !mc.gem ) return;

		mc.gem = false;
		var b = game.dm.attach( "mcBonus", Const.DP_INTER );
		var price = switch( mc._currentframe ) {
			case 1 : Const.GEM1;
			case 2 : Const.GEM2;
			case 3 : Const.GEM3;
			case 4 : Const.PIOUZ;
		}
		cast( b.smc).text =	KKApi.val( price );
		b._x = mc._x;
		b._y = mc._y;
		KKApi.addScore( price );
		var p = new mt.bumdum.Phys( b );
		p.timer = 15;
		p.fadeType = 4;
		p.vsc = 1.1;

		var p = new mt.bumdum.Phys( mc );
		p.timer = 10;
		p.fadeType = 4;
	}
}
