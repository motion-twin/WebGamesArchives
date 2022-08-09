package part;
import Protocole;
import mt.bumdum9.Lib;



class Breath extends mt.fx.Fx {//}
	
	public static var SIZE = 20;
	public var stable:Bool;
	public var board:Board;
	public var px:Int;
	public var py:Int;
	public var life:Int;

	public var pufs:Array < part.Puf >;
	
	public function new(board, px, py) {
		
		this.board = board;
		board.breathes.push(this);
		this.px = px;
		this.py = py;
		
		super();
		stable = false;
		
		pufs = [];
		var pos = getTargetPos();
		for ( i in 0...3 ) {
			var p = new Puf(this);
			p.setPos(pos.x, pos.y);
			p.setScale(0.25 + i * 0.25);
			pufs.push(p);
		}

		life = 0;
	}
	
	public function getTargetPos() {
		return {
			x:(px + 0.5) * SIZE,
			y:(py + 0.5) * SIZE,
		}
	}

	override function update() {
		
		super.update();
		
		
		stable = life++>40;
		
	}
	
	public function checkPos() {
		var a = board.getBreathFreePos(this);
		if ( a == null ) return;
		if ( a.length == 0 ) {
			fxPop();
			kill();
			return;
		}
		px = a[0].x;
		py = a[0].y;
		stable = false;
	}
	
	public function fxPop(){
		// FX
		var max = 8;
		for ( i in 0...max ) {
			var mc =  new gfx.Breath();
			board.dm.add(mc, Board.DP_FX);
			var p = new mt.fx.Part(mc);
			var pos = getTargetPos();
			p.setPos(pos.x, pos.y);
			p.vx = (Math.random() * 2 - 1) * 2.5;
			p.vy = (Math.random() * 2 - 1) * 2.5;
			p.timer = 30;
			p.fadeType = 2;
			p.fadeLimit = 20;
			p.frict = 0.92;
			p.weight -= 0.05 + Math.random() * 0.025;
			p.setScale(0.2 + Math.random() * 0.2);
		}
	}
	
	override function kill() {
		super.kill();
		for ( p in pufs ) p.kill();
		board.breathes.remove(this);
	}
	
	
//{
}