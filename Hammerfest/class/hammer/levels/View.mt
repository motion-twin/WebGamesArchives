import flash.display.BitmapData;

class levels.View
{
	var fl_cache	: bool;
	var fl_fast		: bool; // mode brouillon

	var viewX		: float;
	var viewY		: float;

	var world		: levels.SetManager;
	var data		: levels.Data;
	var depthMan	: DepthManager;

	var _top_dm			: DepthManager; // bitmap cache
	var _back_dm		: DepthManager; // bitmap cache
	var _field_dm		: DepthManager; // no cache
	var _sprite_top_dm	: DepthManager; // no cache
	var _sprite_back_dm	: DepthManager; // no cache

	var xOffset			: float;
	var fl_attach		: bool;
	var fl_shadow		: bool;
	var fl_hideTiles	: bool;
	var fl_hideBorders	: bool;
	var levelId			: int;
	var topCache		: BitmapData;
	var viewCache		: BitmapData;
	var tileCache		: BitmapData;

	var snapShot		: BitmapData;


	// Movies
	private var _top		: { > MovieClip, bitmapMC:MovieClip };
	private var _back		: { > MovieClip, bitmapMC:MovieClip };
	private var _field		: { > MovieClip, bitmapMC:MovieClip };
	private var _sprite_top : MovieClip;
	private var _sprite_back: MovieClip;

	private var _tiles		: MovieClip;
	private var _bg			: MovieClip;
	private var _leftBorder	: MovieClip;
	private var _rightBorder: MovieClip;
	private var _specialBg	: { > MovieClip, sub:MovieClip };
	var tileList			: Array<levels.TileMC>;
	var gridList			: Array<MovieClip>;
	var mcList				: Array<MovieClip>;

//	var thumb				: BitmapData;
//	var fl_thumb			: bool;

	private var _fieldMap	: Array<Array<bool>>;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(world, dm) {
		this.world = world;

		depthMan	= dm;
		xOffset		= 10;

		fl_attach		= false;
		fl_shadow		= true;
		fl_hideTiles	= false;
		fl_hideBorders	= false;

		tileList	= new Array();
		gridList	= new Array();
		mcList		= new Array();

		_sprite_top		= depthMan.empty(Data.DP_SPRITE_TOP_LAYER);
		_sprite_top._x	-= xOffset;
		_sprite_back	= depthMan.empty(Data.DP_SPRITE_BACK_LAYER);
		_sprite_back._x	-= xOffset;
		_sprite_top_dm	= new DepthManager(_sprite_top);
		_sprite_back_dm	= new DepthManager(_sprite_back);

		fl_cache	= world.manager.fl_flash8;
		fl_fast		= false;
	}



	/*------------------------------------------------------------------------
	VUE D'UN NIVEAU DU SET INTERNE
	------------------------------------------------------------------------*/
	function display(id:int) {
		this.data = this.world.levels[id];
		levelId = id;
		if (this.data==null) {
			GameManager.warning("null view");
		}
		attach();
	}

	/*------------------------------------------------------------------------
	VUE DU NIVEAU EN COURS DANS LE SET
	------------------------------------------------------------------------*/
	function displayCurrent() {
		display(world.currentId);
	}


	/*------------------------------------------------------------------------
	UTILISE UN OBJET CUSTOM POUR LA VUE
	------------------------------------------------------------------------*/
	function displayExternal(d:levels.Data) {
		this.data = d;
		levelId = null;
		detachLevel();
		attach();
	}


