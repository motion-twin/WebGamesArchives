@:bind
class Nature extends flash.display.MovieClip {
	public var vect : { x:Float, y:Float };
	public var speed : Float;
	public var rotationSpeed : Float;
	public var scaleMax : Float;

	public function new(){
		super();
		gotoAndStop(Std.random(totalFrames)+1);
		rotationSpeed = 0;
		speed = 0;
		scaleMax = 1;
	}
}

class EnemyDeathAnim extends flash.display.Sprite, implements Anim {
	static var WHITE = 0;
	static var PARTICULES = 1;
	static var FADE = 2;

	static var BOOM_TIME = 0.5;
	static var FADE_TIME = 1;

	var enemy : Enemy;
	var hurt : HurtAnim;
	var state : Int;
	var time : Float;
	var particules : List<Nature>;

	public function new( enemy:Enemy ){
		super();
		this.state = WHITE;
		this.enemy = enemy;
		this.x = enemy.x;
		this.y = enemy.y;
		this.hurt = new HurtAnim(enemy, 200);
		this.time = 0.0;
		Game.instance.fxLayer.addChild(this);
		Game.instance.addAnimation(this);
	}

	function boom(){
		particules = new List();
		var n = 15 + Std.random(10);
		if (Game.instance.slowLevel == 3)
			n = Math.ceil(n / 4);
		else if (Game.instance.slowLevel == 2)
			n = Math.ceil(n / 3);
		else if (Game.instance.slowLevel == 1)
			n = Math.ceil(n / 2);
		var sr = 60/mt.Timer.wantedFPS;
		for (i in 0...n){
			var n = new Nature();
			n.x = 0;
			n.y = 0;
			n.vect = {
				x:1 - 2*Math.random(),
				y:1 - 2*Math.random(),
			};
			n.rotationSpeed = (5 - Math.random()*10) * sr;
			n.speed = (1.5 + Math.random()*3) * sr;
			n.scaleMax = 0.5 * n.speed;
			addChild(n);
			particules.push(n);
		}
	}

	public function update() : Bool {
		time += mt.Timer.deltaT;
		switch (state){
			case WHITE:
				if (!hurt.update()){
					boom();
					enemy.parent.removeChild(enemy);
					state++;
				}
			case PARTICULES:
				var dt = Math.min(time, BOOM_TIME) / BOOM_TIME;
				for (p in particules){
					p.x += mt.Timer.tmod * (1-dt) * p.speed * p.vect.x;
					p.y += mt.Timer.tmod * (1-dt) * p.speed * p.vect.y;
					p.rotation += p.rotationSpeed * mt.Timer.tmod;
					p.scaleX = p.scaleMax * dt;
					p.scaleY = p.scaleMax * dt;
				}
				if (time >= BOOM_TIME){
					state = FADE;
					time = 0;
				}
			case FADE:
				var dt = Math.min(time, FADE_TIME) / FADE_TIME;
				for (p in particules){
					p.x += mt.Timer.tmod * p.speed * p.vect.x * 0.1;
					p.y += mt.Timer.tmod * p.speed * p.vect.y * 0.1;
					p.rotation += p.rotationSpeed * mt.Timer.tmod * 0.1;
					p.scaleX = p.scaleMax * (1-dt);
					p.scaleY = p.scaleMax * (1-dt);
					if (dt == 1){
						removeChild(p);
						particules.remove(p);
					}
				}
				if (dt == 1 ||  particules.length == 0)
					return false;
		}
		return true;
	}
}