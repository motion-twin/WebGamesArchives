package fx;
import mt.bumdum9.Lib;
import Protocol;

class RunningCoin extends mt.fx.Fx {

	public var path:Array<Square>;
	public var spc:Float;
	var el:EL;
	var cur:Square;
	var ox:Float;
	var oy:Float;
	var pathMax:Int;
	
	public function new(start, end) {
		super();
		if( start == end ) {
			kill();
			return;
		}
		spc = 0.2+Math.random()*0.2;
		ox = (Math.random() * 2 - 1) * 0.45;
		oy = (Math.random() * 2 - 1) * 0.45;
		// PATH
		path = [];
		cur = start;
		Game.me.buildDistFrom(end, true);
		
		var to = 0;
		while(cur != end) {
			for( nei in cur.nei ) {
				if( nei.hdist < cur.hdist ) {
					path.push(nei);
					cur = nei;
					break;
				}
			}
			if( to++ > 1000) break;
		}
		cur =  start;
		pathMax = path.length;
		// SKIN
		el = new EL();
		el.goto("coin");
		Level.me.dm.add(el, Level.DP_GROUND);
		//
		var rad = new gfx.Rad();
		rad.blendMode = flash.display.BlendMode.ADD;
		rad.alpha = 0.1;
		el.addChild(rad);
		// FX
		var e = new mt.fx.ShockWave(8, 24, 0.15);
		var pos = Square.getPos(cur.x+0.5+ox, cur.y+0.5+oy);
		e.setPos(pos.x, pos.y);
		Level.me.dm.add(e.root, Level.DP_FX);
		
		el.x = -100;
	}
	
	override function update() {
		super.update();
		
		coef = coef + spc;
		while( coef >= 1 && path.length > 0 ) {
			coef--;
			cur = path.shift();
		}
		var dir = 0;
		if( path.length > 0 ) 	dir = cur.getDir(path[0]);
		else 					coef = 0;
		
		var d =  Cs.DIR[dir];
		var pc = path.length/pathMax;
		var pos = Square.getPos(cur.x + 0.5+ox*pc + d[0]*coef, cur.y + 0.5+oy*pc + d[1]*coef);
		
		el.x = pos.x;
		el.y = pos.y;
		
		if( path.length == 0 ) {
			cur.addCoin();
			el.parent.removeChild(el);
			kill();
		}
	}
}
