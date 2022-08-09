import data.VirusXml;
import data.AntivirusXml;
import Types;

class AntivirMan {
	static public var BOMB_LIMIT = 10;
	static public var DEFENDER_ABSORB = 15;
	static public var SHIELD_ABSORB = 4;
	static public var CSHIELD_ABSORB = 5;
	static public var AV_LIFE = 15;
	static public var CORE_LIFE = 30;
	static public var GUARDIAN_LIFE = 10;


	var term		: UserTerminal;
	public var fast	: Hash<List<FSNode>>;
	var mcList		: Array<flash.MovieClip>;
//	var scanLevel	: Int;

	public var endTurn		: List<Void->Void>;


	public function new(t) {
		term = t;
		mcList = new Array();
		endTurn = new List();
//		scanLevel = 0;
	}

	public function scan(fs:GFileSystem) {
		fast = new Hash();
		for ( f in fs.rawTree )
			if ( f.av!=null )
				register(f);
	}


	public function applyEffects(fs:GFileSystem) {
		if ( systemContains(AntivirusXml.get.mask) ) {
			var list = fast.get(AntivirusXml.get.mask.key);
			for (f in list)
				fs.recursiveAddEffect(f.parent, E_Masked);
		}

		if ( systemContains(AntivirusXml.get.shield) ) {
			var n = fast.get(AntivirusXml.get.shield.key).length;
			for (f in fs.rawTree)
				if ( f.canBeShielded() )
					f.addEffect(E_Shield, n,n);
		}

		if ( systemContains(AntivirusXml.get.paladin) )
			for (f in fs.rawTree)
				if ( !f.fl_folder && f.av==null )
					f.addEffect(E_Immune,1,1);
	}


	function register(f:FSNode) {
		if ( f.hasEffect(E_Disabled) )
			return;
		if ( fast.get(f.av.key)==null )
			fast.set(f.av.key, new List());
		fast.get(f.av.key).push(f);
	}


	public function generate(rseed:mt.Rand,fs:GFileSystem) {
		var diff = fs.getDiff();
		var pool = Lambda.array( Lambda.filter(fs.rawTree, function(f) { return f.av==AntivirusXml.get.avslot; }) );
		var avList = new Array();
		for (av in data.AntivirusXml.ALL)
			if ( av.minLevel<=term.gameLevel )
				avList.push(av);

//		// Anti-virus forcé
//		#if debug
//			avList = [AntivirusXml.get.fantassin];
//		#end

		if ( avList.length<=0 )
			return;

		// génération
		while (diff>0 && pool.length>0) {
			var av = null;
			var tries = 0;
			do {
				av = avList[rseed.random(avList.length)];
				tries++;
			} while ( av.diff>diff && tries<200 );
			if ( tries>=200 )
				break;
			var n = rseed.random(pool.length);
			if ( av==AntivirusXml.get.passwd && pool[n].parent.parent==null )
				continue;
			var file = pool[n];
			file.av = av;
//			file.addResist(D_Corrupt,50);
			file.generateName();
			pool.splice(n,1);
			diff-=av.diff;
		}
	}

	public function unregister(file:FSNode) {
		if ( file.av==null )
			return;

		var old = file.av;

		if (file.av==AntivirusXml.get.shield)
			for(f in term.fs.rawTree)
				f.removeEffect(E_Shield);

		var list = fast.get(file.av.key);
		list.remove(file);
		file.av = null;

		if ( old==AntivirusXml.get.mask ) {
			if ( !parentContains(term.fs.curFolder,old) )
				term.fs.unmaskFolder();
			term.fs.recursiveRemoveEffect(term.fs.curFolder, E_Masked);
		}

		var fl_last = !systemContains(old);
		if ( fl_last )
			onUnregisterLast(old);
//		updateStack( old==AntivirusXml.get.brouilleur && fl_last );
	}

	function onUnregisterLast(av:Antivirus) {
		if (av==AntivirusXml.get.paladin)
			for(f in term.fs.rawTree)
				f.removeEffect(E_Immune);
	}

	function queueAttackAll(av:Antivirus, ?fl_local=false) {
		endTurn.add( callback(attackAll, av, fl_local) );
	}

