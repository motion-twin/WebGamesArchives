import data.AntivirusXml;
import Types;
import mt.bumdum.Lib;
import mt.Timer;

class FSNode {
	public static var ICON_BY_LINE	= 5;


	static var term			: UserTerminal;

	public var fs			: GFileSystem;

	public var mc			: MCFile;
	public var mcIndex		: Int;
	public var id			: Int;
	public var depth		: Int;
	public var parent		: FSNode;
	public var key			: String;
	public var name			: String;
	var owner				: String;
	public var size			: Int;
	public var fl_folder	: Bool;
	public var fl_target	: Bool;
	public var fl_deleted	: Bool;
	public var content		: String;
	public var econtent		: String;
	public var embedData	: String;
	public var av			: Antivirus;
	public var seed			: Int;
	public var sortIndex	: Int;
	public var allowMatrix	: Array<Array<Bool>>;
	public var password		: String;

	public var life			: Int;
	public var lifeTotal	: Int;
	var freezeTimer			: Float;


//	var resists				: Array< {dt:DamageType, v:Int} >;
	var effects				: List<{type:EffectType, cpt:Int}>;
	public var emcList		: Array<MCField>;


	public function new(pterm:UserTerminal, pfs:GFileSystem, p:FSNode, k:String) {
		fs = pfs;
		term = pterm;
		parent = p;
		key = k;
		sortIndex = Data.UNIQ++;

		depth = if(parent==null) 0 else parent.depth+1;
		generateName();
		fl_folder = false;
		fl_target = false;
		fl_deleted = false;
//		avKey = null;
		av = null;
		content = null;
//		resists = new Array();
		effects =  new List();
		emcList = new Array();

		if ( key.indexOf(".antivir")>=0 )
			av = AntivirusXml.get.avslot;
//			avKey = "";

		if ( av==null )
			if ( key=="file.guardian" )
				setLife( AntivirMan.GUARDIAN_LIFE );
			else if ( key=="file.core" ) {
				if ( MissionGen.isTutorial(term.mdata) )
					setLife( AntivirMan.AV_LIFE );
				else
					setLife( AntivirMan.CORE_LIFE );
			}
			else if ( key=="file.control" )
				setLife( AntivirMan.AV_LIFE );
			else
				setLife(1);
		else {
			if (av.key=="bomb")
				setLife(1);
			else
				setLife( AntivirMan.AV_LIFE );
		}
		freezeTimer = 0;
	}


	public function createCopy() {
		term.playSound("bleep_06");
		var f = new FSNode(term, fs, parent, key);
		copyData(f);
		return f;
	}

	public function copyData(f:FSNode) {
		f.id = id;
		f.name = name;
		f.owner = getOwner();
		f.content = getContent();
		f.fl_target = fl_target;
		f.embedData = embedData;
	}


	public function updateInfos() {
		size = 1;
		if ( fl_folder )		size=2;
		if ( ext("video") )		size=5;
		if ( ext("mp3") )		size=2;
		if ( ext("doc") )		size=1;
		if ( ext("pack") )		size=3;
		if ( key=="file.guardian" )	size=1;
		if ( key=="file.core" )		size=2;
		if ( key=="file.control" )	size=1;
	}


	public function generateName() {
		if ( av!=null )
			name = av.key+TD.fsNames.get("ver")+"."+TD.fsNames.get("antivirExt");
		else
			name = TD.fsNames.get(key);
	}


	public function setLife(n:Int) {
		life = n;
		lifeTotal = n;
	}


	function getName() {
		if ( hasEffect(E_Masked) ) {
			var str = "";
			if ( term.hasChipset(data.ChipsetsXml.get.unmask) )
				for (i in 0...name.length)
					if ( (id+i)%3==0 )
						str+=name.charAt(i);
					else
						str+="*";
			else
				for (i in 0...name.length)
					str+="*";
			return str;
		}
		else
			return name;
	}

	public function getOwner() {
		if ( owner==null )
			owner = TD.texts.get("sysadmin");
		return owner;
	}

