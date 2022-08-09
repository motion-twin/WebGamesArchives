import mt.Timer;
import Types;
import Progress;
import GNetwork;
import data.PatternXml;
import data.AntivirusXml;
import mt.bumdum.Lib;

class GFileSystem {
	static var SCROLL_SPEED = 0.2;
	static var FWID			= 152;
	static var FHEI			= 81;
	static var MIN_DANGER_FOR_MUSIC = 15;

	var uniq				: Int;

	var term				: UserTerminal;
	var ml					: Dynamic;
	var fl_lock				: Bool;
	var seed				: Int;
	var rseed				: mt.Rand;
	public var rawTree		: Array<FSNode>;
	var tree				: IntHash<Array<FSNode>>;
	public var patternName	: String;
	var nodeType			: NodeType;
	var users				: Array<String>;
	public var owner		: String;
	public var name			: String;
	public var mpass		: String;
	public var curFolder	: FSNode;
	public var target		: FSNode;
	var baseDiff			: Int;

	var index				: Hash<List<FSNode>>;

	public var matrix		: Array<Array<Bool>>;
	public var mwid			: Int; // matrix width

	var scroller			: flash.MovieClip;
	public var sdm			: mt.DepthManager;
//	var mc_cmd				: MCField;
	var fmcList				: Array<MCField>;
	var exitIcon			: MCField;
	var bg					: flash.MovieClip;
	var title				: MCField;
	var sub					: MCField;
	var wallL				: flash.MovieClip;
	var wallR				: flash.MovieClip;
	var wpaper				: flash.MovieClip;
	var tmc					: TargetMC;
	var scrollPrev			: flash.MovieClip;
	var scrollNext			: flash.MovieClip;

	var zoom				: Float;
	var stimer				: Float;
	var stx					: Int;
	var sty					: Int;
	var sy					: Int;
	var smin				: Int;
	var smax				: Int;

	public var speed		: Float;
	public var fl_crashed	: Bool;
	public var fl_auth		: Bool;
	public var fl_authRecent: Bool;
	public var fl_fresh		: Bool; // jamais connecté

	var localSounds			: List<String>;




	public function new(t:UserTerminal,nt:NodeType, d:Int) {
		baseDiff = d;
		term = t;
		rawTree = new Array();
		tree = new IntHash();
		fmcList = new Array();
		users = new Array();
		uniq = 0;
		speed = 1;
		zoom = 1;
		stimer = 0;
		localSounds = new List();
		sy = 0;
		fl_fresh = true;
		fl_lock = false;
		fl_crashed = false;
		fl_auth = false;
		fl_authRecent = false;
		nodeType = nt;

		matrix = new Array();
		for (x in 0...Data.MATRIX_WID)
			matrix[x] = new Array();
	}
	
	public function toString() {
		return name+" seed="+seed+" crash="+fl_crashed+" corrupt="+fl_auth;
	}

	public function canConnect() {
		return patternName!=null && patternName!="";
	}

	public function setSeed(s:Int) {
		seed = s;
	}


	public function setUsers(list) {
		users = list;
		owner = users[0];
	}


	public function lock() {
		fl_lock = true;
	}

	public function unlock() {
		fl_lock = false;
	}

	public function debug() {
		return name+" ("+patternName+")";
	}

	// *** SONS

	function startLocalLoop(id) {
		term.startLoop(id);
		localSounds.add(id);
	}

	function stopLocalLoops() {
		for (id in localSounds)
			term.stopLoop(id);
		localSounds = new List();
	}

	function getRythmes() {
		var list = new List();
		for (id in localSounds) {
			var s = term.findSound(id);
			if ( s!=null && s.channel==2 )
				list.add(s);
		}
		return list;
	}

	function stopRythmes() {
		for (id in localSounds) {
			var s = term.findSound(id);
			if ( s!=null && s.channel==2 ) {
				term.stopLoop(s.id);
				localSounds.remove(id);
			}
		}
	}


	// *** GÉNÉRATION

	function getSubClass(rseed:mt.Rand, max:Int) {
		var minLevel = 4;
		if ( term.gameLevel<=minLevel )
			return 1;
		// gl 4    / 5
		max = Std.int( Math.min(term.gameLevel-minLevel+1, max) );
		return rseed.random(max)+1;
	}

	public function generate(s:Int) {
		if ( uniq>0 ) throw "generate should be called once !";
		seed = s;

		// schéma de génération
		initRand();
		patternName = switch(nodeType) {
			case Terminal		: "/sys_terminal_"+getSubClass(rseed,5);
			case TerminalMul	: "/sys_multi_users";
			case Printer		: "/sys_printer";
			case Gateway		: "/sys_gate";
			case Slower			: "/sys_slower";
			case Database		: "/sys_db";
			case Keypad			: "/sys_keypad";
			case Camera			: "/sys_camera";
			case CrimeDatabase	: "/sys_crime_db";
			case LockServer		: "/sys_lock";
			case LockServerLight: "/sys_lock_light";
			case Alarm			: "/sys_alarm";
			case BigDisplay		: "/sys_display";
			case GameServer		: "/sys_game";
			case Ftp			: "/sys_ftp";
			case Tv				: "/sys_tv";
			case TutoTerm		: "/sys_tuto";
			case TutoFirewall	: "/sys_tuto_firewall";
			case Empty			: null;
			case TargetEmpty	: null;
			case Entrance		: null;
			case Treasure		: "/sys_treasure";
		};
		#if debugGen
			trace("generateFS : patt="+patternName);
		#end

		if ( !canConnect() )
			return;

		TD.setSeed(seed); // pour les noms de fichiers
		TD.fsNames.set("owner",owner);
		mpass = TD.texts.get("password", rseed).toLowerCase();

		// structure
		initRand();
		generateFolder(patternName);
		buildTree();
		name = getRoot().name;

		// simplification
//		if ( term.gameLevel==4 ) {
//			var i = 0;
//			while( i<rawTree.length ) {
//				if ( rawTree[i].key=="/programs" ) {
//					rawTree.splice(i,1);
//					i--;
//				}
//				if ( rawTree[i].key=="/lib" ) {
//					rawTree.splice(i,1);
//					i--;
//				}
//				i++;
//			}
//			buildTree();
//		}


		// antivirus
		initRand();
		term.avman.generate(rseed,this);
		term.avman.scan(this);

//		applyNameUnicity();

		// passwords
		if ( term.gameLevel>=5 ) {
			lockFoldersWithPasswords(rseed.random(10));
			initRand();
			hidePasswords();
		}

		// Fichiers spéciaux réservés aux niveaux difficiles
		highLevelFiles("index",2);
		highLevelFiles("log",3);
		highLevelFiles("route",4);
		buildTree();

		// pack
		initRand();
		if ( nodeType==Treasure || rseed.random(100)<75 && !MissionGen.isTutorial(term.mdata) )
			fillPackFiles(E_PackMana, rseed.random(30)+20*term.gameLevel);

		// cryptage contenus
		initRand();
		encodeFiles("global.pass", rseed.random(2)+1);
		if ( term.gameLevel>=6 )
			encodeFiles("file.pass", rseed.random(3)+1);
		else
			encodeFiles("file.pass", rseed.random(2));
		encodeFiles("antivir.index", 1+rseed.random(2));
		encodeFiles("file.route", rseed.random(2));
		if ( term.gameLevel>=6 )
			encodeFiles("file.control", rseed.random(3));
		else if ( term.gameLevel>=3 )
			encodeFiles("file.control", rseed.random(2));
		var genc = rseed.random(3);
		encodeFiles("inv.game", genc);
		encodeFiles("stats.game", genc);
		encodeFiles("gold.game", genc);

		cleanUp();
		buildTree();
		applyNameUnicity();
		fillIndexes();
		initRand();

		// effets
		term.avman.applyEffects(this);
		var d = getFilesByKey("file.guardian").length;
		if ( d>0 )
			for (f in getFilesByKey("file.core"))
				f.addEffect(E_CShield, d,d);
	}

