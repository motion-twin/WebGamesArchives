class gui.ExtendBox
{
	var game: mode.GameMode
	var list : Array< {>MovieClip, letter:MovieClip } >;
	var x : float;
	var y : float;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(g) {
		game = g;
		list = new Array();
		x = Data.DOC_WIDTH-20;
		y = 250;
	}


	/*------------------------------------------------------------------------
	AJOUTE UNE LETTRE
	------------------------------------------------------------------------*/
	function collect(id) {
		var mc : {>MovieClip, letter:MovieClip };
		mc = downcast(game.depthMan.attach("hammer_interf_extend", Data.DP_INTERF));
		mc.letter.gotoAndStop( string(id+1) );
		mc._x = x;
		mc._y = y+id*16;
		mc._xscale = 75;
		mc._yscale = mc._xscale;
		list.push(mc);
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function clear() {
		for (var i=0;i<list.length;i++) {
			list[i].removeMovieClip();
		}
		list = new Array();
	}

}
