package fx;

import mt.gx.time.FTimer;

import flash.text.TextFormat;
import flash.text.TextField;

using mt.gx.Ex;

enum WIN_STATE
{
	PRINT(n:Int);
	CROUCH;
	PREP_JUMP;
	JUMP;
}

class Win implements haxe.Public
{
	var word : flash.text.TextField;
	var ws : WIN_STATE ;
	static var me = null;
	
	public var game(get, null) : Game; function get_game() return Game.me
	
	public function new()
	{
		me = this;
		FTimer.tick( this.tick, 300 );
		
		word = new TextField();
		word.text = Text.well_done;
		
		var tf = new TextFormat("galaxy", 50);
		tf.color = 0xff8200;
		word.embedFonts = true;
		word.setTextFormat( word.defaultTextFormat = tf );
		word.y = 80;
		word.x = (Lib.w() >> 1) - (word.textWidth *0.5);
		word.width = 600;
		game.view.parent.addChild( word );
		word.toFront();
		word.filters = [Data.getOrangeFilter(), Data.getOuterBlackFilter()];
		word.selectable  = false;
		word.cacheAsBitmap = true; 
		
		game.char.input = false;
		ws = PRINT(20);
		game.char.godMode = true;
		
		for ( el in game.level.nmy)
			if( el != null )
				for( e in el )
					e.pause = true;
	
	}
	
	
	public function tick(r:Float )
	{
		switch(ws)
		{
			default:
			case  PRINT(n):
				if ( n == 1) 	ws = CROUCH;
				else 			ws = PRINT(n - 1);
				
			case CROUCH:
				var c = game.char;
				c.changeState( FORCE_CROUCH );
				c.flags.unset(GRAVITY);
				c.flags.set(NO_COLLIDE);
				
				ws = PREP_JUMP;
				Level.SKIP_VIEW_SYNC = true;
					
			case PREP_JUMP:
				if ( game.char.getCrouchRatio() >= 1)
				{
					game.char.changeState( JUMP );
					game.char.dy = -4;
					ws = JUMP;
				}
				
			case JUMP:
				var gr = new fx.Greyscale();
				mt.gx.time.FTimer.tick( function(r) 
				{
					gr.setStrengthBloom( r);
					Game.me.filters = [gr.get()];
					
					if ( r >= 0.99 && ! game.level.gameOverCalled)
					{
						#if !ide
							game.level.gameOverCalled = true;					
							api.AKApi.gameOver(true);
						#end
					}
				}, 60 );
		}
		
		if ( r >= 1.0) kill();
	}
	
	public function kill()
	{
		word.detach();
		word = null;
	}
}