package geom;

class Mover3D {
	public var mass : Float;
	public var oldPosition : PVector3D;
	public var position : PVector3D;
	public var steering : PVector3D;
	public var acceleration : PVector3D;
	public var velocity : PVector3D;
	public var friction : Float;
	public var gravity : Float;
	public var frictionFactor : Null<Float>;
	public var maxSpeed(default,setMaxSpeed) : Float;
	var maxSpeedSquared : Float;
	function setMaxSpeed( s:Float ) : Float {
		maxSpeed = s;
		maxSpeedSquared = s * s;
		return maxSpeed;
	}
	public var maxForce(default,setMaxForce) : Float;
	var maxForceSquared : Float;
	function setMaxForce( s:Float ) : Float {
		maxForce = s;
		maxForceSquared = s * s;
		return maxForce;
	}
	public var x(getX,setX) : Float;
	function getX() : Float { return position.x; }
	function setX(v:Float) : Float { return (position.x = v); }
	public var y(getY,setY) : Float;
	function getY() : Float { return position.y; }
	function setY(v:Float) : Float { return (position.y = v); }
	public var z(getZ,setZ) : Float;
	function getZ() : Float { return position.z; }
	function setZ(v:Float) : Float { return (position.z = v); }

	public function new(mass:Float, maxSpeed:Float, maxForce:Float){
		this.mass = mass;
		setMaxSpeed(maxSpeed);
		setMaxForce(maxForce);
		position = new PVector3D();
		oldPosition = new PVector3D();
		steering = new PVector3D();
		acceleration = new PVector3D();
		velocity = new PVector3D();
	}

	public function stop(){
		steering.set(PVector3D.ORIGIN);
		velocity.set(PVector3D.ORIGIN);
	}

	public function update(){
		oldPosition.set(position);
		var steeringForce = steering.clone();
		if (steeringForce.lengthSquared() > maxForceSquared)
			steeringForce.limit(maxForce);
		acceleration.set(steeringForce);
		if (mass != 0)
			acceleration.div(mass);
		velocity.add(acceleration);
		if (frictionFactor != null)
			velocity.mult(frictionFactor);
		if (velocity.lengthSquared() > maxSpeedSquared)
			velocity.limit(maxSpeed);
		position.add(velocity);
	}

	public function seek(p:Pt3D, ?multiplier:Float=1.0 ){
		steering.set(p);
		steering.sub(position);
		var l = steering.normalize();
		steering.mult(Math.min(maxSpeed,l));
		steering.sub(velocity);
		if (multiplier != 1.0)
			steering.mult(multiplier);
	}

	public function toString() : String {
		return position.toString();
	}
}