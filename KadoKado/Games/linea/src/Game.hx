/*
	TODO
	accentuer l'effet des bonus x2 et x4 : une anim à chaque activation
	finir de coder les pb de lignes
*/

import Common;
import KKApi;
import Common;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;
import mt.flash.PArray;
import mt.flash.Volatile;
import mt.white.Geom;
import flash.geom.ColorTransform;
import flash.Key;

using flash.Key;

typedef Hit = {>flash.MovieClip, hit : Bool }
typedef BonusScore = {>flash.MovieClip, score : flash.TextField, mult : flash.TextField }
typedef EMC = {>flash.MovieClip, x:Float, y : Float, color : Int, stopped : Bool, started : Bool, linked : Bool, a : Float, prevX : Int, prevY : Int }
typedef OBJECT = {>EMC, line : Bool, bonus: Bool, vscroll : Float, added : Bool, camper : Bool, lineDone : Bool }
typedef AOBJECT = {>OBJECT, bx : Float, by : Float }
typedef BONUS = {>AOBJECT, b1: Hit, b2: Hit, b3: Hit, b4: Hit, hit : Bool}
typedef BMP = {>EMC, bmp : flash.display.BitmapData }
typedef UI = {>flash.MovieClip, b2 : flash.TextField, b3: flash.MovieClip, b4: flash.TextField, b: flash.TextField, x: flash.TextField, dfactor : flash.TextField   }

class Game {

	public var dm : mt.DepthManager;
	public var root : flash.MovieClip;
	var mcStart : flash.MovieClip;
	var bonus2 : flash.MovieClip;
	var bonus3 : flash.MovieClip;
	var bonus4 : flash.MovieClip;
	var mcBack : flash.MovieClip;
	var ui : UI;
	var stopScroll : Bool;

	var objects : PArray<OBJECT>;
	var uidots : PArray<EMC>;
	var abonus : PArray<BONUS>;

	var scroller : Scroller;
	var dotter : Dotter;

	var gameOver : Bool;
	var signalSent : Bool;
	var step : Int;
	var lastX : Float;
	var ocycle : Int;
	var bcycle : Int;
	var start : Bool;
	var startCycle : Int;
	var mainCycle  : Int;
	var colorTheme : Int;
	var lastWasBonus : Bool;
	var keyPressed : Int;
	var camping : Int;
	var camper : Volatile<Int>;
	var f : Volatile<Float>;
	var scroll : Volatile<Int>;
	var bonus : Volatile<Float>;
	var tmod : Volatile<Float>;
	var keymod : Volatile<Float>;
	var PLines	: Volatile<Int>;
	var PBonus	: Volatile<Int>;
	var Phit	: Volatile<Int>;

	/* ---------------------------------------- INIT --------------------------------------- */


	public function new( mc : flash.MovieClip ){
		haxe.Firebug.redirectTraces();
		root = mc;
		dm = new mt.DepthManager(root);

		scroller = new Scroller( root, 300, 300 );

		camping = 0;
		f = 0.0;
		camper = 2;
		keyPressed = KKApi.val( Const.KEYPRESSED );
		keymod = 0;
		tmod = 0.0;
		lastWasBonus = true;
		colorTheme = Std.random( Const.DOTCOLORS.length );
		ocycle = Const.BONUS_GLOW;
		bcycle = Const.BONUS_GLOW;
		lastX = 0.0;
		gameOver = false;
		step = 1;
		bonus = 0.0;
		objects = new PArray();
		uidots = new PArray();
		Const.DOT_X_SPEED = Math.round( KKApi.val( Const.BASE_DOT_RIGHT_SPEED ) / 5 );
		start = false;
		mainCycle = KKApi.val( Const.MAINCYCLE );
		abonus = new PArray();
		scroll = Math.round( KKApi.val( Const.BASESPEED ) / 10 );

		PLines = PBonus = Phit = 0;
		attachElements();
	}

