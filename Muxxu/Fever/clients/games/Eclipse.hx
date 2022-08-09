

typedef M = {>flash.display.MovieClip, mouth: flash.display.MovieClip, left : flash.display.MovieClip, right : flash.display.MovieClip, glow : flash.display.MovieClip, px: Float, py : Float }

class Eclipse extends Game{//}

	var bg2 : flash.display.MovieClip;
	var sun : M;
	var moon : M;
	var cloud : flash.display.MovieClip;
	var cloud2 : flash.display.MovieClip;
	var speed : Float;
	var minX : Float;
	var maxX : Float;
	var rad : Float;
	var won : Bool;
	var path : Path;

	static var LIMIT_MIN = 190;
	static var LIMIT_MAX = 210;
	static var TRIGGER = 400;
	static var IN_SUN = 300;
	static var OUT_SUN = 200;

	override function init(dif:Float){
		gameTime = 250;
		super.init(dif);
		speed = 2 + dif * 18;
		minX = 50;
		maxX = 105;
		step = 1;
		rad = 1;
		path = new Path();
		path.addCheck( -200, 250);
		path.addCheck( 0, 240);
		path.addCheck( 200, 200 );
		path.addCheck( 400, 240 );
		path.addCheck( 600, 250 );
		attachElements();
	}

	function attachElements(){
		bg2 = dm.attach("mcEclipseBg2", 0 );
		bg = dm.attach("mcEclipseBg",1);
		cloud = dm.attach("mcEclipseClouds", 1 );
		cloud.x = 200;
		cloud.y = Std.random( 200 ) + 100;
		cloud.alpha = 0.2;
		cloud2 = dm.attach("mcEclipseClouds", 1 );
		cloud2.x = 200;
		cloud2.y = cloud.y - 50;
		cloud2.alpha = 0.3;
		sun = cast dm.attach("mcEclipseSun",2);
		sun.x = 200;
		sun.y = 200;
		sun.mouth.gotoAndStop(1);
		moon = cast dm.attach("mcEclipseMoon",3);
		moon.px = moon.x = 600;
		moon.py = moon.y = 200;
		moon.mouth.gotoAndStop(1);
	}

	override function update(){

		for( s in Sprite.LIST ) s.update();

		switch(step){
			case 1:
				moon.x -= speed;
				moon.x = moon.x;
				moon.py = path.getPositionFromX( moon.x, moon.y, -speed ).y;
				if( moon.py > 0 )moon.y = moon.py;
				cloud.x += 0.3;
				cloud2.x += 1.5;
				rad += 1;
				cloud.scaleY = 0.5 + 0.5 * WGeom.sin( rad );
				cloud2.scaleY = 0.5 - 0.5 * WGeom.sin( rad );

				if( moon.x < TRIGGER  ) {
					if( sun.mouth.currentFrame < 20 ) {
						sun.mouth.gotoAndStop( sun.mouth.currentFrame +1 );
					}
					sun.rotation += 0.1;

					if( moon.x < IN_SUN  ) {
						if( moon.mouth.currentFrame < 20 ) {
							moon.mouth.gotoAndStop( moon.mouth.currentFrame +1 );
						}
						moon.rotation -= 0.1;
					}
				
					if( moon.x > OUT_SUN ) {
						bg.alpha -= ( speed * 0.002 ) ;
						moon.glow.scaleX = moon.glow.scaleY += (0.3  * speed  / 2)*0.01;
						sun.glow.scaleX = sun.glow.scaleY += (0.4 * speed  / 2)*0.01;
						moon.glow.alpha = 0.7;
					}
					else if( !won ) {
						sun.mouth.gotoAndStop( sun.mouth.currentFrame +1 );
						moon.mouth.gotoAndStop( moon.mouth.currentFrame +1 );
						bg.alpha += ( speed * 0.002 );
						moon.glow.scaleX = moon.glow.scaleY -= (0.3  * speed / 2)*0.01;
						sun.rotation -= 0.1;
						//sun.x += 2;
						moon.rotation += 0.1;
					}

					if( Std.random( 10 ) == 1 && moon.x > 100 ) {
						var star : flash.display.MovieClip = dm.attach("mcEclipseStar", 0);
						star.x = Std.random( 400 );
						star.y = Std.random( 400 );
						star.rotation = Std.random( 360 );
						star.scaleX = star.scaleY = 0.1;
						var p = new Phys( star );
						p.setAlpha( 20 + Std.random( 50 ) );
						p.timer = 40;
						p.vsc = 1.04;
					}
				}

			if( !won && moon.x < LIMIT_MIN ) {
				setWin(false, 10);
				sun.mouth.gotoAndStop(35);
				moon.mouth.gotoAndStop(35 );
			}
		}
		super.update();
	}

	override function onClick(){
		if( moon.x > LIMIT_MAX + 100 ) return;

		if( hit() ) {
			won = true;
			setWin(true);
			sun.mouth.gotoAndStop( sun.mouth.totalFrames );
			moon.mouth.gotoAndStop( moon.mouth.totalFrames );
			return;
		}
			sun.mouth.gotoAndStop(35);
			moon.mouth.gotoAndStop(35 );

		setWin(false);
	}

	function hit() {
		if( moon.x <= LIMIT_MAX && moon.x >= LIMIT_MIN ) {
			return true;
		}
		return false;
	}


//{
}
