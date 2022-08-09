import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

class QixLazer extends Sprite {
	public var previous : { x:Float, y:Float };
	public var ground : { x:Float, y:Float };
	public var target : geom.PVector;
	public var speed  : Float;
	public static var color : UInt = 0xFFFF4400;
	public static var blurColor : UInt = 0xFFAA8833;
	public var blur : Shape;

	var angle : Float;
	var distance : Float;
	var rpos : Float;

	public function new(x,y, tx, ty){
		super();
		this.x = x;
		this.y = y;
		speed = Game.level.dogLazerSpeed;
		ground = { x:x+0.0, y:y+50.0 };
		previous = { x:x+0.0, y:y+50.0 };
		setTarget(tx, ty);
		blur = new Shape();
		blur.blendMode = flash.display.BlendMode.MULTIPLY;
		addChild(blur);
		draw();
	}

	public function setTarget( tx, ty ){
		target = new geom.PVector(tx,ty);
		var vector = target.clone().sub(ground);
		distance = vector.length();
		angle = vector.angle();
		rpos = 0.0;
	}

	public static function frequencePoint( x:Float, max:Float ){
		var frequence = 1/8;
		var amplitude = 80;
		var distanceRatio = x/max;
		return new geom.PVector(x, Math.sin(x*frequence) * amplitude * distanceRatio);
	}

	public function update() : Bool {
		rpos += (speed * mt.Timer.tmod);
		rpos = Math.min(rpos, distance);
		var fp = frequencePoint(rpos, distance);
		if (ground.x > x)
			fp.y = -fp.y;
		fp.rotate(angle);
		fp.add({x:x, y:y});

		var dif = new geom.PVector(fp.x-ground.x, fp.y-ground.y);
		dif.limit(speed);
		previous.x = ground.x;
		previous.y = ground.y;
		ground.x += dif.x;
		ground.y += dif.y;
		return rpos < distance;
	}

	function drawBlur(){
		var deltaX = ((previous.x - ground.x) > 0) ? 1 : -1;
		var deltaY = ((previous.y - ground.y) > 0) ? 1 : -1;

		blur.graphics.clear();
		// blur.alpha = 0.5;
		blur.graphics.lineStyle(2, blurColor);
		blur.graphics.beginFill(blurColor);
		blur.graphics.moveTo(0, 0);
		blur.graphics.lineTo(ground.x-x, ground.y-y);
		blur.graphics.lineTo(previous.x-x, previous.y-y);
		blur.graphics.lineTo(0, 0);
		graphics.drawCircle(ground.x-x + deltaX*2, ground.y-y + deltaY, 1);
		blur.graphics.endFill();
		blur.filters = [
			new flash.filters.BlurFilter(8,8,1),
			new flash.filters.ColorMatrixFilter([
				1, 0, 0, 0, -2,
				0, 1, 0, 0, -2,
				0, 0, 1, 0, -2,
				0, 0, 0, 1, -1,
			])
		];
	}

	public function draw(){
		var deltaX = ((previous.x - ground.x) > 0) ? 1 : -1;
		var deltaY = ((previous.y - ground.y) > 0) ? 1 : -1;
		graphics.clear();
		graphics.lineStyle(2, color);
		graphics.beginFill(color);
		graphics.moveTo(0, 0);
		graphics.lineTo(ground.x-x, ground.y-y);
		graphics.lineTo(previous.x-x, previous.y-y);
		graphics.lineTo(0, 0);
		graphics.drawCircle(ground.x-x + deltaX*2, ground.y-y + deltaY, 2);
		graphics.endFill();
		graphics.lineStyle(0);
		graphics.beginFill(0xFFFFFF);
		for (i in 0...3){
			var rX = 5 - Std.random(10);
			var rY = 2 - Std.random(10);
			graphics.drawCircle(ground.x-x+rX, ground.y-y+rY, 1);
		}
		graphics.endFill();
		filters = [];
		drawBlur();
	}
}