	function attachElements() {
		scroller.addLayer( "mcBack" );

		mcStart = dm.attach( "mcStart", Const.DP_UI );
		mcStart._y = 65;
		mcStart._visible = true;

		var b = dm.attach( "mcBorder", Const.DP_UI );
		var b2 = dm.attach( "mcBorder", Const.DP_UI );
		b2._y = 280;

		var lineCol = Const.DOTCOLORS[colorTheme][Std.random( Const.DOTCOLORS[colorTheme].length) ];
		addUILine( Const.DP_UI, 0, 20, 300, 0, lineCol );
		addUILine( Const.DP_UI, 0, 280, 300, 0, lineCol );
		addUILine( Const.DP_UNDER, 100, 20, 0, 260, Col.brighten( lineCol, 90 ), 20 );
		addUILine( Const.DP_UNDER, 175, 20, 0, 260, Col.brighten( lineCol, 90 ), 20 );
		addUILine( Const.DP_UNDER, 250, 20, 0, 260, Col.brighten( lineCol, 90 ), 20  );

		var col = Const.DOTCOLORS[colorTheme][0];
		bonus2 = dm.empty( Const.DP_UI );
		bonus3 = dm.empty( Const.DP_UI );
		bonus4 = dm.empty( Const.DP_UI );
		addBonusGlow( bonus2, 100, 280, Col.brighten( col, 50 ), 75 );
		addBonusGlow( bonus3, 175, 280, Col.brighten( col, 70 ), 75 );
		addBonusGlow( bonus4, 250, 280, Col.brighten( col, 90 ), 50 );

		ui = cast dm.attach( "mcUI", Const.DP_UI );
		var dp = new flash.filters.DropShadowFilter( 2, 45, lineCol, 100, 4, 4 );
		ui.b.filters = [dp] ;
		var dp1 = new flash.filters.DropShadowFilter( 2, 45, Col.darken( col, 90 ), 100, 4, 4 );
		ui.b2.filters = [dp,dp1] ;
		ui.b3.filters = [dp,dp1] ;
		ui.b4.filters = [dp,dp1] ;
		ui.x.filters = [dp,dp1];
		ui.dfactor.filters = [dp,dp1];
		ui.dfactor.setNewTextFormat( ui.dfactor.getTextFormat( 0, 1 ) );
		ui.dfactor.text = "1";
		ui.cacheAsBitmap = true;

		dotter = new Dotter( dm.empty( Const.DP_BMP ), Math.ceil( Const.WIDTH / 2 ), Const.HEIGHT, Const.XMARGIN, Const.MARGIN );

		var col = Const.DOTCOLORS[colorTheme].pop();
		dotter.addDot( col );
		addDotToUI( col );
	}

	function addUILine( depth : Int, x : Int, y : Int, x1 : Int, y1 : Int, col : Int, alpha = 100, f = null) {
		var l = dm.empty( depth );
		l._x = x;
		l._y = y;
		if( f != null ) l.filters = [f];
		mt.white.Geom.drawLine( l, x1, y1, col, false, 0.25, alpha );
		return l;
	}

	function addBonusGlow( bonus : flash.MovieClip, x : Int, y : Int, col : Int, width : Int) {
		mt.white.Geom.drawRectangle( bonus, width, 20, col,100,col, 100 );
		bonus._x = x;
		bonus._y = y;
		bonus._alpha = 80;
		bonus._visible = false;
	}


	/* ---------------------------------------- UPDATE --------------------------------------- */


	public function update(){
		if( objects.cheat ) KKApi.flagCheater();

		tmod = mt.Timer.tmod;
		keymod += tmod;

		scroller.update(1,Const.DOT_X_SPEED, Const.DOT_Y_SPEED );
		updateAll();
		keymod -= 0.8;
		while( keymod > 1  ) {
			keymod -= 0.8;
			updateAll();
		}
	}

