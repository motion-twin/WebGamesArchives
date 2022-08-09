class mode.Editor extends Mode
{
	static var DIMENSIONS = [
		{ name:"xml_adventure",		id:0 },
		{ name:"xml_deepnight",		id:1 },
		{ name:"xml_hiko",			id:2 },
		{ name:"xml_ayame",			id:3 },
		{ name:"xml_hk",			id:4 },
	];


	var setName			: String;

	var world			: levels.SetManager;
	var view			: levels.View;
	var buffer			: levels.Data;
	var styleBuffer		: levels.Data;
	var firstLevel		: int;
	var firstSet		: String;
	var dimensionId		: int;

	var badList			: Array<Entity>;

	var fl_menu			: bool;
	var fl_lockToggle	: bool;
	var fl_lockFollow	: bool;
	var fl_click		: bool;
	var fl_modified		: Array<bool>;

	var fl_save			: bool;
	var save_currentId	: int;
	var save_raw		: Array<String>

	// Interface
	var menuC			: gui.Container;
	var tileButton		: gui.SimpleButton;
	var badButton		: gui.SimpleButton;
	var fieldButton		: gui.SimpleButton;
	var startButton		: gui.SimpleButton;
	var specialSlotButton: gui.SimpleButton;
	var scoreSlotButton	: gui.SimpleButton;

	var cursor			: MovieClip;
	var cx				: int;
	var cy				: int;

	var log				: TextField;
	var logMC			: MovieClip;
	var bList			: Array<MovieClip>;
	var fieldList		: Array<TextField>;
	var fields			: MovieClip;

	var tool			: int;
	var badId			: int;
	var fieldId			: int;

	var startMc			: MovieClip;
	var currentBad		: MovieClip;
	var borders			: MovieClip;
	var header			: { >MovieClip, field:TextField, scriptIcon:MovieClip };
	var footer			: { >MovieClip, field:TextField, scriptIcon:MovieClip };

	var slotList		: Array<MovieClip>;
	var triggerList		: Array< { >MovieClip, field:TextField} >;

	var resetConfirm	: float;

	var input			: String;
	var lastKey			: int;
	var lastPoint		: {cx:int,cy:int};




	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,fset,id) {
		super(m);
		_name			= "$editor";
		xOffset			= 10;
		fl_menu			= true;
		fl_click		= false;
		fl_modified		= new Array();
		badList			= new Array();
		badId			= 0;
		slotList		= new Array();
		triggerList		= new Array();
		fieldList		= new Array();
		fieldId			= 1;
		tool			= Data.TOOL_TILE;
		resetConfirm	= 0;
		firstLevel		= id;
		firstSet		= fset;
		input			= "";

		fields = depthMan.empty(Data.DP_INTERF);

		header = downcast(  depthMan.attach("hammer_editor_footer", Data.DP_INTERF)  );
		header._x = Data.DOC_WIDTH*0.5;
		header._y = 9;
		header.scriptIcon._visible = false;

		footer = downcast(  depthMan.attach("hammer_editor_footer", Data.DP_INTERF)  );
		footer._x = Data.DOC_WIDTH*0.5;
		footer._y = Data.DOC_HEIGHT-9;

		lock();
	}


	// *** DIVERS

	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init() {
		super.init();

		// Souris
		cursor = depthMan.attach("hammer_editor_cursor",Data.DP_INTERF);
		cursor._width = Data.CASE_WIDTH;
		cursor._height = Data.CASE_HEIGHT;
		updateCursor();
		var me = this;
		root.onMouseDown = fun() { me.mouseDown() };
		root.onMouseUp = fun() { me.mouseUp() };

		// Bords
		borders = depthMan.attach("hammer_editor_borders", Data.DP_INTERF);
		borders._x -= 10;

		attachMenu();
		toggleMenu();

		loadSet(firstSet);
		redrawAll();
		unlock();
	}


	/*------------------------------------------------------------------------
	DÉFINI LE FICHIER XML SOURCE
	------------------------------------------------------------------------*/
	function loadSet(n) {
		setName = n;

		dimensionId = null;
		for (var i=0;i<DIMENSIONS.length;i++) {
			if ( DIMENSIONS[i].name == setName ) {
				dimensionId = DIMENSIONS[i].id;
			}
		}

		view.destroy();
		world.destroy();
		world = new levels.SetManager(manager,setName);
		world.goto(
			int(  Math.min(firstLevel,world.levels.length-1)  )
		);
		firstLevel = 0;
		lastPoint = null;
		fl_modified = new Array();
	}


	/*------------------------------------------------------------------------
	ATTACH: MENU
	------------------------------------------------------------------------*/
	function attachMenu() {
		// Container virtuel
		menuC = new gui.Container(this, 5,10, Data.DOC_WIDTH-10);

		// Log
		logMC = depthMan.attach("hammer_editor_log",Data.DP_INTERF);
		logMC._x = 6;
		logMC._y = 250;
		log = downcast(logMC).field;
		cls();

		// Attachement du menu
		gui.SimpleButton.attach( menuC, " QUIT ", null, callback(this,onQuit) );
		gui.SimpleButton.attach( menuC, " Test level", 84, callback(this,onTest) );
		gui.SimpleButton.attach( menuC, " Browser", 222, callback(this,onBrowse) );
		gui.SimpleButton.attach( menuC, " Script", Key.ENTER, callback(this,onScript) );
		gui.SimpleButton.attach( menuC, " Items", 73, callback(this,onItemBrowser) );
		gui.SimpleButton.attach( menuC, " Quests", 81, callback(this,onQuestBrowser) );
		gui.SimpleButton.attach( menuC, " Game", 71, callback(this,onStartGame) );
		menuC.endLine();

		gui.Label.attach( menuC, "disk:" );
		var b;
		b = gui.SimpleButton.attach( menuC, "load all", 76, callback(this,onLoadAll) );
		b.setToggleKey(Key.SHIFT);
		b = gui.SimpleButton.attach( menuC, "save all", 83, callback(this,onSaveAll) );
		b.setToggleKey(Key.SHIFT);
		gui.SimpleButton.attach( menuC, " reset cookie ", null, callback(this,onCookieReset) );
//		gui.SimpleButton.attach( menuC, " load ", 76, callback(this,onLoadLevel) );
//		gui.SimpleButton.attach( menuC, " save ", 83, callback(this,onSaveLevel) );
		menuC.endLine();

		gui.Label.attach( menuC, "files:" );
		gui.SimpleButton.attach( menuC, " adv", null, callback(this,onLoadAdv) );
		gui.SimpleButton.attach( menuC, " tuto", null, callback(this,onLoadTuto) );
		gui.SimpleButton.attach( menuC, " sharew", null, callback(this,onLoadShare) );
		gui.SimpleButton.attach( menuC, " dev", null, callback(this,onLoadDev) );
		gui.SimpleButton.attach( menuC, " test", null, callback(this,onLoadTest) );
		gui.SimpleButton.attach( menuC, " time", null, callback(this,onLoadTime) );
		gui.SimpleButton.attach( menuC, " mtime", null, callback(this,onLoadMultiTime) );
		gui.SimpleButton.attach( menuC, " soccer", null, callback(this,onLoadSoccer) );
		gui.SimpleButton.attach( menuC, " HoF", null, callback(this,onLoadHof) );
		gui.SimpleButton.attach( menuC, " FJV", null, callback(this,onLoadFjv) );

		gui.SimpleButton.attach( menuC, " deep", null, callback(this,onLoadDeep) );
		gui.SimpleButton.attach( menuC, " hiko", null, callback(this,onLoadHiko) );
		gui.SimpleButton.attach( menuC, " ayame", null, callback(this,onLoadAyame) );
		gui.SimpleButton.attach( menuC, " HK", null, callback(this,onLoadHk) );
		menuC.endLine();

		gui.Label.attach( menuC, "nav:" );
		gui.SimpleButton.attach( menuC, "<", 33, callback(this,onPrevLevel) );
		gui.SimpleButton.attach( menuC, ">", 34, callback(this,onNextLevel) );
		b = gui.SimpleButton.attach( menuC, "<<", 33, callback(this,onPrevLevelFast) );
		b.setToggleKey(Key.SHIFT);
		b = gui.SimpleButton.attach( menuC, ">>", 34, callback(this,onNextLevelFast) );
		b.setToggleKey(Key.SHIFT);
		b = gui.SimpleButton.attach( menuC, " first ", Key.HOME, callback(this,onFirstLevel) );
		b = gui.SimpleButton.attach( menuC, " last ", Key.END, callback(this,onLastLevel) );
		gui.SimpleButton.attach( menuC, " CLEAR ", null, callback(this,onNew) );
		menuC.endLine();

		gui.Label.attach( menuC, "buffer:" );
		gui.SimpleButton.attach( menuC, " copy ", 67, callback(this,onCopy) );
		gui.SimpleButton.attach( menuC, " paste ", 86, callback(this,onPaste) );
		gui.Label.attach( menuC, "style:" );
		b = gui.SimpleButton.attach( menuC, " copy ", 67, callback(this,onStyleCopy) );
		b.setToggleKey(Key.SHIFT);
		b = gui.SimpleButton.attach( menuC, " paste ", 86, callback(this,onStylePaste) );
		b.setToggleKey(Key.SHIFT);
		menuC.endLine();

		gui.Label.attach( menuC, "bg:" );
		gui.SimpleButton.attach( menuC, "<", null, callback(this,onPrevBg) );
		gui.SimpleButton.attach( menuC, ">", null, callback(this,onNextBg) );
		gui.Label.attach( menuC, "skin:" );
		gui.SimpleButton.attach( menuC, "<", null, callback(this,onPrevTiles) );
		gui.SimpleButton.attach( menuC, ">", null, callback(this,onNextTiles) );
		gui.Label.attach( menuC, "col:" );
		gui.SimpleButton.attach( menuC, "<", null, callback(this,onPrevColumn) );
		gui.SimpleButton.attach( menuC, ">", null, callback(this,onNextColumn) );
		gui.SimpleButton.attach( menuC, "==", null, callback(this,onResetColumn) );
		menuC.endLine();

		gui.Label.attach( menuC, "tools:" );
		tileButton = gui.SimpleButton.attach( menuC, " tiles ", 49, callback(this,onSelectTile) );
		startButton = gui.SimpleButton.attach( menuC, " S ", 50, callback(this,onSelectStart) );
		gui.SimpleButton.attach( menuC, "<", null, callback(this,onPrevBad) );
		badButton = gui.SimpleButton.attach( menuC, "      ", 51, callback(this,onSelectBad) );
		gui.SimpleButton.attach( menuC, ">", null, callback(this,onNextBad) );

		gui.SimpleButton.attach( menuC, "<",null, callback(this,onPrevField) );
		fieldButton = gui.SimpleButton.attach( menuC, " field ", 52, callback(this,onSelectField) );
		gui.SimpleButton.attach( menuC, ">", null, callback(this,onNextField) );
		specialSlotButton = gui.SimpleButton.attach( menuC, " specialSlot ", 53, callback(this,onSelectSpecial) );
		scoreSlotButton = gui.SimpleButton.attach( menuC, " scoreSlot ", 54, callback(this,onSelectScore) );

		gui.Label.attach( menuC, "panning:" );
		b = gui.SimpleButton.attach( menuC, " left ", Key.LEFT, callback(this,onPanLeft) );
		b.setToggleKey(Key.SHIFT);
		b = gui.SimpleButton.attach( menuC, " right ", Key.RIGHT, callback(this,onPanRight) );
		b.setToggleKey(Key.SHIFT);
		b = gui.SimpleButton.attach( menuC, " up ", Key.UP, callback(this,onPanUp) );
		b.setToggleKey(Key.SHIFT);
		b = gui.SimpleButton.attach( menuC, " down ", Key.DOWN, callback(this,onPanDown) );
		b.setToggleKey(Key.SHIFT);
	}


	/*------------------------------------------------------------------------
	AFFICHE/MASQUE LE MENU
	------------------------------------------------------------------------*/
	function toggleMenu() {
		if ( fl_save ) {
			return;
		}
		fl_menu = !fl_menu;
		menuC.mc._visible = fl_menu;
		logMC._visible = fl_menu;
		currentBad._visible = fl_menu;
		cursor._visible = !fl_menu;

		if ( fl_menu ) {
			hideCaseCursor();
		}
		else {
			showCaseCursor();
		}
	}


	/*------------------------------------------------------------------------
	TRACE SUR LA SORTIE DE LOG
	------------------------------------------------------------------------*/
	function display(txt:String) {
		if ( txt==null )
		cls();
		else {
			var str = new String(log.text);
			str += "~ "+txt+"\n";
			log.text = str;
			while ( log.textHeight > log._height )
			log.text = log.text.substr( log.text.indexOf("~",2),999999 );
		}
	}


	/*------------------------------------------------------------------------
	VIDE LA SORTIE LOG
	------------------------------------------------------------------------*/
	function cls() {
		log.text = "";
	}


	/*------------------------------------------------------------------------
	REDESSINE LE NIVEAU EN COURS
	------------------------------------------------------------------------*/
	function redrawAll() {
		redrawView();
		redrawBads();
		redrawSlots();
		redrawScript();
	}

	function redrawView() {
		if ( view.fl_attach ) {
			view.detach();
			view.displayCurrent();
		}
		else {
			view = new levels.View(world, depthMan);
			view.fl_hideBorders = true;
			view.xOffset = 0;
			view.detach();
			view.displayCurrent();
		}
		view.updateSnapShot();

		// Portal IDs
		for (var i=0;i<fieldList.length;i++) {
			fieldList[i].removeTextField();
		}
		fieldList = new Array();
		for (var i=0;i<world.portalList.length;i++) {
			var tf			= Std.createTextField(fields,manager.uniq++);;
			var p			= world.portalList[i];
			tf._x			= Entity.x_ctr(p.cx) - Data.CASE_WIDTH*0.2;
			tf._y			= Entity.y_ctr(p.cy) - Data.CASE_HEIGHT*0.5;
			tf.textColor	= 0xffffff;
			var link = Data.getLink(dimensionId, world.currentId, i);
			tf.text			= ""+i;
			if ( link==null ) {
				tf.text			+= " > ??";
				tf.textColor	= 0xff5500;
			}
			else {
				if ( link.to_did == dimensionId ) {
					tf.text+=" > "+link.to_lid;
				}
				else {
					tf.text+=" > "+link.to_did+","+link.to_lid;
				}
			}
			if ( tf._x + tf.textWidth >= Data.GAME_WIDTH ) {
				tf._x = Data.GAME_WIDTH - tf.textWidth;
			}
			if ( tf._y + tf.textHeight >= Data.GAME_HEIGHT ) {
				tf._y = Data.GAME_HEIGHT - tf.textHeight;
			}
			tf.selectable	= false;
			fieldList.push(tf);
		}


		startMc.removeMovieClip();
		startMc = depthMan.attach("hammer_editor_start",Data.DP_BADS);
		startMc._x = world.current.$playerX * Data.CASE_WIDTH;
		startMc._y = world.current.$playerY * Data.CASE_HEIGHT;

	}



	function redrawBads() {
		// Bads
//		destroyList(Data.ENTITY);
//		for (var i=0;i<world.current.badList.length;i++) {
//			var b = world.current.badList[i];
//			var bad = attachBad( b.id, Data.CASE_WIDTH*b.x, Data.CASE_HEIGHT*b.y );
//			bad._xscale = Math.abs(bad._xscale);
//		}

		for (var i=0;i<bList.length;i++) {
			bList[i].removeMovieClip();
		}
		bList = new Array();
		var perfect=1;
		for (var i=0;i<world.current.$badList.length;i++) {
			var b = world.current.$badList[i];
			var mc;
			var x = Entity.x_ctr(b.$x);
			var y = Entity.y_ctr(b.$y);

			mc = depthMan.attach("hammer_editor_bad_bg", Data.DP_BADS);
			mc._x = x;
			mc._y = y;
			if ( b.$id!=13 && b.$id!=3 && b.$id!=15 ) {
				downcast(mc).field.text = perfect;
				perfect++;
			}
			else {
				downcast(mc).field.text = "";
			}
			bList.push(mc);

			mc = depthMan.attach(Data.LINKAGES[b.$id], Data.DP_BADS)
			mc._x = x;
			mc._y = y;
			if ( mc._height>1.2*Data.CASE_HEIGHT ) {
				var scale = 1.2*Data.CASE_HEIGHT / mc._height;
				mc._xscale = scale*100;
				mc._yscale = scale*100;
			}
			mc.stop();
			downcast(mc).sub.stop();
			bList.push(mc);

		}

		updateBad();
	}


	function redrawSlots() {
		for (var i=0;i<slotList.length;i++) {
			slotList[i].removeMovieClip();
		}
		slotList = new Array();
		for (var i=0;i<world.current.$scoreSlots.length;i++) {
			var pt = world.current.$scoreSlots[i];
			var mc = depthMan.attach("hammer_editor_slot_score", Data.DP_ITEMS);
			mc._x = Entity.x_ctr(pt.$x);
			mc._y = Entity.y_ctr(pt.$y);
			slotList.push(mc);
		}

		for (var i=0;i<world.current.$specialSlots.length;i++) {
			var pt = world.current.$specialSlots[i];
			var mc = depthMan.attach("hammer_editor_slot_special", Data.DP_ITEMS);
			mc._x = Entity.x_ctr(pt.$x);
			mc._y = Entity.y_ctr(pt.$y);
			slotList.push(mc);
		}
	}


	function redrawScript() {
		for (var i=0;i<triggerList.length;i++) {
			triggerList[i].removeMovieClip();
		}
		triggerList = new Array();
		var doc = new Xml(world.current.$script);
		var trigger = doc.firstChild;
		while (trigger!=null ) {
			var cx = Std.parseInt( trigger.get("$x"), 10 );
			var cy = Std.parseInt( trigger.get("$y"), 10 );
			if ( !Std.isNaN(cx) && !Std.isNaN(cy) ) {
				var mc : { >MovieClip, field:TextField};
				mc = downcast( depthMan.attach("hammer_editor_trigger", Data.DP_ITEMS) );
				mc._x = Entity.x_ctr(cx)-Data.CASE_WIDTH*0.5;
				mc._y = Entity.y_ctr(cy)-Data.CASE_HEIGHT;
				mc.field.text = trigger.nodeName.substring(1);
				triggerList.push(mc);
			}
			trigger = trigger.nextSibling;
		}
	}


	/*------------------------------------------------------------------------
	MET À JOUR LE FOOTER
	------------------------------------------------------------------------*/
	function updateFooter() {
		footer.field.text =
			"Set: "+setName+
			" | Level: "+world.currentId+"/"+(world.levels.length-1);
		if ( fl_modified[world.currentId] ) {
			footer.field.text+=" (MODIFIED)";
			footer.field.textColor = 0xff0000;
		}
		else {
			if ( world.current.$specialSlots.length==0 || world.current.$scoreSlots.length==0 ) {
				footer.field.textColor = 0x5555ff;
			}
			else {
				footer.field.textColor = 0xffffff;
			}
		}

		if ( world.current.$script!="" && world.current.$script!=null ) {
			footer.scriptIcon._visible = true;
		}
		else {
			footer.scriptIcon._visible = false;
		}
	}



	/*------------------------------------------------------------------------
	LANCE UN NIVEAU DONNÉ
	------------------------------------------------------------------------*/
	function goto(id) {
		id = int( Math.max(id,0) );
		id = int( Math.min(id,world.levels.length-1) );

		display("Level "+id);

		view.detach();
		world.goto(id);
		lastPoint = null;

		redrawAll();
	}


	/*------------------------------------------------------------------------
	UPDATE DU MENU
	------------------------------------------------------------------------*/
	function updateMenu() {
		fieldButton.setLabel( Data.FIELDS[fieldId] );

		tileButton.rollOut();
		startButton.rollOut();
		badButton.rollOut();
		fieldButton.rollOut();
		specialSlotButton.rollOut();
		scoreSlotButton.rollOut();

		switch(tool) {
			case Data.TOOL_TILE :
				tileButton.rollOver();
			break;
			case Data.TOOL_BAD :
				badButton.rollOver();
			break;
			case Data.TOOL_FIELD :
				fieldButton.rollOver();
			break;
			case Data.TOOL_START :
				startButton.rollOver();
			break;
			case Data.TOOL_SPECIAL :
				specialSlotButton.rollOver();
			break;
			case Data.TOOL_SCORE :
				scoreSlotButton.rollOver();
			break;
		}
	}


	/*------------------------------------------------------------------------
	UPDATE DU BAD SÉLECTIONNÉ
	------------------------------------------------------------------------*/
	function updateBad() {
		currentBad.removeMovieClip();
		currentBad = depthMan.attach(Data.LINKAGES[badId], Data.DP_INTERF);
		currentBad.stop();
		downcast(currentBad).sub.stop();
		currentBad._x = badButton._x+20;
		currentBad._y = badButton._y+30;
		currentBad._xscale = 60;
		currentBad._yscale = currentBad._xscale;
		currentBad._visible = fl_menu;
		currentBad.onRelease = callback(this, onSelectBad);
	}


	/*------------------------------------------------------------------------
	TRACE OU EFFACE UN CARRÉ
	------------------------------------------------------------------------*/
	function square(cx1,cy1, cx2,cy2) {
		if ( cx1>cx2 ) { var tmp=cx1;cx1=cx2;cx2=tmp; }
		if ( cy1>cy2 ) { var tmp=cy1;cy1=cy2;cy2=tmp; }
		for (var x=cx1;x<=cx2;x++) {
			for (var y=cy1;y<=cy2;y++) {
				if ( Key.isDown(Key.CONTROL) ) {
					world.current.$map[x][y] = 0;
				}
				else {
					world.current.$map[x][y] = 1;
				}
			}
		}
	}


	/*------------------------------------------------------------------------
	AJOUTE UN ÉLÉMENT
	------------------------------------------------------------------------*/
	function paint(cx,cy) {
		if ( menuC.fl_lock ) {
			return;
		}

		switch (tool) {
			case Data.TOOL_TILE :
//				Log.trace(lastPoint.cx+","+lastPoint.cy);
				if ( Key.isDown(Key.SHIFT) && lastPoint!=null ) {
					square(lastPoint.cx,lastPoint.cy, cx,cy);
					lastPoint = null;
				}
				else {
					world.current.$map[cx][cy] = 1;
					lastPoint = {cx:cx,cy:cy};
				}
			break;
			case Data.TOOL_BAD :
				var found = false;
				var data = { $id:badId, $x:cx, $y:cy };
				world.current.$badList.push(data);
				redrawBads();
			break;
			case Data.TOOL_FIELD :
				world.current.$map[cx][cy] = -fieldId;
			break;
			case Data.TOOL_START :
				world.current.$playerX = cx;
				world.current.$playerY = cy;
			break;
			case Data.TOOL_SPECIAL :
				if ( world.current.$specialSlots == null ) {
					GameManager.warning("warning: null special slots array !");
				}
				world.current.$specialSlots.push( {$x:cx,$y:cy} );
				redrawSlots();
			break;

			case Data.TOOL_SCORE :
				world.current.$scoreSlots.push( {$x:cx,$y:cy} );
				redrawSlots();
			break;
		}

		setModified(world.currentId);
	}


	/*------------------------------------------------------------------------
	SUPPRIME LE CONTENU D'UNE CASE
	------------------------------------------------------------------------*/
	function remove(cx,cy) {
		var fl_break=false;
		if ( menuC.fl_lock ) {
			return;
		}

		world.current.$map[cx][cy] = 0;
		for (var i=0;i<world.current.$badList.length && !fl_break;i++) {
			var b = world.current.$badList[i];
			if ( b.$x==cx && b.$y==cy ) {
				world.current.$badList.splice(i,1);
				redrawBads();
				fl_break = true;
			}
		}


		for (var i=0;i<world.current.$scoreSlots.length && !fl_break;i++) {
			var pt = world.current.$scoreSlots[i];
			if ( pt.$x==cx && pt.$y==cy ) {
				world.current.$scoreSlots.splice(i,1);
				redrawSlots();
				fl_break = true;
			}
		}

		for (var i=0;i<world.current.$specialSlots.length && !fl_break;i++) {
			var pt = world.current.$specialSlots[i];
			if ( pt.$x==cx && pt.$y==cy ) {
				world.current.$specialSlots.splice(i,1);
				redrawSlots();
				fl_break = true;
			}
		}

		setModified(world.currentId);
	}


	/*------------------------------------------------------------------------
	TESTE LE CONTENU D'UNE CASE
	------------------------------------------------------------------------*/
	function isEmpty(cx,cy):bool {
		var fl_empty = world.current.$map[cx][cy]==0;

		for (var i=0;i<world.current.$badList.length;i++) {
			var b = world.current.$badList[i];
			if ( b.$x==cx && b.$y==cy ) {
				fl_empty = false;
			}
		}

		for (var i=0;i<world.current.$scoreSlots.length;i++) {
			var pt = world.current.$scoreSlots[i];
			if ( pt.$x==cx && pt.$y==cy ) {
				fl_empty = false;
			}
		}

		for (var i=0;i<world.current.$specialSlots.length;i++) {
			var pt = world.current.$specialSlots[i];
			if ( pt.$x==cx && pt.$y==cy ) {
				fl_empty = false;
			}
		}

		return fl_empty;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI AU MOINS UN LEVEL EST MODIFIÉ ET NON SAUVÉ
	------------------------------------------------------------------------*/
	function anyModified() {
		var fl_anyMod = false;
		for (var i=0;i<fl_modified.length;i++) {
			fl_anyMod = fl_modified[i] || fl_anyMod;
		}
		return fl_anyMod;
	}


	/*------------------------------------------------------------------------
	QUITTER
	------------------------------------------------------------------------*/
	function endMode() {
		manager.startGameMode( new mode.Adventure(manager, 1) );
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		hideCaseCursor();
		super.destroy();
	}


	/*------------------------------------------------------------------------
	FLAG UN LEVEL COMME MODIFIÉ ET NON SAUVÉ
	------------------------------------------------------------------------*/
	function setModified(lid) {
		fl_modified[lid] = true;
		if ( view.levelId == lid ) {
			view.updateSnapShot();
		}
	}



	// *** CONTROLES

	/*------------------------------------------------------------------------
	UPDATE LE CURSEUR DE SOURIS
	------------------------------------------------------------------------*/
	function updateCursor() {
		cx = Math.floor((root._xmouse-xOffset)/Data.CASE_WIDTH);
		cy = Math.floor(root._ymouse/Data.CASE_HEIGHT);

		if ( cx<0 ) cx=0;
		if ( cx>=Data.LEVEL_WIDTH ) cx=Data.LEVEL_WIDTH-1;
		if ( cy<0 ) cy=0;
		if ( cy>=Data.LEVEL_HEIGHT ) cy=Data.LEVEL_HEIGHT-1;

		cursor._x = cx * Data.CASE_WIDTH;
		cursor._y = cy * Data.CASE_HEIGHT;
		cursor.gotoAndStop(  "" + (tool-Data.TOOL_TILE+1)  );

		// Force le pointeur de souris
		if ( !fl_menu && !fl_lock ) {
			if ( Key.isDown(Key.SHIFT) ) {
				header.field.text = "Real coords : "+root._xmouse+","+root._ymouse;
			}
			else {
				showCaseCursor();
				header.field.text = "Case coords : "+cx+","+cy;
			}
		}
	}


	/*------------------------------------------------------------------------
	AFFICHE / MASQUE LE CURSEUR CASE
	------------------------------------------------------------------------*/
	function showCaseCursor() {
		Mouse.hide();
		cursor._visible = true;
	}
	function hideCaseCursor() {
		Mouse.show();
		cursor._visible = false;
	}


	/*------------------------------------------------------------------------
	SAISIE DES CONTROLES CLAVIER
	------------------------------------------------------------------------*/
	function getControls() {
		// Menu
		if ( !Key.isDown(Key.ESCAPE) ) fl_lockToggle = false;
		if ( Key.isDown(Key.ESCAPE) && !fl_lockToggle ) {
			toggleMenu();
			fl_lockToggle = true;
		}


		// Mode Converter
		if ( Key.isDown(Key.SHIFT) && Key.isDown(Key.CONTROL) && Key.isDown(67) ) {
			manager.startMode( new mode.Converter(manager) );
		}


		// Suit un portal
		if ( !fl_lock ) {
			if ( !Key.isDown(70) ) fl_lockFollow = false;
			if ( Key.isDown(70) && !fl_lockFollow ) {
				var best = null;
				var bestDist = 5;
				for (var i=0;i<world.portalList.length;i++) {
					var p = world.portalList[i];
					var dist = Math.sqrt( Math.pow(p.cx-cx,2) + Math.pow(p.cy-cy,2) );
					if ( dist<bestDist ) {
						best = i;
						bestDist = dist;
					}
				}
				if ( best!=null ) {
					followPortal(best);
				}
				fl_lockFollow = true;
			}
		}


		// Dernière touche enfoncée
		if ( lastKey>0 && !Key.isDown(lastKey) ) {
			lastKey = 0 ;
		}

		// Saisie au pavé numérique (numpad)
		if ( !fl_lock ) {
			for (var i=0;i<10;i++) {
				if ( Key.isDown(96+i) && lastKey!=96+i ) {
					input+=string(i) ;
					lastKey = 96+i ;
				}
			}
			if (input.length>=3) {
				var n = Std.parseInt(input,10) ;
				if ( n<world.levels.length ) {
					goto(n);
				}
				input="";
			}
		}

		if ( Key.isDown(Key.BACKSPACE) ) {
			input="";
		}


	}


	/*------------------------------------------------------------------------
	VA AU LEVEL INDIQUÉ PAR UN PORTAL
	------------------------------------------------------------------------*/
	function followPortal(pid) {
		var link = Data.getLink(dimensionId, world.currentId, pid);
		if ( link==null ) {
			return;
		}
		if ( link.to_did == dimensionId ) {
			this.goto( link.to_lid );
		}
		else {
			if ( anyModified() ) {
				display("All changes will be lost ! Reload all or save all to follow this portal.");
			}
			else {
				var name = null;
				for (var i=0;i<DIMENSIONS.length;i++) {
					if ( DIMENSIONS[i].id == link.to_did ) {
						name = DIMENSIONS[i].name;
					}
				}
				if ( name!=null ) {
					firstLevel = link.to_lid;
					loadSet(name);
					redrawAll();
				}
			}
		}
	}


	// *** EVENTS

	/*------------------------------------------------------------------------
	EVENT: LEVELS LOADÉS
	------------------------------------------------------------------------*/
	function onLoadComplete() {
		this.goto(firstLevel);
		firstLevel = 1;
		redrawAll();
		updateBad();
	}

	function mouseDown() {
		fl_click = true;
	}
	function mouseUp() {
		fl_click = false;
	}


	/*------------------------------------------------------------------------
	MISE EN ATTENTE / RÉVEIL DU MODE PAR LE MANAGER
	------------------------------------------------------------------------*/
	function onSleep() {
		hideCaseCursor();
		super.onSleep();
	}

	function onWakeUp(n, data:'a) //'
	{
		super.onWakeUp(n,data);

		if ( data!=null ) {
			if ( n.indexOf("$scriptEd",0)>=0 ) {
				var old = world.current.$script;
				world.current.$script = Std.cast(data);
				if ( old!=world.current.$script ) {
					setModified(world.currentId);
				}
				redrawScript();
			}

			if ( n.indexOf("$levelBrowser",0)>=0 ) {
				var id : int = Std.cast(data);
				goto(id);
			}
		}
		if ( fl_menu ) {
			hideCaseCursor();
		}
		else {
			showCaseCursor();
		}
	}


	// *** EVENTS BOUTONS

	function none() {
		display("not implemented...");
	}

	function onNew() {
		world.levels[world.currentId] = new levels.Data();
		setModified(world.currentId);
		world.goto(world.currentId);
		redrawAll();
	}

	function onSaveLevel() {
		world.raw[world.currentId] = world.serialize(world.currentId);
		fl_modified[world.currentId] = false;
		display("Current level saved. Length="+world.raw[world.currentId].length);
	}

	function onLoadLevel() {
		lastPoint = null;
		world.levels[world.currentId] = world.unserialize(world.currentId);
		world.goto( world.currentId );
		fl_modified[world.currentId] = false;
		display("Current level reloaded.");
		redrawAll();
	}

	function onLoadAll() {
		fl_modified = new Array();
		view.destroy();
		loadSet(setName);
		redrawAll();
		display("All reloaded.");
	}

	function onSaveAll() {
		save_currentId = 0;
		save_raw = new Array();
		if ( fl_menu ) {
			toggleMenu();
			hideCaseCursor();
		}
		fl_save = true;
//		var raw=new Array() ;
//		var s=0;
//		for (var i=0;i<world.levels.length;i++) {
//			if ( world.fl_read[i] ) {
//				raw[i] = world.serialize(i);
//				s++;
//			}
//			else {
//				raw[i] = world.raw[i];
//			}
//		}

//		var serial = raw.join(":");
//		world.overwrite( serial );
//		world.exportCookie();
//		fl_modified = new Array();
//		display(raw.length+" levels saved ("+s+"/"+raw.length+" re-serialized)");
//		System.setClipboard(serial);
//		display("Copied to system clipboard (length = "+serial.length+")");
	}


	function onCookieReset() {
		resetConfirm+=Data.SECOND*0.5;
		if ( resetConfirm <= Data.SECOND*0.7  ) {
			display("WARNING: this operation CANNOT be canceled ! Double-click to confirm.");
		}
		else {
			resetConfirm = 0;
			display("Rolled-back to compiled XML data");
			world.rollback_xml();
//			manager.cookie.reset();
			manager.fl_cookie = false;
			onLoadAll();
			manager.fl_cookie = true;
			onSaveAll();
		}
	}

	function onNextLevel() {
		this.goto(world.currentId+1);
	}
	function onPrevLevel() {
		this.goto(world.currentId-1);
	}
	function onNextLevelFast() {
		this.goto(world.currentId+10);
	}
	function onPrevLevelFast() {
		this.goto(world.currentId-10);
	}
	function onFirstLevel() {
		this.goto(0);
	}
	function onLastLevel() {
		this.goto( world.levels.length-1 );
	}

	function onPrevBg() {
		world.current.$skinBg = int( Math.max(1,world.current.$skinBg-1) );
		setModified(world.currentId);
		redrawView();
	}
	function onNextBg() {
		world.current.$skinBg = int( Math.min(Data.MAX_BG,world.current.$skinBg+1) );
		setModified(world.currentId);
		redrawView();
	}


	function onPrevTiles() {
		var tile	= levels.View.getTileSkinId( world.current.$skinTiles );
		var col		= levels.View.getColumnSkinId( world.current.$skinTiles );
		if ( tile==col ) {
			tile--;
			col = tile;
		}
		else {
			tile--;
		}
		tile = Math.max(1,tile);
		world.current.$skinTiles = levels.View.buildSkinId( tile, col );
		setModified(world.currentId);
		redrawView();
	}
	function onNextTiles() {
		var tile	= levels.View.getTileSkinId( world.current.$skinTiles );
		var col		= levels.View.getColumnSkinId( world.current.$skinTiles );
		if ( tile==col ) {
			tile++;
			col = tile;
		}
		else {
			tile++;
		}
		tile = Math.max(1,tile);
		world.current.$skinTiles = levels.View.buildSkinId( tile, col );
		setModified(world.currentId);
		redrawView();
	}


	function onPrevColumn() {
		var tile	= levels.View.getTileSkinId( world.current.$skinTiles );
		var col		= levels.View.getColumnSkinId( world.current.$skinTiles );
		col = Math.max(1,col-1);
		world.current.$skinTiles = levels.View.buildSkinId( tile, col );
		setModified(world.currentId);
		redrawView();
	}
	function onNextColumn() {
		var tile	= levels.View.getTileSkinId( world.current.$skinTiles );
		var col		= levels.View.getColumnSkinId( world.current.$skinTiles );
		col++;
		world.current.$skinTiles = levels.View.buildSkinId( tile, col );
		setModified(world.currentId);
		redrawView();
	}
	function onResetColumn() {
		var tile	= levels.View.getTileSkinId( world.current.$skinTiles );
		world.current.$skinTiles = levels.View.buildSkinId( tile, tile );
		setModified(world.currentId);
		redrawView();
	}


	function onQuit() {
		if ( fl_switch ) {
			return;
		}

		if ( fl_menu ) {
			toggleMenu();
		}
		cursor._visible = false;
		hideCaseCursor();

		endMode();
	}


	function onSelectTile() {
		tool = Data.TOOL_TILE;
	}
	function onSelectBad() {
		tool = Data.TOOL_BAD;
	}
	function onSelectField() {
		tool = Data.TOOL_FIELD;
	}
	function onSelectStart() {
		tool = Data.TOOL_START;
	}
	function onSelectSpecial() {
		tool = Data.TOOL_SPECIAL;
	}
	function onSelectScore() {
		tool = Data.TOOL_SCORE;
	}


	function onPrevField() {
		fieldId = int( Math.max( 1, fieldId-1 ) );
		onSelectField();
	}
	function onNextField() {
		fieldId = int( Math.min( Data.MAX_FIELDS, fieldId+1 ) );
		onSelectField();
	}

	function onPrevBad() {
		badId--;
		if ( badId<0 )
		badId = Data.MAX_BADS;
		onSelectBad();
		updateBad();
	}
	function onNextBad() {
		badId++
		if ( badId>Data.MAX_BADS )
		badId = 0;
		onSelectBad();
		updateBad();
	}

	function onCopy() {
		buffer = Data.duplicate( world.current );
		display("Level copied to buffer.");
	}

	function onPaste() {
		if ( buffer==null ) {
			display("Level buffer is empty");
			return;
		}
		world.levels[world.currentId] = Data.duplicate(buffer);
		world.goto(world.currentId);
		setModified(world.currentId);
		redrawAll();
		display("Paste level from buffer.");
	}

	function onStyleCopy() {
		styleBuffer = Data.duplicate( world.current );
		display("Style copied to buffer");
	}

	function onStylePaste() {
		if ( styleBuffer==null ) {
			display("Style buffer is empty");
			return;
		}
		world.current.$skinTiles	= styleBuffer.$skinTiles;
		world.current.$skinBg		= styleBuffer.$skinBg;
		setModified(world.currentId);
		redrawAll();
	}


	function onLoadAdv() {
		loadSet("xml_adventure");
		redrawAll();
	}
	function onLoadMulti() {
		loadSet("xml_multi");
		redrawAll();
	}
	function onLoadTuto() {
		loadSet("xml_tutorial");
		redrawAll();
	}
	function onLoadShare() {
		loadSet("xml_shareware");
		redrawAll();
	}
	function onLoadFjv() {
		loadSet("xml_fjv");
		redrawAll();
	}
	function onLoadDev() {
		loadSet("xml_dev");
		redrawAll();
	}
	function onLoadTest() {
		loadSet("xml_test");
		redrawAll();
	}
	function onLoadTime() {
		loadSet("xml_time");
		redrawAll();
	}
	function onLoadMultiTime() {
		loadSet("xml_multitime");
		redrawAll();
	}
	function onLoadSoccer() {
		loadSet("xml_soccer");
		redrawAll();
	}
	function onLoadHof() {
		loadSet("xml_hof");
		redrawAll();
	}
	function onLoadDeep() {
		loadSet("xml_deepnight");
		redrawAll();
	}
	function onLoadHiko() {
		loadSet("xml_hiko");
		redrawAll();
	}
	function onLoadAyame() {
		loadSet("xml_ayame");
		redrawAll();
	}
	function onLoadHk() {
		loadSet("xml_hk");
		redrawAll();
	}

	function onBrowse() {
		manager.startChild( new mode.Browser(manager, world, dimensionId, fl_modified) );
	}

	function onTest() {
		manager.startChild( new mode.AdventureTest(manager, world.current) );
	}

	function onScript() {
		manager.startChild( new mode.ScriptEditor(manager,world.current.$script) );
	}

	function onItemBrowser() {
		manager.startChild( new mode.ItemBrowser(manager) );
	}

	function onQuestBrowser() {
		manager.startChild( new mode.QuestBrowser(manager) );
	}



	function onStartGame() {
		if ( anyModified() ) {
			display("All changes will be lost ! Reload all or save all to start the game.");
		}
		else {
			manager.startMode(  new mode.Adventure(manager,world.currentId)  );
//			manager.startMode(  new mode.Soccer(manager,world.currentId)  );
//			manager.startMode(  new mode.TimeAttack(manager,world.currentId)  );
		}
	}


	function onPanLeft() {
		panMap(-1,	0);
	}

	function onPanRight() {
		panMap(1,	0);
	}


	function onPanUp() {
		panMap(0,	-1);
	}

	function onPanDown() {
		panMap(0,	1);
	}



	/*------------------------------------------------------------------------
	DÉPLACEMENT HORIZONTAL
	------------------------------------------------------------------------*/
	function panMap(offsetX, offsetY) {
		var data = world.current;

		var startX,	endX,	incX;
		var startY,	endY,	incY;


		// X
		if ( offsetX==0 ) {
			startX	= 0;
			endX	= Data.LEVEL_WIDTH;
			incX	= 1;
		}
		else {
			incX = -offsetX;
			if ( offsetX>0 ) {
				startX	= Data.LEVEL_WIDTH-2;
				endX	= -1;
			}
			else {
				startX	= 1;
				endX	= Data.LEVEL_WIDTH;
			}
		}

		// Y
		if ( offsetY==0 ) {
			startY	= 0;
			endY	= Data.LEVEL_HEIGHT;
			incY	= 1;
		}
		else {
			incY = -offsetY;
			if ( offsetY>0 ) {
				startY	= Data.LEVEL_HEIGHT-2;
				endY	= -1;
			}
			else {
				startY	= 1;
				endY	= Data.LEVEL_HEIGHT;
			}
		}


		// Panning
		for (var y=startY; y!=endY; y+=incY) {
			for (var x=startX; x!=endX; x+=incX) {
				data.$map[x+offsetX][y+offsetY] = data.$map[x][y];
			}
		}

		// Efface la dernière colonne
		if ( offsetX!=0 ) {
			for (var y=0; y<Data.LEVEL_HEIGHT; y++) {
				world.current.$map[endX+offsetX][y] = 0;
			}
		}

		// Efface la dernière ligne
		if ( offsetY!=0 ) {
			for (var x=0; x<Data.LEVEL_WIDTH; x++) {
				world.current.$map[x][endY+offsetY] = 0;
			}
		}

		redrawAll();
		setModified(world.currentId);
	}


	/*------------------------------------------------------------------------
	EFFACE UNE COLONNE
	------------------------------------------------------------------------*/
	function clearColumn(x) {
		for (var y=0; y<Data.LEVEL_HEIGHT; y++) {
			world.current.$map[x][y] = 0;
		}
	}



	// *** MAIN

	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function main() {
		super.main();
		if ( fl_lock ) {
			return;
		}

		if ( input.length>0 ) {
			var str = input;
			while (str.length<3) { str+="$_".substring(1); }
			Log.print("GOTO: [ "+str+" ]");
		}

		if ( resetConfirm>=0 ) {
			resetConfirm-=Timer.tmod;
		}

		// Sérialisation progressive
		if ( fl_save ) {
			manager.progress(  save_currentId / world.levels.length  );
			if ( world.fl_read[save_currentId] ) {
				save_raw[save_currentId] = world.serialize(save_currentId);
			}
			else {
				save_raw[save_currentId] = world.raw[save_currentId];
			}

			save_currentId++;

			// Done
			if ( save_currentId==world.levels.length ) {
				var serial = save_raw.join(":");
				world.overwrite( serial );
				world.exportCookie();
				fl_modified = new Array();
				display(  save_raw.length+" levels saved"  );
				System.setClipboard(serial);
				display(  "Copied to system clipboard (length = "+serial.length+")"  );

				fl_save = false;
				manager.progress(null);
			}
			else {
				return;
			}

		}

		if ( fl_save ) {
			return;
		}


		updateConstants();
		getDebugControls();

		updateFooter();

		world.update();

		getControls();
		menuC.update();
		updateCursor();
		updateMenu();

		// Dessin
		if ( fl_click && !fl_menu ) {
			if ( !Key.isDown(Key.CONTROL) ) {
				// ajout
				if ( isEmpty(cx,cy) ) {
					paint(cx,cy);
					redrawView();
				}
			}
			else {
				// suppression
				if ( !isEmpty(cx,cy) ) {
					remove(cx,cy);
					redrawView();
				}
			}
		}


	}

}
