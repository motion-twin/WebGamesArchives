import Types;
import Progress;
import mt.bumdum.Lib;
import flash.display.BitmapData;
import MissionGen;
import Tutorial;



enum NodeType {
	Empty;			// 1
	TargetEmpty;	// 3
	Entrance;		// 4
	Terminal;		// 5
	Gateway;		// 6
	Printer;		// 7
	Slower;			// 8 // ???
	TerminalMul;	// 9
	Database;		// 10
	Keypad;			// 11
	Camera;			// 12
	CrimeDatabase;	// 13
	LockServer;		// 14
	BigDisplay;		// 15
	GameServer;		// 16 // TODO
	Ftp;			// 17 // TODO
	Tv;				// 18
	TutoTerm;		// 19
	TutoFirewall;	// 20
	LockServerLight;// 21
	Alarm;			// 22
	Treasure;		// 23
}

typedef NetNode = {
	mc			: MCNode,
	id			: Int,
	ip			: String,
	type		: NodeType,
	x			: Int,
	y			: Int,
	links		: List<{mc:flash.MovieClip,node:NetNode}>,
	users		: Array<String>,
	dist		: Int,
	path		: Array<NetNode>,
	system		: GFileSystem,
	sibling		: NetNode,
	fl_target	: Bool,
	fl_visible	: Bool,
	fl_generated: Bool,
}



class GNetwork {
	static private var MAX_TRIES = 200;
	static private var SCROLL_SPEED = 0.15;
	static private var SMARGIN = 120;
	static private var DEAD_X = 0.25;
	static private var DEAD_Y = Data.HEI/Data.WID * DEAD_X;
	static private var HEXWID = 128;
	static private var HEXHEI = 64;
	static private var MAX_SCROLLING_SPAMS = 3;
	static private var DIST_COLORS = [
		0x888888,
		0x9f9f00,
		0xcc6600,
		0xcc0000,
		0x666699,
		0x8800bb,
	];

	var term		: UserTerminal;

	var uniq		: Int;
	var seed		: Int;
	var rseed		: mt.Rand;
	var map			: Array<Array<NetNode>>;
	var nodes		: List<NetNode>;
	var wid			: Int;

	var genTries	: Int;
	var genEmpty	: Int;

	var users				: Array<String>;
	var baseIp				: String;
	public var owner		: String;

	var tmc					: TargetMC;
	public var sdm			: mt.DepthManager;
	var ldm					: mt.DepthManager;
	var groundField			: MCField;
//	var bg2					: flash.MovieClip;
	var dotLines			: Array<flash.MovieClip>;
	var scroller			: flash.MovieClip;
	var stx					: Int;
	var sty					: Int;
	var sx					: Float;
	var sy					: Float;
	var spamCpt				: Float;
	var gspamList			: List<{mc:flash.MovieClip, dx:Float,dy:Float, bmp:BitmapData}>;
	var scrollSpeed			: Float;

	var fl_lock				: Bool;
	var fl_spamDir			: Bool;

	public var passList		: Array<{user:String,p:String}>;

//	var useful				: Int;
	public var fl_generated	: Bool;

	public var curNode		: NetNode;



	public function new(t:UserTerminal) {
		term = t;
		seed = term.mdata._seed;
		uniq = 0;
		wid = 11;
		stx = 0;
		sty = 0;
		genTries = 0;
		dotLines = new Array();
		spamCpt = Data.SECONDS(7);
		gspamList = new List();
		scrollSpeed = if ( term.fl_lowq ) SCROLL_SPEED*2 else SCROLL_SPEED;

		fl_spamDir = true;
		fl_generated = false;
		fl_lock = false;
		initRand();
//		useful = switch(term.gameLevel) {
//			case 1 : 2+rseed.random(2);
//			case 2 : 3+rseed.random(4);
//			case 3 : 3+rseed.random(5);
//			case 4 : 5+rseed.random(5);
//			default : 6+rseed.random(5);
//		}
		baseIp = TD.texts.get("baseIp");
		scroller = Manager.DM.empty(Data.DP_ITEM);
		sx = 0;
		sy = 0;
		sdm = new mt.DepthManager(scroller);
		#if debug
			trace("NETWORK : seed="+seed+" wid="+wid+" gameLevel="+term.gameLevel+" gameDiff="+term.gameDiff);
			trace("!!! DEBUG MODE !!!");
			if ( Manager.STANDALONE )
				trace("STANDALONE mode");
		#end
	}


	// *** GENERATION

	function updateGenerate() {
		if ( nodes==null ) {

//		var useful = switch(term.gameLevel) {
//			case 1 : 2+rseed.random(2);
//			case 2 : 3+rseed.random(4);
//			case 3 : 3+rseed.random(5);
//			case 4 : 5+rseed.random(5);
//			default : 6+rseed.random(5);
//		}

			initMap();

//			total = useful; // HACK

			try {
				generateStructure();
				generateDetails();
//				generate(useful,total,gw);
				dispatchUsers();
				createMissionNode();
			}
			catch(e:String) {
				#if debugGen
					trace("GEN ERROR: "+e+" seed="+seed);
				#end
				genTries++;
				seed++;
				nodes = null;
				if ( genTries>MAX_TRIES)
					Manager.fatal("can't generate");
				return;
			}

			computePath();
			return;
		}
		else {
			try {
				for (node in nodes)
					if ( !node.fl_generated ) {
						generateFS(node);
						return;
					}

				// on détermine le système protégé par les micro-verrous
				#if debugGen trace("LockServerLight"); #end
				for(lock in getNodes(LockServerLight)) {
					var list = new Array();
					for (node in getNodes()) {
						if ( node==lock || node.type==Empty )
							continue;
						if ( isLinkedTo(node,LockServerLight) && node.dist==lock.dist )
							list.push(node);
					}
					lock.sibling = list[rseed.random(list.length)];
				}

				#if debugGen trace("updateMissionSystems"); #end
				updateMissionSystems();
				for (node in nodes)
					if ( node.type!=Empty ) {
						#if debugGen trace("fillRouteFiles node="+node.system.debug()); #end
						node.system.fillRouteFiles(getNeighbours(node));
					}
				#if debugGen trace("storeMasterpasswords"); #end
				storeMasterPasswords();
				#if debugGen trace("dispatchMoney"); #end
				dispatchMoney(term.mdata._bonus);
				#if debugGen trace("dispatchCards"); #end
				dispatchCards(term.mdata._cards);
			}
			catch(e:String) {
				Manager.fatal(e);
			}
		}

		#if debugGen trace("update generate DONE"); #end
		// terminé !
		initRand();
		onGenerate();
	}




	function generateStructure() {
		var useful = 1;
		switch(term.gameLevel) {
			case 1	: useful=1;
			case 2	: useful=3;
			case 3	: useful=3;
			case 4	: useful=4;
			case 5	: useful=5;
			case 6	: useful=6;
			case 7	: useful=7;
			case 8	: useful=7;
			default	:
				useful = 8+(term.gameLevel-8);
		}

		if ( term.gameLevel>=3 )
			useful+=rseed.random(2);
		if ( term.gameLevel>=8 )
			useful+=rseed.random(2);

		if ( rseed.random(100)<66 )
			genEmpty = rseed.random(5);
		else
			genEmpty = rseed.random(8)+4; // réseau étendu (lignes longues)

		// tuto 1
		if ( MissionGen.isType(term.mdata, _MTutorial) ) {
			useful = 1;
			genEmpty = 1;
		}

		// tuto 2
		if ( MissionGen.isType(term.mdata, _MTutorialDelete(null,null)) ) {
			useful = 3;
			genEmpty = 2;
		}

		// tuto 3
		if ( MissionGen.isType(term.mdata, _MTutorialBypass(null)) ) {
			useful = 1;
			genEmpty = 1;
		}

		#if debugGen
			trace("generate: useful="+useful+" genEmpty="+genEmpty);
		#end
		initRand();
		var x = Std.int(wid*0.5);
		var y = Std.int(wid*0.5);
		initMap();
		var remain = generateNode( x,y, useful );
		if ( remain>0 ) throw "tree failed";

		nodes = getNodes();
		makeAllLinks();
	}


