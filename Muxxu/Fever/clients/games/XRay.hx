
typedef XrayFlower = {>flash.display.MovieClip,
			yspeed : Float,
			xspeed : Float,
			hit1 : flash.display.MovieClip,
			hit2: flash.display.MovieClip,
			hit3 : flash.display.MovieClip,
			hit4 : flash.display.MovieClip,
			hit5 : flash.display.MovieClip,
			vrot : Float
			};
typedef XrayEye = {>flash.display.MovieClip, hit1: flash.display.MovieClip, hit2 : flash.display.MovieClip, hit3 : flash.display.MovieClip }

class XRay extends Game {//}
	
	static var BLINK = 80;
	var blink : Int;
	
	static var TOUCH = 40;
	var touch : Int;
	
	var eye : XrayEye;
	var flowersCount : Int;
	var flowers : Array<XrayFlower>;
	var noHit : Bool;
	var won : Bool;
	var gameOver : Bool;
	
	override function init(dif){
		gameTime = 400;
		super.init(dif);
		blink = 0;
		touch = 0;
		noHit = false;
		won = false;
		flowers = new Array();
		flowersCount = Std.int(50+dif*20);
		//flowersCount = 1;
		attachElements();
	}
	
	function attachElements() {
		bg = dm.attach( "mcXrayBg",0  );
		//WGeom.drawRectangle( bg, 400, 400, 0x86C1E1, 100, 0x000000, 100 );
		eye = cast dm.attach("mcXrayEye", 1 );
		eye.x = 200;
		eye.y = 200;
		resetEye();
		for( i in 0...flowersCount ) addFlower();
	}

	function addFlower() {
		var f : XrayFlower= cast dm.attach("mcXrayFlower", 1 );
		f.gotoAndStop( 1 );
		var rnd = Std.random( 50 );
		//f.scaleX = f.scaleY = 50 + rnd;
		
		var a = Math.random() * 6.28;
		var aa = Math.random() * 6.28;
		var ray = 150 + Std.random(100);
		var v = 0.5 + 1.5 * dif;
		f.x = 200 + Math.cos(a)*ray;
		f.y = 200 + Math.sin(a)*ray;
		f.xspeed = Math.cos(aa) * v;
		f.yspeed = Math.sin(aa) * v;
		f.vrot = v * 2;
		f.rotation = Std.random( 360 );
		/*
		var r = Std.random( 360 );
		f.x = 250 + WGeom.cos( r ) * Cs.mcw / ( if( Std.random( 2) == 0 ) 2 else 3 );
		f.x = if( Std.random( 2) == 0 ) -f.x else f.x;
		f.y = 250 + WGeom.sin( r ) * Cs.mcw / ( if( Std.random( 2) == 0 ) 2 else 3 );
		f.y = if( Std.random( 2) == 0 ) -f.y else f.y;
		var v = 1 + 1 * dif;
		v = if( Std.random( 2) == 0 ) -v else v;
		f.xspeed = v;
		f.yspeed = v;
		f.vrot = v * 2;
		f.rotation = Std.random( 360 );
		*/
		//f.blendMode = "invert";
		flowers.push( f );
	}
		
	override function update() {

		var mp = getMousePos();
		
		if( !gameOver && mp.x >= 0 && mp.x <= Cs.mcw && mp.y >= 0 && mp.y <= Cs.mch ) {
			var dx = mp.x - eye.x;
			var dy = mp.y - eye.y;
			if(eye.hit1 != null ){
				eye.hit1.x += dx;
				eye.hit1.y += dy;
			}
			if(eye.hit2 != null ){
				eye.hit2.x += dx;
				eye.hit2.y += dy;
			}
			if( eye.hit3 != null ){
				eye.hit3.x += dx;
				eye.hit3.y += dy;
			}
			eye.x = mp.x;
			eye.y = mp.y;
		}
		
		switch( step ) {
			case 1 :
				eyeblink();
				moveFlowers();
			case 2:
				moveFlowers();
				var a = [eye.hit1, eye.hit2, eye.hit3];
				var grav = 1.0;
				for( mc in a ) {
					if( mc.tabIndex < 2 ) 	mc.tabIndex = Std.random(200);
					mc.y += grav;
					mc.rotation += (mc.tabIndex-100) * 0.1;
					grav += 1.5;
				}
				
		}
		super.update();
	}
		
