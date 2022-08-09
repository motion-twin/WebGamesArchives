import Types;
import data.AntivirusXml;
import data.VirusXml;
import data.ChipsetsXml;
import WinAppMap;
import GNetwork;

typedef F = FSNode;
typedef N = NetNode;

class VirusMan {
	static public var EXPLOIT_MUL = 1.5;

	static public var BRUTE_CC = 1.3;
	static public var BRUTE_DMG = 1.5;

	var term		: UserTerminal;
	var virus		: Virus;
	var endTurn		: List<Void->Void>;


	public function new(t:UserTerminal) {
		term = t;
		endTurn = new List();
	}

	public function exec(v:Virus, ?f:F, ?n:N) {
		if ( Progress.isRunning() ) return;

		virus = v;
		if ( virus.target!="_net" && term.isDisabled() )
			return;

		var method = Reflect.field(this, "_"+virus.id);
		try {
			term.spam("Running "+v.id+"...");
			if ( virus.target=="_none" ) {
				f = null;
				n = null;
			}
			if ( v.uses==0 )
				throw Lang.get.NoCharge;
			var cc = v.cc;
			if ( v.cat=="damage" && term.hasChipset(data.ChipsetsXml.get.brute) )
				cc = Math.round(BRUTE_CC*cc);
			if ( term.mana<cc )
				throw Lang.get.NotEnoughMana;
			if ( virus==VirusXml.get.cd )
				term.fs.logEvent(Lang.fmt.TraceCD({_name:f.name}));
			else
				term.fs.logEvent(Lang.fmt.TraceVirus({_name:virus.name, _id:virus.id}));
			if ( virus.target=="_none" ) {
				Reflect.callMethod(this,method,[]);
			}
			else {
				if ( f!=null ) {
					// target file
					if ( f.fl_deleted )
						throw Lang.get.InvalidTarget;
					if ( virus.target=="_file" && f.fl_folder )
						throw Lang.get.InvalidTarget;
					if ( virus.target=="_folder" && !f.fl_folder )
						throw Lang.get.InvalidTarget;
					Reflect.callMethod(this,method,[f]);
					return;
				}
				if ( n!=null ) {
					if ( virus.target!="_net" ) throw Lang.get.InvalidTarget;
					if ( !term.net.canReach(n) ) throw ""; //Lang.get.CantReachNode;
					Reflect.callMethod(this,method,[n]);
					return;
				}
			}
	}
		catch(e:String) {
			if (e!="")
				term.popUp(e);
		}
	}


	public function commandLine(str:String) {
		if ( term.fs==null )
			throw "illegal call";
		if ( str==null )
			throw null;

		// nettoyage string
		str = Data.trimSpaces(str);
		str = StringTools.replace(str, "\t", " ");
		while ( str.length>0 && str.indexOf("  ") >= 0 )
			str = StringTools.replace(str, "  ", " ");
		if ( str.length==0 )
			throw null;

		// aliases
		var words = str.split(" ");
		for (from in term.aliases.keys())
			for (i in 0...words.length) {
				if ( words[i].toLowerCase()==from )
					words[i] = term.aliases.get(from);
		}
		str = words.join(" ");

		// récupération du virus
		var v : Virus = null;
		var end = str.indexOf(" ");
		if ( end<0 )
			end = 999;
		var virusId = str.substr( 0, end ).toLowerCase();
		for (v2 in term.dock.getCurrentViruses())
			if ( v2.id==virusId && (v2.uses==null || v2.uses>0) ) {
				v = v2;
				break;
			}
		if ( v==null ) {
			// virus qui n'est pas dans le Dock ? (cd, exit, ...)
			for ( v2 in term.virList )
				if ( v2.id==virusId && VirusXml.isHidden(v2) ) {
					v = v2;
					break;
				}
			if ( v==null )
				throw Lang.get.UnknownVirus;
		}


		// nom du fichier ciblé
		var fname = str.substr( end+1 );
		var f : FSNode = null;
		if ( fname.length==0 )
			f = term.fs.target;
		else
			if ( fname==".." ) {
				f = term.fs.curFolder.parent;
				if ( f==null || v.target!="_folder" )
					throw Lang.get.InvalidTarget;
			}
			else {
				f = term.fs.getFile(fname);
				if ( f==null )
					throw Lang.get.FileNotFound;
			}

		// lancement
		term.fs.focus(f.mcIndex);
		exec(v, f);
	}


	public function check() {
		var list = Type.getInstanceFields(VirusMan);
		var err = new Array();
		for (e in VirusXml.ALL) {
			if ( e.id.length>6 )
				err.push("ID is too long : "+e.id);
			if ( !list.remove("_"+e.id) )
				err.push("Virus not implemented : "+e.id);
		}
		for (m in list)
			if ( m.charAt(0)=="_" )
				err.push("Unknown virus implementation : "+m);
		if ( err.length>0 )
			throw err.join("\n")+"\n";
	}


	function getCT(?f:F) : Float {
		var ct = 1.0 / term.getSpeed();
		if ( f!=null )
			ct *= f.size;
		return ct;
	}