	public function setOwner(str:String) {
		if ( str==null )
			return;
		owner = str;
	}

	public function getContent() {
		var old = TD.texts.rseed;
		TD.texts.rseed = Data.newRandSeed(seed);
		if ( econtent==null )
			econtent = TD.texts.get("encoded");
		if ( content==null ) {
			TD.texts.set("owner",getOwner());
			if ( ext("doc") )
				content = TD.texts.get("document");
			if ( ext("mail") )
				content = TD.texts.get("mail");
			if ( key=="crime.data" )
				content = TD.texts.get("crimeLog");
			if ( av==AntivirusXml.get.passwd ) {
				TD.texts.set("content",term.fs.mpass);
				content = TD.texts.get("fileSettings");
			}
			if ( key=="inv.game" )
				content = TD.texts.get("inventory");
			if ( key=="money.game" )
				content = TD.texts.get("gold");
			if ( key=="stats.game" )
				content = TD.texts.get("stats");
			if ( key=="file.control" )
				content = TD.texts.get("controlFile");
			if ( key=="file.video" )
				content = TD.texts.get("videoFile");
			if ( key=="file.image" )
				content = TD.texts.get("imageFile");
			if ( key=="file.rar" )
				content = TD.texts.get("rarFile");
		}
		TD.texts.rseed = old;
		if ( ext("pack") )
			return null;
		if ( hasEffect(E_Encoded) )
			return econtent;
		return content;
	}

	public function forceMail(from:String,str:String, ?fl_hasSubject=true) {
		key = "file.mail";
		do {
			name = TD.fsNames.get(key);
		} while ( !fs.checkUnicity(this) );
		setOwner(from);
		TD.texts.set("from",from);
		TD.texts.set("mcontent",str);
		if ( fl_hasSubject )
			content = TD.texts.get("forcedMail");
		else
			content = TD.texts.get("forcedMailNoSubject");
	}

	public function getPathString() {
		var stack = new List();
		var p = if ( fl_folder ) this else parent;
		while (p!=null) {
			if ( p.parent!=null )
				stack.push(p);
			p = p.parent;
		}
		var path = "/";
		for (f in stack)
			path+=f.name+"/";
		return path;
	}

	public function print() {
		return getPathString()+"/"+name+"("+id+")" + if(fl_target) " TARGET" else "";
	}

	public function ext(str:String) {
		if ( str==null )
			return false;
		if ( str.indexOf(".")<0 )
			str = "."+str;
		return name.toLowerCase().indexOf(str)>=0;
	}

	public function hasKeyExt(str:String) {
		if ( str==null )
			return false;
		if ( str.indexOf(".")<0 )
			str = "."+str;
		return key.toLowerCase().indexOf(str)>=0;
	}

//	public function addResist(dt:DamageType, v:Int) {
//		for (r in resists)
//			if ( r.dt==dt )
//				if (v>r.v) {
//					r.v=v;
//					return;
//				}
//		resists.push({
//			dt	: dt,
//			v	: v,
//		});
//	}

	public function detach() {
		for (emc in emcList)
			emc.removeMovieClip();
		mc.removeMovieClip();
	}

