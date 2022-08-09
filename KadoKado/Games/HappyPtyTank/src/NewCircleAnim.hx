import EnemyDeathAnim;

class NewCircleAnim extends flash.display.Sprite, implements Anim {
	var time : Float;
	var particules : List<Nature>;
	var duration : Float;
	var state : Int;
	static var BOOM_DURATION = 0.5;
	static var FADE_DURATION = 1;
	
	public function new(){
		super();
		state = 0;
		time = 0;
		duration = BOOM_DURATION;
		particules = new List();
		x = Game.instance.tank.x;
		y = Game.instance.tank.y;
		Game.instance.groundLayer.addChild(this);
		Game.instance.addAnimation(this);
		boom();
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
		var maxSpeed = 1;
		for (i in 0...n){
			var n = new Nature();
			n.x = 0;
			n.y = 0;
			n.vect = {
				x:1 - 2*Math.random(),
				y:1 - 2*Math.random(),
			};
			n.rotationSpeed = (5 - Math.random()*10) * sr;
			n.speed = (maxSpeed/2 + Math.random()*maxSpeed) * sr;
			n.scaleMax = n.speed * 0.8;
			addChild(n);
			particules.push(n);
		}
	}

	public function update() : Bool {
		time += mt.Timer.deltaT;
		var delta = Math.min(1, time / duration);
		switch (state){
			case 0:
				for (p in particules){
					p.x += mt.Timer.tmod * (1-delta) * p.speed * p.vect.x;
					p.y += mt.Timer.tmod * (1-delta) * p.speed * p.vect.y;
					p.rotation += p.rotationSpeed * mt.Timer.tmod;
					p.scaleX = p.scaleMax * Math.pow(delta, 3.0);
					p.scaleY = p.scaleMax * Math.pow(delta, 3.0);
				}
				if (delta >= 1){
					state = 1;
					time = 0;
					duration = FADE_DURATION;
				}

			case 1:
				for (p in particules){
					p.x += mt.Timer.tmod * p.speed * p.vect.x * 0.1;
					p.y += mt.Timer.tmod * p.speed * p.vect.y * 0.1;
					p.rotation += p.rotationSpeed * mt.Timer.tmod * 0.1;
					p.scaleX = p.scaleMax * (1-delta);
					p.scaleY = p.scaleMax * (1-delta);
					if (delta == 1){
						removeChild(p);
						particules.remove(p);
					}
				}
				if (delta == 1 || particules.length == 0)			
					return false;
		}
		return true;
	}
}