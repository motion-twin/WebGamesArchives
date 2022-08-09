package fx.js;

import mt.deepnight.Color;
using Ex;
/**
 * ...
 * @author de
 */


class BackgroundTransition extends fx.FX
{
	public var jq : js.JQuery;
	public var stages : Array<{t:Float,c:Col}>;
	
	public function new( sel: js.JQuery ,ast : Array<{t:Float,c:Col}>)
	{
		Debug.ASSERT( ast != null );
		Debug.ASSERT( ast.length > 0 );
		Debug.ASSERT( ast[ast.length - 1] != null  );
		super( ast[ast.length - 1].t );
		
		stages = ast;
		jq = new js.JQuery( sel );
		//Debug.MSG("starting " + jq.length);
	}
	
	
	
	public static function toHtml( c : Col ) : String
	{
		return Color.intToHex(Color.rgbToInt(c));
	}
	
	public function lookupStages() : {ratio:Float,src:Col,tgt:Col}
	{
		var d = date();
		var vmin = null;
		var vmax = null;
		
		for(st in 0...stages.length)
		{
			if( stages[st].t > d )
			{
				vmax = st;
				vmin = MathEx.clampi( vmax-1, 0, stages.length);
				break;
			}
		}
		
		if( vmax == null)
		{
			vmax = stages.length-1;
			vmin = MathEx.clampi( vmax, 0, stages.length);
		}
		
		var ratio = (vmin == vmax)
		? 0
		:(d - stages[vmin].t) / (stages[vmax].t - stages[vmin].t);
		
		ratio = MathEx.clamp( ratio, 0, 1);
		return { ratio:ratio, src:stages[vmin].c, tgt:stages[vmax].c };
	}
	
	public override function update()
	{
		var cur = lookupStages();
		
		var interp = toHtml(Color.interpolate( cur.src, cur.tgt, cur.ratio));
		jq.css( "background-color", interp  );
		
		if( duration==null && (date() > stages.last().t))
			reset();
		
		return super.update();
	}
	
}