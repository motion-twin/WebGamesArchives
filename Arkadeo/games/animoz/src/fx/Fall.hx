package fx;

class Fall extends mt.fx.Fx
{
	var ent : ent.Ball;
	
	public function new(ball:ent.Ball, height) 
	{
		super();
		ent = ball;
		init(height);
	}
	
	function init(height)
	{
		ent.z = height;
		ent.updatePos();
	}
	
	override function update()
	{
		super.update();
		//
		ent.vz += 0.75;
		ent.z += ent.vz;
		ent.vz *= 0.98;
		if( ent.z > 0 )
		{
			ent.z = 0;
			if( ent.vz < 3 )
			{
				ent.vz = 0;
				kill();
			}
			ent.vz *= -0.5;
		}
		
		ent.updatePos();
	}
}