	function updateAll() {
		onKeyDown();

		if( shk!=null )			updateFxShake();
		if( flasher.length>0 )	updateFxFlash();

		if( Sprite.spriteList.length > 0 ){
			var l = Sprite.spriteList.copy();
			for( s in l ) {
				s.update();
			}
		}

		if( !stopScroll ) {
			scrollDots();
		}

		switch( step ) {
			case 1 :
				var dot = dotter.getFirst();

				if( dot.x < Const.START ) {
					if( startCycle-- <= 0 ){
						dot.started = true;
						dot.ready = true;
						mcStart._visible = !mcStart._visible;
						startCycle = 10;
					}
				} else {
					var p = new Phys(  mcStart );
					p.timer = 15;
					p.fadeType = 4;
					start = true;
					Const.DOT_X_SPEED = 0;
					step = 2;
				}
			case 2:
				scrollObjects();
				scrollBonus();

				var dotMod = Math.max(  dotter.getReady().length, 1 );
				KKApi.addScore( KKApi.const( Math.ceil( KKApi.val( Const.SPEED ) / 100 * bonus * dotMod ) ) );
				var xfactor = bonus + dotMod - 1;
				if( xfactor <= 0 )
					ui.dfactor.text = "-";
				else if( xfactor < 1 )
					ui.dfactor.text = "1"
				else
					ui.dfactor.text = Std.string( xfactor ).substr(0,3);

			case 3 :
				stopScroll = true;
				gameOver = true;
		}

		if( mainCycle-- <= 0 ) {
			if( KKApi.val( Const.MINADD ) < Const.WIDTH - 45 )
				Const.MINADD = KKApi.const(KKApi.val( Const.MINADD ) + 3 );

			Const.VSCROLL = KKApi.const( KKApi.val( Const.VSCROLL ) + 1 );
			Const.BASESPEED = KKApi.const( Math.round( KKApi.val( Const.BASESPEED ) + 2 ) );
			scroll = Math.round( KKApi.val( Const.BASESPEED ) / 10 );
			mainCycle = KKApi.val( Const.MAINCYCLE );
		}

		if( gameOver && !signalSent) {
			//clean();
			KKApi.gameOver({Phit: Phit, PBonus : PBonus, PLines : PLines, PCamper : camper });
			signalSent = true;
		}

		if( keyPressed-- <= 0 ) {
			keyPressed = -1;
		}
	}

	function scrollDots() {

		dotter.updateSpeed( Const.DOT_X_SPEED, Const.DOT_Y_SPEED );

		var me = this;
		var cbk = function( d ) {
			me.score( d.x, d.y, "mcLineScore", me.dotter.getLength() -1 );
			me.addDotToUI( d.color );
		}

		dotter.update( Math.ceil( KKApi.val( Const.BASE_DOT_RIGHT_SPEED ) / 5 ), Math.ceil( KKApi.val( Const.BASE_DOT_DOWN_SPEED ) / 5 ), scroll, cbk );

		var first = dotter.getFirst();

		var tx = first.x + scroll;
		// On check si la première ligne est dans une zone de bonus
		if( tx >= KKApi.val( Const.BONUSX4_THRESHOLD ) ) {
			bonus = KKApi.val( Const.BONUSX4 );
			bonus2._visible = true;
			bonus3._visible = true;
			bonus4._visible = true;
		}
		else if( tx >= KKApi.val( Const.BONUSX3_THRESHOLD ) ) {
			bonus = KKApi.val( Const.BONUSX3 );
			bonus2._visible = true;
			bonus3._visible = true;
			bonus4._visible = false;
		}
		else if( tx >= KKApi.val( Const.BONUSX2_THRESHOLD ) ) {
			bonus = KKApi.val( Const.BONUSX2 );
			bonus2._visible = true;
			bonus3._visible = false;
			bonus4._visible = false;
		} else {
			bonus = 1;
			bonus2._visible = false;
			bonus3._visible = false;
			bonus4._visible = false;
		}
	}

