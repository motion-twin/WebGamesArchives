class gui.Field extends gui.Item
{
	var field : TextField;
	var bg : MovieClip;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		field.text="";
	}

	function initField(c) {
		setWidth(50);
		scale(1);
		init( c, getField() );
	}

	function setWidth(w) {
		field._width = w;
		bg._width = w+5;
		width = w+10;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(c:gui.Container) {
		var mc : gui.Field = downcast( c.depthMan.attach("hammer_editor_field", Data.DP_INTERF) ) ;
		mc.initField(c);
		return mc;
	}


	/*------------------------------------------------------------------------
	AFFECTATION / LECTURE
	------------------------------------------------------------------------*/
	function setField(s:String) {
		field.text = s;
	}

	function getField() {
		return field.text;
	}

	function setLabel(s) {
		setField(s);
	}
}