	function generateDetails() {
//		if ( term.gameLevel<=3 ) {
//			// flat mode
//			var remain = removeNodes(total-useful-1, true );
//			if ( remain>0 )
//				removeNodes(remain, false);
//		}
//		else {
//			// normal mode (beaucoup de terminaux à la suite les uns des autres...)
//			removeNodes(total-useful-1, false );
//		}

		// firewalls
		var gw = 0;
		switch(term.gameLevel) {
			case 1	:
			case 2	:
			case 3	:
			case 4	:
			case 5	: gw=1;
			case 6	: gw=1+rseed.random(2);
			case 7	: gw=2;
			default	:
				gw = 3;
		}
		if ( MissionGen.isType(term.mdata, _MTutorialBypass(null)) )
			gw = 1;
		#if debugGen trace("firewalls="+gw); #end
		addGateways(getOne(Entrance),gw);
		computeDist();

		// serveurs VERROU
		if ( term.gameLevel>=5 && count(Terminal)>=3 && rseed.random(100)<60 )
			if ( term.gameLevel>=7 && rseed.random(100)<75 )
				addReactiveNodes(LockServer, 1);
			else
				addReactiveNodes(LockServerLight, 1);
		computeDist();

		// serveurs ALARM
		if ( term.gameLevel>=5 && count(Terminal)>=3 ) {
			var na = if (term.gameLevel==5) rseed.random(2);
				else if (term.gameLevel==6) 1;
				else if (term.gameLevel<=8) rseed.random(2)+1;
				else rseed.random(2)+2;
			addReactiveNodes(Alarm, na, 1);
		}
		computeDist();

		// serveurs TRESOR
		if ( term.gameLevel>=7 && count(Terminal)>=2 && rseed.random(100)<60 )
			transform(1, Terminal, Treasure, 0,5);
		computeDist();

		// nodes diverses
		if ( !MissionGen.isTutorial( term.mdata ) ) {
			if ( count(Terminal)>=3 && rseed.random(100)<50 )
				transform(Terminal, Printer, 0,999, 1,1);
			if ( count(Terminal)>=3 && rseed.random(100)<50 )
				transform(Terminal, Database, 0,999, 1,1);
		}
		computeDist();

		// mission target node
		var tn = getHardNode(Terminal,3);
		if ( tn==null )
			throw "no target node !";
		else
			tn.type = TargetEmpty;
		if ( tn.dist<=1 && term.gameLevel>=5 )
			throw "too easy...";
		if ( tn.dist>5 && term.gameLevel<=5 )
			throw "too hard...";

		if ( tn.dist>2 && term.gameLevel==4 )
			throw "too hard...";

		if ( MissionGen.isType(term.mdata, _MTutorialDelete(null,null)) )
			for (n in nodes)
				if ( n.dist>1 )
					throw "too hard for tutorial";
	}



	function generateFS(node:NetNode) {
		node.fl_generated = true;
		node.system = new GFileSystem(term, node.type, term.gameDiff);
//		if ( node.system.canConnect() ) {
			node.system.setUsers(node.users);
			node.system.generate(seed+node.id);
//		}

		if ( node.type==Entrance )
			node.system.fl_auth = true;
	}


	function storeMasterPasswords() {
		var list = new Array();
		for (n in nodes)
			if ( n.system.canConnect() )
				list.push({u:if(n.system.owner!=null) n.system.owner else n.system.name, p:n.system.mpass});

		if ( list.length==0 )
			return;

		var content = "";
		for (e in list)
			content+=e.u+" : "+e.p+"\n";


		for (n in nodes) {
			if ( !n.system.canConnect() )
				continue;
			var gpList = n.system.getFilesByKey("global.pass");
			if ( gpList.length>0 ) {
				#if debugGen trace("storeMasterPasswords in "+n.system.debug()); #end
				for (f in gpList) {
					var str = TD.texts.get("globalPassHeader");
					str+=content;
					str+= TD.texts.get("globalPassFooter");
					f.content = str;
				}
			}
		}
	}


	inline function initRand() {
		rseed = Data.newRandSeed(seed);
	}


	function initMap() {
		passList = new Array();
		uniq = 0;
		map = new Array();
		for (i in 0...wid) {
			map[i] = new Array();
		}
	}


	function generateNode(x:Int,y:Int,remain:Int, ?dist=0) : Int {
		var node : NetNode = {
			mc			: null,
			id			: uniq,
			ip			: baseIp+uniq,
			x			: x,
			y			: y,
			type		: if(uniq==0) Entrance else Terminal,
			links		: new List(),
			users		: new Array(),
			dist		: -1,
			path		: null,
			system		: null,
			sibling		: null,
			fl_target	: false,
			fl_visible	: false,
			fl_generated: false,
		}
		uniq++;

		if ( node.type==Terminal )
			if ( dist<5 && genEmpty>0 && rseed.random(100) < 80 ) {
				node.type = Empty;
				genEmpty--;
			}
			else
				remain--;
		map[x][y] = node;

		while ( remain>0 ) {
			var list = new Array();
			if ( y>0 && map[x][y-1]==null )		list.push({x:x,y:y-1});
			if ( y<wid-1 && map[x][y+1]==null )	list.push({x:x,y:y+1});
			if ( x>0 && map[x-1][y]==null )		list.push({x:x-1,y:y});
			if ( x<wid-1 && map[x+1][y]==null )	list.push({x:x+1,y:y});
			if ( list.length==0 ) {
				break;
			}
			else {
				var next = list[ rseed.random(list.length) ];
				var branch = Math.round((rseed.random(100)/100)*remain);
				if ( branch>0 ) {
					if ( node.type==Entrance || list.length==1 ) branch = remain;
					remain -= branch;
					var notAdded = generateNode( next.x, next.y, branch, dist+1 );
					if ( notAdded!=branch )
						node.links.add( {mc:null, node:map[next.x][next.y]} );

					if ( notAdded>0 && node.type==Entrance ) return 1;
					remain += notAdded;
				}
			}

		}
		return remain;
	}


	function makeAllLinks() {
		for (node in nodes)
			for (link in node.links) {
				var fl_found = false;
				for (link2 in link.node.links)
					if ( link2.node==node ) {
						fl_found = true;
						break;
					}
				if ( !fl_found )
					map[link.node.x][link.node.y].links.add({mc:null,node:node});
			}
	}


	function removeNodes(n:Int, fl_flatMode:Bool) {
		var pool = new Array();
		for( node in nodes)
			if ( node.type!=Entrance && (!fl_flatMode || fl_flatMode && node.links.length>1) )
				if ( node.links.length>1 ) {
					// plus de chance qu'on vire les terminaux centraux
					pool.push(node);
					if ( term.gameLevel>=4 ) {
						pool.push(node);
						pool.push(node);
					}
				}
				else
					pool.push(node);

		while (n>0 && pool.length>=0) {
			var i = rseed.random(pool.length);
			if ( pool[i].type!=Empty ) {
				n--;
				pool[i].type = Empty;
			}
			pool.splice(i,1);
		}
		// impasses
		for (node in nodes)
			if ( node.type==Empty && node.links.length==1 )
				recursiveRemove(node);

		return n;
	}

	function recursiveRemove(node:NetNode) {
		if ( node.type!=Empty || node.links.length!=1 )
			return;

		var next = node.links.first().node;
		node.links = new List();
		for (nl in next.links)
			if ( nl.node==node )
				next.links.remove(nl);
		recursiveRemove(next);
		deleteNode(node);
	}


