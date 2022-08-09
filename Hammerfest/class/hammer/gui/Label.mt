class gui.Label extends gui.Item
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
	}

	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(c:gui.Container, l:String) {
		var b : gui.Label = downcast( c.depthMan.attach("hammer_editor_label", Data.DP_INTERF) );
		b.init(c,l);
		return b;
	}
}