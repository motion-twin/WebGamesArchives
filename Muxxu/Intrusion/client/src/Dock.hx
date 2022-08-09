import mt.bumdum.Lib;
import Types;
import data.VirusXml;
import GNetwork;

typedef DockMC = {
	> MCField,
	virusId	: flash.TextField,
}

typedef DockSlot = {
	mc		: DockMC,
	virus	: Virus,
//	hotkey	: Int,
}
class Dock {
	static public var ICON_WIDTH = 39;

	var root			: flash.MovieClip;
	var dm				: mt.DepthManager;
	var decks			: Array<{name:String, content:Array<DockSlot>}>;
	var currentDeck		: Int;
	var term			: UserTerminal;
	var pending			: DockSlot;
	var fl_lock			: Bool;
	var baseFilters		: Array<flash.filters.BitmapFilter>;
	var emcList			: List<MCField>;
	var urlList			: List<{mc:flash.MovieClip, url:String}>;
	var swButton		: MCField;
	var fButton			: MCField;


	public function new(t:UserTerminal) {
		fl_lock = true;
		root = Manager.DM.empty(Data.DP_TOP);
		dm = new mt.DepthManager(root);
		term = t;
		emcList = new List();
		decks = new Array();
		currentDeck = 0;
		baseFilters = new Array();
		baseFilters.push( new flash.filters.GlowFilter(0x0,1, 3,3, 600) );
	}


	public function detach() {
		for (p in getCurrentDeck()) {
			var a = term.startAnim( A_Move, p.mc );
			a.spd*=0.5;
			a.ty-=42;
			term.startAnim( A_FadeRemove, p.mc ).spd*=0.5;
			p.mc = null;
		}
	}

	public function isVirusAvailable(vp:Virus) {
		for (ds in getCurrentDeck())
			if ( ds.virus.id==vp.id )
				return true;
		return false;
	}

	public function switchDeck(?n:Int) {
		if ( n==currentDeck )
			return;
		if ( !swButton._visible )
			return;
		if ( n==null )
			n = currentDeck+1;
		if ( n>=decks.length )
			n = 0;
		detach();
		currentDeck = n;
		term.playSound("absorb_02");
		term.log( Lang.fmt.Log_ChangedDeck({_name:decks[currentDeck].name}) );
		attach();
		if ( term.fs!=null )
			swButton._visible = false;
	}

	public function registerDeck(name:String, list:List<Virus>) {
		var slotList = new List();
		for (v in list) {
			var ds : DockSlot = {
				mc		: null,
				virus	: v,
			};
			slotList.add(ds);
		}
		decks.push({
			name	: name,
			content	: Lambda.array(slotList)
		});
	}

	public function getCurrentDeck() {
		return decks[currentDeck].content;
	}

	public function getCurrentViruses() {
		var d = getCurrentDeck();
		var list = new List();
		for (ds in d)
			list.add(ds.virus);
		return list;
	}


	public function attach() {
		// bouton "fichiers copiés"
		if ( fButton==null ) {
			fButton = cast Manager.DM.attach("menuButton", Data.DP_TOP);
			fButton._x = Data.WID-fButton._width-4;
			fButton._y = 4;
			fButton.field.text = Lang.get.ButtonMyFiles;
			term.initStandardButton(fButton, onMyFiles);
			fButton._visible = term.storage.length>0;
		}
		// bouton "changer de deck"
		if ( swButton==null && decks.length>1 ) {
			swButton = cast Manager.DM.attach("menuButton", Data.DP_TOP);
			swButton._x = 4;
			swButton._y = 4;
			swButton.field.text = Lang.get.ButtonSwitchDeck;
			term.initStandardButton(swButton, onSwitch);
		}
		detach();
		var i = 0;
		var list = getCurrentDeck();
		var me = this;
		for (ds in list) {
			var mc : DockMC = cast dm.attach("slot",0);
			mc._x = Math.round( Data.WID*0.5 - list.length*ICON_WIDTH*0.5 + i*ICON_WIDTH );
			mc._y = 4;
			mc.gotoAndStop(1);
			mc.cacheAsBitmap = true;
			mc.filters = baseFilters;
//			mc._visible = !fl_lock;
			if ( term.fl_leet ) {
				mc.field.text = "";
				mc.virusId.text = ds.virus.id.toUpperCase();
			}
			else {
				mc.onRelease = callback(onClickSlot,ds);
				mc.field.text = ""+(i+1);
				mc.virusId.text = "";
				mc.virusId._visible = false;
			}
			var a = term.startAnim(A_Move,mc);
			a.fl_killFilters = false;
			a.spd*=0.5;
			a.y-=42;
			ds.mc = mc;
			i++;
		}
		loadIcons();
		updateBubbles();

		// on cache les virus épuisés
		for (ds in list)
			if ( ds.virus.uses==0 )
				ds.mc.smc._alpha = 0;
	}


