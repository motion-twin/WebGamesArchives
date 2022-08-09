class GameParameters {
	var manager				: GameManager;

	var specialItemFamilies	: Array<int>;
	var scoreItemFamilies	: Array<int>;
	var soundVolume			: float;
	var musicVolume			: float;
	var generalVolume		: float;
	var fl_detail			: bool;
	var fl_shaky			: bool;

	var root				: MovieClip;
	var families			: Array<String>;
	var options				: Hash<bool>;
	var optionList			: Array<String>; // for toString() output only


	/*------------------------------------------------------------------------
	GETTERS
	------------------------------------------------------------------------*/
	function getStr(n) : String {
		return Std.getVar(root,n);
	}
	function getInt(n) : int {
		return Std.parseInt( Std.getVar(root,n), 10 );
	}
	function getBool(n) : bool {
		return Std.getVar(root,n) != "0" && Std.getVar(root,n) != null;
	}


	/*------------------------------------------------------------------------
	CONSTRUCTEUR (default values)
	------------------------------------------------------------------------*/
	function new(mc, man, f, opt) {
		root = mc;
		manager = man;
		if ( Std.isNaN(getInt("$volume")) ) {
			GameManager.warning("missing parameters");
		}

		// Options de jeu (mirror, nightmare...)
		options = new Hash();
		optionList = new Array();
		if ( opt.length>0 ) {
			optionList = opt.split(",");
			for (var i=0;i<optionList.length;i++) {
				options.set( optionList[i], true );
			}
		}

		// Families
		families			= f.split(",");
		scoreItemFamilies	= new Array();
		specialItemFamilies	= new Array();
		for (var i=0;i<families.length;i++) {
			var id = Std.parseInt( families[i], 10 );
			if ( id>=1000 ) {
				scoreItemFamilies.push(id);
			}
			else {
				specialItemFamilies.push(id);
			}
		}

		// Misc data
		generalVolume		= getInt("$volume") * 0.5 / 100 ;
		soundVolume			= getInt("$sound") * generalVolume;
		musicVolume			= getInt("$music") * generalVolume * 0.65;
		fl_detail			= getBool("$detail");
		fl_shaky			= getBool("$shake");

		if (!fl_detail) {
			setLowDetails();
		}

	}


	/*------------------------------------------------------------------------
	MODE BASSE QUALITÉ
	------------------------------------------------------------------------*/
	function setLowDetails() {
		fl_detail = false;
		downcast( Std.getRoot() )._quality = "$medium".substring(1);
		Data.MAX_FX = Math.ceil( Data.MAX_FX*0.5 );
	}



	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LA FAMILLE ID EST DÉBLOQUÉE
	------------------------------------------------------------------------*/
	function hasFamily(id) {
		var fl_found = false;
		for (var i=0;i<specialItemFamilies.length;i++) {
			if ( specialItemFamilies[i]==id ) {
				fl_found = true;
			}
		}
		for (var i=0;i<scoreItemFamilies.length;i++) {
			if ( scoreItemFamilies[i]==id ) {
				fl_found = true;
			}
		}

		return fl_found;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI L'OPTION DEMANDÉE EST ACTIVÉE
	------------------------------------------------------------------------*/
	function hasOption(oid:String) {
		return options.get(oid)==true;
	}


	/*------------------------------------------------------------------------
	RENVOIE UN RÉSUMÉ DE LA CONFIG
	------------------------------------------------------------------------*/
	function toString() {
		var str = "";
		str += "fam="+families.join(", ")+"\n";
		str += "opt="+optionList.join("\n  ")+"\n";
		str += "mus="+musicVolume +"\n";
		str += "snd="+soundVolume +"\n";
		str += "detail="+fl_detail +"\n";
		str += "shaky ="+fl_shaky +"\n";
		return str;
	}


	function hasMusic() {
		return manager.musics[0]!=null;
	}
}

