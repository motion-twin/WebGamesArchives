
typedef BusStationLight = {>flash.display.MovieClip, wrong : flash.display.MovieClip, glow : flash.display.MovieClip, glowc : Int }
typedef BusStationCeil = {>flash.display.MovieClip, hit1 : BusStationLight, hit2 : BusStationLight, hit3 : BusStationLight, hit4 : BusStationLight, }
typedef BusStationBus = {>flash.display.MovieClip, bx : Float, shk : Float, bshk : Float, validated : Bool, sign : Int, crashed : Bool, ok: flash.text.TextField, wrong: flash.display.MovieClip }

class BusStation extends Game {

	var MAXCOUNT : Int;
	var WARNING : Float;
	var won : Bool;
	var gameOver : Bool;
	var ceil : BusStationCeil;
	var lines : Array<Int>;
	var busCycle : Float;
	var roads : Array<Array<BusStationBus>>;
	var signs : Array<BusStationLight>;
	var speed : Float;
	var tCycle : Float;
	var count : Int;
	var last : Float;

	
	override function init(dif:Float){
		gameTime = 400+Std.random(100);
		super.init(dif);
		lines = [72,153,232,309];
		WARNING = 90;
		MAXCOUNT = 10;
		busCycle = 10;
		roads = new Array();
		roads[0] = new Array();
		roads[1] = new Array();
		roads[2] = new Array();
		roads[3] = new Array();
		signs = new Array();
		speed = 3+dif;
		tCycle = 10.0;
		last = 0.0;
		attachElements();
		count = 0;
		var max = 30 - Std.int( dif * 20);
		for( i in 0...max ) update();
			
	}

	function attachElements() {
		bg = dm.attach( "mcDominosBg", 0  );
		bg.y = 44.3;

		ceil = cast dm.attach( "mcDominosCeil", 2  );
		

		ceil.hit1.gotoAndStop(1);
		ceil.hit2.gotoAndStop(2);
		ceil.hit3.gotoAndStop(3);
		ceil.hit4.gotoAndStop(4);


		
		getSmc(ceil.hit1).gotoAndStop(1);
		getSmc(ceil.hit2).gotoAndStop(1);
		getSmc(ceil.hit3).gotoAndStop(1);
		getSmc(ceil.hit4).gotoAndStop(1);
		
		ceil.hit1.wrong.visible = false;
		ceil.hit2.wrong.visible = false;
		ceil.hit3.wrong.visible = false;
		ceil.hit4.wrong.visible = false;

		ceil.hit1.glow.visible = false;
		ceil.hit2.glow.visible = false;
		ceil.hit3.glow.visible = false;
		ceil.hit4.glow.visible = false;

		signs = [ceil.hit1, ceil.hit2, ceil.hit3, ceil.hit4];
	}

	override function update() {
		controls();

		switch( step ) {
			case 1 :
				addBus();
				moveBus();
			case 2  :
				
				
		}
		super.update();
	}

	function controls() {
		for( s in signs ) {
			if( s.glowc-- <= 0 ) {
				s.glow.visible = false;
			}
		}
	}

	function addBus() {
		if( busCycle-- <= 0 ) {
			var indexes = new Array();
			var minH = 0.0;
			if( count < MAXCOUNT ) {
				busCycle = 80 - dif * (50+Std.random(15));
				var b : BusStationBus = cast dm.attach( "mcDominosBus", 1 );
				b.ok.visible = false;
				b.wrong.visible = false;
				b.gotoAndStop( Std.random( b.totalFrames ) + 1 );
				var idx = Std.random( lines.length );
				var gb = getLastBus(idx);
				if( gb > Cs.mch )
					b.y = gb + b.height * 2;
				else {
					var where = Cs.mch - gb;
					b.y = Cs.mch + if( where < b.height ) where else 0.0;
				}

				if( last > b.y ) {
					b.y = last - ( busCycle - b.height );
				}

				last = b.y;
				var idd = idx;
				var r = Std.random(3);
				b.x = lines[idx] + if( Std.random(2) == 0 ) r else -r;
				b.sign = idx;
				b.bx = b.x;
				b.shk = b.bshk = 1.0;
				roads[idx].push( b );
				minH += b.height / 2;
				count++;
			}
		}
	}

	function moveBus() {
		var i = 0;
		for( r in roads ) {
			for( b in r ) {
				i++;
				b.y -= speed;

				if( tCycle-- <= 0 ) {
					var t = dm.attach("mcBusStationTire", 0);
					t.x = b.bx + 6;
					t.y = b.y + 50;

					var r = Std.random( 5 ) + 30;
					var p = new Phys(t);
					p.timer = r;

					var t = dm.attach("mcBusStationTire", 0);
					t.x = b.bx + 24;
					t.y = b.y + 50;

					var p = new Phys(t);
					p.timer = r;
					tCycle = Std.random( 3 );
				}


				shakebus(b);

				if( b.y > WARNING ) continue;

				if( b.y <= WARNING ) {
					if( gameTime > 0 ) gameTime--;
					var sign = signs[b.sign];
					/*
					if( b.currentFrame != signs[b.sign].currentFrame) {
						getSmc(sign).gotoAndStop( 2 );
					} else {
						getSmc(sign).gotoAndStop( 1 );
					}
					*/
				}

				if( b.y <= ceil.y + ceil.height && !b.validated) {
					count--;
					b.validated = true;
					var sign = signs[b.sign];
					getSmc(sign).gotoAndStop( 1 );
					if( b.currentFrame != sign.currentFrame && !gameOver) {
						b.wrong.visible = true;
						sign.wrong.visible = true;
						gameOver = true;
						setWin(false, 20);
						step = 2;
						
					} else {
						b.ok.visible = true;
					}
				}

				if( b.y + b.height  < 0 ) {
					roads[b.sign].remove( b);
					b.parent.removeChild(b);
				}
			}
		}
	}

	function shakebus(b: BusStationBus){
		b.x += b.shk;
		b.scaleX += b.shk*0.01;
		b.scaleY += b.shk*0.01;
		b.shk *= -Std.random( 3 ) / 10;
		if(Math.abs(b.shk)<0.2){
			b.x = b.bx;
			b.scaleX = 1;
			b.scaleY = 1;
			b.shk = b.bshk;
		}
	}

	override function onClick() {
		if( step != 1 ) return;
		swapColor( ceil.hit1 );
		swapColor( ceil.hit2 );
		swapColor( ceil.hit3 );
		swapColor( ceil.hit4 );
	}

	function getLastBus(idx) {
		var r = roads[idx];
		if( r.length <= 0 ) return 0.0;

		var b = r[r.length-1];
		var y = b.y + b.height;

		return y;
	}

	function swapColor( mc : BusStationLight ) {
		var cur = mc.currentFrame;
		if( cur == mc.totalFrames ) {
			mc.gotoAndStop(1);
			return;
		}
		mc.nextFrame();
		mc.glow.visible = true;
		mc.glowc = 5;
	}

	override function outOfTime() {
		setWin( true );
		won = true;
	}
	
}
