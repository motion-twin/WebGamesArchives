import mt.bumdum9.Lib;
import Protocol;

class Ent {
	
	public var step:EStep;
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public var moveCoef:Float;
	public var jumpSpeed:Float;
	public var dir:Int;
	public var square:Square;
	public var root:SP;
	
	public var reach:Bool;
	public var spc:Float;
	public var speedMult:Float;
	public var ray:Float;
	public var shade:SP;
	
	public function new() {
		root = new SP();
		Level.me.dm.add(root, Level.DP_ENTS);
		Game.me.ents.push(this);
		dir = 0;
		moveCoef = 0;
		x = y = z = 0;
		spc = 0.1;
		speedMult = 1.0;
		jumpSpeed = 0.1;
		ray = 6;
		step = VOID;
		reach = true;
	}
	
	public function gotoSquareId(id) {
		var sq = Game.me.squares[id];
		setSquare(sq.x, sq.y);
	}
	
	public function setSquare(x,y) {
		square = Game.me.getSquare(x, y);
		updateSquarePos();
	}
	
	public function update() {
		
		switch(step) {
			case MOVE :
				moveCoef += spc * speedMult;
				if(square == null ) throw("no square move");
				if(dir < 0 ) throw("move error dir:"+dir);
				updateSquarePos();
				
				if( reach && moveCoef >= 0.5 ) {
					onReach();
					reach = false;
				}
				
				while( moveCoef >= 1 ) {
					moveCoef--;
					reach = true;
					var d = Cs.DIR[dir];
					setSquare(square.x + d[0], square.y + d[1]);
					onEnterSquare();
					updateSquarePos();
				}
				
			case JUMPING :
				moveCoef = Math.min(moveCoef+jumpSpeed,1);
				updateSquarePos();
				z = -Math.sin(moveCoef*3.14)*20;
				
				if( moveCoef == 1 ) {
					onReach();
					moveCoef--;
					var d = Cs.DIR[dir];
					setSquare(square.x + d[0], square.y + d[1]);
					onEnterSquare();
					updateSquarePos();
					onEndJump();
				}
			
				
			default :
		}
	}
	
	public function onEnterSquare() {
		
	}
	
	public function onReach() {
		
	}
	
	public function onStartJump() {
		
	}
	
	public function onEndJump() {
		
	}
	
	public function updateSquarePos() {
		var d = Cs.DIR[dir];
		var pos = Square.getPos(square.x + 0.5 + d[0] * moveCoef, square.y + 0.5 + d[1] * moveCoef%1);
		x = pos.x;
		y = pos.y;
		updatePos();
	}
	
	public function updatePos() {
		root.x = Std.int(x);
		root.y = Std.int(y + z);
		if( shade != null ){
			shade.x = Std.int(x);
			shade.y = Std.int(y + 10);
		}
		
	}
	
	public function kill() {
		root.parent.removeChild(root);
		Game.me.ents.remove(this);
		if( shade != null ) shade.parent.removeChild(shade);
	}
	
	public function drawFace(color) {
		root.graphics.clear();
		root.graphics.beginFill(color);
		root.graphics.drawCircle(0, 0, Cs.SQ>>2);
		root.graphics.endFill();
	}
	
	public function getDistTo(e:Ent ) {
		var dx = root.x - e.root.x;
		var dy = root.y - e.root.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	public function setDir(di:Int ) {
		dir = di;
	}
	
	public function dropShadow() {
		shade = new SP();
		shade.graphics.beginFill(0);
		shade.graphics.drawEllipse( -10, -4, 20, 8);
		Level.me.shade.addChild(shade);
		
	}
	
}
