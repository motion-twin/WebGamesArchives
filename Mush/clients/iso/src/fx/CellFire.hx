package fx;
using Ex;

import Data;
import flash.filters.BlurFilter;
import Types;

@:publicFields
private class Part extends mt.pix.Element
{
	var parentPool : Pool<Part>;
	
	var startLife : Float;
	var life : Float;
	
	var temperature : Temp;
	var speed : V3D;
	
	var tempChange : Bool;
	
	var pr : CellFire;
	
	var pos : V2DIso;
	var pos3 : V3D;
	
	public function new( parent: CellFire, parentPool : Pool<Part> )
	{
		super();
		this.parentPool = parentPool;
		this.pr = parent;
		pr.getDo().addChild( this );
		
		visible = false;
		speed = new V3D();
		temperature = null;
		life = 0;
		startLife = 0;
		pos = new V2DIso();
		pos3 = new V3D();
		
		pr.te.el.mouseEnabled = false;
		pr.te.el.mouseChildren = false;
	}
	
	public function reset()
	{
		startLife = 0;
		life = 0;
		temperature = null;
		speed.set();
		pos.set();
		
		tempChange = true;
		visible = true;
		Debug.ASSERT( pr.getGrid() != null);
		Data.setup2( this, Data.mkSetup( fireString ));
		return this;
	}
	
	public static var fireString = "FX_FIRE_X";
	public static var fireString2 = "FX_FIRE_X2";
	public function changeStage(st)
	{
		var toss = Dice.toss() ? fireString : fireString2 ;
		switch( st)
		{
			case YELLOW: goto( 0, toss );
			case ORANGE: goto( 1, toss);
			case RED:	 goto( 2, toss );
			case SMOKE : goto( Dice.roll( 3, 5 ) , toss );
		}
		temperature  = st;
	}
	
	public function getPos3() return pos3;
	
	public function setPos3(vx:Float,vy:Float,vz:Float)
	{
		pos3.set(vx, vy, vz);
		pos.set(vx, vy);
		var ofs = Data.spriteOfs( fireString );
		
		x = Std.int(pos.x + ofs.x);
		y = Std.int(pos.y + ofs.y - vz * V2DIso.R  * 0.5) - pr.curGrdOfs;
		//Debug.MSG(x+" "+ y);
	}
	
	public function update()
	{
		if( temperature == null)
		{
			changeStage( YELLOW );
		}
		life -= mt.Timer.deltaT;
		
		if( !speed.isZero() )
		{
			var px = pos3.x + speed.x * mt.Timer.deltaT;
			var py = pos3.y + speed.y * mt.Timer.deltaT;
			var pz = pos3.z + speed.z * mt.Timer.deltaT;
			
			setPos3( px, py, pz );
		}
		
		var ratio = life / startLife;
		
		if( tempChange)
		{
			if( ratio < 0.9  && temperature == YELLOW )
			{
				if( Dice.percent( 10 )) tempChange = false;
				changeStage( ORANGE );
			}
			else if( ratio < 0.65  && temperature == ORANGE )
			{
				if( Dice.percent( 20 )) tempChange = false;
				changeStage( RED );
			}
			else if( ratio < 0.5 && temperature == RED )
			{
				speed.scale1( 2.0);
				changeStage( SMOKE );
				tempChange = false;
			}
		}
		
		if( life < 0)
		{
			onEnd();
		}
	}
	
	function onEnd()
	{
		visible = false;
		if ( parentPool != null)
			parentPool.destroy(this);
	}
	
	public  override function kill() {
		super.kill();
		
		if (parentPool != null) {
			parentPool.destroy(this);
			parentPool = null;
		}
		
		if ( pr != null ) {
			detach();
			pr = null;
		}
	}
}

class CellFire extends Entity
{
	
	public static var RED_X_MIN = 1.2;
	public static var RED_X_D = 0.5;
	
	public var yellowPool : Pool<Part>;
	public var intensity : Int;
	
	public var prio : Int;
	
	public function new(  gr:Grid,x : Int,y:Int )
	{
		super( grid, DUMMY );
		setPos( x, y);
		
		yellowPool = new Pool(function() return new Part( this,yellowPool), function(p) p.kill() );
		yellowPool.reserve( 50 );
		prio = super.getPrio() + Std.random(3) - 1;
		prioOverride = function() return IsoConst.FX_PRIO;
		
		init( gr, null);
		engine = [UseTile, UseEntity].random();
		//te.el.filters = [ new BlurFilter(2,2)];
		//te.el.blendMode = flash.display.BlendMode.ADD;
		grid.dirtSort();
	}
	
	public override function setPos(x:Int,y:Int)
	{
		super.setPos( x, y );
	}
	
	public override function update()
	{
		var rf = RandomEx.randF;
		var ri = RandomEx.randI;
		
		var scale :Float = intensity / 8;
		var spawnYellows = Dice.roll( 5, 8);
		if ( !Main.isHiFi())
			spawnYellows >>= 1;
			
		var gpos = pos.toGridF();
		
		//Debug.MSG("spamming " + spawnYellows);
		
		for( r in 0...spawnYellows)
		{
			var p = yellowPool.create();
			
			p.reset();
			p.life = p.startLife = 0.5 +Math.random() * 0.5 + scale;
			
			var z = 0.3;
			if(Std.random(2)==0)
			{
				z = Dice.rollF( 0.3, 1 );
				p.speed.set(0, 0, 1.5+ Dice.rollF( 0.1, 1.5 + scale * 2));
			}
			else p.tempChange = false;
			
			p.setPos3( 	gpos.x + 0.6 * Dice.rollF( -RED_X_MIN, RED_X_MIN),
						gpos.y + 0.5 *Dice.rollF( -RED_X_MIN,RED_X_MIN), z  );
			p.visible = true;
		}
		
		for( p in yellowPool.used )
			p.update();
		
	}
	
	public override function kill()
	{
		super.kill();
		yellowPool.kill();
	}
	
}