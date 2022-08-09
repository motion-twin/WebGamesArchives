package fx;
import Protocole;
import mt.bumdum9.Lib;

class Arc extends Fx {//}

	static var LIFE = 10;
	static var MARGIN = 2;
	
	var pos:Float;
	var wallCoef:Float;
	var spc:Float;
	
	var gfx:flash.display.Graphics;
	var timer:Int;
	public var colors:Array<Int>;
	public function new(pos, gfx) {
		this.pos = pos;
		this.gfx = gfx;
		super();

		
		//colors = [0xDDBBFF, 0x8800FF ];
		colors = [0xFFFFFF, 0xFFFFFF ];
		
		timer = LIFE;
		spc = (Math.random() * 2 - 1) * 0.005;
		
		var ring = sn.getRingData(pos).ring;
		var max = 200;
		var min = 99999.9;
		wallCoef = 0.0;
		for( i in 0...max ) {
			var co = i / max;
			var p = Stage.me.getWallPos(co);
			var dx = p.x - ring.x;
			var dy = p.y - ring.y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if( dist < min ) {
				min = dist;
				wallCoef = co;
			}
		}

	}
	
	override function update() {
		super.update();
		
		wallCoef = Num.sMod(wallCoef+spc,1);
		pos += spc * 200;
		
		var o = Stage.me.getWallPos(wallCoef,MARGIN);
		var ring = sn.getRingData(pos).ring;
		if(!sn.isRingIn(ring)) {
			kill();
			return;
		}
		var dx = o.x - ring.x;
		var dy = o.y - ring.y;
		var a = [];
		var max = 4;
		for( i in 0...max ) {
			var c = i / (max - 1);
			var ec = 4;
			if( i == max - 1 || i ==0) ec = 0;
			a.push( { x:ring.x+dx*c + (Math.random()*2-1)*ec ,y:ring.y+dy*c+(Math.random()*2-1)*ec } );
			
		}
		
		
		// DRAW
		for( i in 0...2 ){
			var size = 2 - Math.abs((timer / LIFE) * 2 - 1) * 1.5;
			size += i * 8;
			
			gfx.lineStyle(size, colors[i],1-i*0.94);
			var first = a.shift();
			gfx.moveTo(first.x, first.y);
			for( p in a ) gfx.lineTo(p.x, p.y);

			
			if( timer-- == 0 ) kill();
		
		}
		
		
	}
	

	
	

	
	

		
	
//{
}