	function deleteNode(node:NetNode) {
		map[node.x][node.y] = null;
		nodes.remove(node);
	}


	function addGateways(node:NetNode, n:Int) {
		if ( n<=0 ) return;
		var pool = new Array();
		for (node in nodes)
			if ( node.type==Empty ) pool.push(node);

		if ( n>pool.length ) throw "no room for "+n+" gateways";

		while ( n>0 && pool.length>0 ) {
			var i = rseed.random(pool.length);
			pool[i].type = Gateway;
			pool.splice(i,1);
			n--;
		}
	}

	function addReactiveNodes(nt:NodeType, count:Int, ?minNeighbours=2) {
		var pool = new Array();
		for (node in nodes)
			if ( node.type==Terminal ) pool.push(node);
		if ( count>pool.length )
			throw "no room for "+count+" reactiveNodes ("+nt+")";
		while( count>0 && pool.length>0 ) {
			var node = pool.splice(rseed.random(pool.length),1)[0];
			//var node = pool[idx];
			var neig = Lambda.filter(getByDist(node.dist), function(n:NetNode) { return n.type!=Empty; });
			if ( neig.length==0 )
				continue;
			var me = this;
			neig = Lambda.filter(neig, function(n:NetNode) { return me.isNeighbour(n,node); });
//			if ( useful<5 && neig.length>=1 || useful>=5 && neig.length>=2 ) {
			if ( neig.length>=minNeighbours ) {
//				if ( term.gameLevel>=7 && rseed.random(100)<50 )
//					node.type = LockServer;
//				else
					node.type = nt;
				for (n2 in neig)
					pool.remove(n2);
				count--;
			}
			//pool.splice(idx,1);
		}
		if ( count>0 )
			throw "addReactiveNodes failed remain="+count;
	}

	function transform( ?n=1, from:NodeType, to:NodeType, ?minDist=0, ?maxDist=999, ?minLinks=1, ?maxLinks=999 ) {
		var list = new Array();
		for (node in nodes)
			if ( node.type==from && node.dist>=minDist && node.dist<=maxDist && node.links.length>=minLinks && node.links.length<=maxLinks ) list.push(node);
		if ( list.length<n )
			throw "transform n="+n+" dist="+minDist+"-"+maxDist+" links="+minLinks+"-"+maxLinks+" failed : found "+list.length+" entity";
		var changed = new Array();
		while( n>0 ) {
			var i = rseed.random(list.length);
			list[i].type = to;
			changed.push(list[i]);
			list.splice(i,1);
			n--;
		}
		return changed;
	}


	function computePath(?node:NetNode,?path:Array<NetNode>) {
		if ( node.path!=null ) return;
		if ( node==null )
			node = getOne(Entrance);
		if ( path==null )
			path = new Array();

//		if ( node.type!=Empty )
			path.push(node);
		node.path = path.copy();

		for (link in node.links)
			computePath(link.node,path.copy());
	}


	function computeDist() {
		for (n in nodes)
			n.dist = -1;
		computeDistRec();
	}

	function computeDistRec(?node:NetNode,?dist:Int=0) {
		if ( node==null )
			node = getOne(Entrance);
		if ( node.dist!=-1 ) return;
		node.dist = dist;
		for (link in node.links) {
			var value = switch(node.type) {
				case Empty			: 0;
				case Gateway		: 4;
				case Slower			: 2;
				default	: 1;
			}
			computeDistRec(map[link.node.x][link.node.y], dist+value);
		}
	}


	function generateUserPool(n:Int) {
		var list = new Array();
		var hashUniq = new Hash();
		for (i in 0...n) {
			var name = "";
			do
				name = TD.names.get("username")
			while(hashUniq.get(name)!=null);
			hashUniq.set(name,true);
			list.push(name);
		}
		Data.shuffle(seed,list);
		return list;
	}


	function dispatchCards(cards:List<String>) {
		var pool = new Array();
		for (n in nodes)
			if ( n.type!=Empty && n.system.countFilesByExt("mail")>0 || n.system.countFilesByExt("doc")>0 )
				pool.push(n);

		if ( pool.length<=0 )
			return;

		// répartition
		for (cc in cards) {
			var node = pool[ rseed.random(pool.length) ];
			var files = if( rseed.random(2)==0 ) node.system.getFilesByKey("file.mail") else node.system.getFilesByKey("file.doc");
			files = Lambda.array(Lambda.filter(files, function(f) {
				return !f.fl_target;
			}));
			var f = files[ rseed.random(files.length) ];
			#if debugGen trace("creditCard : "+cc+" to "+node.system.name+" in "+f.name+" ("+f.getPathString()+")"); #end
			TD.texts.set("card",cc);
			if ( f.ext("mail") )
				f.forceMail(
					TD.texts.get("sellerMail"),
					TD.texts.get("creditCardMail"),
					false
				);
			else {
				f.content = TD.texts.get("creditCardDoc");
				f.name = TD.fsNames.get("creditCard.doc");
			}
		}
	}

	function dispatchMoney(total:Int) {
		// recherche de système contenant des PACKs
		var pool = new Array();
		for (n in nodes)
			if ( n.type!=Empty && n.type!=Treasure && n.system.countFilesByExt("pack")>0 )
				pool.push(n);

		var empty =
			if( pool.length>=6)
				rseed.random(3)+1;
			else if ( pool.length>=4 )
				rseed.random(2)+1;
			else 0;
		while(empty>0) {
			pool.splice( rseed.random(pool.length), 1 );
			empty--;
		}

		var spread = Data.spread(seed, total, pool.length, 5, 20, 25);

		for (n in pool) {
			var m = spread.pop();
			n.system.spreadMoney(m);
		}

		for (n in nodes)
			if ( n.type!=Empty )
				n.system.cleanUpPacks();
	}


	function dispatchUsers() {
		var all = Lambda.filter( getNodes(), function(n) {
			return n.type!=Empty && n.type!=Entrance;
		});
		var max = all.length * 10;

		initRand();
		users = new Array();
		var list = generateUserPool(max);
		for (node in nodes) {
			switch(node.type) {
				case Terminal	: node.users = list.splice(0,1);
				default			:
			}
			if ( node.users.length>0 ) {
				users = users.concat(node.users);
			}
		}
	}


	function onGenerate() {
		fl_generated = true;
		attach();
		owner = term.mdata._corp;
		term.onGenerate();
	}

	function onReleaseNode(node:NetNode) {
		term.detachCMenu();
		if ( Progress.isRunning() )
			return;
		var old = curNode;
		if ( !MissionGen.isTutorial(term.mdata) )
			scrollTo( node.mc._x+scroller._x*0.33, node.mc._y+scroller._y*0.33 );
		curNode = node;

		// target mc
		if (tmc==null) {
			tmc = cast sdm.attach("target",Data.DP_BG);
//			tmc.blendMode = "screen";
			tmc.filters = [ new flash.filters.GlowFilter(0xffffff,0.7,12,12,1) ];
		}
		if ( canReach(node) )
			Col.setPercentColor(tmc, 100, Data.GREEN);
		else
			Col.setPercentColor(tmc, 100, Data.RED);
		tmc._alpha = 50;

		if ( old!=curNode ) {
			tmc._xscale = 175;
			tmc._yscale = tmc._xscale*0.5;
			tmc._x = curNode.mc._x;
			tmc._y = curNode.mc._y-12;
		}

		// fx
		if ( canReach(node) )
			for (i in 0...Std.random(5)+5)
				term.addFx(sdm, Data.DP_BG, AFX_PlayFrames, "fx_glight", node.mc._x, node.mc._y-15);

		// exécution
		if ( node.type==Entrance ) {
			if ( Tutorial.at(Tutorial.get.second, "nowExit") )
				Tutorial.print();
			term.showCMenu(sdm, node.mc._x, node.mc._y-20, [
				{ label:Lang.get.MenuLogout, cb:callback(startConnect,node) },
			]);
		}
		else
			startConnect(node);
		refresh();
	}

//	function isInDeadZone(x,y) {
//		var fl =
//			x>=Data.WID*0.5-Data.WID*DEAD_X && x<=Data.WID*0.5+Data.WID*DEAD_X &&
//			y>=Data.HEI*0.5-Data.HEI*DEAD_Y && y<=Data.HEI*0.5+Data.HEI*DEAD_Y;
//		return fl;
//	}