	public static function attach(dm:mt.DepthManager, fl_anim:Bool, ?fnode:FSNode, ?index=0) {
		var mc : MCFile = cast dm.attach("file",Data.DP_ITEM);
		mc.gotoAndStop( mc._totalframes );

		var x = (index%ICON_BY_LINE);
		var y = Math.floor(index/ICON_BY_LINE);

		if (false) {
			// 2D
			var fwid = 110;
			var fhei = 90;
			mc._x = -30+Math.floor( fwid*0.5 + x*fwid );
			mc._y = -40 + Math.floor( fhei+y*fhei );
		}
		else {
			// 3D iso
			var hexWid = 170; // 150
			var hexHei = 85; // 75
			mc._x = 5 + x*hexWid*0.5 + y*hexWid*0.5;
			mc._y = 200 + -x*hexHei*0.5 + y*hexHei*0.5;
		}

		var name = fnode.getName();
		mc.field.text = name;
		mc.bar.field._visible = false;
		mc.bar._visible = false;
//		mc.icon.cacheAsBitmap = true;
//		mc.icon2.cacheAsBitmap = true;

//		mc.field._visible = false;
//		if ( !fnode.fl_folder ) {
//			mc.hit.onRollOver = function() { mc.field.textColor=0xffffff; }
//			mc.hit.onRollOut = function() { mc.field.textColor=0xaaaaaa; }
////			mc.hit.onRollOver = function() { mc.field._visible=true; }
////			mc.hit.onRollOut = function() { mc.field._visible=false; }
////			mc.hit.onReleaseOutside = mc.hit.onRollOut;
//			mc.hit.onRollOut();
//		}

		if ( fnode!=null ) {
			fnode.mcIndex = index;
			fnode.mc = mc;
			fnode.redraw();
		}
		else
			mc.field._visible = false;

		if ( fl_anim ) {
			var delay = -0.5-0.15*index-Std.random(150)/100;
			var a = term.startAnim(A_FadeIn, mc, name, delay);
			a.spd *= 1.7;
//			a.cb = callback( term.playSound, "single_03", 0.0 );
			term.startAnim(A_Text, mc, name, delay);
			term.startAnim(A_PlayFrames, mc, name, delay); //.spd *= if(term.fl_lowq) 1.5 else 1;
			for (emc in fnode.emcList)
				term.startAnim(A_FadeIn, emc, delay);
		}
		else {
			var a = term.startAnim(A_FadeIn, mc, -index*0.06);
			a.spd*=1.2;
		}
		return mc;
	}


	public function updateIcon() {
		if ( fl_folder ) {
			// folder
			mc.icon.gotoAndStop("folder");
			var mcc:{>MCField, lockIcon:flash.MovieClip} = cast mc.icon;
			var str =  if ( TD.fsNames.exists(key+"_short") ) TD.fsNames.get(key+"_short") else "";
			mcc.field.text = hasEffect(E_Masked) ? "" : str;
			if ( password!=null || term.avman.folderContains(this, AntivirusXml.get.passwd) ) {
				mcc.lockIcon._visible = true;
				mcc.field._visible = false;
			}
			else {
				mcc.lockIcon._visible = false;
				mcc.field._visible = true;
			}
		}
		else
			if ( hasEffect(E_Masked) )
				// crypted
				mc.icon.gotoAndStop("unknown");
			else
				if ( ext("antivir") ) {
					// antivirus
					mc.icon.gotoAndStop("antivir");
					var mcc : {>MCField, lockIcon:flash.MovieClip} = cast mc.icon;
					if ( av==null )
						mcc.field.text = ":-)";
					else
						mcc.field.text = av.key.substr(0,3).toUpperCase();
//					mc.icon.gotoAndStop("unknownAV");
//					if ( av!=null )
//						mc.icon.gotoAndStop(av.key);
				}
				else {
					// misc file
					mc.icon.gotoAndStop("misc");
					var e = name.split(".")[1];
					if ( key=="file.core" )
						mc.icon.gotoAndStop("core");
					else
						if ( e!=null ) {
							mc.icon.gotoAndStop(e);
	//						var mcc : MCField = cast mc.icon;
	//						mcc.field.text = name.split(".")[1];
						}
				}
		mc.icon.stop();
		mc.icon2.gotoAndStop(mc.icon._currentframe);
	}



//	public function canAggro() {
//		return programs.length>0 && !fl_deleted;
//	}

//	public function startAttack() {
//		curCast = programs[ Std.random(programs.length) ];
//		curCast.timer = curCast.ct;
//	}

//	public function endAttack() {
//		curCast.timer = 0;
////		ctTimer = null;
//		mc.bar2._visible = false;
//	}


//	public function corrupt(n) {
//		if ( isCorrupted() || fl_deleted ) return true;
//		life = Std.int( Math.max(0, life-n) );
//		term.popNumber(-n, mc._x, mc._y-30);
//		redraw();
//		term.startAnim( A_Shake, mc );
//		if ( isCorrupted() ) {
//			term.startAnim(A_Corrupt, mc, name);
//			return true;
//		}
//		else
//			return false;
//	}

