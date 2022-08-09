package fx;

import flash.display.BlendMode;
using Ex;

@:publicFields
class LeaveRoom extends mt.fx.Fx
{
	var timer : Int;
	var grStart : Grid;
	var dir : V2D;
	
	public function new( grStart, grEnd ) 
	{
		super();
		this.grStart = grStart;
		var inDep = grStart.findDoorTo( grEnd.getRid() );
		
		var tdir = grStart.getDoorDir(inDep);
		var indir = Dirs.LIST[ Dirs.inv(tdir).index()  ];
		
		var viso :V2D = V2DIso.grid2px( indir.x, indir.y );
		dir = new V2D(0,0);
		dir.x = viso.x;
		dir.y = viso.y;
	}
	
	static inline var totalTime : Int = 30;
	
	public override function update()
	{
		super.update();
		
		timer++;
		
		var incRatio :Float = timer / (1.0 *totalTime);
		
		//Debug.MSG(incRatio);
		incRatio = MathEx.clamp( incRatio, 0,1);
		grStart.x += dir.x;
		grStart.y += dir.y;
		grStart.alpha = MathEx.clamp( MathEx.pow2f( 1.0 - incRatio), 0, 1 );
		//grStart.alpha = 1.0 - incRatio;
		grStart.blendMode = LAYER;
		
		if (timer> totalTime)
		{
			grStart.visible = false;
			kill();
		}
	}
	
	public override function kill()
	{
		super.kill();
		
		//grStart.resetGfx();
		grStart = null;
		dir = null;
		
		ServerProcess.leave = null;
	}
}