	/*------------------------------------------------------------------------
	SCALE DU NIVEAU
	------------------------------------------------------------------------*/
	function scale(ratio:float) {
		var scale = Math.round(ratio*100);
		_tiles._xscale	= scale;
		_tiles._yscale	= scale;
		_bg._xscale		= scale;
		_bg._yscale		= scale;
		_sprite_back._xscale	= scale;
		_sprite_back._yscale	= scale;
		_sprite_top._xscale		= scale;
		_sprite_top._yscale		= scale;

		_leftBorder._visible = (ratio==1);
		_rightBorder._visible = (ratio==1);
		if ( fl_cache ) {
			_top.bitmapMC._xscale = scale;
			_top.bitmapMC._yscale = scale;
			_back.bitmapMC._xscale = scale;
			_back.bitmapMC._yscale = scale;
			if ( ratio!=1 ) {
				_field._visible = false;
			}
			else {
				_field._visible = true;
			}
		}
	}


	/*------------------------------------------------------------------------
	EFFACE LES OMBRES SOUS LES DALLES
	------------------------------------------------------------------------*/
	function removeShadows() {
		fl_shadow = false;
	}


	/*------------------------------------------------------------------------
	RETOURNE SI UNE CASE EST UN MUR
	------------------------------------------------------------------------*/
	function isWall(cx,cy) {
		return
			data.$map[cx][cy]>0 &&
			( data.$map[cx-1][cy]<=0 || data.$map[cx-1][cy]==null ) &&
			( data.$map[cx+1][cy]<=0 || data.$map[cx+1][cy]==null );
	}


	/*------------------------------------------------------------------------
	CALCUL DES ID DE SKIN TILES / COLUMN
	------------------------------------------------------------------------*/
	static function getTileSkinId(id) {
		if ( id>=100 ) {
			id = id - Math.floor(id/100)*100;
			return id;
		}
		else {
			return id;
		}
	}

	static function getColumnSkinId(id) {
		if ( id>=100 ) {
			id = Math.floor( id/100 );
		}
		return id;
	}

	static function buildSkinId( tile, column ) {
		if ( column==tile ) {
			return tile;
		}
		else {
//			if ( column<10 ) {
				return column*100 + tile;
//			}
//			else {
//				return column*100 + tile;
//			}
		}
	}


	/*------------------------------------------------------------------------
	ATTACHE UN PLATEAU
	------------------------------------------------------------------------*/
	function attachTile(sx:int,sy:int,wid:int, skin:int) {
		skin = getTileSkinId(skin);
		if ( fl_fast ) {
			skin = 30;
		}
		var tile : levels.TileMC;
		tile = downcast( Std.attachMC( _tiles, "tile", sy*Data.LEVEL_WIDTH+sx ) );

		tile._x = sx*Data.CASE_WIDTH;
		tile._y = sy*Data.CASE_HEIGHT;
		tile.maskTile._width = wid*Data.CASE_WIDTH;
		tile.endTile._x = wid*Data.CASE_WIDTH;

		tile.skin.gotoAndStop(string(skin));
		tile.endTile.gotoAndStop(string(skin));

		if ( !fl_shadow || fl_fast ) {
			tile.ombre._visible = false;
			tile.endTile.ombre._visible = false;
		}

		tileList.push(tile);
	}

	/*------------------------------------------------------------------------
	ATTACHE UNE COLONNE
	------------------------------------------------------------------------*/
	function attachColumn(sx:int,sy:int,wid:int, skin:int) {
		var tile : levels.TileMC;
		skin = getColumnSkinId(skin);
		if ( fl_fast ) {
			skin = 30;
		}
		tile = downcast( Std.attachMC( _tiles, "tile", sy*Data.LEVEL_WIDTH+sx ) );

		tile._yscale = -100;
		tile._rotation = 90;
		tile._x = sx*Data.CASE_WIDTH;
		tile._y = sy*Data.CASE_HEIGHT;
		tile.maskTile._width = wid*Data.CASE_WIDTH;
		tile.endTile._x = wid*Data.CASE_WIDTH;

		tile.skin.gotoAndStop(string(skin));
		tile.endTile.gotoAndStop(string(skin));

		if ( !fl_shadow || fl_fast ) {
			tile.ombre._visible = false;
			tile.endTile.ombre._visible = false;
		}

		tileList.push(tile);
	}