	function onMouseDown() {
		if ( MissionGen.isTutorial(term.mdata) )
			return;
		stx = Std.int( sx + Data.WID*0.5-Manager.ROOT._xmouse );
		sty = Std.int( sy + Data.HEI*0.5-Manager.ROOT._ymouse );
		term.spam("Moved to "+stx+","+sty);
	}


	function scrollTo(x:Float,y:Float) {
		stx = Std.int((-x + Data.WID*0.5));
		sty = Std.int((-y + Data.HEI*0.5));
		term.spam("Focus at "+stx+","+sty);
	}

	function getFreeLine() {
		var x = Math.ceil(wid*0.5);
		var free = null;
		while (free==null) {
			free = x;
			for (y in 0...wid)
				if ( map[x][y]!=null )
					free = null;
			x++;
		}
		return free;
	}


	// *** MISSIONS

	function createMissionNode() {
		initRand();
		var node = getOne(TargetEmpty);
		node.fl_target = true;
		switch(term.mdata._type) {
			case _MModerate(str) :
				node.type = TerminalMul;
			case _MDelete(owner,fname) :
				node.type = Terminal;
				node.users[0] = owner;
			case _MDeleteAll(owner,ext) :
				node.type = Terminal;
				node.users[0] = owner;
			case _MCopy(owner,fname)	:
				node.type = Terminal;
				node.users[0] = owner;
			case _MSteal(owner,fname)	:
				node.type = Terminal;
				node.users[0] = owner;
			case _MCrashTerminal(str) :
				node.type = Terminal;
				node.users[0] = str;
			case _MCrashPrinter(str) :
				node.type = Printer;
			case _MCrashDB(str) :
				node.type = Database;
			case _MCleanTerminal(owner) :
				node.type = Terminal;
				node.users[0] = owner;
			case _MCopyMail(owner,sender) :
				node.type = Terminal;
				node.users[0] = owner;
			case _MFindMails(owner,n) :
				node.type = Terminal;
				node.users[0] = owner;
			case _MPasswords(str) :
				node.type = Database;
			case _MCleanSecurity :
				var n = Math.min( 3, Math.max(0, count(Terminal)-3) );
				n = rseed.random(2)+1;
				var sDevice = [Camera,Keypad];
				var list = new Array();
				n = Math.min(count(Terminal),n);
				for(i in 0...Std.int(n))
					list.push( transform(Terminal, sDevice[rseed.random(sDevice.length)])[0]  );
				for (cn in list)
					cn.fl_target = true;
				node.type = sDevice[rseed.random(sDevice.length)];
			case _MCamRec(file) :
				var n = Math.min( count(Terminal), rseed.random(3)+1 );
				var list = new Array();
				if ( n>0 )
					list = transform(Std.int(n), Terminal, Camera);
				node.type = Camera;
				list.push(node);
				for (n in list)
					n.fl_target = false;
				list[rseed.random(list.length)].fl_target = true;
			case _MCleanCriminal(name) :
				node.type = CrimeDatabase;
			case _MSpy(name) :
				node.type = Terminal;
				node.users[0] = name;
			case _MCompromiseMail(owner) :
				node.type = Terminal;
				node.users[0] = owner;
			case _MFalsifyCam(sector) :
				node.type = Camera;
			case _MSpyCam :
				var n = Math.min(count(Terminal), rseed.random(2)+1);
				for(i in 0...Std.int(n)) {
					var list = transform(Terminal, Camera);
					for (tm in list)
						tm.fl_target = true;
				}
				node.type = Camera;
			case _MArrest(name) :
				node.type = CrimeDatabase;
			case _MCorruptDisplay(place) :
				node.type = BigDisplay;
			case _MDeliverFile(pk,pname,file,to) :
				node.type = Terminal;
				node.users[0] = to;
			case _MOverwriteFiles(owner,ext) :
				node.type = Terminal;
				node.users[0] = owner;
				for (n in getNodes(Printer))
					n.fl_target = true;
			case _MGameHack(g,s,c) :
				for (n in getNodes(Terminal))
					n.type = GameServer;
				node.type = GameServer;
			case _MInfectNet(v) :
				for (n in getNodes(Terminal))
					n.fl_target = true;
				node.type = Terminal;
				node.users[0] = TD.names.get("username");
			case _MGetVirus(v,ext,n) :
				node.type = Terminal;
				node.users[0] = TD.names.get("username");
				// on choisi un Terminal au hasard
				node.fl_target = false;
				var newTarget = getOne(Terminal);
				newTarget.fl_target = true;
			case _MTutorial :
				node.type = TutoTerm;
				node.fl_target = true;
			case _MTutorialDelete(ext,total) :
				for(n in getNodes(Terminal))
					n.fl_target = true;
				node.type = Terminal;
				node.users[0] = TD.names.get("username");
			case _MTutorialBypass(f) :
				var fw = getOne(Gateway);
				fw.type = TutoFirewall;
				node.type = TutoTerm;
				node.fl_target = true;
			case _MTV(tf,tt) :
				node.type = Tv;
				var list = Lambda.array(getNodes(Terminal));
				var max = Std.int( Math.min(3,list.length) );
				while (max>0) {
					list.splice(rseed.random(list.length),1)[0].type = Tv;
					max--;
				}
			case _MTVTheft(tv,p) :
				node.type = Tv;
				var list = Lambda.array(getNodes(Terminal));
				var max = Std.int( Math.min(3,list.length) );
				while (max>0) {
					list.splice(rseed.random(list.length),1)[0].type = Tv;
					max--;
				}
			case _MTVCrash(tv) :
				node.type = Tv;
				var list = Lambda.array(getNodes(Terminal));
				var max = Std.int( Math.min(3,list.length) );
				while (max>0) {
					list.splice(rseed.random(list.length),1)[0].type = Tv;
					max--;
				}
//				var list = Lambda.array( Lambda.filter( getNodes(Tv), function(n:NetNode) {
//					return !n.fl_target;
//				}) );
//				list[ rseed.random(list.length) ].fl_target = true;
		}
	}

