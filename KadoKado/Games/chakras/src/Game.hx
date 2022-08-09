import KKApi;
import Common;
import Anim;
import mt.bumdum.Plasma;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.flash.PArray;
import mt.flash.Volatile;

class Game {

	public var dm : mt.DepthManager;
	public var root : flash.MovieClip;
	public var mcBg : flash.MovieClip;
	public var mcLine : flash.MovieClip;
	public var mcEnergy : {>flash.MovieClip,mask:flash.MovieClip};
//	public var mcEnergyBack : flash.MovieClip;
	public var mcRelease : flash.MovieClip;
	public var plasma : Plasma;
	public var cycles : Volatile<Int>;
	public var threshold : Volatile<Int>; // nombre de tours avant animation
	public var animated : Bool; // Si une animation est en cours
	public var missLock : Bool;
	public var missKeyLock : Bool;
	public var animReseted : Volatile<Int>;

	var shakeSpeed : Float;
	var shakeCpt : Float;
	var anim : Array<Anim>;
	var chakras : PArray<Chakra>;
	var step : Step;
	var activatedStep : Step;
	var pause : Volatile<Int>; // nombre de tours avant le prochain test
	var pauseCoeff : Volatile<Int>;
	var pauseBase : Volatile<Int>;
	var activation : Volatile<Int>;
	var missed : Volatile<Int>;
	var chakraLock : Bool;
	var points : Volatile<Int>;
	var started : Bool;
	var countCycles : Volatile<Int>;
	var mouse : Bool;
	var catchKey : Bool;
	var combo : Volatile<Int>;

	/*----------------------------------- INIT -------------------------------------*/
	/*------------------------------------------------------------------------------*/

