class levels.ScriptEngine {
	static var T_TIMER			= "$t_timer";
	static var T_POS			= "$t_pos";
	static var T_ATTACH			= "$attach";
	static var T_DO				= "$do";
	static var T_END			= "$end";
	static var T_BIRTH			= "$birth";
	static var T_DEATH			= "$death";
	static var T_EXPLODE		= "$exp";
	static var T_ENTER			= "$enter";
	static var T_NIGHTMARE		= "$night";
	static var T_MIRROR			= "$mirror";
	static var T_MULTI			= "$multi";
	static var T_NINJA			= "$ninja";

	static var E_SCORE			= "$e_score";
	static var E_SPECIAL		= "$e_spec";
	static var E_EXTEND			= "$e_ext";
	static var E_BAD			= "$e_bad";
	static var E_KILL			= "$e_kill";
	static var E_TUTORIAL		= "$e_tuto";
	static var E_MESSAGE		= "$e_msg";
	static var E_KILLMSG		= "$e_killMsg";
	static var E_POINTER		= "$e_pointer";
	static var E_KILLPTR		= "$e_killPt";
	static var E_MC				= "$e_mc";
	static var E_PLAYMC			= "$e_pmc";
	static var E_MUSIC			= "$e_music";
	static var E_ADDTILE		= "$e_add";
	static var E_REMTILE		= "$e_rem";
	static var E_ITEMLINE		= "$e_itemLine";
	static var E_GOTO			= "$e_goto";
	static var E_HIDE			= "$e_hide";
	static var E_HIDEBORDERS	= "$e_hideBorders";
	static var E_CODETRIGGER	= "$e_ctrigger";
	static var E_PORTAL			= "$e_portal";
	static var E_SETVAR			= "$e_setVar";
	static var E_OPENPORTAL		= "$e_openPortal";
	static var E_DARKNESS		= "$e_darkness";
	static var E_FAKELID		= "$e_fakelid";

	static var VERBOSE_TRIGGERS = [
		T_POS,
		T_EXPLODE,
		T_ENTER,
	];


	var game			 : mode.GameMode;

	var script			: Xml;
	var extraScript		: String;
	var baseScript		: String;
	var data			: levels.Data;
	var bads			: int;
	var cycle			: float;

	var mcList			: Array< {sid:int, mc:MovieClip} >; // script attached MCs

	var fl_compile		: bool;
	var fl_birth		: bool;
	var fl_death		: bool;
	var fl_safe			: bool; // safe mode: blocks bads & items spawns

	var fl_redraw		: bool; // true=ré-attache le level en fin de frame

	var fl_elevatorOpen	: bool; // flag fin de jeu
	var fl_firstTorch	: bool;

	var history			: Array<String>;

	var recentExp		: Array< {x:float, y:float, r:float} >;
	var fl_onAttach		: bool;
	var bossDoorTimer	: float;
	var entries			: Array< {cx:int,cy:int} >;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(g, d:levels.Data) {
		game			= g;
		data			= d;
		baseScript		= data.$script;
		bossDoorTimer	= Data.SECOND*1.2;
		extraScript		= "";
		cycle			= 0;
		bads			= 0;
		fl_birth		= false;
		fl_death		= false;
		fl_safe			= false;
		fl_elevatorOpen	= false;
		fl_onAttach		= false;
		fl_firstTorch	= false;
		recentExp		= new Array();
		mcList			= new Array();
		history			= new Array();
		entries			= new Array();
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		script = null;
		fl_compile = false;
	}


	/*------------------------------------------------------------------------
	AJOUTE UNE LIGNE À L'HISTORIQUE
	------------------------------------------------------------------------*/
	function traceHistory(str) {
		history.push("@"+Math.round(cycle*10)/10+"\t: "+str);
	}



	// *** EVENTS ***

	/*------------------------------------------------------------------------
	EVENT: RESURRECTION D'UN JOUEUR OU DÉBUT DE NIVEAU
	------------------------------------------------------------------------*/
	function onPlayerBirth() {
		fl_birth = true;
	}

	function onPlayerDeath() {
		fl_death = true;
	}

