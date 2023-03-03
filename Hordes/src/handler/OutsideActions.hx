package handler;

import db.Zone;
import db.Map;
import db.ZoneAction;
import db.ZoneItem;
import db.User;
import db.Tool;
import db.GatheredObject;
import db.CityLog;
import Common;
import MapCommon;
import tools.Utils;

using Std;
using Lambda;

class OutsideActions extends Handler<Void> {

	public function new() {
		super();

		outside( "doors",				"outside/doors.mtt",	doDoors);
		outside( "default",				"outside/base.mtt",		doOutside);
		outside( "go",					doGo );
		outside( "refresh",				doRefresh );
		outside( "flee",				doFlee );
		outside( "wrestle",				doWrestle );
		outside( "exploreBuilding",		doExploreBuilding );
		outside( "speak",				doSpeak );
		outside( "setInfoTag",			doSetInfoTag );
		outside( "searchGround",		doSearchGround );
		outside( "extractBuilding",		doExtractBuilding );
		outside( "checkUnextracted",	doCheckUnextracted );
		outside( "teleportBack",		doTeleportBack );
		outside( "useArmageddon",		doUseArmageddon );
		outside( "upgradeDefense",		doUpgradeDefense );
		outside( "settleCamp",			doSettleCamp );
		outside( "leaveCamp",			doLeaveCamp );
		outside( "searchGarbages",		doSearchGarbages );
		outside( "hideTools",			doHideTools );
		outside( "reportZoneProblem",	doReportZoneProblem );
		ingame( "heroKillsZombie",		doHeroKillsZombie );
		ingame( "heroTownPortal",		doHeroTownPortal );
		outside( "remoteSearchGround",	doRemoteSearchGround );
		outside( "purifyGround",        doPurifyGround );
		outside( "distantVote", 		doDistantVote);
		outside( "elect",				"outside/elect.mtt",	doElect);
		outside("recalc", 				doRecalcScore);
	}
	
	public function doRecalcScore() {
		var user = App.user;
		var map = App.user.getMapForDisplay();
		var z = db.Zone.manager.get(user.zoneId);
		z.recalcHumanScore(false);
		z.update();
		doRefresh();
	}
	
	public function doDoors() {
		var user = App.user;
		var map = App.user.getMapForDisplay();
		if( user.zoneId != map.cityId ) {
			App.context.invalidZone = true;
		} else {
			App.context.invalidZone = false;
			var pList = db.User.manager.getOutsidePlayers(user.zoneId);
			App.context.hasEscort = db.User.manager.countSquad(user)>0;
			App.context.players = pList;
			var pids = Lambda.map( pList, function(u) { return u.id; } );
			App.context.onlineHash = db.Session.getOnlineHash(pids);
			App.context.townPortalLimit = Const.get.MaxTownPortalDistance;
			//Thomas maze Implementation
			App.context.paCost = user.hasCityBuilding("maze") ? 1 : 0;
			App.context.doorCostBuilding = XmlData.getBuildingByKey("maze");
			App.context.isAtDoors = true;
			App.context.hasDoorOpened = map.hasDoorOpened();
			if( map.hasMod("BANNED") && user.canDoBannedAction(map) )
				App.context.canSearchGarbages = !db.ZoneAction.manager.hasDoneCountedActionZone(user, "searchGarbages", user.getGarbageSearchLimit());
			App.context.canBypassClosedDoors = App.user.hero && map.hasCityBuilding("airing");
			addMapDataToContext( encodeMapData(getMapResponse()) );
			App.context.canPurifyGround = user.isShaman/*App.user.hasThisJob("shaman")*/;
		}
	}
	
	public function doHeroTownPortal() {
		var user = App.user;
		if( user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			doRefresh();
			return;
		}
		
		if( user.isCamping() )
			return;
		
		if( !user.hero ) {
			notify(Text.get.NowYouWishedYouWereAHero);
			App.goto("hero");
			return;
		}
		
		if( !App.user.isOutside ) {
			notify(Text.get.OutsideHeroAction);
			App.goto( "home");
			return;
		}
		
		if( user.usedTownPortal ){
			notify(Text.get.HeroAlreadyUsedTownPortal);
			App.goto("outside/refresh");
			return;
		}
		
		if( user.hasDoneDailyHeroAction ){
			notify(Text.get.HeroTired);
			App.goto("outside/refresh");
			return;
		}
		
		var zone = user.getZoneForDisplay();
		if( zone.level>Const.get.MaxTownPortalDistance ) {
			notify( Text.fmt.TownPortalLimit({max:Const.get.MaxTownPortalDistance, n:zone.level}) );
			App.goto("outside/refresh");
			return;
		}
		
		checkZoneControlBeforeLeaving( user, Text.fmt.HeroTeleported( {name:user.print()} ) );
		
		var umap = db.Map.manager.get( user.mapId , false );
		user.dropAllSquad();
		user.zone = umap._getCity();
		user.isOutside = false;
		user.usedTownPortal = true;
		user.hasDoneDailyHeroAction = true;
		user.endGather = null;
		user.update();
		
		CityLog.add( CL_OpenDoor, Text.fmt.CL_EnterCity( {name:user.print()} ), umap, user );
		
		db.GhostReward.gain(GR.get.heroac);
		db.TempGather.manager.deleteTools( user );
		notify(Text.get.HeroUsedTownPortal);
		App.reboot();
	}
	
	public function doDistantVote() {
		var user = App.user;
		if( user.isCamping() )
			return;
		
		if( !user.hero ) {
			notify(Text.get.NowYouWishedYouWereAHero);
			App.goto("hero");
			return;
		}
		
		if( !App.user.isOutside ) {
			notify(Text.get.OutsideHeroAction);
			App.goto( "home");
			return;
		}
	/*
		if( user.hasDoneDailyHeroAction ){
			notify(Text.get.HeroTired);
			App.goto("outside/refresh");
			return;
		}
	*/
		
		if( !App.user.hasDoorOpened() ) {
			notify( Text.get.CantTeleportDoorClosed );
			App.goto("outside/refresh");
			return;
		}
		
		
		//db.GhostReward.gain(GR.get.heroac);
		App.load("outside/elect?role="+App.request.get("role", "shaman"));
		//App.reboot();
	}

	function doElect() {
		var user = App.user;
		var map = user.getMapForDisplay();
		
		var shamanElection = map.hasMod("SHAMAN_SOULS") && map.flags.get(SHAMAN_ELECTION);
		var guideElection = map.flags.get(GUIDE_ELECTION);
		
		if(!shamanElection && !guideElection) return;
		
		if (App.request.exists("act") && App.request.get("act", "") == "vote" ) {
			var roleKey = App.request.get("role", "");
			var roleName = Text.get.resolve(roleKey + "_role");
			var actName = switch( roleKey ) {
				case "shaman":
					user.validateActivity(Common.BIT_VOTE_SHAMAN_ELECTION);
					"shamanVote";
				case "guide":  
					user.validateActivity(Common.BIT_VOTE_GUIDE_ELECTION);
					"guideVote";
				default:
					throw "unknown rôle : " + roleName;
			}
			
			if ( db.ZoneAction.manager.hasDoneAction(user, actName) ) {
				notify(Text.fmt.electionVoteUnique( { role:roleName } ));
			} else {
				var roleTarget = db.User.manager.get(App.request.getInt("uid", 0), false);
				db.UserVar.manager.fastInc(roleTarget.id, actName);
				db.ZoneAction.addDirectly(user, actName);
				notify(Text.fmt.electionVoteConfirmed( { user:roleTarget.name, role:roleName } ));
			}
			App.goto("outside/refresh");
			return;
		}
		
		var users = map.getUsers(false);
		// On récupère la liste des métiers et les compteurs associés
		var temp = new IntHash();
		var jobs = new List();
		for( u in users ) {
			if( u.jobId == null )
				continue;
			if( temp.exists( u.jobId ) ) {
				temp.set( u.jobId, temp.get( u.jobId ) + 1 );
				continue;
			}
			temp.set( u.jobId,  1 );
		}
		for( t in temp.keys() ) {
			var job = XmlData.jobs[t];
			if( job != null )
				jobs.push( {name:job.name, icon:job.icon, count:temp.get( t )} );
		}
		
		var role = App.request.get("role", "shaman");
		App.context.jList = jobs;
		App.context.role = role;
		App.context.city = map._getCity();
		
		// who is online ?
		var now = DateTools.delta( Date.now(), -DateTools.minutes(Const.get.OnlineStatusMinutes) );
		var minTime = DateTools.format( now, "%Y-%m-%d %H:%M" );
		var onlines = new List();
		if(users.length > 0) 
			onlines = Db.execute("SELECT uid FROM Session WHERE uid IN(" + users.map(function(u) return u.id).join(",") + ") AND mtime >= '" + minTime+"'").results();
		
		var citizens = new Array();
		for(u in users) {
			var c = {user:u, online:false};
			for(o in onlines) {
				if(o.uid == u.id) {
					c.online = true;
					break;
				}
			}
			citizens.push(c);
		}
		App.context.citizens = citizens;
	}	
	
