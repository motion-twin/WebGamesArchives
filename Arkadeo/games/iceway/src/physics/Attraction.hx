/**
 *  Copyright (c) 2011 Martin Lindelof
 *  contact martin.lindelof(at)gmail.com
 *  website www.martinlindelof.com
 */
package physics;

import physics.Particle;

class Attraction implements Force {

	var a : Particle;
	var b : Particle;
	
	var strength : Float; // k
	
	var minDistance : Float;
	var minDistanceSquared : Float;
	
	var on : Bool;
	
	public function new(a : Particle, b : Particle, strength : Float, minDistance : Float)
	{
		this.a = a;
		this.b = b;
		this.strength = strength;
		
		on = true;
		
		this.minDistance = minDistance;
		this.minDistanceSquared = minDistance*minDistance;
	}
	
	public function getMinimumDistance():Float
	{
		return minDistance;
	}
	
	public function setMinimumDistance(d : Float):Void
	{
		minDistance = d;
		minDistanceSquared = d*d;
	}
	
	public function turnOn():Void
	{
		on = true;
	}
	
	public function turnOff():Void
	{
		on = false;
	}
	
	public function isOn():Bool
	{
		return on;
	}
	
	public function isOff():Bool
	{
		return !on;
	}
	
	public function getStrength():Float
	{
		return strength;
	}
	
	public function setStrength(k : Float):Void
	{
		strength = k;
	}
	
	function setA(p : Particle):Void
	{
		a = p;
	}
	
	function setB(p : Particle):Void
	{
		b = p;
	}
	
	public function getOneEnd():Particle
	{
		return a;
	}
	
	public function getTheOtherEnd():Particle
	{
		return b;
	}
	
	public function apply():Void
	{
		if(on && (a.isFree() || b.isFree()))
		{
			var a2bX = a.position.x - b.position.x;
			var a2bY = a.position.y - b.position.y;
			var a2bZ = a.position.z - b.position.z;
			
			var a2bDistanceSquared = a2bX*a2bX + a2bY*a2bY + a2bZ*a2bZ;
			
			if(a2bDistanceSquared < minDistanceSquared)
				a2bDistanceSquared = minDistanceSquared;
			
			var force = strength * a.mass * b.mass / a2bDistanceSquared;
			
			var length = Math.sqrt(a2bDistanceSquared);
			
			a2bX /= length;
			a2bY /= length;
			a2bZ /= length;
			
			a2bX *= force;
			a2bY *= force;
			a2bZ *= force;
			
			if(a.isFree()) a.force.add3( -a2bX, -a2bY, -a2bZ );
			if(b.isFree()) b.force.add3(  a2bX, a2bY, a2bZ );
		}
	}

}
