/**
 *  Copyright (c) 2011 Martin Lindelof
 *  contact martin.lindelof(at)gmail.com
 *  website www.martinlindelof.com
 */
package physics;

import physics.Attraction;
import physics.Force;
import physics.Integrator;
import physics.Particle;
import physics.Spring;

import mt.kiroukou.math.Vec3;
enum SystemIntegrator
{
	RUNGE_KUTTA;
	EULER;
}

using Lambda;
class ParticleSystem {
	
	var integrator : Integrator;
	
	public var gravity : Vec3;
	public var drag : Float;
	
	public var particles : Array<Particle>; // TODO: getters
	public var springs : Array<Spring>;
	public var attractions : Array<Attraction>;
	public var custom : Array<Force>;

	
	public function new(?gravity : { x:Float, y:Float, ?z:Float }, drag : Float = 0.001) : Void
	{
		integrator = new RungeKuttaIntegrator(this);
		
		particles = new Array();
		springs = new Array();
		attractions = new Array();
		custom = new Array();
		
		this.gravity = 	if( gravity != null ) new Vec3(gravity.x, gravity.y, (gravity.z != null)? gravity.z : 0 );
						else new Vec3();
		this.drag = drag;
	}
	
	public function setIntegrator(integrator : SystemIntegrator)
	{
		switch(integrator)
		{
			case RUNGE_KUTTA:
				this.integrator = new RungeKuttaIntegrator(this);
			case EULER:
				this.integrator = new ModifiedEulerIntegrator(this);
		}
	}
	
	public function setGravity(gravity : Vec3) : Void
	{
		this.gravity = gravity;
	}
	
	public function setDrag(d : Float) : Void
	{
        this.drag = d;
	}
	
	public function tick(t : Float = 1.) : Void
	{
        integrator.step(t);
		var deads = [];
		for( p in particles )
			if( p.isDead() )
				deads.push(p);
		for( p in deads )
			removeParticleByReference(p);
	}
	
	public function makeParticle(mass : Float = 1., ?position : { x:Float, y:Float, ?z:Float }) : Particle
	{
		var p = new Particle(mass, new Vec3( position.x, position.y, position.z != null ? position.z : 0.) );
		particles.push(p);
		return p;
	}
	
	public function makeSpring(a : Particle, b : Particle, springConstant : Float, damping : Float, restLength : Float) : Spring
	{
		var s = new Spring(a, b, springConstant, damping, restLength);
		springs.push(s);
		return s;
	}
	
	public function makeAttraction(a : Particle, b : Particle, strength : Float, minDistance : Float) : Attraction
	{
		var m = new Attraction(a, b, strength, minDistance);
		attractions.push(m);
		return m;
	}
	
	public function clear() : Void
	{
		var i : Int;
		for(i in 0...particles.length) 		particles[i] = null;
		for(i in 0...springs.length) 		springs[i] = null;
		for(i in 0...attractions.length) 	attractions[i] = null;
		
		particles = new Array<Particle>();
		springs = new Array<Spring>();
		attractions = new Array<Attraction>();
	}
	
	public function applyForces() : Void
	{
		if(gravity.x != 0 || gravity.y != 0 || gravity.x != 0) // not gravity.z ?
		{
			for( p in particles )
				Vec3.add( p.force, gravity, p.force );
		}
		
		for( p in particles )
		{
			var vdrag = p.velocity.clone().scale(-drag);
			Vec3.add( p.force, vdrag, p.force );
			
			for( pp in p.properties )
				pp.apply();
		}
		
		for(s in springs ) s.apply();
		for(a in attractions) a.apply();
		for(f in custom) f.apply();

	}
	
	public function clearForces() : Void
	{
		for( p in particles )
		{
			p.force.x = 0;
			p.force.y = 0;
			p.force.z = 0;
		}
	}
	
	public function numberOfParticles() : Int
	{
		return particles.length;
	}
	
	public function numberOfSprings() : Int
	{
		return springs.length;
	}
	
	public function numberOfAttractions() : Int
	{
		return attractions.length;
	}
	
	public function getParticle(i : Int) : Particle
	{
		return particles[i];
	}
	
	public function getSpring(i : Int) : Spring
	{
		return springs[i];
	}
	
	public function getAttraction(i : Int) : Attraction
	{
		return attractions[i];
	}
	
	public function addCustomForce(f : Force) : Void
	{
		custom.push(f);
	}
	
	public function numberOfCustomForces() : Int
	{
		return custom.length;
	}
	
	public function getCustomForce(i : Int) : Force
	{
		return custom[i];
	}
	
	public function removeCustomForce(i : Int) : Void
	{
		custom[i] = null;
		custom.splice(i, 1);
	}
	
	public function removeCustomForceByReference(f : Force) : Bool
	{
		var n = custom.indexOf( f );
		if(n != -1)
		{
			custom[n] = null;
			custom.splice(n, 1);
			return true;
		}
		return false;
	}
	
	public function removeSpring(i : Int) : Void
	{
	   springs[i] = null;
	   springs.splice(i, 1);
	}
	
	public function removeSpringByReference(s : Spring) : Bool
	{
		var n = springs.indexOf( s );
		if(n != -1)
		{
			springs[n] = null;
			springs.splice(n, 1);
			return true;
		}
		return false;
	}
	
	public function removeAttraction(i : Int) : Void
	{
		attractions[i] = null;
		attractions.splice(i, 1);
	}
	
	public function removeAttractionByReference(a : Attraction) : Bool
	{
		var n = attractions.indexOf( a ) ;
		if(n != -1)
		{
			attractions[n] = null;
			attractions.splice(n, 1);
			return true;
		}
		return false;
	}
	
	public function removeParticle(i : Int) : Void
	{
		particles[i] = null;
		particles.splice(i, 1);
	}
	
	public function removeParticleByReference(p : Particle) : Bool
	{
		var n = particles.indexOf( p );
		if(n != -1)
		{
			particles[n] = null;
			particles.splice(n, 1);
			return true;
		}
		return false;
	}
}
