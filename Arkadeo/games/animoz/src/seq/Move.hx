package seq;
import Protocol;

using mt.bumdum9.MBut;
using mt.Std;
class Move extends mt.fx.Sequence 
{
	var ball:ent.Ball;
	var trg:ent.Ball;
	
	public function new(ball:ent.Ball, path:Array<Square>) 
	{
		super();
		this.ball = ball;
		ball.charge = true;
		
		// SPECIAL
		switch(ball.type) 
		{
			case BallType._CHEETAH :
				if( Game.me.isEffectAvailable(BallType._CHEETAH) )
				{
					var notPlayable = Game.me.pool.copy();
					notPlayable.remove(BallType._CHEETAH);
					Game.me.extraRound.push( { notPlayable:notPlayable, blockEffect:[BallType._CHEETAH] } );
				}
			case BallType._KOALA :
				Game.me.queue.destroyUntil(1);
			default :
		}
		
		// MOVE
		var e = new fx.MoveBall(ball, path);
		
		// END BALL
		trg = path.first().getBall();
		if( trg != null ) 
		{
			if( ball.type == BallType._BEAR )
			{
				trg.freeSquare();
				Game.me.dm.over(trg.root);
			} 
			else 
			{
				var a = path.copy();
				a.reverse();
				e = new fx.MoveBall(trg, a);
				trg.charge = true;
			}
		}
		
		e.onFinish = end;
	}
	
	function end()
	{
		if( ball.type == BallType._BEAR && trg != null ) trg.burst();
		testCharge();
	}
	
	function testCharge() 
	{
		for( b in Game.me.balls )
		{
			if( !b.charge ) continue;
			
			b.charge = false;
			var e:mt.fx.Sequence = switch(b.type) 
			{
				case BallType._GNU : 		cast new Magnet(b.square);
				case BallType._PIOUZ : 		cast new Convert(b);
				case BallType._CHAMELEON : 	cast new Morph(b);//TODO with HYENA effect which isn't applied after transformation
				case BallType._HYENA :		cast new HyeneCheck(b);
				default :
			}
			if( e != null )
			{
				e.onFinish = testCharge;
				return;
			}
		}
		kill();
		Game.me.endRound();
	}
}