	function start( ct:Float, cb:UserTerminal->Virus->Void ) {
		var me = this;
		if (ct==null)
			ct = getCT();
		if ( term.fl_leet && virus.target!="_net" )
			ct = 0.1;

		// son
		switch(virus.target) {
			case "_net" :
				me.term.playSound("bleep_05");
				me.term.playSound("modem_03", Std.random(200)/100);
			case "_folder" :
				me.term.playSound("bleep_04");
			default :
				me.term.playSound("bleep_01");
		}

		// démarrage après barre de progression
		Progress.start( ct, function() {
			if ( me.virus.uses!=null ) {
				me.virus.uses--;
				if ( me.virus.uses==0 )
					me.term.dock.onDepleted(me.virus);
			}
			cb(me.term, me.virus);

			me.term.checkMission();
			me.term.spam(me.virus.id+" OK");
			me.term.avman.onVirusRun(me.virus);
			me.term.decayLog();
			me.term.hideCompletion();
			me.term.dock.updateBubbles();

			// perte furtivité
			if ( me.term.hasEffect(UE_Furtivity) )
				me.term.avman.endTurn.add( function() {
					me.term.removeEffect(UE_Furtivity);
					me.term.log( Lang.fmt.RemainingFurtivity({_n:me.term.countEffect(UE_Furtivity)}) );
				});
				
			if ( me.virus.cat=="damage" && me.term.hasChipset(data.ChipsetsXml.get.brute) )
				me.term.loseMana( Math.round(me.virus.cc*BRUTE_CC) );
			else
				me.term.loseMana( me.virus.cc );
		}, virus.name, if(ct>=3) BA_Slow else BA_Normal );
		term.detachBubble();
	}

//	function recursiveAVScan(parent:F) {
//		var list = new Array();
//		for (f in term.fs.getFolderFiles(parent)) {
//			if ( f.fl_folder )
//				list = list.concat(recursiveAVScan(f));
//			if ( f.avKey!=null && f.av!=null && !f.fl_deleted )
//				list.push(f);
//		}
//		return list;
//	}

	public function canBeDamaged(f:FSNode) {
		if ( term.hasChipset(data.ChipsetsXml.get.scout) )
			if ( f.key=="file.core" || f.key=="file.guardian" )
				throw Lang.get.NotInScoutMode;
		return !f.fl_deleted && f.life>0 && !f.fl_folder;
	}


	// *** CALLBACKS ***

	public function onEndTurn() {
		while( !endTurn.isEmpty() ) {
			var tmp = endTurn;
			endTurn = new List();
			for (fn in tmp)
				fn();
		}
	}

	public function onTick(t) {
		if ( t%5==0 )
			for (f in term.fs.rawTree)
				if ( f.hasEffect(E_Dot) ) {
					f.damage( f.countEffect(E_Dot) );
					f.removeEffect(E_DotLength);
					if ( !f.hasEffect(E_DotLength) )
						f.clearEffect(E_Dot);
				}
	}


	public function addEndEvent(cb:Void->Dynamic) {
		endTurn.add(cb);
	}


	// *** MISSIONS ***
	public function getMissionVirus() {
		if ( term.mdata==null ) {
			Manager.fatal("getMissionVirus : NO MISSION");
			return null;
		}
		var v = data.VirusXml.get.cust;
		switch(term.mdata._type) {
			case _MSpy(name) :
				v.name = Lang.get.CustSpy;
				v.desc = Lang.get.CustSpyDesc;
				v.uses = null;
			case _MCompromiseMail(owner) :
				v.target = "_none";
				v.name = Lang.get.CustUp;
				v.desc = Lang.get.CustUpDesc;
			case _MFalsifyCam(sector) :
				v.target = "_none";
				v.name = Lang.get.CustVideo;
				v.desc = Lang.get.CustVideoDesc;
				v.uses = null;
			case _MSpyCam :
				v.name = Lang.get.CustSpy;
				v.desc = Lang.get.CustSpyDesc;
				v.uses = null;
			case _MArrest(name) :
				v.target = "_none";
				v.name = Lang.get.CustUp;
				v.desc = Lang.get.CustUpDesc;
			case _MCorruptDisplay(place) :
				v.target = "_none";
				v.name = Lang.get.CustUp;
				v.desc = Lang.get.CustUpDesc;
			case _MDeliverFile(pk,pn,file,to) :
				v.target = "_none";
				v.name = Lang.get.CustUp;
				v.desc = Lang.get.CustUpDesc;
			case _MOverwriteFiles(owner,ext) :
				v.target = "_none";
				v.name = Lang.get.CustOverwrite;
				v.desc = Lang.fmt.CustOverwriteDesc({_ext:ext.toUpperCase()});
				v.uses = null;
			case _MGameHack(g,s,c) :
				v.name = Lang.get.CustGame;
				v.desc = Lang.get.CustGameDesc;
				v.uses = null;
			case _MInfectNet(vname) :
				v.name = vname;
				v.desc = Lang.get.CustVirusDesc;
				v.uses = null;
			case _MGetVirus(vname,ext,n) :
				v.name = Lang.get.CustVExtract;
				v.desc = Lang.fmt.CustVExtractDesc({_ext:ext.toUpperCase()});
				v.uses = null;
			case _MTV(tf,tt) :
				v.name = Lang.get.CustRep;
				v.desc = Lang.get.CustRepDesc;
				v.uses = null;
			default :
				v = null;
		}
		return v;
	}


