import mt.bumdum9.Lib;
typedef Ref = {>flash.display.MovieClip, refX : Float, refY : Float, speed : Float };

class Window extends Game {

	var window : flash.display.MovieClip;
	var top : flash.display.MovieClip;
	var cycle : Int;
	var baseCycle : Int;
	var count : Int;
	var speed : Int;
	var ms : Array<Ref>;
	var ms2 : Array<Ref>;
	var bmp : flash.display.BitmapData;
	var line : flash.display.MovieClip;

	override function init(dif : Float) {
		gameTime = 350;
		super.init(dif );
		baseCycle = Math.ceil( Math.max( 10, 70 - 25 * dif ) );
		cycle = 10;
		count = 2;
		speed = 2;
		ms = new Array();
		ms2 = new Array();
		attachElements();
	}

	function attachElements() {
		bmp = new flash.display.BitmapData( Cs.mcw,Cs.mch,true,0x00FF00);
		bg = dm.attach("mcParBg", 1 );
		bg.addChild(new flash.display.Bitmap(bmp));
		window = dm.attach("mcParWindow", 3);
		var f= new flash.filters.DropShadowFilter();
		window.filters = [f];
		top = dm.attach("mcParTop",4);
		var toptop = dm.attach("mcParTopTop",6);
		line = dm.attach("mcParLine",5);
		line.filters = [f];
		line.y = 200;
	}

	override function update() {

		switch( step ) {
			case 1 :

				var mx = getMousePos().x;
				var dif = mx - getSmc(line).x;
				getSmc(line).x = mx;

				for( m in ms ){
					m.refX += dif;
					var r = Math.atan2( m.refY -  m.y, m.refX - m.x);
					var yf = Math.sin( r ) * m.speed;
					var xf = Math.cos( r ) * m.speed * 4;

					m.y -= yf;
					m.x -= xf;
					m.x = m.x;
					m.y = m.y;
					m.refY -= yf;

					drawLine( m.x, m.y, xf, yf );

					if( m.speed < 0 && m.y + m.height < 0 ){
						ms.remove(m);
						m.parent.removeChild(m);
						continue;
					}
				}

				for( m in ms2 ){
					m.refX -= dif;
					var r = Math.atan2( m.refY -  m.y, m.refX - m.x);
					var yf = Math.sin( r ) * m.speed;
					var xf = Math.cos( r ) * m.speed * 4;

					m.y += yf;
					m.x += xf;
					m.x = m.x;
					m.y = m.y;
					m.refY += yf;

					drawLine( m.x, m.y, xf, yf, true );

					if( m.speed > 0 && m.y + m.height > Cs.mch ){
						ms.remove(m);
						if(m.parent!=null)m.parent.removeChild(m);
						continue;
					}

					if( m.y >= 380 || m.y <= 20 ) continue;

					for( mm in ms ) {
						if( mm.y >= 380 || mm.y <= 20 ) continue;

						var dx = m.x - mm.x;
						var dy = m.y - mm.y;
						if( Math.sqrt( dx*dx+dy*dy) < mm.width ) {
							fxShake(4);
							new mt.fx.Flash( bg );
							cycle = baseCycle;
							blow( m.x, m.y );
							blow( mm.x, mm.y );
							var p = new Phys(if( Std.random(2)==0 )mm else m);
							p.vsc = 2;
							p.fadeType = 4;
							p.timer = 6;
							setWin(false, 20);
							step = 3;
					
						}
					}
				}

			
				// spawn
				if( cycle-- <= 0 && gameTime>80 ){
					for( i in 0...count ){
						var m : Ref = cast dm.attach("mcParM",4);
						m.gotoAndStop(1);
						m.y = Cs.mch + m.height;
						m.x = m.refX = Std.random( Cs.mcw );
						m.y = m.y;
						m.x = m.x;
						m.refY=200;
						m.speed = -speed;
						var f = new flash.filters.DropShadowFilter(2,45,0x000000,90,2,2,1,2);
						m.filters = [f];
						ms.push(m);


						var m : Ref = cast dm.attach("mcParM",4);
						m.gotoAndStop(2);
						m.y = -m.height;
						m.x = m.refX = Std.random( Cs.mcw );
						m.y = m.y;
						m.x = m.x;
						m.refY=200;
						m.speed = speed;
						m.filters = [f];
						ms2.push(m);

						/*
						var m2 : Ref = cast dm.attach("mcParMI",1);
						m2.y = m.y;
						m2.x = m2.refX = m.x;
						m2.refY = 200;
						m2.speed = m.speed;
						var f = new flash.filters.GlowFilter(0xFFFFFF,100,8,8,1,3);
						m2.filters = [f];
						ms2.push(m2);
						*/
					}
					cycle = baseCycle;
				}


					
		}
		super.update();
	}

	function drawLine(x:Float,y:Float,xf:Float,yf:Float,opp = false) {
		var col = if( opp) 0xF54949 else 0xB1D22D;
		var line = dm.empty(1);
		line.graphics.lineStyle(2,col,50+Std.random(50));
		line.graphics.moveTo(x+xf,y+yf);
		line.graphics.lineTo(x ,y );
		/*
		var f = new flash.filters.GlowFilter(0x000000, 100,2,2,1,2);
		line.filters = [f];
		*/
		bmp.draw( line, new flash.geom.Matrix(1,0,0,1,0,0));
		line.parent.removeChild(line);
	}

	override function outOfTime() {
		setWin(true);
	}

	function blow( x, y, max = 20 ) {
		var r = 2;
		var a = 360 / max;
		for( j in 0...4 ) {
			for( i in 0...max ) {
				var o = dm.empty(3);
				WGeom.drawPoint( o, 0xFFFFFF);
				Col.setColor( o, if( Std.random(2) == 0 ) 0xF54949 else 0xB1D22D  );
				var an = a * i;
				o.x = x + WGeom.cos( an ) * (r * j );
				o.y = y + WGeom.sin( an ) * (r * j );
				o.scaleX = o.scaleY = 1 + Math.random() * 3;
				var p = new Phys( o );
				p.timer = 20;
				p.vx = WGeom.cos( an ) * ( 8 / (j +1) );
				p.vy = WGeom.sin( an ) * ( 8 / (j + 1) );
			}
		}
	}
}