	/*------------------------------------------------------------------------
	ATTACHE UN CHAMP D'ÉNERGIE
	------------------------------------------------------------------------*/
	function attachField(sx,sy) {
		if ( fl_fast ) {
			return;
		}
		var fl_flip = false;
		var mc : MovieClip;
		var id = data.$map[sx][sy];
		var td : levels.TeleporterData = null;

		// attachement
		mc = _field_dm.attach("field",1);
//		mc = Std.attachMC( _field_dm, "field", sy*Data.LEVEL_WIDTH+sx );
		mc._x = sx*Data.CASE_WIDTH;
		mc._y = sy*Data.CASE_HEIGHT;



		if ( data.$map[sx+1][sy] == id ) {
			// horizontal
			mc.gotoAndStop("2");
			var i = sx;
			while ( data.$map[i][sy] == id ) {
				_fieldMap[i][sy]=true;
				i++;
			}

			if ( id == Data.FIELD_TELEPORT ) {
				td = new levels.TeleporterData(sx,sy, i-sx, Data.HORIZONTAL);
				td.mc = downcast(mc);
			}
			mc._width = Data.CASE_WIDTH * (i-sx);
		}
		else {
			if ( data.$map[sx][sy+1] == id ) {
				// vertical
				mc.gotoAndStop("1");
				var i = sy;
				while ( data.$map[sx][i] == id ) {
					_fieldMap[sx][i]=true;
					i++;
				}

				if ( id==Data.FIELD_TELEPORT ) {
					td = new levels.TeleporterData(sx,sy, i-sy, Data.VERTICAL);
					td.mc = downcast(mc);
				}
				if ( id==Data.FIELD_PORTAL ) {
					if ( data.$map[sx+1][sy]>0 ) {
						fl_flip = true;
					}
				}
				mc._height = Data.CASE_HEIGHT * (i-sy);
			}
			else {
				mc.gotoAndStop("2");
				mc._width = Data.CASE_WIDTH;
			}
		}

		// skin
		downcast(mc).skin.gotoAndStop( ""+Math.abs(id) );
		downcast(mc).skin.sub.stop();
		if ( fl_flip ) {
			downcast(mc).skin.sub._xscale *= -1;
		}

		// téléporteur
		if ( id == Data.FIELD_TELEPORT ) {
			td.podA		= _field_dm.attach( "hammer_pod", Data.DP_INTERF );
			td.podA._x	= td.startX;
			td.podA._y	= td.startY;
			td.podA.stop();

			td.podB		= _field_dm.attach( "hammer_pod", Data.DP_INTERF );
			td.podB._x	= td.endX;
			td.podB._y	= td.endY;
			td.podB._rotation = 180;
			td.podB.stop();

			td.mc.stop();

			if ( td.dir==Data.HORIZONTAL ) {
				td.podA._y -= Data.CASE_HEIGHT*0.5;
				td.podB._y -= Data.CASE_HEIGHT*0.5;
			}
			else {
				td.podA._rotation += 90;
				td.podB._rotation += 90;
			}
//			td.podB = world.game.fxMan.attachFx( td.endX,td.endY, "hammer_fx_shine" );
//			td.podB.gotoAndStop("2");
			world.teleporterList.push(td);
		}

		// portal
		if ( id == Data.FIELD_PORTAL ) {
			world.portalList.push( new levels.PortalData(mc,sx,sy) );
		}

	}


	/*------------------------------------------------------------------------
	ATTACHE LE BG DE BASE DU LEVEL
	------------------------------------------------------------------------*/
	function attachBg() {
		_bg.removeMovieClip();
		_bg = _back_dm.attach("hammer_bg", 0);
		_bg._x = xOffset;
		_bg.gotoAndStop(""+data.$skinBg);
		if ( world.fl_mirror ) {
			_bg._xscale *= -1;
			_bg._x += Data.GAME_WIDTH;
		}
	}