	function _cust(f:F) {
		if ( getMissionVirus()==null )
			throw Lang.get.InvalidTarget;

		if ( term.avman.systemContains(AntivirusXml.get.couveuse) )
			throw Lang.get.Couveuse;

		if ( f.hasEffect(E_Encoded) || f.hasEffect(E_Masked) )
			throw Lang.get.Crypted;

		var len = 2.0;
		switch(term.mdata._type) {
			case _MFalsifyCam(sector) :
				var n = term.fs.countFilesByExt(term.fs.curFolder,"video");
				if ( n<=0 )
					throw Lang.fmt.NeedInFolder({_ext:"VIDEO"});
				len = n*0.75;
			case _MOverwriteFiles(owner,ext) :
				var n = term.fs.countFilesByExt(term.fs.curFolder,ext);
				if ( n<=0 )
					throw Lang.fmt.NeedInFolder({_ext:ext});
				len = n*0.50;
			case _MCorruptDisplay(place) :
				len = 4;
			case _MGameHack(g,s,c) :
				if ( !f.ext("game") )
					throw Lang.fmt.NeedExt({_ext:"GAME"});
				if ( f.hasEffect(E_Mission) )
					throw Lang.get.AlreadyDone;
			case _MInfectNet(v) :
				if ( !f.ext("control") )
					throw Lang.fmt.NeedExt({_ext:"CONTROL"});
			case _MSpy(name) :
				if ( !f.ext("coeur") )
					throw Lang.fmt.NeedExt({_ext:"COEUR"});
				if ( f.hasEffect(E_CShield) )
					throw Lang.get.CoreProtected;
			case _MSpyCam :
				if ( !f.ext("coeur") )
					throw Lang.fmt.NeedExt({_ext:"COEUR"});
			case _MGetVirus(vname,ext,n) :
				if ( !f.hasEffect(E_Target) )
					throw Lang.fmt.NotInfected({_vname:vname});
			case _MTV(tf,tt) :
				if ( f.key!="tvprog.data" )
					throw Lang.get.NeedTvProg;
				if ( !term.hasFileByOwner("mission") )
					throw Lang.fmt.NeedTvCopy({_from:tf});
				len*=0.6;
			case _MDeliverFile(pk,pn,file,to) :
				if ( term.fs.owner!=to || term.fs.curFolder.key!=pk )
					throw Lang.get.NotThisFolder;
			default :
		}

		start(getCT(f)*len, function(t,v) {
			t.playSound("bleep_06");
			switch(t.mdata._type) {
				case _MCompromiseMail(owner) :
					f = t.fs.uploadFile("file.mail");
					TD.texts.set("from",TD.texts.get("unknownSender"));
					TD.texts.set("mcontent",TD.texts.get("dangerousMail"));
					f.changeContent( TD.texts.get("forcedMail") );
				case _MFalsifyCam(sector) :
					for (f in t.fs.getFilesByExt(t.fs.curFolder,"video"))
						f.addEffect(E_Mission);
				case _MArrest(name) :
					f = t.fs.uploadFile("crime.data");
					f.setOwner(name);
					f.name = f.getOwner()+".data";
					TD.texts.set("owner",f.getOwner());
					f.changeContent( TD.texts.get("crimeLog") );
				case _MCorruptDisplay(place) :
					for (i in 0...Std.random(7)+5) {
						var pf = t.fs.uploadFile("playlist.subversive.data");
						pf.addEffect(E_Mission);
					}
				case _MDeliverFile(pk,pn,file,to) :
					f = t.fs.uploadFile("secret.doc");
					f.addEffect(E_Encoded,6+Std.random(4));
				case _MOverwriteFiles(owner,ext) :
					for (f in t.fs.getFilesByExt(t.fs.curFolder,ext))
						if ( !f.hasEffect(E_Mission) ) {
							f.addEffect(E_Mission);
							f.changeContent( TD.texts.get("hackerSpam") );
						}
				case _MGetVirus(vname,ext,total) :
					f.removeEffect(E_Target);
					t.missionCpt++;
//					var cpt = 0;
//					var list = t.fs.getFilesByExt(ext,true);
//					if ( total>list.length )
//						total = list.length;
//					for (f in list)
//						if ( !f.hasEffect(E_Target) )
//							cpt++;
					var pct = Math.floor(Math.min(t.missionCpt/total,1)*100);
					t.log( Lang.fmt.ExtractedVirus({_pct:pct,_vname:vname}) );
					f = null;
				case _MGameHack(g,s,c) :
					if ( f.key=="inv.game" )
						f.changeContent( TD.texts.get("bigInventory") );
					if ( f.key=="money.game" )
						f.changeContent( TD.texts.get("lotsGold") );
					if ( f.key=="stats.game" )
						f.changeContent( TD.texts.get("bigStats") );
				case _MTV(tf,tt) :
					var name = "";
					for(sf in t.storage)
						if(sf.getOwner()=="mission")
							name = sf.name;
					f.name = name+" ["+Std.random(9999)+"]";
					f.redraw();
				default :
			}
			if ( f!=null ) {
				f.addEffect(E_Mission);
				t.addIconRain(t.fs.sdm, f.mc);
			}
		});
	}



