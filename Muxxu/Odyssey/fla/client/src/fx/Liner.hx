package fx;
import mt.bumdum9.Lib;

class Liner extends mt.fx.Arrow<SP> {//}

	var color:Int;
	var colorEnd:Null<Int>;
	
	public var turn:Float;
	public var turnFrict:Float;
	public var turnAcc:Float;
	public var gy:Null<Int>;
	
	var ox:Float;
	var oy:Float;
	
	public var spc:Float;
	public var time:Int;
	
	public function new(col, ?endCol, time = -4) {
		this.time = time;
		colorEnd = endCol;
		color = col;
		super( new SP() );
		an = Math.random() * 6.28;
		asp = 8;
		aspFrict = 0.97;
		
		turn = 0;
		turnFrict = 0.95;
		turnAcc = 0.1;
		
		
		ox = 0;
		oy = 0;
		
		spc = 0.1;
		
	}
	
	override function setPos(x, y) {
		super.setPos(x, y);
		ox = x;
		oy = y;
	}
	
	override function update() {
		
		
		coef = Math.min(coef + spc, 1);
		
		// MOVE
		turn += (Math.random() * 2 - 1) * turnAcc;
		turn *= turnFrict;
		an += turn;
		//an += 0.3;
		
		// TRACE
		var mc = new McLine();
		mc.gotoAndPlay(24 + time);
		mc.blendMode = root.blendMode;
		mc.filters = root.filters;
	
		var dx = x - ox;
		var dy = y - oy;
		mc.x = ox;
		mc.y = oy;
		mc.scaleX = Math.sqrt(dx * dx + dy * dy) * 0.01;
		mc.rotation = Math.atan2(dy, dx) / 0.0174;
		Game.me.dm.add(mc, Game.DP_FX);
		
		
		var col = color;
		if( colorEnd != null ) col = Col.mergeCol(color, colorEnd, curve(1-coef) );
		
		Col.setColor(mc,col);

		ox = x;
		oy = y;
		
		//
		super.update();
		mc.alpha = root.alpha;
		
		// BOUNCE
		if( gy != null && y > gy ) {
			y = gy;
			var vx = Math.cos(an);
			var vy = -Math.sin(an);
			an = Math.atan2(vy, vx);
		}
		
	}
	
	
	
	
	
	

	
//{
}


