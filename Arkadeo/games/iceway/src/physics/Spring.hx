/**
 *  Copyright (c) 2011 Martin Lindelof
 *  contact martin.lindelof(at)gmail.com
 *  website www.martinlindelof.com
 */
package physics;

import physics.Particle;
import mt.kiroukou.math.Vec3;

class Spring {

	var a : Particle;
	var b : Particle;
	
	var springConstant : Float; // ks
	
	var damping : Float;
	var restLength : Float;
	
	var on : Bool;
	
	public function new(a : Particle, b : Particle, springConstant : Float, damping : Float, restLength : Float) : Void
	{
		this.a = a;
		this.b = b;
		this.springConstant = springConstant;
		this.damping = damping;
		this.restLength = restLength;
		on = true;
	}
	
	public function turnOn() : Void
	{
		on = true;
	}
	
	public function turnOff() : Void
	{
		on = false;
	}
	
	public function isOn() : Bool
	{
		return on;
	}
	
	public function isOff() : Bool
	{
		return !on;
	}
	
	public function currentLength() : Float
	{
		return Vec3.distance(a.position, b.position);
	}
	
	public function getStrength() : Float
	{
		return springConstant;
	}
	
	public function setStrength(ks : Float) : Void
	{
		springConstant = ks;
	}
	
	public function getDamping() : Float
	{
		return damping;
	}
	
	public function setDamping(d : Float) : Void
	{
		damping = d;
	}
	
	public function getRestLength() : Float
	{
		return restLength;
	}
	
	public function setRestLength(l : Float) : Void
	{
		restLength = l;
	}
	
	function setA(p : Particle) : Void
	{
		a = p;
	}
	
	function setB(p : Particle) : Void
	{
		b = p;
	}
	
	public function getOneEnd() : Particle
	{
		return a;
	}
	
	public function getTheOtherEnd() : Particle
	{
		return b;
	}
	
	public function apply() : Void
	{
		if(on && (a.isFree() || b.isFree()))
		{
			var ab = new Vec3();
			Vec3.sub( a.position, b.position, ab );
			var d = ab.length();
			ab.normalize();
			
			var springForce = -(d - restLength) * springConstant;
			
			var abvel = new Vec3();
			Vec3.sub( a.velocity, b.velocity, abvel );
			
			var dampingForce = -damping * (ab.x * abvel.x + ab.y * abvel.y + ab.z * abvel.z);
			ab.scale(springForce + dampingForce);
			
			if(a.isFree()) Vec3.add( a.force, ab, a.force );
			if(b.isFree()) Vec3.add( b.force, ab.flip(), b.force );
		}
	}
}