	public function loadIcons() {
		urlList = new List();
		var me = this;
		for (deck in decks)
			for(ds in deck.content) {
				if ( ds.virus==null )
					continue;
				var mcl = new flash.MovieClipLoader();
				mcl.onLoadComplete = function(mc) {me.onLoadComplete(ds);}
				mcl.onLoadError = onLoadError;
				var url = Manager.PARAMS._iconsUrl+ds.virus.id+".png?v="+Manager.PARAMS._iconsVer;
//				var mc = ds.mc.createEmptyMovieClip("loader",1);
				var  mc = ds.mc.smc;
				mcl.loadClip(url, mc);
				urlList.add({
					mc	: mc,
					url	: url,
				});
			}
	}

	function onLoadComplete(ds:DockSlot) {
	}

	function onLoadError(mc,err) {
		#if debug
			for (e in urlList)
				if (e.mc==mc)
					trace("Failed loading : "+e.url+" err="+err);
		#end
	}

	function getDesc(v:Virus) {
		if ( v.desc==null )
			return "";
		else {
//			d+=Lang.replaceVars(v.desc, {_p:v.power, _s:v.size, _cc:v.cc, _pc:v.power*term.countEffect(UE_Combo)});
			var d = VirusXml.getDesc(v, term.countEffect(UE_Combo));
			var i = "";
			if ( v.cc>0 )
				i+=Lang.fmt.ManaCost({_n:v.cc}) + "\n";
			if ( v.uses!=null )
				i+=Lang.fmt.ChargeRemaining({_n:v.uses}) + "\n";
			if ( i.length>0 )
				d = d+"\n----------------\n"+i;
			return d;
		}
	}

	public function lock() {
		clearPending();
		detachEffects();
		fl_lock = true;
		Col.setPercentColor( root, 65, 0x505336 );
	}
	public function unlock() {
		displayEffects();
		fl_lock = false;
		Col.setPercentColor( root, 0, 0x505336 );
	}

	public function hide() {
		root._visible = false;
		hideSwitcher();
	}

	public function show() {
		if ( term.fs==null )
			showSwitcher();
		root._visible = true;
	}

	public function showSwitcher() {
		swButton._visible = true;
	}

	public function hideSwitcher() {
		swButton._visible = false;
		term.detachCMenu();
	}


	function setPending(p:DockSlot) {
		if ( fl_lock ) return;
		pending = p;
		pending.mc.filters = [
			new flash.filters.GlowFilter(Data.GREEN,1, 2,2, 10, 1, true ),
			new flash.filters.GlowFilter(Data.GREEN,1, 32,32, 1, 1),
		];
	}

	public function clearPending() {
		pending.mc.filters = baseFilters;
		pending = null;
	}

	public function needTarget() {
		return pending!=null;
	}

	public function giveTarget(f:FSNode) {
		if ( fl_lock ) return;
		if ( Progress.isRunning() ) return;
		if ( pending==null ) return;
		term.vman.exec( pending.virus, f );
		onActivate(pending);
		term.fs.setTarget(f);
		clearPending();
	}

	public function giveTargetNode(n:NetNode) {
		if ( fl_lock ) return;
		if ( pending==null ) return;
		term.vman.exec( pending.virus, n );
//		term.fs.setTarget(f);
		clearPending();
	}

//	public function onRestore(v:Virus) {
//		for (ds in slots)
//			if ( ds.virus==v ) {
//				ds.mc._alpha = 100;
//				ds.mc.filters = null;
//			}
//	}


	function displayFile(f:FSNode) {
		var c = f.getContent();
		if ( c!=null ) {
			if ( term.fs!=null )
				term.fs.clearTarget();
			f.displayContent();
		}
	}


	function onMyFiles() {
		if ( !fButton._visible )
			return;
		var options = new Array();
		for (f in term.storage)
			if ( f.getContent()!=null && f.getContent().length>0 )
				options.push({ label:f.name, cb:callback(displayFile, f) });
		term.showCMenu(Manager.DM, fButton._x-5,fButton._y+12, options );
	}

	function onSwitch() {
		if ( !swButton._visible )
			return;
		var options = new Array();
		for (i in 0...decks.length) {
			var d = decks[i];
			var label = d.name;
			if ( i==currentDeck )
				label = "* "+label;
			options.push({ label:label, cb:callback(switchDeck, i) });
		}
		term.showCMenu(Manager.DM, swButton._x+5, swButton._y+12, options );
	}

