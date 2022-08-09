package part;
import mt.bumdum.Lib;


class Bubbles extends Part {

	var angle:Float;
	var defaultScale : Float;
	var defaultWeight : Float;
	var defautWeightCoef : Float;
	var defaultKillY : Float;
	//var speed:Float;
	
	public function new( ?pScale : Float = 30, ?pWeight : Float = -0.003, ?pWeightCoef : Float = 0.003, ?pKillY:Float = 50. ) {
		var ball = Scene.me.dm.attach("bulles", Scene.DP_FIGHTER);
		super(ball);
		defaultScale = pScale;
		defaultWeight = pWeight;
		defautWeightCoef = pWeightCoef;
		defaultKillY = pKillY;
		init();
	}
	
	function init() {
		x = Math.random() * Cs.mcw;//Scene.WIDTH;
		y = Scene.getRandomPYPos();
		z = 0;
		updatePos();
		
		this.weight = defaultWeight;
		this.vx = this.vz = 0;
		this.vy = 2 * this.weight;
		this.vr = 0.0;
		this.setScale(defaultScale);
		//speed = .3 + .5 * Math.random();
	}

	public override function update() {
		super.update();
		//var dist = speed * mt.Timer.tmod;
		x += Math.random() * 2 - 1;
		//
		weight -= defautWeightCoef * mt.Timer.tmod;
		//
		if(  root._y < defaultKillY ) kill();
	}
	
	override function kill() {
		init();
		
	}
	
	public function dispose() {
		super.kill();
	}
}