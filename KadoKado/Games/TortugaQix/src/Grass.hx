import geom.PVector;
import flash.Lib;
import flash.display.Shape;

class Grass extends Shape {
	public static var DEFAULT_COLORS = [ 0x113300, 0x00EE00, 0x88FF88 ];
	var length : Float;
	var baseLength : Float;
	var controlHeight : Float;
	var mx : Float;
	var my : Float;
	var wind : Float; // wind direction
	var colors : Array<UInt>;

	public function new(base:Float, height:Float, ?ctr:Float=0.6, ?wind:Float=0.0, ?colors:Array<UInt>){
		super();
		baseLength = base;
		length = height;
		controlHeight = ctr;
		mx = 0;
		my = -height*3/4;
		this.wind = wind;
		if (wind < -1.0)
			this.wind = -1.0;
		else if (wind > 1.0)
			this.wind = 1.0;
		this.colors = DEFAULT_COLORS;
		if (colors != null)
			this.colors = colors;
		draw();
	}

	function draw(){
		var botLeft = new PVector(-baseLength/2, 0);
		var botRight = new PVector(baseLength/2, 0);
		var top = new PVector(0, -length);
		var center = new PVector(0, -length*controlHeight);
		var dist = length*(1-controlHeight);
		var angle = -2 * Math.PI * wind/2 + Math.PI/2;
		top.x = center.x + Math.cos(angle) * dist;
		top.y = center.y - Math.sin(angle) * dist;
		var cLeft = new PVector(-baseLength/2, -length*controlHeight);
		var cRight = new PVector(baseLength/2, -length*controlHeight);
		graphics.clear();
		var matrix = new flash.geom.Matrix();
		matrix.createGradientBox(length, length, -Math.PI/2, mx, my);
		graphics.beginFill(colors[0], 0.3);
		graphics.moveTo(botLeft.x, botLeft.y);
		graphics.curveTo(cLeft.x, cLeft.y, top.x, top.y+(length*0.2));
		graphics.curveTo(cRight.x+(baseLength*0.2), cRight.y, botRight.x+(baseLength*0.2), botRight.y);
		graphics.lineTo(botLeft.x, botLeft.y);
		graphics.endFill();
		graphics.beginGradientFill(flash.display.GradientType.LINEAR, colors, [1,1,1], [1,254,255], matrix);
		graphics.moveTo(botLeft.x, botLeft.y);
		graphics.curveTo(cLeft.x, cLeft.y, top.x, top.y);
		graphics.curveTo(cRight.x, cRight.y, botRight.x, botRight.y);
		graphics.lineTo(botLeft.x, botLeft.y);
		graphics.endFill();
	}

	static var screen : flash.display.Bitmap;
	static var allGrass : flash.display.Sprite;

	static function drawLawn(){
		allGrass = new flash.display.Sprite();
		allGrass.graphics.beginFill(0x335500);
		allGrass.graphics.drawRect(0,0,300,300);
		allGrass.graphics.endFill();
		var step = 4;
		var zoom = 2;
		var step = step * zoom;
		for (x in 0...Std.int(300/step)+1){
			for (y in 0...Std.int(300/step)+3){
				var g = new Grass(
					zoom* (1+1*Math.random()),
				    zoom* (10+40*Math.random()),
					(0.5 + 0.3*Math.random()),
					(0.4 * (Math.random()*2 - 1))
				);
				g.x = x * step + Math.random()*step/2;
				g.y = y * step + Math.random()*step/2;
				allGrass.addChild(g);
			}
		}
		screen.bitmapData.draw(allGrass);
	}

	static function update(_) : Void {
		Key.update();
		if (Mouse.down){
			Mouse.down = false;
			drawLawn();
		}
	}
}