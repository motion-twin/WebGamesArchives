package seq;
import api.AKApi;
import Protocol;

class CheckCombo extends mt.fx.Sequence 
{
	var escaped:Int;
	var combos:Array<ent.Ball>;
	var explode:Array<ent.Ball>;
	var locked:Bool;
	var newFreeTurn:Bool;
	
	public function new() 
	{
		super();
		Game.me.buildCombos();
		// SCAN
		newFreeTurn = false;
		combos = [];
		locked = false;
		for( b in Game.me.balls ) 
		{
			if( b.score > 0 ) 
			{
				combos.push(b);
				if( b.square != null ) b.square.removeActions();
				if( b.type == _SQUIRREL ) newFreeTurn = true;
				if( b.square.bonus != null ) b.square.bonus.splash();
			}
		}
		
		if( combos.length == 0 ) 
		{
			if( Game.me.getRandomFreeSquare() == null ) 
			{
				kill();
				new fx.GameOver();
				return;
			} 
			else
			{
				end();
			}
			return;
		}
		
		// EXPLODER
		for( b in Game.me.balls )
			b.square.tag = 0;
			
		for( b in combos )
			b.square.tag = 1;
		
		explode = [];
		
		for( b in Game.me.balls )
		{
			if( b.score < 0 ) 
			{
				b.square.tag = 1;
				explode.push(b);
			}
		}
		
		for( b in combos ) 
		{
			if( b.type != BallType._LION ) continue;
			for( nsq in b.square.nei ) 
			{
				if( nsq.tag == 1 ) continue;
				nsq.tag = 1;
				var nball = nsq.getBall();
				if( nball != null ) explode.push(nball);
			}
		}
		
		// HEN
		var a  = [];
		for( b in combos )
		{
			if( b.type == BallType._HEN )
				a.push(b);
		}
		
		if( a.length > 0 )
		{
			new fx.Egg(a[Game.me.random(a.length, "egg")].square, a.length);
		}
			
		// ESCAPE
		escaped = 0;
		combos.sort(orderCombo);
		var wait = 0;
		for( b in combos ) 
		{
			b.unregister();
			b.freeSquare();
			var e = new fx.Escape(b, ++wait);
			e.onFinish = escape;
			
			if( wait == combos.length )
				e.endJump = end;
				
			Game.me.incScore(b.score, b.x, b.y);
		}
		
		for( b in explode )
		{
			b.burst();
		}
		
		spc = 0.05;
	}
	
	function orderCombo(a:ent.Ball, b:ent.Ball) 
	{
		var na = a.square.x + a.square.y;
		var nb = b.square.x + b.square.y;
		if( na < nb ) return -1;
		if( na > nb ) return 1;
		return 0;
	}
	
	// UPDATE
	override function update()
	{
		super.update();
		var esc = [];
		for( e in Game.me.ents )
			if( e.bounce )
				esc.push(e);
		
		for( i in 0...esc.length )
		{
			var a = esc[i];
			for( j in i + 1...esc.length ) 
			{
				var b = esc[j];
				var dx = a.x - b.x;
				var dy = a.y - b.y;
				var dist = Cs.SQ - Math.sqrt(dx * dx + dy * dy);
				if( dist > 0 ) 
				{
					var an = Math.atan2(dy, dx);
					var ddx = Math.cos(an) * dist * 0.2;
					var ddy = Math.sin(an) * dist * 0.2;
					a.x += ddx;
					a.y += ddy;
					b.x -= ddx;
					b.y -= ddy;
				}
			}
		}
	}

	function escape()
	{
		if( ++escaped == combos.length ) 
		{
			kill();
		}
	}
	
	function end() 
	{
		if( newFreeTurn ) 		Game.me.newRound()
		else 					new Wave();
	}
}

