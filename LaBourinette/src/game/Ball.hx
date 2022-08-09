package game;

import Stat;
import game.Event;
import geom.PVector3D;
import geom.PVector;
import game.Geom;

class Ball extends geom.Mover3D {
	public static inline var AIR_MAX_SPEED = 8.7;
	public static inline var AIR_FRICTION = 0.98;
	//public static inline var AIR_MAX_SPEED = 4.3;
	//public static inline var AIR_FRICTION = 0.49;
	static inline var GROUND_MAX_SPEED = 0.2;
	// public static inline var AIR_FRICTION = 0.98;
	public static inline var GROUND_FRICTION = 0.70;
	public static inline var GRAVITY = 9.80665;
	public static var GRAVITY_V = new PVector3D(0.0, 0.0, -GRAVITY);

	public var resolver : game.Resolver;
	public var owner : game.PlayerData;
	public var alive : Bool;
	var groundHit : PVector3D;
	public var firstGroundHit : PVector3D;
	public var landing : PVector3D; // end of ball fly, when it will won't move anymore
	public var middleCourse : PVector3D; // avg between first ground hit and final landing
	public var isFlying : Bool;
	public var stuntTurns : Int;
	public var fx : ThrowFx;
	// used by viewer
	public var positionReset : Bool;
	public var pass : { from:PlayerData, to:PlayerData };

	public function new( resolver:Resolver ){
		super(1.0, AIR_MAX_SPEED, 1.0);
		this.resolver = resolver;
		x = 20;
		y = 0;
		frictionFactor = GROUND_FRICTION;
		alive = false;
		isFlying = false;
		stuntTurns = 0;
		positionReset = false;
	}

	public function getPoint() : Point {
		return new Point(x, y);
	}

	public function catchOrKillDifficulty() : Float {
		if (velocity == null)
			return Dice.EASY_FACTOR;
		if (velocity.length() <= 2)
			return Dice.MEDIUM_FACTOR;
		return Dice.HARD_FACTOR;
	}

	public function kick(groundAngle:Float, airRatio:Float, power:Float){
		fx = null;
		maxForce = 1;
		isFlying = true;
		maxSpeed = AIR_MAX_SPEED;
		var p = new PVector(1.0, 0.0).rotate(groundAngle);
		var z = new PVector(1.0, 0.0).rotate(airRatio * Math.PI/2);
		var v = { x:p.x*airRatio, y:p.y*airRatio, z:z.x };
		power = power * maxSpeed * 2 / 100;
		velocity.set(v);
		velocity.normalize();
		velocity.mult(power);
		oldPosition.set(position);
		var oldV = velocity.clone();
		var oldP = position.clone();
		groundHit = null;
		firstGroundHit = null;
		var step = 0;
		do {
			update();
			if (firstGroundHit == null && groundHit != null)
				firstGroundHit = groundHit;
		}
		while (!velocity.isNull());
		landing = position.clone();
		middleCourse = landing.clone().add(firstGroundHit).div(2);
		position.set(oldP);
		oldPosition.set(position);
		velocity.set(oldV);
		isFlying = true;
		maxSpeed = AIR_MAX_SPEED;
	}

	public function takenBy( player:PlayerData ){
		if (player != null)
			resolver.event(HasPicoron(player));
		if (pass != null){
			if (pass.to == player)
				pass.from.stats.success(DefPass);
			pass = null;
		}
		owner = player;
		x = player.x;
		y = player.y;
		z = 0;
		stuntTurns = 0;
		velocity.set(PVector3D.ORIGIN);
		isFlying = false;
		maxSpeed = GROUND_MAX_SPEED;
	}

	public var perProduct : geom.PVector;

	public function throwAt( dest:PVector3D, power:Float, ?tk:ThrowKind ){
		if (tk != null)
			switch (tk){
				case SpeedThrow:
					power = power * 1.5 * AIR_MAX_SPEED / 100;
					power = Math.max(power, 10);
				default:
			}
		owner = null;
		pass = null;
		z = 1;
		oldPosition.set(position);
		velocity = new PVector3D(dest.x - x, dest.y -y);
		velocity.normalize();
		velocity.mult(power);
		isFlying = true;
		maxSpeed = AIR_MAX_SPEED;
		perProduct = null;
		if (tk != null){
			var moveSeg = new geom.Vector2D(
				{x:position.x, y:position.y},
				{x:dest.x, y:dest.y}
			);
			var zoneSeg = new geom.Vector2D(
				game.Field.RECEPTION_ZONE[0],
				game.Field.RECEPTION_ZONE[1]
			);
			perProduct = geom.Vector2D.perProduct(moveSeg, zoneSeg);
			if (resolver.debug()){
				trace("Power = "+tools.MyStringTools.doubleToHex(power));
				trace("Position = "+position.toHex());
				trace("Destination = "+dest.toHex());
				if (perProduct != null)
					trace("Per product = "+perProduct.toHex());
			}
		}
		fx = getFx(tk, (perProduct != null) ? new PVector3D(perProduct.x, perProduct.y) : dest, power);
	}

	function getFx(tk, dest, power){
		if (tk == null)
			return null;
		return switch (tk){
			case PowerThrow: cast new PowerThrowFx(this, power, dest);
			case SpeedThrow: cast new SpeedThrowFx(this, power, dest);
			case CurveThrow: cast new CurveThrowFx(this, power, dest);
		}
	}

	public function nextPositions( nturns:Int ) : Array<PVector3D> {
		if (velocity == null)
			return [position.clone()];
		var oldP = position.clone();
		var velP = velocity.clone();
		var r = [];
		for (n in 0...nturns){
			update();
			r.push(position.clone());
		}
		position.set(oldP);
		velocity.set(velP);
		return r;
	}

