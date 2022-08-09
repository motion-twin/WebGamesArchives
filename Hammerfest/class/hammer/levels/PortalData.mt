class levels.PortalData
{

	var mc		: MovieClip;
	var cx		: int ;
	var cy		: int ;

	var x		: float; // for animation purpose only
	var y		: float;
	var cpt		: float;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new( mc, cx:int,cy:int ) {
		this.mc = mc;
		this.cx = cx ;
		this.cy = cy ;

		x = mc._x;
		y = mc._y;
		cpt = 0;
	}

}