	public function damage(base:Int, ?fl_canBeBoosted=true, ?fl_ignoreShield=false, ?fl_canSpread=true) {
		var dmg : Float = base;
		if ( term.hasChipset(data.ChipsetsXml.get.brute) )
			dmg = Math.round(VirusMan.BRUTE_DMG*dmg);
		var extra = "";

		if ( key!="file.core" && Tutorial.at(Tutorial.get.first, "core") ) {
			term.popUp(Lang.get.NotNow);
			return 0;
		}

		// sécurité mode Scout
		if ( term.hasChipset(data.ChipsetsXml.get.scout) )
			if ( key=="file.guardian" || key=="file.core" ) {
				dmg = 0;
				extra = Lang.get.Immune;
			}

		// multiplicateur de dégâts
		if ( fl_canBeBoosted ) {
			if ( term.hasEffect(UE_DamageBurst) ) {
				dmg+=term.getEffectSource(UE_DamageBurst).power;
				term.vman.addEndEvent( function() {term.removeEffect(UE_DamageBurst);} );
			}
			if ( term.hasEffect(UE_Charge) ) {
				dmg*=term.countEffect(UE_Charge);
				term.vman.addEndEvent( function() {term.clearEffect(UE_Charge);} );
			}

//			if ( term.hasEffect(UE_Charge3) ) {
//				dmg*=3*term.countEffect(UE_Charge3);
//				term.vman.addEndEvent( function() {term.clearEffect(UE_Charge3);} );
//			}
		}
		
		if ( hasEffect(E_Exploit) )
			dmg*=VirusMan.EXPLOIT_MUL*countEffect(E_Exploit);

		// shield
		if ( !fl_ignoreShield ) {
			if ( hasEffect(E_Shield) ) {
				var a = AntivirMan.SHIELD_ABSORB*countEffect(E_Shield);
				dmg = Math.max(0, dmg-a);
				extra = Lang.fmt.Shielded({_n:a});
			}
			if ( hasEffect(E_CShield) ) {
				var a = AntivirMan.CSHIELD_ABSORB*countEffect(E_CShield);
				dmg = Math.max(0, dmg-a);
				extra = Lang.fmt.Shielded({_n:a});
			}
		}

		// paladin
		if ( hasEffect(E_Immune) ) {
			dmg = 0;
			extra = Lang.get.Immune;
		}

		// Résistances spécifiques
//		var absorb = AntivirMan.DEFENDER_ABSORB;
//		if ( hasEffect(E_CorrResist) && dt==D_Corrupt ) {
//			dmg = Math.max(0, dmg-absorb );
//			extra = Lang.fmt.CorruptResisted({_n:absorb});
//		}
//		if ( hasEffect(E_SpamResist) && dt==D_Spam ) {
//			dmg = Math.max(0, dmg-absorb );
//			extra = Lang.fmt.SpamResisted({_n:absorb});
//		}
//		if ( hasEffect(E_OverResist) && dt==D_Overwrite ) {
//			dmg = Math.max(0, dmg-absorb );
//			extra = Lang.fmt.OverResisted({_n:absorb});
//		}

		// affichage multiplicateur
		if ( term.hasEffect(UE_Charge) )
			extra+=" [x"+term.countEffect(UE_Charge)+"]";

		// display
		var final = Math.floor(dmg);
		life = Std.int( Math.max(0, life-final) );

		if ( fl_canSpread && final>0 && hasEffect(E_Tag) ) {
			var sdamage = Math.floor( base * countEffect(E_Tag)/100 );
			for (neig in term.fs.getFilesByEffect(E_Tag))
				if ( neig!=this )
					term.vman.addEndEvent( callback(neig.damage, sdamage, true, false, false) );
		}

		if ( mc._name!=null ) {
			var pmc = term.popNumber(term.fs.sdm, -final, extra, mc._x+36, mc._y+15);
			pmc.field.textColor = 0xdb95c2;
			if ( final>0 )
				term.addIconRain(term.fs.sdm, mc);
			if ( final<base ) {
				term.playSound("shield");
				var sh = term.fs.sdm.attach("shield", Data.DP_ITEM);
				sh._x = this.mc._x;
				sh._y = this.mc._y-10;
				term.startAnim( A_FadeRemove, sh );
			}
			redraw();
		}


		term.spam("Damage "+final+" (#"+id+")");

		Tutorial.play(Tutorial.get.first, "shield");

		// delete
		if ( life<=0 ) {
			term.playSound("explode_04");
			if ( mc._name!=null )
				term.log( Lang.fmt.Log_Death({_name:name}) );
			else
				term.log( Lang.fmt.Log_DistantDeath({_name:name, _n:final}) );

			// splash damage ! (librairie piégée)
			if ( hasEffect(E_Splash) && !fl_deleted ) {
				var sdamage = Math.floor( dmg * countEffect(E_Splash)/100 );
				for (neig in term.fs.getFolderFiles(parent))
					if ( neig.key=="file.core" || neig.key=="file.guardian" || neig.av!=null )
						if ( neig!=this && !neig.fl_folder && !neig.fl_deleted )
							term.vman.addEndEvent( callback(neig.damage, sdamage, true, false, true) );
			}

			term.fs.delete(this);
			Tutorial.play(Tutorial.get.first, "coreExposed");
		}
		else
			if ( mc._name!=null) {
				if ( final>0 ) {
					term.playSound("hit_01");
					term.startAnim(A_Shake, mc);
					term.startAnim(A_Blink, mc);
				}
			}
			else
				if ( final>0 )
					term.log( Lang.fmt.Log_DistantDamage({_name:name, _n:final}) );

		if ( final>0 )
			term.avman.onDamageFile(final,this);

		return final;
	}

