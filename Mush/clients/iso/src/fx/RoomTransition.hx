package fx;

using Ex;
/**
 * ...
 * @author de
 */

enum RT_State
{
	Incoming;
	Waiting;
	Arriving;
}

@:publicFields
class RoomTransition extends mt.fx.Fx
{
	var timer : Int;
	var dir : V2D;
	var pause : Bool;
	var selfKill: Bool;
	
	var grStart : Grid;
	var grEnd : Grid;
	var state : RT_State;
	
	var grEndIncPos : V2I;
	
	public function new( grStart : Grid, grEnd : Grid , selfKill ) 
	{
		super();
		
		pause = false;
		this.grStart = grStart;
		this.grEnd = grEnd;
		
		var inDep = grStart.findDoorTo( grEnd.getRid() );
		
		var outDep = grEnd.findDoorTo( grStart.getRid() );
		var outPad = grEnd.getDoorPad( outDep );
		
		grEndIncPos = outPad.first();
		
		Debug.MSG( "pad pod = "+Std.string( grEndIncPos )+ V2DIso.grid2px( grEndIncPos.x,grEndIncPos.x ) );
		
		var tdir = grStart.getDoorDir(inDep);
		//Debug.MSG( "using tdir = " + tdir );
		var indir = Dirs.LIST[ Dirs.inv(tdir).index()  ];
		
		var viso :V2D = V2DIso.grid2px( indir.x, indir.y );
		dir = new V2D(0,0);
		dir.x = viso.x;
		dir.y = viso.y;
		this.selfKill = selfKill; 
		timer = 0;
		grEnd.visible = false;
		state = Incoming;
	}
	
	public function doArriving()
	{
		grStart.visible = false;
		grEnd.visible = true;
		grEnd.dirtSort();
		grEnd.x = 0;
		grEnd.y = 0;
		
		var grEndPix : V2D;
		if ( Player.DYN_VP.has( Protocol.roomDb( grEnd.getRid()).type ))
		{
			grEndPix = Main.getVpCentersPos(V2DIso.grid2px( grEndIncPos.x, grEndIncPos.y ));
			//Debug.MSG("targeting door");
		}
		else
		{
			grEndPix = Main.getVpCenter( grEnd );
			//Debug.MSG("targeting center");
		}
		
		Main.view.scrollPix(  grEndPix.x + -dir.x * 30,
								grEndPix.y + -dir.y * 30 );
		Main.view.tweenPix(grEndPix.x,grEndPix.y);
	}
	
	public override function update()
	{
		super.update();
		var totalTime : Int = 30;
		
		if ( state != Waiting)
		{
			timer++;
		}
		
		var arRatio = ((timer - (totalTime >> 1)) / (totalTime >> 1));
		var incRatio = timer / (totalTime >> 1);
		
		grStart.x += dir.x ;
		grStart.y += dir.y;
		grStart.alpha = MathEx.pow2f( 1.0 - incRatio);
		grStart.blendMode = flash.display.BlendMode.LAYER;
		
		//Debug.MSG( "up " + grStart.x + " " + dir.x);
		//Debug.MSG( arRatio );
		if ( selfKill )
		{
			switch(state)
			{
				case Waiting:
				case Incoming:
					
				if ( timer >= (totalTime >> 1))
				{
					timer =  totalTime >> 1;
					state = Arriving;
					doArriving();
				}
				case Arriving:
				
			}
			
			if ( timer > totalTime )
				kill();
		}
		else
		{
			switch(state)
			{
				case Incoming:
				if ( timer >= (totalTime >>1))
				{
					if ( ServerProcess.waitingServer )
					{
						state = Waiting;
					}
					else 
					{
						state = Arriving;
						timer = totalTime >>1;
					}
				}
				
				case Waiting:
				{
					timer = totalTime>>1;
					if ( !ServerProcess.waitingServer )
					{
						state = Arriving;
						doArriving();
					}
				}
				case Arriving:
				{
					var ratio : Float = arRatio;
					//Debug.MSG( "ratio:" + ratio );
				}
			}
		}
	}
	
	public override  function kill()
	{
		if ( grStart != null )
		{
			grStart.resetGfx();
			grStart.visible = false;
		}
		grStart = null;
		
		if ( grEnd != null)
			grEnd.resetGfx();
		grEnd = null;
		
		//Main.doVp();+
		super.kill();
	}
	
	
}