	function attackAll(av:Antivirus,?fl_local=false) {
		var list = fast.get(av.key);
		for (f in list) {
			if ( !fl_local || fl_local && f.parent==term.fs.curFolder ) {
				if ( f.hasEffect(E_SkipAction) ) {
					f.removeEffect(E_SkipAction);
					term.log( Lang.fmt.AntivirusBlocked({_name:f.name, _av:f.av.key.toUpperCase()}) );
					continue;
				}

				// actions non-détectables
				if ( term.hasEffect(UE_Furtivity) ) {
					logDodge(f);
					continue;
				}
				if ( term.hasEffect(UE_MoveFurtivity) )
					if ( av==AntivirusXml.get.oxy || av==AntivirusXml.get.bigoxy || av==AntivirusXml.get.mine ) {
						logDodge(f);
						continue;
					}
				if ( term.hasEffect(UE_SilentDeath) )
					if ( av==AntivirusXml.get.repurgator || av==AntivirusXml.get.sysdef ) {
						logDodge(f);
						continue;
					}

				var dmg = f.getAttackModified(av);
				if ( dmg>0 ) {
					endTurn.add( callback(onAttackSuccessful, f) );
					logDamage(f.name, f.av, dmg);
					term.damage(dmg);
				}
			}
		}
	}

	function logDodge(f:FSNode) {
		term.log( Lang.fmt.AntivirusDodged({_name:f.name, _av:f.av.key.toUpperCase()}) );
	}

	function logDamage(fname:String, av:Antivirus, n:Int) {
		term.log(
			"["+av.key.toUpperCase()+"] "+
			Lang.format( "AV_"+av.key, {_name:fname} ) +
			" : "+Lang.fmt.AntivirusDamage({_n:n})+".",
			Data.WARNING
		);
	}

	public function getAllByFolder(dir:FSNode, ?av:Antivirus) {
		var result = new List();
		if ( av==null )
			for (k in fast.keys()) {
				var list = fast.get(k);
				for (f in list)
					if ( f.parent==dir )
						result.add(f);
			}
		else
			for (f in fast.get(av.key))
				if ( f.parent==dir )
					result.add(f);

		return result;
	}

	public function folderContains(dir:FSNode, av:Antivirus) {
		var list = fast.get(av.key);
		for (f in list)
			if (f.parent==dir)
				return true;
		return false;
	}

	public function folderContainsAny(dir:FSNode) {
		for (k in fast.keys())
			for (f in fast.get(k))
				if (f.parent==dir)
					return true;
		return false;
	}

	public function parentContains(dir:FSNode, av:Antivirus) {
		var plist = new List();
		while (dir!=null) {
			plist.add(dir);
			dir = dir.parent;
		}
		var list = fast.get(av.key);
		for (f in list)
			if ( plist.remove(f.parent) )
				return true;
		return false;
	}

	public function systemContains(av:Antivirus) {
		return fast.get(av.key).length > 0;
//		for (f in fast.get(av.key))
//			if (!f.hasEffect(E_Ignored))
//				return true;
//		return false;
	}

	public function countDanger() {
		var d = 0;
		for (avk in fast.keys())
			d+= AntivirusXml.ALL.get(avk).diff * fast.get(avk).length;
		return d;
	}


	// *** LISTENERS

	public function onDeleteFile(f:FSNode,?fl_stealth=false) {
		if ( f.av!=null ) {
			var me = this;
			endTurn.add(function() {
				me.term.gainCombo();
			});
			unregister(f);
		}
		if ( f.key=="file.guardian" )
			for (f2 in term.fs.getFilesByKey("file.core"))
				f2.removeEffect(E_CShield);
		if (!fl_stealth) {
			endTurn.add( callback(attackAll, AntivirusXml.get.repurgator, null) );
			if ( f.key=="file.core" || f.key=="file.guardian" || f.key=="file.control" )
				if ( systemContains(AntivirusXml.get.sysdef) )
					endTurn.add( callback(attackAll, AntivirusXml.get.sysdef, null) );
		}
	}

	public function onOpenDir() {
		attackAll(AntivirusXml.get.mine,true);
		attackAll(AntivirusXml.get.oxy);
		attackAll(AntivirusXml.get.bigoxy);
	}

	public function onDisconnect() {
		attackAll(AntivirusXml.get.mine,true);
		attackAll(AntivirusXml.get.oxy);
		attackAll(AntivirusXml.get.bigoxy);
	}

	public function onVirusRun(v:Virus) {
		if ( v==VirusXml.get.cd || v==VirusXml.get.connec || v==VirusXml.get.extrac || v==VirusXml.get.target )
			return;

		// fantassins
		if ( folderContains(term.fs.curFolder, AntivirusXml.get.fantassin) )
			queueAttackAll(AntivirusXml.get.fantassin, true);

		// bombes
		var bomb = AntivirusXml.get.bomb;
		for (f in fast.get(bomb.key)) {
			if ( term.hasEffect(UE_Furtivity) ) {
				term.log( Lang.fmt.AntivirusDodged({_name:f.name, _av:f.av.key.toUpperCase()}) );
				continue;
			}
			f.addEffect(E_Counter);
			var n = f.countEffect(E_Counter);
			if ( n<=BOMB_LIMIT ) {
				if (n==BOMB_LIMIT)
					term.log( Lang.get.Log_BombLast );
				else
					term.log( Lang.fmt.Log_Bomb({_n:n, _max:BOMB_LIMIT}) );
			}
			else
				endTurn.add( callback(onExplodeBomb,f) );
		}
	}