	public function decode() {
		while ( hasEffect(E_Encoded) )
			removeEffect(E_Encoded);
		term.addIconRain(term.fs.sdm, ["fx_lock"], mc);
		term.startAnim(A_Blink, mc);
		onTarget();
		term.playSound("bleep_06");
	}

	public function changeContent(str:String) {
		content = str;
		if ( mc._name!=null )
			term.fs.onChangedContent(this);
	}

	public function disableAV() {
		addEffect(E_Disabled,1,1);
		term.avman.unregister(this);
		if ( mc._name!=null ) {
			term.startAnim(A_FadeIn, mc);
			term.addIconRain(term.fs.sdm, mc);
			redraw();
		}
	}

	public function getAttackModified(av:Antivirus) {
		var dmg = av.power;

		// anti-oxy
		if ( term.hasChipset( data.ChipsetsXml.get.nox ) )
			if ( av==AntivirusXml.get.oxy || av==AntivirusXml.get.bigoxy )
				dmg = Math.ceil(dmg*0.5);

		// dégâts réduits
		if ( hasEffect(E_Weaken) )
			dmg = Math.round(dmg / (countEffect(E_Weaken)));

		// boost dégâts
		var av = AntivirusXml.get.inferno;
		if ( term.avman.systemContains(av) )
			dmg = Math.floor(dmg * av.power/100);

		return dmg;
	}