	// *** IMPLÉMENTATION : NETWORK

	function _connec(n:N) {
		if ( n.type==Entrance ) {
			term.logout();
			return;
		}

		if ( term.isDisabled() )
			throw term.getDisableReason();

		if ( !n.system.canConnect() )
			throw Lang.get.InvalidTarget;

		if ( term.net.isShielded(n) )
			throw Lang.get.SystemLocked;

		var mc = Manager.DM.attach("pop",Data.DP_FX);
		Manager.loading( Lang.fmt.ConnectingPopUp({_ip:n.ip}) );
		if ( n.system.fl_crashed )
			term.startAnim( A_Connect, mc, n.ip, true ).data = -1;
		else
			term.startAnim( A_Connect, mc, n.ip, true );
		term.log(Lang.get.Log_Connecting);

		start(getCT()*2, function(t,v) {
			t.net.connect(n);
			t.fs.logEvent(Lang.fmt.TraceConnect({_name:t.username}));
			Tutorial.play( Tutorial.get.third, "openSys" );
			Tutorial.play( Tutorial.get.third, "copyFile2" );
		} );
	}

	// *** IMPLÉMENTATION : FILE

	function _exit(f:F) {
		if ( term.fs.curFolder.parent!=null )
			throw Lang.get.OnlyInRoot;

		if ( !Tutorial.reached( Tutorial.get.first, "end" ) ) {
			term.popUp(Lang.get.NotNow);
			throw "";
		}
		if ( !Tutorial.reached( Tutorial.get.second, "userProfile" ) ) {
			term.popUp(Lang.get.NotNow);
			throw "";
		}

		if ( term.avman.folderContains(term.fs.curFolder, AntivirusXml.get.glue ) )
			if ( !term.hasEffect(UE_Furtivity) && !term.hasEffect(UE_MoveFurtivity) )
				throw term.popUp(Lang.get.CantGetOut);

		start(0.1, function(t,v) {
			Tutorial.play( Tutorial.get.second, "nowExit" );
			t.fs.focus(0);
			t.disconnectFS();
		});
	}

	function _target(f:F) {
		start(0.1, function(t,v) {
			t.fs.setTarget(f);
		});
	}

	function _cd(f:F) {
		if ( !f.fl_folder ) throw Lang.get.NeedFolder;
		if ( f.password!=null || term.avman.folderContains(f, AntivirusXml.get.passwd) ) {
			term.askPass(f);
			throw "";
		}
		if ( !Tutorial.reached(Tutorial.get.second, "userProfile") )
			throw Lang.get.NotNow;
		if ( Tutorial.reached(Tutorial.get.third, "killCore") && !Tutorial.reached(Tutorial.get.third, "bypassed") )
			throw Lang.get.NotNow;
		if ( !Tutorial.reached(Tutorial.get.first, "cd") )
			throw Lang.get.NotNow;
		if ( !Tutorial.reached(Tutorial.get.second, "userProfile") )
			throw Lang.get.NotNow;
		if ( f==term.fs.curFolder.parent && !Tutorial.reached(Tutorial.get.first, "end") )
			throw Lang.get.NotNow;
		if ( term.avman.folderContains(term.fs.curFolder, AntivirusXml.get.glue) )
			if ( !term.hasEffect(UE_Furtivity) && !term.hasEffect(UE_MoveFurtivity) )
				throw Lang.get.CantGetOut;
		term.startAnim( A_StrongBlink, f.mc.icon );

		var t = getCT()*0.6;
		if ( f==term.fs.curFolder.parent || MissionGen.isTutorial(term.mdata) )
			t*=0.5;

		start(t, function(t,v) {
			t.fs.openFolder(f);
			if ( f.parent==null )
				Tutorial.play( Tutorial.get.second, "exit2" );
			Tutorial.play( Tutorial.get.first, "core" );
			Tutorial.play( Tutorial.get.second, "waitDelete" );
			Tutorial.play( Tutorial.get.third, "killCore" );
			if ( t.hasEffect(UE_MoveFurtivity) ) {
				t.removeEffect(UE_MoveFurtivity);
				t.log( Lang.fmt.RemainingMoveFurtivity({_n:t.countEffect(UE_MoveFurtivity)}) );
			}
		});
	}

	function _reboo1(f:F) {
		//if ( term.avman.systemContains(AntivirusXml.get.sysdef) )
			//throw Lang.get.RebootBlocked;
		//start(getCT(f), function(t,v) {
			//t.fs.reboot();
		//});
		if ( term.avman.systemContains(AntivirusXml.get.sysdef) )
			throw Lang.get.RebootBlocked;
		start(getCT(f), function(t,v) {
			for (lk in t.avman.fast.keys()) {
				var list = t.avman.fast.get(lk);
				for (file in list)
					file.addEffect(E_SkipAction, 3,3);
			}
			t.fs.reboot();
		});
	}

	function _reboo2(f:F) {
		if ( term.avman.systemContains(AntivirusXml.get.sysdef) )
			throw Lang.get.RebootBlocked;
		start(getCT(f), function(t,v) {
			for (lk in t.avman.fast.keys()) {
				var list = t.avman.fast.get(lk);
				for (file in list) {
					file.addEffect(E_SkipAction, 3,3);
					file.addEffect(E_Exploit, 1,1);
				}
			}
			t.fs.reboot();
		});
	}

