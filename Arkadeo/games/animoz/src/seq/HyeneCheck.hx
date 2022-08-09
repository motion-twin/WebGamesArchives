package seq;
import Protocol;

class HyeneCheck extends mt.fx.Sequence 
{
	public function new(b:ent.Ball) 
	{
		super();
		
		Game.me.buildCombos();
		if ( b.score == 0 ) 
		{
			timer == 9;
			return;
		}
		
		Game.me.addExtraRound();
		for ( b in Game.me.balls ) 
		{
			if( b.score == 0 || b.type != BallType._HYENA ) continue;
			var e = new mt.fx.Flash(b.root, 0.05);
			e.glow(2, 4, 0xCC00FF);
		}
	}
	
	override function update()
	{
		super.update();
		if( timer == 10 ) kill();
	}
}
