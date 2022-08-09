class Cookie {
	static var NAME = "$hammerfest_data";
	static var VERSION = 4;


	var cookie	: SharedObject;
	var manager	: GameManager;
	var data : {
		version		: int,
		lastModified: int,
		// ... following level bulk data (setVar/getVar)
	};



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m) {
		manager	= m;
		cookie	= SharedObject.getLocal(NAME);
		data	= downcast(cookie.data);

		checkVersion();
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function reset() {
		cookie.clear();
		data			= downcast(cookie.data);
		data.version	= VERSION;
		flush();
	}

	/*------------------------------------------------------------------------
	ENREGISTRE LE COOKIE
	------------------------------------------------------------------------*/
	function flush() {
		data.lastModified = new Date().getTime();
		cookie.flush();
	}


	/*------------------------------------------------------------------------
	VÉRIFIE LA VERSION DU COOKIE
	------------------------------------------------------------------------*/
	function checkVersion() {
		var ver : int = data.version;
		if (  ver!=VERSION || Key.isDown(Key.CONTROL)  ) {
			if (  ver==null || Key.isDown(Key.CONTROL)  ) {
				if ( manager.fl_debug ) {
					GameManager.warning("Cookie initialized to version "+VERSION);
				}
				reset();
			}
			else {
				GameManager.fatal("invalid cookie version (compiled="+VERSION+" local="+ver+")");
				GameManager.fatal("note: Hold CTRL at start-up to clear cookie");
			}
		}
	}


	/*------------------------------------------------------------------------
	RUNTIME => COOKIE
	------------------------------------------------------------------------*/
	function saveSet(name:String, raw:String) {
		Std.setVar( downcast(data), name, raw);
		flush();
	}


	/*------------------------------------------------------------------------
	COOKIE => RUNTIME
	------------------------------------------------------------------------*/
	function readSet(name:String) : String {
		return Std.getVar( downcast(data), name );
	}
}

