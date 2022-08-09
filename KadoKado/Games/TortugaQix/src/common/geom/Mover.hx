package geom;

class Mover {
	public var pos : PVector;
	public var oldPos : PVector;
	// movements
	public var acceleration : PVector;
	public var velocity : PVector;
	public var maxSpeed(default,setMaxSpeed) : Float;
	var maxSpeedSquared : Float;
	// extended movements
	public var frictionFactor : Null<Float>; // Factor applyed to the velocity at each update
	public var mass : Null<Float>; // object mass : when specified, the steering is divided by this mass to determine the acceleration
	// steering
	public var steering : PVector;
	public var maxForce(default,setMaxForce) : Float;
	var maxForceSquared : Float;
	// wandering stuff
	var wanderDelta : Float;
	public var wanderRadius : Float;
	public var wanderDistance : Float;
	public var wanderStep : Float;
	public var x(getX,setX) : Float;
	public var y(getY,setY) : Float;
	function getX() : Float { return pos.x; }
	function setX(v:Float) : Float { return pos.x = v; }
	function getY() : Float { return pos.y; }
	function setY(v:Float) : Float { return pos.y = v; }

	public function new(maxForce=1.0, maxSpeed=10.0){
		this.setMaxForce(maxForce);
		this.setMaxSpeed(maxSpeed);
		reset();
	}

	public function reset(){
		mass = null;
		frictionFactor = null;
		wanderDelta = 0.0;
		wanderRadius = 16.0;
		wanderDistance = 60.0;
		wanderStep = 0.25;
		pos = new PVector();
		oldPos = new PVector();
		velocity = new PVector();
		acceleration = new PVector();
		steering = new PVector();
	}

	function setMaxSpeed( s:Float ) : Float {
		maxSpeed = s;
		maxSpeedSquared = s * s;
		return maxSpeed;
	}

	function setMaxForce( s:Float ) : Float {
		maxForce = s;
		maxForceSquared = s * s;
		return maxForce;
	}

	public function update() : Bool {
		oldPos.set(pos);
		if (mass != null){
			acceleration.set(steering);
			acceleration.div(mass);
		}
		velocity.add(acceleration);
		if (frictionFactor != null)
			velocity.mult(frictionFactor);
		if (velocity.lengthSquared() > maxSpeedSquared){
			velocity.normalize();
			velocity.mult(maxSpeed);
		}
		pos.add(velocity);
		if (mass == null){
			acceleration.x = 0;
			acceleration.y = 0;
		}
		return true;
	}

	public function rotation() : Float {
		return velocity.angle();
	}

	public function seek( target:Pt, ?multiplier:Float=1.0 ){
		steering = steer(target);
		if (multiplier != 1.0)
			steering.mult(multiplier);
		acceleration.add(steering);
	}

	public function arrive( target:Pt, ?easeDistance:Float=100.0, ?multiplier:Float=1.0 ){
		steering = steer(target, true, easeDistance);
		if (multiplier != 1.0)
			steering.mult(multiplier);
		acceleration.add(steering);
	}

	public function flee( target:Pt, ?panicDistance:Float=100.0, ?multiplier:Float=1.0 ){
		var distance = pos.distance(target);
		if (distance > panicDistance)
			return;
		steering = steer(target, true, -panicDistance);
		if (multiplier != 1.0)
			steering.mult(multiplier);
		steering.negate();
		acceleration.add(steering);
	}

	public function wander( ?multiplier:Float=1.0 ){
		wanderDelta += Math.random() * wanderStep;
		if (Math.random() < 0.5)
			wanderDelta = -wanderDelta;
		var p = velocity.clone();
		p.normalize();
		p.mult(wanderDistance);
		p.add(pos);
		var off = new PVector();
		off.x = wanderRadius * Math.cos(wanderDelta);
		off.y = wanderRadius * Math.sin(wanderDelta);
		p.add(off);
		steering = steer(p);
		if (multiplier != 1.0)
			steering.mult(multiplier);
		acceleration.add(steering);
	}

	function steer( target:Pt, ?ease:Bool=false, ?easeDist:Float=100.0 ) : PVector {
		steering.set(target);
		steering.sub(pos);
		var distance = steering.normalize();
		if (distance > 0.00001){
			if (ease && distance < easeDist){
				steering.mult(maxSpeed * (distance/easeDist));
			}
			else
				steering.mult(maxSpeed);
			steering.sub(velocity);
			if (steering.lengthSquared() > maxForceSquared){
				steering.normalize();
				steering.mult(maxForce);
			}
		}
		return steering;
	}
}