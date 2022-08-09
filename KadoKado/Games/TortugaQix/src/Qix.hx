import flash.display.Shape;
import geom.PVector;

@:bind
class Ovni extends flash.display.MovieClip {
	public var sub : flash.display.MovieClip;
	public function new(){
		super();
	}
}

class Shadow extends flash.display.BitmapData {
	public function new(){
		super(Qix.W, Qix.H, true, 0x00000000);
		var s = new flash.display.Shape();
		var g = s.graphics;
		g.beginFill(0x333333);
		g.drawEllipse(0, 0, Qix.W, Qix.H);
		g.endFill();
		draw(s);
	}
}

enum QixState {
	FLY;
	LAND;
	SHOOT;
	LAUNCH;
}

class Qix extends Ovni {
	public static var W = 80;
	public static var H = 42;
	var shape : Shape;
	var lines : Array<Array<PVector>>;
	var mover : geom.Mover;
	var state : QixState;
	public var bitmap : flash.display.BitmapData;
	var target : PVector;
	var timing : Float;

	public var lazers : Array<QixLazer>;
	var lazersFilter : flash.filters.BitmapFilter;
	public var lazersFront : flash.display.BitmapData;
	public var lazersBack : flash.display.BitmapData;

	public function new(){
		super();
		mover = new geom.Mover();
		mover.x = W/2;
		mover.y = H/2;
		mover.wanderRadius = Math.PI/4;
		mover.wanderDistance = 5;
		mover.wanderStep = 5;
		mover.maxSpeed = 7;
		bitmap = new Shadow();
		lazersFront = new flash.display.BitmapData(Game.W, Game.H, true, 0x00000000);
		lazersBack = new flash.display.BitmapData(Game.W, Game.H, true, 0x00000000);
		lazersFilter = new flash.filters.ColorMatrixFilter([
				1, 0, 0, 0,  0,
				0, 1, 0, 0,  0,
				0, 0, 1, 0,  0,
				0, 0, 0, 1, -20
		]);
		reset();
	}

	public function reset(){
		state = FLY;
		if (Game.level != null)
			mover.maxSpeed = Game.level.dogSpeed;
		gotoAndStop(1);
		if (lazers != null)
			endLazers();
	}

	public function getCollisionPos() : flash.geom.Point {
		return new flash.geom.Point(x-W/2, y-H/2);
	}

	public function getPos() : PVector {
		return new PVector(mover.x, mover.y);
	}

	public function setPos(nx,ny){
		x = nx;
		y = ny;
		mover.x = nx;
		mover.y = ny;
	}

	public function update(){
		timing += mt.Timer.deltaT * 1000;
		switch (state){
			case FLY:
				updateFly();
				if (mover.pos.distanceSquared(cast Game.getCursorPos()) < 120*120 && Std.int(Math.random() * 50) == 0){
					gotoAndStop(2);
					state = LAND;
				}

			case LAND:
				if (sub.currentFrame == sub.totalFrames){
					sub.stop();
					timing = 0;
					state = SHOOT;
				}

			case LAUNCH:
				if (sub.currentFrame == sub.totalFrames){
					sub.stop();
					gotoAndStop(1);
					state = FLY;
				}

			case SHOOT:
				if (lazers == null)
					initLazers();
				if (updateLazers()){
					endLazers();
					gotoAndStop(3);
					state = LAUNCH;
				}
		}
	}

	public function updateAnim(){
		switch (state){
			case LAND,LAUNCH:
				if (sub.currentFrame == sub.totalFrames)
					sub.stop();
			default:
		}
	}

	public function updateFly(){
		if (target != null && Game.getPixel(Math.round(target.x), Math.round(target.y)) != Colors.TO_CONQUER)
			target = null;
		if (target == null){
			var me = this;
			var targets = [];
			var getTarget = function( v ){
				var pos = me.mover.pos.clone();
				pos.add(v);
				if (Game.getPixel(Math.round(pos.x), Math.round(pos.y)) == Colors.TO_CONQUER)
					targets.push(pos);
			}
			getTarget({ x:0.0, y:-30 - 70*Math.random() });
			getTarget({ x:0.0, y:30 + 70*Math.random() });
			getTarget({ y:0.0, x:-30 - 70*Math.random() });
			getTarget({ y:0.0, x:30 + 70*Math.random() });
			getTarget({ x:-30 - 70*Math.random(), y:-30 - 70*Math.random() });
			getTarget({ x:-30 - 70*Math.random(), y:30 + 70*Math.random() });
			getTarget({ y:-30 - 70*Math.random(), x:30 + 70*Math.random() });
			getTarget({ y:30 + 70*Math.random(), x:30 + 70*Math.random() });
			target = targets[Std.random(targets.length)];
		}
		if (target != null){
			mover.maxSpeed = Game.level.dogSpeed * mt.Timer.tmod;
			mover.seek(target, 1);
			mover.update();
			var nx = Math.round(mover.x);
			var ny = Math.round(mover.y);
			if (Game.getPixel(nx, ny) != Colors.TO_CONQUER){
				mover.pos.set(mover.oldPos);
				target = null;
			}
			else if (mover.pos.distanceSquared(target) <= 100)
				target = null;
			x = Math.round(mover.x);
			y = Math.round(mover.y);
		}
	}

	function initLazers(){
		lazersBack.fillRect(lazersFront.rect, 0x00000000);
		lazersFront.fillRect(lazersFront.rect, 0x00000000);
		var yH = y-Game.level.dogLazerLength;
		var yL = y+Game.level.dogLazerLength;
		var xL = x-Game.level.dogLazerLength;
	    var xR = x+Game.level.dogLazerLength;
		lazers = [
			new QixLazer(x-20, y-30, xL, yH),
			new QixLazer(x+20, y-30, xR, yH),
			new QixLazer(x-20, y-8, xL, yL),
			new QixLazer(x+20, y-8, xR, yL),
		];
	}

	function updateLazers() : Bool {
		var complete = true;
				try {
		lazersFront.applyFilter(lazersFront, lazersFront.rect, new flash.geom.Point(0,0), lazersFilter);
		lazersBack.applyFilter(lazersFront, lazersFront.rect, new flash.geom.Point(0,0), lazersFilter);
		for (l in lazers){
			if (l.update()){
				complete = false;
				l.draw();
				var m = new flash.geom.Matrix();
				m.translate(l.x, l.y);
				if (l.ground.y > y)
					lazersFront.draw(l, m);
				else
					lazersBack.draw(l, m);
			}
		}
				}
				catch (e:Dynamic){
					trace(Std.string(e));
				}
		return complete;
	}

	function endLazers(){
		lazers = null;
	}
}