	function scrollBonus() {
		for( i in 0...abonus.length ) {
			var b = abonus[i];

			b.x -= scroll;
			b._x = b.x;

			var dy = KKApi.val( Const.VSCROLL ) / 10;
			b.y += dy - ( if( dotter.cannotGoY ) 0 else Const.DOT_Y_SPEED );
			b._y = b.y;

			if( b.x + b._width < -5 ) {
				lastWasBonus = false;
				abonus.remove( b);
				b.removeMovieClip();
			}

			if( b.hit ) continue;

			if( bcycle-- <= 0 ) {
				b.gotoAndStop(  if( b._currentframe == 1 ) 2 else 1 );
				bcycle = Const.BONUS_GLOW;
			}

			var mult = 0;
			var x = 0;
			var y = 0;


			var linked = dotter.getStarted();
			var first = linked.first();
			if( first.x > b.x + b._width ) {
				var ph = new Phys(b);
				ph.timer = 10;
				ph.fadeType = 5;
				ph.vx = -scroll;
				abonus.remove( b );
				continue;
			}

			for( d in linked ) {
				var dx = b.x - d.x;
				var dy = b.y - d.y;
				var dist = Math.sqrt(  dy * dy + dx * dx );
				if( b.x - d.x > 3 ) continue;

				var sleep = 0;

				if( hit2( b, b.b1, d.x, d.y )  && !b.b1.hit ) {
					removeBonus( b.b1, b );
					mult++;
				}
				if( hit2( b, b.b2, d.x, d.y ) && !b.b2.hit  ) {
					removeBonus( b.b2, b, 1 );
					mult++;
				}
				if( hit2( b, b.b3, d.x, d.y ) && !b.b3.hit  ) {
					removeBonus( b.b3, b, 2 );
					mult++;
				}
				if( hit2( b, b.b4, d.x, d.y )  && !b.b4.hit  ) {
					removeBonus( b.b4, b, 3 );
					mult++;
				}

				x = d.x;
				y = d.y;
			}

			if( mult <= 0 ) continue;

			b.hit = true;

			if( mult >= 4 ) {
				score( x, y - 50, "mcBonusCombo", KKApi.val( Const.BONUS_COMBO ) );
				var s = KKApi.val( Const.BONUS_COMBO );
				PBonus += s;
				KKApi.addScore( KKApi.const( s ));
				continue;
			}

			score( x, y - 50, "mcBonusScore", KKApi.val( Const.BASE_SCORE ), mult, 20 );
			var s = KKApi.val( Const.BASE_SCORE ) * mult;
			PBonus += s;
			KKApi.addScore( KKApi.const( s ));

		}

	}

	function removeBonus( mc : Hit, b, sleep = 0 ) {
		mc.hit = true;
		var parts : flash.MovieClip = dm.attach( "mcBonusParts", Const.DP_BONUS );
		var n = parts._totalframes;
		var a = 360 / n;
		parts.removeMovieClip();

		for( i in 1...n ) {
			var part = dm.attach( "mcBonusParts", Const.DP_BONUS );
			Col.setColor( part, b.color );
			part.gotoAndStop(i+1);
			part._x = mc._x + b._x;
			part._y = mc._y + b._y;
			var f = new flash.filters.GlowFilter();
			f.color = b.color;
			part.filters = [f];
			var p = new Phys( part );
			p.timer = 13;
//			p.fadeType = 2;
			var an = (i + 1) * a;
			p.x = part._x + mt.white.Geom.cos( an ) * 1;
			p.y = part._y + mt.white.Geom.sin( an ) * 1;
			p.vx = mt.white.Geom.cos( an ) * 5;
			p.vy = mt.white.Geom.sin( an ) * 5;
			p.weight = 1.02;
			p.sleep = sleep;
		}
		var p = new Phys( mc );
		p.timer = 5;
	}

	function score( x: Float, y : Float, name : String, score : Int, mult : Int = 0, sleep = 0 ) {
		var b : BonusScore = cast dm.attach( name, Const.DP_UI );
		b.score.text = Std.string( score );
		b.mult.text = Std.string( mult );
		b._x = x;
		b._y = y;
		var col = Const.OBJECTS_COLOR[colorTheme][Std.random( Const.OBJECTS_COLOR[colorTheme].length )];
		var f = new flash.filters.GlowFilter( Col.brighten( col, 90 ), 80, 2, 2, 5 );
		b.filters = [f];
		var p = new Phys(  b );
		p.timer = 15;
		p.fadeType = 4;
		p.vy = -1.2;
		p.sleep = sleep;
	}

