package fx;
import mt.bumdum9.Lib;

typedef GrabFruit = { fr:Fruit, fid:Int, tw:Tween, c:Float, spc:Float, z:Float };

class MagicHat extends Fx{//}

	
	var fruits:Array<GrabFruit>;

	
	public function new() {
		super();
		
		var ray = 50;
		//var ex  = sn.x + Snk.cos(sn.angle)*ray;
		//var ey  = sn.y + Snk.sin(sn.angle)*ray;
		var ex = Stage.me.width >> 1;
		var ey = Stage.me.height >> 1;
		
		var chaos = 10;
		fruits = [];
		for( fr in Game.me.fruits ) {
			ex += Game.me.seed.random(chaos * 2) - chaos;
			ey += Game.me.seed.random(chaos * 2) - chaos;
			var tw = new Tween(fr.x, fr.y, ex, ey);
			var dx = ex - fr.x;
			var dy = ey - fr.y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			fruits.push( { fr:fr, fid:fr.initId, tw:tw, c:0.0, spc:Math.min(0.2,7/dist)*(0.8+Game.me.seed.rand()*0.2), z:12+dist/5 } );
		}
	}
	
	override function update() {
		
	
		
		var a = fruits.copy();
		for( o in a ) {
			o.c = Math.min(o.c+o.spc,1);
			var p = o.tw.getPos(o.c);
			var z = -Snk.sin(o.c * 3.14) * o.z;
			
			if( o.fr.initId != o.fid ) {
				fruits.remove(o);
				continue;
			}
			
			// MOVE
			o.fr.setPos( p.x, p.y, z );
			
			if( o.c == 1 ) {
				o.fr.sprite.filters = [];
				fruits.remove(o);
				continue;
			}
			
			// SHADE
			if( Game.me.gtimer % 2 == 0 ) o.fr.fxShade(0xAA00AA);
			
			// SPARK
			for( i in 0...2 ){
				var p = Stage.me.getPart("spark_dust");
				p.sprite.anim.loop = true;
				p.sprite.anim.gotoRandom();
				p.x = o.fr.sprite.x + Std.random(13)-7;
				p.y = o.fr.sprite.y + Std.random(13)-7;
				p.timer = 15;
				p.sprite.filters = [ new flash.filters.GlowFilter(0xFF00FF, 1, 4, 4, 2) ];
				p.sprite.blendMode = flash.display.BlendMode.ADD;
			}
			
			//
			var pow = Math.abs(Snk.sin(o.c * 3.14));
			o.fr.sprite.filters = [
				new flash.filters.GlowFilter(0xFFFFFF, pow, 2, 2, 10),
				//new flash.filters.GlowFilter(0xFF00FF, 1, 6+pow*12, 6+pow*12, 1),
			];
			
			
			
		}
		
		
		if( fruits.length == 0 ) kill();
	}
		
	
	
//{
}