	/*------------------------------------------------------------------------
	ATTACHE UN BACKGROUND SPÉCIAL EN REMPLACEMENT TEMPORAIRE DE L'ACTUEL
	------------------------------------------------------------------------*/
	function attachSpecialBg( id:int, subId:int ) {
		_specialBg = downcast( depthMan.attach("hammer_special_bg", Data.DP_SPECIAL_BG) );
		_specialBg.gotoAndStop(string(id+1));

		if ( subId!=null ) {
			_specialBg.sub.gotoAndStop(string(subId+1));
		}
		if ( fl_cache ) {
			_specialBg.cacheAsBitmap = true;
			_back_dm.destroy();
			_back.bitmapMC = _back_dm.empty(0);
			_back.bitmapMC.attachBitmap(tileCache,0);
		}
		else {
			_bg._visible = false;
		}

		return _specialBg;
	}


	/*------------------------------------------------------------------------
	DETACHE LE FOND SPÉCIAL EN COURS
	------------------------------------------------------------------------*/
	function detachSpecialBg() {
		_specialBg.removeMovieClip();
		if ( fl_cache ) {
			_back.bitmapMC.attachBitmap(viewCache,0);
		}
		else {
			_bg._visible = true;
		}
	}


	/*------------------------------------------------------------------------
	ATTACHE CE LEVEL
	------------------------------------------------------------------------*/
	function attach() {
		var startX:int = 0;
		var startY:int = 0;
		var tracing:bool = false;

		world.teleporterList = new Array();
		world.portalList = new Array();

		// Containers généraux
		_top		= downcast( depthMan.empty(Data.DP_TOP_LAYER) );
		_field		= downcast( depthMan.empty(Data.DP_FIELD_LAYER) );
		_back		= downcast( depthMan.empty(Data.DP_BACK_LAYER) );
		_top_dm		= new DepthManager(_top);
		_field_dm	= new DepthManager(_field);
		_back_dm	= new DepthManager(_back);

		_top._x		= xOffset;

		// Container pour les dalles
		_tiles = _back_dm.empty( 2 );
		_tiles._x = xOffset;
		_tiles._visible = !fl_hideTiles;
		if ( fl_cache ) {
			_tiles.cacheAsBitmap = true;
		}


		_fieldMap = new Array();
		for( var i=0;i<Data.LEVEL_WIDTH;i++ ) {
			_fieldMap[i] = new Array();
		}

		// Background
		if ( !fl_fast ) {
			attachBg();
		}


		// Tiles
		for ( var y=0 ; y<Data.LEVEL_HEIGHT ; y++ ) {
			for ( var x=0 ; x<=Data.LEVEL_WIDTH ; x++ ) {

				if ( !tracing ) {
					if ( data.$map[x][y] > 0 ) {
						startX = x;
						startY = y;
						tracing = true;
					}
				}

				// Fin de trace
				if (tracing) {
					if ( data.$map[x][y] <= 0 || x == Data.LEVEL_WIDTH ) {
						var wid;
						wid = x-startX;
//						if ( x==Data.LEVEL_WIDTH && data.map[x-1][y] > 0 ) {
//							wid ++;
//						}
						// Sol ou colonne ?
						if ( wid==1 && isWall(x-1,y) ) {
							var hei=0;
							var vtx = x-1 ; // vertical tracer
							var vty = y;
							if ( !isWall(vtx,vty-1) ) {
								while (isWall(vtx,vty)) {
									hei++;
									vty++;
								}
								if ( hei==1 ) {
									attachTile( startX, startY, 1, data.$skinTiles );
								}
								else {
									attachColumn( startX, startY, hei, data.$skinTiles );
								}
							}
						}
						else {
							attachTile( startX, startY, wid, data.$skinTiles );
						}
						tracing = false;
					}
				}
			}
		}


		// Fields
		for ( var y=0 ; y<Data.LEVEL_HEIGHT ; y++ ) {
			for ( var x=0 ; x<Data.LEVEL_WIDTH ; x++ ) {
				if ( data.$map[x][y] < 0 && _fieldMap[x][y]==null ) {
					attachField(x,y);
				}
			}
		}


		// Colonnes de pierre
		if ( !fl_fast ) {
			_leftBorder = _top_dm.attach("hammer_sides", 2);
			_leftBorder._x = 5;
			_rightBorder = _top_dm.attach("hammer_sides", 2);
			_rightBorder._x = Data.GAME_WIDTH+15;

			_leftBorder._visible = !fl_hideBorders;
			_rightBorder._visible = !fl_hideBorders;
		}

		// Mise en cache bitmap
		if ( fl_cache ) {
			// _top		: mc for top-elements
			// _top_dm	: depthManager for _top
			// topCache	: bitmap data for _top

			topCache.dispose();
			viewCache.dispose();
			tileCache.dispose();

			topCache = new BitmapData( Data.DOC_WIDTH, Data.DOC_HEIGHT, true, 0xff0000);
			viewCache = new BitmapData( Data.DOC_WIDTH, Data.DOC_HEIGHT, true, 0xff0000);
			tileCache = new BitmapData( Data.DOC_WIDTH, Data.DOC_HEIGHT, true, 0xff0000);
			topCache.drawMC(_top,0,0);
			_bg._visible = false;
			tileCache.drawMC(_back,0,0);
			_bg._visible = true;
			viewCache.drawMC(_back,0,0);
			_top_dm.destroy(); // aka: _top
			_back_dm.destroy();
			_top.bitmapMC = _top_dm.empty(0);
			_back.bitmapMC = _back_dm.empty(0);
			_top.bitmapMC.attachBitmap(topCache,0);
			_back.bitmapMC.attachBitmap(viewCache,0);

			_top_dm		= new DepthManager(_top);
		}

		if ( _specialBg._name!=null ) {
			_back_dm.destroy();
			_back.bitmapMC = _back_dm.empty(0);
			_back.bitmapMC.attachBitmap(tileCache,0);
		}

		fl_attach = true;

	}


