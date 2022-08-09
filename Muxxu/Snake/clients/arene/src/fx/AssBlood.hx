package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class AssBlood extends Fx {//}
	
	var brush:pix.Sprite;
	public function new(speed=0.2) {
		super();
		
		brush = new pix.Sprite();
		brush.setAnim(Gfx.fx.getAnim("blood_trace"), false);
		brush.anim.onFinish = kill;
		brush.anim.play(speed);
	}
	
	override function update() {
		
		var bmp = Stage.me.gore.bitmapData;
		var m = new flash.geom.Matrix();
		var a = Game.me.snake.queue;
		if (a.length < 2 ) return;
		
		var p = a[a.length - 1];
		var p2 = a[a.length - 2];
		var dx = p2.x - p.x;
		var dy = p2.y - p.y;
		var a = Math.atan2(dy, dx);
		m.rotate(a);
		m.translate(p.x,p.y);
		bmp.draw(brush, m);
		
		var n = 8;
		Stage.me.renderBg(new flash.geom.Rectangle(p.x-n,p.y-n,n*2,n*2));
		
	}
	
	override function kill() {
		super.kill();
		brush.kill();
	}

		
	
//{
}












