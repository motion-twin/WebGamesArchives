package seq;

import Protocol;

class Wave extends mt.fx.Sequence 
{
	var count:Int;
	var wait:Int;
	var size:Int;
	var interrupt:Bool;
	
	public function new() 
	{
		super();
		interrupt = false;
		
		var balls = Game.me.balls.copy();
		var free = [];
		for ( sq in Game.me.squares )
		{
			if ( sq.isFree() )
			{
				free.push(sq);
			}
		}
		
		count = 0;
		for ( ball in Game.me.queue.balls.copy() ) 
		{
			if ( free.length == 0 )
			{
				interrupt = true;
				break;
			}
			
			var trg = free[Game.me.random(free.length, "wave")];
			if( ball.type == _SHEEP ) 							trg = findSquareNear(_SHEEP, free);
			if( ball.type == _HIPPO && balls.length > 0 ) 		trg = balls[Game.me.random(balls.length, "hippo")].square;
			free.remove(trg);
			
			var pos = trg.getCenter();
			var e = new fx.TweenEnt(ball, pos.x, pos.y, 90, 25);
			e.addFx(UP_DOWN(ball));
			e.addFx(FLOWERS);
			e.addFx(GRASS);
			
			count++;
			e.onFinish = function() 
			{
				trg.splash();
				ball.setSquare(trg);
				ball.register();
				//
				if ( trg.kdo != null )
				{
					trg.kdo.trig();
				}
				//
				if( --count == 0 )
					finish();
			}
			Game.me.queue.balls.remove(ball);
		}
		if( count == 0 )
			finish();
	}
	
	function finish() 
	{
		if ( interrupt )
		{
			interrupt = false;
			count = 0;
			for ( b in Game.me.queue.balls )
			{
				count ++;
				var e = new fx.GoBack(b);
				e.onFinish = function()
				{
					if( --count == 0 )
						finish();
				}
			}
			Game.me.queue.balls = [];
		} 
		else 
		{
			Game.me.newTurn();
			kill();
		}
	}
	
	function findSquareNear(bt:BallType, free:Array<Square>) 
	{
		var a = [];
		for( sq in Game.me.squares ) sq.tag = 1;
		for( sq in free ) sq.tag = 0;
		for ( sq in Game.me.squares ) 
		{
			var ball = sq.getBall();
			if( ball == null || ball.type != bt ) continue;
			for ( nsq in sq.nei ) 
			{
				if( nsq.tag == 1 ) continue;
				nsq.tag = 1;
				if( nsq.isFree() ) a.push(nsq);
			}
		}
		if( a.length == 0 ) a = free;
		return a[Game.me.random(a.length, "findSquareNear")];
	}
}