	public function doTeleportBack() {
		if( App.user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			doRefresh();
			return;
		}
		
		if( !App.user.hasDoorOpened() ) {
			notify( Text.get.CantTeleportDoorClosed );
			App.goto("outside/refresh");
			return;
		}
		
		var squad = User.manager.getSquad(App.user,true);
		for( pet in squad )
			teleportBack(pet);
		
		teleportBack(App.user);
		App.reboot();
	}

	function teleportBack(user:User) {
		var maxTelepDist = db.CityUpgrade.getValueIfAvailableByKey( "tower", 2, user.getMapForDisplay(), 0 );
		if( user.getZoneForDisplay().level > maxTelepDist )
			return;
		
		if( user.isCamping() )
			return;
		
		checkZoneControlBeforeLeaving( user, Text.fmt.OutsideCitizenTeleported( {name:user.print()} ) );
		var umap = db.Map.manager.get(  user.mapId , false );
		var city = umap._getCity();
		user.dropAllSquad();
		user.zone = city;
		user.isOutside = false;
		user.endGather = null;
		user.update();
		
		CityLog.add( CL_OpenDoor, Text.fmt.CL_EnterCity( {name:user.print()} ), umap, user );
		db.TempGather.manager.deleteTools( user );
	}

	public function doHeroKillsZombie() {
		var user = User.manager.get( App.user.id );
		if( !user.hero ) {
			notify(Text.get.NowYouWishedYouWereAHero);
			App.goto("hero");
			return;
		}
		
		if( user.isCamping() )
			return;
		
		if( !App.user.isOutside ) {
			notify(Text.get.OutsideHeroAction);
			App.goto( "home");
			return;
		}
		
		var zone = Zone.manager.get( user.zoneId );
		if( zone.zombies <= 0 ){
			notify(Text.get.NoZombiesToKill);
			doRefresh();
			return;
		}
		
		if( user.usedHeroKill ){
			notify(Text.get.HeroAlreadyKilledAZombie);
			doRefresh();
			return;
		}
		
		if( user.hasDoneDailyHeroAction ){
			notify(Text.get.HeroTired);
			doRefresh();
			return;
		}
		
		var kills = Std.int( Math.min(zone.zombies, Const.get.HeroKickPower) );
		zone.zombies -= kills;
		zone.kills += kills;
//		if( zone.zombies <= zone.getHumanScore() ) zone.isFeist = false;
//		isZoneNowUnderControl(zone);
		zone.update();
		
		user.usedHeroKill = true;
		user.hasDoneDailyHeroAction = true;
		user.update();
		
		db.GhostReward.gain(GR.get.killz, kills);
		db.GhostReward.gain(GR.get.heroac);
		
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.HeroKilledZombies({u:user.print(), n:kills}), user.getMapForDisplay(), user.zone );
		notify( Text.fmt.HeroKillsZombies({n:kills}) );
		doRefresh();
	}

	public function doSpeak() {
		if( !App.request.exists( "message" ) ) {
			doRefresh();
			return;
		}
		var user = App.user;
		var msg = Utils.sanitize( App.request.get("message") );
		msg = Utils.formatPost(msg);
		if( msg != "" ) {
			msg = tools.Utils.scrambleMessage(msg,user);
			var map = db.Map.manager.get( user.mapId, false ); // On évite de locker la ressource
			CityLog.addToZone( CL_OutsideChat, Text.fmt.OutsideSpeech( {name:user.print(), msg:msg} ), map, user.zone );
		}
		doRefresh();
	}

	public function doSetInfoTag() {
		if( App.user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			doRefresh();
			return;
		}
		if( !App.request.exists( "tid" ) ) {
			notify( Text.fmt.UnknownError({t:"no tid"}) );
			doRefresh();
			return;
		}
		var tid = App.request.getInt("tid");
//		if( tid>1 && !App.user.hasJob("eclair") ) return; // check

		App.user.zone.infoTagEnum = Reflect.field(InfoTags, Type.getEnumConstructs(InfoTags)[tid]);
		App.user.zone.update();
		doRefresh();
	}

	public function doExtractBuilding() {
		var user = App.user;
		var zone = user.zone;
		if( zone.type<=1 ) return;
		var bname = XmlData.getOutsideBuilding(zone.type).name;

		if( user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			doRefresh();
			return;
		}

		if( user.isCamping() )
			return;

		if( !zone.isBuilding() ) {
			notify( Text.get.NoBuildingToExtract );
			doRefresh();
			return;
		}

		if( user.zone.hasBuildingExtracted() ) {
			notify( Text.fmt.BuildingAlreadyExtracted({building:bname}) );
			doRefresh();
			return;
		}

		if( !App.user.canDoTiringAction(Const.get.PA_ExtractBuilding) ) {
			notify( Text.fmt.NeedPA({n:Const.get.PA_ExtractBuilding}) );
			doRefresh();
			return;
		}

		db.GhostReward.gain(GR.get.digger);
		zone.diggers--;
		zone.update();

		if( zone.hasBuildingExtracted() ) {
			notify( Text.fmt.BuildingExtracted({building:bname}) );
		}
		else {
			notify( Text.get.BuildingNotExtractedYet );
		}
		appendNotify( Text.fmt.UsedPA({n:Const.get.PA_ExtractBuilding}) );
		if( App.user.loseCamo() ) {
			appendNotify(Text.get.LostCamo);
		}
		user.doTiringAction(Const.get.PA_ExtractBuilding);

		var map = user.getMapForDisplay();
		var zone = user.getZoneForDisplay();
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDigged( {name:App.user.print()} ), map, zone );
		if( zone.hasBuildingExtracted() )
			CityLog.addToZone( CL_OutsideEvent, Text.fmt.OutsideDiggedDone( {building:bname} ), map, zone );

		doRefresh();
	}
	
	
	function doCheckUnextracted() {
		var user = App.user;
		var zone = user.zone;
		if( zone.type <= 1 ) return;
		var bname = XmlData.getOutsideBuilding(zone.type).name;
		if( !App.user.hasThisJob("eclair") )
			return;
		if( user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			doRefresh();
			return;
		}
		if( user.isCamping() )
			return;
		if( !zone.isBuilding() ) {
			notify( Text.get.NoBuildingToExtract );
			doRefresh();
			return;
		}
		if( user.zone.hasBuildingExtracted() ) {
			App.reboot();
			return;
		}
		user.update();
		notify(Text.fmt.CheckedUnextracted( { bname:bname} ));
		doRefresh();
	}
	
	// Action : Fouiller le sol : une fois par zone / jour
	public function doSearchGround() {
		if( App.user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			doRefresh();
			return;
		}
		if( App.user.isCamping() )
			return;
		startGather(App.user, App.user.getMapForDisplay(), App.user.zone);
		doRefresh();
	}

	public function doRemoteSearchGround() {
		if( !App.user.map.hasMod("FOLLOW") ) {
			notify( Text.get.Forbidden );
			doRefresh();
			return;
		}
		var pet = db.User.manager.get(App.request.getInt("uid"));
		if( pet == null || !pet.isFollower(App.user) ) {
			notify(Text.get.Forbidden);
			doRefresh();
			return;
		}
		startGather(pet, pet.getMapForDisplay(), pet.zone);
		doRefresh();
	}


	public function startGather(user:User, map:Map, zone:Zone) {
		var fl_isMe = user == App.user;
		if( !fl_isMe && !map.hasMod("FOLLOW") ) {
			return;
		}
		if( zone.isInFeist() || zone.isBeforeFeist() ) {
			notify(Text.get.LostControl);
			return;
		}
		if( ZoneAction.manager.hasDoneActionZone(user, "pick" ) ) {
			notify(Text.get.AlreadyDoneZone);
			return;
		}
		if( zone.id == map.cityId ) {
			notify(Text.get.CannotPickOnTown);
			return;
		}
		if( user.job == null ) {
			notify(Text.get.NeedJob);
			return;
		}
		if( map.hasMod("BANNED") && Std.random(100) < Const.get.FindHiddenChance && !user.canDoBannedAction() ) {
			var hiddenTools = db.ZoneItem.manager._getZoneItems(zone, true, false);
			if( hiddenTools.length > 0 ) {
				// objets cachés découverts !
				var list = new List();
				for( zi in hiddenTools ) {
					for (i in 0...zi.count) {
						ZoneItem.create(zone, zi.toolId, 1, zi.isBroken);
						var t = Reflect.copy(XmlData.getTool(zi.toolId));
						t.isBroken = zi.isBroken;
						list.add(t);
						zi.delete();
					}
				}
				var listStr = ToolActions.printList(list);
				if( fl_isMe ) {
					notify( Text.fmt.DiscoveredHiddenTools({list:listStr}) );
				} else {
					notify( Text.fmt.PetDiscoveredHiddenTools({name:user.print(),list:listStr}) );
				}
				CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDiscoveredHiddenTools( {name:user.print(),list:listStr} ), map, zone );
				return;
			}
		}
		
		// Les objets à trouver dans la zone sont issus des ressources disponibles dans la zone
		var tinfo : Tool;
		if( zone.dropCount <= 0 ) {
			var chance = Const.get.OverflowGatherChance;
			if( map.hasMod("NIGHTMODS") && App.isNight() && map.isFar() )
				chance -= 10;
			tinfo = zone.getSpecialDropListItem(9996, chance);
		} else {
			//nightmod is taken into account here
			var chance = user.getGatherChance(map.isFar());
			tinfo = zone.getRandomRessource(chance);
		}
		
		ZoneAction.addDirectly( user, "pick" ); // Tests déjà réalisés, pas besoin d'en refaire :)
		// gather auto
		var fg = DateTools.delta( Date.now(), DateTools.minutes(user.getGatherDuration()) );
		user.endGather = new Date( fg.getFullYear(), fg.getMonth(), fg.getDate(), fg.getHours(), fg.getMinutes(), 0 );
		user.dirt(false);
		user.update();

		if( tinfo == null ) {
			if( fl_isMe ) {
				notify( Text.get.NothingFound );
				if( user.hasWound(W_Eye) )
					appendNotify(Text.get.WoundedEyeHandicap);
				if( user.isDrunk )
					appendNotify(Text.get.DrunkPenalty);
			} else {
				notify( Text.get.PetNothingFound );
				if( user.hasWound(W_Eye) )
					appendNotify(Text.get.PetWoundedEyeHandicap);
				if( user.isDrunk )
					appendNotify(Text.get.PetDrunkPenalty);
			}
			return;
		}

		// une fois découvert on pose l'objet dans la zone.
		// Au joueur de voir s'il peut en faire qqch
		tinfo.isBroken = false;
		getRewards(tinfo, user);
		if( fl_isMe ) {
			notify( Text.fmt.FoundObject( {item:tinfo.print()} ));
		} else {
			notify( Text.fmt.PetFoundObject( {item:tinfo.print()} ));
		}
		if( zone.dropCount < 0 ) {
			appendNotify( Text.get.DriedZone );
		}
		if( user.hasCapacity() && ToolActions.canTakeObject(user,tinfo,true) ) {
			var t = Tool.add(tinfo.toolId, user, true);
		} else {
			appendNotify( if(fl_isMe) Text.get.NoRoomDrop else Text.get.PetNoRoomDrop );
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDropped( {name:user.print(),tool:tinfo.print()} ), map, zone );
			ZoneItem.create( zone, tinfo.toolId );
		}
		zone.dropCount--;
		zone.update();
		return;
	}

	// Action : Explorer un building : une seule fois par jour / 2x pour le Collecteur
	public function doExploreBuilding() {
		if( App.user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			doRefresh();
			return;
		}
		if( App.user.isCamping() )
			return;
		if( ZoneAction.manager.hasDoneActionZone(App.user,  "exploreBuilding" ) ) {
			notify( Text.get.AlreadyDigged );
			doRefresh();
			return;
		}
		// on ne peut pas fouiller un bâtiment qui n'est pas encore déterré
		var user = App.user;
		var zone = App.user.zone;
		var map = db.Map.manager.get( user.mapId, false ); // On évite de locker la ressource
		if( zone.type <= 0 ) {
			doRefresh();
			return;
		}
		if( zone.id == map.cityId ) {
			notify(Text.get.CannotPickOnTown);
			doRefresh();
			return;
		}
		if( !zone.hasBuildingExtracted() ) {
			doRefresh();
			return;
		}
		
		// Bâtiment vide
		if( zone.bdropCount <= 0 ) {
			notify( Text.get.EmptyBuilding );
			doRefresh();
			return;
		}
		ZoneAction.add( App.user, "exploreBuilding", (App.user.job.key == "collec") );
		
		// Les objets à trouver dans la zone sont issus de la liste fournie dans le xml
		var chanceMod = if( App.user.job.key == "collec" ) Const.get.GathererBonus
						else 0;
		
		if( App.user.isDrunk )
			chanceMod -= 20;
		
		if( App.user.hasWound(W_Eye) )
			chanceMod -= 20; // blessure oeil
		
		if( map.hasMod("NIGHTMODS") && App.isNight() && map.isFar() )
			chanceMod -= 10;
		
		var tinfo = zone.getRandomItem( chanceMod );
		if( tinfo == null ) {
			notify( Text.get.NothingFound );
			
			if( user.isDrunk )
				appendNotify(Text.get.DrunkPenalty);
				
			if( App.user.loseCamo() )
				appendNotify(Text.get.LostCamo);
			
			doRefresh();
			return;
		}
		zone.bdropCount --;
		zone.update();
		
		var binfo = XmlData.hashOutsideBuildings.get(zone.type);
		notify( Text.fmt.ExploredBuilding( {building : binfo.print(), item : tinfo.print()} ) );
		if( zone.level >= 18 )
			db.GhostReward.gain( GR.get.explo2 );
		else
			if( zone.level >= 6 )
				db.GhostReward.gain( GR.get.explor );
		
		getRewards( tinfo, user );
		
		if( App.user.hasCapacity() && ToolActions.canTakeObject(tinfo, true) ) {
			Tool.add( tinfo.toolId, App.user, true );
		} else {
			appendNotify( Text.get.NoRoomDrop );
			var m = db.Map.manager.get( App.user.mapId, false ); // On évite de locker la ressource
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDropped( {name:App.user.print(),tool:tinfo.print()} ), map, App.user.zone );
			ZoneItem.create( App.user.zone, tinfo.toolId );
		}
		
		if( App.user.loseCamo() )
			appendNotify( Text.get.LostCamo );
		
		doRefresh();
	}

	private static function getRewards(tinfo:Tool, user:User) {
		if( tinfo.key == "chest_xl" ) {
			db.GhostReward.gain(GR.get.chstxl, user);
		}
	}

	public function doFlee() {
		var user = App.user;
		if( user.isCamping() ) {
			notify( Text.get.ForbiddenWhenCamping );
			doRefresh();
			return;
		}
		if( user.hasTool("camoVest",true) ) {
			notify(Text.get.Forbidden);
			doRefresh();
			return;
		}
		if( user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			doRefresh();
			return;
		}
		// La zone s'est entre temps sortie du pétrin
		if( !user.zone.isInFeist() ) {
			notify(Text.get.NoNeedToFlee);
			doRefresh();
			return;
		}
		if( user.isTerrorized ) {
			notify(Text.get.CantActInTerror);
			doRefresh();
			return;
		}
		if( user.isWounded ) {
			notify(Text.get.CantFleeWhileWounded);
			doRefresh();
			return;
		}
		if( !user.hasPaToMove() ) {
			notify(Text.get.NoMoveLeft);
			doRefresh();
			return;
		}
		user.wound(false);
		user.isBrave = true;
		user.dirt(false);
		user.update();
		notify(Text.fmt.FleeingIsDangerous( {p:"<strong>"+user.getWoundType()+"</strong>" }));
		doRefresh();
	}

	public function doWrestle() {
		var user = App.user;
		
		if( user.isCamping() ) {
			notify( Text.get.ForbiddenWhenCamping );
			doRefresh();
			return;
		}

		if( user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			doRefresh();
			return;
		}

		if( user.hasTool("camoVest",true) || user.zone.isInFeist() && user.isBrave ) {
			notify(Text.get.Forbidden);
			doRefresh();
			return;
		}

		// La zone s'est entre temps sortie du pétrin
		if( !user.zone.isInFeist() ) {
			notify(Text.get.NoNeedToWrestle);
			doRefresh();
			return;
		}

		if( user.isTerrorized ) {
			notify(Text.get.CantActInTerror);
			doRefresh();
			return;
		}

		var zone = user.zone;
		if( zone.zombies <= 0 ){
			notify(Text.get.NoZombiesToKill);
			doRefresh();
			return;
		}

		if( !user.canDoTiringAction(1) ) {
			notify( Text.fmt.NeedPA({n:1}) );
			doRefresh();
			return;
		}

		user.doTiringAction(1);
		user.dirt();
		var m = user.getMapForDisplay();
		var chance = if(user.isDrunk) Math.floor(Const.get.WrestleChance*0.5) else Const.get.WrestleChance;
		if( Std.random(100) < chance ) {
			var control = false;
			var fl_wasInFeist = zone.isInFeist();
			zone.zombies--;

			db.GhostReward.gain( GR.get.killz);
			db.GhostReward.gain( GR.get.wrestl);
			notify(Text.get.WrestledAndKilled);
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideWrestledAndKilled({u:user.print()}), m, zone );
			if( fl_wasInFeist && !zone.isInFeist() ) {
				zone.endFeist = null;
				CityLog.addToZone( CL_OutsideTempEvent, Text.get.OutsideGainedControl, m, zone );
			}
			zone.update();
		} else {
			notify(Text.get.WrestledFailed);
			if( user.isDrunk ) appendNotify(Text.get.DrunkPenalty);
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideWrestledFailed({u:user.print()}), m, zone );
		}
		doRefresh();
	}

	public function doRefresh() {
		var user = App.user;
		var zone = App.user.zone; // lockée
		var map = user.getMapForDisplay();
		// on passe sur le gestionnaire des portes
		if( zone.id == map.cityId ) {
			App.goto("outside/doors");
			return;
		}

		var explo = zone.explo;
		if( explo != null && explo.user == user ) {
			App.goto("explo/");
			return;
		}
		if( user.wasEscorted ) {
			user.wasEscorted = false;
			user.update();
			App.reboot();
			return;
		}
		
		prepareTemplate("outside/main.mtt" );
		
		var pList = zone.getPlayers(null,false);
		var h = zone.getHumanScore(Lambda.map( pList, function( u ) { return {id:u.id, spentHeroDays:u.spentHeroDays, hero:u.hero} ;} ));
		var z = zone.zombies;
		
		App.context.user = user;
		App.context.players = pList;
		App.context.expandedUid = App.request.getInt("expand");
		App.context.canDropPlan = zone.canDropPlan(map);
		
		var pids = Lambda.map( pList, function(u) { return u.id; } );
		App.context.onlineHash = db.Session.getOnlineHash(pids);
		
		if( zone.infoTagEnum != null ) {
			App.context.infoTag = Type.enumIndex(zone.infoTagEnum);
		}
		
		var it = new Array();
		for( key in Type.getEnumConstructs(InfoTags) ) {
			it.push( Text.getByKey(key) );
		}
		App.context.infoTags = it;
		// Case de la ville
		if( zone.id == map.cityId ) {
			App.context.hdom = h;
			App.context.zdom = 0;
			addMapDataToContext( encodeMapData(getMapResponse(zone,h,0)) );
			if( !App.request.exists("noRemind") && user.isNoob && user.steps==0 && user.inTown() ) {
				notify(Text.get.ReminderTutorial);
				App.goto("outside/refresh?noRemind=1");
				return;
			}
			return;
		}
		// on prépare la liste des users à updater (si on en contrôle d'autres)
		var ulist = new List();
		ulist.add(user);
		var squad = db.User.manager.getSquad(user,true);
		for( u in squad ) ulist.add(u);
		// Gather en cours...
		for( u in ulist ) {
			if( u.endGather != null && u.hasDoneActionZone("pick") ) {
				gather(u);
			}
		}
		// cas du joueur sauvé par un héros :)
		if( user.wasRescued ) {
			user.wasRescued = false;
			user.update();
			notify( Text.get.RescuedByAHero );
			App.goto("city/enter");
			return;
		}
		// Interruption du gather pendant un festin
		if( zone.zombies > zone.humans ) {
			for( u in ulist ) {
				if( u.endGather != null ) {
					CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideEndGather( {n:u.name})+debugMsg("ef="+zone.endFeist) , map, zone );
					u.endGather = null;
					u.update();
				}
			}
		}
		// un timer a été enclenché, mais il ne reste plus de temps
		if( zone.endFeist != null && !zone.hasTimeBeforeFeist() ) {
			if( h < z ) {
				CityLog.addToZone( CL_OutsideTempEvent, Text.get.OutsideTimeToFeist, map, zone );
				zone.endFeist = null;
				zone.update();
			}
		}
		
		var zitems = db.ZoneItem.manager._getZoneItems(zone, false, if(user.canDoBannedAction()) null else true );
		App.context.items = sortZoneItems( zitems );
		
		App.context.lostControl = zone.endFeist != null && zone.hasTimeBeforeFeist();
		App.context.noControl = h < z;
		App.context.hdom = h;
		App.context.zdom = z;
		
		var coords = zone.coord( map._getCity() );
		App.context.canMove = canMove(user, zone, h, z);
		App.context.zoneDir = Text.getByKey("AtSector"+zone.direction);
		App.context.title = makeTitle(zone,pList);
		App.context.cityDir = Text.getByKey("ToSector"+((zone.direction+4)%8));
		
		var city = map._getCity();
		App.context.cityCost = Math.abs(zone.x-city.x) + Math.abs(zone.y-city.y);
		App.context.townPortalLimit = Const.get.MaxTownPortalDistance;
		App.context.canUseAggression = map.canUseAggression();
		
		var inBag = user.getInBagTools();
		App.context.hasPicked = user.hasDoneActionZone("pick");
		App.context.inspectBuilding = App.request.exists("inspectBuilding");
		App.context.aggCost = map.getAggressionCost();
		
		var hasCamo = false;
		for( t in inBag ) {
			if( t.key == "camoVest" ) {
				hasCamo = true;
				break;
			}
		}
		App.context.hasCamo = hasCamo;
		addMapDataToContext( encodeMapData(getMapResponse(zone, h, z, pList.length)) );
		
		if( map.hasMod("EXPLORATION") )
			App.context.explo = zone.explo;
		
		var maxTelepDist = db.CityUpgrade.getValueIfAvailableByKey( "tower", 2, map, 0 );
		App.context.canTeleport = zone.level <= maxTelepDist;
		App.context.canPurifyGround = App.user.isShaman;/* App.user.hasThisJob("shaman"); */
		if( App.request.exists("fullLog") ) {
			App.context.logLimited = false;
			CityActions.addLogs(map, zone, 999999);
		} else {
			App.context.logLimited = db.CityLog.manager.countByZone(zone) < Const.get.MaxLogsDefaultOutside;
			CityActions.addLogs(map, zone, Const.get.MaxLogsDefaultOutside);
		}
	}

	public function doGo() {
		var user = App.user;
		if( user.wasRescued ) { // cas du joueur sauvé par un héros :)
			user.wasRescued = false;
			user.update();
			notify( Text.get.RescuedByAHero );
			App.goto("city/enter");
			return;
		}

		if( user.hasLeader() ) {
			notify( Text.get.Forbidden );
			doRefresh();
			return;
		}
		
		if( user.inExplo() ) {
			notify( Text.get.Forbidden );
			doRefresh();
			return;
		}

		if( !user.hasPaToMove()  ) { // plus de PAs ?
			notify(Text.get.NoMoveLeft);
			doRefresh();
			return;
		}

		var squad = db.User.manager.getSquad(user,true);
		var zone = user.zone;
		if( !user.squadCanMove(squad,zone) ) {
			notify(Text.get.SquadCantMove);
			App.goto("outside");
			return;
		}

		var dx = App.request.getInt("x");
		var dy = App.request.getInt("y");
		var currentZoneId = App.request.getInt("z");

		if( zone.id != currentZoneId ) {
			if(currentZoneId==null) {
				db.Error.create("map send no zoneId","user: "+user.name+" #"+user.id+" dx="+dx+" dy="+dy, user);
			}
			App.reboot();
			return;
		}

		var map = user.getMapForDisplay();
		var city = map._getCity();
		if( !checkUserBeforeMove(user, map, zone, city, dx, dy) )
			return;
		
		for( u in squad )
			if( !checkUserBeforeMove(u, map, zone, city, dx, dy) )
				return;
		
		user.isWaitingLeader = false;
		moveUser(user, dx,dy);
		for( u in squad ) {
			if( !u.isOutside ) {
				u.isOutside = true;
			}
			moveUser(u, dx,dy);
		}
		App.context.justMoved = true;
		// on revient en ville
		if( user.zone.id == map.cityId ) {
			for( u in squad ) {
				if( u.onlyEscortToTown && map.hasDoorOpened() ) {
					u.wasEscorted = true;
					u.wasRescued = true;
					u.leader = null;
					u.isWaitingLeader = false;
					u.isOutside = false;
					u.update();
					CityLog.add( CL_OpenDoor, Text.fmt.CL_PetBackToHome( {name:user.print(), pet:u.print()} ), map, u );
					notify( Text.fmt.PetArrivedAtHome({user:u.print()}) );
				}
			}
			App.goto("outside/doors");
			return;
		}
		doRefresh();
	}

	public function doOutside() {
		var user = App.user;
		var map = user.getMapForDisplay();
		App.context.staticSites = db.Site.manager.getAllSitesSplitted(7);
		App.context.staticMySites = db.Site.manager.getMySites(user);
		if( user.wasRescued ) { // cas du joueur sauvé par un héros :)
			user.wasRescued = false;
			user.update();
			notify( Text.get.RescuedByAHero );
			App.goto("city/enter");
			return;
		}
		addMapDataToContext( encodeMapData( getMapData(map, user) ) );
		if( App.request.exists("go") ) {
			App.load( App.request.get("go") );
			return;
		}
		if( db.User.isAtDoorsStatic( user, map.cityId ) )
			App.load("outside/doors");
		else
			App.load("outside/refresh");
	}

	/* ---------------------- UTILE --------------------- */

	// Regarde s'il y a des objets à récupérer : ramasse uniquement
	public static function gather( user: User ) {
		var gatheredTools = db.TempGather.manager._getTools( user );
		if( gatheredTools.length <= 0 )
			return;
		var m = user.getMapForDisplay();
		for( g in gatheredTools ) {
			// quand les fouilles n'ont rien donné
			if( g.toolId == null ) {
				CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideNothingFound( {name:user.print()} ), m, user.zone );
				continue;
			}
			var xmlTool = g.getDescription();
			xmlTool.isBroken = false;
			if( xmlTool==null ) {
				throw "[OutsideActions.gather] Invalid object dropped : TempGather.id="+g.id+" TempGather.userId="+g.userId+" TempGather.toolId="+g.toolId;
				continue;
			} else {
				getRewards(xmlTool, user);
				if( user.hasCapacity() && ToolActions.canTakeObject(user,xmlTool,true) ) {
					var t = Tool.add( g.toolId, user, true);
				} else {
					ZoneItem.create( user.zone, g.toolId );
					App.notification = (Text.get.NoRoomForGather);
					CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDropped( {name:user.print(),tool:xmlTool.print()} ), m, user.zone );
				}
			}
		}
		db.TempGather.manager.deleteTools( user );
	}

	public static function canMove( user:User, ?z:Zone, ?hd, ?zd ) {
		return user.canMove(z);
	}


	function checkUserBeforeMove(user:User, map:Map, zone:Zone, city:Zone, dx:Int,dy:Int) {
		if( Math.abs(dx)>1 || Math.abs(dy)>1 || ( dx==0 && dy==0 ) || ( dx!=0 && dy!=0) ) {
			App.reboot();
			return false;
		}
		
		var targetZone = Zone.manager._getZone( map, zone.x+dx, zone.y+dy );
		if( targetZone == null ) {
			notify( Text.get.UnknownZone );
			App.reboot();
			return false;
		}
		if( zone.isInFeist() ) {
			if( !canMove(user,zone) ) { // utile pour les éclaireurs
				notify(Text.get.LostControl);
				App.goto("outside");
				return false;
			}
		}
		if( user!=App.user && user.onlyEscortToTown ) {
			var distBefore = Math.sqrt( Math.pow( city.x-zone.x, 2 ) + Math.pow( city.y-zone.y, 2 ) );
			var distAfter = Math.sqrt( Math.pow( city.x-(zone.x+dx), 2 ) + Math.pow( city.y-(zone.y+dy), 2 ) );
			if( distAfter > distBefore ) {
				notify( Text.fmt.PetWantToGoHome({user:user.print()}) );
				App.goto("outside");
				return false;
			}
		}
		// terreur
		if( zone.zombies > 5 && user.isTerrorized && Std.random(100) < Const.get.TerrorizedCantMove ) {
			user.losePa( 1 );
			if( user==App.user )
				notify( Text.get.TerrorizedCantMove );
			else
				notify( Text.get.SquadCantMove );
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideTerrorizedCantMove({name:user.print()}), map, zone );
			App.goto("outside");
			return false;
		}
		// blessure jambe
		if( user.hasWound(W_Leg) && Std.random(100) < Const.get.WoundedLegFallProba ) {
			user.losePa( 1 );
			if( user == App.user )
				notify( Text.get.WoundedFalls );
			else
				notify( Text.get.SquadCantMove );
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideWoundedFalls({name:user.print()}), map, zone );
			App.goto("outside");
			return false;
		}
		return true;
	}

	function moveUser(user:User, dx,dy, fl_leaveZone=true) {
		if( fl_leaveZone ) leaveZone(user, dx, dy);
		goToNewZone(user, dx, dy);
	}

	function leaveZone(user:User, dx:Int, dy:Int) {
		// A ce stade là je n'ai pas encore changé de zone
		var x = App.request.getInt("x");
		var y = App.request.getInt("y");
		// le joueur s'en va, on supprime les objets qui ont été trouvés entre temps
		db.TempGather.manager.deleteTools( user );
		user.loseCamp();
		if( user.endGather != null ) {
			user.endGather = null;
			user.update();
		}
		var msg = Text.fmt.OutsideMoved( {name:user.printFull(),to:Utils.getDirection(x,y)} ) + debugMsg("dx="+dx+", dy="+dy);
		checkZoneControlBeforeLeaving(user, msg);
	}

	public function goToNewZone(user:User, dx, dy) {
		var map = user.getMapForDisplay();
		var zone = Zone.manager._getZone( map, user.zone.x + dx, user.zone.y + dy );
		if( zone.id == map.cityId ) {
			// on arrive en ville :)
			user.changeZone(zone);
		} else {
			// Je rentre dans la zone et je peux éventuellement sortir tout le monde du chaos
			// Sinon je vis la situation de la zone telle qu'elle est déjà
			var msg = Text.fmt.OutsideArrived( {name:user.printFull(),from:Utils.getDirection(-dx,-dy)} );
			msg += debugMsg("h="+zone.humans+" z="+zone.zombies+" me="+user.getControlScore());
			CityLog.addToZone( CL_OutsideMessage, msg, map, zone );
			if( user.job != null && user.job.key == "eclair" ) {
				if( user.hasTool("camoVest") && Std.random(100) < zone.getDetectionChance(0) ) {
					user.loseCamo(true);
					notify(Text.get.CamoDetected);
					appendNotify(Text.get.LostCamo);
				}
				zone.scout++;
			}
			user.changeZone(zone);
			updateZoneControl( zone, user.getControlScore(), map );
			user.validateActivity(Common.BIT_OUT);
		}
	}
	
	function checkZoneControlBeforeLeaving( leavingUser: User, leaveMessage : String ) {
		var zone = leavingUser.zone; // zone est locké, on ne peut pas modifier les informations
		var fl_hadControl = zone.humans >= zone.zombies;
		
		//zone.changeHumanScore( -leavingUser.getControlScore(), false );
		//force reupdate in case there's a guide on the zone, and that his score does not update
		zone.recalcHumanScore([leavingUser], false);
		
		var z = zone.zombies;
		var h = zone.humans;
		var m = leavingUser.getMapForDisplay();
		if( m.hasMod("EXPLORATION") && zone.explo != null && zone.explo.user == leavingUser) {
			var explo = db.Explo.manager.get(zone.id);
			if( explo.user == leavingUser ) {
				ExploActions.updateOxygen(explo, false);
				explo.user = null;
				explo.update();
			}
		}
		var m = leavingUser.getMapForDisplay();
		var fl_logMove = true;
		if( ZoneAction.manager.hasDoneActionZone(leavingUser, "smokeBomb") ) {
			// fumigène
			var cl = CityLog.manager.getLast(leavingUser.zoneId, Text.get.OutsideSmokeBomb);
			if( cl != null && cl.dateLog.getTime() >= DateTools.delta(Date.now(), -DateTools.minutes(3)).getTime() )
				fl_logMove = false;
			ZoneAction.manager.deleteAction(leavingUser, "smokeBomb");
		}
		if(fl_logMove) {
			// msg de départ de la zone
			leaveMessage += "<span style='display:none'>(h="+zone.humans+" z="+zone.zombies+")</span>";
			CityLog.addToZone( CL_OutsideMessage, leaveMessage, m, zone );
		}
		
		zone.tempChecked = true;
		zone.checked = true;
		var last = ( zone.countPlayers() - 1 ) <= 0;
		if( last ) { // cas du dernier qui part
			CityLog.manager.clearLogs(zone.id);
			if( zone.infoTagEnum == IT_Help ) {
				zone.infoTag = null;
				zone.infoTagEnum = null;
			}
			zone.endFeist = null;
			zone.update();
			return;
		}
		
		if( h < z ) {
			// je quitte une zone où il n'y a plus de contrôle
			if( zone.isInFeist() && leavingUser.isBrave && zone.endFeist == null ) {
				CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideFled({n:leavingUser.name}), m, zone );
			} else {
				if( fl_hadControl ) {
					zone.endFeist = DateTools.delta( Date.now(), DateTools.minutes(Const.get.ControlTime) );
					CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideFeistTime({n:leavingUser.name}) + debugMsg("ef="+zone.endFeist), m, zone );
				}
			}
		} else {
			zone.endFeist = null;
		}
		zone.update();
	}

	function printDebugStatus(h:Float,z:Float) {
		return "(h="+h+" z="+z+")";
	}

	public static function updateZoneControl( zone : Zone, scoreDelta:Int, map : Map ) {
		zone.tempChecked = true;
		zone.checked = true;
		//TODO  S14 fix bug with guide and control
		//zone.changeHumanScore(scoreDelta, false);
		zone.recalcHumanScore(false);
		
		var fl_wasEmpty = zone.humans == 0;
		var fl_wasUnderControl = zone.zombies <= zone.humans;
		if( fl_wasEmpty && scoreDelta >= 0 ) {// Premier arrivé dans la zone
			zone.endFeist = null;
		} else { // il y a déjà du monde, on vérifie le nouvel état de la zone en cours
			if( fl_wasUnderControl && zone.zombies > zone.humans ) {
				// on vient de perdre le contrôle
				zone.endFeist = DateTools.delta( Date.now(), DateTools.minutes(Const.get.ControlTime) );
				CityLog.addToZone( CL_OutsideTempEvent, Text.get.OutsideLostControl, map, zone );
			} else {
				if( zone.zombies <= zone.humans ) {
					zone.endFeist = null;
					if( !fl_wasUnderControl ) {// on vient de gagner le contrôle
						CityLog.addToZone( CL_OutsideTempEvent, Text.get.OutsideGainedControl, map, zone );
					}
				}
			}
		}
		zone.update();
	}
	
	/*----------------------------- GESTION DE LA CARTE SWF -----------------------------------*/

	// Mise à jour de la description de la map plus adaptée aux sous-sections qu'au chargement initial de la carte
	// En effet, c'est l'objet resp qui nous intéresse en premier lieu ici
	function getMapResponse(?z, ?hd, ?zd, ?countP) {
		var user = App.user;
		var zone = if( z == null ) App.user.zone else z;
		var h = if( hd == null ) zone.getHumanScore() else hd;
		var z = if( zd == null ) zone.zombies else zd;
		var cp = if( countP == null ) zone.countPlayers() else countP;
		// plus de PA, on peut pas faire grand chose....
		if( user.getPa() <= 0 ) {
			var resp = getNoMoveResponse( zone, cp );
			return {
				response		: resp,
				outsideMapInit	: null,
			}
		}
		// cas du joueur non éclaireur qui ne peut pas se déplacer en cas de festin
		if( ( user.job == null || user.job.key != "eclair" ) && !canMove( user, zone, h, z ) ) {
			var resp = getNoMoveResponse( zone, cp );
			return {
				response		: resp,
				outsideMapInit	: null,
			}
		}
		// Cas du joueur ni éclaireur, ni fouineur
		if( ( user.job == null || ( user.job.key!="eclair" && user.job.key!="collec" ) ) ) {
			var resp : OutMapResponse = {
									_zid: zone.id,
									_neig: new Array(),
									_neigDrops: new Array(),
									_c: if(zone.diggers > 0) -1 else zone.type,
									_z: zone.zombies,
									_h: cp,
									_t: zone.infoTag,
									_state: zone.isInFeist(),
									_m: if( !canMove(user, zone,h,z) ) -1 else user.getPa() };

			return {
				response		: resp,
				outsideMapInit	: null,
			}
		} else {
			if( user.job.key == "eclair" ) {
				// Cas de l'éclaireur : affichage des infos des cases adjacentes
				var umap = db.Map.manager.get(  user.mapId , false );
				var zones = Zone.manager._getZonesForSWFMap(umap);
				var neig = new Array();
				if( user.job != null && user.job.key == "eclair" ) {
					neig = getScoutEstimations(zones, zone, user );
				}

				var resp : OutMapResponse = {
										_zid: zone.id,
										_neig: neig,
										_neigDrops: new Array(),
										_c: if(zone.diggers > 0) -1 else zone.type,
										_z: zone.zombies,
										_h: cp,
										_t: zone.infoTag,
										_state: zone.isInFeist(),
										_m: if( !canMove(user, zone, h, z) ) -1 else user.getPa() };

				return {
					response		: resp,
					outsideMapInit	: null,
				}
			}

			if( user.job.key == "collec" ) {
				// Cas du fouineur : affichage des infos des cases adjacentes
				var umap = db.Map.manager.get(  user.mapId , false );
				var zones = Zone.manager._getZonesForSWFMap(umap);
				var neigDrops = new Array();
				neigDrops = getCollecEstimations(zones, zone, user );

				var resp : OutMapResponse = {
										_zid: zone.id,
										_neig: new Array(),
										_neigDrops: neigDrops,
										_c: if(zone.diggers>0) -1 else zone.type,
										_z: zone.zombies,
										_h: cp,
										_t: zone.infoTag,
										_state: zone.isInFeist(),
										_m: if( !canMove(user,zone,h,z) ) -1 else user.getPa() };

				return {
					response		: resp,
					outsideMapInit	: null,
				}
			}
		}
		return null; // impossible
	}
	
	// Initialisation de départ de la carte
	public static function getMapData(map:Map, user:User, ?z:Zone,?hd:Int,?zd:Int,?countP:Int) {
		var zone = if( z == null ) user.zone else z;
		var h = if( hd == null ) zone.getHumanScore() else hd;
		var z = if( zd == null ) zone.zombies else zd;
		var cp = if( countP == null ) zone.countPlayers() else countP;
		// Zones de la carte en cours
		var zones : List<Zone> = Zone.manager._getZonesForSWFMap(map);
		var zoneTypesFiltered = getZoneTypes( zones, zone, user );
		var zoneTypesGlobal = getZoneTypes( zones, zone );
		// détails de chaque zone
		var details : Array<OutMapDetail> = getDetails( zones );
		// Liste des infos de zones adjacentes pour l'éclaireur
		var neig = new Array();
		var neigDrops = new Array();
		if( user.hasThisJob("eclair") ) {
			neig = getScoutEstimations(zones, zone, user );
		} else if( user.hasThisJob("collec") ) {
			neigDrops = getCollecEstimations(zones, zone, user );
		}
		// map client
		var resp : OutMapResponse = {
								_zid: zone.id,
								_neig: neig,
								_neigDrops: neigDrops,
								_c: if(zone.diggers > 0) -1 else zone.type,
								_z: zone.zombies,
								_h: cp,
								_t: zone.infoTag,
								_state: zone.isInFeist(),
								_m: if( !canMove(user, zone, h, z) ) -1 else user.getPa(),
						};

		var hours = Date.now().getHours();
		var fl_betterMap = user.hasCityBuilding("betterMap");
		var om : OutMapInit = { _w: map.width,
								_h : map.width,
								_x: zone.x,
								_y : zone.y,
								_city : map.name,
								_view : zoneTypesFiltered,
								_global : zoneTypesGlobal,
								_mid : map.id,
								_map : true,
								_up : fl_betterMap,
								_hour : hours,
								_b : XmlData.getOutsideBuildingNames(true),
								_r : resp,
								_details : details,
								_town : false,
								_e : db.Expedition.manager.getForSwf(map),
								_path : null,
								_editor : false,
								_slow : user.slowMode,
								_users : null,
						};

		// utilisé par le swf map en ville
		var zonesHash : IntHash<Zone> = new IntHash();
		for(z in zones)
			zonesHash.set(z.id, z);
		return {
			zonesHash		: zonesHash,
			response		: resp,
			outsideMapInit	: om,
		}
	}

	public static function encodeMapData(data) {
		return {
			rawResponse		: data.response,
			response		: MapCommon.encode(haxe.Serializer.run(data.response)),
			outsideMapInit	: MapCommon.encode( haxe.Serializer.run(data.outsideMapInit) ),
		}
	}

	public static function addMapDataToContext(data) {
		App.context.rawResponse = data.rawResponse;
		App.context.response = data.response;
		App.context.outsideMapInit = data.outsideMapInit;
	}

	public static function getZoneTypes( zones : List<Dynamic>, zone, ?user:User ) : Array<Int> {
		var zz = new Array();
		for( z in zones ) {
			var t = null;
			if( z.id == zone.id ) {
				t = z.type;
			} else {
				if( user == null )
					t = if( z.checked ) z.type else null;
				else
					t = if( user.hasVisitedByZoneId(z.id) ) z.type else null;
			}
			if( z.diggers > 0 && t != null ) t = -1;
			if( z.type == 1 ) t = 1;
			zz.push(t);
		}
		return zz;
	}

	public static function getDetails( zones : List<Dynamic> ) {
		var details = new Array();
		for( z in zones ) {
			var z:Zone = cast z;
			var hasSoul = false;
			if( z.type != Zone.TYPE_CITY && App.user.isShaman ) {
				hasSoul =  db.ZoneItem.manager.exists( z, XmlData.getToolByKey("soul").toolId )
						|| db.ZoneItem.manager.exists( z, XmlData.getToolByKey("red_soul").toolId )
						|| db.ExploItem.manager.exists( z, XmlData.getToolByKey("soul").toolId )
						|| db.ExploItem.manager.exists( z, XmlData.getToolByKey("red_soul").toolId );
			}
			var realType = if( z.diggers > 0 ) -1 else z.type;
			if( z.type == 1 ) {
				details.push({ _c:1, _z:0, _t:0, _nvt:false, _s:hasSoul });
			} else if( z.checked && z.tempChecked )  {
				details.push({ _c:realType, _z:z.zombies, _t:z.infoTag, _nvt:false, _s:hasSoul });
			} else if( z.tempChecked )  {
				details.push({ _c:realType, _z:z.zombies, _t:z.infoTag, _nvt:false, _s:hasSoul }) ;
			} else if( z.checked ) {
				details.push({ _c:realType, _z:0, _t:z.infoTag, _nvt:true, _s:hasSoul });
			} else details.push({ _c:null, _z:null, _t:null, _nvt:null, _s:hasSoul });
		}
		return details;
	}

	public static function getScoutEstimations( zones : List<Dynamic>, zone, user ){
		var neig = new Array();
		for( z in zones ) {
			var rseed = new mt.Rand(user.id + z.id);
			var error = Std.int( Math.max(0, 3 - Zone.getStaticScoutLevel(z.scout)) );
			var delta = if( error == 0 ) 0 else ( rseed.random(error) * (rseed.random(2) * 2 - 1) );
			var est = Std.int( Math.max( 0, (z.zombies + delta) ) );
			if( z.zombies == 0 ) est = 0;
			if( z.x == zone.x - 1 && z.y == zone.y ) neig[3] = est; // left
			if( z.x == zone.x + 1 && z.y == zone.y ) neig[1] = est; // right
			if( z.x == zone.x && z.y == zone.y - 1 ) neig[0] = est; // up
			if( z.x == zone.x && z.y == zone.y + 1 ) neig[2] = est; // down
		}
		return neig;
	}

	public static function getCollecEstimations( zones : List<Dynamic>, zone, user ) {
		var neigDrops = new Array();
		for( z in zones ) {
			var hasDrops = z.dropCount>0 || (z.type>1 && z.bdropCount>0);
			if( !z.checked ) hasDrops = null;
			if( z.type == 1 ) hasDrops = null; // ville
			if( z.x == zone.x - 1 && z.y == zone.y ) neigDrops[3] = hasDrops; // left
			if( z.x == zone.x + 1 && z.y == zone.y ) neigDrops[1] = hasDrops; // right
			if( z.x == zone.x && z.y == zone.y - 1 ) neigDrops[0] = hasDrops; // up
			if( z.x == zone.x && z.y == zone.y + 1 ) neigDrops[2] = hasDrops; // down
		}
		return neigDrops;
	}

	function getNoMoveResponse( zone, cp ) {
		return {
				_zid: zone.id,
				_neig: new Array(),
				_neigDrops: new Array(),
				_c: if(zone.diggers>0) -1 else zone.type,
				_z: zone.zombies,
				_h: cp,
				_t: zone.infoTag,
				_state: zone.isInFeist(),
				_m: -1
			};
	}

	function sortZoneItems(ziList:List<ZoneItem>) {
		var arr = Lambda.array(ziList);
		arr.sort( function(a,b) {
			var ta = XmlData.getTool(a.toolId);
			var tb = XmlData.getTool(b.toolId);
			if( ta.name.toLowerCase() < tb.name.toLowerCase() ) return -1;
			if( ta.name.toLowerCase() > tb.name.toLowerCase() ) return  1;
			return Std.random(3) - 1; // randomisation pour cacher les items empoisonnés
		} );
		return Lambda.list(arr);
	}

	function doUseArmageddon() {
		if( App.user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			doRefresh();
			return;
		}
		if( App.user.isCamping() )
			return;
			
		if( !App.user.armageddon || App.user.usedArmageddon ) {
			notify(Text.get.Forbidden);
			App.goto("outside/refresh");
			return;
		}
		
		var zone = App.user.zone;
		if( zone.zombies <= 0 || !zone.isInFeist() ) {
			notify(Text.get.Useless);
			App.goto("outside/refresh");
			return;
		}
		
		var bonus = 0;
		if( App.user.map.hasMod("NIGHTMODS") && App.isNight() )
			bonus += 25;
		
		if( Std.random(100) < Const.get.ArmageddonPowerChance+bonus ) {
			var d = Const.get.ArmageddonPowerDuration;
			var z = Std.int( Math.min(zone.zombies,1) );
			zone.zombies -= z;
			
			var base = if(zone.endFeist!=null) zone.endFeist else Date.now();
			zone.endFeist = DateTools.delta( base, DateTools.minutes(d) );
			zone.update();
			
			db.GhostReward.gain(GR.get.killz, z);
			
			notify( Text.fmt.UsedArmageddon({d:d}) );
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideArmageddon( {name:App.user.print(),z:z, d:d} ), App.user.getMapForDisplay(), App.user.zone );
		} else {
			notify( Text.get.UsedArmageddonFailed );
		}
		App.user.usedArmageddon = true;
		App.user.update();
		App.goto("outside/refresh");
	}

	function doUpgradeDefense() {
		var user = App.user;
		var map = user.getMapForDisplay();
		if ( !map.hasMod("CAMP") ) 
			return;
		
		if( user.hasLeader() )
			return;
		
		var zone = user.zone;
		if( !user.canDoTiringAction(1) ) {
			notify( Text.fmt.NeedPA({n:1}) );
			App.goto("outside/refresh?inspectBuilding=1");
			return;
		}
		if( zone.defense >= Const.get.CampMaxDefense ) {
			notify( Text.get.CampMaxed );
			App.goto("outside/refresh?inspectBuilding=1");
			return;
		}

		zone.defense += Const.get.CampDefenseAction;
		zone.update();
		user.doTiringAction(1);
		notify(Text.get.CampUpgraded);
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideUpgradeDefense( {name:App.user.print()} ), user.getMapForDisplay(), zone );
		App.goto("outside/refresh?inspectBuilding=1");
	}

	function doReportZoneProblem() {
		var zone = App.user.zone;
		if( db.ZoneAction.manager.hasDoneAction(App.user,"zoneReport_"+zone.id) ) {
			notify(Text.get.AlreadyDoneZone);
			App.goto("outside/refresh");
			return;
		}

		db.ZoneAction.add( App.user, "zoneReport_"+zone.id );
		var fl_wasInFeist = zone.isInFeist();
		var e = zone.logError("manual report");
		var delta = zone.recalcHumanScore(false);
		if( e != null )
			e.error+="\nFIX APPLIED :\ndelta="+delta+"\n";
		if( fl_wasInFeist && !zone.isInFeist() ) {
			zone.endFeist = null;
			if(e!=null)
				e.error+="feist disabled\n";
		}
		if(e != null)
			e.update();
		zone.update();
		notify(Text.get.ErrorReported);

		App.goto("outside/refresh");
	}

	function makeTitle(zone:Zone, users:Array<User>) {
		var str = "";
		var h = Date.now().getHours();
		if( h >= 18 && h <= 19 ) {
			str += Text.get.OutTitle_Sunset;
		} else if( h >= 20 || h <= 5 ) {
			str += Text.get.OutTitle_Night;
		} else if( h >= 6 && h <= 8 ) {
			str += Text.get.OutTitle_Sunrise;
		} else if( h >= 9 && h <= 11 ) {
			str += Text.get.OutTitle_Morning;
		} else {
			str += Text.get.OutTitle_Normal;
		}

		if( users.length == 1 ) {
			str += Text.get.OutTitle_Alone;
		} else if( users.length == 2 ) {
			var friend = if(users[0]==App.user) users[1] else users[0];
			str += Text.fmt.OutTitle_Duo({name:friend.name});
		} else if( users.length > 2 ) {
			str += Text.get.OutTitle_Group;
		}
		if( zone.isBuilding() ) {
			if( zone.hasBuildingExtracted() ) {
				str += Text.fmt.OutTitle_Building({dir:Text.getByKey("ToSector"+zone.direction)});
			} else {
				str += Text.get.OutTitle_Ruin;
			}
		}
		if( zone.isInFeist() ) {
			str += Text.get.OutTitle_Feist;
		} else {
			if( !zone.isBuilding() ) {
				str += Text.fmt.OutTitle_Calm({dir:Text.getByKey("AtSector"+zone.direction)});
			}
		}
		return str;
	}

	function doSearchGarbages() {
		var map = App.user.getMapForDisplay();
		if( !map.hasMod("BANNED") ) return;
		
		if( !App.user.canDoBannedAction(map) || App.user.zoneId!=map.cityId || !App.user.isOutside ) {
			notify(Text.get.Forbidden);
			if( App.user.zoneId!=map.cityId ) {
				doRefresh();
			}
			else {
				App.goto("outside/doors");
			}
			return;
		}
		if( !App.user.canDoTiringAction(1) ) {
			notify( Text.fmt.NeedPA({n:1}) );
			App.goto("outside/doors");
			return;
		}
		if( !App.user.hasCapacity(1) ) {
			notify( Text.fmt.NeedRoom({n:1}) );
			App.goto("outside/doors");
			return;
		}
		if( db.ZoneAction.manager.hasDoneCountedActionZone(App.user,"searchGarbages",App.user.getGarbageSearchLimit()) ) {
			notify( Text.fmt.AlreadyDoneCounted({n:App.user.getGarbageSearchLimit()}) );
			App.goto("outside/doors");
			return;
		}
		db.ZoneAction.add(App.user,"searchGarbages", true);

		var zone = App.user.getZoneForDisplay();
		var found = zone.getSpecialDropListItem(9994,Const.get.GarbageSearchChance);
		App.user.dirt(false);
		App.user.doTiringAction(1);
		if( found != null ) {
			notify( Text.fmt.GarbageFoundObject({item:found.print()}) );
			Tool.add(found.toolId, App.user, true );
		} else {
			notify(Text.get.GarbageNothingFound);
		}

		appendNotify( Text.fmt.UsedPA({n:1}) );

		App.goto("outside/doors");
	}

	function doHideTools() {		
		var zone = App.user.getZoneForDisplay();
		var map = App.user.getMapForDisplay();
		if( !map.hasMod("BANNED") ) return;
		
		if( map.cityId==zone.id || !App.user.canDoBannedAction() ) {
			Text.get.Forbidden;
			doRefresh();
			return;
		}
		
		if( !App.user.canDoTiringAction(Const.get.HideToolsCost) ) {
			notify( Text.fmt.NeedPA({n:Const.get.HideToolsCost}) );
			doRefresh();
			return;
		}
		
		var tools = Lambda.filter( App.user.getInBagTools(true), function(t) { return !t.soulLocked; } );
		if( tools.length == 0 ) {
			notify( Text.get.Useless );
		} else {
			var fl_success = map.chaos || db.Zone.manager.countUnbannedPlayers(zone)==0;
			var list = new List();
			for( t in tools ) {
				ZoneItem.create(zone, t.toolId, t.isBroken, !fl_success);
				t.delete();
				list.add(t);
			}
			if( fl_success )
				notify(Text.get.HasHiddenTools);
			else {
				CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideToolsHidden({name:App.user.print(), list:ToolActions.printList(list)}), map, zone);
				notify(Text.get.HideToolsDetected);
			}
			App.user.doTiringAction(Const.get.HideToolsCost);
			appendNotify( Text.fmt.UsedPA({n:Const.get.HideToolsCost}) );
			if( App.user.loseCamo() ) {
				appendNotify(Text.get.LostCamo);
			}
		}
		doRefresh();
	}

	public function doSettleCamp() {
		var fl_tomb = App.request.getInt("tomb",0) == 1;
		var user = App.user;
		var map = user.getMapForDisplay();
		if( !map.hasMod("CAMP") )
			return;
		
		if( user.hasLeader() )
			return;
		
		var zone = user.getZoneForDisplay();
		
		if( zone.id == map.cityId )
			return;
			
		if( user.isCamping() )
			return;
			
		if( fl_tomb && !user.canDoTiringAction(1) ) {
			notify( Text.fmt.NeedPA({n:Const.get.PA_ExtractBuilding}) );
			doRefresh();
			return;
		}

		var bonus = if(fl_tomb) Const.get.CampTombBonus else 0;
		var c = user.getCampingChance(bonus);
		user.isWaitingLeader = false;
		user.dropAllSquad();
		user.campStatus = Std.random(100) < c;
		user.lastCampChance = c;
		user.endGather = null;
		if( fl_tomb )
			user.doTiringAction(1);
		else
			user.update();
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideCamp( {name:user.print()} ), map, zone );
		doRefresh();
	}

	public function doLeaveCamp() {
		if( App.user.hasLeader() )
			return;
		if( !App.user.map.hasMod("CAMP") )
			return;
		if( !App.user.isCamping() )
			return;
		App.user.loseCamp();
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideCampLeft( {name:App.user.print()} ), App.user.getMapForDisplay(), App.user.getZoneForDisplay() );
		doRefresh();
	}

	//update shaman 2.0
	public function doPurifyGround() {
		var user = App.user;
		if( !user.isShaman ) {
			return;
		}
		if( ZoneAction.manager.hasDoneActionZone( user, "rainDance" ) ) {
			notify(Text.get.ShamanRainDanceZoneLimited);
			doRefresh();
			return;
		}
		
		var charlatanActions = user.getCharlatanActions();
		if( charlatanActions < Const.get.ShamanRainDanceCost ) {
			notify(Text.get.OutsideShamanCantMakeRain);
			doRefresh();
			return;
		}
		
		user.useCharlatanActions(Const.get.ShamanRainDanceCost);
		user.update();
		notify(Text.get.ShamanRainDance);
		var zone = user.zone;
		// cela fonctionne
		if( Std.random(100) < Const.get.ShamanRainChance ) {
			if( user.zoneId == user.map.cityId ) {
				var map = Map.manager.get( user.mapId );
				map.water += Const.get.ShamanRainWell;
				map.update();
				
				CityLog.add( CL_GiveWater, Text.fmt.CL_Shaman_RainCity({user:user.print(), count:Const.get.ShamanRainWell}), map );
				appendNotify(Text.get.ShamanRainDanceCitySuccess);
			} else {
				var kills = 3 + Std.random(4);
				if( kills > zone.zombies ) kills = zone.zombies;
				zone = Zone.manager.get(zone.id, true);
				zone.kills += kills;
				zone.zombies -= kills;
				zone.update();
				Zone.manager.updateHumanScores(user.map);
				
				CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideRain( { user:user.print(), count:kills } ), user.getMapForDisplay(), zone );
				appendNotify(Text.get.ShamanRainDanceOutsideSuccess);
			}
		} else { //echec
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsidePurifyZoneFail( { user:user.print() } ), user.getMapForDisplay(), zone );
			appendNotify(Text.get.ShamanRainDanceFail);
		}
		db.ZoneAction.addDirectly( user, "rainDance" );
		doRefresh();
	}
	
	public static function debugMsg(str:String) {
		return "<span style='display:none'>("+str+")</span>";
	}
}
