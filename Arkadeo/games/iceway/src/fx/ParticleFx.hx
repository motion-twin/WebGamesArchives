package fx;

class ParticleFx extends fx.Fx
{
	var particles : Array<physics.Particle>;
	public function new(?particles : Array<physics.Particle> )
	{
		super();
		if( particles != null )
			this.particles = particles.copy();
		else
			this.particles = [];
	}
	
	public function addParticle( p : physics.Particle )
	{
		if( initialized ) throw "impossible d'ajouter une particule à une effet déjà en cours";
		removeParticle(p);
		this.particles.push(p);
	}
	
	public function removeParticle( p : physics.Particle )
	{
		if( initialized ) throw "impossible de supprimer une particule à une effet déjà en cours";
		this.particles.remove(p);
	}
}