	function scrollObjects() {

		if( objects.length <= 0 ) {
			addObject();
			return;
		}

		for( i in 0...objects.length ) {
			var p = objects[i];

			if( p == null ) {
				objects.remove( p );
				continue;
			}

			if( p.line ) {

				if( Const.DOTCOLORS[colorTheme].length <= 0 ) {
					objects.remove( p );
					p.removeMovieClip();
					continue;
				}

				// Animation
				if( ocycle-- <= 0 ) {
					p.gotoAndStop(  if( p._currentframe == 1 ) 2 else 1 );
					ocycle = Const.BONUS_GLOW;
				}

			}

			var linked = dotter.getStarted();
			var first = linked.first();
			if( first.x > p.x + p._width ) {
				if( camper > Const.CAMPER )  p.gotoAndStop( 4 );

				var ph = new Phys(p);
				ph.timer = 15;
				ph.fadeType = 5;
				ph.fadeLimit = 5;
				ph.vx = -scroll;
				objects.remove( p );
				continue;
			}

			if( (p.x - first.x ) <= 1 && first.x <= p.x + p._width ) {
				for( d in linked ) {

					if( camper > Const.CAMPER ) {
						var centerX = p.x + p._width / 2;
						var centerY = p.y+ p._height / 2;
						var dx = centerX - d.x;
						var dy = centerY - d.y;
						if( Math.sqrt( dx * dx + dy * dy ) < p._width * 3 ) {
							p.gotoAndStop( 3 );
						}
					}

					if( !d.started ) continue;
					if( !hit(p, d.x, d.y ) ) continue;

					if( p.line ) {
						if( Const.DOTCOLORS[colorTheme].length > 0 && !p.lineDone ) {
							p.lineDone = true;
							dotter.addDot( Const.DOTCOLORS[colorTheme].pop() );
							PLines++;
							objects.remove( p);
							var ph = new Phys( p );
							ph.timer = 10;
							ph.fadeLimit = 20;
							ph.fadeType = 3;
							continue;
						}

						var ph = new Phys( p );
						ph.timer = 10;
						ph.fadeType = 3;
						continue;
					}

					Const.DOTCOLORS[colorTheme].push( d.color );
					fxShake( 3 );
					if( !d.ready ) lastWasBonus = false;
					dotter.remove( d.uid );
					removeUIDot( d.color );
					fxFlash( p, 100, 0.8, d.color );
					if( dotter.getLength() <= 0 ) {
						step = 3;
					}
					Phit++;
					d.stopped = true;
					blowLine( d.x, d.y, d.color );
				}
			}

			if( p.x <= KKApi.val( Const.MINADD ) && !p.added ) {
				p.added = true;
				addObject();
				f = 0;
			}

			if( p.x + p._width < -5 ) {
				if( p.line ) lastWasBonus = false;
				objects.remove( p );
				p.removeMovieClip();
			}

			p.x -= scroll;
			p._x = p.x;
			f += scroll;

			if( p.vscroll > 0 ) {
				var th = p.y + p._height;
				if( th >= Const.HEIGHT - Const.MARGIN ) {
					p.vscroll = -p.vscroll;
				}
			}

			if( p.vscroll < 0 ) {
				if( p.y <= Const.MARGIN ) p.vscroll = -p.vscroll;
			}

			var dy = p.vscroll * KKApi.val( Const.VSCROLL ) / 10;
			p.y += dy - ( if( dotter.cannotGoY ) 0 else Const.DOT_Y_SPEED );
			p._y = p.y;

		}
	}

	function hit2( root : flash.MovieClip, mc : flash.MovieClip, x, y ) {
		var dx = root._x + mc._x - x;
		var dy = root._y + mc._y - y;
		return Math.sqrt( dx*dx + dy*dy ) < 8;
	}

	function hit( mc : OBJECT, x, y ) {
		if( mc.line ) {
			var dx = x - mc.x;
			var dy = y - mc.y;
			return Math.sqrt( dx*dx + dy*dy ) < 15;
		}

		if( x < mc._x )  return false;
		if( x > mc._x +mc._width )  return false;
		return y >= mc._y && y <= mc._y + mc._height;
	}

	function addDotToUI( color : Int ) {
		var w = 20;
		var s : EMC = cast dm.empty( Const.DP_UI );
		mt.white.Geom.drawRectangle( s, w, 5, Col.darken( color, 50 ), 100, color, 100, 1 );
		s._y = 7.5;
		s._x = 10 + uidots.length * w + 5;
		s.color = color;
		uidots.push( s );
	}