	function moveFlowers() {
		

		for( f in flowers ) {
			if( ( noHit || won ) && eye.hit1 == null ) {
				f.alpha = 0.1;
				continue;
			}
			
			if( touch >= 0 ) {
				if( touch-- <= 0) {
						
						getSmc(eye).gotoAndStop( 1 );
						touch = -1;
					}
			}
			
			//*
			f.alpha = 1;
			f.x += f.xspeed + WGeom.cos( f.rotation ) * f.xspeed;
			f.y += f.yspeed + WGeom.sin( f.rotation ) * f.yspeed;
			f.rotation += f.vrot;
			if( f.xspeed < 0 ) {
				if( f.x < -f.width ) f.x = Cs.mcw;
			} else {
				if( f.x > Cs.mcw + f.width ) f.x = 0;
			}
			if( f.yspeed < 0 ) {
				if( f.y < -f.width ) f.y = Cs.mch;
			} else {
				if( f.y > Cs.mch + f.width ) f.y = 0;
			}//*/
		
			if( hit( f, f.hit1 ) ) {
				
				flowers.remove( f );
				hitAnim(f,1);
				continue;
			}
			
			if( hit( f, f.hit2 ) ){
				flowers.remove( f );
				hitAnim(f,2);
				continue;
			}
		}
	}
	
	function hit( f: flash.display.MovieClip, mc1 : flash.display.MovieClip ) {
		if( mc1 == null ) return false;
		
	
		
		var dy = eye.x - f.x + f.width / 2;
		var dx = eye.y - f.y + f.height / 2;
		if( Math.abs( dx ) > 50 ) return false;
		if( Math.abs( dy ) > 50 ) return false;
		
		var ax = WGeom.clockWiseAtan2( mc1.y, mc1.x );
		var fa = WGeom.clockWiseAngle( f.rotation ) + ax;
		fa = WGeom.angle360( fa );
		
		//trace( ax );
		var r = 0.0;
		if( mc1.x == 0 )
			r = mc1.y / WGeom.cos( ax )
		else
			r = mc1.x / WGeom.sin( ax );
			
		//trace( r );
		var x = WGeom.sin( fa ) * ( r );
		var ex = eye.x - f.x;
		var y = -WGeom.cos( fa ) * ( r ) ;
		var ey = eye.y - f.y ;
		
		/*
		trace( "x=" + x + " ex=" + ex );
		trace( "y=" + y + " ey=" + ey );
		//*/
		
		var prec = 10;
		var dy = y - ey;
		var dx = x - ex;
		var d = Math.sqrt(  dy * dy + dx * dx );
		if( d > 0 && d < prec ) {
			return true;
		}
		
		return false;
	}
	
	function getAngle(a : Float) {
		if( a > 0 ) return a;
		return 180 + 180 + a;
	}

	function hitAnim( f : XrayFlower, fr : Int ) {
		//dm.swap( f, 2 );
		new mt.fx.Flash(eye, 0.1, 0xFF0000);
		fxShake(3);
		touch = TOUCH;
		addFlower();
		f.gotoAndStop( 1+fr);

		for( i in 0...20 ) {
			var m = dm.attach("mcXrayBlood", 5);
			m.x = f.x;
			m.y = f.y;
			var p = new Phys( m );
			p.timer = 10;
			p.weight = 0.3 + Std.random( 2 ) / 10;
			p.vx = Math.cos( f.xspeed ) * ( Std.random( 2 ) + 1 ) / 10;
			//p.vy = Math.cos( f.yspeed ) * ( Std.random( 2 ) + 1 ) / 10;
			p.fadeType = 3;
			p.sleep = Math.round(i / 10);
		}
			
		if( eye.hit1 == null ) {
			eye.hit1 = f;
			return;
		}
		if( eye.hit2 == null ) {
			eye.hit2 = f;
			return;
		}
		if( eye.hit3 == null ) {
			eye.hit3 = f;
			gameOver = true;
			setWin(false, 20);
			eye.visible = false;
			var mc = new McEyeSplurch();
			mc.x = eye.x;
			mc.y = eye.y;
			dm.add(mc, 10);
			step = 2;
			return;
		}
	
	}
	
	function eyeblink() {
		if( eye.hit1 !=  null ) return;

		if( blink-- <= 0 ) {
			if( eye.currentFrame==1) {
				eye.gotoAndStop(2);
				blink = Math.floor( BLINK / 6 );
				noHit = true;
				return;
			}
			noHit = false;
			resetEye();
			blink = BLINK + Std.random( BLINK );
		}
	}
	
	function resetEye() {
		eye.gotoAndStop(1);
	}

	override function outOfTime() {
		setWin( true );
		won = true;
	}

//{
}
