package handler;
import db.Cadaver;
import db.BetaAccess;
import db.CityLog;
import db.User;

import tools.TextTransformer;
import Common;

class UserActions extends Handler<Void>{

	public function new() {
		super();
		//called from twinoid
		free( "validateForumMessage", 	doValidateForumMessage );
		free( "backToWar",				doBackToWar );
		logged( "experienced", 	"experienced.mtt", doExperienced);
		//
		ingame( "setExpert",			doSetExpert );
		ingame( "upgradeHome",			doUpgradeHome );
		ingame( "heroActAgain",			doHeroActAgain );
		ingame( "heroTrance",			doHeroTrance );
		ingame( "changeBankSort",		doChangeBankSort );
		ingame( "falsifyLog",			doFalsifyLog );
		ingame( "shareHero",			doShareHero );
		ingame( "resetJob",				doResetJob );
		ingame( "aggression",			doAggression );
		ingame( "stopEscort",			doStopEscort );
		ingame( "pickUpEscort",			doPickUpEscort );
		ingame( "cancelEscort",			doCancelEscort );
		ingame( "waitForLeader",		doWaitForLeader );
		ingame( "toggleEscortToTown",	doToggleEscortToTown );
		ingame( "toggleFullEscort",		doToggleFullEscort );
		ingame( "ghoulAttack",			doGhoulAttack );
		ingame( "openCustomMap", 		doOpenCustomMap );
		//
		dead( "welcomeToNowhere",	"game/dead.mtt", doWelcomeToNowhere );
		dead( "finalizeDeath",			doFinalizeDeath);
		dead( "bypassSpeech",			doByPassSpeech );
		//
		logged( "welcome",			"welcome.mtt",		doWelcome );
		logged( "event",			"game/event.mtt",	doMajorEvent );
		#if old_cash
		logged( "retryCredit",			doRetryCredit );
		#end
		//
		inTown( "heal",					doHealUser );
	}
	
	function doExperienced() {
		var user = App.user;
		var map = user.getMapForDisplay();
		db.UserVar.delete(user, "newlyExperienced");
	}
	
	function doValidateForumMessage() {
		var editable = true, cancel = false;
		var message = App.request.get("text");
		var isCityForum = App.request.getBool("isCityForum");
		var extraContent = null;// données pour la position du joueur
		var user = db.User.manager.get( App.request.getInt("uid"), false );
		var map = user.getMapForDisplay();
		var cancel = !(user != null && user.mapId != null && user.zoneId != null);
		
		/*
		if ( db.GameMod.hasMod("CHRISTMAS") )
		{
			message = ~/:xmas:/.customReplace( message, function(e) {
				return "@twinoid/8/9/7a3547a6_3.jpg@";
			} );
		}
		*/
		
		if( !cancel ) {
			if ( isCityForum && !user.dead ) {// Gestion des blessures uniquement dans le forum ville
				if( !App.request.getBool("edit") )
					db.GhostReward.gain(GR.get.forum, user, 1);
				
				
				var zone = user.getZoneForDisplay();
				var mapUsers = map.getUsers(false);
				// pour les petits malins
				message = ~/{rnduser:(.*)}/.replace( message, "{habitant}");				
				message = ~/{habitant}/.customReplace( message,  function(e) {
					return "{rnduser:" + Lambda.map(mapUsers, function(u) return u.twinId).join(",") + "}";
				} );
				
				var scrambleMessage = tools.Utils.scrambleMessage(message, user, false);
				if( scrambleMessage != message )
					editable = false;
				
				message = scrambleMessage;
				var city = map._getCity();
				if ( city != null && zone != null ) {
					var pt = MapCommon.coords(city.x, city.y, zone.x, zone.y);
					//
					extraContent = 	'<div class="pos">';
					if( user.job != null )
						extraContent += user.job.printIcon();
					extraContent += ' <img alt="" src="'+App.IMG+'/gfx/icons/item_map.gif">	';
					extraContent +=	if( city.x == zone.x && city.y == zone.y )
										Text.get.saloon_incity
									else if( user.map.chaos )
										Text.get.saloon_outside
									else if( pt != null )
										'[' + pt.x + ',' + pt.y + ']'
									else '';
					extraContent += '</div>';
				}
			}
		}
		neko.Lib.print(haxe.Serializer.run( { text:message, extra:extraContent, notEditable:!editable, cancel:cancel } ));
	}
	
