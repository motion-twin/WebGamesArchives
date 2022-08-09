package fx;

using Ex;

@:publicFields
class EnterRoom extends mt.fx.Fx {
	
	var grStart : Grid;
	var grEnd : Grid;
	var grEndIncPos : V2I;
	var dir : V2D;
	
	public function new(grStart : Grid, grEnd : Grid ) 
	{
		super();
		
		
		this.grStart = grStart;
		this.grEnd = grEnd;
		
		//restore it in background
		grStart.resetGfx();
		grStart.visible = false;
		
		var inDep = grStart.findDoorTo( grEnd.getRid() );
		var outDep = grEnd.findDoorTo( grStart.getRid() );
		if ( outDep == null)
		{
			kill();
			return;
		}
		var outPad = grEnd.getDoorPad( outDep );
		grEndIncPos = outPad.first();
		Debug.MSG( "pad pod = " + Std.string( grEndIncPos ) + V2DIso.grid2px( grEndIncPos.x, grEndIncPos.x ) );
		var tdir = grStart.getDoorDir(inDep);
		var indir = Dirs.LIST[ Dirs.inv(tdir).index()  ];
		
		var viso :V2D = V2DIso.grid2px( indir.x, indir.y );
		dir = new V2D(0,0);
		dir.x = viso.x;
		dir.y = viso.y;
		
		execute();
	}
	
	public function execute()
	{
		grEnd.visible = true;
		
		grEnd.x = 0;
		grEnd.y = 0;
		
		grEnd.dirtSort();
		grEnd.update();
		
		var grEndPix : V2D;
		if ( Player.DYN_VP.has( Protocol.roomDb( grEnd.getRid()).type ))
			grEndPix = Main.getVpCentersPos(V2DIso.grid2px( grEndIncPos.x, grEndIncPos.y ));
		else
			grEndPix = Main.getVpCenter( grEnd );
		
		Main.view.scrollPix(  grEndPix.x + -dir.x * 30,
								grEndPix.y + -dir.y * 30 );
		Main.view.tweenPix(grEndPix.x, grEndPix.y);
		
		kill();
	}
}