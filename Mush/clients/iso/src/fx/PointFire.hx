package fx;
using Ex;

import Data;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import mt.gx.math.Vec3;
import Types;

@:publicFields
private class Part extends Spr3D
{
	var parentPool : Pool<Part>;
	var life : Int = 0;
	var maxLife : Int = 0;
	var pf : PointFire;
	var seed : Int;
	
	public function new( parent: PointFire, parentPool : Pool<Part> )
	{
		pf = parent;
		super(parent.getGrid(),FX);
		this.parentPool = parentPool;
		engine = UsePostFx;
		te.el.mouseEnabled = false;
		te.el.mouseChildren = false;
		init( grid, Data.mkSetup( "FX_PIXEL" ), false );
		grid.addEntity( this, false);
		visible = false;
	}
	
	
	public function reset(){
		if ( pf.getGrid() != grid ) {
			grid.removeEntity(this,false);
			onEnd();
			grid = pf.getGrid();
			grid.addEntity( this, false);
		}
			
		grid = pf.getGrid();
		life = 0;
		maxLife = 0;
		el.alpha = 0.65;
		el.blendMode = flash.display.BlendMode.ADD;
		el.scaleX = el.scaleY = 4.0;
		
		var f = new GlowFilter(0xDDB000, 0.5, 1, 1);
		
		el.filters = [f];
		
		var ct = el.transform.colorTransform;
		
		if ( Dice.percent(50 )) 
		{
			ct.redMultiplier = 0.7;
			ct.greenMultiplier = 0.4;
			ct.blueMultiplier = 0.01;
		}
		
		else {
			ct.redMultiplier = 0.8;
			ct.greenMultiplier = 0.75;
			ct.blueMultiplier = 0;
		}
		
		el.transform.colorTransform = ct;
		
		pos.set();
		visible = true;
		return this;
	}
	
	//public static var fireString = "FX_FIRE_X";
	//public static var fireString2 = "FX_FIRE_X2";
	
	public override function update()
	{
		var v = 0.3;
		var kspread = 0.0005 * v;
		var sx = el.scaleX;
		var sqx = sx ;
		z += v * Dice.rollF(0.1,0.5);
		x += Math.sin(Main.time + seed) * kspread * sqx;
		y += Math.cos(Main.time + seed) * kspread * sqx;
		el.scaleX = el.scaleY = el.scaleX * 0.97;
		
		super.update();
		
		life++;
		if( life >= maxLife || grid != pf.getGrid() )
			onEnd();
			
		setPos3( x, y, z, pf.parent.curGrdOfs, false);
		
	}
	
	function onEnd(){
		el.filters = [];
		parentPool.destroy(this);
		visible = false;
	}
}

class PointFire extends Spr3D{
	
	public var yellowPool : Pool<Part>;
	public var intensity : Int;
	
	public var ofs : Vec3;
	public var parent : HumanNPC;
	
	public function new(  parent : HumanNPC  )
	{
		var gr  = parent.grid;
		super( parent.grid, DUMMY );
		
		yellowPool = new Pool(function() return new Part( this,yellowPool));
		prio = super.getPrio() + Std.random(3) - 1;
		prioOverride = function() return IsoConst.FX_PRIO;
		
		init( gr, null);
		engine = UsePostFx;
		ofs = new Vec3();
		this.parent = parent;
		
		grid.dirtSort();
	}
	
	var spin = 0;
	public override function update()
	{
		spin++;
		var spawnYellows = Dice.percent(Main.isHiFi() ? 60 : 30) ? 1 : 0;
		var sp  = spawnYellows;
		
		if( visible )
		for( r in 0...sp){
			var p = yellowPool.create();
			
			p.reset();
			p.maxLife = 50;
			p.seed = Std.random(53474);
			
			var grPos = parent.getGridPos();
			var k = 0.1;
			var kz = 0.1;
			p.setPos3( 
				ofs.x + grPos.x + k * Dice.rollF( -1, 1), 
				ofs.y + grPos.y + k * Dice.rollF( -1, 1), 
				ofs.z + kz*Dice.rollF(-1,1) );
		}
		
		for ( p in yellowPool.used )
			if ( p == null) continue;
			else p.update();
	}
	
	public function dispose() {
		kill();
	}
	
	public override function kill(){
		super.kill();
		yellowPool.kill();
	}
	
}