	public function new( mc : flash.MovieClip ){
		combo = 0;
		catchKey = true;
		shakeSpeed = 0.1;
		shakeCpt = 0;
		mouse = false;
		started = false;
		points = 300;
		chakraLock = false;
		animReseted = 0;
		threshold = Const.ANIMATION_THRESHOLD;
		activation = 0;
		haxe.Firebug.redirectTraces();
		root = mc;

		dm = new mt.DepthManager(root);

		mcBg = dm.attach("mcBg",Const.DP_BG);
		mcBg.gotoAndStop( 1 );

		mcEnergy = cast dm.attach("mcBg",Const.DP_BG);
		mcEnergy.gotoAndStop( 2 );

		step = Play;
		initChakras();
		cycles = Const.BASE_CYCLE;
		pause = Const.MAX_PAUSE;
		pauseBase = Const.MAX_PAUSE;
		anim = new Array();
		missed = 0;
		missLock = false;
		countCycles = KKApi.val( Const.CYCLES ); 
		var me = this;
		flash.Key.onKeyUp = function() { me.missKeyLock = false; };		
		
		mcRelease = dm.empty(Const.DP_TOP);
		mcRelease.beginFill( 1, 0 );
		mcRelease.moveTo( 0,0);
		mcRelease.lineTo( 0,300);
		mcRelease.lineTo( 300,300);
		mcRelease.lineTo( 300,0);
		mcRelease.lineTo(  0, 0);
		mcRelease.endFill( );
		var me = this;
		mcRelease.onPress = function() { me.mouse = true ;};
		//mcRelease.onRelease = function() { me.mouse = false; };

		plasma = new Plasma(dm.empty(Const.DP_CHAKRAS),300,300,0.4);
		var fl = new flash.filters.BlurFilter();
		fl.blurX = 4;
		fl.blurY = 4;
		fl.quality = 3.0;
		plasma.filters.push(fl);
		plasma.ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,-25);
		plasma.root.blendMode = "ligthen";
		
	}

	function initChakras() {
		chakras = new PArray();
		var i = 1;
		chakras.push( new Chakra( this, Const.X, 278, i++) );
		chakras.push( new Chakra( this, Const.X, 250, i++) );
		chakras.push( new Chakra( this, Const.X, 209, i++) );
		chakras.push( new Chakra( this, Const.X, 168, i++) );
		chakras.push( new Chakra( this, Const.X, 128, i++) );
		chakras.push( new Chakra( this, Const.X, 60, i++) );
		chakras.push( new Chakra( this, Const.X, 34, i++) );
	}

	/*----------------------------------- CONTROL -------------------------------------*/
	/*---------------------------------------------------------------------------------*/

	function checkInput() {

		if( step == GameOver ) {
			return;
		}
	
		if( !started ) {
			mouse = false;
			return;
		}

		if( activatedStep != null && catchKey ) {
			getKeyBoardKey();
			catchKey = true;
		} else {
			missKey();
		}
	}

	public function missedChakra(c) {
		if( missLock ) return;
		c.miss();		
		shake();
		var me = this;
		var f = function() { me.missLock = false; };
		loose(f );
		missLock = true;
	}

	function missKey() {
		if( missLock ) return;
		if( missKeyLock ) return;

		if( mouse ) {
			mouse = false;
			shake();
			var me = this;
			var f = function() { me.missKeyLock = false; };
			loose(f);

			missKeyLock = true;
		}
	}

	public function getKeyBoardKey() {
		if( step == GameOver ) return;
		if( chakraLock ) return;

		if( mouse ) {
			mouse = false;
			missKeyLock = true;
			if( activatedStep != null && activatedStep != Play ) {
				chakraLock = true;
				var chakra = chakras[ Type.enumIndex( activatedStep ) ];
				if( chakra.trap ) {
					missedChakra( chakra );
				} else {
					var touch = chakra.touch();
					if( touch > 0 ) {
						if( threshold-- <= 0 && !animated) {
							var anim = Const.MOVES[ Std.random( Const.MOVES.length ) ];
							animReseted = 0;
							animated = true;
							threshold = 0;
							for( c in chakras ) {
								c.animate(anim, Std.random(5));
							}										
						}

						if( chakra.missed ) {
							showPoints( chakra, 0 ); 
						} else {

							var score = KKApi.const ( 0 );
							if( chakra.bonus ) {
								score = KKApi.cmult(Const.SCORE_MUL,KKApi.const( Std.int( touch * 20 ) ));
							}
							else
								score = KKApi.cmult(Const.SCORE_MUL,KKApi.const( Std.int( touch * 10 ) ));

							KKApi.addScore( score );					

							// le score est élevé on affiche le symbole
							if( touch > cycles - cycles / KKApi.val( Const.CYCLE_DIV ) *  KKApi.val( Const.CYCLE_DIV_2 )) {
								energyUp( addPoints( KKApi.val( Const.ENERGY_UP ) ) );

								if( combo++ == KKApi.val(  Const.COMBO_T ) ) {
									showNeon(chakra,true);
									var p = new BonusAnim( this, KKApi.val( Const.COMBO_SCORE ));
									anim.push( p );
									KKApi.addScore( Const.COMBO_SCORE );					
									combo = 0;
								}
								else {
									showPoints( chakra, KKApi.val( score ) ); 
									showNeon(chakra);
								}
								return;
							} else{
								showPoints( chakra, KKApi.val( score ) ); 
								energyUp( addPoints( KKApi.val( Const.ENERGY_SUP ) ) );
								combo = 0;
							}
						}
					}
				}
			}
		}
	}


	/*----------------------------------- ANIM -------------------------------------*/
	/*---------------------------------------------------------------------------------*/

	function getStep(idx) {
		switch( idx ) {
			case 0: return Muladhara;
			case 1: return Swadhisthana;
			case 2: return Manipura;
			case 3: return Anahata;
			case 4: return Visshudha;
			case 5: return Ajna;
			case 6: return Sahasrara;
		}
		return null;
	}

	public function update(){

		if( chakras.cheat ) KKApi.flagCheater();

		if( Sprite.spriteList.length > 0 ){
			var l = Sprite.spriteList.copy();
			for( s in l ) {
				s.update();
			}
		}

		if ( shakeCpt>0 ) {
			root._x = (Std.random(2)*2-1) * shakeCpt;
			root._y = (Std.random(2)*2-1) * shakeCpt;
			shakeCpt-=shakeSpeed;
			if ( shakeCpt<=0 ) {
				shakeCpt = 0;
				root._x = 0;
				root._y = 0;
			}
		}


		for( c in chakras ) {
			c.update();
		}

		if( anim.length > 0 ){
			for( a in anim ){
				if( a.play() ){
					a.onEnd();
					a.clean();
					anim.remove( a );
				}
			}
		}

		plasma.update();

		if( step == GameOver ) {
			KKApi.gameOver({});
			return;
		}

		step = Play;

		checkInput();
		checkEnergy();

		if( pause-- <= 0) {
			if( activatedStep == null ) {
				started = true;

				var ct = Type.getEnumConstructs( Step );
				var idx = Std.random( ct.length );
				var c = chakras[ idx ];			
				activatedStep = getStep(idx);
				c.activate(cycles);
				activation++;
			}
			
			modifyGameplay();

			if( pauseBase <= Const.MIN_PAUSE ) {
				switch( Std.random( 3 ) ) {
					case 0 :
						pause = pauseBase + Std.random( 80 );
					case 1 :
						pause = 2;
					case 2 :
						pause = pauseBase + Std.random( 80 );
				}
			} else {
				pause = pauseBase;
			}
		}
	}

	function modifyGameplay() {
		// réglage du laps de temps entre les affichages du curseur
		if( activation % 2 == 0 && pauseBase > Const.MIN_PAUSE ) {
			pauseBase -= KKApi.val( Const.PAUSE_DEC );
		}

		if( activation % 25 == 0 ) {
			if( KKApi.val( Const.CYCLES ) > 4 ) {
				Const.CYCLES = KKApi.const( KKApi.val( Const.CYCLES ) - KKApi.val( Const.CYCLE_DEC ) );
			}
		}

		/*
		if( activation % 2 == 0 && cycles > Const.MIN_CYCLE ) {
			cycles -= KKApi.val( Const.CYCLE_DEC );
		}*/
	}

	function energyUp(p) {
		var a = new EnergyAnim( mcEnergy.mask, p, false );
		anim.push(a);
	}

	function showPoints( chakra : Chakra , points ) {
		if( chakra.bonus ) {
			var b = new BonusPointsAnim( this, chakra, points );
			anim.push(  b );
			return;
		}

		var p = new PointsAnim( this, chakra, points);
		anim.push( p );
	}

	function loose(f : Void -> Void) {
		var r = removePoints( KKApi.val( Const.MISS_KEY_LOOSE ) );

		if( KKApi.val( Const.POINTS ) <= 0 ) {
			var me = this;
			var a = new EnergyAnim( mcEnergy.mask, r );
			a.onEnd = function() { me.step = GameOver;  f();};
			anim.push(a);
			return;
		}
		else {
			var me = this;
			var a = new EnergyAnim( mcEnergy.mask, r );
			a.onEnd = function() { f(); };
			anim.push(a);
		}
	}

	function shake() {
		shakeCpt = 2;
		for( i in 0...10 ) {
			var mc = dm.attach( "mcRock", Const.DP_TOP );
			mc.gotoAndStop(  Std.random( 2) + 1 );
			mc._yscale = mc._xscale = Std.random( 80 ) + 20;
			mc._x = (i+1)*(Std.random( 30 ) + 10);
			mc._y = -10;
			var s = new Phys( mc );
			s.vy = mc._yscale / 20;
			s.weight = mc._yscale / 80;
			s.vr = mc._yscale / 10;
			s.timer = 50;
		}
	}


	function checkEnergy() {
		if( KKApi.val( Const.POINTS ) <= 0 ) {
			step = GameOver;
			return;
		}

		/*
		if( countCycles % 20 == 0 ) {
			if( mcEnergy.mask._x > 50 )
				mcEnergy.mask._x-- ;
			else if( mcEnergy.mask._x <= -50 ) {
				mcEnergy.mask._x++;
				mcEnergy.mask._x = -49;
			}
			else
				mcEnergy.mask._x++;
		}*/

		if( countCycles-- <= 0 ) {
			countCycles = KKApi.val( Const.CYCLES );
			if( KKApi.val( Const.POINTS ) > 300 ) return;
			var r = removePoints( KKApi.val( Const.ENERGY_DEC ) );
			if( step != GameOver )
				mcEnergy.mask._y += KKApi.val( Const.ENERGY_DEC );
		}
	}

	function showNeon(c : Chakra, all = false ) {	
		if( all ) {
			for( i in 1...8 ) {
				neon( i );
			}
			return;
		}

		neon( c.type );
	}

	function neon( type ) {
		var m = dm.attach("mcNeons",Const.DP_BG );
		switch( type ) {
			case 1 : m._x = 228; m._y = 8; // rouge 
			case 2 : m._x = 48; m._y = 7; // orange
			case 3 : m._x = 232; m._y = 66; // jaune
			case 4 : m._x = 187; m._y = 21; // vert : OK
			case 5 : m._x = 0; m._y = 109; // cyan
			case 6 : m._x = 246; m._y = 108; // bleu
			case 7 : m._x = 15; m._y = 49; // violet
		}
		m.gotoAndStop(8-type);
		var p = new Phys( m );
		p.fadeType = 4;
		p.fadeLimit = 25;
		p.timer = 50;
	}

	// Quand l'animation globale des chakras est présente
	public function resetAnim(anim) {
		if( animReseted++ == chakras.length -1 ) {
			animated = false;
			threshold = Const.ANIMATION_THRESHOLD;
			animReseted = 0;
		}
	}

	public function resetChakra( c : Chakra, endAnim = false ) {
		chakraLock = false;
		c.initGlow();
		activatedStep = null;
		missKeyLock = false;
		missLock = false;
		//catchKey = true;
	}

	function removePoints( p ) {
		var result = KKApi.val(Const.POINTS ) - p;
		if( result <= 0 ) {
//			trace( "no more points!");
			var v = KKApi.val(Const.POINTS ); 
			Const.POINTS = KKApi.const( 0 );
			step == GameOver;
			return v;
		}

//		trace( "remaining: " + result);
		Const.POINTS = KKApi.const( result );
		return p;
	}

	function addPoints( p ) {
//		trace("addPoints");
		if( KKApi.val( Const.POINTS ) >= KKApi.val( Const.MAX_POINTS ) ) {
//			trace("already Full");
			Const.POINTS = Const.MAX_POINTS;
			return 0;
		}

		if( KKApi.val(Const.POINTS ) + p >= KKApi.val( Const.MAX_POINTS ) ) {
//			trace("now Full");
			var v = KKApi.val( Const.POINTS );
			Const.POINTS = Const.MAX_POINTS;
			return KKApi.val( Const.MAX_POINTS ) - v;
		}

//		trace("adding " + KKApi.val( Const.ENERGY_UP ));
		var max = Std.int( Math.max( KKApi.val(Const.POINTS ) + p, KKApi.val(Const.MAX_POINTS ) ) );
		Const.POINTS = KKApi.const( KKApi.val(Const.POINTS ) + p );
		return p;
	}
	
}
