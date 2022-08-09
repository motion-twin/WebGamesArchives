@:bind
class EnemyShot extends flash.display.MovieClip, implements Anim {
	public var dx : Float;
	public var dy : Float;
	public var speed : Float;
	public var destroyed : Bool;
	public var power : Int;

	public function new( vec:{x:Float, y:Float}, ?speed:Float=2.0 ){
		super();
		this.speed = speed * (60/mt.Timer.wantedFPS);
		this.dx = vec.x;
		this.dy = vec.y;
		this.destroyed = false;
		this.power = 1;
		this.rotation = Geom.angleDeg({x:0.0, y:0.0}, vec);
		this.gotoAndStop(1);
	}

	public function update() : Bool {
		this.x += dx * speed * mt.Timer.tmod;
		this.y += dy * speed * mt.Timer.tmod;
		return true;
	}
}

@:bind
class Lazer extends EnemyShot {
	var end : Float;
	var state : Int;

	public function new(){
		super({x:0.0, y:0.0});
		setState(0, 200);
	}

	function setState( st:Int, dur:Float ){
		end = Game.instance.now + dur;
		state = st;
		switch (state){
			case 0: gotoAndStop(1);
			case 1: gotoAndStop(2);
		}
	}

	override public function update() : Bool {
		switch (state){
			case 0:
				if (Game.instance.now >= end)
					setState(1, 200);
			case 1:
				if (Game.instance.now >= end){
					destroyed = true;
					if (parent != null)
						parent.removeChild(this);
					return false;
				}
		}
		return true;
	}
}