	public function onDamageFile(dmg:Int,f:FSNode) {
		// eject
		if ( folderContains(term.fs.curFolder, AntivirusXml.get.eject) )
			for (f in getAllByFolder(term.fs.curFolder,AntivirusXml.get.eject))
				endTurn.add(callback(onEject,f));
		// tique
		queueAttackAll(AntivirusXml.get.tique);
	}

	function onExplodeBomb(f:FSNode) {
		if ( f.life<=0 )
			return;
		if ( f.hasEffect(E_SkipAction) ) {
			f.removeEffect(E_SkipAction);
			term.log( Lang.fmt.AntivirusBlocked({_name:f.name, _av:f.av.key.toUpperCase()}) );
			return;
		}
		var bomb = AntivirusXml.get.bomb;
		var dmg = f.getAttackModified(bomb);
		if ( dmg>0 ) {
			logDamage(f.name, f.av, dmg);
			term.damage(dmg);
		}
		f.clearEffect(E_Counter);
//		var a = term.startAnim(A_FadeOut,f.mc);
//		a.spd*=0.6;
//		a.cb = function() {
//			f.mc._visible = false;
//		}
//		term.fs.delete(f, a, true);
	}


	function onEject(f:FSNode) {
		if ( f.life<=0 )
			return;

		if ( f.hasEffect(E_SkipAction) ) {
			f.removeEffect(E_SkipAction);
			term.log( Lang.fmt.AntivirusBlocked({_name:f.name, _av:f.av.key.toUpperCase()}) );
			return;
		}

		term.log( Lang.fmt.Ejected({_name:f.name, _av:f.av.key.toUpperCase()}) );
		term.disconnectFS();
	}

	function onAttackSuccessful(f:FSNode) {
		if ( f.hasEffect(E_Revenge) ) {
			f.removeEffect(E_Revenge);
			var p = VirusXml.get.reveng.power;
			term.log( Lang.fmt.RevengeEffect({_av:f.av.key, _v:VirusXml.get.reveng.name, _p:p}) );
			f.damage(p,false);
		}
	}


	public function onEndTurn() {
		while( !endTurn.isEmpty() ) {
			var tmp = endTurn;
			endTurn = new List();
			for (fn in tmp)
				fn();
		}

		term.clearEffect(UE_SilentDeath);
	}


	// *** DISPLAY

//	public function setScanLevel(n:Int) {
//		scanLevel = n;
//		updateStack(true);
//	}
//
//	public function detachStack() {
//		for (mc in mcList)
//			mc.removeMovieClip();
//		mcList = new Array();
//	}
//
//	public function updateStack(?fl_anim=false) {
//		detachStack();
//		if ( scanLevel<=0 )
//			return;
//		if ( term.fs==null )
//			return;
//		var fl_hidden = systemContains(AntivirusXml.get.brouilleur);
//		var total = 0;
//		for (k in fast.keys()) {
//			var list = fast.get(k);
//			if ( list.length==0 )
//				continue;
//			var mc : MCField = cast Manager.DM.attach("logLine",Data.DP_TOP);
//			var av = data.AntivirusXml.ALL.get(k);
//			var v = av.diff*list.length;
//			total+=v;
//			var extra = "";
//			mc.field.text = switch( scanLevel ) {
//				case 1	: k;
//				case 2	: if ( list.length==1 ) k else k+" x "+list.length;
//				case 3	:
//					extra+="\n";
//					for (f in list)
//						extra+=f.getPathString()+"\n";
//					if ( list.length==1 )
//						k
//					else
//						k+" x "+list.length;
//			}
//			#if debug
//				mc.field.text+=" (+"+v+")";
//			#end
//			mc._x = Math.round(Data.WID-5-mc.field.textWidth);
//			mc._y = Math.round(5 + 16*mcList.length);
//			var onOver = function() { mc.field.textColor = 0xffffff; };
//			var onOut = function() { mc.field.textColor = Data.GREEN; };
//			term.bubble(mc, k.toUpperCase(), av.desc+extra, -2, onOver, onOut );
//			mcList.push(mc);
//			if ( fl_anim )
//				term.startAnim(A_Text,mc,mc.field.text);
//		}
//		#if debug
//			var mc : MCField = cast Manager.DM.attach("logLine",Data.DP_TOP);
//			mc.field.text = "TOTAL = "+total+" points";
//			mc._x = Math.round(Data.WID-5-mc.field.textWidth);
//			mc._y = Math.round(5 + 16*mcList.length);
//			mcList.push(mc);
//		#end
//
//	}
}
