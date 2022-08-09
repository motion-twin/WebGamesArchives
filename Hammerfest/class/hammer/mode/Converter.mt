class mode.Converter extends Mode {

	static var SETS = [
//		"$menu",
		"$tutorial",
		"$adventure",
//		"$multi",
	];

	var world : levels.SetManager;
	var currentSet : int;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m) {
		super(m);
		_name = "$converter";

		Log.trace("Hit ENTER to start.");
		Log.trace("ESCAPE to quit.");
		currentSet = 0;
	}


	/*------------------------------------------------------------------------
	LIT LE SET SUIVANT
	------------------------------------------------------------------------*/
	function readNext() {
		world = new levels.SetManager(manager,SETS[currentSet]);
		world.goto(0);
		Log.trace("Reading set "+currentSet+" : "+world.setName);
		Log.trace("Content : "+world.levels.length+" levels");
		currentSet++;
	}



	/*------------------------------------------------------------------------
	CONVERSION!
	------------------------------------------------------------------------*/
	function convert() {
		var id = 100; // start id
		var raw = new Array();

		Log.trace("------");

		for (var i=0;i<world.levels.length;i++) {
			world.goto(i);

			/*** CONVERSION PROCESS ***/
			var l = world.levels[i];
			Log.trace("> Processing "+i+"...");
			var doc = new Xml( l.$script );
			var node = doc.firstChild;
			while ( node!=null ) {
				var child = node.firstChild;
				while ( child!=null ) {
					if ( child.nodeName=="$e_msg" || child.nodeName=="$e_tuto" ) {
						var str = child.firstChild.nodeValue;
						if ( str!=null ) {
							str = Tools.replace( str, String.fromCharCode(13), "");
							str = Tools.replace( str, String.fromCharCode(10), "");
							Log.trace("FOUND: "+str);
							raw.push('<t id="'+id+'" v="'+str+'"/>');
							id++;
						}
					}
					child = child.nextSibling;
				}
				node = node.nextSibling;
			}
			/*** END OF PROCESS ***/
		}
		Log.trace("Done, copied to system clipboard.");
		Log.trace("Hit ENTER to start next one.");
		System.setClipboard( raw.join("\n") );
	}


	/*------------------------------------------------------------------------
	SERIALIZATION
	------------------------------------------------------------------------*/
	function serialize( d:levels.Data/*[..]Converted*/ ) {
		return (new PersistCodec()).encode( d );
	}
	function unserialize( s:String ) {
		return (new PersistCodec()).decode( s );
	}


	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function main() {
		super.main();
		if ( Key.isDown(Key.ENTER) || Key.isDown(Key.SPACE) ) {
			if ( SETS[currentSet]==null ) {
				Log.trace("All done.");
			}
			else {
				readNext();
				convert();
			}
		}
		if ( Key.isDown(Key.ESCAPE) ) {
			Log.clear();
			endMode();
		}
	}

}