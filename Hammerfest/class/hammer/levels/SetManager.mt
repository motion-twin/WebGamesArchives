class levels.SetManager
{

	var manager				: GameManager;

	var levels				: Array< levels.Data >;
	var raw					: Array<String>;
	var fl_read				: Array<bool>;
	var fl_mirror			: bool;
	var csum				: int;

	var setName				: String;

	var teleporterList		: Array<levels.TeleporterData> ;
	var portalList			: Array<levels.PortalData>;

	private var current		: levels.Data;
	private var currentId	: int;
	private var _previous	: levels.Data;
	private var _previousId	: int;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new( m, s:String ) {
		manager			= m;
		fl_read			= new Array();
		fl_mirror		= false;
		setName			= s;
		teleporterList	= new Array() ;
		portalList		= new Array();

		// Lecture niveaux
		var data = Std.getVar( manager.root, setName );
		raw = data.split(":");
		if ( Std.getVar( manager.root, setName+"_back_xml" ) == null ) {
			Std.setVar( manager.root, setName+"_back_xml", raw.join(":") )
		}
		/*
		csum = 0;
		var list = data.split("0");
		var cc = setName.charCodeAt(3);
		for (var n=0;n<list.length;n++) {
			var l = list[n];
			if(l.length>30)
				csum += l.charCodeAt(cc%5) + l.charCodeAt(cc%9) * l.charCodeAt(cc%15) + l.charCodeAt(cc%19) + l.charCodeAt(cc%22);
		}
//		Log.trace(Md5.encode(setName)+" => "+Md5.encode(""+csum));
		if(GameManager.HH.get("$"+Md5.encode(setName))!="$"+Md5.encode(""+csum)) {GameManager.fatal(""); return;}
		*/

		importCookie();
		if ( raw == null ) {
			GameManager.fatal("Error reading "+setName+" (null value)");
			return;
		}
		levels = new Array();
		levels[raw.length-1] = null; // fix for correct .length attribute
	}


	/*------------------------------------------------------------------------
	DESTRUCTEUR
	------------------------------------------------------------------------*/
	function destroy() {
		suspend();
		levels = new Array();
		fl_read = new Array();
	}


	/*------------------------------------------------------------------------
	�CRASE LE CONTENU DU XML EN M�MOIRE
	------------------------------------------------------------------------*/
	function overwrite( sdata : String ) {
		if ( Std.getVar( manager.root, setName+"_back" ) == null ) {
			Std.setVar( manager.root, setName+"_back", raw.join(":") )
		}
		raw = sdata.split(":");
		Std.setVar( manager.root, setName, sdata );
	}

	/*------------------------------------------------------------------------
	RELIS LA DERNI�RE VERSION SAUVEGARD�E
	------------------------------------------------------------------------*/
	function rollback() {
		if ( Std.getVar( manager.root, setName+"_back" ) != null ) {
			var rawStr = Std.getVar( manager.root, setName+"_back" );
			Std.setVar( manager.root, setName, rawStr )
			raw = rawStr.split(":");
		}
	}


	/*------------------------------------------------------------------------
	RELIS LA VERSION XML COMPIL�E
	------------------------------------------------------------------------*/
	function rollback_xml() {
		var rawStr = Std.getVar( manager.root, setName+"_back_xml" );
		Std.setVar( manager.root, setName, rawStr )
		raw = rawStr.split(":");
	}


	/*------------------------------------------------------------------------
	ALLUME / �TEINT UN FIELD DE T�L�PORTATION
	------------------------------------------------------------------------*/
	function showField(td:levels.TeleporterData) {
		if ( td.fl_on ) {
			return;
		}
		td.fl_on = true;
		td.mc.skin.sub.gotoAndStop("2");
		td.podA.gotoAndStop("2");
		td.podB.gotoAndStop("2");
	}

	function hideField(td) {
		if ( !td.fl_on ) {
			return;
		}
		td.fl_on = false;
		td.mc.skin.sub.gotoAndStop("1");
		td.podA.gotoAndStop("1");
		td.podB.gotoAndStop("1");
	}


	/*------------------------------------------------------------------------
	GESTION VERROU
	------------------------------------------------------------------------*/
	function suspend() {
		// do nothing
	}
	function restore(lid:int) {
		// do nothing
	}


	/*------------------------------------------------------------------------
	D�FINI LE NIVEAU COURANT
	------------------------------------------------------------------------*/
	function setCurrent(id:int) {
		//if(GameManager.HH.get("$"+Md5.encode(setName))!="$"+Md5.encode(""+csum)) {GameManager.fatal(""); return;}
		_previous = current;
		_previousId = currentId;
		current = levels[id];
		currentId = id;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LES DONN�ES SONT PRETES � ETRE UTILIS�ES
	------------------------------------------------------------------------*/
	function isDataReady() {
		return fl_read[currentId];
	}

	function checkDataReady() {
		if ( isDataReady() ) {
			onDataReady();
		}
	}


	/*------------------------------------------------------------------------
	ACTIVE UN NIVEAU DONN�
	------------------------------------------------------------------------*/
	function goto(id:int) {
		teleporterList = new Array() ;
		if ( id>=levels.length ) {
			onEndOfSet();
			id = currentId;
			return;
		}
		if ( !fl_read[id] ) {
			levels[id] = unserialize(id);
		}
		setCurrent(id);
		onReadComplete();
	}

	function next() {
		//if(GameManager.HH.get("$"+Md5.encode(setName))!="$"+Md5.encode(""+csum)) {GameManager.fatal(""); return;}
		goto(currentId+1);
	}


	/*------------------------------------------------------------------------
	D�TRUIT UN NIVEAU DU SET
	------------------------------------------------------------------------*/
	function delete(id) {
		if ( id>=levels.length ) {
			GameManager.fatal("delete after end");
		}
		raw.splice(id,1);
		levels.splice(id,1);
		fl_read.splice(id,1);
	}


	/*------------------------------------------------------------------------
	INS�RE UN NIVEAU DANS LE SET
	------------------------------------------------------------------------*/
	function insert(id:int,data:levels.Data) {
		raw.insert( 	id,	serializeExternal(data) );
		levels.insert(	id,	data );
		fl_read.insert(	id,	true );
	}

	function push(data:levels.Data) {
		raw.push( 		serializeExternal(data) );
		levels.push(	data );
		fl_read.push(	true );
	}


	/*------------------------------------------------------------------------
	INVERSION HORIZONTALE D�FINITIVE
	------------------------------------------------------------------------*/
	function flip( l:levels.Data ) {
		if ( !fl_mirror ) {
			return l;
		}

		var lf			= new levels.Data();
		lf.$playerX		= Data.LEVEL_WIDTH-l.$playerX-1;
		lf.$playerY		= l.$playerY;
		lf.$skinTiles	= l.$skinTiles;
		lf.$skinBg		= l.$skinBg;
		lf.$script		= l.$script;
		lf.$badList		= l.$badList;
		lf.$specialSlots= l.$specialSlots;
		lf.$scoreSlots	= l.$scoreSlots;

		// map
		lf.$map = new Array();
		for (var x=0;x<Data.LEVEL_WIDTH;x++) {
			lf.$map[x] = new Array();
			for (var y=0;y<Data.LEVEL_HEIGHT;y++) {
				lf.$map[x][y] = l.$map[Data.LEVEL_WIDTH-x-1][y]
			}
		}



		/*
		// bads
		for (var i=0;i<l.$badList.length;i++) {
			var b = l.$badList[i];
			lf.$badList.push(
				new levels.BadData(Data.LEVEL_WIDTH-b.$x-1, b.$y, b.$id)
			);
		}

		// special slots
		for (var i=0;i<l.$specialSlots.length;i++) {
			var s = l.$specialSlots[i];
			lf.$specialSlots.push(
				{ $x:Data.LEVEL_WIDTH-s.$x-1,		$y:s.$y }
			);
		}

		// score slots
		for (var i=0;i<l.$scoreSlots.length;i++) {
			var s = l.$scoreSlots[i];
			lf.$scoreSlots.push(
				{ $x:Data.LEVEL_WIDTH-s.$x-1,		$y:s.$y }
			);
		}
		*/

		return lf;
	}


	/*------------------------------------------------------------------------
	INVERSION HORIZONTALE DES PORTALS
	------------------------------------------------------------------------*/
	function flipPortals() {
		var ylist = new Array();
		var list = new Array();
		for (var i=0;i<portalList.length;i++) {
			var p = portalList[i];
			if ( ylist[p.cy]==null ) {
				ylist[p.cy] = new Array();
			}
			ylist[p.cy].push(p);
		}

		for (var y=0;y<ylist.length;y++) {
			if ( ylist[y]!=null ) {
				for (var i=ylist[y].length-1;i>=0;i--) {
					var p = ylist[y][i];
					list.push(p);
				}
			}
		}

		portalList = list;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI L'ID DE LEVEL SP�CIFI� EST VIDE
	------------------------------------------------------------------------*/
	function isEmptyLevel(id, g:mode.GameMode) {
		if ( id>=levels.length ) {
			return true;
		}
		if ( !fl_read[id] ) {
			levels[id] = unserialize(id);
		}
		var ld = levels[id];
		var def = new levels.Data();
		var defX;
		var defY = def.$playerY;

		if ( g==null ) {
			defX = def.$playerX;
		}
		else {
			defX = g.flipCoordCase(def.$playerX);
		}
		return
			ld.$playerX==defX &&
			ld.$playerY==defY &&
			ld.$skinBg==def.$skinBg &&
			ld.$skinTiles==def.$skinTiles &&
			ld.$badList.length==0 &&
			ld.$specialSlots.length==0 &&
			ld.$scoreSlots.length==0;
	}


	// *** ACCESSEURS *****

	/*------------------------------------------------------------------------
	RETOURNE UNE CASE DE LA MAP
	------------------------------------------------------------------------*/
	function getCase(pt) {
		var cx:int=pt.x ;
		var cy:int=pt.y ;
		if (inBound(cx,cy)) {
			if ( cy==0 ) {
				// Les tiles en haut n'agissent pas comme des sols
				if ( current.$map[cx][0]>0 ) {
					return Data.WALL;
				}
				else {
					return 0;
				}
			}
			else {
				return current.$map[cx][cy] ; // dans la zone de jeu
			}
		}
		else
		if ( cy<0 ) {
			if ( current.$map[cx][0]>0 ) {
				return Data.WALL;
			}
			else {
				return 0; // hors �cran haut
			}
		}
		else {
			return Data.OUT_WALL ; // hors �cran bas/gauche/droite
		}
	}

	/*------------------------------------------------------------------------
	MODIFIE DYNAMIQUEMENT UNE CASE
	------------------------------------------------------------------------*/
	function forceCase(cx:int,cy:int, t:int) {
		if ( inBound(cx,cy) ) {
			if (  t<=0  &&  getCase({x:cx,y:cy})>0  &&  getCase({x:cx,y:cy+1})==Data.WALL  ) {
				forceCase( cx, cy+1, Data.GROUND );
			}
			current.$map[cx][cy]=t;
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LES COORDONN�ES DE CASE SONT DANS L'AIRE DE JEU
	------------------------------------------------------------------------*/
	function inBound(cx,cy):bool {
		return cx>=0 && cx<Data.LEVEL_WIDTH && cy>=0 && cy<Data.LEVEL_HEIGHT ;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LA BOUNDING BOX EST DANS L'AIRE DE JEU
	------------------------------------------------------------------------*/
	function shapeInBound(e:Entity):bool {
		return (
			e.x >= -e._width &&
			e.x < Data.GAME_WIDTH &&
			e.y >= -e._height &&
			e.y < Data.GAME_HEIGHT
		);
	}

	/*------------------------------------------------------------------------
	RENVOIE LE PREMIER SOL RENCONTR� A PARTIR D'UNE CASE DONN�E
	------------------------------------------------------------------------*/
	function getGround(cx,cy) : {x:int,y:int} {
		var ty,n;
		for (n=0,ty=cy ; n<=Data.LEVEL_HEIGHT;n++,ty++) {
			if ( ty>0 && getCase( {x:cx,y:ty} ) == Data.GROUND ) {
				return {x:cx,y:ty-1};
			}
			if ( ty>=Data.LEVEL_HEIGHT ) {
				ty=0;
			}
		}

		return {x:cx,y:cy};

	}


	// *** CALLBACKS *****

	/*------------------------------------------------------------------------
	EVENT: LECTURE DES NIVEAUX TERMIN�E
	------------------------------------------------------------------------*/
	function onReadComplete() {
		checkDataReady();
	}


	/*------------------------------------------------------------------------
	EVENT: DONN�ES PR�TES
	------------------------------------------------------------------------*/
	function onDataReady() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DU SET DE LEVELS
	------------------------------------------------------------------------*/
	function onEndOfSet() {
		// do nothing
	}


	function onRestoreReady() {
		// do nothing
	}



	// *** ENCODING *****

	/*------------------------------------------------------------------------
	FONCTIONS DE SERIALIZATION
	------------------------------------------------------------------------*/
	function unserialize(id) : levels.Data {
		//if(GameManager.HH.get("$"+Md5.encode(setName))!="$"+Md5.encode(""+csum)) {GameManager.fatal(""); return null;}
		var l : levels.Data = Std.cast(  (new PersistCodec()).decode(raw[id])  );
		if ( fl_mirror ) {
			l = flip(l);
		}
		convertWalls(l);
		if ( l.$specialSlots==null || l.$scoreSlots==null ) {
			GameManager.warning("empty slot array found ! spec="+l.$specialSlots.length+" score="+l.$scoreSlots.length);
		}
		fl_read[id]=true;
		return l;
	}

	function serialize(id) : String {
		convertWalls(levels[id]);
		var l = (new PersistCodec()).encode( levels[id] );
		return l;
	}

	function serializeExternal(l : levels.Data) {
		convertWalls(l);
		return (new PersistCodec()).encode( l );
	}

	function convertWalls(l) {
		var map = l.$map;
		for (var cy=0;cy<Data.LEVEL_HEIGHT;cy++) {
			for (var cx=0;cx<Data.LEVEL_WIDTH;cx++) {
				if (map[cx][cy]==Data.WALL) {
					map[cx][cy] = Data.GROUND;
					GameManager.warning("found wall @ "+cx+","+cy);
				}
			}
		}
	}



	// *** COOKIES ***

	/*------------------------------------------------------------------------
	EXPORT
	------------------------------------------------------------------------*/
	function exportCookie() {
		if ( !manager.fl_cookie ) {
			return;
		}
		manager.cookie.saveSet(  setName, raw.join(":")  );
	}

	/*------------------------------------------------------------------------
	IMPORT
	------------------------------------------------------------------------*/
	function importCookie() {
		if ( !manager.fl_cookie ) {
			return;
		}
		var rawStr = manager.cookie.readSet(  setName  );
		if ( rawStr!=null ) {
			raw = rawStr.split(":");
		}
		else {
			exportCookie();
		}
	}



	// *** MISC ***


	/*------------------------------------------------------------------------
	DEBUG
	------------------------------------------------------------------------*/
	function trace(id:int) {
		Log.trace("Total size: "+levels.length+" level(s)")
		if (id!=null) {
			Log.trace("Level "+id+":");
			Log.trace("player: "+current.$playerX+","+current.$playerY);
			Log.trace(current.$map);
		}
	}


	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function update() {
		// do nothing
	}

}