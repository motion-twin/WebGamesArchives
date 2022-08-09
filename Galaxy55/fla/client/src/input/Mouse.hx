
package input;


class Mouse
{
	var game : Game;
	
	public function new ( g )
	{
		game = g;
	}
	
	public function update()
	{
		var g = game;
		// mouse camera
		var mx = Std.int(g.smoothMouse.x);
		var my = Std.int(g.smoothMouse.y);
		var stage = flash.Lib.current.stage;
		var dead = 0.30;
		var hero = g.hero;
		
		if( !g.mouseOut) {
			var d = (mx - stage.stageWidth*0.5) / (stage.stageWidth*0.5);
			if( d>-dead && d<dead )
				d = 0;
			else
				d = d*(1-dead);
			
			g.hero.angle += Math.PI*0.015 * d * hero.angleSpeed;
			
			if( g.drag==null || !g.drag.active ) {
				var d = Math.max(-1, Math.min(1, (stage.stageHeight*0.5 - my) / (stage.stageHeight*0.4)));
				if( !hero.lock ) g.bobbingY += d*2;
				var a = d * Math.PI*0.20; // 0.33
				g.hero.angleZ = hero.angleZ + (a - g.hero.angleZ) * 0.17 * mt.Timer.tmod * hero.angleSpeed;
			}
		}
		
		g.interf.showDeadZone(dead);
	}
}