	function doOpenCustomMap() {
		if( !db.GameMod.hasMod("CUSTOM_MAP") )
			throw "unknown page";
		var user = App.user;
		var mapId = App.request.getInt("mapId");
		var map = db.Map.manager.get(mapId, false);
		if( map != null && mapId != null && map.isCustom() && map.isCreator(user) ) {
			db.MapVar.setValue( map, "invitOnly", 0 );
			db.MapVar.setValue( map, "opened", 1 );
			notify( Text.get.UnlockedYourCustomMap );
		}
		App.goto("home");
	}
	
	//Thomas infirmary Implementation
	function doHealUser() {
		var u = App.user;
		var map = u.getMapForDisplay();
		if( !map.hasCityBuilding("infirmary") || db.ZoneAction.manager.hasDoneAction(u, "infirmary") ) {
			notify(Text.get.NoInfirmaryBuilt);
			return;
		}
		if ( u.getPa() >= 5 ) {
			
			if( u.isInfected && App.request.get("act", "infect") == "infect" ) {
				u.losePa(5);
				u.isInfected = false;
				u.update();
				notify( Text.get.InfectionCanceled );
			} else if( u.isWounded ) {
				u.losePa(5);
				u.isWounded = false;
				u.update();
				notify( Text.get.WoundedCanceled );
				db.ZoneAction.add(u, "infirmary");
			} else
				notify( Text.get.Useless );
		} else {
			notify(Text.fmt.NeedPA( { n:5 } ) );
		}
		App.goto("home");
	}
	
	function isCountryRestricted(name:String, ip:String) {
		var restrict = Text.get.CountryRestriction.split(",");
		if( restrict.length > 0 ) {
			// bypass pour certains
			name = name.toLowerCase();
			var names = Text.get.CountryBypass.split(",");
			for( n in names )
				if( n.toLowerCase() == name )
					return false;
			// vérification
			var country = try mt.net.GeoIp.resolve(ip) catch(e:Dynamic) "XX";
			for( r in restrict )
				if( country.toUpperCase() == r.toUpperCase() )
					return true;
		}
		return false;
	}

	function doWelcome() {
		App.context.goldenHello = App.user.getGoldenHello();
		App.context.similarMids = App.user.countSimilarMids();
	}

	#if old_cash
	function doRetryCredit() {
		if( !App.request.exists("l") ) {
			App.goto( "hero" );
			return;
		}
		if( App.request.get("l") != App.session.sid ) {
			App.goto( "hero" );
			return;
		}
		if( App.user.applyCredit() ) {
			notify( Text.get.bank_credit_done );
			App.goto("ghost/options");
			return;
		}
		notify( Text.get.bank_credit_done );
		App.goto("hero");
	}
	#end

	function doByPassSpeech() {
		var cadaver = Cadaver.manager._getUserCadaver( App.user, App.user.map, false );
		if( cadaver != null ) {
			App.reboot();
			return;
		}
		var user = App.user;
		db.GhostReward.manager.validateGame(user, cadaver); // was : cadaver.survivalDays (bug potentiel ?)
		user.map = null;
		user.zone = null;
		user.dead = false;
		user.update();
		App.reboot();
	}