	function cleanUp() {
		var list = Lambda.filter( rawTree, function(f:FSNode) {return f.av!=AntivirusXml.get.avslot;} );
		list = Lambda.filter( list, function(f:FSNode) {return !(f.key=="file.pass" && f.content==null);} );
//		list = Lambda.filter( list, function(f:FSNode) {return !(f.key=="file.pack" && f.content==null);} );
		rawTree = Lambda.array(list);
	}

	inline function initRand() {
		rseed = Data.newRandSeed(seed);
	}


	function generateFolder(?parent:FSNode, pname:String, ?depth:Int=0 ) {
		if ( pname=="/programs" && MissionGen.isTutorial(term.mdata) )
			return;
		var folder = generateFile(parent, pname);
		folder.fl_folder = true;
		folder.sortIndex = rseed.random(500);
		folder.updateInfos();

		// dossiers
		var p = TD.patterns.getContent(pname);
		if ( p!=null ) {
			for (key in p.folders)
				for (i in 0...PatternXml.getCount(rseed,key))
					generateFolder(folder, PatternXml.cleanUpKey(key), depth+1);

			// fichiers
			for (key in p.files)
				for (i in 0...PatternXml.getCount(rseed,key))
					generateFile(folder, PatternXml.cleanUpKey(key));
		}
	}


	function generateFile( parent:FSNode, key:String ) {
		var depth = if(parent==null) 0 else parent.depth+1;
		var file = new FSNode(term, this, parent, key);
		file.id = uniq;
		file.sortIndex = 1000 + rseed.random(500);
		file.seed = uniq + seed;
		if ( file.key=="crime.data" ) {
			file.setOwner(TD.names.get("username"));
			file.name = file.getOwner()+".data";
		}
		else
			file.setOwner(owner);
		file.updateInfos();

		uniq++;
		rawTree.push(file);
		return file;
	}


	public function fillPackFiles(e:EffectType, total:Int) {
		if ( total<=0 )
			return;
		var list = getFilesByExt("pack");

		// filtrage des pack déjà remplis
		list = Lambda.array( Lambda.filter(list, function(f) {
			return f.content==null;
		}) );

		if ( list.length==0 )
			return;
		var n = Std.int( Math.min(3, rseed.random(list.length)+2 ) );
		if ( total<50 && n>1 )
			n = 1;
		if ( total<60 && n>2 )
			n = 2;
		var spreadList = Data.spread(seed, total, n, 0, 10, 25);
		while ( spreadList.length>0 ) {
			var sum = spreadList.splice(0,1)[0];
//			total-=sum;
			var pack = list.splice( rseed.random(list.length), 1 )[0];
			pack.addEffect(e);
			pack.content = Std.string(sum);
		}
	}

	public function spreadMoney(total:Int) {
		if ( !canConnect() )
			return;
		var list = getFilesByExt("pack");

		// filtrage des pack déjà remplis
		list = Lambda.array( Lambda.filter(list, function(f) {
			return f.content==null;
		}) );

		if ( list.length==0 )
			return;

		var spread = divideInBills(total, list.length, data.ValuablesXml.getValues());

		// surplus
		while (spread.length>list.length)
			spread.shift();
		for (f in list) {
			if ( spread.length==0 )
				break;
			f.addEffect(E_PackMoney);
			f.content = Std.string(spread.pop());
		}
	}

	public function cleanUpPacks() {
		// clean up
		rawTree = Lambda.array(
			Lambda.filter( rawTree, function(f:FSNode) {return !(f.key=="file.pack" && f.content==null);} )
		);
		buildTree();
	}

	function divideInBills(total:Int, piles:Int, bills:Array<Int>) {
//		#if debug
//			trace("divideInBills total="+total+" piles="+piles+" bills="+bills);
//		#end
		if ( piles<=0 )
			return new Array();
		if ( bills.length==0 )
			return new Array();
		bills.sort(Reflect.compare);
		total = Math.floor(total/bills[0])*bills[0];
		var list = new Array();
		var i = bills.length-1;
		while( i>=0 && total>0 )
			if ( bills[i]<=total ) {
				total-=bills[i];
				list.push(bills[i]);
			}
			else
				i--;

		// on casse le premier "billet" si on a encore de la place
		list.sort(Reflect.compare);
		if ( piles>list.length ) {
			var highest = list[list.length-1];
			var newBills = Lambda.array( Lambda.filter( bills, function(n) { return n<highest; } ) );
			if ( newBills.length>0 ) {
				var broken = divideInBills(highest, piles-list.length+1, newBills);
				if ( broken.length>0 ) {
					list.pop();
					list = broken.concat(list);
					list.sort(Reflect.compare);
				}
			}
		}
		return list;
	}

	public function fillRouteFiles(neig:List<NetNode>) {
		if ( !canConnect() )
			return;
		if ( neig.length==0 )
			for (f in getFilesByKey("file.route"))
				f.content = TD.texts.get("noRoute");
		else {
			var neigNames = new List();
			for (n in neig) {
				TD.texts.set("ip",n.ip);
				if ( n.type==Entrance )
					TD.texts.set("sysName",Lang.get.EntranceName);
				else
					TD.texts.set("sysName",n.system.name);
				neigNames.add( TD.texts.get("routeEntry") );
			}
			TD.texts.set("route",neigNames.join("||"));
			for (f in getFilesByKey("file.route"))
				f.content = TD.texts.get("route");
		}
	}

