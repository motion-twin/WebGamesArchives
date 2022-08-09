/**
 *  Copyright (c) 2011 Martin Lindelof
 *  contact martin.lindelof(at)gmail.com
 *  website www.martinlindelof.com
 */
package physics;

import physics.Integrator;
import physics.ParticleSystem;
import mt.kiroukou.math.Vec3;
class ModifiedEulerIntegrator implements Integrator {

	var s : ParticleSystem;
	
	public function new(s : ParticleSystem) : Void
	{
		this.s = s;
	}
	
	public function step(t : Float) : Void
	{
		 var particles = s.particles;
		 s.clearForces();
		 s.applyForces();
		
		 var halftt = (t*t)*.5;
		 var one_over_t = 1/t;
		
		 for(p in particles)
		 {
		 	if(!p.fixed)
		 	{
		 		var ax = p.force.x / p.mass;
		 		var ay = p.force.y / p.mass;
		 		var az = p.force.z / p.mass;
		
		 		var vel_div_t = p.velocity.clone();
		 		vel_div_t.scale(one_over_t);
				//
		 		p.position = Vec3.add(p.position, vel_div_t, p.position);
		 		p.position.add3( ax*halftt, ay*halftt, az*halftt );
		 		p.velocity.add3(ax*one_over_t, ay*one_over_t, az*one_over_t );
		 	}
		}
	}
}