	public function superUpdate(){
		super.update();
	}

	override function stop(){
		fx = null;
		maxForce = 1;
		super.stop();
	}

	override public function update(){
		if (stuntTurns > 0)
			stuntTurns--;
		if (owner != null){
			position.z = 0;
			position.x = owner.x;
			position.y = owner.y;
			velocity.set(PVector3D.ORIGIN);
			isFlying = false;
		}
		else if (isFlying) {
			if (position.z > 0){
				frictionFactor = AIR_FRICTION;
				steering.set(GRAVITY_V);
			}
			else {
				frictionFactor = GROUND_FRICTION;
				steering.set(PVector3D.ORIGIN);
			}
			if (fx != null)
				fx.update();
			else
				super.update();
			// ground collision
			if (oldPosition.z > 0 && position.z <= 0){
				// ground is at z 0, it is easy to find the collision point
				var dampling = 0.8;
				var ratio = (velocity.z - position.z) / velocity.z;
				var colVector = velocity.clone();
				colVector.mult(1-ratio);
				position.sub(colVector);
				groundHit = position.clone();
				colVector.mult(dampling);
				colVector.z *= -1;
				position.add(colVector); // add remaining of vector
				velocity.z *= -1;
				velocity.z *= dampling;
				if (velocity.z < GRAVITY/(mass*2)){
					velocity.z = 0;
					position.z = 0;
				}
			}
			if (position.z < 0){
				position.z = 0;
				velocity.z = 0;
				groundHit = position.clone();
			}
			if (velocity.lengthSquared() < 0.0001){
				velocity.set(PVector3D.ORIGIN);
				isFlying = false;
				maxSpeed = GROUND_MAX_SPEED;
			}
		}
		else if (stuntTurns <= 0){
			// the picoron is free... what is it going to do :)
			/* Keep distance from other players */
			var minidist = 20;
			var vect = new PVector3D();
			for (p in resolver.field.players)
				if (position.distanceSquared(p.position) < (minidist*minidist)*((p.getAttractPicoronFactor()+2)*(p.getAttractPicoronFactor()+2)))
					vect.add(p.position.clone().sub(position).mult(p.getAttractPicoronFactor()));
			steering.set(vect);
			/* Stay inside field (as much as possible) */
			var angle = Math.atan2(y, x);
			if (position.distanceSquared(PVector3D.ORIGIN) >= 90*90){
				var vect = new PVector3D(1.0, 0.0, 0.0);
				vect.rotateZ(angle - Math.PI);
				steering.add(vect);
			}
			if (angle < (-Math.PI/4) + Math.PI/8){
				steering.add({ x:1.0, y:1.0, z:0.0 });
			}
			else if (angle > (Math.PI/4) - Math.PI/8){
				steering.add({ x:1.0, y:-1.0, z:0.0 });
			}
			super.update();
			// avoid players
			// do not leave the field
		}
	}
}

class ThrowFx {
	var origin : PVector3D;
	var target : PVector3D;
	var delta : PVector3D;
	var dist : Float;
	var ball : Ball;
	public function new( b:Ball, p:Float, t:PVector3D ){
		ball = b;
		origin = b.position;
		target = t;
		delta = target.clone().sub(origin);
		dist = delta.length();
	}
	public function update(){
		ball.superUpdate();
	}
}

class SpeedThrowFx extends ThrowFx {
	public function new(b:Ball, pow:Float, t:PVector3D){
		super(b,pow,t);
	}
	override function update(){
		ball.oldPosition.set(ball.position);
		ball.position.add(ball.velocity);
	}
}

class PowerThrowFx extends ThrowFx {
}

class CurveThrowFx extends ThrowFx {
	var pt1 : PVector3D;
	var pt2 : PVector3D;

	public function new(b:Ball, pow:Float, t:PVector3D){
		super(b,pow,t);
		pt1 = delta.clone().div(3);
		pt2 = delta.clone().mult(0.9).add(origin);
		var angleL = pt1.angleZ();
		pt1.rotateZ(-angleL);
		var n = 5.0;
		var limit = 0.8;
		n = n - b.resolver.random()*n*2;
		if (n >= 0 && n < limit)
			n = limit;
		if (n <= 0 && n > -limit)
			n = -limit;
		pt1.y += n;
		pt1.rotateZ(angleL);
		pt1.add(origin);
		b.velocity = new PVector3D(pt1.x-origin.x, pt1.y-origin.y);
		b.velocity.normalize();
		b.velocity.mult(pow);
		b.maxSpeed = Ball.AIR_MAX_SPEED;
	}

	override function update(){
		if (ball.position.x <= pt1.x && ball.position.x >= pt2.x){
			ball.maxForce = 3;
			ball.seek(target, 4);
		}
		ball.superUpdate();
		if (ball.position.x <= target.x){
			ball.position.set(target);
		}
		else if (ball.oldPosition.x > pt2.x && ball.position.x < pt2.x){
			ball.position.set(target);
		}
		else if (ball.position.x <= pt2.x){
			ball.maxForce = 1;
			var speed = ball.velocity.length();
			ball.velocity = new PVector3D(target.x - ball.x, target.y - ball.y);
			ball.velocity.normalize();
			ball.velocity.mult(speed);
			ball.fx = null;
		}
		if (ball.position.equals(target)){
			ball.maxForce = 1;
			ball.velocity.limit(0.1);
			ball.fx = null;
		}
	}
}
