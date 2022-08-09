package part;
import mt.bumdum9.Lib;

class Basic extends mt.fx.Part<SP>  {
	public var shade:SP;
	public var zh:Float;
	public var vz:Float;
	
	public var frictGroundXY:Float;
	public var frictGroundZ:Float;
	public var weightZ:Float;
	
	public var ray:Int;
	
	public function new(sp) {
		super(sp);
		ray = 1;
		zh = -ray;
		vz = 0;
		weightZ = 0;
		
		frictGroundZ = 0.5;
		frictGroundXY = 0.75;
	}

	override function updatePos() {
		root.x = Std.int(x);
		root.y = Std.int(y + zh);
		if ( shade != null ) {
			shade.x = Std.int(x);
			shade.y = Std.int(y);
		}
	}
	
	override function update() {
		vz += weightZ;
		vz *= frict;
		zh += vz;
		if ( zh > -ray ) {
			zh = -ray;
			vx *= frictGroundXY;
			vy *= frictGroundXY;
			vz *= -frictGroundZ;
		}
		// UPDATE
		super.update();
		// RECAL
		var ma = Game.BORDER_X + ray;
		if ( x < ma || x > Game.WIDTH - ma ) {
			x = Num.mm(ma, x, Game.WIDTH - ma);
			vx *= -1;
		}
		var ma = Game.BORDER_Y + ray;
		if ( y < ma || y > Game.HEIGHT - ma ) {
			y = Num.mm(ma, y, Game.HEIGHT - ma);
			vy *= -1;
		}
	}
	
	public function dropShade(?r:Int) {
		if ( r != null ) ray = r;
		shade = new SP();
		shade.graphics.beginFill(0);
		shade.graphics.drawCircle(0, 0, ray);
		shade.graphics.endFill();
		Game.me.shadeLayer.addChild(shade);
	}

	override function kill() {
		super.kill();
		if ( shade != null ) shade.parent.removeChild(shade);
	}
}