	function removeUIDot( color ) {
		for( u in uidots ) {
			if( color == u.color ) {
				uidots.remove( u );
				var p = new Phys( u );
				p.timer = 20;
				p.fadeType = 4;
			}
		}
		for( i in 0...uidots.length ) {
			var u = uidots[i];
			u._x = 10 + i * 20 + 5;
		}
	}

	// Explosion de la ligne en cas de collision
	function blowLine( x, y, color ) {
		var r = 2;
		var max = 10;
		var a = 360 / max;
		for( j in 0...4 ) {
			for( i in 0...max ) {
				var o = dm.attach( "mcPart", Const.DP_DOT );
				Col.setColor( o.smc, color );
				var an = a * i;
				o._x = x + mt.white.Geom.cos( an ) * (r * j );
				o._y = y + mt.white.Geom.sin( an ) * (r * j );
				o._rotation = an;
				var p = new Phys( o );
				p.timer = 20;
				p.vx = mt.white.Geom.cos( an ) * ( 8 / (j +1) ) - (if( step < 3 ) scroll else 0 );
				p.vy = mt.white.Geom.sin( an ) * ( 8 / (j + 1) );
			}
		}
	}

	// FX
	var shk:Float;
	var shkFrict:Float;

	function fxShake(sh,shf=0.5){
		shk = sh;
		shkFrict = shf;
		updateFxShake();
	}
	function updateFxShake(){
		root._y = shk;
		shk *= -shkFrict;
		if(Math.abs(shk)<0.2){
			root._y = 0;
			shk = null;
		}
	}

	var flasher:List<flash.MovieClip>;
	function fxFlash(mc:flash.MovieClip,flh=100,coef=0.75,col=0xFFFFFF ){
		if(flasher==null)flasher = new List();
		untyped{
			mc._flhPrc = flh;
			mc._flhCoef = coef;
			mc._flhCol = col;
			Col.setPercentColor(mc,flh,col);
		}
		for( mc2 in flasher )if(mc==mc2)return;
		flasher.push(mc);
	}

	function updateFxFlash(){
		for( mc in flasher ){
			untyped{
				var prc = mc._flhPrc;
				mc._flhPrc *= mc._flhCoef;
				if( mc._flhPrc < 1 ){
					prc = 0;
					flasher.remove(mc);
				}
				Col.setPercentColor(mc,prc,mc._flhCol);
			}
		}
	}


	/* ---------------------------------------- OBJECTS --------------------------------------- */