	function updateMissionSystems() {
		// affecte le contenu de la node objectif
		initRand();
		var mnodes = getTargetNodes();
		var fn = mnodes[0];
		switch(term.mdata._type) {
			case _MModerate(owner)			:
				var parent = fn.system.getOneFolder("/user");
				parent.name = owner;
				if ( rseed.random(100)<50 )
					fn.system.forceFolder(parent,"/junk");
				else
					fn.system.forceFolder(parent,"/music");
				fn.system.forceFiles(parent,"file.video",rseed.random(2));
				fn.system.forceFiles(parent,"file.music",rseed.random(6)+1);
			case _MDelete(owner,fname)	:
				var f = fn.system.replaceFile(fname);
				f.addEffect(E_Encoded,rseed.random(4)+6);
			case _MDeleteAll(owner,fname) :
			case _MCopy(owner,fname)		:
				var p = getOne(Printer);
				if ( p!=null && rseed.random(100)<40 && term.gameLevel>=5 ) {
					// fichier dans l'historique d'une imprimante
					fn.fl_target = false;
					p.fl_target = true;
					var f = p.system.replaceFile(fname,owner);
//					f.addEffect(E_Encoded,rseed.random(4)+6);
				}
				else {
					var f = fn.system.replaceFile(fname);
//					f.addEffect(E_Encoded,rseed.random(4)+6);
				}
			case _MSteal(owner,fname) :
				fn.system.replaceFile(fname);
			case _MCrashTerminal(str) :
			case _MCrashPrinter(str) :
				fn.system.forceRootName(str);
			case _MCrashDB(str) :
				fn.system.forceRootName(str);
			case _MCleanTerminal(owner) :
				fn.system.forceRootName(owner);
			case _MCopyMail(owner,sender) :
				var list = fn.system.getFilesByExt("mail");
				var mail = list[rseed.random(list.length)];
				mail.fl_target = true;
				mail.forceMail( sender, TD.texts.get("dangerousMail") );
			case _MFindMails(owner,n) :
				var list = fn.system.getFilesByExt("mail");
				if ( list.length<n )
					Manager.fatal("not enough file for mission _MFindMails");
				for (i in 0...n) {
					var mail = list.splice( rseed.random(list.length),1 )[0];
					mail.forceMail( TD.texts.get("unknownSender"), TD.texts.get("dangerousMail") );
					mail.fl_target = true;
				}
			case _MPasswords(str) :
				fn.system.forceRootName(str);
				for(f in fn.system.getFilesByKey("global.pass"))
					f.fl_target = true;
			case _MCleanSecurity :
			case _MCamRec(file) :
				fn.system.replaceFileByKey("archive.video",file,true);
			case _MCleanCriminal(name) :
				var list = fn.system.getFilesByKey("crime.data");
				var f = list[rseed.random(list.length)];
				f.name = name+".data";
				TD.texts.set( "owner", name );
				f.content = TD.texts.get("crimeLog");
				f.fl_target = true;
			case _MSpy(name) :
			case _MCompromiseMail(owner) :
			case _MFalsifyCam(sector) :
				fn.system.forceRootName(TD.fsNames.get("camName") +" "+ sector);
				for (f in fn.system.getFilesByKey("archive.video"))
					f.fl_target = true;
			case _MSpyCam :
			case _MArrest(name) :
			case _MCorruptDisplay(place) :
			case _MDeliverFile(pk,pname,file,to) :
				var dir = fn.system.getOneFolder(pk);
				dir.name = pname;
			case _MOverwriteFiles(owner,ext) :
				for (n in mnodes)
					for (f in n.system.getFilesByExt(ext))
						f.fl_target = true;
			case _MGameHack(g,s,c) :
				fn.system.forceRootName(s);
				var dir = fn.system.getOneFolder("/char");
				dir.name = c;
				for (f in fn.system.getFolderFiles(dir))
					if (!f.fl_deleted && f.hasKeyExt("game"))
						f.fl_target = true;
			case _MInfectNet(v) :
				for (n in mnodes)
					for (f in n.system.getFilesByKey("file.control"))
						f.fl_target = true;
			case _MGetVirus(v,ext,total) :
				for (n in mnodes) {
					var list = n.system.getFilesByExt(ext);
					for (f in list) {
						f.fl_target = true;
						f.addEffect(E_Target);
					}
					if ( list.length < total )
						term.missionCpt = total-list.length;
				}
			case _MTutorial :
			case _MTutorialDelete(ext,cpt) :
				for (f in fn.system.getFilesByExt(ext))
					f.fl_target = true;
			case _MTutorialBypass(name) :
				var f = fn.system.getOneFile("file.doc");
				f.name = name;
				f.fl_target = true;
			case _MTV(tf,tt) :
				fn.system.forceRootName(tt);
				var list = Lambda.array( Lambda.filter( getNodes(Tv), function(n:NetNode) {
					return !n.fl_target;
				}) );
				var source = list.splice(rseed.random(list.length),1)[0];
				source.system.forceRootName(tf);
				for (f in source.system.getFilesByKey("tvprog.data")) {
					f.name = TD.names.get("hotProg");
					f.setOwner("mission");
				}
			case _MTVTheft(tv,program) :
				for (ntv in getNodes(Tv))
					ntv.system.name = tv+" "+TD.texts.get("roman")+"-"+(rseed.random(9)+1);
				var f = fn.system.getOneFile("tvprog.data");
				f.name = program;
				f.fl_target = true;
				f.addEffect(E_Encoded,rseed.random(4));
			case _MTVCrash(tv) :
				fn.system.forceRootName(tv);
//				var list = source.system.getFilesByKey("tvprog.data");
//				var f = list[rseed.random(list.length)];
//				f.name = pf;
//				f.owner = "mission";
//				f.fl_target = true;
		}
	}


	// *** OUTILS

	public function getNeighbours(node:NetNode) {
		if ( node.type==Empty )
			return new List();
		var list = new List();
		for (n in nodes)
			if ( n.type!=Empty && n!=node && isInPath(node,n.path) )
				list.add(n);
		return list;
	}

	public function getByDist(d:Int, ?type:NodeType) {
		var list = new List();
		for (n in nodes)
			if ( n.dist==d )
				if ( type==null || type!=null && type==n.type )
					list.add(n);
		return list;
	}


	public function getNodes(?type:NodeType) {
		var list = new List();
		for (col in map)
			for (node in col)
				if ( node!=null && (node.type==type || type==null) )
					list.push(node);
		return list;
	}

	public function getTargetNodes(?type:NodeType) {
		var list = new Array();
		for (node in nodes)
			if ( node.fl_target && (node.type==type || type==null) )
				list.push(node);
		if ( list.length==0 ) throw "no target found !";
		return list;
	}

	public function getNodeByIp(ip:String) {
		ip = ip.toLowerCase();
		for (node in nodes)
			if ( node.ip.toLowerCase()==ip ) return node;
		return null;
	}

	public function getNodeBySys(fs:GFileSystem) {
		if ( fs==null )
			return null;
		for (node in nodes)
			if ( node.system==fs )
				return node;
		return null;
	}


	function getOne(type:NodeType) {
		var list = Lambda.array( getNodes(type) );
		return list[rseed.random(list.length)];
	}

	function count(type:NodeType) {
		var n = 0;
		for (node in nodes)
			if ( node.type==type ) n++;
		return n;
	}

	public function isNeighbour(node1:NetNode,node2:NetNode, ?mark:IntHash<Bool>) {
		if ( mark==null ) mark = new IntHash();
		mark.set(node1.id,true);
		var result = false;
		for (link in node1.links)
			if ( !mark.exists(link.node.id) )
				if ( link.node==node2 )
					return true;
				else if ( link.node.type==Empty )
					result = result || isNeighbour(link.node,node2,mark);
		return result;
	}


	public function getLinked(node:NetNode,t:NodeType, ?mark:IntHash<Bool>) : NetNode {
		if ( mark==null )
			mark = new IntHash();
		mark.set(node.id,true);
//		if ( node.type==t ) return true;
//		if ( node.type!=Empty ) return false;
		for (link in node.links)
			if ( !mark.exists(link.node.id) )
				if ( link.node.type==Empty ) {
					var r = getLinked(link.node,t,mark);
					if ( r!=null )
						return r;
				}
				else
					if ( link.node.type==t && isUp(link.node) )
						return link.node;
		return null;
	}


	public function isLinkedTo(node:NetNode,t:NodeType) {
		return getLinked(node,t)!=null;
	}


	function isInPath(node:NetNode, path:Array<NetNode>) {
		for (n in path)
			if (node==n)
				return true;
		return false;
	}


	function canGoThrough(node:NetNode) {
		return node.type==Entrance || node.type==Empty || !isUp(node);
	}


	public function canReach(node:NetNode) {
		var start = null;
		for (p in node.path)
			if ( node!=p && !canGoThrough(p) )
				return false;
		return true;
	}