	function _dmgs(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		start(getCT(f)*0.2, function(t,v) { f.damage(v.power); });
	}
	function _dmgm(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		start(getCT(f)*0.35, function(t,v) { f.damage(v.power); });
	}
	function _dmgl(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		start(getCT(f)*0.7, function(t,v) { f.damage(v.power); });
	}
	function _dmgxl(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		start(getCT(f), function(t,v) { f.damage(v.power); });
	}
	function _zone(f:F) {
		var list = term.avman.getAllByFolder(term.fs.curFolder);
		if ( list.length==0 ) throw Lang.get.NoAntivirusInFolder;
		start(getCT(f)*0.6, function(t,v) {
			for(f2 in list)
				f2.damage(v.power);
		});
	}
	function _dshld(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		start(getCT(f)*0.3, function(t,v) { f.damage(v.power,true,true); });
	}
	function _clone(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		var list = term.avman.getAllByFolder(term.fs.curFolder,f.av);
		start(getCT(f)*0.6, function(t,v) {
			for(f2 in list)
				f2.damage(v.power);
		});
	}

	function _avdmg1(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		start(getCT(f)*0.3, function(t,v) { f.damage(v.power); });
	}

	function _avdmg2(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		start(getCT(f)*0.3, function(t,v) { f.damage(v.power); });
	}

	function _fdmg(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av!=null ) throw Lang.get.NoAV;
		start(getCT(f)*0.15, function(t,v) { f.damage(v.power); });
	}

	function _dsilen(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		start(getCT(f)*1, function(t,v) {
			t.addEffect(UE_SilentDeath);
			f.damage(v.power);
		});
	}

	function _dsile2(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		start(getCT(f)*1, function(t,v) {
			t.addEffect(UE_SilentDeath);
			t.addEffect(UE_Furtivity);
			f.damage(v.power);
		});
	}

	function _dot1(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		start(getCT(f)*0.1, function(t,v) {
			f.addEffect(E_Dot, v.power);
			f.addEffect(E_DotLength, v.info);
		});
	}

	function _dot2(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		start(getCT(f)*0.1, function(t,v) {
			f.addEffect(E_Dot, v.power);
			f.addEffect(E_DotLength, v.info);
		});
	}