	function fillIndexes() {
		// antivirus
		var names = new List();
		var keys = term.avman.fast.keys();
		for (k in keys)
			for (f in term.avman.fast.get(k))
				if ( f.av!=AntivirusXml.get.avslot ) {
					TD.texts.set("path", f.getPathString());
					TD.texts.set("name", f.name.toLowerCase());
					names.add( TD.texts.get("indexEntry") );
				}
		var list = getFilesByKey("antivir.index");
		var c = names.join("\n");
		for (f in list)
			f.content = c;

//		// all files
//		var names = new List();
//		for (f in rawTree) {
//			TD.texts.set("path", f.getPathString());
//			TD.texts.set("name", f.name.toLowerCase());
//			names.add( TD.texts.get("indexEntry") );
//		}
//		var list = getFilesByKey("all.index");
//		var c = names.join("\n");
//		for (f in list)
//			f.content = c;
	}

//	public function fillMatrixes() {
//		var files = getFilesByExt("control");
//		var fl_easy = false;
//		var tries = 0;
//		do {
//			for (f in files) {
//				f.allowMatrix = new Array();
//				for (x in 0...Data.MATRIX_WID)
//					f.allowMatrix[x] = new Array();
//			}
//			// liste de coords
//			var rs = Data.newRandSeed(seed);
//			var ptList = new Array();
//			for (x in 0...Data.MATRIX_WID)
//				for (y in 0...Data.MATRIX_WID)
//					ptList.push({x:x,y:y});
//			// retrait
//			var max = Data.MATRIX_WID-1;
//			for (i in 0...max)
//				ptList.splice(rs.random(ptList.length), 1);
//			// répartition
//			while ( ptList.length>0 ) {
//				var pt = ptList.splice( rs.random(ptList.length),1 )[0];
//				files[rs.random(files.length)].allowMatrix[pt.x][pt.y] = true;
//			}
//
//			fl_easy = false;
//			for (f in files)
//				if ( Data.hasLine(f.allowMatrix) ) {
//					fl_easy = true;
//					break;
//				}
//			tries++;
//		} while(fl_easy && tries<50);
//	}


	function highLevelFiles(ext:String, l:Int) {
		if ( term.gameLevel>=l )
			return;
		var i=0;
		while (i<rawTree.length)
			if ( rawTree[i].hasKeyExt(ext) )
				rawTree.splice(i,1);
			else
				i++;
	}

	function encodeFiles(k:String, l:Int) {
		if ( term.gameLevel<=4 )
			return;
		if ( l==0 )
			return;
		for (f in getFilesByKey(k))
			f.addEffect(E_Encoded,l);
	}


	function hidePasswordInFile(pf:FSNode) {
		TD.texts.set("pass",mpass);
		if ( pf.ext("mail") )
			pf.forceMail( TD.texts.get("SysAdmin"), TD.texts.get("passwordMail") );
		else {
			var o = if(owner!=null) owner else TD.texts.get("sysadmin");
			TD.texts.set("user",o);
			pf.name = TD.fsNames.get("file.pass");
			pf.content = TD.texts.get("passwordDoc");
			pf.key = "file.pass";
		}
	}

	function canHostPassword(file:FSNode,avFile:FSNode) {
		if ( file.fl_target )
			return false;

		// un parent est locké ?
		var p = file.parent;
		while (p!=null) {
			if ( p.password!=null )
				return false;
			p = p.parent;
		}
//		if ( term.avman.folderContains(file.parent, AntivirusXml.get.passwd) )
//			return false;
//		if ( term.avman.parentContains(file.parent, AntivirusXml.get.passwd) )
//			return false;
		return true;
	}

	function lockFoldersWithPasswords(n:Int) {
		if ( MissionGen.isTutorial(term.mdata) )
			return;
		if ( n<=0 )
			return;
		var pool = Lambda.array( Lambda.filter( getFolders(), function(f) {
			return f.parent!=null && f.key!="/program";
		}) );

		// on évite de locker tous les dossiers d'un système qui en contient peu (genre Tv)
		if ( pool.length<=3 && rseed.random(100)<60 )
			return;

		while( n>0 && pool.length>0 ) {
			var f = pool[ rseed.random(pool.length) ];
			f.password = mpass;
			n--;
		}
	}

	public function hidePasswordByKey(k:String, avFile:FSNode) {
		var all = getFilesByKey(k);
		var pool = new Array();
		for (f in all)
			if ( canHostPassword(f,avFile) )
				pool.push(f);

		if ( pool.length==0 )
			return false;
		var pf = pool[ rseed.random(pool.length) ];
		hidePasswordInFile(pf);
		return true;
	}

	public function hidePasswords() {
		var list = Lambda.filter( rawTree, function(f) {
			return f.password!=null;
		});
		if ( list.length<=0 )
			return;

		var n = rseed.random(list.length)+1;
		for (i in 0...n) {
			var file = list.pop();
			TD.texts.set("content",mpass);

			var possibleKeys =
				if ( nodeType==TerminalMul || term.gameLevel<=4 )
					["file.pass","file.data"];
				else
					["file.doc","file.mail","file.pass","file.data"];
			var fl_done = false;
			while ( !fl_done && possibleKeys.length>0 ) {
				var key = possibleKeys.splice( rseed.random(possibleKeys.length), 1 )[0];
				if ( hidePasswordByKey(key,file) )
					fl_done = true;
			}

			// pas réussi ? on crée un dossier dans root !
			if ( !fl_done && possibleKeys.length==0 ) {
				var root = getRoot();
				generateFolder(root,"/pass", root.depth);
				fl_done = hidePasswordByKey("file.pass",file);
				buildTree();
			}
			if ( fl_done )
				break;
		}
	}


	function buildTree() {
		tree = new IntHash();
		index = new Hash();
		for (f in rawTree) {
			var key = if(f.parent==null) -1 else f.parent.id;
			if (tree.get(key)==null) tree.set(key,new Array());
			tree.get(key).push(f);
			if ( f.ext("log") )
				addIndex(f);
		}
	}

	function addIndex(f:FSNode) {
		var ext = f.name.split(".")[1];
		if ( ext==null )
			throw "can't index file "+f.name;
		if ( index.get(ext)==null )
			index.set(ext, new List());
		index.get(ext).add(f);
	}

	public function getFolderFiles(parent:FSNode) {
		return tree.get( if(parent==null) -1 else parent.id );
	}

	public function getFolders() {
		return
			Lambda.array( Lambda.filter(rawTree, function(f:FSNode) {
				return f.fl_folder;
			}) );
	}


	function applyNameUnicity() {
		for (f in rawTree)
			while (!checkUnicity(f))
				f.generateName();
	}


	// *** MISSIONS

	public function uploadFile(?parent:FSNode, key:String) {
		if ( parent==null )
			parent = curFolder;

		// prend la place d'un fichier effacé
		var rep : FSNode = null;
		for (i in 0...rawTree.length) {
			var f = rawTree[i];
			if ( f.parent==parent && f.fl_deleted ) {
				rep = f;
				f.detach();
				rawTree.splice(i,1);
				break;
			}
		}

		var f = generateFile(parent,key);
		if ( rep==null )
			f.sortIndex = 2000 + Data.UNIQ++;
		else
			f.sortIndex = rep.sortIndex;
		buildTree();
		attachFolder(curFolder,false);
		term.addIconRain(sdm,f.mc);
		return f;
	}

