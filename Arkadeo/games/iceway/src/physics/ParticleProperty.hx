package physics;

/**
 * ...
 * @author Thomas
 */

interface ParticleProperty
{
	public function getParticle() : physics.Particle;
	public function invalidate():Void;
	public function apply():Void;
}