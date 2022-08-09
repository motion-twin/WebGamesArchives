class levels.TeleporterData
{

	var mc		: {  >MovieClip, skin:{>MovieClip,sub:MovieClip}  } ;
	var podA	: MovieClip;
	var podB	: MovieClip;
	var cx		: int ;
	var cy		: int ;

	var centerX	: float ;
	var centerY	: float ;
	var startX	: float;
	var startY	: float;
	var endX	: float;
	var endY	: float;

	var dir		: int ;
	var length	: int ;

	var fl_on	: bool;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new( x:int,y:int, len:int, dir:int ) {
		cx = x ;
		cy = y ;
		this.dir = dir ;
		length = len ;

		fl_on = false;


		// Calcul du point central
		centerX	= cx * Data.CASE_WIDTH + Data.CASE_WIDTH/2 ;
		centerY	= cy * Data.CASE_HEIGHT + Data.CASE_HEIGHT ;
		startX	= Entity.x_ctr(x);
		startY	= Entity.y_ctr(y);

		if ( dir==Data.HORIZONTAL ) {
			centerX += length/2*Data.CASE_WIDTH ;
			startX -= Data.CASE_WIDTH*0.5;
		}
		if ( dir==Data.VERTICAL ) {
			centerY += length/2*Data.CASE_HEIGHT ;
			startY -= Data.CASE_HEIGHT;
		}

		endX	= startX;
		endY	= startY;
		if ( dir==Data.HORIZONTAL ) {
			endX += length*Data.CASE_WIDTH;
		}
		else {
			endY += length*Data.CASE_HEIGHT;
		}
	}

}