	public function forceFolder(?parentKey:String, ?parent:FSNode, pname:String) {
		if ( parent==null)
			parent = getRoot();
		if ( parentKey!=null ) {
			var list = new Array();
			for (f in rawTree)
				if ( f.fl_folder && f.key==parentKey )
					list.push(f);
			if ( list.length<=0 ) throw "forceFolder failed : "+parentKey;
			parent = list[ rseed.random(list.length) ];
		}
		generateFolder(parent,pname,parent.depth);
		buildTree();
	}

	public function forceFiles(?parentKey:String, ?parent:FSNode, pname:String, ?n=1) {
		if ( n<=0 )
			return;
		if ( parent==null)
			parent = getRoot();
		if ( parentKey!=null ) {
			var list = new Array();
			for (f in rawTree)
				if ( f.fl_folder && f.key==parentKey )
					list.push(f);
			if ( list.length<=0 ) throw "forceFiles failed : "+parentKey;
			parent = list[ rseed.random(list.length) ];
		}
		for (i in 0...n)
			generateFile(parent,pname);
		buildTree();
	}

	public function getOneFolder(pname:String) {
		var list = new Array();
		for (f in rawTree)
			if ( f.fl_folder && f.key==pname )
				list.push(f);
		if ( list.length<=0 ) throw "can't find folder : "+pname;
		return list[ rseed.random(list.length) ];
	}

	public function getOneFile(key:String) {
		var list = getFilesByKey(key);
		return list[rseed.random(list.length)];
	}

	public function replaceFile(fname:String,?owner:String,?fl_target=true) { // TODO gérer unicité de nom
		var ext = fname.split(".")[1];
		var list = getFilesByExt(ext);
		var f = list[ rseed.random(list.length) ];
		f.name = fname;
		if ( owner!=null )
			f.setOwner(owner);
		if ( fl_target )
			f.fl_target = true;
		f.updateInfos();
		return f;
	}

	public function replaceFileByKey(k:String, fname:String,?owner:String,?fl_target=true) { // TODO gérer unicité de nom
		var list = getFilesByKey(k);
		var f = list[ rseed.random(list.length) ];
		f.name = fname;
		if ( owner!=null )
			f.setOwner(owner);
		if ( fl_target )
			f.fl_target = true;
		f.updateInfos();
		return f;
	}

	public function forceRootName(name:String) {
		var root = getRoot();
		root.name = name;
		this.name = name;
	}

	public function getTargetFiles(?ext:String,?fl_alsoDeleted=false) {
		var list = new Array();
		for (f in rawTree)
			if ( fl_alsoDeleted && f.fl_deleted || !f.fl_deleted )
				if( f.fl_target && (ext==null || f.ext(ext)) ) list.push(f);
		return list;
	}

	public function getFilesByEffect(e:EffectType) {
		var list = new Array();
		for (f in rawTree)
			if ( !f.fl_deleted && f.hasEffect(e) )
				list.push(f);
		return list;
	}
	public function countTargetFiles(?ext:String) {
		return getTargetFiles(ext).length;
	}



	public function reboot() {
		term.disconnectFS();
	}

	public function crash() {
		if(!fl_auth)
			term.kills++;
		term.onNodeStatusChanged( term.net.curNode );
		term.playSound("explode_05");
		fl_crashed = true;
		for (i in 0...Std.random(15)+10)
			term.addFx(term.net.sdm, AFX_Binary, "fx_binary", term.net.curNode.mc._x, term.net.curNode.mc._y);
		for (i in 0...Std.random(5)+5)
			term.addFx(term.net.sdm, AFX_PlayFrames, "fx_glight", term.net.curNode.mc._x, term.net.curNode.mc._y);
		term.addFx(term.net.sdm, AFX_PlayFrames, "fx_explosion", term.net.curNode.mc._x, term.net.curNode.mc._y);
		fl_authRecent = false;
		term.bigLog(Lang.get.Crashed);
		term.disconnectFS();
		Tutorial.play( Tutorial.get.first, "crashed" );
		Tutorial.play( Tutorial.get.third, "bypassed" );
		term.winGoal("crash");
	}

	public function corrupt() {
		if(!fl_auth)
			term.kills++;
		term.onNodeStatusChanged( term.net.curNode );
		term.playSound("corrupt_02");
		fl_auth = true;
		fl_authRecent = true;
		term.startAnim( A_Text, sub, TD.texts.get("gotcha") );
		term.bigLog(Lang.get.Corrupted);
		updateBg();
		term.winGoal("corrup");
	}


	function updateExternalEffect(nt:NodeType, e:EffectType, ?n:Int, ?max:Int ) {

		if ( term.net.isLinkedTo(term.net.curNode,nt) ) {
			for (f in rawTree)
				if ( !f.fl_folder )
					f.addEffect(e,n,max);
		}
		else
			for (f in rawTree)
				f.removeEffect(e);
	}

	// *** DIVERS

	public function requiresMusic() {
		if ( MissionGen.isTutorial(term.mdata) )
			return false;
		if ( term.avman.countDanger()<=MIN_DANGER_FOR_MUSIC )
			return false;

		switch(nodeType) {
			case Terminal		: return false;
			case TerminalMul	: return false;
			case Printer		: return false;
			case Gateway		: return true;
			case Slower			: return true;
			case Database		: return true;
			case Keypad			: return false;
			case Camera			: return false;
			case CrimeDatabase	: return true;
			case LockServer		: return true;
			case LockServerLight: return false;
			case Alarm			: return false;
			case BigDisplay		: return false;
			case GameServer		: return false;
			case Ftp			: return false;
			case Tv				: return false;
			case TutoTerm		: return false;
			case TutoFirewall	: return true;
			case Empty			: return false;
			case TargetEmpty	: return false;
			case Entrance		: return false;
			case Treasure		: return false;
		}
		return false;
	}

	public function checkUnicity(node:FSNode) {
		for (f in rawTree)
			if ( f.parent==node.parent && f!=node && f.name==node.name )
				return false;
		return true;
	}

	function getPath(file:FSNode) {
		var path = "";
		var parent = file.parent;
		while ( parent!=null ) {
			path=parent.name+"/"+path;
			parent=parent.parent;
		}
		return "/"+path;
	}


	public function countChilds(parent:FSNode, ?fl_countDeleted=false) {
		var list = getFolderFiles(parent);
		var n=0;
		for (f in list)
			if ( fl_countDeleted || !fl_countDeleted && !f.fl_deleted ) n++;
		return n;
	}


