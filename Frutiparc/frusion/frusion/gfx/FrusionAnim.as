/*
	$Id: FrusionAnim.as,v 1.2 2003/11/14 15:11:16  Exp $
*/


/*
	Class: gfx.FrusionFrusionAnim
	Frusion animation befor game startup
*/
class frusion.gfx.FrusionAnim
{
	
	
/*------------------------------------------------------------------------------------
 * Private members
 *------------------------------------------------------------------------------------*/

	
	private var mc: MovieClip;
	
	
/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/
	
	
	/*
		Function: FrusionAnim
		Constructor
		
		Parameters:
		- mc : MovieClip - the frusionAnim MovieClip
	*/
	public function FrusionAnim( mc : MovieClip, depth : Number ) 
	{
		this.mc = mc;
	}
	
	
	/*
		Function: update
		Perform updates on the animation, change size, etc...		
	*/
	public function update() : Void
	{		
		/*
		var anim_ratio : Number = (this.animWidth / this.animHeight);
		var game_ratio : Number = (this.mc.width / this.mc.height);

		if(game_ratio > anim_ratio)
		{
			// jeu plus large que l'anim
			this.animScale= this.mc.height / this.animHeight;
		}else{
			// anim plus large que le jeu ou m�me proportions
			this.animScale= this.mc.width / this.animWidth;
		}

		this.mc.anim_init._xscale = this.animScale * 100;
		this.mc.anim_init._yscale = this.animScale * 100;

		this.mc.anim_init._x = (this.mc.width - (this.mc.animWidth * this.anim_scale)) / 2;
		this.mc.anim_init._y = (this.mc.height - (this.mc.animHeight * this.anim_scale)) / 2;
		*/
	}
	
}