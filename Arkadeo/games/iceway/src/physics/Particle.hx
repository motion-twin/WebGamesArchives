/**
 *  Copyright (c) 2011 Martin Lindelof
 *  contact martin.lindelof(at)gmail.com
 *  website www.martinlindelof.com
 */
package physics;

import mt.kiroukou.math.Vec3;
class Particle
{
	public var position : Vec3;
	public var velocity : Vec3;
	
	public var force : Vec3;
	public var mass : Float;
	public var age : Float;
	public var fixed : Bool;
	
	var dead : Bool;
	
	public var properties(default, null):List<physics.ParticleProperty>;
	
	//used to store whatever the user needs !
	public var data : Dynamic;
	
	public function new(mass : Float, ?position : {x:Float, y:Float, ?z:Float} ) : Void
	{
		this.mass = mass;
		this.position = new Vec3( position.x, position.y, position.z );
		
		velocity = new Vec3();
		force = new Vec3();
		fixed = false;
		age = 0;
		dead = false;
		properties = new List();
	}
	
	public function distanceTo(p : Particle) : Float
	{
		return Vec3.distance( this.position, p.position );
	}
	
	public function makeFixed() : Void
	{
		fixed = true;
		velocity.x = 0.;
		velocity.y = 0.;
		velocity.z = 0.;
	}
	
	public function makeFree() : Void
	{
		fixed = false;
	}
	
	public function isFixed() : Bool
	{
		return fixed;
	}
	
	public function isFree() : Bool
	{
		return !fixed;
	}
	
	public function makeDead() : Void
	{
		dead = true;
	}
	
	public function isDead() : Bool
	{
		return dead;
	}
	
	public function setMass(m : Float) : Void
	{
		mass = m;
	}
	
	public function reset() : Void
	{
		age = 0;
		dead = false;
		position.x = 0; position.y = 0; position.z = 0;
		velocity.x = 0; velocity.y = 0; velocity.z = 0;
		force.x = 0; force.y = 0; force.z = 0;
		mass = 1;
	}
	
	function invalidate()
	{
		for( p in properties )
			p.invalidate();
	}
	
	public function toString() : String
	{
		return("[object Particle]\tm:" + mass + " [" + position.x + ", " + position.y + ", " + position.z +"]");
	}

}
