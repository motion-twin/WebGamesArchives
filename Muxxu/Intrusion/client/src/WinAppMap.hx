import Types;
import data.ChipsetsXml;

enum MapMode {
	MapAV;
	MapPack;
//	MapKernel;
}

class WinAppMap extends WinApp {
	static var X_STACK = 320;
	static var Y_STACK = 40;
	static var LINE_HEIGHT = 15;
	static var X_OFFSET = 22;

	var fs			: GFileSystem;
	var avList		: List<flash.MovieClip>;
	var scanLevel	: Int;
	var mode		: MapMode;
	public var fl_ignoreScrambler	: Bool;

	public function new(t) {
		super(t);
		avList = new List();
		mode = null;
		fl_ignoreScrambler = false;
	}

	override public function start() {
		super.start();
	}

	override public function stop() {
		detachStack();
		super.stop();
	}

	public function showMap(pfs:GFileSystem, lvl:Int, ?mm:MapMode) {
		fs = pfs;
		scanLevel = lvl;
		mode = mm;
		separator(X_STACK);
		scrollUp._x = X_STACK-10;
		scrollDown._x = X_STACK-10;
		attachNode();
		updateStack();
	}

	function isScrambled() {
		if ( fl_ignoreScrambler || term.hasChipset(ChipsetsXml.get.sscan) )
			return false;
		else
			return term.avman.systemContains(data.AntivirusXml.get.brouilleur);
	}

	function junkName(f:FSNode) {
		var len = Std.int( Math.min(4, fs.name.length) );
		var str = "";
		for (i in 0...len)
			str+=String.fromCharCode( 33+Std.random(50) );
		return str;
	}

	function attachNode(?parent:FSNode, ?level=0, ?y=0) {
		if ( term.fs.curFolder==parent ) {
			var me = sdm.attach("mapBleep", Data.DP_FX);
			me._x = level*X_OFFSET +3;
			me._y = y + 5;
			term.bubble(me, Lang.get.MapYouAreHere);
		}

		var fl_scrambled = isScrambled();
		var fl_superScan = term.hasChipset( ChipsetsXml.get.sscan );


		// child "???" si parent protégé par password
		if ( parent.password!=null && !fl_superScan ) {
			var mc : MCField = cast sdm.attach("mapFolder",Data.DP_ITEM);
			mc._x = 20 + level*X_OFFSET;
			mc._y = 15 + y;
			mc.smc._visible = false;
			mc.field._x = 0;
			mc.field.text = "???";
			addBranch(mc._x-10, mc._y, 1);
			return y + LINE_HEIGHT;
		}


		// récupération du contenu affichable de ce dossier
		var me = this;
		var list = fs.getFolderFiles(parent);
		list.sort( function(a,b) {
			if (a.fl_folder) return 1;
			return -1;
		} );
		list = Lambda.array( Lambda.filter(list, function(f:FSNode) {
			if ( f.fl_deleted )
				return false;
			if ( !f.fl_folder )
				if ( me.mode==null || me.mode==MapAV && f.av==null || me.mode==MapPack && f.key!="file.pack" )
					return false;
			return true;
		}) );


		var i = 0;
		var oldY = 9999;
		for (f in list) {

			// label
			var mc : MCField = cast sdm.attach("mapFolder",Data.DP_ITEM);
			mc._x = 20 + level*X_OFFSET;
			mc._y = 15 + y;
			mc.smc.gotoAndStop(1);
			if ( fl_scrambled )
				mc.field.text = junkName(f);
			else
				mc.field.text =  f.name;


			// branches : lignes
			if ( i<list.length ) {
				oldY+=LINE_HEIGHT*2;
				while ( oldY <= y ) {
					addBranch(mc._x-10, oldY, 2);
					oldY+=LINE_HEIGHT;
				}
			}
			oldY = y;

			if ( f.fl_folder ) {
				// dossiers
				if ( scanLevel>=3 && term.avman.folderContainsAny(f) ) {
					tip(mc, Lang.get.MapAV);
					mc.field.textColor = 0xffff00;
					mc.field.filters = [ new flash.filters.GlowFilter(0xffbb00, 0.5, 5,5) ];
					mc.smc.gotoAndStop(2);
				}
				if ( f.password!=null ) {
					mc.smc.gotoAndStop(6);
					tip(mc, Lang.get.MapLocked);
				}

				y = attachNode(f, level+1, y+LINE_HEIGHT);
			}
			else {
				// fichiers
				switch(mode) {
					case MapAV :
						mc.smc.gotoAndStop(3);
						tip(mc, f.av.key.toUpperCase(), f.av.desc);
					case MapPack :
						mc.smc.gotoAndStop(4);
						tip(mc, Lang.get.Tooltip_Extract);
				}
				y += LINE_HEIGHT;
			}


			// banches : coins
			if ( parent!=null )
				addBranch(mc._x-10, mc._y, 1);

			i++;
		}
		return y;
	}

	function addBranch(x,y,frame:Int) {
		var branch = sdm.attach("mapBranch", Data.DP_BG_ITEM);
		branch._x = x;
		branch._y = y;
		branch.gotoAndStop(frame);
		return branch;
	}

	function tip(mc:flash.MovieClip, title:String, ?txt:String) {
		term.bubble(mc,title,txt, callback(onOver,mc), callback(onOut,mc));
	}

	public function detachStack() {
		for (mc in avList)
			mc.removeMovieClip();
		avList = new List();
	}


	public function updateStack() {
		detachStack();
		if ( scanLevel<=1 )
			return;

		if ( term.fs==null )
			return;

		if ( mode==MapPack )
			return;

		addField(X_STACK+20, Y_STACK, Lang.get.MapAVList);

		var total = 0;
		for (k in term.avman.fast.keys()) {
			var list = term.avman.fast.get(k);
			if ( list.length==0 )
				continue;
			var av = data.AntivirusXml.ALL.get(k);
			var v = av.diff*list.length;
			total+=v;
			var extra = "";
			var text = switch( scanLevel ) {
				case 1	: k;
				case 2	: if ( list.length==1 ) k else k+" x "+list.length;
				case 3	: if ( list.length==1 ) k else k+" x "+list.length;
				case 4	: if ( list.length==1 ) k else k+" x "+list.length;
//				case 4	:
//					extra+="\n";
//					for (f in list)
//						extra+=f.getPathString()+"\n";
//					if ( list.length==1 )
//						k.toUpperCase()
//					else
//						k.toUpperCase()+" x "+list.length;
			}
			text = "[?] "+text;
			#if debug
				text+=" (+"+v+")";
			#end
			var mc = addField(X_STACK+20, Math.round(Y_STACK+25 + 16*avList.length), text, -Std.random(15)/10);
			var onOver = function() { mc.field.textColor = 0xffffff; };
			var onOut = function() { mc.field.textColor = Data.GREEN; };
			term.bubble(mc, k.toUpperCase(), av.desc+extra, 0, onOver, onOut );
			avList.push(mc);
		}
		#if debug
			avList.add(
				addField(X_STACK+20, Math.round(Y_STACK+35 + 16*avList.length), "TOTAL = "+total+" points")
			);
		#end

	}

	override function onClose() {
		super.onClose();
		Tutorial.play( Tutorial.get.second, "mapAfter" );
	}


	override public function update() {
		super.update();
		if ( Tutorial.at(Tutorial.get.second,"mapDone" ) )
			Tutorial.point(dm, win.close._x+10, win.close._y+30, 180);
	}
}