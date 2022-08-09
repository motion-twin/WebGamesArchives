/*
	$Id: LoadingBar.as,v 1.2 2003/11/14 15:11:16  Exp $
*/


/*
	Class: gfx.FrusionLoadingBar
	Loading bar during game loading
*/
class frusion.gfx.LoadingBar
{
	

/*------------------------------------------------------------------------------------
 * Private members
 *------------------------------------------------------------------------------------*/
	
	
	private var mc : MovieClip;


/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/
	
	
	/*
		Function: LoadingBar
		Constructor
		
		Parameters:
		- mc : MovieClip - the parent MovieClip
		- depth : Number - depth to use
	*/
	public function LoadingBar( mc : MovieClip, depth : Number ) 
	{
		this.mc = mc;
		this.mc.createEmptyMovieClip( "loading", depth);
		this.mc.loading._y = this.mc._height - 22;
		
		trace( "this.mc.height=" + this.mc._height );
	}
	
	
	/*
		Function: increase
		increase the progress bar
		
		Parameters:
		- percent : Number - the achieved percentage
	*/
	public function increase( percent : Number ) : Void
	{		
		this.mc.loading.clear();
		this.mc.loading.initDraw();
		if( percent > 0)
		{
			var radius = 10;
			var width = ( ( this.mc._width - radius * 2) * percent / 100 ) + radius;
			trace("width=" + width);
			this.mc.loading.drawSmoothSquare({x:2,y:2,w: width,h: 20},0xCCCCCC,radius);
			this.mc.loading.drawSmoothSquare({x:0,y:0,w: width,h: 20},0xEEEEEE,radius);
		}
	}
	
	
	/*
		Function: finalize
		do some cleanup
	*/
	public function finalize() : Void
	{
		this.mc.loading.removeMovieClip();
		delete this.mc.loading;		
	}

}