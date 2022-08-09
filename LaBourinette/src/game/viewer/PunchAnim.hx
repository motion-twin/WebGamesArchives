package game.viewer;

class PunchAnim extends flash.display.Sprite {
	var step : Int;
	var col : UInt;
	var particules : List<Particule>;

	public function new(x_:Float, y_:Float, c:UInt=0xFFFFFF, withParticules:Bool=false){
		super();
		col = c;
		x = x_;
		y = y_;
		step = 16;
		blendMode = flash.display.BlendMode.OVERLAY;
		draw();
		if (withParticules){
			particules = new List();
			for (i in 0...Std.random(20)){
				var p = new Particule(c, Math.random()*Math.PI*2);
				addChild(p);
				particules.push(p);
			}
		}
	}

	function draw(){
		var ratio = (16-step)/16;
		graphics.clear();
		graphics.beginFill(col, 1);
		graphics.drawCircle(0, 0, step/2);
		graphics.endFill();
	}

	public function stop() : Void {
		if (parent != null)
			parent.removeChild(this);
	}

	public function update() : Bool {
		step--;
		if (particules != null)
			for (p in particules)
				p.update();
		draw();
		if (step <= 0){
			stop();
			return false;
		}
		return true;
	}
}

class Particule extends flash.display.Shape {
	public var dx : Float;
	public var dy : Float;

	public function new(col=0xFFFFFF, a:Float){
		super();
		var speed = Math.random() * 0.5;
		dx = Math.cos(a) * speed;
		dy = Math.sin(a) * speed;
		graphics.clear();
		graphics.beginFill(col, 1);
		graphics.drawCircle(0, 0, 0.5);
		graphics.endFill();
	}

	public function update(){
		x += dx;
		y += dy;
	}
}