	public function extractBonus() {
		if ( fl_deleted )
			return;
		var v = Std.parseInt(content);
		if ( v==null || Math.isNaN(v) )
			return;

		var fxLink = "fx_binary";
		if ( hasEffect(E_PackMana) ) {
			term.playSound("bonus_01");
			term.gainMana(v);
			fxLink = "fx_mana";
			term.popNumber(term.fs.sdm, v, mc._x+36, mc._y+15);
			term.winGoal( "eextra" );
		}
		if ( hasEffect(E_PackMoney) ) {
			term.playSound("bonus_02");
			var vf = term.gainMoney(v);
			fxLink = "fx_money";
			term.popString(term.fs.sdm, null, vf.name, Data.GREEN, mc._x+36, mc._y+15);
			term.winGoal( "mextra" );
		}
//		switch(id%2) {
//			case 0 :
//				term.gainMana(50);
//			case 1 :
//				term.gainMoney(Std.random(25)+25);
//		}
		var a = term.startAnim(A_FadeOut,mc);
		a.spd*=0.6;
		var me = this;
		a.cb = function() {
			me.mc._visible = false;
		}
		term.fs.delete(this,a,true);
		term.addIconRain(term.fs.sdm, [fxLink], 40, mc);
		for (i in 0...10)
			term.addFx(term.fs.sdm, Data.DP_BG, AFX_PlayFrames, "fx_glight", mc._x+35,mc._y+50);

	}

	public function canBeShielded() {
		return !fl_folder && (av!=null || key=="file.core" || key=="file.guardian");
	}

	public function canBeExtracted() {
		return !fl_deleted && !fl_folder && ext("pack");
	}


	public function displayContent() {
		if ( hasEffect(E_Masked) )
			return;
		var c = getContent();
		if ( c!=null ) {
			term.printSide(name,c,this);
			term.fs.logEvent(Lang.fmt.TraceAccess({_name:name}));
			if ( key=="file.video" )
				Live.loadVideo(this);
			if ( key=="file.image" )
				Live.loadImage(this);
		}
	}


	public function onTarget() {
		term.spam("Target #"+id);
		if ( hasEffect(E_Masked) )
			return;
		displayContent();
		if ( key=="file.pack" )
			term.showCMenu(term.fs.sdm, mc._x+35, mc._y+58, term.fs.clearTarget, [
				{ label:Lang.get.MenuExtract, cb:callback(term.vman.exec, data.VirusXml.get.extrac, this, null) },
			]);

		if ( key=="file.guardian" )
			Tutorial.play( Tutorial.get.first, "attackGuardian" );
	}

	public function onLoseTarget() {
		term.detachSide();
	}

//	public function freeze(t:Int) {
//		freezeTimer = Data.SECONDS(t);
//		interrupt();
//	}
//
//	public function unfreeze() {
//		freezeTimer = 0;
//	}

//	public function interrupt() {
//		if ( curCast.timer>0 )
//			curCast.timer = curCast.ct;
//	}


