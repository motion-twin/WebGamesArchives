package ;

/**
 * ...
 * @author de
 */

enum EVT
{
	ON_ENTER;
	ON_OUT;
	ON_CLICK;
	ON_HOLD;
	ON_RELEASE;
}

typedef EventTracker = 
{
	el : mt.pix.Element,
	entered : Bool,
	clicked : Bool,
	dispatch : EnumHash< EVT, Void -> Void>,
}

class InputManager 
{
	var list : List<EventTracker>;
	var enabled : Bool;
	public var skip : Bool;
	
	public function new() 
	{
		list = new List();
		enabled = true;
		skip  = false;
	}
	
	public function register( evt : EVT, el : mt.pix.Element, prc : Void->Void ) 
	{
		for(x in list)
		{
			if ( x.el == el )
			{
				x.dispatch.set( evt, prc );
				return;
			}
		}
		
		var t = { el:el, entered:false, dispatch:new EnumHash(EVT),clicked:false };
		t.dispatch.set( evt, prc );
		list.push( t );
	}
	
	public function clean( el : mt.pix.Element )
		list = list.filter( function( et ) return et.el != el );
	
	public function disable()
	{
		for ( x in list )
			if ( x.entered )
			{
				var onOut = x.dispatch.get( ON_OUT );
				if ( onOut != null ) 
					onOut();
				x.entered = false;
			}
		enabled = false;
	}
	
	public function isEnabled() return enabled;
	public function enable()
	{
		enabled = true;
	}
	
	public function update()
	{
		var testDone = false;
		if ( !enabled ) 
			return;
			
		if (skip)
		{
			skip = false;
			return;
		}
		
		for(x in list)
		{
			var mx = x.el.mouseX;
			var my = x.el.mouseY;
			
			var test = x.el.visible && As3Tools.hitTest( x.el, mx, my );
						
			if(!test || testDone)
			{
				if ( x.entered)
				{
					var onOut = x.dispatch.get( ON_OUT );
					if ( onOut != null ) 
						onOut();
					x.entered = false;
				}
			}
			else
			{
				var click = Main.mouse.isDown;
				if (!click)
				{
					if (!x.entered)
					{
						var proc = x.dispatch.get( ON_ENTER );
						if ( proc != null ) 
							proc();
						x.entered = true;
					}
					
					if(x.clicked)
					{
						var proc = x.dispatch.get( ON_RELEASE );
						if ( proc != null )
							proc();
						x.clicked = false;
						x.entered = false;
					}
				}
				else
				{
					if ( x.clicked )
					{
						var proc = x.dispatch.get( ON_HOLD );
						if ( proc != null ) 
							proc();
					}
					else
					{
						x.clicked = true;
						var proc = x.dispatch.get( ON_CLICK );
						if ( proc != null ) 
							proc();
					}
				}
				testDone = true;
			}
		}
	}
}


