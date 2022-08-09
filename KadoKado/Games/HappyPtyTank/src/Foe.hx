@:bind
class Foe extends WaveEnemy {
	var time : Float;
	public var back : Array<FoeBack>;

	public function new(){
		super();
		life = maxLife = 10;
		value = KKApi.const(100);
		speed = 3 * (60/mt.Timer.wantedFPS);
		angle = 0;
		time = 0;
		back = new Array();
	}

	function newShadow(){
		if (back.length > 0)
			back.shift().reset();
		else
			new FoeBack(this);
	}

	override public function update(){
		if (Game.instance.slowLevel < 3){
			time += mt.Timer.deltaT;
			if (time > 0.1){
				newShadow();
				time = 0;
			}
		}
		super.update();
	}

	override public function updateLeader(){
		angle = Geom.averageRadianAngle(angle, Geom.angleRad(this, Game.instance.tank)) ;
		Geom.moveAngle(this, angle, speed * mt.Timer.tmod);
	}
}

@:bind
class FoeBack extends flash.display.Sprite, implements Anim {
	var time : Float;
	var foe : Foe;

	public function new(foe:Foe){
		super();
		this.foe = foe;
		reset();
	}

	public function reset(){
		x = foe.x;
		y = foe.y;
		alpha = 0.9;
		rotation = foe.rotation + 60 - Std.random(60);
		time = 0;
		Game.instance.groundLayer.addChild(this);
		Game.instance.addAnimation(this);
	}

	public function update(){
		time += mt.Timer.deltaT;
		if (time > 0.2){
			alpha = 0.5;
		}
		if (time > 0.4){
			parent.removeChild(this);
			Game.instance.delAnimation(this);
			foe.back.push(this);
			return false;
		}
		return true;
	}
}