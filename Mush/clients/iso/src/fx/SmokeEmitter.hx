package fx;


import mt.fx.Part;
import Data;
import Types;

using Ex;
/**
 * ...
 * @author de
 */

class SmokPart extends Part < mt.pix.Element >
{
	var pr : mt.pix.Element;
	var puid : Int;
	public function new(p)
	{
		super(p);
		pr = p;
		puid = Std.random(4);
		pr.mouseEnabled = false;
	}
	override function update()
	{
		var iratio = 1.0 * timer / SmokeEmitter.BASE_LIFE;
		var cl = As3Tools.colTans();
		cl.alphaMultiplier = iratio;
		
		switch(puid)
		{
			case 0, 1, 2:
				var val = MathEx.lerpi(0x77, 0xFF, 1-iratio);
				cl.color = (val << 16) | (val << 8) | (val);
			case 3:
				//var val = Dice.roll(0x77, 0xFF);
				//cl.color = (val << 16) | (val << 8) | (val);
		}
		pr.transform.colorTransform = cl;
		super.update();
	}
}

class SmokeEmitter extends mt.fx.Fx
{
	static var SMOKES = [];
	
	var tile : Tile;
	var pr : mt.pix.Element;
	
	public static var BASE_LIFE = 40;
	public var coolSpawns : Array<V2D>;
	
	public function new( tile,te, sz:V2I )
	{
		Debug.ASSERT( tile != null && te != null);
		super();
		
		SMOKES.push( this );
		this.tile = tile;
		pr = te.el;
		
		var setup : PixSlice = Data.slices.get( te.setup.index );
		
		var rd = function()
		{
			
			var base = V2DIso.grid2px( 1.0 - Math.random() * sz.x,  1.0 - Math.random()  * sz.y);
			base.x -= setup.ofsX;
			base.y -= setup.ofsY;
			return base;
		}
		
		coolSpawns = [];
		for(x in 0...10)
		{
			coolSpawns.push( rd());
		}
		if( coolSpawns.length > 6 )
		{
			coolSpawns.scramble();
			coolSpawns=  coolSpawns.slice( 0,6 );
		}
		Debug.MSG("spawns:" + coolSpawns.length);
	}
	
	public function getSmoke() : mt.pix.Element
	{
		var el = cast new ElementEx();
		Data.setup2( el, Data.mkSetup("FX_SMOKE" ));
		pr.addChild( el ) ;
		return el;
	}
	
	
	public override function update()
	{
		super.update();
		
		
		if(Dice.percent(40))
		{
			var p = new SmokPart( getSmoke() );
			var pos = coolSpawns.random();
			
			p.setPos( pos.x, pos.y) ;
			p.vy = -0.8;
			p.vx = (0.5 - Math.random()) * 0.275;
			
			p.setScale( 0.4 + RandomEx.rf( 0.1 ) );
			p.sfr = 1.04;
			p.timer = BASE_LIFE;
			p.fadeIn( 2 );
		}
		
	}
	
	public static function remove( mc : mt.pix.Element )
	{
		if ( mc == null) return;
		
		for(x in SMOKES.copy())
		{
			if( x.pr == mc )
			{
				if( x!=null && !x.dead)
					x.kill();
				SMOKES.remove( x );
			}
		}
	}
	
}