	function doWelcomeToNowhere() {
		var user = App.user;
		var umap = db.Map.manager.get( user.mapId, false );
		var cadaver = Cadaver.manager._getUserCadaver( user, umap, true );
		if( cadaver != null ) {
			// La carte existe toujours
			App.context.cadaver = cadaver;
		} else {
			// La partie est fermée : un des derniers joueurs
			cadaver = Cadaver.manager.getLastUserCadaver( user );
			if( cadaver != null ) {
				App.context.oldMap = true;
				App.context.cadaver = cadaver;
			} else {
				// Le cadavre a été supprimé de la DB (??)
				user.map = null;
				user.zone = null;
				user.dead = false;
				user.update();
				App.reboot();
				return;
			}
		}

		var str = cadaver.getDeathEnumName();
		App.context.deathPic = str;
		App.context.deathDesc = if(Text.exists(str+"_Desc")) Text.getByKey(str+"_Desc") else "???";
		// goules
		//if( cadaver.mapFlag("GHOULS")) {
			var killed = db.GameAction.manager.countActionByUserId(user.id, "devourTotal");
			if( killed > 0 ) App.context.ghoulHeroDays = killed*1;
		//}
		// Rewards
		db.GhostReward.manager.updateCleanReward(user, cadaver.survivalDays);
		
		var rlist = db.GhostReward.manager.getNewRewardsByUser(user, cadaver);
		var missedList = db.GhostReward.manager.getMissedRewardsByUser(user, cadaver);
		
		// villes privées : une partie des distinctions est perdue
		if ( cadaver.custom && !cadaver.mapFlag("fullReward") ) {
			var lossRatio = 0.5;
			var filter = db.GhostReward.filterCustomMapRewards(rlist, cadaver.id, lossRatio);
			rlist = filter.won;
			for( r in filter.lost )
				missedList.push(r);
			App.context.custMapLossRatio = lossRatio*100;
		}
		
		var missedTotal = 0;
		for( r in missedList )
			missedTotal += r.value;
			
		App.context.missedList = missedList;
		App.context.missedTotal = missedTotal;
		App.context.rlist = rlist;
		App.context.oldMap = false;
		App.context.hideBar = true;
	}
	
	function doFinalizeDeath() {
		if( !App.user.dead ) {
			App.reboot();
			return;
		}
		var cadaver = null;
		var user = App.user;
		// La partie est terminée, a été supprimée mais le jouer n'a toujours pas validé sa mort
		// on récupère donc son dernier cadavre
		if( user.mapId == null )
			cadaver = Cadaver.manager.getLastUserCadaver( user, true );
		else
			cadaver = Cadaver.manager._getUserCadaver( user, user.map, true );
		// NE DEVRAIT JAMAIS SE PRODUIRE
		if( cadaver == null ) {
			if( App.DEBUG ) notify("Cadavre non reconnu");
			App.reboot();
			return;
		}
		//protéger les morts volontaires? Bof. Mais si il faut, on peut flag la mort sur le user par deshydratation avec un uservar suicide
		var isSuicide = (cadaver.mapDay == 1 && cadaver.deathType == Type.enumIndex(DT_Dehydrated));
		
		if ( !isSuicide )
			isSuicide = (cadaver.mapDay == 3 && cadaver.deathType == Type.enumIndex(DT_Dehydrated) && cadaver.attackedCity);
		
		if( isSuicide ) {
			if ( !db.UserVar.getBool(user, "inactiveWarning") ) {
				db.UserVar.setValue(user, "inactiveWarning", 1, true);
				notify( Text.get.UserWarnedBecauseInactive );
			} else {
				db.UserVar.setValue(user, "inactiveLocked", 4, true);
				notify( Text.get.UserLockedBecauseInactive );
			}
		} else if ( cadaver.mapDay > 3 && db.UserVar.getBool(user, "inactiveWarning") ) {
			db.UserVar.delete(user, "inactiveWarning");
		}
		
		var msg = App.request.get("message", "");
		if ( user.muted ) 
			msg = "";
		
		cadaver.deathMessage = TextTransformer.transform( tools.Utils.sanitize(msg, 120), false );
		cadaver.update();
		if( !App.user.muted && cadaver.canLeaveMessage() ) {
			appendNotify( Text.get.DeathMessageSent );
			if( db.GameMod.hasMod("TWINOID") ) {
				// message avec un peu d'aléatoire
				var id = 1 + Std.random(5);
				if( cadaver.mapDay == 1 ) id = 0;
				var messageFnc = [Text.fmt.twinoid_wall_death_short, Text.fmt.twinoid_wall_death_1,  Text.fmt.twinoid_wall_death_2,  Text.fmt.twinoid_wall_death_3,  Text.fmt.twinoid_wall_death_4,  Text.fmt.twinoid_wall_death_5][id];
				mt.db.Twinoid.callApi( "wallPost", { user: user.twinId, html: messageFnc( { city:cadaver.mapName, days:cadaver.mapDay, reason:cadaver.getDeathReason() } ) }, false );
				if( msg.length > 0 )
					mt.db.Twinoid.callApi( "wallPost", { user: user.twinId, html: Text.fmt.twinoid_wall_cadaver_msg( { msg:cadaver.deathMessage } ) }, false );
			}
		}
		db.GhostReward.manager.validateGame(user, cadaver);
		db.XmlCache.manager.deleteByKey("ghost"+user.id);
		user.leaveMap();
		
		if (user.hasFlag("newlyExperienced")) {
			App.goto("user/experienced");
		} else if( !user.hero && user.hideCommercials() ) {
			App.reboot();
		} else {
			App.goto("hero?go=hero/death");
		}
	}