	function addObject(dx : Float = 0) {
		if( objects.length <= 0 ) { lastX = Const.HEIGHT; }

		// A modifier ! Actuellement c'est trop simple : il faut que le block oblige un vrai mouvement
		if( camping > 30 ) {
			camping = 0;
			camper++;
			var y = dotter.getFirst().y;
			//var y = dots[0].y;
			var o : OBJECT = cast dm.attach( "mcSquare", Const.DP_OBJECTS );
			o.gotoAndStop( if( camper > Const.CAMPER ) 2 else 1 );
			o._x = o.x = lastX;

			if( y >= Const.HEIGHT - Const.MARGIN - o._height ) {
				y = Math.ceil( Const.HEIGHT - Const.MARGIN - o._height / 2 );
			}else if( y > Const.MARGIN + o._height ) {
				y = Math.floor( y - o._height / 2 );
			} else if( y < Const.MARGIN + o._height ) {
				y = Math.floor( Const.MARGIN - o._height / 3 );
			}

			o.y = o._y = y;
			o.vscroll = 0;
			o.camper = true;
			var c = Col.brighten( Const.OBJECTS_COLOR[colorTheme][Std.random( Const.DOTCOLORS[colorTheme].length )], 80 );
			Col.setColor( o, c );
			objects.push( o );
			var n = o.x + o._width * 1.1;
			lastX = n;
			return;
		}

		if( Std.random( 50 ) == 0 && !lastWasBonus ) {
//		if( Std.random( 2 ) == 0 && !lastWasBonus ) {
			var o : BONUS = cast dm.attach( "mcBonus", Const.DP_BONUS );
			o.vscroll = 0;
			o.bx = o._x = o.x = Const.HEIGHT + scroll;
			o.by = o._y = o.y = Const.MARGIN + Std.random( Math.ceil( Const.HEIGHT - Const.MARGIN * 2 - o._height ) );
			var c = Const.OBJECTS_COLOR[colorTheme][Std.random( Const.DOTCOLORS[colorTheme].length )];
			o.color= c;
			Col.setColor( o, c );
			o.bonus = true;
			abonus.push( o );
			lastX = o.x + 5;
			lastWasBonus = true;
			return;
		}

		if( Std.random( 100 ) <= KKApi.val( Const.LINE_BONUS ) && Const.DOTCOLORS[colorTheme].length > 0  && !lastWasBonus ) {
//		if( Const.DOTCOLORS[colorTheme].length > 0  && !lastWasBonus ) {
			var o : OBJECT = cast dm.attach( "mcAddLine", Const.DP_BONUS );
			o.gotoAndStop( 1);
			o.vscroll = if( Std.random( 2 ) == 0 ) -1 else 1;
			o.line = true;
			o._x = o.x = Const.HEIGHT + scroll;
			o._y = o.y = Const.MARGIN + Std.random(  Math.floor( Const.HEIGHT - Const.MARGIN * 2 - o._height ) );
			objects.push( o );
			lastX = o.x + o._width * 1.5;
			lastWasBonus = true;
			return;
		}

		var o : OBJECT = cast dm.attach( "mcSquare", Const.DP_OBJECTS );
		o._x = o.x = Const.HEIGHT + scroll * objects.length;
		o.gotoAndStop( if( camper > Const.CAMPER ) 2 else 1 );
		o.y = o._y = getY(o);
		o.vscroll = if( Std.random( 2 ) == 0 ) -1 - camper % 2 else 1 + camper % 2;
		var c = Col.brighten( Const.OBJECTS_COLOR[colorTheme][Std.random( Const.DOTCOLORS[colorTheme].length )], 80 );
		Col.setColor( o, c );
		objects.push( o );
		var n = o.x + o._width * 1.1;
		lastX = n;
		lastWasBonus = false;
	}

	function getY( o : flash.MovieClip ) {
		var y = Std.random(  Const.HEIGHT );

		if( y <= Const.MARGIN ) return Const.MARGIN - 1;
		if( y >= (Const.HEIGHT - Const.MARGIN - o._height )) {
			y = Const.HEIGHT - Const.MARGIN - Math.floor( o._height ) + 2;
			return y ;
		}
		return y;
	}

	/* ---------------------------------------- CONTROLS --------------------------------------- */


	public function onKeyDown() {
		if( !start ) return;

		Const.DOT_Y_SPEED = 0;
		Const.DOT_X_SPEED = 0;
		Const.SPEED = Const.BASESPEED;
		camping++;

		if( Key.UP.isDown() ) {
			Const.DOT_Y_SPEED = getSpeed( KKApi.val( Const.BASE_DOT_UP_SPEED ));
			Const.SPEED = Const.MINSPEED;
			if( Const.DOT_X_SPEED != 0 ) camping = 0;
		}
		if( Key.DOWN.isDown() ) {
			Const.DOT_Y_SPEED = getSpeed( KKApi.val( Const.BASE_DOT_DOWN_SPEED ) );
			Const.SPEED = Const.MINSPEED;
			if( Const.DOT_X_SPEED != 0 ) camping = 0;
		}
		if( Key.LEFT.isDown() ) {
			Const.DOT_X_SPEED = getSpeed( KKApi.val( Const.BASE_DOT_LEFT_SPEED ) );
			if( Const.DOT_Y_SPEED != 0 ) camping = 0;
		}
		if( Key.RIGHT.isDown() ) {
			Const.DOT_X_SPEED = getSpeed( KKApi.val( Const.BASE_DOT_RIGHT_SPEED ) );
			if( Const.DOT_Y_SPEED != 0 ) camping = 0;
		}

		/*
		if( Key.SPACE.isDown() ) {
			stopScroll = !stopScroll;
		}*/

		/*
		if( Key.CONTROL.isDown() && keyPressed < 0) {
			merge = !merge;
			keyPressed = KKApi.val( Const.KEYPRESSED );
		}*/

	}

	function getSpeed( speed : Int ) {
		return Math.round( speed / 10 );
	}

}
