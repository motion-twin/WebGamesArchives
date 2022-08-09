package fx;
import Protocole;
import Snake;

class Magnet extends CardFx {//}

	var dec:Float;
	var layer:flash.display.Sprite;
	public static var me:Magnet;
	
	public function new(ca) {
		if( me != null ) return;
		me = this;
		super(ca);
		dec = 0;
		layer = new flash.display.Sprite();
		Stage.me.dm.add(layer, Stage.DP_BG);
		//layer.blendMode = flash.display.BlendMode.ADD;
		
	}
	
	override function update() {
		

		var ray = 40 * Game.me.numCard(MAGNET) + 20 * Game.me.numCard(LASSO);
		var a = Game.me.fruits.copy();
		for( fr in a ) {
			if( fr.dummy || fr.z < -3 ) continue;
			var dx  = sn.x - fr.x;
			var dy  = sn.y - fr.y;
			if( Math.sqrt(dx * dx + dy * dy) < ray ) new FruitToTarget(fr, 6,sn);
		}
		
		
		// FX
		dec = (dec + 0.2) % 6.28;
		var max = Std.int( (Math.PI * ray * 2) / 16 );
		var ec = 6.28 / max;
		max++;
		var b = [];
		for( i in 0...max) {
			var a = (i + 1) * ec;
			var cycle = Snk.sin(a) * 4;
			var dist = ray + Snk.sin(dec + cycle) * 8;
			var dx =  Snk.cos(a) * dist;
			var dy =  Snk.sin(a) * dist;
			b.push( { dx:dx, dy:dy } );
		}
		
		layer.graphics.clear();

		for( i in 0...2 ) {
			var first = true;
			var c = 1 - i * 0.5;
			layer.graphics.beginFill(0xFFFF66, 0.15);
			if( i == 0 )layer.graphics.lineStyle(1, 0xFFFF88,0.2);
			for( p in b ) {
				var x = sn.x + p.dx*c;
				var y = sn.y + p.dy*c;
				var p = Stage.me.clamp(x, y, 2);
				if(first) {
					layer.graphics.moveTo(p.x, p.y);
					first = false;
					continue;
				}
				layer.graphics.lineTo(p.x, p.y);
			}
			layer.graphics.endFill();
		}
		
		//
		super.update();
		layer.visible = !sn.dead && sn.rlength > 5;
		
	}
	
	override function kill() {
		if(!Game.me.have(MAGNET)) {
			layer.parent.removeChild(layer);
			me = null;
			super.kill();
		}
	}
	


	
//{
}