	public function getFolderSorted(?parent:FSNode) {
//		var list = new Array();
//		for (f in getFolderFiles(parent))
//			if( type==null || type!=null && type==f.type ) list.push(f);
		var list = getFolderFiles(parent).copy();

		list.sort( function(a,b) {
			if ( a.sortIndex<b.sortIndex )	return -1;
			if ( a.sortIndex>b.sortIndex )	return 1;
			return 0;
//			if (a.fl_folder)
//				return -1;
//			else
//				return 1;
		});
		return list;
	}

	public function getRoot() {
		return getFolderFiles(null)[0];
	}

	public function getNode() {
		return term.net.getNodeBySys(this);
	}


	function shuffle(parent:FSNode, nodes:Array<FSNode>) {
		var files = new Array();
		var dirs = new Array();
		for (node in nodes)
			if ( node.fl_folder ) dirs.push(node) else files.push(node);
		var s = seed + if ( parent==null ) 0 else parent.id;
		Data.shuffle(s,files);
		Data.shuffle(s,dirs);
		return dirs.concat(files);
	}


	public function setTarget(file:FSNode) {
		if ( file.fl_deleted )
			return;
		var old = target;
		Manager.stopTimers();
		if ( target!=null )
			target.onLoseTarget();
		target = file;
		if ( target!=old )
			term.playSound("single_01");

		target.onTarget();
		if (tmc==null) {
			tmc = cast sdm.attach("target",Data.DP_BG);
			if ( term.fl_lowq ) {
				tmc.c2._visible = false;
				tmc.c3._visible = false;
			}
			else {
				tmc.blendMode = "screen";
				tmc.filters = [ new flash.filters.GlowFilter(0xffffff,0.7,12,12,1) ];
			}

		}
		tmc._x = target.mc._x+35;
		tmc._y = target.mc._y+58;

		if ( old!=target ) {
//			term.startAnim(A_Bump, file.mc);
			if ( !term.fl_lowq )
				tmc._xscale = 175;
			tmc._yscale = tmc._xscale*0.5;
			if ( target.allowMatrix!=null )
				term.showCMenu(sdm, target.mc._x+35, target.mc._y+58, [
					{ label:"hack", cb:callback(term.showSystemGame,target) },
				]);
		}

		if ( target.av!=null && !target.hasEffect(E_Masked) ) {
			Col.setPercentColor( tmc, 100, 0xff0000 );
			tmc._alpha = 65;
		}
		else {
			Col.setPercentColor( tmc, 100, 0xffffff );
			tmc._alpha = 40;
		}
		focus(file.mcIndex);

//		file.mc.icon.filters = [ new flash.filters.GlowFilter(0xffffff,1, 3,3, 10) ];
	}

	public function onChangedContent(f:FSNode) {
		if ( target==f )
			f.onTarget();
	}

	public function onCorruptControl() {
		// reste-t-il un fichier control valide ?
		for (f in rawTree)
			if (f.key=="file.control" && !f.hasEffect(E_Corrupt)) {
				term.playSound("corrupt_01");
				return;
			}

		// non :)
		corrupt();
	}

	public function clearTarget() {
		Manager.stopTimers();
		term.detachCMenu();
		tmc.removeMovieClip();
		tmc=null;
//		target.mc.icon.filters = null;
		if ( target!=null )
			target.onLoseTarget();
		target = null;
	}

	function getFilesSorted() {
		var me = this;
		var files = filterFiles( function(f) {
			return !f.fl_folder && f.parent==me.curFolder; //&& f.canAggro();
		});
		files.sort( function(fa,fb) {
			if (fa.sortIndex<fb.sortIndex) return -1;
			if (fa.sortIndex>fb.sortIndex) return 1;
			return 0;
		});
		return files;
	}

	public function nextTarget() {
		var files = getFilesSorted();
		if ( files.length==0 ) return;

		if ( target==null )
			setTarget(files[0]);
		else {
			files.push( files[0] ); // pour looper
			var fl_found = false;
			for (f in files) {
				if ( fl_found ) {
					clearTarget();
					setTarget(f);
					break;
				}
				if ( f.id==target.id )
					fl_found = true;
			}
		}
	}

	public function prevTarget() {
		var files = getFilesSorted();
		if ( files.length==0 ) return;
		if ( target==null )
			setTarget(files[files.length-1]);
		else {
			files.insert(0, files[files.length-1] ); // pour looper
			var fl_found = false;
			var i = files.length-1;
			while( i>=0 ) {
				var f = files[i];
				if ( fl_found ) {
					clearTarget();
					setTarget(f);
					break;
				}
				if ( f.id==target.id )
					fl_found = true;
				i--;
			}
		}
	}

	public function getFilesByKey(k:String, ?parent:FSNode) {
		k = k.toLowerCase();
		var files = if(parent!=null) getFolderFiles(parent) else rawTree;
		var list = new Array();
		for (f in files)
			if ( f.key==k && !f.fl_deleted )
				list.push(f);
		return list;
	}

	public function getFile(name:String) {
		if(name==null) return null;
		name = name.toLowerCase();
		for (f in getFolderFiles(curFolder))
			if (!f.fl_deleted && f.name.toLowerCase()==name) return f;
		return null;
	}

	public function delete(f:FSNode,?a:Anim,?fl_stealth=false) {
		var oldAvKey = f.av.key;
		f.fl_deleted = true;
		f.clearEffect(E_Dot);
		if ( f.hasKeyExt("log") ) {
			term.playSound("bonus_01");
			term.gainTime(30);
			term.winGoal( "log" );
		}
		if ( f.hasKeyExt("antivir") ) {
			term.winGoal( "av" );
			if ( getRythmes().length>0 && !requiresMusic() ) {
				stopRythmes();
				startLocalLoop( term.getDrone(seed) );
			}
		}
		logEvent( Lang.fmt.TraceDelete({_name:f.name}) );
		if (target==f)
			clearTarget();
		if ( a==null )
			term.startAnim( A_Delete, f.mc );
		term.avman.onDeleteFile(f,fl_stealth);
		term.onDeleteFile(f);

		if ( getFilesByKey("file.core").length<=0 )
			crash();
//		if ( oldAvKey=="crypto" )
//			onDeleteCrypto();
		Tutorial.play(Tutorial.get.first, "fileDestroyed");
	}

	public function unmaskFolder() {
		for (f in getFolderFiles(curFolder)) {
			if ( f.fl_deleted || !f.hasEffect(E_Masked) )
				continue;
			var a = term.startAnim(A_Decrypt, f.mc, f.name, -Std.random(100)/100);
			a.cb = callback(onUnmask,f);
		}
	}

	public function onUnmask(f:FSNode) {
		f.redraw();
		if ( target==f )
			setTarget(f);
	}

	public function disconnect() {
		curFolder = null;
		detach();
		term.inheritLoop( localSounds.pop() );
		stopLocalLoops();

		for (f in rawTree) {
			f.clearEffect(E_Dot);
			f.clearEffect(E_DotLength);
		}

		if ( fl_authRecent ) {
			fl_authRecent = false;
			for (i in 0...Std.random(15)+10)
				term.addFx(term.net.sdm, AFX_Binary, if(Std.random(100)<75) "fx_corrupt" else "fx_binary", term.net.curNode.mc._x, term.net.curNode.mc._y);
		}
	}


