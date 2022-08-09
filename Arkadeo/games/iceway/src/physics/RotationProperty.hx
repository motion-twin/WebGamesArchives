package physics;

class RotationProperty implements physics.ParticleProperty
{
	public var rotation : Float = 0.;
	public var rotationDrag : Float = 0.;
	public var rotationSpeed : Float = 0.;
	
	var p : physics.Particle;
	public function new( p : physics.Particle )
	{
		this.p = p;
	}
	
	public function getParticle()
	{
		return p;
	}
	
	public function invalidate()
	{
		
	}
	
	public function apply()
	{
		rotationSpeed *= (1 - rotationDrag);
		rotation += rotationSpeed;
	}
}