	function getMaxNode(t:NodeType) {
		var max : NetNode = null;
		for (n in nodes)
			if ( n.type==t && (max==null || n.dist>max.dist) ) max = n;
		return max;
	}

	function getHardNode(t:NodeType, dmin:Int) : NetNode {
		if ( dmin<=0 )
			return null;
		var pool = new Array();
		for (n in nodes)
			if ( n.type==t && n.dist>=dmin )
				pool.push(n);
		if ( pool.length==0 )
			return getHardNode(t,dmin-1);
		return pool[ rseed.random(pool.length) ];
	}


	function startConnect(node:NetNode) {
		if ( Tutorial.at(Tutorial.get.third, "showTargetTerm2") && node.type!=TutoTerm ) {
			term.popUp(Lang.get.NotNow);
			return;
		}
		if ( Tutorial.play(Tutorial.get.third, "unreachable") )
			return;

		term.vman.exec(data.VirusXml.get.connec, node);
	}


	public function connect(node:NetNode) {
		if ( !node.system.canConnect() )
			return;
		term.disconnectFS();
		curNode = node;
		refresh();

		if ( node.system.fl_crashed ) {
			term.popUp(Lang.get.SystemIsCrashed);
			return;
		}

		var fl_slower = isLinkedTo(node,Slower);
		var speed = if(fl_slower) 0.4 else 1;
		if ( speed<1 )
			term.popUp(Lang.get.SystemSlowedDown);
		else
			term.dock.unlock();
		term.dock.hideSwitcher();
		term.fs = node.system;
//		term.fs.speed = speed;
//		term.avman.scan(term.fs);
		term.fs.connect(speed);
		lock();
//		term.spamLog._visible = true;
		term.log( Lang.fmt.Log_ConnectedNode({_name:term.fs.curFolder.name.toUpperCase()}) );
	}


	public function lock() {
		fl_lock = true;
		setVisibility(false);
	}

	public function unlock() {
		fl_lock = false;
		setVisibility(true);
	}

	function setVisibility(fl:Bool) {
		for (node in nodes) {
			if (node.type==Empty)
				continue;
			node.mc._visible = fl;
			for (ln in node.links)
				ln.mc._visible = fl;
		}
		for(mc in dotLines)
			mc._visible = fl;

		for(gs in gspamList)
			gs.mc._visible = fl;
		groundField._visible = fl;
	}

	function isUp(node:NetNode) {
		var s = node.system;
		return s==null || !s.fl_crashed && !s.fl_auth;
	}

	function tutorialPoint(tuto:Tut, step:String, nt:NodeType) {
		if ( Tutorial.at(tuto,step) ) {
			var node = getOne(nt);
			Tutorial.point(sdm, node.mc._x, node.mc._y-50);
		}
	}


	// *** AFFICHAGE

	public function bleep(node:NetNode) {
		if ( fl_lock )
			return;
		var mc = sdm.attach("mapBleep",Data.DP_TOPTOP);
		mc._x = node.mc._x;
		mc._y = node.mc._y-24;
		mc.onEnterFrame = function() {
			if (mc._currentframe==mc._totalframes-1 )
				mc.removeMovieClip();
		}
	}

	public function updateVisibility(?fl_anim=true) {
		for (n in nodes) {
			// links
			for (l in n.links)
				if (canReach(n) && canReach(l.node)) {
					if ( l.mc._currentframe!=1 && fl_anim )
						term.startAnim( A_FadeIn, l.mc ).spd*=0.5;
					l.mc.gotoAndStop(1);
				}
			// node
			if( n.type!=Empty && !n.fl_visible && (n.dist<=1 || canReach(n)) ) {
				var me = this;
				if ( fl_anim ) {
					var a2 = me.term.startAnim(A_FadeOut,n.mc,-Std.random(100)/100);
					a2.cb = function() {
						n.fl_visible = true;
						me.term.startAnim(A_FadeIn,n.mc).spd*=0.5;
						var a3 = me.term.startAnim(A_Move, n.mc);
						a3.spd*=0.5;
						a3.y-= Std.random(30)+10;
						me.refresh();
						Col.setPercentColor( n.mc, 0,0 );
						n.mc._alpha = 0;
					}
				}
				else {
					n.fl_visible = true;
					Col.setPercentColor( n.mc, 0,0 );
				}
			}
		}
	}

	function drawSubPath(from:NetNode,to:NetNode) {
		var line = sdm.attach("link",Data.DP_BG_ITEM);
		line.gotoAndStop(2);
		line._x = from.mc._x + (to.mc._x - from.mc._x)*0.5;
		line._y = from.mc._y + (to.mc._y - from.mc._y)*0.5;
		if ( to.mc._x>from.mc._x && to.mc._y>from.mc._y )
			line._xscale*=-1;
		if ( to.mc._x<from.mc._x && to.mc._y<from.mc._y )
			line._xscale*=-1;
		if (!canReach(to)) {
			to.mc.filters = [ new flash.filters.GlowFilter( Data.RED, 1, 8,8, 2, 1) ];
			Col.setPercentColor(line, 75, Data.RED);
		}
		dotLines.push(line);
	}

	function detachPath() {
		for (mc in dotLines) mc.removeMovieClip();
		dotLines = new Array();
	}

	public function drawPath(node:NetNode) {
		var i = 0;
		while (i<node.path.length-1) {
			drawSubPath( node.path[i], node.path[i+1] );
			i++;
		}
	}