	/*------------------------------------------------------------------------
	AFFICHE LES SPOTS DES BADS
	------------------------------------------------------------------------*/
	function attachBadSpots() {
		for (var i=0;i<data.$badList.length;i++) {
			var sp = data.$badList[i];
			var mc = _sprite_top_dm.attach("hammer_editor_bad", Data.DP_BADS);
			mc._x = Entity.x_ctr(sp.$x) + Data.CASE_WIDTH*0.5;
			mc._y = Entity.y_ctr(sp.$y);
			mc.gotoAndStop(  ""+(sp.$id+1)  )
//			Log.trace(sp.$x+","+sp.$y+" id="+sp.$id+" --> "+mc._name);
		}
	}



	/*------------------------------------------------------------------------
	AFFICHE LA GRILLE DE DEBUG
	------------------------------------------------------------------------*/
	function attachGrid(flag:int, over:bool) {
		var depth = Data.DP_SPECIAL_BG;
		if (over) {
			depth = Data.DP_INTERF;
		}

		for (var cx=0;cx<Data.LEVEL_WIDTH;cx++) {
			for (var cy=0;cy<Data.LEVEL_HEIGHT;cy++) {
				var mc = downcast( _top_dm.attach("debugGrid",depth) );
				mc._x = cx*Data.CASE_WIDTH+xOffset;
				mc._y = cy*Data.CASE_HEIGHT;
//				mc.fieldA.text = downcast(world).fallMap[cx][cy];
//				mc.fieldB.text = cy;
				if ( (downcast(world).flagMap[cx][cy] & flag) == 0 ) {
					mc.gotoAndStop("1");
				}
				else {
					mc.gotoAndStop("2");
				}
				gridList.push(Std.cast(mc));
			}
		}
	}