	public function redraw() {
		updateIcon();
		displayEffects();

		var fl_crypted = hasEffect(E_Masked);

		if ( fl_crypted || av==null )
			mc.field.textColor = 0x999999;
		else
			mc.field.textColor = 0xffffff;

		mc.bar._visible = (lifeTotal>1 && (fl_crypted && life<lifeTotal || !fl_crypted));
		mc.bar.smc._xscale = 100 * life/lifeTotal;
		mc.field.text = getName();
		mc._visible = !fl_deleted;

		if ( fl_crypted )
			term.bubble(mc.hit, Lang.fmt.MaskedFile({_v:AntivirusXml.get.mask.key.toUpperCase()}), -2);
		else {
			if ( av!=null )
				term.bubble(mc.hit, av.key.toUpperCase(), av.desc, -2);
			if ( canBeExtracted() )
				term.bubble(mc.hit, Lang.get.Tooltip_Extract,-1);
			if ( key=="file.guardian" )
				term.bubble(mc.hit, Lang.get.Tooltip_Guardian,-1);
			if ( key=="file.core" )
				term.bubble(mc.hit, Lang.get.Tooltip_Core,-1);
			if ( key=="file.control" )
				term.bubble(mc.hit, Lang.get.Tooltip_Control,-1);
			if ( key=="file.log" )
				term.bubble(mc.hit, Lang.get.Tooltip_LogFile,-1);
		}

		if ( life<=0 && lifeTotal>0 ) {
			mc.field.textColor = Data.CORRUPT;
			mc.field.filters = [];
		}
	}



//	public function affect(cp:CombatProg) {
//		switch( cp.fx ) {
//			case C_Damage :
//				unfreeze();
//				life = Std.int( Math.max(0, life-cp.power) );
//				term.popNumber(-cp.power,mc._x,mc._y-25);
//			case C_Heal :
//				life += cp.power;
//				if ( life>lifeTotal )
//					life = lifeTotal;
//				term.popNumber(cp.power,mc._x,mc._y-25);
//			case C_Freeze :
//				freezeTimer = Data.SECONDS(cp.power);
//				interrupt();
//		}
//		redraw();
//
//		// répétitions
//		if ( cp.tics<=0 )
//			return true;
//		else {
//			var repeat : CombatProg = null;
//			for (cp2 in fxot)
//				if(cp2.fx==cp.fx) {
//					repeat = cp2;
//					break;
//				}
//			if ( repeat==null ) {
//				repeat = Reflect.copy(cp);
//				repeat.tics--;
//				fxot.push(repeat);
//			}
//			repeat.tics--;
//			repeat.timer = repeat.tt;
//			return false;
//		}
//	}


//	function run(cp:CombatProg) {
//		switch( cp.fx ) {
//			case C_Damage :
//				term.damage(cp.power);
//			case C_Heal :
//				var list = Lambda.filter(term.fs.combat, function(f) {
//					return f.lifeTotal>0 && f.life/f.lifeTotal<=0.5;
//				});
//				if ( list.length==0 )
//					list = Lambda.filter(term.fs.combat, function(f) {
//						return f.lifeTotal>0 && f.life<f.lifeTotal;
//					});
//				var flist =
//					if ( list.length==0 )
//						term.fs.combat;
//					else
//						Lambda.array(list);
//				var f = flist[ Std.random(flist.length) ];
//				f.affect(cp);
//			case C_Freeze :
//				// TODO
//		}
//	}


//	public function updateCombat() {
//		if ( fl_deleted )
//			return false;
//
//		if ( freezeTimer>0 ) {
//			mc.bar2._visible = false;
//			freezeTimer-=1;
//			mc.field.textColor = 0x54e0e0;
//			if( freezeTimer<=0 )
//				unfreeze();
//			else
//				return true;
//		}
//
//		var i = 0;
//		while (i<fxot.length) {
//			var cp = fxot[i];
//			cp.timer-=Timer.tmod;
//			if ( cp.timer<=0 ) {
//				if ( affect(cp) ) {
//					fxot.splice(i,1);
//					i--;
//				}
//			}
//			i++;
//		}
//
//		mc.field.textColor = 0xff0000;
//		curCast.timer -= Timer.tmod;
//
//		mc.bar2._visible = true;
//		mc.bar2.smc._xscale = 100 * (1 - curCast.timer/curCast.ct);
//
//		if ( curCast.timer<=0 ) {
//			curCast.timer = 0;
//			run(curCast);
//			startAttack();
//		}
//
//		return true;
//	}


	public function hasEffect(et:EffectType) {
		for (e in effects)
			if ( e.type==et )
				return true;
		return false;
	}

	public function countEffect(et:EffectType) {
		var n = 0;
		for (e in effects)
			if ( e.type==et )
				return e.cpt;
		return 0;
	}


	public function addEffect(et:EffectType, ?cpt=1, ?max=100) {
		if ( cpt>max )
			cpt = max;
		for (e in effects)
			if ( e.type==et ) {
				e.cpt+=cpt;
				if ( e.cpt>max )
					e.cpt = max;
				displayEffects();
				return;
			}
		effects.push({
			type	: et,
			cpt		: cpt,
		});
		displayEffects();
	}

	public function removeEffect(et:EffectType) {
		if ( effects.length==0 )
			return;
		for (e in effects)
			if ( e.type==et ) {
				e.cpt--;
				if ( e.cpt<=0 )
					effects.remove(e);
			}
		displayEffects();
	}