	public function openFolder(f:FSNode,?fl_stealth=false) {
		if ( !fl_stealth )
			term.avman.onOpenDir();
		else
			term.log(Lang.get.Log_Stealth);
		clearTarget();
		term.dock.clearPending();
		attachFolder(f);
		term.playSound("single_03");
	}

	public function searchExt(parent:FSNode, str:String) {
		return getMatch(parent, "."+str).length > 0;
	}


	function getMatch(parent:FSNode, str:String) : Array<FSNode> {
		str = str.toLowerCase();
		var list = new Array();
		for (f in getFolderFiles(parent))
			if ( matchRec(f,str) )
				list.push(f);
		return list;
	}

	function matchRec(file:FSNode, str:String) {
		if ( file.fl_deleted )
			return false;

		if ( file.fl_folder ) {
			for (f in getFolderFiles(file))
				if ( matchRec(f,str) )
					return true;
			return false;
		}
		else
			return file.name.toLowerCase().indexOf(str) >= 0;
	}


	public function countFilesByExt(?parent:FSNode, ext:String, ?fl_alsoDeleted=false) {
		return getFilesByExt(parent,ext,fl_alsoDeleted).length;
	}


	public function getFilesByExt(?parent:FSNode, ext:String, ?fl_alsoDeleted=false) {
		ext = ext.toLowerCase();
		var files = if(parent==null) rawTree else getFolderFiles(parent);
		var list = new Array();
		for (f in files)
			if ( !f.fl_folder && (!f.fl_deleted && !fl_alsoDeleted || fl_alsoDeleted) && f.ext(ext) )
				list.push(f);
		return list;
	}

	public function getFilesByExtRec(?parent:FSNode, ext:String, ?fl_alsoDeleted=false) {
		ext = ext.toLowerCase();
		var files = if(parent==null) rawTree else getFolderFiles(parent);
		var list = new Array();
		for (f in files)
			if (f.fl_folder)
				list = list.concat(getFilesByExtRec(f,ext,fl_alsoDeleted));
			else
				if ( (!f.fl_deleted && !fl_alsoDeleted || fl_alsoDeleted) && f.ext(ext) )
					list.push(f);
		return list;
	}


	public function filterFiles( ?fl_alsoDeleted=false, ?parent:FSNode, filter:FSNode->Bool ) : Array<FSNode> {
		var files = if(parent==null) rawTree else getFolderFiles(parent);
		var list = new Array();
		for (f in files)
			if ( (!fl_alsoDeleted && !f.fl_deleted || fl_alsoDeleted) && filter(f)) list.push(f);
		return list;
	}

	public function highlight(f:FSNode) {
		for (mc in fmcList)
			if ( mc.field.text==f.name ) {
				var a = mc._alpha;
				Col.setPercentColor( mc, 50, 0xffaa00 );
				mc._alpha = a;
				return;
			}
	}

	public function recursiveAddEffect(parent:FSNode, e:EffectType, ?n=1) {
		for (f in getFolderFiles(parent)) {
			if ( f.fl_folder )
				recursiveAddEffect(f, e, n);
			f.addEffect(e,n);
		}
	}

	public function recursiveRemoveEffect(parent:FSNode, e:EffectType) {
		for (f in getFolderFiles(parent)) {
			if ( f.fl_folder )
				recursiveRemoveEffect(f, e);
//			while (f.hasEffect(e))
				f.removeEffect(e);
		}
	}


	public function getDiff() {
		var d = baseDiff;
		var node = getNode();
		if ( node.type==Terminal )
			d = Std.int( Math.min(15,d) );
		return d;
	}


	public function logEvent(str:String) {
		if ( term.hasEffect(UE_Furtivity) )
			return;
		TD.texts.set("time", DateTools.format(Date.now(),"%H:%M"));
		TD.texts.set("event",str);
		str = "<p>"+TD.texts.get("forcedLog")+"</p>";
		TD.texts.set("pass",mpass);
		var base : String = null;
		for (f in index.get("log")) {
			if ( f.fl_deleted )
				continue;
			if ( f.content==null ) {
				if ( base==null )
					base = TD.texts.get("log", Data.newRandSeed(seed));
				f.content = base;
			}
			f.content = str + f.content;
		}
	}


	// *** AFFICHAGE

	public function onGotoParent() {
		if ( curFolder.parent==null )
			onDisconnectButton();
		else
			onReleaseFolder(curFolder.parent);
	}

	function onReleaseFolder(file:FSNode) {
		focus(file.mcIndex);
		term.vman.exec( data.VirusXml.get.cd, file );
	}

	function onReleaseFile(file:FSNode) {
		var prevTarget = target;
		clearTarget();
		if ( term.dock.needTarget() ) {
			if ( Progress.isRunning() ) return;
			term.dock.giveTarget(file);
		}
		else
			if ( file!=prevTarget )
				setTarget(file);
//		term.shell.run("delete "+name);
	}

	public function focus(idx:Int) {
		if ( Math.isNaN(idx) )
			idx = 0;
		if ( idx>0 )
			idx--;

		stimer = 0;
		sty = Std.int( Math.floor(idx/FSNode.ICON_BY_LINE)*75 );

		if ( sty<smin )
			sty = smin;
		if ( sty>smax )
			sty = smax;

		blinkArrows(sty-sy);
		updateScrollPos();
	}

	function blinkArrows(delta:Int) {
		if ( delta==0 )
			return;

		if ( scrollPrev._name!=null && !term.fl_lowq )
			if ( delta>0 ) {
				if ( !term.hasAnim(scrollNext, 0.7) )
					term.startAnim(A_Blink, scrollNext);
			}
			else {
				if ( !term.hasAnim(scrollPrev, 0.7) )
					term.startAnim(A_Blink, scrollPrev);
			}
	}

	public function scroll(dirY:Int) {
		onMouseWheel(-dirY*16);
	}

	function onMouseWheel(delta:Int) {
		if (fl_lock)
			return;

		blinkArrows(-delta);

		// scrolling
		var d : Float = -delta;
		d *= term.ls.wheelSpeed/5;
		if ( d>0 && sy+d>smax )
			d *= 1-Math.min( 1, Math.abs(smax-sy)/50 );
		if ( d<0 && sy+d<smin )
			d *= 1-Math.min( 1, Math.abs(smin-sy)/25 );
		if ( sty==null )
			sty = sy;
		sty += Math.round(d*6);

		stimer = 0;
		updateScrollPos();
		stimer = 2;
	}


