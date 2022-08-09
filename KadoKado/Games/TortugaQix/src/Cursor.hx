import flash.geom.Point;
import flash.display.BitmapData;
import flash.display.Shape;

@:bind
class Tortue extends flash.display.MovieClip {
	public var sub : flash.display.MovieClip;
	public function new(){ super(); }
}

class Cursor {
	public var oldPos : Point;
	public var pos : Point;
	public var gfx : Tortue;
	public var gfxPos(getGfxPos,null) : Point;
	public var collision : flash.display.BitmapData;
	public var speed : Float;
	public var moveVector : geom.Pt;
	var frame : Float;

	public function new(){
		moveVector = { x:0.0, y:0.0 };
		speed = Game.SLOW_SPEED;
		pos = new Point();
		oldPos = new Point();
		gfx = new Tortue();
		gfx.gotoAndStop(3);
		frame = 0;
		collision = new flash.display.BitmapData(40,40,true,0x00000000);
	}

	public function getCollisionBitmap() : flash.display.BitmapData {
		collision.fillRect(collision.rect, 0x00000000);
		collision.draw(gfx);
		return collision;
	}

	public function setNewMoveVector( x:Float, y:Float ){
		if (x == moveVector.x && y == moveVector.y)
			return;
		moveVector.x = x;
		moveVector.y = y;
		if (y > 0){
			gfx.gotoAndStop(3);
			frame = 0;
		}
		else if (y < 0){
			gfx.gotoAndStop(2);
			frame = 0;
		}
		else if (x > 0){
			gfx.gotoAndStop(1);
			frame = 0;
		}
		else if (x < 0){
			gfx.gotoAndStop(4);
			frame = 0;
		}
	}

	function getGfxPos() : Point {
		return new Point(pos.x - 5, pos.y - 5);
	}

	public function update(){
		if (gfx == null)
			return;
		gfx.x = pos.x;
		gfx.y = pos.y;
		var fspeed = (speed/Game.SLOW_SPEED);
		frame += fspeed * mt.Timer.tmod;
		if (gfx.sub == null)
			return;
		if (moveVector.x == 0 && moveVector.y == 0){
			gfx.sub.stop();
			return;
		}
		var f = Math.round(frame);
		if (f > gfx.sub.totalFrames){
			f -= gfx.sub.totalFrames;
			frame -= gfx.sub.totalFrames;
		}
		gfx.sub.gotoAndStop(f);
	}
}