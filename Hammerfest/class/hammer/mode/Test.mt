class mode.Test extends Mode {

	var world : levels.SetManager;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m) {
		super(m);
		_name = "$test";
	}




	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function main() {
		super.main();
		Log.print(_name);
		if ( Key.isDown(Key.ESCAPE) ) {
			endMode();
		}
	}

}