	function updateScrollPos() {
		if ( sty!=null ) {
			var delta = (sty-sy)*0.1;
			if ( delta>-1 && delta<0 )
				delta = -1;
			if ( delta>0 && delta<1 )
				delta = 1;
			sy += Std.int(delta);
			if ( Math.abs(sy-sty)<=1 ) {
				sy = sty;
				sty = null;
			}
		}
		if ( stimer>0 )
			stimer-=Timer.tmod;
		else {
			if ( sy<smin ) {
				sy = Std.int(sy + Timer.tmod*(smin-sy)*SCROLL_SPEED);
				sty = null;
			}
			if ( sy>smax ) {
				sy = Std.int(sy + Timer.tmod*(smax-sy)*SCROLL_SPEED);
				sty = null;
			}
			scroller._x = (10-sy);
			scroller._y = Math.round((30-sy)*0.5);
		}
	}

	function onDisconnectButton() {
		if ( Progress.isRunning() )
			return;
		term.vman.exec( data.VirusXml.get.exit );
//		if ( !Tutorial.reached( Tutorial.get.first, "end" ) ) {
//			term.popUp(Lang.get.NotNow);
//			return;
//		}
//		if ( !Tutorial.reached( Tutorial.get.second, "userProfile" ) ) {
//			term.popUp(Lang.get.NotNow);
//			return;
//		}
//
//		Tutorial.play( Tutorial.get.second, "nowExit" );
//		if ( term.avman.folderContains(curFolder, AntivirusXml.get.glue ) )
//			if ( term.hasEffect(UE_Furtivity) || term.hasEffect(UE_MoveFurtivity) )
//				term.disconnectFS();
//			else
//				term.popUp(Lang.get.CantGetOut);
//		else
//			term.disconnectFS();
//		focus(0);
	}


	function changeZoom(?delta=0.0) {
		zoom+=delta;
		zoom = Math.max(0.5,Math.min(1.5,zoom));
		var scale = zoom*100;
//		cont._xscale = zoom*100;
//		cont._yscale = cont._xscale;
//		cont._x = Data.WID*0.5-cont._width*0.5;
		var index=0;
		for (mc in fmcList) {
			mc._xscale = scale;
			mc._yscale = scale;
			mc.field._xscale = 100-0.5*(scale-100);
			mc.field._yscale = mc.field._xscale;
			mc.field._visible = zoom>=1;

			var x = (index%FSNode.ICON_BY_LINE);
			var y = Math.floor(index/FSNode.ICON_BY_LINE);
			var hexWid = 150*zoom*zoom;
			var hexHei = 75*zoom*zoom;
			mc._x = 5 + x*hexWid*0.5 + y*hexWid*0.4;
			mc._y = 200 + -x*hexHei*0.5 + y*hexHei*0.5;
			index++;
		}
	}


	public function detach() {
		fl_lock = true;
		clearTarget();
		detachFolder();
		bg.removeMovieClip();
		title.removeMovieClip();
		wallR.removeMovieClip();
		scrollPrev.removeMovieClip();
		scrollNext.removeMovieClip();
		scroller.removeMovieClip();
		flash.Mouse.removeListener(ml);
		sdm.destroy();
		term.detachBubble();
	}

	public function attach() {
		detach();

		bg = Manager.DM.attach("bg",Data.DP_FS);
		bg.stop();
		bg.blendMode = "layer";
		bg.useHandCursor = false;
		bg.onRelease = function() {};

		wallR = Manager.DM.attach("wallIso",Data.DP_FS);
		wallR._x = 250;
		wallR._y = 0;
		wallR._xscale*=-1;

		scroller = Manager.DM.empty(Data.DP_FS);
		scroller._x = 32;
		sdm = new mt.DepthManager(scroller);

		title = cast sdm.attach("title", Data.DP_TOP);
		title._x = 0;
		title._y = 5;
		title.cacheAsBitmap = true;

		sub = cast sdm.attach("title", Data.DP_TOP);
		sub._x = 10;
		sub._y = 85;
		sub._xscale = 60;
		sub._yscale = sub._xscale;
		sub._alpha = 70;
		sub.cacheAsBitmap = true;

		attachFolder(getRoot());

		wallL = sdm.attach("wallIso",Data.DP_BG_ITEM);
		wallL._x = 380;
		wallL._y = 50;
		Col.setPercentColor(wallR, 45, 0x0);
		zoom = 1;
//		changeZoom();
		ml = {};
		Reflect.setField(ml, "onMouseWheel", onMouseWheel);
		flash.Mouse.addListener(ml);
		updateBg();

		for (f in rawTree)
			f.displayEffects();

//		term.avman.updateStack();
		fl_lock = false;

		Col.setColor(bg, term.mdata._color, -60);
		Col.setColor(wallL, term.mdata._color, -30);
		Col.setColor(wallR, term.mdata._color, -50);

		Tutorial.play(Tutorial.get.first, "showDock");
		Tutorial.play(Tutorial.get.second, "scanner");

		if ( fl_fresh ) {
			// premier affichage
		}
		fl_fresh = false;
	}


	public function connect(spd) {
		speed = spd;
		term.avman.scan(this);

//		updateExternalEffect( AntiOverwrite, E_OverResist, 1,1 );

		term.stopLocalLoops();
		term.stopSound("modem_03");
		term.playSound("bleep_01");
		if ( requiresMusic() ) {
			startLocalLoop(term.getElectro(seed));
			startLocalLoop(term.getRythm(seed));
		}
		else {
			if ( Std.random(2)==0 ) {
				startLocalLoop(term.getDrone(seed));
				startLocalLoop(term.getElectro(seed));
			}
			else {
				startLocalLoop(term.getElectro(seed));
				startLocalLoop(term.getDrone(seed));
			}
		}

		attach();
		term.showCmdLine();
		Manager.stopLoading();
	}


	function setWallpaper(link:String,frame:Dynamic) {
		wpaper.removeMovieClip();
		wpaper = wallL.smc.attachMovie(link,"mc_"+Data.UNIQ, Data.UNIQ++);
		wpaper._xscale = 300;
		wpaper._yscale = wpaper._xscale;
		wpaper.gotoAndStop(frame);
		wpaper.blendMode = "screen";
		wpaper._x = -wpaper._width*2;
		wpaper._y = -wpaper._height;
		wpaper._alpha = 30;
	}

	function updateBg() {
		var f = if(fl_auth) 2 else 1;
		bg.gotoAndStop(f);
		wallL.smc.gotoAndStop(f);
		wallR.smc.gotoAndStop(f);
		if ( fl_auth )
			setWallpaper("sicon","corrupt");

//			Col.setPercentColor( bg, 50, 0xff0000 );
//			Col.setPercentColor( wallL, 50, 0xff0000 );
//			Col.setPercentColor( wallR, 50, 0xff0000 );
//		}
//		bg
//		bg.gotoAndStop( if(fl_auth) 1 else 2 );
	}

	function detachFolder() {
		sty = null;
		stimer = 0;
		for (mc in fmcList) mc.removeMovieClip();
		fmcList = new Array();
		term.detachBubble();
	}