	public function doBackToWar() {
		if( App.HORDE_ATTACK ) {
			App.reboot();
			return;
		}
		App.user.eventState = null;
		App.user.update();
		App.goto("news");
	}

	function doSetExpert() {
		if( !App.request.exists("v") )
			return;
		App.user.isNoob = if(App.request.get("v") == "1") false else true;
		App.user.update();
		App.reboot();
	}

	function doUpgradeHome() {
		var user = App.user;
		var map = user.getMapForDisplay();
		if( !user.inTown() ) return;
		if( map.devastated ) return;
		var hu = XmlData.homeUpgrades[user.homeLevel+1];
		var pa = hu.pa;
		if( !user.canDoTiringAction(pa) ) {
			notify( Text.fmt.NeedPA({n:pa}) );
			App.goto("home/upgrade");
			return;
		}
		if( hu.level > 4 && !map.hasCityBuilding("citizen") ) {
			notify( Text.fmt.HomeUpgradeLimit({b:XmlData.getBuildingByKey("citizen").print()}) );
			App.goto("home/upgrade");
			return;
		}
		var reqs = new Array();
		var textList = new List();
		for (req in hu.reqs)
			textList.push( XmlData.getToolByKey(req.key).print() +" <strong>x"+req.n+"</strong>" );
		// check reqs
		for( req in hu.reqs ) {
			if( !user.hasToolCount(req.key, req.n) ) {
				notify( Text.fmt.CantUpgrade({old:user.getHome().name, up:hu.name, lvl:hu.level, list:textList.join(",")}) );
				App.goto("home/upgrade");
				return;
			}
		}
		// cool down
		if( !map.chaos ) {
			if( db.ZoneAction.manager.hasDoneActionZone(App.user, "upgradeHome" ) ) {
				notify( Text.get.AlreadyDone );
				App.goto( "home/upgrade" );
				return;
			}
		}
		// delete reqs
		for (req in hu.reqs) {
			for (n in 0...req.n) {
				for(t in user.getTools(true)) {
					if(t.key==req.key) {
						t.delete();
						break;
					}
				}
			}
		}
		// done !
		db.GhostReward.gain(GR.get.homeup);
		user.homeLevel++;
		if( hu.reqs.length==0 )
			notify( Text.fmt.HomeUpgradedNoRsc({name:hu.name, list:textList.join(","), cost:pa}) );
		else
			notify( Text.fmt.HomeUpgraded({name:hu.name, list:textList.join(","), cost:pa}) );
		if( !user.map.chaos )
			db.ZoneAction.add( App.user, "upgradeHome", true );
		user.doTiringAction(pa);
		var map = user.getMapForDisplay();
		if( !map.isHardcore() )
			CityLog.add( CL_HomeUpgraded, Text.fmt.CL_HomeUpgraded( {name:user.print(), up:hu.name, lvl:user.homeLevel} ), map, user );
		App.goto("home/upgrade");
	}

	function doHeroActAgain() {
		var url = if(App.user.isOutside) "outside/refresh" else "home";
		if( !App.user.hero ) {
			notify(Text.get.NowYouWishedYouWereAHero);
			App.goto(url);
			return;
		}
		if( !App.user.hasHeroUpgrade("powerActAgain") || App.user.usedActAgain ) {
			notify(Text.get.Forbidden);
			App.goto(url);
			return;
		}
		if( App.user.hasDoneDailyHeroAction ) {
			notify(Text.get.HeroTired);
			App.goto(url);
			return;
		}
		if( App.user.getPa()>=App.user.maxPa() ) {
			notify(Text.get.Useless);
			App.goto(url);
			return;
		}

		App.user.usedActAgain = true;
		App.user.hasDoneDailyHeroAction = true;
		App.user.setPa( App.user.maxPa() );
		App.user.isTired = false;
		App.user.update();
		db.GhostReward.gain(GR.get.heroac);

		notify( Text.fmt.HeroUsedActAgain({pa:App.user.getPa()}) );
		App.goto(url);
	}


