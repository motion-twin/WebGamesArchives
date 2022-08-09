package part;
import flash.MovieClip;
import haxe.Timer;
import mt.bumdum.Lib;

class Leaf extends Part {

	var clip:flash.MovieClip;
	var angle:Float;
	var fall:Bool;
	var maxAmpl:Float;
	var minAmpl:Float;
	var dir:Int;
	var w:Float;
	var vitesse:Float;
	var all:Array<MovieClip>;
	var defaultW:Float;
	public var offsetX:Float;
	public var defaultVx:Float;
	public var defaultVy:Float;
	public var defaultVz:Float;
	
	public function new( mc, delay, pW:Int ) {
		super(mc);
		all = [];
		defaultW = pW;
		init();
	}
	
	public function init() {
		this.vr = 0.0;
		this.bounceFrict = 0.0;
		this.groundFrict = 0.0;
		maxAmpl = 130 + Math.random() * 50;
		minAmpl = 180 - maxAmpl;
		angle = minAmpl + (Math.random() * (maxAmpl - minAmpl));
		vitesse = 0.8 + Math.random() * 3 * maxAmpl / 180;
		w = defaultW;
		dir = 1;
		fall = true;
		clip = root;
		vx = defaultVx;
		vy = defaultVy;
		vz = defaultVz;
		setScale( 100 - vz * 10 );
		updatePos();
	}
	
	inline static var TO_RAD = Math.PI / 180;
	
	dynamic public function onEnd( f ) {
		offsetX = Math.random() * Cs.mcw;
		y = Scene.getRandomPYPos();
		z = -1.5 * Cs.mch;
		init();
	}
	
	public override function update() {
		super.update();
		if( fall ) {
			if( angle > maxAmpl ) dir = -1;
			if( angle < minAmpl ) dir = 1;
			var dist = mt.Timer.tmod * w;
			angle += dir * vitesse * Math.sin(angle*TO_RAD);
			var dx = Math.cos(angle * TO_RAD) * dist;
			x = dx + offsetX;
			root._rotation = angle - 70;
		}
		if( fall && z >= 0 ) {
			fall = false;
			vx = vy = vz = 0;
			onEnd(this);
		}
	}
	
	public function dispose() {
		for( a in all )
			a.removeMovieClip();
		clip.removeMovieClip();
		super.kill();
	}
}