	/*------------------------------------------------------------------------
	EVENT: EXPLOSION D'UNE BOMBE D'UN JOUEUR
	------------------------------------------------------------------------*/
	function onExplode(x:float,y:float,radius:float) {
		recentExp.push( {
			x : x,
			y : y,
			r : radius
		} );
	}

	/*------------------------------------------------------------------------
	EVENT: ENTRÉE D'UN JOUEUR DANS UNE CASE
	------------------------------------------------------------------------*/
	function onEnterCase(cx:int,cy:int) {
		entries.push( {cx:cx,cy:cy} );
	}

	/*------------------------------------------------------------------------
	ATTACHEMENT DE LA VUE DU NIVEAU
	------------------------------------------------------------------------*/
	function onLevelAttach() {
		fl_onAttach = true;
	}


	/*------------------------------------------------------------------------
	GESTION MODE SAFE
	------------------------------------------------------------------------*/
	function safeMode() {
		fl_safe = true;
	}

	function normalMode() {
		fl_safe	= false;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE TRIGGER AFFICHE UNE ALERTE EN CAS DE KEY MANQUANTE
	------------------------------------------------------------------------*/
	function isVerbose(t) {
		var fl_verbose = false;
		for (var i=0;i<VERBOSE_TRIGGERS.length;i++) {
			if (t==VERBOSE_TRIGGERS[i]) {
				fl_verbose = true;
			}
		}
		return fl_verbose;
	}


	// *** ACCESSEURS ***/

	/*------------------------------------------------------------------------
	LECTURE D'UN CHAMP TYPÉ D'UNE NODE
	------------------------------------------------------------------------*/
	function getInt( node, name ) : int {
		if ( node.get(name)==null ) {
			return null;
		}
		else {
			return Math.floor(  Std.parseInt( node.get(name),10 )  );
		}
	}

	function getFloat( node, name ) : float {
		if ( node.get(name)==null ) {
			return null;
		}
		else {
			return Std.parseInt( node.get(name),10 )
		}
	}

	function getString( node, name ) {
		if ( node.get(name)==null ) {
			return null;
		}
		else {
			return node.get(name);
		}
	}



	// *** GESTION DU SCRIPT ***

	/*------------------------------------------------------------------------
	SCRIPT: AJOUTE UN CODE DE SCRIPT
	------------------------------------------------------------------------*/
	function addScript(str: String) {
		if ( fl_compile ) {
			var xml = new Xml(str);
			if ( xml==null ) {
				GameManager.fatal("invalid XML !");
			}
			else {
				script.appendChild( xml.firstChild );
			}
		}
		else {
			extraScript+=" "+str;
		}


		// Debug: trace dans le log
		var node = new Xml(str).firstChild;
		traceHistory("+"+node.nodeName);
		node = node.firstChild;
		while ( node!=null ) {
			traceHistory("  +"+node.nodeName);
			node = node.nextSibling;
		}

	}


	function addNode(name, att, inner) {
		addScript("<"+name+" "+att+">"+inner+"</"+name+">");
	}


	function addShortNode(name,att) {
		addScript("<"+name+" "+att+"/>");
	}


	/*------------------------------------------------------------------------
	SCRIPT: LANCE UN EVENT
	------------------------------------------------------------------------*/
	function executeEvent( event:XmlNode ) {
		if ( event.nodeName==null ) {
			return;
		}

		traceHistory(" |--"+event.nodeName);

		switch (event.nodeName) {

			case E_SCORE: // score item
				var x = Entity.x_ctr(  getInt(event, "$x")  );
				var y = Entity.y_ctr(  getInt(event, "$y")  );
				x = game.flipCoordReal(x);
				var id = getInt(event, "$i");
				var subId = getInt(event, "$si");
				var mc = entity.item.ScoreItem.attach(game, x,y, id, subId );
				var inf = getInt(event, "$inf");
				if ( inf==1 ) {
					mc.setLifeTimer(-1);
				}
				var scriptId = getInt(event, "$sid");
				killById( scriptId );
				mc.scriptId = scriptId;
			break;

			case E_SPECIAL: // special item
				if ( game.canAddItem() && !fl_safe ) {
					var x = Entity.x_ctr(  getInt(event, "$x")  );
					x = game.flipCoordReal(x);
					var y = Entity.y_ctr(  getInt(event, "$y")  );
					var id = getInt(event, "$i");
					var subId = getInt(event, "$si");
					var mc = entity.item.SpecialItem.attach(game, x,y, id, subId );
					var inf = getInt(event, "$inf");
					if ( inf==1 ) {
						mc.setLifeTimer(-1);
					}
					var scriptId = getInt(event, "$sid");
					killById( scriptId );
					mc.scriptId = scriptId;
				}
			break;

			case E_EXTEND: // extend
				if ( game.canAddItem() && !fl_safe ) {
					game.statsMan.attachExtend();
				}
			break;

			case E_BAD: // bad
				if ( !fl_safe ) { //&& !game.world.isVisited() ) {
					var x = Entity.x_ctr( game.flipCoordCase( getInt(event, "$x") ) ) - Data.CASE_WIDTH*0.5;
					var y = Entity.y_ctr( getInt(event, "$y")-1 );
					var id = getInt(event, "$i");
					var fl_sys = ( getInt(event, "$sys")!=0 && getInt(event, "$sys")!=null );
					var mc = game.attachBad( id, x,y );
					if ( (mc.types&Data.BAD_CLEAR)>0 ) {
						if ( fl_sys && game.world.isVisited() ) {
							mc.destroy();
							game.badCount--;
							break;
						}
						else {
							bads++;
							game.fl_clear = false;
						}
					}
					var scriptId = getInt(event, "$sid");
					killById( scriptId );
					mc.scriptId = scriptId;
				}
			break;

			case E_KILL: // kill by id
				var id = getInt(event, "$sid");
				killById(id);
			break;

			case E_TUTORIAL: // message tutorial
				var id = getInt(event, "$id");
				var msg;
				if ( id==null ) {
					msg = event.firstChild.nodeValue;
					GameManager.warning("@ level "+game.world.currentId+", script still using inline text value");
				}
				else {
					msg = Lang.get(id);
				}
				if ( msg!=null ) {
					game.attachPop("\n"+msg,true);
				}
			break;

			case E_MESSAGE: // message standard
				var id = getInt(event, "$id");
				var msg;
				if ( id==null ) {
					msg = event.firstChild.nodeValue;
					GameManager.warning("@ level "+game.world.currentId+", script still using inline text value");
				}
				else {
					msg = Lang.get(id);
				}
				if ( msg!=null ) {
					game.attachPop("\n"+msg,false);
				}
			break;

			case E_KILLMSG:
				game.killPop();
			break;

			case E_POINTER:
				var p = game.getOne(Data.PLAYER);
				var cx = getInt(event, "$x");
				var cy = getInt(event, "$y");
				cx = game.flipCoordCase(cx);
				game.attachPointer( cx,cy, p.cx,p.cy )
			break;

			case E_KILLPTR:
				game.killPointer();
			break;

			case E_MC:
				var cx = getInt(event, "$x");
				var cy = getInt(event, "$y");
				var xr = getInt(event, "$xr");
				var yr = getInt(event, "$yr");
				var sid = getInt(event, "$sid");
				var back = getInt(event, "$back");
				var name = getString(event, "$n");
				var p = getInt(event, "$p");
				// WARNING: "name" must be "$"-escaped against obfu
				killById(sid);
				var x,y;
				if  ( xr==null ) {
					x = Entity.x_ctr(cx);
					y = Entity.y_ctr(cy);
				}
				else {
					x = xr;
					y = yr;
				}
				x = game.flipCoordReal(x);
				if ( game.fl_mirror ) {
					x += Data.CASE_WIDTH;
				}
				var mc = game.world.view.attachSprite(  name, x, y, (back==1)?true:false );
				if ( game.fl_mirror ) {
					mc._xscale *= -1;
				}
				if ( p>0 ) {
					mc.play();
				}
				else {
					mc.stop();
				}
				downcast(mc).sub.stop();
				if ( name=="$torch" ) {
					if ( !fl_firstTorch ) {
						game.clearExtraHoles();
					}
					game.addHole(x+Data.CASE_WIDTH*0.5,y-Data.CASE_HEIGHT*0.5,180);
					game.updateDarkness();
					fl_firstTorch = true;
				}
				mcList.push(  {sid:sid, mc:mc}  );
			break;

			case E_PLAYMC:
				var sid = getInt(event,"$sid");
				playById(sid);
			break;

			case E_MUSIC:
				var id = getInt(event, "$id");
				game.playMusic(id);
			break;

			case E_ADDTILE:
				var cx1	= getInt(event, "$x1");
				var cy1	= getInt(event, "$y1");
				var cx2	= getInt(event, "$x2");
				var cy2	= getInt(event, "$y2");
				cx1 = game.flipCoordCase(cx1);
				cx2 = game.flipCoordCase(cx2);
				var id	= getInt(event, "$type");
				if ( id > 0 ) {
					id = -id;
				}
				else {
					id = Data.GROUND;
				}
				while ( cx1!=cx2 || cy1!=cy2 ) {
					game.world.forceCase( cx1,cy1, id );
					if ( cx1 < cx2 )	{ cx1++; }
					if ( cx1 > cx2 )	{ cx1--; }
					if ( cy1 < cy2 )	{ cy1++; }
					if ( cy1 > cy2 )	{ cy1--; }
				}
				game.world.forceCase( cx1,cy1, id );
				fl_redraw = true;
			break;

			case E_REMTILE:
				var cx1 = getInt(event, "$x1");
				var cy1 = getInt(event, "$y1");
				var cx2 = getInt(event, "$x2");
				var cy2 = getInt(event, "$y2");
				cx1 = game.flipCoordCase(cx1);
				cx2 = game.flipCoordCase(cx2);
				while ( cx1!=cx2 || cy1!=cy2 ) {
					game.world.forceCase( cx1,cy1, 0 );
					if ( cx1 < cx2 )	{ cx1++; }
					if ( cx1 > cx2 )	{ cx1--; }
					if ( cy1 < cy2 )	{ cy1++; }
					if ( cy1 > cy2 )	{ cy1--; }
				}
				game.world.forceCase( cx1,cy1, 0 );
				fl_redraw = true;
			break;

			case E_ITEMLINE:
				var cx1	= getInt(event, "$x1");
				var cx2	= getInt(event, "$x2");
				var cy	= getInt(event, "$y");
				var id	= getInt(event, "$i");
				var subId	= getInt(event, "$si");
				var time	= getInt(event, "$t");
				var i=0;
				var fl_done = false;
				while ( !fl_done ) {
					addScript(
						'<'+T_TIMER+' $t="'+(cycle+i*time)+'">'+
						'<'+E_SCORE+' $i="'+id+'" $si="'+subId+'" $x="'+cx1+'" $y="'+cy+'" $inf="1" />'+
						'</$'+T_TIMER+'>'
					);

					if ( cx1==cx2 ) {
						fl_done = true;
					}
					if ( cx1 < cx2 )	{ cx1++; }
					if ( cx1 > cx2 )	{ cx1--; }
					i++;
				}
			break;

			case E_GOTO:
				var id = getInt(event,"$id");
				game.forcedGoto(id);
			break;

			case E_HIDE:
				var fl_t = (getInt(event, "$tiles")==1)?true:false;
				var fl_b = (getInt(event, "$borders")==1)?true:false;
				game.world.view.fl_hideTiles = fl_t;
				game.world.view.fl_hideBorders = fl_b;
				game.world.view.detach();
				game.world.view.attach();
				game.world.view.moveToPreviousPos();
			break;

			case E_HIDEBORDERS:
				game.world.view.fl_hideTiles = true;
				game.world.view.detach();
				game.world.view.attach();
				game.world.view.moveToPreviousPos();
			break;


			case E_CODETRIGGER :
				var id = getInt(event,"$id");
				codeTrigger(id);
			break;


			case E_PORTAL:
				if ( game.fl_clear && cycle>10 ) {
					var pid = getInt(event,"$pid");
					if ( !game.usePortal(pid, null) ) {
						// do nothing ?
					}
				}
			break;


			case E_SETVAR:
				var name = getString(event,"$var");
				var value = getString(event,"$value");
				game.setDynamicVar(name,value);
			break;

			case E_OPENPORTAL:
				var cx = getInt(event,"$x");
				var cy = getInt(event,"$y");
				var pid = getInt(event,"$pid");
				game.openPortal(cx,cy,pid);
			break;

			case E_DARKNESS:
				var v = getInt(event, "$v");
				game.forcedDarkness = v;
				game.updateDarkness();
			break;

			case E_FAKELID:
				var lid = getInt(event, "$lid");
				if ( Std.isNaN(lid) ) {
					game.fakeLevelId = null;
					game.gi.hideLevel();
				}
				else {
					game.fakeLevelId = lid;
					game.gi.setLevel(lid);
				}
			break;


			default:
				// Event inconnu ? Peut etre un trigger ?
				if ( isTrigger(event.nodeName) ) {
					script.appendChild(event);
				}
				else {
					GameManager.warning("unknown event: "+event.nodeName+" (not a trigger)");
				}
			break;
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE NOM DE NODE DONNÉ EST UN TRIGGER
	------------------------------------------------------------------------*/
	function isTrigger(n:String) {
		return (n==T_TIMER || n==T_POS || n==T_ATTACH || n==T_DO || n==T_END || n==T_BIRTH || n==T_DEATH ||
				n==T_EXPLODE || n==T_ENTER || n==T_NIGHTMARE || n==T_MIRROR || n==T_MULTI || n==T_NINJA );
	}

	/*------------------------------------------------------------------------
	SCRIPT: TESTE SI UN TRIGGER EST ACTIVÉ
	------------------------------------------------------------------------*/
	function checkTrigger( trigger:XmlNode ) : bool {
		if ( trigger.nodeName==null || trigger.nodeName=="" ) {
			return false;
		}


		switch (trigger.nodeName) {
			case T_TIMER: // timer
				if ( cycle >= getInt(trigger,"$t") ) {
					return true;
				}
			break;
			case T_POS: // player position
				var l = game.getPlayerList();
				var x = getInt(trigger,"$x");
				var y = getInt(trigger,"$y");
				x = game.flipCoordCase(x);
				var dist = getInt(trigger,"$d");
				for (var i=0;i<l.length;i++) {
					if ( !l[i].fl_kill && !l[i].fl_destroy ) {
						var d = l[i].distanceCase(x,y);
						if ( d<=dist && !Std.isNaN(d) ) {
							return true;
						}
					}
				}
			break;
			case T_ATTACH: // attachement du niveau
				if ( fl_onAttach ) {
					return true;
				}
			break;
			case T_DO: // exécution inconditionnelle d'events
				return true;
			break;
			case T_END: // level terminé
				if ( game.fl_clear && cycle>10 ) {
					return true;
				}
			break;
			case T_BIRTH: // le joueur depuis le dernier cycle
				if ( fl_birth ) {
					return true;
				}
			break;
			case T_DEATH:
				if ( fl_death ) {
					return true;
				}
			break;
			case T_EXPLODE:
				var x = Entity.x_ctr(  getInt(trigger,"$x")  );
				var y = Entity.y_ctr(  getInt(trigger,"$y")  );
				x = game.flipCoordReal(x);
				for (var i=0;i<recentExp.length;i++) {
					var expl = recentExp[i];
					var sqrDist = Math.pow(x-expl.x, 2) + Math.pow(y-expl.y, 2);
					if ( sqrDist <= Math.pow(expl.r, 2) ) {
						if ( Math.sqrt(sqrDist) <= expl.r ) {
							return true;
						}
					}
				}
			break;
			case T_ENTER:
				var cx = getInt(trigger,"$x");
				var cy = getInt(trigger,"$y");
				cx = game.flipCoordCase(cx);
				for (var i=0;i<entries.length;i++) {
					if ( entries[i].cx==cx && entries[i].cy==cy ) {
						return true;
					}
				}
			break;

			case T_NIGHTMARE:
				return game.fl_nightmare;
			break;

			case T_MIRROR:
				return game.fl_mirror;
			break;

			case T_MULTI:
				return game.getPlayerList().length>1;
			break;

			case T_NINJA:
				return game.fl_ninja;
			break;

			default:
				GameManager.warning("unknown trigger "+trigger.nodeName);
			break;
		}
		return false;
	}


	/*------------------------------------------------------------------------
	SCRIPT: LANCE UN TRIGGER
	------------------------------------------------------------------------*/
	function executeTrigger( trigger:XmlNode ) {
		var event;

		traceHistory(trigger.nodeName);

		event = trigger.firstChild;
		while (event!=null) {
			executeEvent(event);
			event = event.nextSibling;
		}


		// Compteur de répétition
		var total = getInt(trigger,"$repeat");
		if ( !Std.isNaN(total) ) {
			total--;
			traceHistory("R "+trigger.nodeName+": "+total);
			trigger.set("$repeat",""+total);


			if ( total==0 ) {
				// Fin de répétition
				trigger.removeNode();
			}
			else {
				// Répétition
				if ( trigger.nodeName==T_TIMER ) {
					var str = trigger.get("$base");
					if ( str==null ) {
						str = trigger.get("$t");
						trigger.set("$base", str);
					}
					var timer = Std.parseInt(str,10);
					timer += cycle;
					trigger.set("$t",""+timer);
				}
			}
		}
		else {
			traceHistory("X "+trigger.nodeName);
			trigger.removeNode();
		}


	}


	/*------------------------------------------------------------------------
	INSERTION DE LA BADLIST DANS LE SCRIPT
	------------------------------------------------------------------------*/
	function insertBads():int {
//		if ( game.globalActives[12] ) { // parapluie bleu
//			game.globalActives[12] = false;
//			return 0;
//		}
//		if ( game.globalActives[108] ) { // parapluie vert
//			game.globalActives[108] = false;
//			return 0;
//		}
		var str='<'+T_DO+'>';
		for (var i=0;i<data.$badList.length;i++) {
			var b = data.$badList[i];
			str+='<'+E_BAD+' $i="'+b.$id+'" $x="'+b.$x+'" $y="'+b.$y+'" $sys="1"/>';
		}
		str+='</'+T_DO+'>';
		addScript(str);
		return data.$badList.length;
	}


	/*------------------------------------------------------------------------
	INSERTION: ITEM
	------------------------------------------------------------------------*/
	function insertItem(event:String, id:int,subId:int, x:int,y:int, t:int, repeat:int, fl_inf, fl_clearAtEnd) {
		var subStr;
		if (subId==null) {
			subStr="";
		}
		else {
			subStr=string(subId);
		}

		var doStr = "";
		if (repeat!=null) {
			doStr = ' $repeat="'+repeat+'"';
		}

		addScript (
			'<'+T_TIMER+' $t="'+(cycle+t)+'" '+doStr+' $endClear="'+(fl_clearAtEnd?'1':'0')+'">'+
			'<'+event+' $x="'+x+'" $y="'+y+'" $i="'+id+'" $si="'+subStr+'" $inf="'+(fl_inf?'1':'')+'" $sys="1"/>'+
			'</'+T_TIMER+'>'
		);
	}

	/*------------------------------------------------------------------------
	INSERTION: ITEM SPÉCIAL
	------------------------------------------------------------------------*/
	function insertSpecialItem(id:int,sid:int, x:int,y:int, t:int, repeat:int, fl_inf, fl_clearAtEnd) {
		insertItem(E_SPECIAL, id,sid,x,y,t,repeat,fl_inf, fl_clearAtEnd);
	}

	/*------------------------------------------------------------------------
	INSERTION: BONUS
	------------------------------------------------------------------------*/
	function insertScoreItem(id:int,sid:int, x:int,y:int, t:int, repeat:int, fl_inf, fl_clearAtEnd) {
		insertItem(E_SCORE, id,sid,x,y,t,repeat,fl_inf, fl_clearAtEnd);
	}


	/*------------------------------------------------------------------------
	INSERTION DES EXTENDS RÉGULIERS
	------------------------------------------------------------------------*/
	function insertExtend() {
		var s = '<'+T_TIMER+' $t="'+Data.EXTEND_TIMER+'" $repeat="-1" $endClear="1"><'+E_EXTEND+'/></'+T_TIMER+'>';
		addScript(s);
	}


	function insertPortal(cx:int,cy:int,pid:int) {
		addScript(
			'<'+T_POS+' $x="'+cx+'" $y="'+cy+'" $d="1" $repeat="-1">'+
			'<'+E_PORTAL+' $pid="'+pid+'"/>'+
			'</'+T_POS+'>'
		);
	}


	/*------------------------------------------------------------------------
	SCRIPT: EXÉCUTE LE SCRIPT DU NIVEAU
	------------------------------------------------------------------------*/
	function runScript() {
		var trigger : XmlNode;
		if ( script==null ) {
			return;
		}

		trigger = script.firstChild;
		while ( trigger!=null ) {
			if ( checkTrigger(trigger) ) {
				// World keys
				var kid = getInt(trigger, "$key");
				if ( !game.hasKey(kid) ) {
					if ( isVerbose(trigger.nodeName) ) {
						game.fxMan.keyRequired( kid );
					}
				}
				else {
					if ( kid!=null ) {
						game.fxMan.keyUsed( kid );
					}
					executeTrigger(trigger);
				}
			}

			trigger = trigger.nextSibling;
		}
		fl_birth		= false;
		fl_death		= false;
		fl_onAttach		= false;
		recentExp		= new Array();
		entries			= new Array();
		fl_onAttach		= false;
	}


	/*------------------------------------------------------------------------
	CRÉATION DE LA NODE XML DU SCRIPT
	------------------------------------------------------------------------*/
	function compile() {
		history = new Array();

		// Debug: log
		traceHistory(baseScript);
		var node = new Xml(baseScript).firstChild;
		while ( node!=null ) {
			if ( node.nodeName!=null ) {
				traceHistory("b "+node.nodeName);
			}
			node = node.nextSibling;
		}
		node = new Xml(extraScript).firstChild;
		while ( node!=null ) {
			if ( node.nodeName!=null ) {
				traceHistory("b2 "+node.nodeName);
			}
			node = node.nextSibling;
		}

		// Compilation
		var doc = new Xml(baseScript+" "+extraScript);
		doc.ignoreWhite = true;
		if ( doc==null ) {
			GameManager.fatal("compile: invalid XML");
		}
		else {
			this.script = doc;
		}


		normalMode();
		fl_compile	= true;
		traceHistory("first="+cycle);
		runScript(); // lecture du premier cycle du script
	}


	/*------------------------------------------------------------------------
	DÉTRUIT LE SCRIPT "COMPILÉ"
	------------------------------------------------------------------------*/
	function clearScript() {
		this.script = null;
		baseScript = "";
		extraScript = "";
		cycle = 0;
		fl_compile = false;
	}


	/*------------------------------------------------------------------------
	DÉTRUIT TOUS LES TRIGGERS TIMÉS
	------------------------------------------------------------------------*/
	function clearEndTriggers() {
		var trigger : XmlNode;
		trigger = script.firstChild;
		while (trigger!=null) {
			var next = trigger.nextSibling;
			if ( trigger.get("$endClear")== "1" ) {
				traceHistory("eX "+trigger.nodeName);
				trigger.removeNode();
			}
			trigger = next;
		}
	}


	/*------------------------------------------------------------------------
	REMISE À ZÉRO (DÉBUT DE LEVEL)
	------------------------------------------------------------------------*/
	function reset() {
		cycle=0;
		traceHistory("(r)");
	}


	/*------------------------------------------------------------------------
	DÉTRUIT UNE ENTITÉ CRÉÉE PAR UN SCRIPT
	------------------------------------------------------------------------*/
	function killById(id:int) {
		if ( id==null ) {
			return;
		}
		var l = game.getList(Data.ENTITY);
		for (var i=0;i<l.length;i++) {
			if ( l[i].scriptId == id ) {
				l[i].destroy();
			}
		}

		for (var i=0;i<mcList.length;i++) {
			if ( mcList[i].sid == id ) {
				mcList[i].mc.removeMovieClip();
				mcList.splice(i,1);
				i--;
			}
		}
	}


	/*------------------------------------------------------------------------
	JOUE UNE ENTITÉ CRÉÉE PAR UN SCRIPT
	------------------------------------------------------------------------*/
	function playById(id:int) {
		if ( id==null ) {
			return;
		}
		for (var i=0;i<mcList.length;i++) {
			if ( mcList[i].sid == id ) {
				mcList[i].mc.play();
				downcast(mcList[i].mc).sub.play();
			}
		}
	}


	/*------------------------------------------------------------------------
	CODES SPÉCIFIQUES NON-SCRIPTABLES
	------------------------------------------------------------------------*/
	function codeTrigger(id:int) {
		switch (id) {
			case 0: // Seau 1er level
				downcast(game).fl_warpStart = true;
			break;

			case 1: // long hurry up
				game.huTimer -= Timer.tmod*0.5;
			break;

			case 2: // anti fleche de sortie
				game.fxMan.detachExit();
			break;

			case 3: // libération des fruits
				playById(101);
				fl_elevatorOpen = true;
				var l = game.getPlayerList();
				for (var i=0;i<l.length;i++) {
					l[i].lockControls(Data.SECOND*12.5);
					l[i].dx = 0;
				}
				game.huTimer = 0;
			break;

			case 4: // sortie par l'ascenseur
				if ( fl_elevatorOpen ) {
					var l = game.getPlayerList();
					for (var i=0;i<l.length;i++) {
						l[i].hide();
						l[i].lockControls(99999);
						game.huTimer = 0;
					}

					for (var i=0;i<mcList.length;i++) {
						if ( mcList[i].sid == 101 ) {
							downcast(mcList[i].mc).head = game.getPlayerList()[0].head
						}
					}
					playById(101);
					game.endModeTimer = Data.SECOND*14;
					fl_elevatorOpen = false;
				}
			break;

			case 5: // sortie après tuberculoz
				if ( downcast(game.getOne(Data.BOSS)).fl_defeated ) {
					bossDoorTimer-=Timer.tmod;
					if ( bossDoorTimer<=0 ) {
						game.destroyList(Data.BOSS);
						game.world.view.destroy();
						game.forcedGoto(102);
					}
				}
			break;

			case 6: // attachement de ballons en sur les slots spéciaux
				var s = game.world.current.$specialSlots[ Std.random(game.world.current.$specialSlots.length) ];
				var b = entity.bomb.player.SoccerBall.attach(
					game,
					Entity.x_ctr(s.$x),
					Entity.y_ctr(s.$y)
				);
				b.dx = (10+Std.random(10)) * (Std.random(2)*2-1);
				b.dy = -Std.random(5)-5
			break;

			case 7: // igor pleure
				var pl = game.getPlayerList();
				for (var i=0;i<pl.length;i++) {
					pl[i].setBaseAnims( Data.ANIM_PLAYER_WALK, Data.ANIM_PLAYER_STOP_L );
				}
			break;

			case 8: // igor est content
				var pl = game.getPlayerList();
				for (var i=0;i<pl.length;i++) {
					pl[i].setBaseAnims( Data.ANIM_PLAYER_WALK_V, Data.ANIM_PLAYER_STOP_V );
				}
			break;

			case 9: // rire tuberculoz
				game.soundMan.playSound("sound_boss_laugh", Data.CHAN_BAD);
			break;

			case 10: // désactive les jump down sur les monstres !
				var l = game.getBadList();
				for (var i=0;i<l.length;i++) {
					downcast(l[i]).setJumpDown(null);
				}
			break;

			case 11: // tue tous les bads (clear only)
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					var b = l[i];
					game.fxMan.attachFx( b.x, b.y-Data.CASE_HEIGHT, "hammer_fx_pop" );
					b.destroy();
				}
			break;

			case 12: // force le hurry up (à utiliser avec parcimonie)
				while ( game.huState<2 ) {
					var mc = game.onHurryUp();
					if ( game.huState<2 ) {
						mc.removeMovieClip();
					}
				}
			break;

			case 13: // détruit tous les items (score & special)
				var l = game.getList(Data.ITEM);
				for (var i=0;i<l.length;i++) {
					var it = l[i];
					game.fxMan.attachFx( it.x, it.y-Data.CASE_HEIGHT, "hammer_fx_pop" );
					it.destroy();
				}
			break;

			case 14: // efface les lumières de torches
				game.clearExtraHoles();
			break;

			case 15: // reset hurry (dangeureux !)
				game.resetHurry();
			break;

			default:
				GameManager.fatal("code trigger #"+id+" not found!");
			break;
		}
	}


	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function update() {
		if ( fl_compile ) {
			cycle+=Timer.tmod;
			runScript();
		}

		if ( fl_redraw ) {
			fl_redraw = false;
			game.world.view.detachLevel();
			game.world.view.displayCurrent();
			game.world.view.moveToPreviousPos();
		}
		fl_firstTorch = false;
	}

}
