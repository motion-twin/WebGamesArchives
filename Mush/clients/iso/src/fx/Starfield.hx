package fx;

import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Shape;
import flash.display.BlendMode;
import flash.display.Stage;
import flash.filters.GlowFilter;
import mt.deepnight.Lib;

using Ex;
using As3Tools;

/**
 * ...
 * @author de
 */
typedef RayDesc =
{
	start : V2D,
	//depth : Float;
	ratio : Float,//star at 0 end at 1
	gfx : flash.display.Bitmap,
	depth: Float,
};

enum SF_CLASS
{
	SF_DAEDALUS_STOPPED;
	SF_PATROL;
	SF_DAEDALUS_TRAVELING;
}

class Starfield extends mt.fx.Fx
{
	var speed 	: Float;
	var angle 	: Float;
	var dir 	: V2D;
	public var root 	: Sprite;
	
	static var MAX_NB : Int = 500;
	
	static var START_RATIO : Float = -4;
	static var MAX_RATIO : Float = 4;
	
	public var rayList : Array<RayDesc>;
	public var type( default, set ) : SF_CLASS;
	
	/**
	 * @param	speed in hom float per frame
	 * @param	angle in rads
	 */
	public function new( c : SF_CLASS, parent : DisplayObjectContainer)
	{
		super();
		root = new Sprite();
		rayList = [];
		if( !Main.isHiFi()) 
			c = SF_DAEDALUS_STOPPED;
		
		set_type( c );
		
		var width = Main.isHiFi() ? 500 : 50;
		for(x in 0...MAX_NB)
			spawn();
		parent.addChild( root );
	}
	
	public function set_type(t)
	{
		if ( type == t ) return t;
		
		type = t;
		
		switch( t)
		{
			case SF_DAEDALUS_STOPPED:
				{
					speed = 0.001;
					angle = 0;
				}
			case SF_PATROL:
				{
					speed = 0.1;
					angle = - Math.PI / 2;
				}
			case SF_DAEDALUS_TRAVELING:
				{
					speed = 0.1;
					angle = 0;
				}
		}
			
		if ( !Main.isHiFi()) 
			speed *= 0.001;
		dir = V2D.unit(angle);
		return t;
	}
	
	public function spawn()
	{
		var spr : Shape = new Shape();
		spr.blendMode = BlendMode.ADD;
		spr.alpha = Dice.rollF( 0.6, 1.0);
		
		var def : RayDesc =
		{
			start: rdStart(),
			ratio: Dice.rollF( START_RATIO,MAX_RATIO ),
			depth : Dice.rollF( 0.1, 0.5) + Dice.rollF( 0.1, 0.5),
			//gfx: spr,
			gfx:null,
		};
		rayList.push( def );
		
		var r = def;
		var from = morph(	r.start.x + r.ratio * dir.x,
							r.start.y + r.ratio * dir.y);
		
		var lineSpeed = Math.max( 0.0012, speed * 4  * r.depth) ;
		var to = morph( r.start.x + r.ratio * dir.x + dir.x * lineSpeed,
						r.start.y + r.ratio * dir.y + dir.y * lineSpeed );
		
		spr.graphics.clear();
		
		var thickness = 3.0 * r.depth;
		
		spr.graphics.lineStyle( thickness, 0xFFffFF, 1 );
		spr.graphics.moveTo( from.x, from.y);
		spr.graphics.lineTo( to.x, to.y );
		spr.filters = [ new GlowFilter(0xFFFFFF,0.8,6,6,2) ];
		
		r.gfx = Lib.flatten(spr, true);
		r.gfx.pixelSnapping = flash.display.PixelSnapping.NEVER;
		
		root.addChild( r.gfx );
		//trace(r.gfx.x + " " + r.gfx.y);
	}
	
	public function rdStart()
	{
		return V2D.unit( MathEx.lerp( angle + Math.PI - Math.PI * 0.5, angle + Math.PI + Math.PI * 0.5 , Math.random() ) );
	}
	
	public function morph( x : Float,y : Float )
	{
		return V2DIso.grid2px( x * 30.0, y * 30.0 );
	}
	
	
	static var ac = 0;
	static var toggle = true;
	public override function update()
	{
		
		for(r in rayList)
		{
			/*
			var from = morph(	r.start.x + r.ratio * dir.x,
								r.start.y + r.ratio * dir.y);
			
			var lineSpeed = Math.max( 0.0012, speed * 4  * r.depth) ;
			var to = morph( r.start.x + r.ratio * dir.x + dir.x * lineSpeed,
							r.start.y + r.ratio * dir.y + dir.y * lineSpeed );
			
			r.gfx.graphics.clear();
			
			var thickness = 3.0 * r.depth;
			
			r.gfx.graphics.lineStyle( thickness, 0xFFffFF, 1 );
			r.gfx.graphics.moveTo( from.x, from.y);
			r.gfx.graphics.lineTo( 	to.x, to.y );
			*/
			var vx = Main.view.x;
			var vy = Main.view.y;
			
			r.gfx.visible = (r.gfx.x > -500 && r.gfx.x < flash.Lib.current.stage.stageWidth+ 500)
			&&				(r.gfx.y > -500 && r.gfx.y < flash.Lib.current.stage.stageHeight+ 500);
									
			var dr : Float = speed * r.depth;
			r.ratio += speed * r.depth;
			
			var dx = dr * dir.x;
			var dy = dr * dir.y;
			var md = morph( dx, dy);
			r.gfx.x += md.x;
			r.gfx.y += md.y;
			
			//trace(r.gfx.y+" "+md.y);
			//trace(r.gfx.x+" "+md.x);
			
			//r.gfx.y = r.start.y + r.ratio * dir.y;
			if ( r.ratio >= MAX_RATIO )
			{
				r.ratio = Dice.rollF( START_RATIO,MAX_RATIO );
				r.start = rdStart();
				
				var md = morph( r.start.x+ r.ratio * dir.x, r.start.y + r.ratio * dir.y);
				r.gfx.x = md.x;
				r.gfx.y = md.y;
			}
			
		}
	}
	
	public override function kill()
	{
		super.kill();
		
		//root.detach();
		//for ( x in rayList) x.gfx.detach();
		rayList = [];
	}
}