class gui.Item extends MovieClip
{
	var field : TextField ;
	var container : gui.Container ;

	var width : float ;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
	}

	/*------------------------------------------------------------------------
	DÉFINI LE LABEL
	------------------------------------------------------------------------*/
	function setLabel(l) {
		field.text = l ;
		width = field.textWidth+5 ;
	}

	/*------------------------------------------------------------------------
	RESIZE
	------------------------------------------------------------------------*/
	function scale(ratio) {
		_xscale = ratio*100;
		_yscale = _xscale;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(c:gui.Container, l:String) {
//		tabEnabled = false;
//		tabChildren = false;
		container = c ;
		setLabel(l) ;
		var p = container.insert(downcast(this)) ;
		_x = p.x ;
		_y = p.y ;
	}


	function update() {
	}

}