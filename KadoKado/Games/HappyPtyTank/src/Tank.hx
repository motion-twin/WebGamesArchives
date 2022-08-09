import flash.display.MovieClip;
import flash.display.Sprite;

enum State {
	Normal;
	Hurt;
	Heal;
}

@:bind
class Tank extends MovieClip {
	public var ltracks : TankTracks;
	public var rtracks : TankTracks;
	public var canon : {>MovieClip, col3:MovieClip};
	public var target : Target;
	public var direction : Int;
	public var velocity : Float;
	public var speed : Float;
	public var angle : Float;
	public var rotationSpeed : Float;
	public var initCanonRot : Float;
	public var oldX : Float;
	public var oldY : Float;
	public var maxSpeed : Float;
	public var screenX : Float;
	public var screenY : Float;
	var col1 : MovieClip;
	var col2 : MovieClip;
	var bounds : WarZone;
	var state : State;
	var stateEnd : Float;

	public function new(){
		super();
		state = Normal;
		angle = 0.0;
		velocity = 0.0;
		speed = 0.0;
		rotationSpeed = 0.05 * (60/mt.Timer.wantedFPS);
		direction = 1;
		initCanonRot = canon.rotation;
		maxSpeed = 3.0 * (60/mt.Timer.wantedFPS);
		screenX = Config.W / 2;
		screenY = Config.H / 2;
		var color = Game.color.random();
		ColorSet.setColor(col1, color);
		ColorSet.setColor(col2, color);
		ColorSet.setColor(canon.col3, color);
		Config.addGroundShadow(this);
	}

	public function setBounds( w:WarZone ){
		bounds = w;
	}

	static var ANGLES : Array<Array<Null<Float>>>= [
		[ Math.PI*5/4, Math.PI*6/4, Math.PI*7/4, ],
		[ Math.PI,     null,        0 ],
		[ Math.PI*3/4, Math.PI*2/4, Math.PI*1/4 ],
	];
	static var oldVector = "";

	public function updateControls( up:Bool, down:Bool, left:Bool, right:Bool ){
		if (!up && !down && !left && !right){
			noway();
			return false;
		}
		direction = 1;
		var dx = 0;
		var dy = 0;
		if (up)
			dy = -1;
		if (down)
			dy = 1;
		if (left)
			dx = -1;
		if (right)
			dx = 1;

		var newVector = dx+":"+dy;
		if (oldVector != newVector){
			oldVector = newVector;
		}
		var oldAngle = angle;
		var destAngle = ANGLES[dy+1][dx+1];
		if (destAngle != null && destAngle != angle){
			angle = Geom.averageRadianAngle(oldAngle, destAngle);
			var diff = Geom.angleDiff(oldAngle, angle);
			if (diff <= 0.01){
				angle = destAngle;
			}
			else if (diff > Math.PI / 2){
				speed = 0.2 * (60/mt.Timer.wantedFPS);
			}
		}
		rotation = Geom.rad2deg(angle) - 180;
		speed = Math.min(maxSpeed, speed + 0.4 * (60/mt.Timer.wantedFPS) * mt.Timer.tmod);
		rtracks.forward();
		ltracks.forward();
		return true;
	}

	public function noway(){
		if (speed > 0)
			speed = Math.max(0.0, speed - mt.Timer.tmod * (60/mt.Timer.wantedFPS));
		rtracks.pause();
		ltracks.pause();
	}

	public function unmove(){
		x = oldX;
		y = oldY;
	}

	public function move(){
		oldX = x;
		oldY = y;
		if (speed > 0)
			Geom.moveAngle(this, angle, direction * speed * mt.Timer.tmod);
		if (bounds != null && bounds.isOutOfZone(this))
			bounds.recall(this);
		canon.rotation = Geom.angleDeg({x:screenX, y:screenY}, target) - initCanonRot - rotation - 180;
		rtracks.update();
		ltracks.update();
	}

	public function setState( st ){
		state = st;
		switch (state){
			case Normal:
				transform.colorTransform = new flash.geom.ColorTransform(1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0);
			case Hurt:
				stateEnd = Game.instance.now + 250;
				transform.colorTransform = new flash.geom.ColorTransform(1.0, 1.0, 1.0, 1.0, 1000.0);
			case Heal:
				stateEnd = Game.instance.now + 250;
				transform.colorTransform = new flash.geom.ColorTransform(1.0, 1.0, 1.0, 1.0, 1.0, 1000.0, 1.0, 1.0);
		}
	}

	public function update(){
		switch (state){
			case Normal:
			case Hurt,Heal:
				if (stateEnd <= Game.instance.now)
					setState(Normal);
		}
	}

	public function getAimAngle(){
		return Geom.angleDeg({x:screenX, y:screenY}, target) - initCanonRot;
	}
}

@:bind
class TankTracks extends MovieClip {
	var d : Int;

	public function new(){
		super();
		stop();
		d = 0;
	}

	public function pause(){
		d = 0;
	}

	public function forward(){
		d = 1;
	}

	public function backward(){
		d = -1;
	}

	public function update(){
		var f = currentFrame + d;
		if (f <= 0)
			f = totalFrames;
		else if (f > totalFrames)
			f = 1;
		gotoAndStop(f);
	}
}