	/*------------------------------------------------------------------------
	DÉTACHE LA GRILLE DE DEBUG
	------------------------------------------------------------------------*/
	function detachGrid() {
		for (var i=0;i<gridList.length;i++) {
			gridList[i].removeMovieClip();
		}
		gridList = new Array();
	}


	/*------------------------------------------------------------------------
	AFFICHE UN SPRITE STATIQUE DE DÉCOR
	------------------------------------------------------------------------*/
	function attachSprite(link,x,y,fl_back) {
		var dm = fl_back?_sprite_back_dm:_sprite_top_dm;
		var mc = dm.attach(link,10);
		mc._x = x;
		mc._y = y;
		mcList.push(mc);

		return mc;
	}


	/*------------------------------------------------------------------------
	DÉTACHEMENT
	------------------------------------------------------------------------*/
	function detach() {
		detachLevel();
		detachSprites();
		fl_attach = false;
		snapShot.dispose();
	}


	function detachLevel() {
		for (var i=0;i<tileList.length;i++) {
			tileList[i].removeMovieClip();
		}
		tileList = new Array();

		detachGrid();

		topCache.dispose();
		viewCache.dispose();
		tileCache.dispose();

		_top.removeMovieClip();
		_back.removeMovieClip();
		_field.removeMovieClip();
	}


	function detachSprites() {
		for (var i=0;i<mcList.length;i++) {
			mcList[i].removeMovieClip();
		}
		mcList = new Array();
		_sprite_back_dm.destroy();
		_sprite_top_dm.destroy();
	}



	/*------------------------------------------------------------------------
	DÉPLACE LE NIVEAU À UN POINT DONNÉ
	------------------------------------------------------------------------*/
	function moveTo(x,y) {
		viewX		= x;
		viewY		= y;
		_top._x		= x - xOffset;
		_top._y		= y;
		_back._x	= _top._x;
		_back._y	= _top._y;
		_field._x	= _top._x+xOffset;
		_field._y	= _top._y;
		_sprite_back._x	= _top._x;
		_sprite_back._y	= _top._y;
		_sprite_top._x	= _top._x;
		_sprite_top._y	= _top._y;
	}


	/*------------------------------------------------------------------------
	APPLIQUE UN FILTRE À TOUT LE NIVEAU
	------------------------------------------------------------------------*/
	function setFilter(f) {
		_top.filters = [f];
		_back.filters = [f];
		_field.filters = [f];
		_sprite_back.filters = [f];
		_sprite_top.filters = [f];
	}


	/*------------------------------------------------------------------------
	REPLACE LA VUE EN POSITION
	------------------------------------------------------------------------*/
	function moveToPreviousPos() {
		if ( viewX!=null ) {
			moveTo(viewX,viewY);
		}
		else {
			moveTo(0,0);
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE UN BITMAP DE LA VUE
	------------------------------------------------------------------------*/
	function getSnapShot(x,y) {
		var ss;
		ss = new BitmapData(Data.DOC_WIDTH, Data.DOC_HEIGHT, true, 0xff0000);
		ss.drawMC(_back,x,y);
		ss.drawMC(_sprite_back,x,y);
		ss.drawMC(_top,x,y);
		ss.drawMC(_sprite_top,x,y);
		return ss;
	}


	/*------------------------------------------------------------------------
	MET À JOUR LE SCREEN INTERNE
	------------------------------------------------------------------------*/
	function updateSnapShot() {
		if ( fl_attach ) {
			snapShot.dispose();
			snapShot = getSnapShot(0,0);
		}
		else {
			GameManager.warning("WARNING: updateSnapShot while not attached");
		}
	}


	/*------------------------------------------------------------------------
	DÉTRUIT LA VUE
	------------------------------------------------------------------------*/
	function destroy() {
		detach();
	}

}