	public function clearEffect(et:EffectType) {
		while (hasEffect(et))
			removeEffect(et);
	}


	public function getEffectDesc(et:EffectType) {
		return switch (et) {
			case E_SkipAction	: Lang.get.E_SkipAction;
			case E_Masked		: "E_Masked";
			case E_Shield		: Lang.fmt.E_Shield({_n:AntivirMan.SHIELD_ABSORB*countEffect(E_Shield)});
			case E_Gathered		: Lang.get.E_Gathered;
			case E_Disabled		: Lang.get.E_Disabled;
			case E_Immune		: Lang.get.E_Immune;
			case E_CShield		: Lang.fmt.E_CShield({_n:AntivirMan.CSHIELD_ABSORB*countEffect(E_CShield)});
			case E_Counter		: Lang.fmt.E_Counter({_n:countEffect(E_Counter),_total:AntivirMan.BOMB_LIMIT});
			case E_PackMoney	: Lang.get.E_PackMoney;
			case E_PackMana		: Lang.get.E_PackMana;
			case E_PackLife		: Lang.get.E_PackLife;
			case E_Revenge		: Lang.get.E_Revenge;
			case E_Weaken		: Lang.fmt.E_Weaken({_f:countEffect(E_Weaken)});
			case E_Encoded		: Lang.fmt.E_Encoded({_n:countEffect(E_Encoded)});
			case E_Exploit		: Lang.fmt.E_Exploit({_f:VirusMan.EXPLOIT_MUL});
			case E_Copy			: Lang.get.E_Copy;
			case E_Corrupt		: Lang.get.E_Corrupt;
			case E_Dot			: Lang.fmt.E_Dot({_n:countEffect(E_Dot)});
			case E_DotLength	: "E_DotLength";
			case E_Splash		: Lang.fmt.E_Splash({_n:countEffect(E_Splash)});
			case E_Tag			: Lang.fmt.E_Tag({_n:countEffect(E_Tag)});
			case E_Mission		:
				var v = term.vman.getMissionVirus();
				if ( v.name==Lang.get.CustUp )
					Lang.get.UploadedFile;
				else
					v.name;
			case E_Target		: MissionGen.getMissionEffectName(term.mdata);
		}
	}

	public function displayEffects() {
		for (emc in emcList)
			emc.removeMovieClip();
		emcList = new Array();
		if ( mc._name==null || hasEffect(E_Masked) )
			return;
		for (e in effects) {
			var frame =
				switch(e.type) {
					case E_SkipAction	: 1;
					case E_Masked		: null;
					case E_Shield		: 3;
					case E_Gathered		: null;
					case E_Disabled		: 19;
					case E_Immune		: 4;
					case E_CShield		: 8;
					case E_Counter		: 6;
					case E_PackMoney	: 11;
					case E_PackMana		: 12;
					case E_PackLife		: 13;
					case E_Revenge		: 16;
					case E_Weaken		: 18;
					case E_Encoded		: 10;
					case E_Exploit		: 7;
					case E_Copy			: 2;
					case E_Mission		: 15;
					case E_Target		: 17;
					case E_Corrupt		: 5;
					case E_Dot			: 14; // TODO
					case E_Splash		: 14;
					case E_Tag			: 9;
					case E_DotLength	: null;
				}
			if ( frame==null )
				continue;
			var emc : MCField = cast mc.attachMovie("effect","effect_"+Data.UNIQ, Data.UNIQ++);
			emc.gotoAndStop(frame);
			emc._x = 18*emcList.length;
			emc._y = 50;
			emc.field.text = ""+e.cpt;
			emc.field._visible = (e.cpt>1);
//			emc.field._width = emc.field.textWidth+5;
			var over = function() {
				emc.filters = [ new flash.filters.GlowFilter(0xffffff,1, 3,3, 600) ];
			}
			var out = function() {
				emc.filters = [];
			}
			term.bubble( emc, getEffectDesc(e.type),over,out );
			emcList.push(emc);
		}
	}
}