	function doHeroTrance() {
		var url = if(App.user.isOutside) "outside/refresh" else "home";
		if( !App.user.hero ) {
			notify(Text.get.NowYouWishedYouWereAHero);
			App.goto(url);
			return;
		}
		if( !App.user.hasHeroUpgrade("powerTrance") || App.user.usedTrance ) {
			notify(Text.get.Forbidden);
			App.goto(url);
			return;
		}
		if( App.user.hasDoneDailyHeroAction ) {
			notify(Text.get.HeroTired);
			App.goto(url);
			return;
		}

		App.user.usedTrance = true;
		App.user.hasDoneDailyHeroAction = true;
		App.user.isInTrance = true;
		App.user.update();
		db.GhostReward.gain(GR.get.heroac);

		notify(Text.get.HeroUsedTrance);
		App.goto(url);
	}

	function doFalsifyLog() {
		var url = App.request.get("url");
		if( !App.user.hero ) {
			notify(Text.get.NowYouWishedYouWereAHero);
			App.goto(url);
			return;
		}
		if( App.user.isOutside ) {
			notify(Text.get.Forbidden);
			App.goto(url);
			return;
		}
		if( !App.user.hasHeroUpgrade("falsify") ) {
			notify(Text.get.Forbidden);
			App.goto(url);
			return;
		}
		var log = db.CityLog.manager.get( App.request.getInt("id") );
		var newText = "<span class='falsified'>"+Text.get.CL_Falsified+"</span>";
		if( log.ctext==newText || log.hasKey(CL_AttackEvent) || log.hasKey(CL_Attack) ) {
			notify(Text.get.CantFalsify);
			App.goto(url);
			return;
		}
		if( log.zoneId!=null && App.user.zoneId!=log.zoneId ) {
			notify(Text.get.Forbidden);
			App.goto(url);
			return;
		}

		var max = if(App.user.hasHeroUpgrade("falsify2")) Const.get.FalsifyLimit2 else Const.get.FalsifyLimit;
		var count = db.GameAction.manager.countAction(App.user,"falsifyLog");
		if( count>=max ) {
			notify( Text.fmt.GameActionLimit({n:max}) );
			App.goto(url);
			return;
		}
		db.GameAction.add(App.user,"falsifyLog");

		log.user = null;
		log.ctext = newText;
		log.update();

		notify( Text.fmt.Falsified({n:max-count-1}) );
		App.goto(url);
	}

	function doChangeBankSort() {
		App.user.sortedBank = App.request.getInt("sortedBank",0)==1;
		App.user.update();
		App.goto("city/bank");
	}

	function doResetJob() {
		if( !App.user.hero || !App.user.hasThisJob("basic") ) {
			notify(Text.get.Forbidden);
			return;
		}
		App.user.jobId = null;
		App.user.update();
		App.reboot();
	}