//	function _over2(f:F) {
//		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
//		start(function(t,v) { f.damage(p.power, D_Overwrite); });
//	}

	function _stun1(f:F) {
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		start(getCT(f), function(t,v) { f.addEffect(E_SkipAction, v.power); });
	}

	function _stun2(f:F) {
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		start(getCT(f), function(t,v) { f.addEffect(E_SkipAction, v.power); });
	}

	function _debug(f:F) {
		#if debug
			term.addEffect(virus,UE_Furtivity, virus.power);
			term.fs.crash();
		#else
			throw "error";
		#end
	}

	function _fdebug(f:F) {
		#if debug
			start(0.1, function(t,v) { f.damage(2); });
		#else
			throw "error";
		#end
	}
	function _copy(f:F) {
		if ( term.avman.systemContains(AntivirusXml.get.couveuse) )
			throw Lang.get.Couveuse;
		if ( f.fl_folder || f.av!=null )
			throw Lang.get.InvalidTarget;
		if ( !canBeDamaged(f) )
			throw Lang.get.InvalidTarget;
		if ( f.hasEffect(E_Masked) || f.hasEffect(E_Encoded) )
			throw Lang.get.CantCopyCrypted;

		if ( f.key=="file.pack" )
			throw Lang.get.CantCopyPack;

		if ( f.key=="file.log" )
			throw Lang.get.CantCopyLog;

		if ( f.hasEffect(E_Copy) )
			throw Lang.get.Useless;

		if ( term.storage.length>=term.getMaxStorage() )
			throw Lang.fmt.DiskFull({_max:term.getMaxStorage()});

		start(getCT(f), function(t,v) {
			t.copyFile(f);
			f.addEffect(E_Copy);
			t.log( Lang.fmt.Log_Copied({_name:f.name, _n:t.storage.length, _max:t.getMaxStorage()}) );
			if ( f.fl_target )
				Tutorial.play( Tutorial.get.third, "copied" );
		});
	}

	function _unmask(f:F) {
		if ( !f.hasEffect(E_Masked) ) throw Lang.get.Useless;
		start(getCT(f)*0.3, function(t,v) {
			if ( t.hasChipset(ChipsetsXml.get.deciph) )
				t.gainMana( Math.floor(v.cc*0.5), true );
			while (f.hasEffect(E_Masked))
				f.removeEffect(E_Masked);
			var a = t.startAnim(A_Decrypt, f.mc, f.name);
			a.cb = callback(t.fs.onUnmask,f);
		});
	}

	function _scan1(f:F) {
		start(getCT(f)*0.4, function(t,v) {
			var a = new WinAppMap(t);
			a.start();
			a.setTitle(v.name);
			a.showMap(t.fs, 1);
			Tutorial.play(Tutorial.get.second, "scannerDone");
		});
	}

	function _scan2(f:F) {
		start(getCT(f)*0.5, function(t,v) {
			var a = new WinAppMap(t);
			a.setTitle(v.name);
			a.start();
			a.showMap(t.fs, 2);
		});
	}

	function _scan3(f:F) {
		start(getCT(f)*0.6, function(t,v) {
			var a = new WinAppMap(t);
			a.setTitle(v.name);
			a.start();
			a.showMap(t.fs, 3);
		});
	}

	function _scan4(f:F) {
		start(getCT(f)*1, function(t,v) {
			var a = new WinAppMap(t);
			a.setTitle(v.name);
			a.start();
			a.showMap(t.fs, 3, MapAV);
		});
	}

	function _scan42(f:F) {
		start(getCT(f)*1, function(t,v) {
			var a = new WinAppMap(t);
			a.fl_ignoreScrambler = true;
			a.setTitle(v.name);
			a.start();
			a.showMap(t.fs, 3);
		});
	}

	function _hunt(f:F) {
		start(getCT(f)*0.5, function(t,v) {
			var a = new WinAppMap(t);
			a.setTitle(v.name);
			a.start();
			a.showMap(t.fs, 1, MapPack);
		});
	}

	function _panic1(f:F) {
		start(getCT(f)*0.5, function(t,v) {
			if ( t.hasEffect(UE_MoveFurtivity) ) {
				t.removeEffect(UE_MoveFurtivity);
				t.log( Lang.fmt.RemainingMoveFurtivity({_n:t.countEffect(UE_MoveFurtivity)}) );
			}
			t.disconnectFS();
		});
	}

	function _panic2(f:F) {
		start(getCT(f)*1.5, function(t,v) {
			t.disconnectFS(true);
		});
	}

	function _extrac(f:F) {
		if ( f.hasEffect(E_Gathered) )
			throw Lang.get.AlreadyDone;
		if ( !f.canBeExtracted() )
			throw Lang.get.CantExtractThat;
		if ( term.avman.systemContains(AntivirusXml.get.couveuse) )
			throw Lang.get.Couveuse;
		start(getCT(f)*0.4, function(t,v) {
			f.addEffect(E_Gathered,1,1);
			f.extractBonus();
		});
	}

	function _disabl(f:F) {
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		if ( f.hasEffect(E_Disabled) ) throw Lang.get.OnlyOnce;
		start(getCT(f), function(t,v) {
			f.disableAV();
		});
	}

	function _disab2(f:F) {
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		if ( f.hasEffect(E_Disabled) ) throw Lang.get.OnlyOnce;
		start(getCT(f), function(t,v) {
			f.disableAV();
		});
	}


	function _rolbck(f:F) {
		if ( term.fs.curFolder.parent==null )
			throw Lang.get.NotInRoot;
		start(getCT(f)*0.5, function(t,v) {
			t.fs.openFolder(t.fs.curFolder.parent, true);
			if ( t.hasEffect(UE_MoveFurtivity) ) {
				t.removeEffect(UE_MoveFurtivity);
				t.log( Lang.fmt.RemainingMoveFurtivity({_n:t.countEffect(UE_MoveFurtivity)}) );
			}
		});
	}

	function _heal1(f:F) {
		if ( term.life>=term.lifeTotal )
			throw Lang.get.Useless;
		start(getCT(f)*1.5, function(t,v) {
			t.gainLife(v.power);
		});
	}


	function _heal2(f:F) {
		if ( term.life>=term.lifeTotal )
			throw Lang.get.Useless;
		start(getCT(f)*1.5, function(t,v) {
			t.gainLife(v.power);
		});
	}

	function _mana1(f:F) {
		if ( term.mana>=term.manaTotal )
			throw Lang.get.Useless;
		start(getCT(f)*1.5, function(t,v) {
			t.gainMana(v.power);
		});
	}

	function _mana2(f:F) {
		if ( term.mana>=term.manaTotal )
			throw Lang.get.Useless;
		start(getCT(f)*1.5, function(t,v) {
			t.gainMana(v.power);
		});
	}

	function _mana3(f:F) {
		if ( term.mana>=term.manaTotal )
			throw Lang.get.Useless;
		start(getCT(f)*1.5, function(t,v) {
			t.gainMana(v.power);
		});
	}


	function _fmove1(f:F) {
		start(getCT(f)*1.5, function(t,v) {
			if ( t.hasChipset(ChipsetsXml.get.thief) )
				t.gainMana( Math.floor(v.cc*0.3), true );
			t.addEffect(v, UE_MoveFurtivity, v.power);
		});
	}

	function _fmove2(f:F) {
		start(getCT(f)*1.5, function(t,v) {
			if ( t.hasChipset(ChipsetsXml.get.thief) )
				t.gainMana( Math.floor(v.cc*0.4), true );
			t.addEffect(v, UE_MoveFurtivity, v.power);
		});
	}

	function _invis(f:F) {
		start(getCT(f)*1.5, function(t,v) {
			if ( t.hasChipset(ChipsetsXml.get.thief) )
				t.gainMana( Math.floor(v.cc*0.6), true );
			t.addEffect(v, UE_Furtivity, v.power+1);
		});
	}


	function checkCorrupt(f:F) {
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.hasEffect(E_Encoded) ) throw Lang.get.Crypted;
		if ( term.hasChipset(ChipsetsXml.get.scout) )
			throw Lang.get.NotInScoutMode;
		if ( f.key!="file.control" )
			throw Lang.fmt.NeedExt({_ext:"CONTROL"});
		if ( f.hasEffect(E_Corrupt) )
			throw Lang.get.AlreadyDone;
		if ( term.avman.systemContains(AntivirusXml.get.harmonie) )
			throw Lang.get.CorruptBlocked;
	}

	function _corrup(f:F) {
		checkCorrupt(f);
		start(getCT(f)*0.25, function(t,v) {
			f.addEffect(E_Corrupt);
			var lines = f.content.split("\n");
			var str = "";
			for (l in lines)
				if ( l.indexOf("//")>=0 )
					str+=l+"\n";
				else
					str+="<del>"+l+"</del>\n";
			f.changeContent( str+"\n"+TD.texts.get("cfLineHacker") );
			t.addIconRain(t.fs.sdm, ["fx_corrupt"], f.mc);
			t.fs.onCorruptControl();
		});
	}

	function _corru2(f:F) {
		checkCorrupt(f);
		start(getCT(f)*0.25, function(t,v) {
			f.addEffect(E_Corrupt);
			var lines = f.content.split("\n");
			var str = "";
			for (l in lines)
				if ( l.indexOf("//")>=0 )
					str+=l+"\n";
				else
					str+="<del>"+l+"</del>\n";
			f.changeContent( str+"\n"+TD.texts.get("cfLineHacker") );
			t.addIconRain(t.fs.sdm, ["fx_corrupt"], f.mc);
			var list = t.fs.getFilesByExt("control");
			var n = 0;
			for (fc in list)
				if ( !fc.hasEffect(E_Corrupt) )
					n++;
			t.log( Lang.fmt.Log_CorruptRemain({_n:n}) );
			t.fs.onCorruptControl();
		});
	}

	function _reveng(f:F) {
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		if ( f.hasEffect(E_Revenge) ) throw Lang.get.InvalidTarget;
		start(getCT(f)*0.5, function(t,v) {
			f.addEffect(E_Revenge);
		});
	}

	function _pbomb(f:F) {
		if ( term.hasChipset(data.ChipsetsXml.get.scout) )
			throw Lang.get.NotInScoutMode;
		start(getCT(f)*6, function(t,v) {
			var list = t.fs.getFilesByKey("file.core");
			for (f2 in list)
				f2.fl_deleted = true;
			t.fs.crash();
		});
	}

	function _cbomb(f:F) {
		if ( term.hasChipset(data.ChipsetsXml.get.scout) )
			throw Lang.get.NotInScoutMode;
		if ( term.fs.fl_auth )
			throw Lang.get.Useless;
		start(getCT(f)*4.5, function(t,v) {
			t.fs.corrupt();
		});
	}


	function _weak1(f:F) {
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		if ( f.hasEffect(E_Weaken) ) throw Lang.get.OnlyOnce;
		start(getCT(f)*0.7, function(t,v) {
			f.addEffect(E_Weaken,v.power);
		});
	}

	function _weak2(f:F) {
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		if ( f.hasEffect(E_Weaken) ) throw Lang.get.OnlyOnce;
		start(getCT(f)*0.7, function(t,v) {
			f.addEffect(E_Weaken,v.power);
		});
	}

	function _exploi(f:F) {
		if ( !canBeDamaged(f) ) throw Lang.get.InvalidTarget;
		if ( f.hasEffect(E_Exploit) ) throw Lang.get.OnlyOnce;
		start(getCT(f), function(t,v) {
			f.addEffect(E_Exploit);
		});
	}

	function _unshld(f:F) {
		if ( !f.hasEffect(E_Shield) )
			throw Lang.get.NeedShield;
		start(getCT(f), function(t,v) {
			f.removeEffect(E_Shield);
			t.addIconRain(t.fs.sdm, ["fx_corrupt", "fx_binary"], f.mc);
		});
	}

	function _dec1(f:F) {
		if ( !f.hasEffect(E_Encoded) ) throw Lang.get.Useless;
		var n = f.countEffect(E_Encoded);
		if ( n>virus.power )throw Lang.fmt.EncodingTooStrong({_n:f.countEffect(E_Encoded)});
		start(getCT(f)*(n+1), function(t,v) {
			if ( t.hasChipset(ChipsetsXml.get.deciph) )
				t.gainMana( Math.floor(v.cc*0.5), true );
			f.decode();
		});
	}

	function _dec2(f:F) {
		if ( !f.hasEffect(E_Encoded) ) throw Lang.get.Useless;
		var n = f.countEffect(E_Encoded);
		if ( n>virus.power )throw Lang.fmt.EncodingTooStrong({_n:f.countEffect(E_Encoded)});
		start(getCT(f)*(n+1), function(t,v) {
			if ( t.hasChipset(ChipsetsXml.get.deciph) )
				t.gainMana( Math.floor(v.cc*0.6), true );
			f.decode();
		});
	}

	function _dec3(f:F) {
		if ( !f.hasEffect(E_Encoded) ) throw Lang.get.Useless;
		var n = f.countEffect(E_Encoded);
		if ( n>virus.power )throw Lang.fmt.EncodingTooStrong({_n:f.countEffect(E_Encoded)});
		start(getCT(f)*(n*1.3), function(t,v) {
			if ( t.hasChipset(ChipsetsXml.get.deciph) )
				t.gainMana( Math.floor(v.cc*0.6), true );
			f.decode();
		});
	}

	function _chrge2(f:F) {
		start(getCT(f)*0.7, function(t,v) {
			t.addEffect(v, UE_Charge, 2);
		});
	}
	function _chrge3(f:F) {
		start(getCT(f)*0.7, function(t,v) {
			t.addEffect(v, UE_Charge, 3);
		});
	}

	function _shld1(f:F) {
		start(getCT(f)*0.7, function(t,v) {
			t.addEffect(v, UE_Shield, v.power, v.power);
		});
	}

	function _shld2(f:F) {
		start(getCT(f)*0.7, function(t,v) {
			t.addEffect(v, UE_Shield, v.power, v.power);
		});
	}

	function _rconv(f:F) {
		if ( term.life<=virus.info )
			throw Lang.get.WouldKillYou;
		start(getCT(f)*0.1, function(t,v) {
			t.damage(v.info,false);
			t.gainMana(v.power);
		});
	}

	function _libxpl(f:F) {
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( !f.ext("lib") )
			throw Lang.fmt.NeedExt({_ext:"LIB"});
		if ( f.hasEffect(E_Splash) )
			throw Lang.get.OnlyOnce;
		start(getCT(f)*0.5, function(t,v) {
			f.addEffect(E_Splash, v.power);
		});
	}

	function _tag1(f:F) {
		if ( f.hasEffect(E_Tag) )
			throw Lang.get.OnlyOnce;
		start(getCT(f)*0.3, function(t,v) {
			f.addEffect(E_Tag, v.power);
		});
	}

	function _tag2(f:F) {
		if ( f.hasEffect(E_Tag) )
			throw Lang.get.OnlyOnce;
		start(getCT(f)*0.3, function(t,v) {
			f.addEffect(E_Tag, v.power);
		});
	}

	function _tag3(f:F) {
		if ( f.hasEffect(E_Tag) )
			throw Lang.get.OnlyOnce;
		start(getCT(f)*0.3, function(t,v) {
			f.addEffect(E_Tag, v.power);
		});
	}

	function _cevi(f:F) {
		if ( !term.hasEffect(UE_Combo) ) throw Lang.get.NeedCombo;
		start(getCT(f)*0.5, function(t,v) {
//			f.damage(v.power*t.countEffect(UE_Combo));
			t.addEffect(v, UE_DamageBurst, t.countEffect(UE_Combo));
			t.loseCombo();
		});
	}

	function _cstun(f:F) {
		if ( !term.hasEffect(UE_Combo) ) throw Lang.get.NeedCombo;
		if ( f.hasEffect(E_Masked) ) throw Lang.get.UnknownType;
		if ( f.av==null ) throw Lang.get.NeedAV;
		start(getCT(f)*0.5, function(t,v) {
			f.addEffect(E_SkipAction, t.countEffect(UE_Combo));
			t.loseCombo();
		});
	}

	function _cshld(f:F) {
		if ( !term.hasEffect(UE_Combo) ) throw Lang.get.NeedCombo;
		start(getCT(f)*0.5, function(t,v) {
			t.addEffect(v, UE_Shield, v.power*t.countEffect(UE_Combo), v.power*t.countEffect(UE_Combo));
			t.loseCombo();
		});
	}

	function _cshld2(f:F) {
		if ( !term.hasEffect(UE_Combo) ) throw Lang.get.NeedCombo;
		start(getCT(f)*0.5, function(t,v) {
			t.addEffect(v, UE_Shield, v.power*t.countEffect(UE_Combo), v.power*t.countEffect(UE_Combo));
			t.loseCombo();
		});
	}
	
	function _cshld3(f:F) {
		if ( !term.hasEffect(UE_Combo) ) throw Lang.get.NeedCombo;
		start(getCT(f)*0.5, function(t,v) {
			t.addEffect(v, UE_Shield, v.power*t.countEffect(UE_Combo), v.power*t.countEffect(UE_Combo));
			t.loseCombo();
		});
	}

	function _cchrge(f:F) {
		if ( !term.hasEffect(UE_Combo) ) throw Lang.get.NeedCombo;
		start(getCT(f)*1, function(t,v) {
			t.addEffect(v, UE_Charge, t.countEffect(UE_Combo));
			t.loseCombo();
		});
	}

	function _dckswi(f:F) {
		start(getCT(f)*1, function(t,v) {
			t.dock.showSwitcher();
		});
	}

	function _dcksw2(f:F) {
		start(getCT(f)*1, function(t,v) {
			t.dock.showSwitcher();
		});
	}


//	function _hunt(f:F) {
//		start(getCT(f)*1.5, function(t,v) {
//			if ( t.fs.searchExt(t.fs.curFolder, "pack") )
//				t.log(Lang.get.PackFound);
//			else
//				t.log(Lang.get.PackNotFound);
//		});
//	}


}