	public function attachFolder(?parent:FSNode,?fl_anim:Bool) {
		detachFolder();

		if ( fl_anim==null )
			fl_anim = parent!=curFolder.parent;

		var nodes = getFolderSorted(parent);
//		nodes = shuffle(parent,nodes);

		var mc = FSNode.attach(sdm,false);
		term.startAnim(A_FadeIn,mc);
		mc.hit.onRelease = onGotoParent;
		mc.icon.gotoAndStop( if(parent.parent!=null) "parent" else "disconnect" );
		mc.icon2.gotoAndStop(mc.icon._currentframe);
		fmcList.push(mc);
		exitIcon = mc;

		var i = fmcList.length;
		for (f in nodes) {
			var mc = FSNode.attach(sdm,fl_anim, f,i);
			if ( f.fl_folder )
				mc.hit.onRelease = callback(onReleaseFolder,f);
			else
				mc.hit.onRelease = callback(onReleaseFile,f);
			i++;
			fmcList.push(mc);
		}

		smin = 0;
		smax = Std.int( 90 * Math.max(0, Math.ceil(fmcList.length/FSNode.ICON_BY_LINE)-2) );

		Data.zsort(sdm, cast fmcList);

		curFolder = parent;
		var spam = TD.texts.get(if(fl_auth) "hackerSpam" else "corpoSpam");
		title.field.text = curFolder.name;
		sub.field.text = spam;
		if ( !term.fl_lowq ) {
			term.startAnim( A_Text, title, curFolder.name );
			term.startAnim( A_Text, sub, spam, -3 );
		}
		focus(0);
		updateBg();

		// scrolling arrows
		scrollPrev.removeMovieClip();
		scrollNext.removeMovieClip();
		if ( fmcList.length/FSNode.ICON_BY_LINE >= 2 ) {
			scrollPrev = Manager.DM.attach("scrollArrow", Data.DP_FX);
			scrollPrev._x = 510;
			scrollPrev._y = 50;
			scrollPrev.onRelease = callback( scroll, -1 );
			scrollNext = Manager.DM.attach("scrollArrow", Data.DP_FX);
			scrollNext._x = scrollPrev._x+30;
			scrollNext._y = scrollPrev._y+17;
			scrollNext.smc.smc._xscale *= -1;
			scrollNext.onRelease = callback( scroll, 1 );
			term.startAnim(A_FadeIn, scrollPrev, -2);
			term.startAnim(A_FadeIn, scrollNext, -2.5);
		}
	}


	public function updateFolder() {
		for (f in getFolderFiles(curFolder))
			if ( f!=null )
				f.redraw();
	}

	function tutorialPoint( filter:FSNode->Bool, x=35,y=20, ?ang:Int ) {
		for (f in getFolderFiles(curFolder) )
			if (filter(f))
				Tutorial.point( sdm, f.mc._x+x, f.mc._y+y, ang);
	}

	public function update() {
		if ( fl_lock ) return;

		updateScrollPos();
//		if ( stimer>0 )
//			stimer-=Timer.tmod;
//		else {
//			if ( sy<smin ) {
//				sy = Std.int(sy + Timer.tmod*(smin-sy)*SCROLL_SPEED);
//				sty = null;
//			}
//			if ( sy>smax ) {
//				sy = Std.int(sy + Timer.tmod*(smax-sy)*SCROLL_SPEED);
//				sty = null;
//			}
//			updateScrollPos();
//		}

		if ( tmc._name!=null ) {
			var spd = 4;
			tmc.c1._rotation+=spd;
			if ( !term.fl_lowq ) {
				tmc.c2._rotation+=-spd*1.3;
				tmc.c3._rotation+=spd*0.5;
			}
			if ( tmc._xscale!=120 ) {
				tmc._xscale += (120-tmc._xscale)*0.4;
				tmc._yscale = tmc._xscale*0.5;
			}
		}


		if ( Tutorial.at(Tutorial.get.first, "askTarget") )
			tutorialPoint( function(f) { return f.ext("doc"); } );

		if ( Tutorial.at(Tutorial.get.first, "cd") )
			tutorialPoint( function(f) { return f.fl_folder; } );

		if ( Tutorial.at(Tutorial.get.first, "core") || Tutorial.at(Tutorial.get.first, "coreExposed") )
			tutorialPoint( function(f) { return f.key=="file.core"; } );

		if ( Tutorial.at(Tutorial.get.third, "waitKillCore") ) {
			tutorialPoint( function(f) { return f.key=="file.core"; } );
			tutorialPoint( function(f) { return f.key=="file.guardian"; } );
		}

		if ( Tutorial.at(Tutorial.get.first, "shield2") )
			tutorialPoint( function(f) { return f.key=="file.core"; }, 2, 53, -55 );

		if ( Tutorial.at(Tutorial.get.first, "targetGuardian") )
			tutorialPoint( function(f) { return f.key=="file.guardian"; } );

		if ( Tutorial.at(Tutorial.get.second, "scannerDone") )
			Tutorial.point( Manager.DM, Data.WID-70, 25, -90 );

		if ( Tutorial.at(Tutorial.get.second, "userProfile") )
			tutorialPoint( function(f) { return f.key=="/usersingle"; } );

		if ( Tutorial.at(Tutorial.get.third, "openSys") || Tutorial.at(Tutorial.get.third, "waitOpenSys") ) {
			tutorialPoint( function(f) { return f.fl_folder; } );
			tutorialPoint( function(f) { return f.av!=null; } );
		}
		if ( Tutorial.at(Tutorial.get.third, "copyFile2") )
			tutorialPoint( function(f) { return f.fl_target; } );

		if ( Tutorial.at(Tutorial.get.second, "exit1") || Tutorial.at(Tutorial.get.second, "exit2") )
			Tutorial.point(sdm, exitIcon._x+35, exitIcon._y+20);

//		stx = Math.floor( (Data.WID - Manager.ROOT._xmouse-Data.WID*0.5) * 0.25 );
//		sty = Math.floor( (Data.HEI - Manager.ROOT._ymouse-Data.HEI*0.5) * 0.25 );

//		if ( scroller._x!=stx || scroller._y!=sty ) {
//			// X
//			var delta = Math.round(stx-scroller._x);
//			if ( delta>0 && delta<1 )	delta=1;
//			if ( delta>-1 && delta<0 )	delta=-1;
//			scroller._x = scroller._x + delta*SCROLL_SPEED;
//			if ( Math.abs(stx-scroller._x)<1 )
//				scroller._x = stx;
//			// Y
//			var delta = Math.round(sty-scroller._y);
//			if ( delta>0 && delta<1 )	delta=1;
//			if ( delta>-1 && delta<0 )	delta=-1;
//			scroller._y = scroller._y + (sty-scroller._y)*SCROLL_SPEED;
//			if ( Math.abs(sty-scroller._y)<1 )
//				scroller._y = sty;
//		}

	}
}