	function doStopEscort() {
		var zone = App.user.getZoneForDisplay();
		var map = App.user.getMapForDisplay();
		
		if( !map.hasMod("FOLLOW") ) return;
		var url = if(App.user.isOutside) "outside/refresh" else "city/enter";
		var pet = db.User.manager.get( App.request.getInt("uid") );
		if( pet==null || !pet.isFollower(App.user) ) {
			notify(Text.get.Forbidden);
			App.goto(url);
			return;
		}
		pet.dropEscort();
		
		if( map.cityId!=zone.id ) {
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsidePetDropped({master:App.user.print(),pet:pet.print()}), App.user.getMapForDisplay(), App.user.getZoneForDisplay() );
		}
		notify( Text.fmt.PetDropped({user:pet.print()}) );
		App.goto(url);
	}

	function doPickUpEscort() {
		if( !App.user.map.hasMod("FOLLOW") )
			return;

		if( App.user.isCamping() )
			return;

		var url = if(App.user.isOutside) "outside/refresh" else "city/enter";
		var pet = db.User.manager.get( App.request.getInt("uid") );
		if( App.user.isNoob ) {
			notify(Text.get.ForbiddenToNoob);
			App.goto(url);
			return;
		}
		if( !(App.user.hero || App.user.isGuide) ) {
			notify(Text.get.OnlyHeroesCanEscort);
			App.goto(url);
			return;
		}
		if( App.user.isCityBanned ) {
			notify(Text.get.BanForbidden);
			App.goto(url);
			return;
		}
		if( pet==null || pet.hasLeader() || !pet.isWaitingLeader ) {
			notify(Text.get.Forbidden);
			App.goto(url);
			return;
		}
		if( db.User.manager.countSquad(App.user)>=Const.get.SquadLimit ) {
			notify( Text.fmt.SquadLimit({n:Const.get.SquadLimit}) );
			App.goto(url);
			return;
		}
		if( !pet.follow(App.user) ) {
			notify( Text.get.CantPickUpPet );
		} else {
			// ok
			App.user.wasEscorted = false;
			App.user.isWaitingLeader = false;
			App.user.loseCamp(false);
			App.user.update();
			notify( Text.fmt.PetPickedUp({user:pet.print()}) );
			var zone = App.user.getZoneForDisplay();
			var map = App.user.getMapForDisplay();
			if( map.cityId!=zone.id ) {
				CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsidePetPickedUp({master:App.user.print(),pet:pet.print()}), map, zone );
				if( zone.isInFeist() && App.user.loseCamo(true) ) {
					appendNotify(Text.get.LostCamo);
				}
			}
		}
		App.goto(url);
	}

	function doCancelEscort() {
		if( !App.user.map.hasMod("FOLLOW") )
			return;
		var url = if(App.user.isOutside) "outside/refresh" else "city/enter";
		var fl_hadLeader = App.user.hasLeader();
		App.user.isWaitingLeader = false;
		App.user.leader = null;
		App.user.update();
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsidePetCancelEscort({name:App.user.print()}), App.user.getMapForDisplay(), App.user.getZoneForDisplay());
		if( fl_hadLeader )
			App.reboot();
		else
			App.goto(url);
	}

	function doWaitForLeader() {
		if( !App.user.map.hasMod("FOLLOW") )
			return;

		if( !App.user.isOutside || App.user.hasLeader() ) {
			notify(Text.get.Forbidden);
			App.goto("outside/refresh");
			return;
		}
		if( db.User.manager.countSquad(App.user)>0 ) {
			notify(Text.get.Forbidden);
			App.goto("outside/refresh");
			return;
		}
		App.user.isWaitingLeader = true;
		App.user.onlyEscortToTown = App.user.isOutside && App.user.zoneId!=App.user.getMapForDisplay().cityId;
		App.user.fullEscortMode = false;
		App.user.update();
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsidePetWaitLeader({name:App.user.print()}), App.user.getMapForDisplay(), App.user.getZoneForDisplay());
		App.goto("outside/refresh");
	}

	function doShareHero() {
		var user = App.user;
		if ( !db.GameMod.hasMod("SHARE_HERO") ) return;
		
		var url = if(user.isOutside) "outside/refresh" else "city/co";
		if( user.isCamping() )
			return;

		if( !user.hasHeroUpgrade("share") ) {
			notify(Text.get.Forbidden);
			App.goto(url);
			return;
		}
		if( !user.hero ) {
			notify(Text.get.NowYouWishedYouWereAHero);
			App.goto(url);
			return;
		}
		if( user.heroDays <= 1 ) {
			notify(Text.get.CantShareNotEnoughDays);
			App.goto(url);
			return;
		}
		var n = db.GameAction.manager.countAction(user,"shareHero");
		if( n >= Const.get.HeroShareLimit ) {
			notify( Text.fmt.GameActionLimit({n:Const.get.HeroShareLimit}) );
			App.goto(url);
			return;
		}

		var tid = App.request.getInt("uid");
		var target = db.User.manager.get(tid,true);
		if( target == null || target.zoneId != user.zoneId || !target.playsWithMe(user) ) {
			notify( Text.get.Forbidden );
			App.goto(url);
			return;
		}

		if(!user.isOutside) url = "city/seeClint?id="+target.id;

		if( target.heroDays > 0 || db.UserVar.getValue(target, "heroGift",0) > 0 ) {
			notify( Text.get.CantShareHeroWithHero );
			App.goto(url);
			return;
		}
		
		if( !target.isPlaying() ) {
			notify( Text.get.CantShareHeroWithGhost );
			App.goto(url);
			return;
		}
		
		if( target.isOnline() ) {
			// connecté
			target.heroDays += 1;
			target.onReceivedHeroDays();
			if( !target.hero )
				target.hero = true;
			target.wasRescued = true;
			target.update();
		} else {
			// non-connecté, jours reçus au prochain login ! (note: pour pas qu'il ne soit perdu ?)
			db.UserVar.setValue(target, "heroGift", 1);
			db.UserVar.setValue(target, "heroGiftGiver", user.id);
		}

		user.heroDays -= 1;
		user.update();
		db.GhostReward.gain(GR.get.share);
		db.GameAction.add(user,"shareHero");
		notify( Text.fmt.SharedHero({name:target.print()}) );
		App.goto(url);
	}

	function doToggleEscortToTown() {
		var user = App.user;
		if( !user.map.hasMod("FOLLOW") )
			return;
		var url = if(user.isOutside) "outside/refresh" else "city/enter";
		if( user.zoneId == user.getMapForDisplay().cityId ) {
			notify(Text.get.ForbiddenAtDoors);
			App.goto(url);
			return;
		}
		user.onlyEscortToTown = !user.onlyEscortToTown;
		user.update();
		App.goto(url);
	}

	function doToggleFullEscort() {
		var user = App.user;
		if( !user.map.hasMod("FOLLOW") ) return;
		if( !user.map.hasMod("FOLLOW_FULL") ) return;
		var url = if(user.isOutside) "outside/refresh" else "city/enter";
		user.fullEscortMode = !user.fullEscortMode;
		user.update();
		App.goto(url);
	}

	function doGhoulAttack() {
		var user = App.user;
		var url = if(user.isOutside) "outside/refresh" else "city/co";
		var map = user.getMapForDisplay();
		var zone = user.getZoneForDisplay();
		if( !map.hasMod("GHOULS") )
			return;
		
		if( !user.isGhoul || user.dead || user.isCamping() )
			return;
		
		if(db.ZoneAction.manager.hasDoneAction(user, "devour")) {
			notify(Text.get.AlreadyDone);
			App.goto(url);
			return;
		}
		
		var victim = db.User.manager.get( App.request.getInt("uid") );
		if( victim == null || !user.playsWithMe(victim) || victim.id == user.id )
			return;

		if( user.isOutside && user.zoneId == map.cityId ) {
			// pas d'attaque dehors aux portes de la ville
			notify( Text.get.NoGhoulAttackOnDoors );
			App.goto(url);
			return;
		}

		if( victim.isOutside != user.isOutside || victim.zoneId != user.zoneId || victim.inExplo() != user.inExplo() )
			return;
			
		if( victim.isGhoul ) {
			notify(Text.get.CantEatGhoul);
			App.goto(url);
			return;
		}

		// Miam !
		var fl_detect = false;
		if( victim.isOutside ) {
			// outre-monde
			CityLog.addToZone( CL_OutsideEvent, Text.get.OutsideGhoulAttack, map, zone );
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideGhoulAttackTemp( { name:user.print(), victim:victim.print() } ), map, zone );
			var fl_hadControl = zone.humans >= zone.zombies;
			if( fl_hadControl ) {
				zone = user.zone;// lock
				zone.endFeist = DateTools.delta( Date.now(), DateTools.minutes(Const.get.ControlTime) );
				zone.update();
			}
		} else {
			if( Std.random(100) < map.getGhoulDetectChance() ) {
				// détecté en ville
				CityLog.add( CL_Death, Text.fmt.CL_GhoulAttackNamed( {name:user.print(), victim:victim.print()}), map );
				fl_detect = true;
			} else {
				// non-détecté en ville
				CityLog.add( CL_Death, Text.fmt.CL_GhoulAttack( { victim:victim.print() } ), map );
			}
		}

		// héritage des états de santé de la victime
		var fl_inherited =
			victim.isDrugged && !user.isDrugged ||
			victim.isAddict && !user.isAddict ||
			victim.isDrunk && !user.isDrunk;
		
		user.isDrugged = victim.isDrugged || user.isDrugged;
		user.isAddict= victim.isAddict || user.isAddict;
		user.isDrunk= victim.isDrunk || user.isDrunk;

		// résolution
		notify(Text.fmt.GhoulAttack({name:victim.print()}));
		victim.die(DT_GhoulAttack);
		db.GhostReward.gain( GR.get.cannib );
		user.refillMoves(false);
		user.changeHunger(-user.ghoulHunger, true);
		user.addPa(Const.get.TastyBonus); // update
		db.ZoneAction.add(user, "devour", true );
		db.GameAction.add(user, "devourTotal");

		// msg complémentaires
		if(fl_inherited)
			appendNotify( Text.get.GhoulStatusInherited );
		if(fl_detect)
			appendNotify( Text.get.Detected );
		App.goto(url);
	}
	
	function doMajorEvent() {
		var user = App.user;
		if( user.majorEvent == null )
			App.reboot();
		App.context.hideBar = true;
		App.context.event = user.majorEvent;
		user.clearMajorEvent();
	}

	function doAggression() {
		var user = App.user;
		var map  = user.getMapForDisplay();
		var zone = user.getZoneForDisplay();
		var target = db.User.manager.get(App.request.getInt("uid", 0));
		if( target == null )
			return;
		
		try {
			var cost = map.getAggressionCost();
			if( !user.isInGame() || !target.isInGame() || target.zoneId != user.zoneId || target.id == user.id || target.mapId != user.mapId || user.isCamping())
				return;
			
			if( user.isOutside && !map.hasMod("BANNED"))
				return;
			
			if( user.isOutside != target.isOutside )
				return;
			
			if( user.isWounded )
				throw Text.get.CantDoWhenWounded;
			//on prend en compte le statut de goule, car sinon cela la rend quasi immortelle
			if( target.isWounded && !target.isGhoul )
				throw Text.get.CantAgressWounded;
			
			if( !map.canUseAggression() )
				return;
			
			if( !map.isFar() && !map.isHardcore() && map.hasMod("GHOULS") )
				if( db.User.manager.countGhouls(map) <= 0 )
					throw Text.get.NoGhoulNoAggression; // pas d'agression possible en RNE si pas de goule !
			
			if( user.isOutside && map.cityId == zone.id )
				throw Text.get.ForbiddenAtDoors;
			
			if( !user.canDoTiringAction(cost) )
				throw Text.fmt.NeedPA({n:cost});
			
			var woundChance = map.getAggressionWoundChance();
			if( target.isGhoul ) {
				// goule abattue
				target.die( DT_GhoulWounded );
				notify( Text.fmt.AggressionWounded({target:target.print()}) );
				appendNotify(Text.fmt.AggressionGhoul({name:target.name}) );
				appendNotify(Text.get.EventLogged);
				if( user.isOutside )
					CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideAggressionWounded({name:user.print(), target:target.print()}), map, zone);
				else
					CityLog.add( CL_Thief, Text.fmt.CL_AggressionWound( {name:user.print(), target:target.print()} ), map, user );
			} else {
				if( !target.isWounded && Std.random(100) < woundChance ) {
					// victime blessée
					target.wound();
					notify( Text.fmt.AggressionWounded({target:target.print()}) );
					if( user.isOutside ) {
						CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideAggressionWounded({name:user.print(), target:target.print()}), map, zone);
					} else {
						appendNotify(Text.get.EventLogged);
						CityLog.add( CL_Thief, Text.fmt.CL_AggressionWound( {name:user.print(), target:target.print()} ), map, user );
						MessageActions.sendOfficialMessage( target, Text.fmt.MT_AggressionWounded( { u:user.print() } ), Text.fmt.M_AggressionWounded( { u:user.print() } ) );
					}
				} else {
					// victime indemne
					notify( Text.fmt.Aggression({target:target.print()}) );
					if( user.isOutside ) {
						CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideAggression({name:user.print(), target:target.print()}), map, zone);
					} else {
						appendNotify(Text.get.EventLogged);
						MessageActions.sendOfficialMessage( target, Text.fmt.MT_Aggression({u:user.print()}), Text.fmt.M_Aggression({u:user.print()}) );
						CityLog.add( CL_Thief, Text.fmt.CL_Aggression( {name:user.print(), target:target.print()} ), map, user );
					}
				}
			}
			
			user.doTiringAction(cost);
			
		} catch( e:String ) { notify(e); }
		
		if( App.user.isOutside )
			App.goto("outside/refresh");
		else
			if( target.dead )
				App.goto("city/co");
			else
				App.goto("city/seeClint?id="+target.id);
	}

}
