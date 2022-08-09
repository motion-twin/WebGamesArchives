import Protocole;

class Attractor extends Game {

	var att : flash.display.MovieClip;
	var sender : flash.display.MovieClip;
	var goal : flash.display.MovieClip;
	var leftMargin : Float;
	var frontier : Float;
	var cycle : Int;
	var baseCycle : Int;
	var balls : Array<Phys>;
	var speed : Float;
	var goals : List<flash.display.MovieClip>;
	var bmp : flash.display.BitmapData;
	var cg : Int;

	override function init(dif : Float) {
		baseCycle = 5 + Std.int( 30 * dif );
		cg = 4;
		gameTime = Math.max( 380, baseCycle * cg);
		super.init(dif );
		balls = new Array();
		goals = new List();
		attachElements();
	}

	function attachElements() {
		bmp = new flash.display.BitmapData( Cs.mcw,Cs.mch,true,0x00FF00);
		bg = dm.attach("mcAttractorBg", 1 );
		bg.addChild( new flash.display.Bitmap(bmp));
		//bg.attachBitmap( bmp, 1 );
//
		att = dm.attach("mcAttractor",2);
		frontier = 200;
		att.x = 200;
		att.y = 200;
		att.gotoAndStop(1);
		sender = dm.attach("mcAttractor",2);
		sender.x = 0;
		sender.y = Std.random( Cs.mch );
		sender.gotoAndStop(2);
		leftMargin = sender.width;
		step = 1;
		cycle = 10;
		speed = 4;
		var goal = dm.attach("mcAttractor",2);
		goal.x = 400;
		var margin = ( Cs.mch - cg * goal.height ) / cg;
		goal.gotoAndStop(3);
		goal.y = margin;

		// TODO debugger le placement
		goals.add( goal );
		for( i in 1...cg ) {
			var goal = dm.attach("mcAttractor",2);
			goal.gotoAndStop(3);
			goal.x = 400;
			goal.y = margin * (i+1) + i * goal.height;
			goals.add( goal );
		}
		
	}

	override function update() {
		if( goals.length <= 0 ) {
			setWin( true, 20 );
			step = 2;
		}

		for( s in balls ) {

			if( s.x > Cs.mcw + s.rootwidth ) {
				s.kill();
				balls.remove(s);
				continue;
			}
	
			if( s.x > att.x || s.root.currentFrame == 2 ) {

				/*
				if( s.root.currentFrame == 1 ) {
					if( s.x > att.x ) {
						var p = new Phys(s.root);
						p.timer = 10;
						balls.remove(s);
					}
				}*/

				if( s.root.currentFrame == 2 ) {
					drawLine( s.x, s.y, s.vx, s.vy, true );
					for( g in goals ) {
						var rect = WGeom.getRectangle( g, box );
						if( rect.containsPoint( new flash.geom.Point( s.x, s.y ) ) ) {
//						if( s.x >= g.x && s.y >= g.y && s.y <= g.y + g.height) {
							new mt.fx.Flash( g );
							var p = new Phys(g);
							p.fadeType = 4;
							p.timer = 10;
							goals.remove(g);
						}
					}
				}
				continue;
			}

			// TODO: il faut être proche de la balle pour qu'elle suive < 20px par ex
			var r = Math.atan2( att.y - s.y, att.x - s.x);
			var yf = Math.sin( r ) * speed;
			var xf = Math.cos( r ) * speed;
			
			s.x += xf;
			s.y += yf;

			if( s.x > att.x ) {
				s.root.gotoAndStop(2);
				new mt.fx.Flash( att );
				s.vx = xf * getFullSpeed();
				s.vy = yf * getFullSpeed();
				drawLine( att.x, att.y, s.vx * 3, s.vy * 3 );
			} else {
				drawLine( s.x, s.y, xf, yf );
			}

			s.update();
		}

		switch( step ) {
			case 1 :
				var pos = getMousePos();
				att.y = pos.y;
				sender.rotation += 0.2;
				att.rotation += 1;
				for( g in goals ) {
					g.rotation -= 3;
				}
				//att._alpha = 100 - ( att.x / Cs.mcw * 100 );

				// spawn des balles
				if( cycle-- <= 0 ){
					var ball = dm.attach("mcAttractorBall",1);
					ball.x = sender.x;
					ball.y = sender.y;
					ball.gotoAndStop(1);
					var pb = new Phys( ball );
					balls.push( pb );
					cycle = baseCycle;
					new mt.fx.Flash( sender );
				}
				
			case 2:
				
			
		}
		super.update();
		
		
		var ct = new flash.geom.ColorTransform(1, 1, 1, 1, 0, 0, 0, -1);
		bmp.colorTransform(bmp.rect,ct);
		
	}

	function getFullSpeed() {
		var s = 5;
		return Math.max( s * ( 100 - ( att.x / ( Cs.mcw - ( sender.width * 2 ) ) * 100 ) ) / 100, 0.1 );
	}

	function drawLine(x:Float,y:Float,xf:Float,yf:Float, brute = false) {
		var line = dm.empty(1);
		line.graphics.lineStyle(if( brute )1 else 2,0xFFFFFF,if( brute ) 90 else 40);
		line.graphics.moveTo(x+xf,y+yf);
		line.graphics.lineTo(x ,y );
		var f = new flash.filters.GlowFilter(0xFFFFFF, 100,if( brute ) 8 else 4,8,1,3);
		line.filters = [f];
		bmp.draw( line, new flash.geom.Matrix(1,0,0,1,0,0));
		line.parent.removeChild(line);
	}
	
	override function outOfTime() {
		setWin(false);
	}
}
