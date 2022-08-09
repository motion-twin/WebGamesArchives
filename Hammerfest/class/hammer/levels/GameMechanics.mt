import levels.TeleporterData;

class levels.GameMechanics extends levels.ViewManager
{
	var game			: mode.GameMode;

	var fl_parsing		: bool;
	var flcurrentIA		: bool;
	var fl_compile		: bool;
	var fl_lock			: bool;
	var fl_visited		: Array<bool>;
	var fl_mainWorld	: bool;

	var flagMap			: Array<Array<int>>; // flags IA
	var fallMap			: Array<Array<int>>; // hauteur de chute par case
	var triggers		: Array<Array< Array<Entity> >> ;

	var scriptEngine	: levels.ScriptEngine;


	private var _iteration : {cx:int,cy:int} ;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,s) {
		super(m,s);

		fl_parsing		= false;
		fl_lock			= true;
		fl_visited		= new Array();
		fl_mainWorld	= true;

		resetIA();

		triggers = new Array() ;

		for ( var i=0 ; i<Data.LEVEL_WIDTH ; i++ ) {
			triggers[i] = new Array() ;
			for ( var j=0 ; j<Data.LEVEL_HEIGHT ; j++ ) {
				triggers[i][j] = new Array() ;
			}
		}
	}

	function destroy() {
		super.destroy();
		scriptEngine.destroy();
	}


	/*------------------------------------------------------------------------
	DÉFINI LE GAME INTERNE
	------------------------------------------------------------------------*/
	function setGame(g) {
		game = g;
	}


	/*------------------------------------------------------------------------
	GESTION VERROU DE SCRIPT
	------------------------------------------------------------------------*/
	function lock() {
		fl_lock = true;
	}
	function unlock() {
		fl_lock = false;
	}


	/*------------------------------------------------------------------------
	CHANGE LE NIVEAU COURANT
	------------------------------------------------------------------------*/
	function goto(id) {
		setVisited();
		resetIA();
//		scriptEngine.clearScript();
		super.goto(id);
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LES DONNÉES SONT PRETES
	------------------------------------------------------------------------*/
	function isDataReady() {
		return super.isDataReady() && flcurrentIA;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT D'UNE VUE
	------------------------------------------------------------------------*/
	function createView(id) {
		scriptEngine.onLevelAttach();
		return super.createView(id);
	}


	/*------------------------------------------------------------------------
	MISE EN ATTENTE
	------------------------------------------------------------------------*/
	function suspend() {
		super.suspend();
		lock();
		var s = Data.cleanString( scriptEngine.script.toString() );
		if ( s != null ) {
			current.$script = s;
		}
		setVisited();
	}

	function restore(lid) {
		super.restore(lid);
	}


	/*------------------------------------------------------------------------
	FLAG LE LEVEL COURANT COMME DÉJÀ PARCOURU
	------------------------------------------------------------------------*/
	function setVisited() {
		fl_visited[currentId]=true;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE NIVEAU A DÉJÀ ÉTÉ PARCOURU
	------------------------------------------------------------------------*/
	function isVisited() {
		return fl_visited[currentId]==true;
	}


	// *** IA *****


	/*------------------------------------------------------------------------
	RELANCE LE PROCESSUS DE PARSING IA
	------------------------------------------------------------------------*/
	function resetIA() {
		flcurrentIA = false;
		_iteration = {cx:0, cy:0};
		flagMap = new Array();
		fallMap = new Array();

		for ( var i=0 ; i<Data.LEVEL_WIDTH ; i++ ) {
			flagMap[i] = new Array() ;
			fallMap[i] = new Array() ;
			for ( var j=0 ; j<Data.LEVEL_HEIGHT ; j++ ) {
				flagMap[i][j] = 0 ;
				fallMap[i][j] = -1 ;
			}
		}
	}

	/*------------------------------------------------------------------------
	RETOURNE UNE CASE DE LA MAP IA
	------------------------------------------------------------------------*/
	function checkFlag(pt, flag:int):bool {
		var x:int=pt.x ;
		var y:int=pt.y ;
		if (x>=0 && x<Data.LEVEL_WIDTH && y>=0 && y<Data.LEVEL_HEIGHT) {
			return (flagMap[x][y] & flag)>0 ; // dans la zone de jeu
		}
		else {
			return false ; // hors écran
		}
	}


	/*------------------------------------------------------------------------
	FORCE UN FLAG DANS UNE CASE
	------------------------------------------------------------------------*/
	function forceFlag(pt, flag:int, value:bool) {
		if ( value ) {
			flagMap[pt.x][pt.y] |= flag;
		}
		else {
			flagMap[pt.x][pt.y] &= ~flag;
		}
	}


	/*------------------------------------------------------------------------
	PARCOURE DE LA MAP DÉCALÉ SUR PLUSIEURS FRAMES
	------------------------------------------------------------------------*/
	function parseCurrentIA( it: {cx:int,cy:int} ) {
		var n=0 ;
		var total = Data.LEVEL_WIDTH*Data.LEVEL_HEIGHT ;
		var cx = it.cx ;
		var cy = it.cy ;

		while (n<Data.MAX_ITERATION && cy<Data.LEVEL_HEIGHT) {
			var flags = 0 ;

			// Dalle normale
			if ( getCase( {x:cx,y:cy+1} )==Data.GROUND ) {
				flags |= Data.IA_TILE_TOP ;
				// Zone de saut vers le haut
				if ( getCase( {x:cx,y:cy-Data.IA_VJUMP} )==Data.GROUND && getCase( {x:cx,y:cy-Data.IA_VJUMP-1} )<=0 ) {
					flags |= Data.IA_JUMP_UP ;
				}
			}

			if ( getCase( {x:cx,y:cy} )==Data.GROUND && getCase( {x:cx,y:cy-1} )<=0 ) {
				flags |= Data.IA_TILE ;
			}

			// Point de chute autorisé (fallHeight==-1 si dans le vide)
			var fallHeight = _checkSecureFall(cx,cy) ;
			fallMap[cx][cy] = fallHeight;
			if ( fallHeight>=0 ) {
				flags |= Data.IA_ALLOW_FALL ;
			}

			// Point de saut vertical, vers le bas (on est sous une dalle)
			if ( getCase( {x:cx,y:cy} )==0 && getCase( {x:cx,y:cy+1} )==Data.GROUND ) {
				fallHeight = _checkSecureFall(cx,cy+2) ;
				if ( fallHeight>=0 ) {
					flags |= Data.IA_JUMP_DOWN ;
				}
			}

			// Bord de dalle
			if ( getCase( {x:cx,y:cy+1} )==Data.GROUND &&
			( getCase( {x:cx-1,y:cy+1} )<=0 || getCase( {x:cx+1,y:cy+1} )<=0 ) ) {
				flags |= Data.IA_BORDER ;
			}

			// Case en bord de dalle d'où les bads peuvent se laisser tomber
			if ( getCase( {x:cx,y:cy+1} )<=0 &&
			( getCase( {x:cx-1,y:cy+1} )==Data.GROUND || getCase( {x:cx+1,y:cy+1} )==Data.GROUND ) ) {
				flags |= Data.IA_FALL_SPOT ;
			}

			// Petite dalle merdique
			if ( (flags & Data.IA_BORDER)>0 ) {
				if ( getCase( {x:cx-1,y:cy+1} )!=Data.GROUND && getCase( {x:cx+1,y:cy+1} )!=Data.GROUND ) {
					flags |= Data.IA_SMALL_SPOT ;
				}
			}

			// Au pied d'un mur
			if ( (flags & Data.IA_TILE_TOP)>0 ) {

				// Calcule la distance au plafond
				var maxHeight=1;
				var d=1;
				while (d<=5) {
					if ( getCase( {x:cx,y:cy-d} )<=0 ) {
						maxHeight++;
					}
					else {
						d=999;
					}
					d++;
				}

				if ( maxHeight>0 ) {
					// Gauche
					if ( getCase( {x:cx-1,y:cy} )>0 ) {
						var h = getWallHeight(cx-1,cy, Data.IA_CLIMB);
						if ( h!=null && h<maxHeight && cy-h>=0 ) {
							flags |= Data.IA_CLIMB_LEFT;
						}
					}
					// Droite
					if ( getCase( {x:cx+1,y:cy} )>0 ) {
						var h = getWallHeight(cx+1,cy, Data.IA_CLIMB);
						if ( h!=null && h<maxHeight && cy-h>=0 ) {
							flags |= Data.IA_CLIMB_RIGHT;
						}
					}
				}
			}


			// Escaclier dans le vide
			if ( (flags & Data.IA_FALL_SPOT)>0 ) {

				// Calcule la distance au plafond
				var maxHeight=1;
				var d=1;
				while (d<=5) {
					if ( getCase( {x:cx,y:cy-d} )<=0 ) {
						maxHeight++;
					}
					else {
						maxHeight+=2;
						d=999;
					}
					d++;
				}


				if ( maxHeight>0 ) {
					// Gauche
					if ( getCase( {x:cx+1,y:cy+1} )==Data.GROUND ) {
						var h = getStepHeight(cx,cy, Data.IA_CLIMB);
						if ( h!=null && h<maxHeight ) {
							if (  checkFlag( {x:cx,y:cy-h}, Data.IA_BORDER ) && checkFlag( {x:cx+1,y:cy-h}, Data.IA_FALL_SPOT )  ) {
								flags |= Data.IA_CLIMB_LEFT;
							}
						}
					}
					// Droite
					if ( getCase( {x:cx-1,y:cy+1} )==Data.GROUND ) {
						var h = getStepHeight(cx,cy, Data.IA_CLIMB);
						if ( h!=null && h<maxHeight ) {
							if (  checkFlag( {x:cx,y:cy-h}, Data.IA_BORDER ) && checkFlag( {x:cx-1,y:cy-h}, Data.IA_FALL_SPOT )  ) {
								flags |= Data.IA_CLIMB_RIGHT;
							}
						}
					}
				}
			}


			// Sous-catégories de bords de dalle
			if ( (flags & Data.IA_FALL_SPOT)>0 ) {
				// Saut à gauche
				if ( getCase( {x:cx+1,y:cy+1} )==Data.GROUND && getCase( {x:cx-Data.IA_HJUMP,y:cy+1} )==Data.GROUND ) {
					if ( getCase( {x:cx-1,y:cy} )<=0 ) {
						flags |= Data.IA_JUMP_LEFT ;
					}
				}
				// Saut à droite
				if ( getCase( {x:cx-1,y:cy+1} )==Data.GROUND && getCase( {x:cx+Data.IA_HJUMP,y:cy+1} )==Data.GROUND ) {
					if ( getCase( {x:cx+1,y:cy} )<=0 ) {
						flags |= Data.IA_JUMP_RIGHT ;
					}
				}
			}

			flagMap[cx][cy] = flags ;

			// Case suivante
			cx++ ;
			if ( cx>=Data.LEVEL_WIDTH ) {
				cx=0 ;
				cy++ ;
			}
			n++ ;
		}

		manager.progress( cy/Data.LEVEL_HEIGHT ) ;

		if (n!=Data.MAX_ITERATION) {
			onParseIAComplete() ;
		}

		it.cx = cx ;
		it.cy = cy ;
	}



	/*------------------------------------------------------------------------
	VERIFIE SI UN POINT EST SÛR POUR TOMBER (RENVOIE LA HAUTEUR OU -1 SI VIDE)
	------------------------------------------------------------------------*/
	private function _checkSecureFall(cx,cy) {
		var secure,i,h ;

		// Optimisations
		if ( current.$map[cx][cy]==Data.GROUND )			return -1 ;
		if ( current.$map[cx][cy]==Data.WALL )				return -1 ;
		if ( (flagMap[cx][cy-1] & Data.IA_ALLOW_FALL)>0 )	return fallMap[cx][cy-1]-1;

		secure = false ;
		i = cy+1 ;
		h = 0;
		while ( !secure && i < Data.LEVEL_HEIGHT && cx >= 0 && cx < Data.LEVEL_WIDTH ) {
			if ( current.$map[cx][i] == Data.GROUND ) {
				secure = true ;
			}
			else {
				i++ ;
				h++;
			}
		}

		if ( secure ) {
			return h;
		}
		else {
			return -1;
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE LA HAUTEUR D'UN MUR (AVEC UN MAX ÉVENTUEL, -1 SI MAX ATTEINT)
	------------------------------------------------------------------------*/
	function getWallHeight(cx,cy,max):int {
		var h = 0;
		while ( getCase( {x:cx,y:cy-h} )>0 && h<max ) {
			h++;
		}
		if ( h>=max ) {
			h=null;
		}
		return h;
	}


	/*------------------------------------------------------------------------
	RENVOIE LA HAUTEUR D'UNE MARCHE DANS LE VIDE
	------------------------------------------------------------------------*/
	function getStepHeight(cx,cy,max):int {
		var h = 0;
		while (  getCase( {x:cx,y:cy-h} )<=0  &&  h<max  ) {
			h++;
		}
		h++;
		if ( h>=max ) {
			h=null;
		}
		return h;
	}

	// *** EVENTS *****

	/*------------------------------------------------------------------------
	EVENT: DONNÉES LUES, PRÊT POUR LE SCROLLING
	------------------------------------------------------------------------*/
	function onDataReady() {
		super.onDataReady();
		scriptEngine.compile();
	}

	/*------------------------------------------------------------------------
	EVENT: PARSE MAP IA TERMINÉ
	------------------------------------------------------------------------*/
	function onParseIAComplete() {
		fl_parsing = false;
		flcurrentIA = true;
		checkDataReady();
	}


	/*------------------------------------------------------------------------
	EVENT: DECRUNCH TERMINÉ
	------------------------------------------------------------------------*/
	function onReadComplete() {
		super.onReadComplete();
		scriptEngine = new levels.ScriptEngine(game, current);
		fl_parsing = true;
	}

	/*------------------------------------------------------------------------
	EVENT: VUE PRÊTE À ÊTRE JOUÉE
	------------------------------------------------------------------------*/
	function onViewReady() {
		super.onViewReady();
		game.onLevelReady();
	}

	/*------------------------------------------------------------------------
	EVENT: FIN DE TRANSITION PORTAL
	------------------------------------------------------------------------*/
	function onFadeDone() {
		super.onFadeDone();
		game.onRestore();
		onViewReady();
	}
	function onHScrollDone() {
		super.onHScrollDone();
		game.onRestore();
		onViewReady();
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DU SET
	------------------------------------------------------------------------*/
	function onEndOfSet() {
		super.onEndOfSet();
		game.onEndOfSet();
	}


	/*------------------------------------------------------------------------
	EVENT: RESTORE TERMINÉ
	------------------------------------------------------------------------*/
	function onRestoreReady() {
		super.onRestoreReady();
		scrollDir = game.fl_rightPortal ? 1 : -1; // hack: game var doesn't exist in ViewManager
	}


	// *** DONNÉES ***

	/*------------------------------------------------------------------------
	FORCE LE CONTENU D'UNE CASE (DYNAMIQUE SEULEMENT!)
	------------------------------------------------------------------------*/
	function forceCase(cx,cy,t) {
		super.forceCase(cx,cy,t);
		if ( inBound(cx,cy) ) {
			if ( t==Data.GROUND ) {
				forceFlag( {x:cx,y:cy}, Data.IA_TILE, true );
			}
			else {
				forceFlag( {x:cx,y:cy}, Data.IA_TILE, false );
			}
		}
	}

	/*------------------------------------------------------------------------
	DÉTECTION DES MURS (ID=2)
	------------------------------------------------------------------------*/
	function parseWalls(l) {
		var map = l.$map;
		var n=0;
		for (var cy=0;cy<Data.LEVEL_HEIGHT;cy++) {
			for (var cx=0;cx<Data.LEVEL_WIDTH;cx++) {
				if ( map[cx][cy] > 0 ) {
					if ( map[cx][cy-1] > 0 ) {
						map[cx][cy] = Data.WALL;
						n++;
					}
				}
			}
		}
	}


	/*------------------------------------------------------------------------
	LECTURE + DÉTECTION DES MURS (ID=2)
	------------------------------------------------------------------------*/
	function unserialize(id) {
		var l = super.unserialize(id);
		parseWalls(l);
		return l;
	}



	// *** TÉLÉPORTEURS *****

	/*------------------------------------------------------------------------
	RENVOIE LE TELEPORTER D'UNE CASE DONNÉE
	------------------------------------------------------------------------*/
	function getTeleporter(e:entity.Physics, cx,cy) : TeleporterData {
		var out : TeleporterData = null ;
		if ( getCase( {x:cx,y:cy} ) != Data.FIELD_TELEPORT ) {
			return null ;
		}

		var fl_break=false;


		for (var i=0;i<teleporterList.length && !fl_break;i++) {
			var td = teleporterList[i] ;
			if ( td.dir==Data.HORIZONTAL && cx>=td.cx && cx<td.cx+td.length && cy==td.cy ) {
				out = td;
				fl_break = true;
			}
			if ( !fl_break ) {
				if ( td.dir==Data.VERTICAL && cy>=td.cy && cy<td.cy+td.length && cx==td.cx ) {
					out = td;
					fl_break = true;
				}
			}
		}

		if ( out==e.lastTeleporter ) {
			return null ;
		}

		if ( out == null ) {
			GameManager.fatal("teleporter not found in level "+currentId) ;
		}
		return out ;
	}


	/*------------------------------------------------------------------------
	RENVOIE LE TÉLÉPORTEUR D'ARRIVÉE POUR UN TÉLÉPORTEUR DONNÉ
	------------------------------------------------------------------------*/
	function getNextTeleporter( start : TeleporterData ) : { fl_rand:bool, td:TeleporterData }   {
		var out : TeleporterData = null ;
		var fl_break = false;
		var fl_rand = false;

		// Recherche de correspondance face à face
		for (var i=0;i<teleporterList.length && !fl_break;i++) {
			var td = teleporterList[i] ;
			if ( td.cx!=start.cx || td.cy!=start.cy ) {
				if ( start.dir == Data.HORIZONTAL ) {
					if ( start.dir==td.dir && start.cx==td.cx && start.length==td.length ) {
						out = td ;
						fl_break = true;
					}
				}
				if ( !fl_break && start.dir == Data.VERTICAL ) {
					if ( start.dir==td.dir && start.cy==td.cy && start.length==td.length ) {
						out = td ;
						fl_break = true;
					}
				}
			}
		}

		// Correspondance par dir / length egales
		if ( out==null ) {

			fl_rand = true;
			if ( teleporterList.length>1 ) {
				var l = new Array() ;
				for(var i=0;i<teleporterList.length;i++) {
					var td = teleporterList[i];
					if (  td.cx!=start.cx || td.cy!=start.cy  ) {
						if ( td.dir == start.dir && td.length == start.length ) {
							l.push(teleporterList[i]) ;
						}
					}
				}
				if ( l.length>0 ) {
					out = l[Std.random(l.length)] ;
					if ( l.length==1 ) {
						fl_rand = false;
					}
				}
			}
		}

		// Correspondance random
		if ( out==null ) {

			fl_rand = true;
			if ( teleporterList.length>1 ) {
				var l = new Array() ;
				for(var i=0;i<teleporterList.length;i++) {
					if (  teleporterList[i].cx!=start.cx || teleporterList[i].cy!=start.cy  ) {
						l.push(teleporterList[i]) ;
					}
				}
				out = l[Std.random(l.length)] ;
			}
		}

		// Aucune correspondance
		if ( out==null ) {
			GameManager.fatal("target teleporter not found in level "+currentId) ;
		}
		return { fl_rand:fl_rand, td:out };
	}



	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function update() {
		super.update();

		// Analyse (IA) niveau en cours si on a la main et que ca n'est pas déjà fait
		if ( fl_parsing ) {
			parseCurrentIA(_iteration);
		}

		if ( !fl_lock ) {
			scriptEngine.update();
		}


		// Flottement des fields Portal
		for (var i=0;i<portalList.length;i++) {
			var p = portalList[i];
			p.mc._y = p.y + 3*Math.sin(p.cpt);
			p.cpt += Timer.tmod*0.1;
			if ( Std.random(5)==0 ) {
				var a = game.fxMan.attachFx(
					p.x + Data.CASE_WIDTH*0.5 + Std.random(15)*(Std.random(2)*2-1),
					p.y + Data.CASE_WIDTH*0.5 + Std.random(15)*(Std.random(2)*2-1),
					"hammer_fx_star"
				);
				a.mc._xscale	= Std.random(70)+30;
				a.mc._yscale	= a.mc._xscale;
			}
		}

	}

}

