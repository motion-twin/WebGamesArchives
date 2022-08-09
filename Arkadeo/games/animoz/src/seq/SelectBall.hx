package seq;

import haxe.zip.Entry;
import mt.bumdum9.Lib;

using mt.bumdum9.MBut;
class SelectBall extends mt.fx.Sequence 
{
	public function new()
	{
		super();
		
		for( sq in Game.me.squares )
			sq.selectable = 1;
		
		for( np in Game.me.rules.notPlayable ) 
		{
			for( b in Game.me.balls ) 
			{
				if( b.type != np ) continue;
				b.square.selectable = 0;
				Filt.grey(b.root);
			}
		}
		
		Game.me.bindOnSquareSelected( select );
		if ( !api.AKApi.isReplay() )
		{
			function emit(p_sq : Square)
			{
				if( p_sq.getBall() != null )
					Game.me.emitSquareSelectedEvent(p_sq);
			}
			
			for( b in Game.me.balls ) 
			{
				if ( b.square == null ) continue;
				b.square.removeActions();
				if ( b.square.selectable == 1 )
				{
					b.square.setAction( callback(emit, b.square), 
										callback(over, b), 
										callback(out, b) 
									);
				}
			}
		}
	}
	
	override function update() 
	{
		super.update();
		/*
		var sid = api.AKApi.getEvent();
		if( sid != null )
			select( Game.me.squares[sid] );
		*/
		Game.me.fxAmbient();
	}
	
	function select( sq : Square ) 
	{
		var b = sq.getBall();
		if( b == null )  throw( "no ball at " + sq.x +";" + sq.y + " !!!");
		out(b);
		kill();
		new seq.SelectTarget(b);
	}
	
	function over(b:ent.Ball)
	{
		if( !api.AKApi.isReplay() )
		{
			Game.me.infosPanel.showInfo(b);
		}
		Filt.glow(b.root, 2, 8, 0xFFFFFF);
	}
	
	function out(b:ent.Ball) 
	{
		b.root.filters = [];
		if( !api.AKApi.isReplay() )
		{
			Game.me.infosPanel.hideInfo();
		}
	}
	
	override function kill() 
	{
		for( b in Game.me.balls ) 
		{
			b.square.removeActions();
			b.root.filters = [];
		}
		//
		Game.me.unbindOnSquareSelected( select );
		//
		if( !api.AKApi.isReplay() )
		{
			Game.me.infosPanel.hideInfo();
		}
		super.kill();
	}
}
