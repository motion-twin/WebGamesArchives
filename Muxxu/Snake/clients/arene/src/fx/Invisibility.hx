package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Invisibility extends Fx {//}
	
	var timer:Int;

	public function new() {
		super();
		sn.invicible = true;
		timer = 400;
		sn.setPalette(1);
		
		var max = 32;
		var cr = 4;
		
		Game.me.shake(0, 8);
		var m = [
			1,1,0,0,0,
			0,1,1,0,0,
			1,0,1,0,400,
			0,0,0,1,0.0,
		];
		new FlashScreen(0.1,m);
		
		
	}
	
	override function update() {
		super.update();
		if( Game.me.snake == null ||Game.me.snake.length == 0 ) return;
		for( i in 0...2 ) {
			var p = part.Globule.get();
			initSprite(p.sprite);
		}
		
		if( timer < 60 ) {
			var blink = 3;
			sn.setPalette( (timer % (blink * 2) < blink )?0:1 );
		}
		
		
		
		if( timer-- == 0 ) kill();
	}
	
	function initSprite(sprite:pix.Sprite) {
		sprite.setAnim(Gfx.fx.getAnim("spark_dust_pulse"), true);
		Stage.me.dm.add(sprite, Stage.DP_FX);
		var color = Col.objToCol({ r:0, g:Std.random(100), b:Std.random(255) } );
		Filt.glow(sprite, 8, 8, color);
		sprite.blendMode = flash.display.BlendMode.ADD;
		sprite.alpha = 0.75;
	}
	
	override function kill() {
		sn.invicible = false;
		sn.setPalette(0);
		super.kill();
	}
	
//{
}












