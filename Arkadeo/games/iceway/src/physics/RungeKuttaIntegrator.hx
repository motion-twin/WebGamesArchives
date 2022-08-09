/**
 *  Copyright (c) 2011 Martin Lindelof
 *  contact martin.lindelof(at)gmail.com
 *  website www.martinlindelof.com
 */
package physics;

import physics.Particle;
import physics.ParticleSystem;
import mt.kiroukou.math.Vec3;

class RungeKuttaIntegrator implements Integrator {

	var s : ParticleSystem;
	
	var originalPositions : Array<Vec3>;
	var originalVelocities : Array<Vec3>;
	var k1Forces : Array<Vec3>;
	var k1Velocities : Array<Vec3>;
	var k2Forces : Array<Vec3>;
	var k2Velocities : Array<Vec3>;
	var k3Forces : Array<Vec3>;
	var k3Velocities : Array<Vec3>;
	var k4Forces : Array<Vec3>;
	var k4Velocities : Array<Vec3>;
	
	public function new(s : ParticleSystem) : Void
	{
		this.s = s;
		
		originalPositions = new Array();
		originalVelocities = new Array();
		k1Forces = new Array();
		k1Velocities = new Array();
		k2Forces = new Array();
		k2Velocities = new Array();
		k3Forces = new Array();
		k3Velocities = new Array();
		k4Forces = new Array();
		k4Velocities = new Array();
	}
	
	function allocateParticles() : Void
	{
		while(s.particles.length > originalPositions.length)
		{
			originalPositions.push( new Vec3() );
			originalVelocities.push( new Vec3() );
			k1Forces.push( new Vec3() );
			k1Velocities.push(new Vec3());
			k2Forces.push( new Vec3() );
			k2Velocities.push( new Vec3() );
			k3Forces.push( new Vec3() );
			k3Velocities.push( new Vec3() );
			k4Forces.push( new Vec3() );
			k4Velocities.push( new Vec3() );
		}
	}
	
	
	var particles : Array<Particle>;
    var p : Particle;
    var originalPosition : Vec3;
    var originalVelocity : Vec3;

    var k1Velocity : Vec3;
    var k2Velocity : Vec3;
    var k3Velocity : Vec3;
    var k4Velocity : Vec3;

    var k1Force : Vec3;
    var k2Force : Vec3;
    var k3Force : Vec3;
    var k4Force : Vec3;
	
