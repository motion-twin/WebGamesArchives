package part;

import mt.bumdum.Lib;
import Fight;

class Lightning extends Sprite
{
	var segments:Array<{x:Float,y:Float}>;
	var clength:Int;
	var mcDraw:flash.MovieClip;
	
	public function new() {
		mcDraw = Scene.me.dm.empty(Scene.DP_FIGHTER);
		mcDraw.blendMode = "add";
		Filt.glow(mcDraw, 10, 1, 0xFFFF00);
		
		super(mcDraw);
		
		generate();
	}
	
	public function generate()
	{
		var w = 10;
		var units = 20;
		var px = x;
		clength = 20;
		var ty = Scene.getGY(0);
		var py = 1.0*Scene.HEIGHT;
		segments = [{x:px,y:py}];
		
		while( py > ty ) {
			py -= clength;
			segments.push( {x:px,y:py} );
		}
		
		power = Std.random(6);
		flashTime = 10 + power;
		life = 15 + 2 * power;
		randomness = 5 + Std.random(10);
		root._alpha = 100;
		wait = Std.random(15);
		mcDraw.clear();
		
		x = Math.random() * Scene.WIDTH;
		y = Scene.getRandomPYPos();
		z = -1.5 * Scene.HEIGHT;
		updatePos();
	}
	
	var wait:Int;
	var power:Int;//(0 - 5)
	var flashTime:Int;
	var life:Int;
	var randomness:Int;
	
	public override function update(){
		//super.update();
		wait--;
		if(  wait > 0 ) return;
		life --;
		flashTime--;
		if( flashTime >= 0 ){
			mcDraw.lineStyle(1,0xFFFFFF,100);
			var first = segments[0];
			mcDraw.clear();
			mcDraw.moveTo(first.x,first.y);
			var ec = randomness;
			var id = 0;
			var thickness = power;
			var minThickness = 3;//lower value must be >= 1

			var half = segments.length*0.5;

			for( p in segments ){
				var c = (1-Math.abs(id-half)/half);
				mcDraw.lineStyle(minThickness+c*thickness,0xFFFFFF,100);
				mcDraw.lineTo( p.x+(Math.random()*2-1)*ec, p.y+(Math.random()*2-1)*ec );
				id++;
			}
			
			//if( flashTime == 0 )
			//	Filt.blur(mcDraw, 4, 4 );
		}
		else {
			root._alpha -= 100/life;
			if(  life == 0 ) kill();
		}
	}
	
	override function kill()
	{
		generate();
	}
	
	public function dispose()
	{
		mcDraw.removeMovieClip();
		super.kill();
	}
}