	function onClickSlot(ds:DockSlot) {
		if (fl_lock) return;
		if (pending==ds) {
			clearPending();
			return;
		}
		if ( pending!=null )
			clearPending();

//		if ( ps.virus.cdTimer>0 )
//			return;

		if ( Progress.isRunning() )
			return;
		if ( ds.virus.target=="_none" ) {
			term.vman.exec(ds.virus);
			onActivate(ds);
		}
		else {
			setPending(ds);
			if ( term.fs.target!=null )
				giveTarget(term.fs.target);
			else
				term.playSound("bleep_03");
		}
		if ( ds.virus.id=="dmgs" )
			Tutorial.play(Tutorial.get.first, "damageExp");
	}

//	public function onKeyShortcut(idx:Int) {
//		if ( fl_lock ) return;
//		if ( idx==0 )
//			idx = 9;
//		else
//			idx--;
//		if ( idx>=slots.length) return;
//		for (ds in slots)
//			if ( ds.hotkey==idx ) {
//				onClickSlot(ds);
//				break;
//			}
//	}

	public function onShortcut(idx:Int) {
		if ( fl_lock ) return;
		if ( idx>=getCurrentDeck().length) return;
		var list = Lambda.array( getCurrentDeck() );
		onClickSlot(list[idx]);
	}

	function onActivate(ds:DockSlot) {
		dm.over(ds.mc);
		if ( pending!=null )
			dm.over(pending.mc);
		var a = term.startAnim(A_Blink,ds.mc);
		var me = this;
		a.cb = function() {
			ds.mc.filters = me.baseFilters;
		}
	}

	function onRollOver(ds:DockSlot) {
		if ( fl_lock ) return;
//		if ( ds.virus.uses==0 )
//			return;
		if ( pending==ds )
			return;
		dm.over(ds.mc);
		if ( pending!=null )
			dm.over(pending.mc);
//		displayEffects();
		ds.mc.filters = [ new flash.filters.GlowFilter(0xffffff,1, 3,3,600) ];
	}

	function onRollOut(ds:DockSlot) {
//		if ( ds.virus.uses==0 )
//			return;
		if ( pending==ds )
			return;
		ds.mc.filters = baseFilters;
	}

	public function updateBubbles() {
		for (ds in getCurrentDeck())
			term.bubble(ds.mc, ds.virus.name, getDesc(ds.virus),-1, callback(onRollOver,ds), callback(onRollOut,ds));
	}

	function detachEffects() {
		for (mc in emcList)
			mc.removeMovieClip();
		emcList = new List();
	}


	public function displayEffects() {
		detachEffects();
		for (e in term.ueffects)
			for (ds in getCurrentDeck())
				if ( e.source!=null && ds.virus==e.source ) {
					var emc : MCField = cast ds.mc.attachMovie("userEffect", "effect_"+Data.UNIQ, Data.UNIQ++);
					emc._x = Math.round(ds.mc._width*0.4);
					emc._y = Math.round(ds.mc._height*0.8);
					emc.gotoAndStop(1);
					emc.field.text = Std.string(e.cpt);
//					emc.field._visible = (e.cpt>1);
					emcList.add(emc);
				}
	}

	public function onStorageChange() {
		fButton._visible = true;
	}

	public function onDepleted(v:Virus) {
		for (ds in getCurrentDeck())
			if ( ds.virus==v )
				term.startAnim(A_FadeOut, ds.mc.smc).spd*=0.3;
	}


	public function update() {
		// affichages pour tuto
		if ( MissionGen.isTutorial(term.mdata) )
			for (ds in getCurrentDeck()) {
				if ( !fl_lock ) {
					if ( Tutorial.at(Tutorial.get.first,"showDock" ) )
						Tutorial.point(Manager.DM, ds.mc._x+16, ds.mc._y+32, 180);
					if ( ds.virus.id=="dmgs" ) {
						if (Tutorial.at(Tutorial.get.first, "showDmgVirus") ||
							Tutorial.at(Tutorial.get.first, "attackGuardian") ||
							Tutorial.at(Tutorial.get.first, "core") )
								Tutorial.point(Manager.DM, ds.mc._x+16, ds.mc._y+32, 180);
					}
					if ( ds.virus.id=="scan1" )
						if ( Tutorial.at(Tutorial.get.second, "scanner") )
							Tutorial.point(Manager.DM, ds.mc._x+16, ds.mc._y+32, 180);
					if ( ds.virus.id=="copy" )
						if ( Tutorial.at(Tutorial.get.third, "copyFile2") )
							Tutorial.point(Manager.DM, ds.mc._x+16, ds.mc._y+32, 180);
				}
			}
	}
}