	public function attach() {
		if ( !fl_generated ) return;
//		bg2 = sdm.attach("bgNet",Data.DP_BG);
//		bg2._xscale = 75;
//		bg2._yscale = bg2._xscale;
//		bg2.cacheAsBitmap = true;
//		bg2.blendMode = "overlay";
//		bg2._alpha = 30;

		var bmpCont = sdm.empty(Data.DP_BG);
		bmpCont._x = -300;
		bmpCont.blendMode = "overlay";
		var flat  = sdm.empty(Data.DP_BG);
		var flatDm = new mt.DepthManager(flat);
		var bg = flatDm.attach("bgNet",0);
		bg._x = -15-bmpCont._x;
		bg._y = 140;
		var lmc = sdm.empty(Data.DP_BG);
		ldm = new mt.DepthManager(lmc); // links

		groundField = cast sdm.attach("groundField", Data.DP_TOP);
		var x = getFreeLine()+0.5;
		var y = wid*0.4;
		groundField._alpha = 70;
		groundField.field.text = TD.texts.get("corpWelcome");
		if ( term.fl_lowq )
			groundField.field.filters = [];
		groundField._x = -350 + x*HEXWID*0.5 + y*HEXWID*0.5;
		groundField._y = 350 + -x*HEXHEI*0.5 + y*HEXHEI*0.5;
		term.startAnim(A_Text, groundField, groundField.field.text, -2).spd*= if(term.fl_lowq) 2 else 0.5;

		var mcList : Array<{d:Int,mc:flash.MovieClip}> = new Array();
		var ambSpots : Array<{x:Float,y:Float}> = new Array();
		for (y in 0...wid)
			for (x in 0...wid) {
				var node = map[x][y];
				if ( node==null ) {
					ambSpots.push({
						x : -350 + x*HEXWID*0.5 + y*HEXWID*0.5,
						y : 350 + -x*HEXHEI*0.5 + y*HEXHEI*0.5,
					});
					continue;
				}
				var mcNode : MCNode = cast sdm.attach("node",Data.DP_ITEM);
				mcNode._x = -350 + x*HEXWID*0.5 + y*HEXWID*0.5;
				mcNode._y = 350 + -x*HEXHEI*0.5 + y*HEXHEI*0.5;
				mcNode.base._visible = false;
				mcNode.sicon._visible = false;
				mcNode.sicon.stop();
				Col.setPercentColor( mcNode, 75, term.mdata._color );
//				var hexWid = 32;
//				var hexHei = 32;
//				mcNode._x = x*48 + 50;
//				mcNode._y = y*48 + 50;
				if ( node==null ) {
					mcNode.gotoAndStop(1);
					mcNode._alpha = 20;
					mcNode.field._visible = false;
				}
				else {
					mcNode.gotoAndStop( Type.enumIndex(node.type)+1 );
//					Col.setPercentColor( mcNode, 50, DIST_COLORS[node.dist] );
					mcNode.field.text = node.ip;
					mcNode.field._visible = false;
					var links = node.links;
					if ( node.type==Empty )
						mcNode._visible = false;
					else {
						mcNode.onRelease = callback(onReleaseNode, node);
						mcNode.onReleaseOutside = callback(onReleaseNode, node);
					}
					for (link in links) {
						var mc = ldm.attach("link",Data.DP_BG_ITEM);
						mc.gotoAndStop(1);
						mc._x = mcNode._x;
						mc._y = mcNode._y;
						var lx = link.node.x;
						var ly = link.node.y;
						if ( ly!=y )
							mc._xscale*=-1;
						var f = 0.25;
						if ( lx<x ) {
							mc._x -= HEXWID*f;
							mc._y += HEXHEI*f;
						}
						if ( lx>x ) {
							mc._x += HEXWID*f;
							mc._y -= HEXHEI*f;
							mc._visible = false;
						}
						if ( ly<y ) {
							mc._x -= HEXWID*f;
							mc._y -= HEXHEI*f;
//							mc._visible = false;
						}
						if ( ly>y ) {
							mc._x += HEXWID*f;
							mc._y += HEXHEI*f;
							mc._visible = false;
						}
//						if ( link.y!=y )	mc._rotation = 90;
//						if ( link.x<x )		mc._x -= 32;
//						if ( link.x>x )		mc._x += 32;
//						if ( link.y<y )		mc._y -= 32;
//						if ( link.y>y )		mc._y += 32;
						mc.gotoAndStop(3);
						link.mc = mc;
						mcList.push({d:node.path.length, mc:mc});
					}
				}
				mcNode.cacheAsBitmap = true;
				node.mc = mcNode;
				if ( node.fl_target && term.gameLevel==4 ) {
					var amc = sdm.attach("arrow",Data.DP_ITEM);
					amc._x = node.mc._x;
					amc._y = node.mc._y-45;
				}
				if ( node!=null && node.type!=Empty )
					if ( node.type==Entrance ) {
						term.startAnim(A_Blink,node.mc,-1).spd*=0.5;
						scrollTo(node.mc._x+scroller._x,node.mc._y+scroller._y);
					}
					else {
						mcList.push({d:node.path.length, mc:cast node.mc});
					}
			}

//		if ( rseed.random(2)==0 ) {
//			// damier de base
//			var zBase = uniq++;
//			for (x in 0...wid)
//				for (y in 0...wid) {
//					var hx = -350 + x*HEXWID*0.5 + y*HEXWID*0.5;
//					var hy = 350 + -x*HEXHEI*0.5 + y*HEXHEI*0.5;
//					var mc : MCNode = cast flatDm.attach("bgGround",1);
//					mc._x = hx-bmpCont._x;
//					mc._y = hy;
//					mc._y-=rseed.random(10);
//					mc.gotoAndStop(38);
//					mc.sicon._visible = false;
//					mc.shield._visible = false;
//				}
//			flatDm.ysort(1);
//		}
//		else {
			// décors d'ambiance
			var cx = -350 + (wid*0.5)*HEXWID*0.5 + (wid*0.5)*HEXWID*0.5;
			var cy = 350 + -(wid*0.5)*HEXHEI*0.5 + (wid*0.5)*HEXHEI*0.5;
			for (i in 0...rseed.random(40)+10) {
				var idx = rseed.random(ambSpots.length);
				var c = ambSpots[idx];
				ambSpots.splice(idx,1);
				var mc : MCNode = cast flatDm.attach("node",2);
				mc._x = c.x-bmpCont._x;
				mc._y = c.y;
				mc.gotoAndStop( 30 + rseed.random(mc._totalframes-30+1) );
				mc.sicon._visible = false;
				mc.shield._visible = false;
				var dist = Math.sqrt( Math.pow(c.x-cx,2) + Math.pow(c.y-cy,2) );
				mc._alpha = Std.int( 5+Math.min(1, dist/600 )*60 );
			}
//		}

		var bmp = new BitmapData( 1300, 800, true, 0x0);
		bmp.draw(flat);
		flat.removeMovieClip();
		bmpCont.attachBitmap(bmp,1);

		lmc.filters = [
			new flash.filters.DropShadowFilter(2,90, 0x333333, 1, 0,0),
			new flash.filters.DropShadowFilter(1,90, 0x111111, 1, 0,0),
//			new flash.filters.GlowFilter(0x0,1, 3,3, 2),
//			new flash.filters.GlowFilter(0xffffff,0.1, 3,3, 100),
			new flash.filters.DropShadowFilter(15,90, 0x0, 0.25, 0,0),
		];
		updateVisibility(false);
		var base = if(mcList.length>40) 100 else 20;
		refresh();
		for (e in mcList)
			term.startAnim(A_BlurIn, e.mc, -(Std.random(Std.int(base*0.5))+e.d*base)/100);
//			term.startAnim(A_FadeIn, e.mc, -(Std.random(rand)+base)/100).spd*=10;
		term.bg.onRelease = onMouseDown;
	}

	public function isShielded(node:NetNode) {
		if ( node==null || !isUp(node) || node.type==Entrance || node.type==LockServer || node.type==LockServerLight )
			return false;
		var lock = getLinked(node,LockServer);
		var lockLight = getLinked(node,LockServerLight);
		return lock!=null && lock.dist==node.dist || lockLight!=null && lockLight.dist==node.dist && lockLight.sibling==node;
	}

	public function getLinkedAlarm(node:NetNode) {
		if ( node==null || !isUp(node) )
			return null;
		return getLinked(node,Alarm);
	}


	function getNodeDescription(node:NetNode, fl_shield:Bool) {
		var base = switch(node.type) {
			case LockServer			: Lang.get.NDescLock;
			case LockServerLight	: Lang.get.NDescLockLight;
			case Alarm				: Lang.get.NDescAlarm;
			default : "";
		}
		if ( node.system.fl_crashed || node.system.fl_auth )
			base = "";

		var extra =
			if ( node.system.fl_crashed ) Lang.get.NodeCrashed;
			else if ( node.system.fl_auth ) Lang.get.NodeAuth;
			else if ( fl_shield ) Lang.get.NodeShielded;
			else "";
		#if debug
			extra+="\n"+node.x+","+node.y+" ("+node.dist+") ip="+node.ip;
		#end
		return
			if(base=="")
				extra
			else if( extra=="" )
				base
			else
				base+"\n"+extra;
	}


	public function refresh() {
		for (node in nodes) {
			if ( node.type==Empty )
				continue;
			var fl_shield = isShielded(node);
			node.mc.shield._visible = fl_shield;
//			node.mc.gotoAndStop( if(node.fl_visible) Type.enumIndex(node.type)+2 else 2 );
			node.mc.gotoAndStop( Type.enumIndex(node.type)+2 );
//			if ( node.fl_visible )
//				Col.setPercentColor( node.mc, 0, 0 );
//			else
//				Col.setPercentColor( node.mc, 75, term.color );

			if ( node.fl_visible )
				if ( node.type==Entrance )
					term.bubble(node.mc, Lang.get.EntranceName);
				else
					term.bubble(node.mc, node.system.name, getNodeDescription(node,fl_shield));
			else
				term.bubble(node.mc, Lang.get.HiddenNode);
			node.mc.filters = null;
			#if debug
				if ( node.fl_target )
					node.mc.filters = [ new flash.filters.GlowFilter(0xffff00, 1, 6,6, 2) ];
			#end
			if ( node.system.canConnect() && (node.system.fl_crashed || node.system.fl_auth) ) {
				node.mc.sicon._visible = true;
				if ( node.system.fl_auth )
					node.mc.sicon.gotoAndStop("smile");
				if ( node.system.fl_crashed ) {
					node.mc.sicon.gotoAndStop("corrupt");
					Col.setPercentColor( node.mc, 30, 0xaa2244 );
				}
//				node.mc.base._visible = true;
			}
		}
		detachPath();
		if ( curNode!=null )
			drawPath(curNode);
	}


