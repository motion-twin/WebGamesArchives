package fx;
import mt.bumdum9.Lib;

class MouseString extends Fx{//}

	public static var box:flash.display.Sprite;
	public static var me:MouseString;
	
	public function new( ) {
		super();
		me = this;
		box = new flash.display.Sprite();
		Stage.me.dm.add(box, Stage.DP_BG);
	}
	
	override function update() {
	
		var a = [];
		var x = sn.x;
		var y = sn.y;
		var an = sn.angle;
		var turnSpeed = sn.getTurnSpeed();

		var dist = 9999.9;
		for( i in 0...100 ) {
			a.push( { x:x, y:y } );
			
			x += Snk.cos(an) * sn.realSpeed;
			y += Snk.sin(an) * sn.realSpeed;
			var coef = Game.me.getMouseTurn(x, y, an);
			an += turnSpeed * coef;
			
			var mp = Cs.getMousePos(Stage.me.root);
			var d = Math.abs(mp.x - x) + Math.abs(mp.y - y);
			if( d < dist )		dist = d;
			else				break;
			
		}
		
		// DRAW
		var gfx = box.graphics;
		gfx.clear();
		gfx.lineStyle(1, 0xFFFFFF, 0.5);
		gfx.moveTo(a[0].x, a[0].y);
		for( p in a ) {
			gfx.lineTo(p.x, p.y);
		}
		
		
	}

	override function kill() {
		me = null;
		super.kill();
	}
	
//{
}