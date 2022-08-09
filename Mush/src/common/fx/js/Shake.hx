package fx.js;

/**
 * ...
 * @author de
 */

class Shake extends FX
{
	var jq : js.JQuery;
	
	var bp_t : Int;
	var bp_l : Int;
	
	var anchor : String;
	
	public function new( sel : String , expires : Float, ?right_anchored)
	{
		super(expires);
		jq = new js.JQuery(sel);
		if( jq.length == 0 )
		{
			kill();
		}
		else
		{
			if( right_anchored )
				anchor = "margin-right";
			else
				anchor = "margin-left";
			bp_t = Std.parseInt(jq.css("margin-top"));
			bp_l = Std.parseInt(jq.css(anchor));
		}
		FXManager.self.add(this);
	}
	
	public override function onKill()
	{
		jq.css( "margin-top", Std.string(bp_t));
		jq.css( anchor, Std.string(bp_l));
		
		jq = null;
		bp_t = null;
		bp_l = null;
	}
	
	public override function update()
	{
		//Debug.MSG("jig");
		jq.css( "margin-top" , Std.string( bp_t + Dice.roll(-10,10) )+"px");
		jq.css( anchor , Std.string( bp_l + Dice.roll(-10,10) )+"px");
		return super.update();
	}
}