	public function update() {
		if ( !fl_generated ) {
			updateGenerate();
			return;
		}

		if ( fl_lock )
			return;


		// Scrolling sur border
//		var xm = Manager.ROOT._xmouse;
//		var ym = Manager.ROOT._ymouse;
//		if ( ym>=Data.HEI-SMARGIN )
//			sty-=Std.int( 10* (ym-(Data.HEI-SMARGIN))/SMARGIN );
//		if ( ym<=SMARGIN )
//			sty+=Std.int( 10* (SMARGIN-ym)/SMARGIN );

		// scrolling offset souris
//		var mstx = (Manager.ROOT._xmouse - Data.WID*0.5)*0.15;
//		var msty = (Manager.ROOT._ymouse - Data.HEI*0.5)*0.15;

		if ( tmc._name!=null ) {
			var spd = 4;
			tmc.c1._rotation+=spd;
			tmc.c2._rotation+=-spd*1.3;
			tmc.c3._rotation+=spd*0.5;
			if ( tmc._xscale!=90 ) {
				tmc._xscale += (90-tmc._xscale)*0.4;
				tmc._yscale = tmc._xscale*0.5;
			}
		}


		// random fx
		if ( !term.fl_lowq && term.countFx()<=10 && Std.random(100)<15 ) {
//			if ( Std.random(100)<50 )
				// electric
				term.addFx(sdm, Data.DP_BG, AFX_PlayFrames, "fx_glight", Std.random(1000), Std.random(1000)).mc._alpha = Std.random(30)+10;
//				term.addSpark(sdm);
//			else {
//				// binary
//				var fx = term.addFx(sdm, Data.DP_BG, AFX_Binary, "fx_binary", Std.random(1000), Std.random(1000));
//				Col.setPercentColor(fx.mc, 50, term.color);
//			}
		}

		// ground spam (celui qui ne scroll pas)
		if ( !MissionGen.isTutorial(term.mdata) ) {
			if ( !term.hasAnim(groundField) ) {
				if ( groundField.field.text.length==0 ) {
					var a = term.startAnim(A_Text, groundField, TD.texts.get("shortCorpoSpam"));
					a.spd *= if (term.fl_lowq) 3 else 1.5;
				}
				else
					if ( spamCpt<=0 ) {
						spamCpt = Std.random(Std.int(Data.SECONDS(5))) + Data.SECONDS(5);
						term.startAnim(A_EraseText, groundField).spd*=1.5;
					}
				spamCpt-=mt.Timer.tmod*mt.Timer.tmod;
			}

			// scrolling spam (creation)
			var max = if(term.fl_lowq) 1 else MAX_SCROLLING_SPAMS;
			if ( gspamList.length<max && Std.random(100)<3 ) {
				var cont = sdm.empty(Data.DP_BG);
				cont._alpha = 25;
				cont._x = 850;
				var mc : MCField = cast cont.attachMovie("groundFieldV", "uniq_"+uniq,uniq++);
				if ( fl_spamDir ) {
					mc.gotoAndStop(2);
					cont._y = -500 + Std.random(600);
				}
				else {
					mc.gotoAndStop(1);
					cont._y = 250 + Std.random(500);
				}
				var str = "";
				do {
					str = TD.texts.get("corpoSpam");
				} while(str.length>70);
				mc.field.text = str;
				mc.field._width = mc.field.textWidth+5;
				mc.field.filters = [ new flash.filters.GlowFilter(0xffffff,0.7, 10,10, 1) ];
				if ( fl_spamDir )
					mc.field._y = mc.field._height-45;
				var mcc : {>MCField, shadow:flash.TextField} = cast mc;
				mcc.shadow.text = mc.field.text;
				mcc.shadow._width = mcc.shadow.textWidth+5;
				mcc.shadow._y = mc.field._y+22;
				mcc.shadow.filters = [ new flash.filters.BlurFilter(4,4) ];
				var delta = Std.random(30)+10;
				mcc.shadow._x-=delta*0.2;
				mcc.shadow._y+=delta;
				var bmp = new BitmapData(Std.int(cont._width+20),Std.int(cont._height+40),true,0xff0000);
				bmp.draw(cont);
				mc.removeMovieClip();
				cont.attachBitmap(bmp,1);
				var spd = Std.random(20)/10+1;
				gspamList.push({
					mc	: cont,
					dx	: spd,
					dy	: if(fl_spamDir) -spd*0.5 else spd*0.5,
					bmp	: bmp,
				});
				fl_spamDir = !fl_spamDir;
			}

			// scrolling spam (anim)
			for (gs in gspamList) {
				var mc = gs.mc;
				mc._x-=mt.Timer.tmod*gs.dx;
				mc._y-=mt.Timer.tmod*gs.dy;
				if ( mc._x+mc._width*2<0 || mc._y+mc._height<0 || mc._y>700 ) {
					gs.bmp.dispose();
					gspamList.remove(gs);
					mc.removeMovieClip();
				}
			}
		}


		if ( sx!=stx || sy!=sty ) {
			// X
			var delta = Math.round(stx-sx);
			if ( delta>0 && delta<1 )	delta=1;
			if ( delta>-1 && delta<0 )	delta=-1;
			sx = sx + delta*scrollSpeed;
			if ( Math.abs(stx-sx)<1 )
				sx = stx;
			// Y
			var delta = Math.round(sty-sy);
			if ( delta>0 && delta<1 )	delta=1;
			if ( delta>-1 && delta<0 )	delta=-1;
			sy = sy + (sty-sy)*scrollSpeed;
			if ( Math.abs(sty-sy)<1 )
				sy = sty;
		}
		sx = Math.max(-260, Math.min(260,sx));
		sy = Math.max(-260, Math.min(0,sy));
//		scroller._x = Math.round( sx-mstx );
//		scroller._y = Math.round( sy-msty );
		scroller._x = Math.round(sx);
		scroller._y = Math.round(sy);
//		bg2._x = -0.3*scroller._x + 50;
//		bg2._y = -0.3*scroller._y + 250;

		tutorialPoint( Tutorial.get.first, "connect", TutoTerm );
		tutorialPoint( Tutorial.get.first, "entrance", Entrance );
		tutorialPoint( Tutorial.get.first, "crashed", Entrance );

		tutorialPoint( Tutorial.get.second, "waitConnect", Terminal );
		tutorialPoint( Tutorial.get.second, "nowExit", Entrance );

		tutorialPoint( Tutorial.get.third, "showTargetTerm", TutoTerm );
		tutorialPoint( Tutorial.get.third, "showFirewall", TutoFirewall );
		tutorialPoint( Tutorial.get.third, "showTargetTerm2", TutoTerm );
		tutorialPoint( Tutorial.get.third, "needBypass", TutoFirewall );
		tutorialPoint( Tutorial.get.third, "connectFirewall", TutoFirewall );
		tutorialPoint( Tutorial.get.third, "copyFile", TutoTerm );
		tutorialPoint( Tutorial.get.third, "copied", Entrance );
	}
}