	public function step(t : Float) : Void
	{
		particles = s.particles;
		// k1: save original, apply forces, result is k1
		
		for(i in 0...particles.length)
		{
			p = particles[i];
			if(!p.fixed)
			{
				originalPositions[i] = p.position.clone();
				originalVelocities[i] = p.velocity.clone();
			}
			p.force.x = 0;
			p.force.y = 0;
			p.force.z = 0;
			// clear;
		}
		
		s.applyForces();
		
		for(i in 0...particles.length)
		{
			p = particles[i];
			if(!p.fixed)
			{
				k1Forces[i] = p.force.clone();
				k1Velocities[i] = p.velocity.clone();
			}
			p.force.x = 0;
			p.force.y = 0;
			p.force.z = 0;
		}

		// k2 : use k1, apply forces, result is k2
		for(i in 0...particles.length)
		{
			p = particles[i];
			if(!p.fixed)
			{
				originalPosition = originalPositions[i];
				k1Velocity = k1Velocities[i];
				
				p.position.x = originalPosition.x + k1Velocity.x * 0.5 * t; // TODO: rewrite with vector op? add() scaleBy()É
				p.position.y = originalPosition.y + k1Velocity.y * 0.5 * t;
				p.position.z = originalPosition.z + k1Velocity.z * 0.5 * t;
				
				originalVelocity = originalVelocities[i];
				k1Force = k1Forces[i];
				
				p.velocity.x = originalVelocity.x + k1Force.x * 0.5 * t / p.mass;
				p.velocity.y = originalVelocity.y + k1Force.y * 0.5 * t / p.mass;
				p.velocity.z = originalVelocity.z + k1Force.z * 0.5 * t / p.mass;
			}
		}
		
		s.applyForces();
		
		for(i in 0...particles.length)
		{
			p = particles[i];
			if(!p.fixed)
			{
				k2Forces[i] = p.force.clone();
				k2Velocities[i] = p.velocity.clone();
			}
			p.force.x = 0;
			p.force.y = 0;
			p.force.z = 0;
		}
		
		// k3 : use k2, apply forces, result is k3
		
		for(i in 0...particles.length)
		{
			p = particles[i];
			if(!p.fixed)
			{
				originalPosition = originalPositions[i];
				k2Velocity = k2Velocities[i];
				
				p.position.x = originalPosition.x + k2Velocity.x * 0.5 * t; // TODO: rewrite with vector op? add() scaleBy()É
				p.position.y = originalPosition.y + k2Velocity.y * 0.5 * t;
				p.position.z = originalPosition.z + k2Velocity.z * 0.5 * t;
				
				originalVelocity = originalVelocities[i];
				k2Force = k2Forces[i];
				
				p.velocity.x = originalVelocity.x + k2Force.x * 0.5 * t / p.mass;
				p.velocity.y = originalVelocity.y + k2Force.y * 0.5 * t / p.mass;
				p.velocity.z = originalVelocity.z + k2Force.z * 0.5 * t / p.mass;
			}
		}
		
		s.applyForces();
		
		for(i in 0...particles.length)
		{
			p = particles[i];
			if(!p.fixed)
			{
				k3Forces[i] = p.force.clone();
				k3Velocities[i] = p.velocity.clone();
			}
			p.force.x = 0;
			p.force.y = 0;
			p.force.z = 0;
		}
		
		// k4 : use k3, apply forces, result is k4
		
		for(i in 0...particles.length)
		{
			p = particles[i];
			if(!p.fixed)
			{
				originalPosition = originalPositions[i];
				k3Velocity = k3Velocities[i];
				
				p.position.x = originalPosition.x + k3Velocity.x * 0.5 * t; // TODO: rewrite with vector op? add() scaleBy()É
				p.position.y = originalPosition.y + k3Velocity.y * 0.5 * t;
				p.position.z = originalPosition.z + k3Velocity.z * 0.5 * t;
				
				originalVelocity = originalVelocities[i];
				k3Force = k3Forces[i];
				
				p.velocity.x = originalVelocity.x + k3Force.x * 0.5 * t / p.mass;
				p.velocity.y = originalVelocity.y + k3Force.y * 0.5 * t / p.mass;
				p.velocity.z = originalVelocity.z + k3Force.z * 0.5 * t / p.mass;
			}
		}
		
		s.applyForces();
		
		for(i in 0...particles.length)
		{
			p = particles[i];
			if(!p.fixed)
			{
				k4Forces[i] = p.force.clone();
				k4Velocities[i] = p.velocity.clone();
			}
			p.force.x = 0;
			p.force.y = 0;
			p.force.z = 0;
		}
		
		// update position and velocity
		// based on intermediate forces
		
		for(i in 0...particles.length)
		{
			p = particles[i];
			p.age += t;
			
			if(!p.fixed)
			{
				// position
				originalPosition	= originalPositions[i];
				k1Velocity			= k1Velocities[i];
				k2Velocity			= k2Velocities[i];
				k3Velocity			= k3Velocities[i];
				k4Velocity			= k4Velocities[i];
				
				p.position.x = originalPosition.x + t / 6*(k1Velocity.x + 2*k2Velocity.x + 2*k3Velocity.x + k4Velocity.x);
				p.position.y = originalPosition.y + t / 6*(k1Velocity.y + 2*k2Velocity.y + 2*k3Velocity.y + k4Velocity.y);
				p.position.z = originalPosition.z + t / 6*(k1Velocity.z + 2*k2Velocity.z + 2*k3Velocity.z + k4Velocity.z);
				
				// velocity
				originalVelocity	= originalVelocities[i];
				k1Force				= k1Forces[i];
				k2Force				= k2Forces[i];
				k3Force				= k3Forces[i];
				k4Force				= k4Forces[i];
				
				p.velocity.x = originalVelocity.x + t / 6*p.mass * (k1Force.x + 2*k2Force.x + 2*k3Force.x + k4Force.x);
				p.velocity.y = originalVelocity.y + t / 6*p.mass * (k1Force.y + 2*k2Force.y + 2*k3Force.y + k4Force.y);
				p.velocity.z = originalVelocity.z + t / 6*p.mass * (k1Force.z + 2*k2Force.z + 2*k3Force.z + k4Force.z);
			}
		}
		
	}

}
