package ui;

import Protocol;
import Protocol.ShipStatsId;
using Ex;
/**
 * ...
 * @author de
 */

enum State
{
	IDLE;
	HUNTING;
	DYING;
}

@:publicFields
class MySprite extends ElementEx
{
	var st : State;
	var id : Int;
	var isPatrol : Bool;
	var life : Float;
	
	function new(patrol, id,?data)
	{
		super();
		this.id = id;
		isPatrol = patrol;
		this.data = data;
		add();
		st = IDLE;
		life = 0;
		alpha = 0;
		
		
		var fr = "FX_SPC_SMALL_HUNTER";
		Data.setup2( this, Data.mkSetup(fr) );
	}
	
	function add()
	{
		var bef = (Main.ship.planet == null) ? Main.sf.root : Main.ship.planet;
		As3Tools.putBefore( this, bef );
	}
	
	function clean()
	{
		this.detach();
	}
	
	function onExplode()
	{
		clean();
	}
	
	function onHurt()
	{
		
	}
	
	function update()
	{
		life += mt.Timer.tmod;
	}
	
	function refresh()
	{
		var old = Main.previousServerData;
		var now = Main.actServerData;
	
		if ( null==now )
			return;
		
		if ( !isPatrol )
		{
			var data = now.hunters.find( function(i) return i.id == id );
			if ( data == null )
			{
				st = DYING; life = 0;
				onExplode();
			}
			else
			{
				if ( old != null)
				{
					var oldData = old.hunters.find( function(i) return i.id == id );
					if(oldData != null)
						if ( data.hp > oldData.hp )
							onHurt();
				}
			}
		}
		else
		{
			
		}
	}
}

class SpaceRunners
{
	var hunters : IntHash<MySprite>;
	var patrols : IntHash<MySprite>;
	
	var life : Float;
	var next : Float;
	public function new()
	{
		life = 0;
		hunters = new IntHash();
		patrols = new IntHash();
		next = 60;
		if ( IsoConst.EDITOR)
			for ( i in 0...5)
			{
				var data = { type: ShipStatsId.HUNTER.index() };
				var spr = new MySprite( false, i,data );
			}
	}
	
	public function add()
	{
		for ( h in hunters)
			h.add();
			
		for ( p in patrols )
			p.add();
	}
		
	public function refresh()
	{
		for ( h in hunters )
			h.refresh();
			
		for ( p in patrols )
			p.refresh();
			
		var data = Main.actServerData;
		for( d in data.hunters )
			if ( !hunters.exists( d.id ) )
			{
				var spr = new MySprite( false, d.id,d );
				hunters.set( d.id,spr );
			}
	}
			
	public function update()
	{
		if (! IsoConst.BG_ANIM )
			return;
		
		life++;
		if (life > next)
		{
			for( a in 0...Dice.roll(1,3) )
				makeFormation();
			life = 0;
			next = Std.random( 120 ) + 120;
		}
	}
	
	public function makeChase()
	{
		
	}
	
	public function makeFormation()
	{
		var l = hunters.filter( function(h) return h.st == IDLE && h.data.type == HUNTER.index() );
		
		//find trajectory and launch one on it
		var f = l.random();
		if ( f == null)
		{
			//Debug.MSG("no idle");
			return;
		}
		
		//var tl = Main.grid().viewToGrid(-50,-50);
		//var br = Main.grid().viewToGrid(Window.W() + 50, Window.H() + 50);
		
		var fromX = -50.;
		var fromY = -50.;
		
		var toX = Window.W() + 50.;
		var toY = Window.H() + 50.;
		toY *= .5;
		
		var st = 30;
		var dx = Std.random( Std.int((Window.W()>>1) / st * st) );
		fromX += dx;
		toX += dx;
		
		var dy = Std.random( Std.int((Window.H()>>1) / st * st) );
		fromY += dy;
		toY += dy;
		
		f.x = fromX;
		f.y = fromY;
		
		if ( fromX < toX )
		{
			f.flags.set(EF_FLIP_X);
			f.redraw();
		}
		
		var t = 750;
		Main.tweenie.create(f.x,  toX, t);
		var p = Main.tweenie.create(f.y,  toY, t );
		
		f.st = HUNTING;
		f.life = 0;
		f.alpha = 1;
		
		
		function term() { f.st = IDLE; f.life = 0; };
		p.onEnd = function() { var e = Main.tweenie.create( f.alpha, 0 ); e.onEnd = term; };
		
		//Debug.MSG("making formation");
		
	}
}