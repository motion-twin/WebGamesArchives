class gui.Container
{
	static var MARGIN		= 5;
	static var MIN_HEIGHT	= 20;


	var mode			: Mode;
	var depthMan		: DepthManager;
	var mc				: MovieClip;

	var fl_lock			: bool;

	var scale			: float;

	var width			: int;
	var currentX		: float;
	var currentY		: float;
	var lineHeight		: float;
	var list			: Array< gui.Item >;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m:Mode, x,y, wid) {
		mode = m;
		mc = mode.depthMan.empty(Data.DP_INTERF);
		depthMan = new DepthManager(mc);

		mc._x = x;
		mc._y = y;
		width = wid;
		currentX = 0;
		currentY = 0;
		scale = 1;
		lineHeight = MIN_HEIGHT;

		list = new Array();
		unlock();
	}


	/*------------------------------------------------------------------------
	GESTION VERROU
	------------------------------------------------------------------------*/
	function lock() {
		fl_lock = true;
	}
	function unlock() {
		fl_lock = false;
	}


	/*------------------------------------------------------------------------
	INSERTION D'UN BOUTON
	------------------------------------------------------------------------*/
	function insert(b:gui.Item) {
		b.scale(scale);
		var endX = currentX + b.width*scale + MARGIN;
		if ( endX > width ) {
			endLine();
			endX = b.width*scale + MARGIN;
		}
		var pt = { x:currentX, y:currentY }

		currentX = endX;

		lineHeight = Math.max( lineHeight, b._height );
		list.push(b);
		return pt;
	}


	/*------------------------------------------------------------------------
	REMPLI LA PROCHAINE LIGNE INCOMPLÈTE
	------------------------------------------------------------------------*/
	function endLine() {
		currentX = 0;
		currentY += lineHeight + MARGIN;
		lineHeight = MIN_HEIGHT*scale;
	}


	/*------------------------------------------------------------------------
	RESIZE
	------------------------------------------------------------------------*/
	function setScale(ratio:float) {
		scale = ratio;
//		mc._xscale = ratio*100;
//		mc._yscale = mc._xscale;
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		for ( var i=0;i<list.length;i++ ) {
			list[i].update();
		}
	}

}