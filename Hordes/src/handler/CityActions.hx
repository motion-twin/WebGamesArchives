package handler;
import db.Cadaver;
import db.Zone;
import db.CityLog;
import db.Tool;
import db.GatheredObject;
import db.Complaint;
import db.Map;
import db.User;
import db.CityBuilding;
import db.ZoneItem;
import db.Expedition;
import tools.TextTransformer;
import Common;
import MapCommon;

using Lambda;
using Std;
class CityActions extends Handler<Void>
{
	public function new() {
		super();
		
		inTown( "co",					"city/citizen_office.mtt",	doCitizenOffice );
		inTown( "seeClint",				"city/clint.mtt",			doSeeClint );
		inTown( "well",					"city/well.mtt",			doWell );
		inTown( "seeCadaver",			"city/cadaver.mtt",			doSeeCadaver );
		inTown( "well_water",			doGetWater );
		inTown( "giveWater",			doGiveWater );
		inTown( "devourDead",			doDevourDead );
		inTown( "waterDead",			doWaterDead );
		inTown( "throwDead",			doThrowDead );
		inTown( "cookDead",				doCookDead );
		inTown( "complaint",			doComplaint );
		inTown( "removeComplaint",		doRemoveComplaint );
		inTown( "recycle",				doRecycle );
		
		inTown( "createExp",			doCreateExp );
		inTown( "deleteExp",			doDeleteExp );
		inTown( "exp",					doExp );
		
		inTown( "door",					"city/door.mtt",			doDoor );
		inTown( "openDoor",				"city/door.mtt",			doOpenDoor );
		inTown( "closeDoor",			"city/door.mtt",			doCloseDoor );
		
		inTown( "buildings",			"city/buildings.mtt",		doBuildings);
		inTown( "participateBuild",		doParticipateBuild );
		inTown( "repairBuilding",		doRepairBuilding );
		inTown( "recommendBuilding",	doRecommendBuilding ) ;
		
		inTown( "enter",				"city/base.mtt",	doEnterCity );
		inTown( "refine",				"city/refine.mtt",	doRefine );
		inTown( "refineItem",			doRefineItem );
		
		inTown( "bank",					"city/bank.mtt",	doBank);
		inTown( "emptyBagBank",			"city/bank.mtt",	doEmptyBagBank );
		inTown( "takeFromCity",			"city/bank.mtt",	doTakeFromCity );
		inTown( "giveTown",				"city/bank.mtt",	doGiveTown );
		
		// dispo en ville et hors ville
		ingame( "heroSavePeople",		doHeroSavePeople );
		ingame( "default",				"city/default.mtt");
		outside( "crossDoors",			doCrossDoors );
		inTown( "leave",				doLeaveTown );
		
		if( App.user.map != null && App.user.map.hasMod("GUARDIAN") )
		{
			inTown( "guardCity",			"city/guard.mtt", doGuardCity );
			inTown( "unguardCity",			"city/guard.mtt", doUnGuardCity );
			inTown( "guard",				"city/guard.mtt", doDefaultGuard );
		}
		
		inTown( "tower",				"city/tower.mtt", doTower );
		inTown( "towerInspect",			doTowerInspect );
		inTown( "catapult",				"city/catapult.mtt", doCatapult );
		inTown( "catapultMaster",		doCatapultMaster );
		inTown( "catapultLaunch",		doCatapultLaunch );
		inTown( "conspirate",			doConspirate );
		inTown( "voteUpgrade",			doVoteUpgrade );
		inTown( "upgrades",				"city/upgrades.mtt", doUpgrades );
		inTown( "setHeroMsg",			doSetHeroMsg );
		inTown( "refillWaterWeapons",	doRefillWaterWeapons );
		inTown( "giveTool",				doGiveTool );
		inTown( "dump",					"city/dump.mtt",	doDump );
		inTown( "dumpInstall",			doDumpInstall );
		inTown( "revealBuilding", 		doRevealBuilding );
		inTown( "curativeHelp",     	doCurativeHelp );
		inTown( "elect",     			"city/election.mtt", doElection);
	}
	
	function doCurativeHelp() {
		var user = App.user;
		var map = user.getMapForDisplay();
		
		if( !user.isShaman )
			return;
		
		if( !App.request.exists("uid") ) {
			App.goto("city/co");
			return;
		}
		
		var id = Std.parseInt(App.request.get("uid") );
		if( id == user.id ) {
			App.goto("city/co");
			return;
		}
		
		var clint = User.manager.get( id );
		if( clint == null ) {
			notify(Text.get.UnknownUser);
			App.goto("city/co");
			return;
		}
		if ( clint == user ) 
			return;
		
		if( !clint.playsWithMe( user ) || !clint.inTown() ) {
			notify(Text.get.ShamanCantHealUser);
			App.goto("city/co");
			return;
		}
		
		if( clint.hasDoneActionZone( "curativeHelped" ) ) {
			notify(Text.get.ShamanCantHealUser);
			App.goto("city/co");
			return;
		}
		
		if( user.hasDoneCountedActionZone("curativeHelp", 2) ) {
			notify(Text.get.ShamanHealRestricted);
			App.goto("city/co");
			return;
		}
		
		var cost = Const.get.ShamanHealCost;
		var charlatanActions = user.getCharlatanActions();
		
		if( user.isTerrorized || user.isDrunk || user.isDrugged || cost > charlatanActions ) {
			notify(Text.get.ShamanCantHeal);
			App.goto("city/co");
			return;
		}
		
		var status = [];
		for( s in ["isTerrorized", "isDrunk", "isDrugged", "isInfected"] ) {
			if( Reflect.field(clint, s) == true )
				status.push(s);
		}
		
		if( status.length == 0 ) {
			notify(Text.get.ShamanCantHealUser);
			App.goto("city/co");
			return;
		}
		
		var canHelp = Std.random(100) < Const.get.ShamanSoulCurativeChance;
		if( canHelp ) {
			var injured = Std.random(100) < Const.get.ShamanSoulCurativeRisk;
			var s = status[Std.random(status.length)];
			switch( s ) {
				case "isTerrorized": // joueur terrorisé
					notify(Text.fmt.ShamanHealTerror( { clint:clint.print() } ));
					clint.calmDown(true);
					if( injured ) {
						user.isTerrorized = true;//TODO ADD Notification
						appendNotify(Text.get.ShamanHealTerrorInjured);
					}
				case "isDrunk" :
					notify(Text.fmt.ShamanHealAlcohol( { clint:clint.print() } ));
					clint.isDrunk = false;
					if( injured ) {
						user.isDrunk = true; 	//TODO ADD Notification
						appendNotify(Text.get.ShamanHealAlcoholInjured);
					}
				case "isDrugged" :
					notify(Text.fmt.ShamanHealDrug( { clint:clint.print() } ));
					clint.isDrugged = false;
					if( injured ) {
						user.isDrugged = true; 	//TODO ADD Notification
						appendNotify(Text.get.ShamanHealDrugInjured);
					}
				case "isInfected" :
					notify(Text.fmt.ShamanHealInfection( { clint:clint.print() } ));
					clint.isInfected = false;
					if( injured ) {
						user.isInfected = true; //TODO ADD Notification
						appendNotify(Text.get.ShamanHealInfectionInjured);
					}
				default : throw "Impossible";
			}
			CityLog.add(CL_Heal, Text.fmt.CL_Shaman_Heal( { clint:clint.print(), user:user.print() } ), map);
		} else {
			notify( Text.fmt.ShamanHealFailed( { clint:clint.print() } ) );
		}
		// le joueur
		user.useCharlatanActions(cost);
		
		user.update();
		clint.update();
		//
		db.ZoneAction.add( user, "curativeHelp" );
		db.ZoneAction.add( clint, "curativeHelped", true );
		//
		App.goto( "city/seeClint?id=" + clint.id );
	}
	
	function doDefaultGuard() {
		var user = App.user;
		var map = user.map;
		if ( !map.hasMod("GUARDIAN") ) return;
		
		App.context.roundPathBuilding = XmlData.getBuildingByKey("roundPath");
		App.context.hasRoundPath = map.hasCityBuilding("roundPath");
		
		//check if a guard has a tool : chkspk which impacts all the guards defense
		var hasSpeech = false;
		var lguards = db.User.manager.getGuards(map);
		var count = lguards.length;
		for ( g in lguards ) {
			//discours rassurant multicoloré
			if ( g.hasTool("chkspk", true) ) {
				hasSpeech = true;
				break;
			}
		}
		
		App.context.hasSpeech = hasSpeech;
		if ( hasSpeech )
		{
			App.context.speechDef = lguards.length * (2 * data.Guardians.BASE_DEF);
			App.context.speechName = XmlData.getToolByKey("chkspk").name;
		}
	}
	
	function doGuardCity() {
		var user = App.user;
		var map = user.map;
		if ( !map.hasMod("GUARDIAN") ) return;
		
		if ( !map.hasCityBuilding("roundPath") ) {
			var b = XmlData.getBuildingByKey("roundPath");
			notify( Text.fmt.BuildingRequired( { building:b.name } ) );
		}
		else if( !user.isCityGuard ) {
			user.isCityGuard = true;
			user.update();
			notify(Text.get.guard_city );
		}
		App.goto("city/guard");
	}

	function doUnGuardCity() {
		var user = App.user;
		var map = user.map;
		if( !map.hasMod("GUARDIAN") ) return;
		if ( !map.hasCityBuilding("roundPath") ) {
			var b = XmlData.getBuildingByKey("roundPath");
			notify( Text.fmt.BuildingRequired( { building:b.name } ) );
		}
		else if( user.isCityGuard ) {
			user.isCityGuard = false;
			user.update();
			notify(Text.get.unguard_city );
		}
		App.goto("city/guard");
	}

	//Thomas scouts Implementation
	function doRevealBuilding() {
		var u = App.user;
		var map = u.map;
		if( !map.hasCityBuilding("scouts") )
			return;
		if( db.ZoneAction.manager.hasDoneAction( u, "scouts" ) )
			return;
		if( u.jobId == null || u.job.key != "eclair" )
			return;
		
		var unrevealZones = new Array();
		var zl = Zone.manager.getZonesWithBuilding(map);
		for( z in zl )
			if( !z.checked && !z.tempChecked )
				unrevealZones.push(z);
		
		if( unrevealZones.length > 0 ) {
			var z = unrevealZones[Std.random(unrevealZones.length)];
			z = db.Zone.manager.get(z.id, true);
			z.tempChecked = true;
			z.update();
			db.ZoneAction.add(u, "scouts");
			var coords = z.coord( map._getCity() );
			notify( Text.fmt.ZoneBuildingRevealedByEclair( { name:u.name, x:coords.x, y:coords.y } ) );
		} else
			notify( Text.get.NoMoreZoneBuildingToReveal );
	
		App.goto("home");
	}
	
	public function doEmptyBagBank() { // drops everything in city bank
		var user = App.user;
		if( App.user.isOutside ) {
			App.goto( "outside" );
			return;
		}
		var tlist = user.getInBagTools(true);
		if( tlist.length == 0 ) {
			doBank();
			return;
		}
		for( tool in tlist ) {
			if( tool.soulLocked || tool.hasType(Bag) ) {
				continue;
			}
			var m = db.Map.manager.get( App.user.mapId, false ); // On évite de locker la ressource
			ZoneItem.addToCity( m, tool );
			CityLog.add(	CL_GiveInventory,
							Text.fmt.CL_GiveInventory({name:App.user.print(), item:tool.print()} ),
							m, App.user );
			tool.delete();
		}
		doBank();
	}

	public function doGiveTown() { // bag to town
		if( App.user.isOutside ) {
			App.goto( "outside" );
			return;
		}
		var tid = App.request.getInt("tid");
		var tool = Tool.manager.get( tid );
		if( tool == null ) {
			doBank();
			return;
		}
		if( tool.user != App.user ) {
			doBank();
			return;
		}
		if( tool.soulLocked ) {
			notify( Text.get.CantDropSoulLocked);
			doBank();
			return;
		}

		var countNonBagObjects = Lambda.filter( App.user.getInBagTools() , function(tool:Tool) { if( tool.hasType(Bag) || tool.soulLocked ) return false; return true; }).length;
		if( tool.hasType(Bag) && countNonBagObjects > 0 ) {
			notify( Text.get.EmptyInvFirstToGiveBag);
			doBank();
			return;
		}
		var m = db.Map.manager.get( App.user.mapId, false ); // On évite de locker la ressource
		var i = ZoneItem.addToCity( m, tool );
		if( i == null ) {
			notify( Text.get.CantGiveBrokenToTown);
			doBank();
			return;
		}
		App.user.update();
		CityLog.add(	CL_GiveInventory,
						Text.fmt.CL_GiveInventory({name:App.user.print(), item:tool.print()} ),
						m, App.user );
		tool.delete();
		doBank();
	}

	public function doTakeFromCity() { // town to bag
		var tid = tools.Utils.decodeToolId( App.request.getInt("tid") );
		if( tools.Utils.isMidnight() )
			return;
		
		if( App.user.isCityBanned ) {
			notify( Text.get.BanForbidden );
			doBank();
			return;
		}
		
		var item = ZoneItem.manager._getByToolId( App.user.zone, tid, App.request.exists("broken"), true );
		if( item == null ) {
			notify(Text.get.ItemNoMoreInBank);
			doBank();
			return;
		}
		
		if( item.count <= 0 ) {
			notify(Text.get.ItemNoMoreInBank);
			doBank();
			return;
		}
		
		if( !App.user.hasCapacity() ) {
			notify(Text.get.NoMoreRoomInBag);
			doBank();
			return;
		}
		
		var tinfo = XmlData.getTool(item.toolId);
		if( !ToolActions.canTakeObject( tinfo ) ) {
			notify(Text.get.CannotTakeThisObject);
			doBank();
			return;
		}
		
		var umap = db.Map.manager.get( App.user.mapId, false ); // NO LOCK
		if( !App.user.cooledDownAction() ) {
			notify( Text.fmt.CooledDownActionLocked({n:Const.get.AbuseBan}) );
			doBank();
			return;
		}
		
		var tool = Tool.add( tid, App.user, true );
		tool.isBroken = item.isBroken;
		tool.update();
		item.delete();
		App.user.update();
		
		if( App.request.getInt("dotheft", 0) == 1 && umap.canRobBank() ) {
			if( Std.random(100) < Const.get.NightBankChance ) {
				// vol réussi
				notify( Text.fmt.RobFromCity({tool:tool.print()}) );
				CityLog.add( CL_BankRob, Text.fmt.CL_TakeInventoryByNight( {item:tool.print() } ), umap );
			} else {
				// échec du vol
				notify( Text.fmt.RobFromCityFailed({tool:tool.print()}) );
				CityLog.add( CL_BankRob, Text.fmt.CL_BankRobFailed( {name:App.user.print(),item:tool.print()} ), umap, App.user );
			}
		} else {
			// prise classique
			notify( Text.fmt.TakeFromCity({tool:tool.print()}) );
			CityLog.add( CL_TakeInventory, Text.fmt.CL_TakeInventory( {name:App.user.print(),item:tool.print() } ), umap, App.user );
		}
		doBank();
	}

	public function doHeroSavePeople() {
		var user = App.user;
		if( !user.hero ) {
			notify(Text.get.NowYouWishedYouWereAHero);
			App.goto("hero");
			return;
		}
		if( App.user.isOutside ) {
			notify(Text.get.IntownHeroAction);
			App.goto( "outside/refresh" );
			return;
		}
		if( user.usedHeroRescue ) {
			notify(Text.get.HeroAlreadyUsedRescue);
			App.goto( "home" );
			return;
		}
		if( user.hasDoneDailyHeroAction ){
			notify(Text.get.HeroTired);
			App.goto( "home" );
			return;
		}

		var ts = App.request.getInt( "id" );
		var rescueList = db.User.getRescueList(user, user.getMapForDisplay());
		var ok = null;
		for( u in rescueList )
			if( u.id == ts )
				ok = u;

		if( ok == null ) {
			notify(Text.get.UserVanished);
			App.goto( "city/enter?go=home");
			return;
		}

		var saved = User.manager.get( ok.id );
		var oldZoneId = saved.zoneId;
		user.usedHeroRescue = true;
		user.hasDoneDailyHeroAction = true;
		db.GhostReward.gain(GR.get.heroac);
		user.update();

		var zone = saved.zone;
		var fl_hadControl = zone.humans>=zone.zombies;
		zone.changeHumanScore( -saved.getControlScore(), false );

		var count = 0;
		for( c in rescueList )
			if( c.zoneId == oldZoneId )
				count++;
		var h = count - user.getControlScore();
		var z = zone.zombies;
		// Je le sors de la zone, mais je fous les autres dans la merde
		if( zone.zombies > zone.humans && fl_hadControl ) {
			zone.endFeist = DateTools.delta( Date.now(), DateTools.minutes(Const.get.ControlTime) );
			CityLog.addToZone( CL_OutsideTempEvent, Text.get.OutsideLostControl, user.getMapForDisplay(), zone );
		}

		// last user leaves area
		if( zone.countPlayers() == 1 ) {
			CityLog.manager.clearLogs(zone.id);
			zone.endFeist = null;
		}
		if( zone.infoTagEnum == IT_Help ) {
			zone.infoTag = null;
			zone.infoTagEnum = null;
		}
		zone.update();
		var map = user.getMapForDisplay();
		var city = map._getCity();
		var pt = MapCommon.coords( city.x, city.y, saved.zone.x, saved.zone.y );
		saved.dropEscort();
		saved.dropAllSquad();
		saved.wasRescued = true;
		saved.zone = city;
		saved.isOutside = false;
		saved.loseCamp(false);
		CityLog.add( CL_OpenDoor, Text.fmt.CL_EnterCity( {name:saved.print()} ), map, saved );
		saved.endGather = null;
		db.TempGather.manager.deleteTools( saved );
		saved.update();

		CityLog.add( CL_HeroRescue, Text.fmt.CL_HeroRescued({hero:user.print(), target:saved.print(), x:pt.x, y:pt.y}), map, user );
		notify(Text.fmt.HeroRescueSuccess({s:saved.print()}));
		App.goto( "home");
	}

	public function doElection() {
		var user = App.user;
		var map = user.getMapForDisplay();
		
		App.context.shamanElection = map.isShamanElection();
		App.context.guideElection = map.isGuideElection();
		
		if (App.request.exists("act") && App.request.get("act", "") == "vote" ) {
			var roleKey = App.request.get("role", "");
			var roleName = Text.get.resolve(roleKey + "_role");
			var actName = switch( roleKey ) {
				case "shaman": 
					App.user.validateActivity( Common.BIT_VOTE_SHAMAN_ELECTION );
					"shamanVote"; 
				case "guide": 
					App.user.validateActivity( Common.BIT_VOTE_GUIDE_ELECTION );
					"guideVote"; 
				default: throw "unknown rôle : " + roleName;
			}
			
			if ( db.ZoneAction.manager.hasDoneAction(user, actName) ) {
				notify(Text.fmt.electionVoteUnique( { role:roleName } ));
			} else {
				var roleTargetId = App.request.getInt("uid", 0);
				if( roleTargetId == user.id ) {
					notify(Text.fmt.electionVoteConfirmed( { user:Text.get.TheCrow , role:roleName } ));
				} else {
					var roleTarget = db.User.manager.get(roleTargetId, false);
					db.UserVar.manager.fastInc(roleTarget.id, actName);
					db.ZoneAction.addDirectly(user, actName);
					notify(Text.fmt.electionVoteConfirmed( { user:roleTarget.name, role:roleName } ));
				}
			}
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
		App.context.hasVoted = switch( role ) {
			case "shaman"	: db.ZoneAction.manager.hasDoneAction(user, "shamanVote");
			case "guide"	: db.ZoneAction.manager.hasDoneAction(user, "guideVote");
			default: throw "unknown rôle : " + role;
		}
	}	
	
	public function doCitizenOffice() {
		var user = App.user;
		var map = user.getMapForDisplay();
		
		var users = user.getMapForDisplay().getUsers(false);
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
		App.context.jList = jobs;
		if( user.isAdmin || user.hasHeroUpgrade("overview2") )
			App.context.alt = App.request.getInt("alt", 0) == 1;
		else
			App.context.alt = false;

		var ids = Lambda.map( users, function( u : User ) { return u.zoneId; } );
		var uids = Lambda.map( users, function( u  : User ) {return u.id;} );
		var zones = Db.results( "SELECT id, x, y FROM Zone WHERE id IN("+ids.join(",")+")");
		var hZ = new IntHash();
		for( z in zones ) {
			hZ.set( z.id, {x:z.x,y:z.y} );
		}
		App.context.zones = hZ;
		App.context.chaos = map.chaos;
		App.context.city = map._getCity();
		var tools = db.Tool.manager.getUsersTools( map, uids );
		App.context.userTools = getUserToolsHash(tools);
		App.context.userDefense = getUsersDefenseHash(tools);
		
		var allCadavers = Lambda.array( Db.results( "SELECT c.id, c.deathType, c.homeRecycle, c.diedInTown, c.deathMessage, c.attackedCity, c.watered, c. garbaged, u.name, u.avatar FROM Cadaver c, User u WHERE c.mapId=" + App.user.mapId + " AND u.id = c.userId" ) );
		allCadavers.sort( function(o1,o2) { if( o2.id > o1.id ) return 1; if( o1.id > o2.id) return -1; return 0; } );
		App.context.cadavers = Lambda.list( allCadavers );
		App.context.getDeathReason = db.Cadaver.getDeathReasonStatic;
		App.context.hasHomeRecycled = db.Cadaver.hasHomeRecycledStatic;
		// objets des cadavres
		var remains : IntHash<List<db.CadaverRemains>> = new IntHash();
		if( allCadavers.length > 0 ) {
			for( r in db.CadaverRemains.manager.getByCadavers( Lambda.map( allCadavers, function( c ) { return c.id; } ) ) ) {
				if( remains.exists( r.cadaverId ) ) {
					var l = remains.get( r.cadaverId );
					l.add( r );
					continue;
				}
				var l = new List();
				l.add( r );
				remains.set( r.cadaverId, l );
			}
		}
		App.context.remains = remains;
		// who is online ?
		var now = DateTools.delta( Date.now(), -DateTools.minutes(Const.get.OnlineStatusMinutes) );
		var minTime = DateTools.format( now, "%Y-%m-%d %H:%M" );
		var onlines = if(uids.length == 0) new List() else Db.execute("SELECT uid FROM Session WHERE uid IN("+uids.join(",")+") AND mtime >= '"+minTime+"'").results();
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
		App.context.isAtDoors = db.User.isAtDoorsStatic( user, map.cityId );
		if( map.hasMod("GHOULS") && user.isGhoul )
			App.context.ghoulDetectChance = map.getGhoulDetectChance();
		
		App.context.shamanElection = map.isShamanElection();
		App.context.guideElection = map.isGuideElection();
	}

	public function doWaterDead() {
		if( !App.user.inTown() ) {
			App.reboot();
			return;
		}
		if( !App.request.exists("cid") ){
			App.reboot();
			return;
		}
		var id = App.request.getInt("cid");
		var clint = Cadaver.manager.get( id );
		if( clint == null ) {
			App.reboot();
			return;
		}
		if( clint.garbaged != null ) {
			notify( Text.get.AlreadyGarbaged );
			App.goto( "city/seeCadaver?id=" + clint.id );
			return;
		}
		if( clint.watered != null ) {
			notify( Text.get.AlreadyWatered );
			App.goto( "city/seeCadaver?id=" + clint.id );
			return;
		}
		if( clint.mapId != App.user.mapId ) {
			notify( Text.get.UnknownUser );
			App.reboot();
			return;
		}
		if( !clint.diedInTown ) {
			notify( Text.get.UnknownUser );
			App.reboot();
			return;
		}
		if( !App.user.hasTool( "water" ) ) {
			notify( Text.get.NeedWater );
			App.goto( "city/seeCadaver?id=" + clint.id );
			return;
		}
		var t = App.user.findTool( "water" );
		if( t == null ) {
			notify( Text.get.NeedWater );
			App.goto( "city/seeCadaver?id=" + clint.id );
			return;
		}
		clint.watered = App.user.name;
		clint.update();
		db.GhostReward.gain( GR.get.cwater );
		t.delete();
		notify( Text.get.CadaverWatered );
		var m = db.Map.manager.get( App.user.mapId, false ); // On évite de locker la ressource
		CityLog.add( CL_DeadGarbaged, Text.fmt.CL_CadaverWatered( {name:App.user.print(), cadaver:clint.print()} ), m, App.user );
		App.goto( "city/seeCadaver?id=" + clint.id );
	}

	public function doDevourDead() {
		if( !App.user.map.hasMod("GHOULS") || !App.user.isGhoul || !App.request.exists("cid") ){
			App.reboot();
			return;
		}
		var id = App.request.getInt("cid");
		var clint = Cadaver.manager.get( id );
		var map = App.user.getMapForDisplay();
		if( clint == null || clint.garbaged!=null || clint.watered!=null || clint.mapId != App.user.mapId || !clint.diedInTown ) {
			App.reboot();
			return;
		}
		var url = "city/seeCadaver?id="+clint.id;
		if( db.ZoneAction.manager.hasDoneAction(App.user, "devourInTown") ) {
			notify(Text.get.AlreadyDone);
			App.goto(url);
			return;
		}

		clint.garbaged = "";
		clint.update();
		db.ZoneAction.add(App.user, "devourInTown");
		db.GhostReward.gain( GR.get.cannib );
		App.user.changeHunger(Const.get.GFoodCadaver, false);
		notify( Text.get.BadHumanFood );
		App.goto(url);
	}

	public function doThrowDead() {
		if( !App.user.inTown() ) {
			App.reboot();
			return;
		}
		if( !App.request.exists("cid") ){
			App.reboot();
			return;
		}
		var id = App.request.getInt("cid");
		var clint = db.Cadaver.manager.get( id );
		if( clint == null ) {
			App.reboot();
			return;
		}
		if( clint.garbaged != null ) {
			notify( Text.get.AlreadyGarbaged );
			App.goto( "city/seeCadaver?id=" + clint.id );
			return;
		}
		if( clint.watered != null ) {
			notify( Text.get.AlreadyWatered );
			App.goto( "city/seeCadaver?id=" + clint.id );
			return;
		}
		if( clint.mapId != App.user.mapId ) {
			notify( Text.get.UnknownUser );
			App.reboot();
			return;
		}
		if( !clint.diedInTown ) {
			notify( Text.get.UnknownUser );
			App.reboot();
			return;
		}
		if( !App.user.canDoTiringAction(Const.get.PA_ThowDead) ) {
			notify( Text.fmt.NeedPA({n:Const.get.PA_ThowDead}) );
			App.goto( "city/seeCadaver?id=" + clint.id );
			return;
		}
		clint.garbaged = App.user.name;
		clint.update();
		App.user.doTiringAction( Const.get.PA_ThowDead );
		db.GhostReward.gain( GR.get.cgarb );
		notify( Text.fmt.CadaverGarbaged({cadaver:clint.print()}) );
		var m = db.Map.manager.get( App.user.mapId, false ); // On évite de locker la ressource
		CityLog.add( CL_DeadGarbaged, Text.fmt.CL_CadaverRemoved( {name:App.user.print(), cadaver:clint.print()} ), m, App.user );

		App.goto( "city/seeCadaver?id=" + clint.id );
	}

	public function doCookDead() {
		if( !App.user.inTown() ) {
			App.reboot();
			return;
		}
		if( !App.request.exists("cid") ){
			App.reboot();
			return;
		}
		var id = App.request.getInt("cid");
		var clint = Cadaver.manager.get( id );
		if( clint == null ) {
			App.reboot();
			return;
		}
		if( clint.garbaged  != null) {
			notify( Text.get.AlreadyGarbaged );
			App.goto( "city/seeCadaver?id=" + clint.id );
			return;
		}
		if( clint.watered != null ) {
			notify( Text.get.AlreadyWatered );
			App.goto( "city/seeCadaver?id=" + clint.id );
			return;
		}
		if( clint.mapId != App.user.mapId ) {
			notify( Text.get.UnknownUser );
			App.reboot();
			return;
		}
		if( !clint.diedInTown ) {
			notify( Text.get.UnknownUser );
			App.reboot();
			return;
		}
		if( !App.user.hasCityBuilding("crema") ) {
			notify( Text.get.ImpossibleAction );
			App.goto( "city/seeCadaver?id=" + clint.id );
			return;
		}
		clint.garbaged = App.user.name;
		clint.update();
		db.GhostReward.gain(GR.get.cooked);
		var count = Const.get.CadaverConversion;
		var tool = XmlData.getToolByKey("huMeat");
		for(i in 0...count) {
			ZoneItem.addToCity( App.user.map, tool );
		}
		notify( Text.fmt.CadaverCooked({cadaver:clint.print(), n:count}) );
		var m = db.Map.manager.get( App.user.mapId, false ); // On évite de locker la ressource
		CityLog.add( CL_GiveInventory, Text.fmt.CL_CadaverCooked( {name:App.user.print(), cadaver:clint.print(), n:count} ), m, App.user );
		App.goto( "city/seeCadaver?id=" + clint.id );
	}

	public function doLeaveTown() {
		var user = App.user;
		var map = user.getMapForDisplay();
		//Thomas airing Implementation
		var bypassClosedDoor = user.hero && map.hasCityBuilding("airing");
		if( user.getPa() <= 0 || user.isTired || ( !map.hasDoorOpened() && !bypassClosedDoor ) ) {
			App.goto( "city/enter" );
			return;
		}
		
		var fl_furtive = map.hasMod("GHOULS") && user.isGhoul && App.request.getInt("furtive", 0) == 1;
		if( !fl_furtive )
			CityLog.add( CL_OpenDoor, Text.fmt.CL_LeaveCity( {name:user.print()} ), map, user );
		user.isOutside = true;
		user.update();
		App.goto( "outside" );
	}

	public function doGetWater() {
		var user = App.user;
		var hasPump = user.hasCityBuilding("pump");
		if( !user.canHaveWater() ) {
			// more water...
			if( !hasPump ) {
				error( Text.get.UserAlreadyGotDailyWater );
				App.goto( "city/well" );
				return;
			}
			if( checkCityBan("city/well", user) ) return;
		}
		var map = user.map;
		if( map.water <= 0 ) {
			notify( Text.get.NoWaterleft );
			App.goto( "city/well" );
			return;
		}
		var count = 1;
		if( !user.hasCapacity(count) ) {
			notify( Text.fmt.NoRoomCount({n:count}) );
			App.goto( "city/well" );
			return;
		}
		var extra = Const.get.MaxExtraWater;
		if( map.chaos ) extra ++;
		if( user.waterTaken >= extra ) {
			notify( Text.fmt.ExtraWaterLimit({n:extra}) );
			App.goto( "city/well" );
			return;
		}
		if( user.waterTaken >= Const.get.MaxFreeWater && !App.user.cooledDownAction() ) {
			notify( Text.fmt.CooledDownActionLocked({n:Const.get.AbuseBan}) );
			App.goto( "city/well" );
			return;
		}
		for( i in 0...count )
			Tool.add( 1, user, true );
		user.waterTaken++;
		user.update();
		map.water -= count;
		map.update();
		// -------
		if( user.waterTaken <= Const.get.MaxFreeWater ) {
			// normal take
			notify( Text.fmt.UserGotDailyWater({n:count, tool:XmlData.getTool(1).print()}) );
			if( !user.isCityBanned && hasPump && user.waterTaken < Const.get.MaxFreeWater ) {
				appendNotify( Text.get.CanTakeMoreWater );
			}
			CityLog.add( CL_Well, Text.fmt.CL_Well( {name:App.user.print()} ), App.user.getMapForDisplay(), App.user );
		} else {
			// more water...
			notify( Text.fmt.UserGotMoreWater({tool:XmlData.getTool(1).print()}) );
			CityLog.add( CL_WellExtra, Text.fmt.CL_WellExtra( {name:App.user.print()} ), App.user.getMapForDisplay(), App.user );
		}
		App.goto( "city/well" );
	}

	public function doGiveWater() {
		if( !App.user.hasCityBuilding("pump") ) {
			return;
		}
		var wlist = App.user.getToolsByType(Beverage, true, Fake);
		if( wlist.length == 0 ) {
			notify(Text.get.NeedWaterInBag);
			App.goto("city/well");
			return;
		}
		var water = wlist.first();
		if( water.replacement != null && water.replacement.length > 0 )
			Tool.add( XmlData.getToolByKey(water.replacement[0]).toolId, App.user, water.inBag );
		water.delete();
		App.user.map.water ++;
		App.user.map.update();
		notify( Text.fmt.GaveWaterToWell({tool:water.print()}) );
		var m = db.Map.manager.get( App.user.mapId, false ); // On évite de locker la ressource
		CityLog.add( CL_GiveWater, Text.fmt.CL_GiveWaterSingle( {name:App.user.print()} ), m, App.user );
		App.goto("city/well");
	}

	public function doOpenDoor() {
		doDoor();
		var map = App.user.getMapForDisplay();
		if( App.user.isCityBanned ) {
			notify( Text.get.BanForbidden );
			return;
		}
		if( map.isQuarantined() ) {
			notify( Text.get.DoorLockQuarantine );
			return;
		}
		if( App.user.isWounded && App.user.hasWound(W_Arm) ) {
			notify(Text.get.WoundedArm);
			return;
		}
		if( map.countP < Const.get.MaxPlayers && map.isCustom() ) {
			notify(Text.get.DoorLockCustomMap);
			return;
		}
		var now = Date.now();
		var cronHour = App.getNextCronDate();
		if( map.hasCityBuilding("bigDoor") ) {
			var lockHour = DateTools.delta( cronHour, -DateTools.minutes(Const.get.BigDoorLockMin) );
			if( (now.getTime() > lockHour.getTime()) && (now.getTime() <= (cronHour.getTime() + DateTools.minutes(10))) ) {
				notify( Text.get.BigDoorLock);
				return;
			}
		}
		if( map.hasCityBuilding("doorLock") ) {
			var lockHour = DateTools.delta( cronHour, -DateTools.minutes(Const.get.BasicDoorLockMin) );
			if( (now.getTime() > lockHour.getTime()) && (now.getTime() <= (cronHour.getTime() + DateTools.minutes(10))) ) {
				notify( Text.get.BasicDoorLock);
				return;
			}
		}
		if( tools.Utils.isMidnight() )
			return;
		// -------
		if( !App.user.canDoTiringAction(Const.get.PA_Door) ) {
			notify( Text.fmt.NeedPA({n:Const.get.PA_Door}) );
			return;
		}
		// -------
		var lockedMap = App.user.map;
		if( lockedMap!=null && !lockedMap.hasDoorOpened() && !lockedMap.isQuarantined() ) {
			if( lockedMap.openDoor() ) {
				CityLog.add( CL_OpenDoor, Text.fmt.CL_OpenDoor( {name:App.user.print()} ), lockedMap, App.user );
				App.user.doTiringAction(Const.get.PA_Door);
			}
		}
		App.context.hasDoorOpened = lockedMap.getDoorOpened();
		addLogs( [CL_OpenDoor, CL_CloseDoor], lockedMap, 20 );
	}


	public static function closeDoor(user:User) : String {
		if( App.isEvent("aprilfool") )
			throw "Invalid field access : closeDoor";
			
		if( user.isOutside )
			return null;
		if( tools.Utils.isMidnight() )
			return null;
		if( user.isCityBanned )
			return Text.get.BanForbidden;
		if( !user.canDoTiringAction(Const.get.PA_Door) )
			return Text.fmt.NeedPA({n:Const.get.PA_Door});
		if( user.isWounded && user.hasWound(W_Arm) )
			return Text.get.WoundedArm;
		// -------
		var lockedMap = user.map;
		if( lockedMap.devastated )
			return null;
		// -------
		if( lockedMap!=null && lockedMap.hasDoorOpened() ) {
			if( lockedMap.closeDoor(true) ) {
				CityLog.add( CL_CloseDoor, Text.fmt.CL_CloseDoor( {name:user.print()} ), lockedMap, user );
				user.doTiringAction(Const.get.PA_Door);
				return Text.get.DoorClosed;
			}
		}
		return Text.get.DoorAlreadyClosed;
	}

	public function doCloseDoor() {
		doDoor();
		var res = closeDoor(App.user);
		if( res != null )
			notify(res);
		var map = App.user.getMapForDisplay();
		App.context.hasDoorOpened = map.getDoorOpened();
		addLogs( [CL_OpenDoor, CL_CloseDoor], map, 20 );
	}

	public function doDoor() {
		//if( !App.user.map.hasFlag("resetZonesScores") ) {
		//	db.Zone.manager.syncZonesScores(App.user.map);	
		//	db.MapVar.setValue(App.user.map, "resetZonesScores", 1);
		//}
		//
		var map = App.user.getMapForDisplay();
		var buildings = db.CityBuilding.manager.getDoneBuildingsHash(map);
		addDefenseInfo( map, buildings );
		App.context.hasDoorOpened = map.hasDoorOpened();
		App.context.devastated = map.devastated;
		// Reminder
		if( !App.request.exists("noRemind") && App.user.isNoob && map.days <= 1 ) {
			if( App.user.waterTaken == 0 ) {
				notify(Text.get.ReminderWater);
				App.goto("city/door?noRemind=1");
				return;
			}
			if( !App.user.hasToolsByType(Food, true) && !App.user.hasToolsByType(Beverage, true) ) {
				notify(Text.get.ReminderEquip);
				App.goto("city/door?noRemind=1");
				return;
			}
		}

		addLogs( [CL_OpenDoor, CL_CloseDoor], map, 20 );
		var expeditions = db.Expedition.manager.getByMapId(map);
		var mdata = OutsideActions.getMapData(map,App.user, map._getCity(), 0, 0, 0);
		App.context.outsideMapInit = updateMapDataForCity( map, mdata, expeditions );
		App.context.hasExp = Expedition.manager.hasExpedition(App.user);
		App.context.canBypassClosedDoors = App.user.hero && map.hasCityBuilding("airing");
	}

	function updateMapDataForCity( map:Map, data, expeditions, ?path:String, ?fl_editor:Bool ) {
		var omi = data.outsideMapInit;
		var ucount = new IntHash();
		var users : Array<OutMapCitizen> = new Array();
		var ulist = Lambda.array( Db.results( "SELECT zoneId, name FROM User WHERE dead = 0 AND mapId = " + map.id) );
		ulist.sort( function( o1 : {zoneId:Int,name:String},o2: {zoneId:Int,name:String}) { return tools.Utils.compareStrings( o1.name, o2.name ); } );
		for( u in ulist ) {
			if( ucount.exists( u.zoneId ) ) {
				var t = ucount.get( u.zoneId );
				ucount.set( u.zoneId, t++ );
			} else {
				ucount.set( u.zoneId, 1 );
			}
			var z : Zone = data.zonesHash.get( u.zoneId );
			if(z != null) // ne devrait pas arriver : bug du 2/11/2010(ploukdu23 / cortho)
				users.push({
					_x	: z.x,
					_y	: z.y,
					_n	: u.name,
				});
		}

		omi._map	= true;
		omi._town	= true;
		omi._e		= expSwf(expeditions);
		omi._path	= path;
		omi._editor	=(fl_editor == true);
		omi._slow	= true;
		omi._users	= if( map.chaos ) null else users;
		return MapCommon.encode( haxe.Serializer.run(omi) );
	}

	public function doWell() {
		var map = App.user.getMapForDisplay();
		addLogs( [CL_Well,CL_WellExtra,CL_GiveWater], map );
		var hasPump = App.user.hasCityBuilding("pump");
		App.context.hasPump = hasPump;
		App.context.maxFreeWater = Const.get.MaxFreeWater;
	}

	public function doSeeClint() {
		if( !App.request.exists("id") ) {
			App.goto("city/co");
			return;
		}
		var id = Std.parseInt(App.request.get("id") );
		if( id == App.user.id ) {
			App.goto("home");
			return;
		}
		var clint  = User.manager.get( id );
		if( clint == null ){
			notify(Text.get.UnknownUser);
			App.goto("city/co");
			return;
		}
		if( !clint.playsWithMe( App.user ) ) {
			notify(Text.get.UnknownUser);
			App.goto("city/co");
			return;
		}
		App.context.inv = Lambda.filter( clint.getInTownTools(), function( t ) return !t.hasType(Hidden) );
		var map = App.user.getMapForDisplay();
		App.context.clint = clint;
		var rlist = new Array();
		var i = 1;
		var r = "";
		while( Text.exists("ComplaintReason_"+i) ) {
			rlist.push(Text.getByKey("ComplaintReason_"+i));
			i++;
		}
		
		App.context.reasons = rlist;
		if( App.request.exists("theft") ) {
			App.context.thiefMode = true;
			if( clint.homeAlarm ) {
				if( !db.ZoneAction.manager.hasDoneCountedActionZone(App.user,"alarm_"+App.user.id+"_"+clint.id, 4) ) {
					db.ZoneAction.add( App.user, "alarm_"+App.user.id+"_"+clint.id, true);
					CityLog.add( CL_Thief, Text.fmt.CL_Alarm( {thief:App.user.print(),clint:clint.print()} ), App.user.map, App.user );
					var time = DateTools.format( Date.now(), "%H:%M" );
					MessageActions.sendOfficialMessage( clint, Text.fmt.MT_Alarm({user:App.user.print()}), Text.fmt.M_Alarm({user:App.user.print(), time:time}) );
				}
				notify( Text.fmt.Alarm({clint:clint.print()}) );
			}
		} else {
			App.context.thiefMode = false;
		}
		
		var complaints = Complaint.manager.getComplaints(clint);
		var list = new List();
		var cpt = 0;
		if( complaints.length > 0 ) {
			for( c in complaints ) {
				list.add( c );
				cpt += c.cpt;
			}
		}
		
		if( !clint.homeProtected() ) {
			App.context.userTools = App.user.getInBagTools();
		}
		
		addLogs( clint, map );
		// date de dernière visite
		App.context.lastTime = clint.getLastActivity();
		App.context.comcpt = cpt;
		App.context.complaints = list;
		App.context.complained =( Complaint.manager.getWithKeys({mapId:App.user.mapId, plaintiff:App.user.id, suspect:clint.id}) != null );
		App.context.canUseAggression = map.canUseAggression();
		App.context.aggCost = map.getAggressionCost();
		
		if( App.user.isShaman && clint != App.user ) {
			App.context.canHeal = true;
			App.context.canHealClint = clint.playsWithMe( App.user ) && clint.inTown();
			App.context.healCost = Const.get.ShamanHealCost;
		}
	}

	public function doSeeCadaver() {
		if( !App.request.exists("id") ) {
			App.goto("city/co");
			return;
		}
		if( !App.user.inTown() ) {
			App.goto("outside");
			return;
		}
		var id = App.request.getInt("id");
		var cadaver  = Cadaver.manager.get( id );
		if( cadaver == null ){
			notify(Text.get.UnknownUser);
			App.goto("city/co");
			return;
		}
		if( cadaver.mapId != App.user.mapId ) {
			notify(Text.get.UnknownUser);
			App.goto("city/co");
			return;
		}
		App.context.canCook = App.user.hasCityBuilding("crema");
		App.context.inv = cadaver.getTools();
		App.context.cadaver = cadaver;
	}

	public function doCrossDoors() { // ie. enter town
		var user = App.user;
		var map = App.user.getMapForDisplay();
		var bypassClosedDoor = user.hero && map.hasCityBuilding("airing") && App.request.getInt("bypass") == 1;
		if( !user.isOutside )
			return;
		if( tools.Utils.isMidnight() )
			return;
		if( user.hasLeader() ) {
			notify( Text.get.ForbiddenInEscort );
			App.goto("outside");
			return;
		}
		if( user.zoneId != map.cityId ) {
			App.goto("outside");
			return;
		}
		if( !map.hasDoorOpened() && !bypassClosedDoor )
			return;
		// porte labyrinthe
		var paCost = if(user.hasCityBuilding("maze") && !bypassClosedDoor) 1 else 0;
		if( paCost > 0 && !user.canDoTiringAction(paCost) ) {
			notify(Text.fmt.NeedPA( { n:paCost } ));
			App.goto("outside");
			return;
		}
		
		var fl_furtive = map.hasMod("GHOULS") && user.isGhoul && App.request.getInt("furtive",0)==1;
		user.isWaitingLeader = false;
		user.wasEscorted = false;
		user.loseCamp(false);
		
		var list = new List();
		list.add(user);
		for( u in db.User.manager.getSquad(user, true) )
			if( u.isFollower(user) )	list.add(u);
			else						u.dropEscort();
		
		for( u in list ) {
			if( u != user &&(!App.request.exists("all") || bypassClosedDoor) ) {
				// le leader a choisi de rentrer seul : escorte abandonnée
				u.dropEscort();
			} else {
				if( u != user && paCost > 0 && !u.canDoTiringAction(paCost) ) {
					// un escorté n'a pas assez de PA pour franchir la porte !
					u.dropEscort();
					continue;
				}
				if( !fl_furtive )
					CityLog.add( CL_OpenDoor, Text.fmt.CL_EnterCity( {name:u.print()} ), map, u );
				u.isOutside = false;
				if( paCost > 0 )
					u.losePa(paCost);
				if( u != user ) {
					// escort ramenée en ville
					u.wasRescued = true;
					u.dropEscort();
				}
			}
			u.update();
		}
		App.goto("city/enter");
	}

	public function doEnterCity() {
		if( tools.Utils.isMidnight() )
			return;
		
		var user = App.user;
		App.context.staticSites = db.Site.manager.getAllSitesSplitted(7);
		App.context.staticMySites = db.Site.manager.getMySites(user);
		var map = user.getMapForDisplay();
		if( map.isQuarantined() ) App.context.quarantined = true;
		var doneHash = db.CityBuilding.manager.getDoneBuildingsHash(map);
		App.context.hasDoorOpened = map.getDoorOpened();
		App.context.buildingExists = doneHash.exists;
		App.context.buildingList = Lambda.list(doneHash);
		App.context.zid = map.cityId;
		App.context.main_section = true;
		var doneActions = db.ZoneAction.manager.getDoneActionsHash( user );
		App.context.hasConspirated = doneActions.exists( "conspirate" );
		
		if( App.request.exists( "go" ) ) {
			if( App.request.exists( "goSub" ) ) {
				App.load( tools.Utils.makeUrl( App.request.get("go"), {goSub:App.request.get("goSub")} ) );
			} else {
				//propagate variables
				var o = App.request.getParamsObject();
				Reflect.deleteField(o, "go");
				App.load( tools.Utils.makeUrl( App.request.get("go"), o ) );
			}
		} else {
			// page de garde de la ville
			addDefenseInfo( map, doneHash );
			var needUpVotes = false;
			for( b in doneHash ) {
				if( b.getInfos().hasLevels ) {
					needUpVotes = true;
					break;
				}
			}
			if( map.devastated )
				needUpVotes = false;
				
			App.context.hasUnreadTeamPosts = user.hasUnreadTeamPosts();
			App.context.hasUnreadMessages = user.hasUnreadMessages();
			App.context.hasTeamInvitation = user.hasTeamInvitation();
			App.context.hasPostedOnForum = db.UserVar.getValue(user, "forumPosts", 0) > 0;
			App.context.needUpVotes = needUpVotes;
			App.context.needHomeUpgrade = !map.devastated && ! db.ZoneAction.manager.hasDoneActionZone(App.user, "upgradeHome" ) &&(map.days>=2 && user.homeLevel==0 || map.days>=7 && user.homeLevel<2);
			App.context.dailyWater = user.waterTaken > 0;
			
			if( doneHash.exists("tower") )
				App.context.estimData = getEstim(map,user, doneHash, doneActions);
			
			if( map.isShamanElection()  ) {
				App.context.shamanElection = true;
				App.context.dailyShamanVote = user.hasDoneActivity(Common.BIT_VOTE_SHAMAN_ELECTION);
			}
			
			if( map.isGuideElection() ) {
				App.context.guideElection = true;
				App.context.dailyGuidevote = user.hasDoneActivity(Common.BIT_VOTE_GUIDE_ELECTION);
			}
			
			App.context.dailyVoteUp = doneActions.exists("voteUpgrade");
			App.context.dailyForum = user.hasDoneActivity(Common.BIT_FORUM_READ);
			App.context.dailyActivity = user.hasDoneActivity(Common.BIT_REFINE) || user.hasDoneActivity(Common.BIT_OUT) || user.hasDoneActivity(Common.BIT_BUILD);
			App.context.defaultSection = true;
		}
	}

	function getListFromRecup(recup:Array<String>) {
		recup.sort(function(a,b) {
			if( a > b ) return 1;
			if( a < b ) return -1;
			return 0;
		});
		var recupCount = new List();
		var i = 0;
		while( i < recup.length ) {
			var n = 1;
			while( recup[i] == recup[i+1] ) { n++; i++; }
			recupCount.push(recup[i]+" x"+n);
			i++;
		}
		return recupCount;
	}
	
	function doComplaint() {
		if( !App.request.exists("suspect") ) {
			App.reboot();
			return;
		}
		
		var user = App.user;
		if( !user.inTown() ) {
			App.reboot();
			return;
		}
		
		var suspect = User.manager.get( App.request.getInt("suspect") );
		if( suspect == user ) {
			notify(Text.get.SelfComplaint);
			App.goto("city/seeClint?id="+suspect.id);
			return;
		}
		
		if( suspect == null )
			return;
		
		if( suspect.mapId == null ){ // genre je te balance une plainte par url sur un joueur de Hordes par forcément sur une map...( ça arrive, oui oui )
			App.reboot();
			return;
		}
		
		if( !suspect.playsWithMe( user ) ){ // genre je te balance une plainte par url sur un joueur de Hordes par forcément sur MA map...( ça arrive, oui oui )
			notify(Text.get.Forbidden);
			App.reboot();
			return;
		}
		
		if( checkCityBan("city/seeClint?id="+suspect.id, user) ) {
			return;
		}
		
		var reasonId = App.request.getInt("reasonId", 0);
		if( reasonId <= 0 || !Text.exists("ComplaintReason_"+reasonId) ) {
			notify(Text.get.NeedReason);
			App.goto("city/seeClint?id="+suspect.id);
			return;
		}

		var map = App.user.getMapForDisplay();
		var reason = Text.getByKey("ComplaintReason_"+reasonId);
		var fl_hasHanger = db.CityBuilding.hasHanger(map);
		var fl_hasMeatCage = db.CityBuilding.hasMeatCage(map);
		
		if( suspect.isCityBanned && !fl_hasHanger && !fl_hasMeatCage) {
			notify(Text.get.NeedExecutionBuilding);
			App.goto("city/seeClint?id="+suspect.id);
			return;
		}
		
		if( Complaint.manager.getWithKeys({mapId:user.mapId, plaintiff:user.id, suspect:suspect.id}) != null ) {
			notify( Text.fmt.AlreadyComplained({suspect:suspect.print()}) );
			App.goto("city/seeClint?id="+suspect.id);
			return;
		}
		
		if( db.ZoneAction.manager.hasDoneCountedActionZone(user,"complained",Const.get.MaxComplaintsByDay) ) {
			notify( Text.fmt.AlreadyDoneCounted({n:Const.get.MaxComplaintsByDay}) );
			App.goto("city/seeClint?id="+suspect.id);
			return;
		}
		
		db.ZoneAction.add( user, "complained", true);
		
		var complaintValue = if(user.hero && map.hasCityBuilding("popCourt")) 2 else 1;
		Complaint.add( map, user, suspect, reason, complaintValue);
		
		var count = Complaint.manager.countComplaints(suspect);
		if( map.chaos || map.devastated ) {
			// chaos !
			notify(Text.get.ChaosNoBan);
			appendNotify(Text.get.Chaos);
			
			MessageActions.sendOfficialMessage( suspect, Text.fmt.MT_Complaint({n:count}), Text.fmt.M_Complaint({msg:reason}) );
			App.goto("city/seeClint?id="+suspect.id);
			return;
		} else {
			var fl_solidHanger = map.hasMod("SOLID_HANGER");
			var minComplaints = Const.get.MinComplaints;
			// cas 1 : potence fragile, on réduit le quota requis si le citoyen est déjà banni et qu'on veut le pendre
			// cas 2 : potence solide, on a un quota fixe
			var fl_maxed =	(!fl_solidHanger && (!suspect.isCityBanned && count >= minComplaints || suspect.isCityBanned && count >= Const.get.MinComplaintsIfBanned)) || (fl_solidHanger && count >= minComplaints);
			
			if( fl_maxed ) {
				// quota atteint !
				{
					if( fl_hasHanger ) {
						// pendaison
						var recup = suspect.hangDown();
						if( App.isEvent("paques") ) {
							notify( Text.fmt.ComplaintCrucified( { suspect:suspect.print() } ) );
							if(map.hasMod("FRAGILE_HANGER"))
								appendNotify( Text.get.EasterCrossDestroyed );
							CityLog.add(CL_Crucified, Text.fmt.CL_Crucified({name:suspect.print()} ),map,suspect );
							var recupCount = getListFromRecup(recup);
							if( recupCount.length > 0 )
								CityLog.add(CL_Crucified, Text.fmt.CL_RetrievedItems( { list:recupCount.join(", "), clint:suspect.print() } ), map, suspect);
						} else {
							notify( Text.fmt.ComplaintHanged({suspect:suspect.print()}) );
							if(map.hasMod("FRAGILE_HANGER"))
								appendNotify( Text.get.HangerDestroyed );
							CityLog.add(CL_HangDown, Text.fmt.CL_HangDown({name:suspect.print()} ),map,suspect );
							var recupCount = getListFromRecup(recup);
							if( recupCount.length > 0 )
								CityLog.add(CL_HangDown, Text.fmt.CL_RetrievedItems( { list:recupCount.join(", "), clint:suspect.print() } ), map, suspect);
						}
					} else if( fl_hasMeatCage ) {
						// cage à viande
						var def = 40 + if(suspect.hero) 20 else 0;
						suspect.map.tempDef += def;
						suspect.map.update();
						var recup = suspect.sendToMeatCage();
						notify( Text.fmt.ComplaintMeatCage( { suspect:suspect.print() } ) );
						CityLog.add(CL_HangDown, Text.fmt.CL_MeatCage({name:suspect.print(), def:def} ),map, suspect );
						
						var recupCount = getListFromRecup(recup);
						if( recupCount.length > 0 ) {
							CityLog.add(CL_HangDown, Text.fmt.CL_RetrievedItems( { list:recupCount.join(", "), clint:suspect.print() } ), map, suspect);
						}						
					} else if( map.hasMod("BANNED") ) {//RAJOUT THOMAS
						// ban
						var recup = suspect.cityBan();
						notify( Text.fmt.ComplaintBanned({suspect:suspect.print()}) );
						if( recup.length > 0 ) {
							// récupération d'items
							var recupCount = getListFromRecup(recup);
							CityLog.add(CL_Ban, Text.fmt.CL_Ban({name:suspect.print()} ), map, suspect);
							if( recupCount.length > 0 )
								CityLog.add(CL_GiveInventory, Text.fmt.CL_RetrievedItems({list:recupCount.join(", "), clint:suspect.print()}), map, suspect);
							
							MessageActions.sendOfficialMessage( suspect, Text.get.MT_Banned, Text.fmt.M_BannedRecycle({tools:recupCount.join(", ")}) );
						} else {
							// pas de récup
							CityLog.add(CL_Ban, Text.fmt.CL_Ban({name:suspect.print()} ), map, suspect);
							MessageActions.sendOfficialMessage( suspect, Text.get.MT_Banned, Text.get.M_Banned );
						}
					}
				}
				App.goto("city/co");
				return;
			} else {
				// not enough complaints
				MessageActions.sendOfficialMessage( suspect, Text.fmt.MT_Complaint({n:count}), Text.fmt.M_Complaint({msg:reason}) );
			}
			notify( Text.fmt.Complained({suspect:suspect.print()}) );
		}
		App.goto("city/seeClint?id="+suspect.id);
	}

	function doRemoveComplaint() {
		if( !App.request.exists("suspect") ) {
			App.goto("city/co");
			return;
		}
		// on ne supprime que les plaintes affÃ©rentes Ã  un joueur encore vivant
		var suspect = User.manager.get( App.request.getInt("suspect") );
		if( suspect == null ) {
			App.goto("city/co");
			return;
		}
		if( !App.user.inTown() ) {
			App.reboot();
			return;
		}
		if( !App.user.playsWithMe(suspect) ) {
			notify(Text.get.Forbidden);
			App.goto("city/co");
			return;
		}
		if( suspect.dead ) {
			notify(Text.get.SuspectIsDead);
			App.goto("city/seeClint?id="+suspect.id);
			return;
		}
		var comp = Complaint.manager.getWithKeys({mapId:App.user.mapId, plaintiff:App.user.id, suspect:suspect.id});
		if( comp == null ) {
			App.goto("city/seeClint?id="+suspect.id);
			return;
		}
		comp.delete();
		var count = Complaint.manager.countComplaints(suspect);
		
		MessageActions.sendOfficialMessage( suspect, Text.fmt.MT_ComplaintRemoved({n:count}), Text.fmt.M_ComplaintRemoved({msg:comp.reason}) );
		notify( Text.get.ComplaintRemoved );
		App.goto("city/seeClint?id="+suspect.id);
	}

	function doRecycle() {
		if( !App.request.exists("cid") ) {
			notify( Text.get.UnknownUser );
			App.goto("city/co");
			return;
		}
		var cadaver = Cadaver.manager.get( App.request.getInt("cid"), true );
		if( cadaver == null ) {
			notify( Text.get.UnknownUser );
			App.goto("city/co");
			return;
		}
		if( cadaver.mapId != App.user.mapId ) {
			App.goto("city/co");
			return;
		}
		if( cadaver.hasHomeRecycled() ) {
			notify( Text.get.RecyclingAlreadyDone );
			App.goto("city/co");
			return;
		}
		if( !App.user.canDoTiringAction(1) ) {
			notify( Text.fmt.NeedPA({n:1}) );
			App.goto("city/seeCadaver?id="+cadaver.id);
			return;
		}
		cadaver.homeRecycle++;
		cadaver.update();
		App.user.doTiringAction(1);
		if( cadaver.hasHomeRecycled() ) {
			var rsc = cadaver.recycle();
			if( rsc.length == 0 ) {
				notify( Text.fmt.RecycledNothing({c:cadaver.print()}) );
				var m = db.Map.manager.get( App.user.mapId, false ); // On évite de locker la ressource
				CityLog.add( CL_GiveInventory, Text.fmt.CL_RecycledNothing( {c:cadaver.print(), rsc:rsc.join(", ")} ), m );
			} else {
				notify( Text.fmt.RecyclingDone({c:cadaver.print(),rsc:rsc.join(", ")}) );
				var m = db.Map.manager.get( App.user.mapId, false ); // On évite de locker la ressource
				CityLog.add( CL_GiveInventory, Text.fmt.CL_RecyclingDone( {c:cadaver.print(), rsc:rsc.join(", ")} ), m );
			}
		} else {
			notify( Text.fmt.Recycling({c:cadaver.print()}) );
		}
		App.goto("city/seeCadaver?id="+cadaver.id);
	}

	public function doBank() {
		var map = App.user.getMapForDisplay();
		addDefenseInfo( map, db.CityBuilding.manager.getDoneBuildingsHash(map) );
		var canRob = map.canRobBank();
		App.context.canRob = canRob;
		App.context.theft = canRob && App.request.getInt("theft")==1;
		addLogs( [CL_GiveInventory,CL_TakeInventory,CL_Refined,CL_BankRob], map, 100 );
	}

	private function getRealPaCost(cost, fact:Float, map:Map) {
		fact = (100-fact) / 100;
		return Math.ceil( cost * fact );
	}
	
	private function flattenTreeBranch(tree:Hash<List<CityBuilding>>, branch:List<CityBuilding>) : List<CityBuilding> {
		var list = new List();
		for( b in branch ) {
			var binfos = b.getInfos();
			list.add(b);
			if( tree.exists(binfos.key) ) {
				var subList = flattenTreeBranch(tree, tree.get(binfos.key));
				for( sb in subList )
					list.add(sb);
			}
		}
		return list;
	}
	
	public function doBuildings() {
		var repartition = mt.deepnight.Lib.randomSpread(800, 40);
		var total = 0;
		for(r in repartition)
			total += r;
		
		var map = App.user.getMapForDisplay();
		var city = map._getCity();
		var filter = App.request.get("filter");
		
		// array optimisé pour un accès rapide aux stocks par le toolId
		var stocks = new Array();
		var bank = ZoneItem.manager.countZoneItemList( App.user.zoneId );
		for( i in bank )
			stocks[i.id] = i.amount;
		App.context.stocks = stocks;
		
		// création une représentation array(linéaire) de l'arbre des buildings
		var allBuildings = CityBuilding.manager.getKnownBuildings(map).filter( function(b) return XmlData.buildings.exists(b.type) );
		var doneBuildingsHash = CityBuilding.manager.getDoneBuildingsHash(map);
		var tree = new Hash();
		for(b in allBuildings) {
			if( b.getInfos() == null ) throw "Error: unknown infos about building "+b.type;
			var parent = b.getInfos().parent;
			if( !tree.exists(parent) )
				tree.set(parent, new List());
			tree.get(parent).add(b);
		}
		
		var groups = new List();
		var categories = new List();
		for( b in tree.get("") ) {
			var binfos = b.getInfos();
			categories.add(binfos);
			if(filter == null || binfos.key == filter) {
				var group = new List();
				group.add(b);
				if( tree.get(binfos.key) != null ) {
					for( sb in flattenTreeBranch(tree, tree.get(binfos.key)) ) {
						group.add(sb);
					}
				}
				groups.add(group);
			}
		}
		// recommandations
		var rBuild : CityBuilding = null;
		for( b in allBuildings )
			if( !b.isDone && b.isVisible(doneBuildingsHash) )
				if( b.heroVotes > 0 &&(rBuild==null || b.heroVotes > rBuild.heroVotes) ) rBuild = b;
		App.context.recommendedBuilding = rBuild;
		
		if( !db.ZoneAction.manager.hasDoneAction(App.user, "recommendBuilding") && App.user.hasHeroUpgrade("writeCityBoard") )
			App.context.canRecommendBuilding = true;
		App.context.categories = categories;
		App.context.groups = groups;
		App.context.doneBuildingsHash = doneBuildingsHash;
		App.context.buildingList = Lambda.list(doneBuildingsHash);
		// calcul des coûts de construction ajustés en PA
		var paCostFactor = db.CityUpgrade.getValueIfAvailableByKey( "command", map, 0 );
		var paCosts = new Hash();
		for( group in groups )
			for( b in group ) {
				var binfos = b.getInfos();
				paCosts.set(binfos.key, getRealPaCost(binfos.paCost, paCostFactor, map));
			}
		App.context.paCosts = paCosts;
		App.context.getDef = CityBuilding.getDef;
		// infos diverses
		addLogs( [CL_Building,CL_NewBuilding,CL_NewBuildingFailed], map );
		App.context.city = city;
		App.context.filter = filter;
		App.context.city = city;
		App.context.repairRatio = Const.get.RepairRatio;
		App.context.refundPA = db.MapVar.getValue(map, "refundPA", 0);
	}

	function doRecommendBuilding() {
		var user = App.user;
		var map = user.getMapForDisplay();
		var building = CityBuilding.manager.getByKey( map, App.request.get("k"), true );
		if( building == null || building.isDone )
			return;
		var done = db.ZoneAction.manager.hasDoneAction(App.user, "recommendBuilding");
		if( user.isCityBanned ) {
			notify( Text.get.BanForbidden );
			App.goto("city/buildings");
			return;
		}
		var done = db.ZoneAction.manager.hasDoneAction(user, "recommendBuilding");
		if( !done && user.hasHeroUpgrade("writeCityBoard") ) {
			building.heroVotes ++;
			building.update();
			db.ZoneAction.add( App.user, "recommendBuilding");
			notify(Text.get.RecommendedBuilding );
		} else
			notify(Text.get.CantRecommendBuilding);
		App.goto("city/buildings");
		return;
	}
	
	function doRepairBuilding() {
		var user = App.user;
		var map = user.getMapForDisplay();
		var building = CityBuilding.manager.getByKey(map, App.request.get("k"), true );
		var pa = App.request.getInt("more", 1);
		
		var repairRatio:Int = Const.get.RepairRatio;
		var atelierUpgrade = db.CityUpgrade.getValueIfAvailableByKey("command", 2, map, 0);
		neko.Web.logMessage("atelierUpgrade:" + atelierUpgrade);
		repairRatio += Std.int(atelierUpgrade);
		
		var repair = pa * repairRatio;
		if( building == null || !building.isDone || building.life == building.maxLife || pa == null || pa <= 0 )
			return;
		
		var  l = new List<db.CityBuilding>();
		if ( !building.isActive(l) )
		{
			notify( Text.fmt.BuildingRequired({building:l.first().getInfos().name}) );
			App.goto("city/buildings");
			return;
		}
		
		var binfos = building.getInfos();
		var maxPa = Math.ceil((building.maxLife-building.life) / Const.get.RepairRatio );
		// blessure bras
		if( App.user.hasWound( W_Arm ) ) {
			notify( Text.get.WoundedArm );
			App.goto("city/buildings");
			return;
		}
		// trop de PA investis ?
		if( pa > maxPa ) {
			notify(Text.fmt.TooManyPA( { n:pa, max:Math.floor((building.maxLife-building.life)/Const.get.RepairRatio) } ) );
			App.goto("city/buildings");
			return;
		}
		var pc = user.getPc();
		// Pas assez de PA pour bosser là-dessus
		if( !user.canDoTiringAction( pa - pc ) ) {
			notify(Text.fmt.NeedPA( { n:pa } ) );
			App.goto("city/buildings");
			return;
		}
		// ok !
		user.validateActivity(Common.BIT_BUILD);
		//On permet de réparer avec des points de chantier
		var usedPc = false;
		if ( pc > 0 ) {			
			var pcCost = mt.MLib.min( pc, pa );
			user.usePc(pcCost);
			pa -= pcCost;
			usedPc = true;
			appendNotify( Text.fmt.UsedTechnicianPA( { n:pcCost } ) );			
			db.GhostReward.gain(GR.get.buildr, user, pcCost);
		}
		
		user.doTiringAction(pa);
		building.life += Std.int( Math.min(repair, building.maxLife - building.life) );
		building.update();
		notify( Text.fmt.RepairedBuilding({building:binfos.name, repair:repair, pa:pa}) );
		if( App.user.hasCityBuilding("buildingRegistry") )
			CityLog.add( CL_Building, Text.fmt.CL_RepairedBuilding({name:user.print(), building:binfos.name, repair:repair }), map, user );
		
		if( !usedPc )
			db.GhostReward.gain(GR.get.brep, user, pa);
		App.goto("city/buildings");
	}

	public function doParticipateBuild() {
		//Thomas slaveryOffice Implementation
		var map = App.user.getMapForDisplay();
		var hasSlaveryOffice = map.hasCityBuilding("slaveryOffice");
		if( !hasSlaveryOffice && checkCityBan("city/buildings", App.user) ) return;

		var city = map._getCity();
		var doneHash = CityBuilding.manager.getDoneBuildingsHash(map);
		var b = CityBuilding.manager.getByKey(map, App.request.get("k"), true);
		if( b == null || b.isDone || !b.isVisible(doneHash) ) {
			App.goto("city/buildings");
			return;
		}
		var binfos = b.getInfos();
		if( App.user.hasWound( W_Arm ) ) {
			notify( Text.get.WoundedArm );
			App.goto("city/buildings");
			return;
		}
		var pa = App.request.getInt("more",1);
		if( pa==null || pa<=0 ) {
			notify(Text.get.Forbidden);
			App.goto("city/buildings");
			return;
		}

		// vérification + lock des ressources
		var tids = Lambda.map(binfos.needList, function(need) { return need.t.toolId; } );
		var bankItems = new List();
		if( tids.length > 0 ) bankItems = ZoneItem.manager.getItemList(tids, city, false, true); // lockés
		for( need in binfos.needList ) {
			var fl_ok = false;
			for( zi in bankItems )
				if(zi.toolId == need.t.toolId && zi.count >= need.amount)
					fl_ok = true;
			if( !fl_ok ) {
				notify( Text.fmt.CantBuildNow({building:binfos.print()}) );
				App.goto("city/buildings");
				return;
			}
		}

		var fact = db.CityUpgrade.getValueIfAvailableByKey( "command", map, 0 );
		var realPaCost = getRealPaCost( binfos.paCost, fact, map );
		// Bâtiment qui est normalement déjà terminé, on réduit l'investissement PA à 0
		if( b.pa >= realPaCost )
			pa = 0;
		// on n'a pas le droit d'investir plus que les PA restants à investir
		var maxNeededPa = Math.max(0, realPaCost - b.pa);
		if( maxNeededPa > 0 && pa > maxNeededPa ) {
			notify(Text.fmt.TooManyPA({n:pa,max:maxNeededPa}) );
			App.goto("city/buildings");
			return;
		}
		
		var refundVar = db.MapVar.manager.getVar(map, "refundPA", true); // lock requis
		var refundPA = if( refundVar != null ) refundVar.value else 0;
		var pc = App.user.getPc();
		// Pas assez de PA pour bosser là-dessus
		if( refundPA <= 0 ) {
			// PA personnels
			if( pa > 0 && !App.user.canDoTiringAction(pa - pc) ) {
				notify( Text.fmt.NeedPA({n:pa}) );
				App.goto("city/buildings");
				return;
			}
		} else {
			// PA issus d'un remboursement de bâtiment(passage v2->v3)
			if( pa > refundPA ) {
				notify(Text.get.RefundPALimit);
				App.goto("city/buildings");
				return;
			}
		}
		
		// On valide l'investissement du citoyen, s'il a effectivement investi des PA dessus
		if( pa > 0 ) {
			var bonus = if( refundPA <= 0 && App.user.isCityBanned && hasSlaveryOffice ) Math.floor(pa * 0.5) else 0;
			b.pa += pa + bonus;
			if( bonus > 0 )
				CityLog.add( CL_Building, Text.fmt.CL_WorkedOnBuildingSlavery( { name:App.user.print(), building:binfos.name } ), map, App.user );
			else if( CityBuilding.manager.hasBuilding(map, "buildingRegistry") )
				CityLog.add( CL_Building, Text.fmt.CL_WorkedOnBuilding( { name:App.user.print(), building:binfos.name } ), map, App.user );
		}
		App.user.validateActivity(Common.BIT_BUILD); // donné dans tous les cas, car c'est juste signe que le joueur est allé au chantier :)

		if( b.pa >= realPaCost ) {
			// chantier terminé !
			b.pa = realPaCost;
			for(need in binfos.needList)
				for(zi in bankItems)
					if(zi.toolId == need.t.toolId) {
						zi.count -= need.amount;
						if(zi.count <= 0)
							zi.delete();
						else
							zi.update();
					}
			b.isDone = true;
			b.applyEffects();
			var list = new Array();
			for( need in binfos.needList ) {
				need.t.isBroken = false;
				list.push( need.t.print()+" x"+need.amount );
			}
			CityLog.add( CL_NewBuilding, Text.fmt.CL_NewBuilding( {name:binfos.print(), list:list.join(",")} ), map );
			CityLog.add( CL_TakeInventory, Text.fmt.CL_BuildingUsedRsc( {building:binfos.print(), list:list.join(",")} ), map );
			notify(Text.fmt.DoneBuilding({building:binfos.print()}) );
		} else {
			// le chantier a avancé mais n'est pas terminé...
			notify(Text.fmt.ParticipatedBuilding({building:binfos.print()}) );
		}

		// On retire les PA
		if( pa > 0 ) {
			if( refundPA <= 0 ) {
				db.GhostReward.gain(GR.get.buildr, App.user, pa);
				// ... de la réserve du métier en premier
				if( pc > 0 ) {
					var pcCost = mt.MLib.min(pc, pa);
					App.user.usePc(pcCost);
					
					pa -= pcCost;
					appendNotify( Text.fmt.UsedTechnicianPA({n:pcCost}) );
				}
				if( pa > 0 ) {
					// .. de la réserve du User
					App.user.doTiringAction(pa);
					appendNotify( Text.fmt.UsedPA( { n:pa } ) );
					if(App.user.isCityBanned && hasSlaveryOffice)
						appendNotify( Text.get.Slavery );
				}
			} else {
				// .. de la réserve de remboursement de la ville(passage v2->v3)
				refundVar.value -= pa;
				refundVar.update();
				appendNotify( Text.fmt.UsedRefundPA({n:pa}) );
			}
		} else
			appendNotify( Text.get.DidNotUsedPA );

		b.update();
		App.goto("city/buildings");
	}

	public function doCreateExp() {
		if( Expedition.manager.countForMap(App.user.map) >= Const.get.MaxExpeditionsByCity ) {
			notify( Text.fmt.TooManyExpeditions({n:Const.get.MaxExpeditionsByCity}) );
			App.goto("city/exp");
			return;
		}
		if( Expedition.manager.hasExpedition(App.user) ) {
			notify(Text.get.AlreadyHaveExpedition);
			App.goto("city/exp");
			return;
		}
		var clist = new Array();
		var n = 0;
		var raw = new Array();
		while( App.request.exists("coord_"+n) ) {
			var c = App.request.get("coord_"+n);
			c = StringTools.trim(c);
			c = StringTools.replace(c," ","");
			c = StringTools.replace(c,",",MapCommon.CoordSep);
			c = StringTools.replace(c,"/",MapCommon.CoordSep);
			c = StringTools.replace(c,";",MapCommon.CoordSep);
			if( c != "" ) {
				raw.push(c);
				clist.push(c);
			}
			n++;
		}

		var name = App.request.get("name");
		name = StringTools.trim(name);
		name = tools.Utils.removeAccents(name);
		if( name == "" ) {
			notify(Text.get.ExpeditionNameMissing);
			App.goto("city/exp?editor=1;prev="+raw.join(MapCommon.GroupSep));
			return;
		}
		var e = Expedition.create(App.user,clist.join(MapCommon.GroupSep),name);
		if( e == null ) {
			notify(Text.get.InvalidPath);
			App.goto("city/exp?editor=1;name="+name+";prev="+raw.join(MapCommon.GroupSep));
		} else {
			App.goto("city/exp?path="+e.path);
		}
	}

	public function doDeleteExp() {
		if( !Expedition.manager.hasExpedition(App.user) ) {
			return;
		}
		var e = Expedition.manager.getByUser(App.user, true);
		e.delete();
		notify(Text.get.ExpeditionDeleted);
		doExp();
	}

	public function doExp() {
		var fl_editor = App.request.exists("editor");
		if( fl_editor && Expedition.manager.hasExpedition(App.user) ) {
			notify(Text.get.AlreadyHaveExpedition);
			return;
		}
		prepareTemplate( "city/expeditions.mtt" );

		var map = App.user.getMapForDisplay();
		var city = map._getCity();
		App.context.elist = Expedition.manager.getByMapId(App.user.map);
		var path = App.request.get("path");
		if( path == null ) {
			path = ""; // used to detect path-preview mode
		}
		if( App.request.exists("prev") ) {
			var prev = App.request.get("prev");
			if( prev.length > 0 ) {
				var prevPath = prev.split(MapCommon.GroupSep);
				App.context.prevPath = prevPath;
				// coordonnées cartésiennes
				var prevPathDisp = new Array();
				for( c in prevPath ) {
					var ptStr = c.split(MapCommon.CoordSep);
					var pt = MapCommon.coords( city.x, city.y, Std.parseInt(ptStr[0]), Std.parseInt(ptStr[1]) );
					prevPathDisp.push( pt.x + "," + pt.y );
				}
				App.context.prevPathDisp = prevPathDisp;
				App.context.name = App.request.get("name");
				path = prev;
			}
		}

		App.context.editor = fl_editor;
		var expeditions = db.Expedition.manager.getByMapId(map);
		var mdata = OutsideActions.getMapData(map,App.user, city, 0,0,0);
		App.context.outsideMapInit = updateMapDataForCity( map, mdata, expeditions, path, fl_editor );
		var hasExp = false;
		for( e in expeditions ) {
			if( e.userId == App.user.id ) {
				hasExp = true;
				break;
			}
		}
		App.context.hasExp = hasExp;
		App.context.hasDoorOpened = map.getDoorOpened();
	}

	public function getRefineCost() {
		var cost = Const.get.PA_Refine;
		if( App.user.hasTool("tool_saw", true) )
			cost--;
		if( App.user.hasCityBuilding("factory") )
			cost--;
		return cost;
	}
	
	function doRefine() {
		var map = App.user.getMapForDisplay();
		checkBuilding(map, "command");
		var ziList = ZoneItem.manager._getZoneItems(App.user.zone);
		var list = new List();
		for( zi in ziList ) {
			if( zi.count > 0 ) {
				var xmlTool = XmlData.getTool(zi.toolId);
				if ( xmlTool == null ) continue;
				
				if( xmlTool.hasType(Refinable) )
					list.push({ tool:xmlTool, count:zi.count, rcount:0 });
			}
		}
		for( i in list ) {
			var rep = i.tool.getReplacement();
			if( i.tool.replacement.length > 1 ) {
				i.rcount = -1; // random replacement
			} else {
				for( zi in ziList ) {
					if( zi.toolId == rep.toolId ) { // TODO : rep.id transformé en rep.toolId : bug à signaler ?
						i.rcount = zi.count;
						break;
					}
				}
			}
		}
		App.context.tlist = list;
		App.context.cost = getRefineCost();
		addLogs( [CL_Refined], App.user.getMapForDisplay() );
	}

	function doRefineItem() {
		var map = App.user.getMapForDisplay();
		checkBuilding(map, "command");
		var cost = getRefineCost();
		var xmlTool = XmlData.getTool(App.request.getInt("tid"));
		if( xmlTool == null || !xmlTool.hasType(Refinable) )
			return;
		
		if( checkCityBan("city/refine", App.user) )
			return;
		var pc = App.user.getPc();
		if( !App.user.canDoTiringAction(cost - pc) ) {
			notify( Text.fmt.NeedPA({n:cost}) );
			App.goto("city/refine");
			return;
		}
		var zitem = ZoneItem.manager._getByToolId( App.user.zone, xmlTool.toolId, false, true );
		if( zitem == null || zitem.count <= 0 ) {
			notify(Text.get.ItemNoMoreInBank);
			App.goto("city/refine");
			return;
		}
		
		var rep = xmlTool.getReplacement();
		rep.isBroken = false;
		if( pc > 0 ) {
			var extraBuildingVar = db.UserVar.manager.getVar(App.user, "buildingActions", true); // lock requis
			var pcCost = Math.min(extraBuildingVar.value, cost).int();
			extraBuildingVar.value -= pcCost;
			extraBuildingVar.update();
			cost -= pcCost;
			appendNotify( Text.fmt.UsedTechnicianPA({n:pcCost}) );
		}
		
		//use user actions
		App.user.doTiringAction(cost);
		ZoneItem.addToCity( App.user.map, rep );
		db.GhostReward.gain( GR.get.refine );
		App.user.validateActivity( Common.BIT_REFINE );
		zitem.delete();
		
		CityLog.add( CL_Refined, Text.fmt.CL_Refined( {name:App.user.print(), from:xmlTool.print(), tool:rep.print()} ), map, App.user );
		notify( Text.fmt.Refined({tool:xmlTool.print(), ref:rep.print()}) );
		appendNotify( Text.fmt.UsedPA( { n:cost } ) );
		
		App.goto("city/refine");
	}

/*------------------------------------- PRIVATES ---------------------------------*/

	private function getUserToolsHash( tools : List<Tool>) : IntHash<List<Tool>> {
		var ht : IntHash<List<Tool>>= new IntHash();
		var uid : Int = null ;
		var ctools : List<Tool>= new List();
		var toolL = tools.length;
		var i = 0;
		for( t in tools ) {
			if( uid != t.userId ) {
				if( uid == null ) {
					uid= t.userId;
				} else {
					ht.set( uid, ctools );
					uid = t.userId;
					ctools = new List();
				}
			}
			ctools.add( t );
			if( i++ >= toolL -1 ) {
				ht.set( uid, ctools );
			}
		}
		
		for ( u in ht.keys() )
		{
			var l = ht.get(u);
			if ( l != null && l.length > 0 ) 
				ht.set(u, db.User.sortTools(l));
		}
		
		return ht;
	}
	
	private function getUsersDefenseHash( atools : List<Tool>) : IntHash<Int> {
		var tl = Lambda.map( XmlData.getToolsByType( Armor ), function( t: Tool ) { return t.toolId; });
		var tools = new List();
		for( t in atools ) {
			for( tt in tl ) {
				if( t.toolId == tt ) {
					tools.add( t );
					break;
				}
			}
		}
		var ht : IntHash<Int> = new IntHash();
		var uid : Int = null ;
		var def = 0;
		var toolL = tools.length;
		for( i in 0...tools.length ) {
			var t = tools.pop();
			if( t.isBroken )
				continue;
			if( uid != t.userId ) {
				if( uid == null ) {
					uid= t.userId;
				} else {
					ht.set( uid, def );
					uid = t.userId;
					def = 0;
				}
			}
			def++;
			if( i >= toolL - 1 ) {
				ht.set( uid, def );
			}
		}
		return ht;
	}

	public static function addLogs( ?user:db.User, ?keys : Array<CityLogKey>, m : db.Map, ?zone:db.Zone, ?limit:Int ) {
		if( App.request.exists("logDay") )
			App.context.logDay = Std.parseInt(App.request.get("logDay"));
		if( App.request.exists("fullLog") )
			limit = 9999999;

		var logs = if( zone == null ) db.User.getCityLogs( user, keys, m, limit ) else zone.getLogs( keys, user, limit );
		// on récupère les infos des joueurs
		var uids = new List();
		var h = new IntHash();
		for( l in logs ) {
			if( l.userId != null && !h.exists(l.userId) ) {
				h.set( l.userId, true );
				uids.add( l.userId );
			}
		}
		var users = new IntHash();
		if( uids.length > 0 ) {
			var ul = Db.results("SELECT id, dead, mapId, name, avatar, homeMsg FROM User where id IN(" + uids.join(",") + ")");
			for( u in ul )
				users.set( u.id, {name:u.name, avatar:u.avatar, homeMsg:u.homeMsg} );
		}
		App.context.lusers = users;
		App.context.logs = logs;
		App.context.logLimited = limit!=null && limit<9999 && logs.length>limit;
	}

	function checkCityBan(url, user) {
		if( user.isCityBanned ) {
			notify( Text.get.BanForbidden );
			App.goto( url );
			return true;
		}
		return false;
	}
	
	// TODO : à optimiser ?
	static function checkBuilding(?map:Map, bkey:String) {
		if( map == null)
			map = App.user.getMapForDisplay();
		if( !CityBuilding.manager.hasBuilding(map, bkey) )
			throw "Bâtiment introuvable";
	}
	
	/*** TOUR DE GUET ***/
	
	static function roughEstim(e:{min:Int, max:Int}, rough) {
		// réalise une approximation à +/- "rough" d'une plage de valeurs
		e.min = Math.floor(e.min / rough) * rough;
		e.max = Math.ceil( e.max / rough) * rough;
	}

	public static function getEstimQuality( map : Map, ?buildings ) {
		var maxToday = 0.85;
		var hasScanner = if( buildings != null ) buildings.exists( "scanner" ) else db.CityBuilding.manager.hasBuilding(map, "scanner");
		if( hasScanner ) {
			maxToday = 0.95;
		}
		return maxToday;
	}
	
	public static function getEstim(map:Map,user:User, ?buildings, ?doneActions) {
		var city = map._getCity();
		var count = map.estimCount;
		var needed = Const.get.Tower1NeededInspections;
		//si il y a cet objet en banque, on réduit le nombre necessaire d'inspections
		var telescope = XmlData.getToolByKey("scope");
		var bankItems = map.getCityItems();
		for ( i in bankItems )
			if ( i.toolId == telescope.toolId ) {
				needed = needed >> 1;
				break;
			}
		
		var maxToday = 0.85;
		// réduction du nombre de clics requis si Scanner construit
		var hasScanner = if( buildings != null ) buildings.exists( "scanner" ) else db.CityBuilding.manager.hasBuilding(map, "scanner");
		if( hasScanner ) {
			needed = Const.get.Tower2NeededInspections;
			maxToday = 0.95;
		}
		if( map.chaos ) {
			needed = Math.floor(needed * 0.66);
		}
		// prévisions du lendemain
		var estimNext = null;
		var qualityNext = 0.0;
		var hasNextDay = if( buildings != null ) buildings.exists("nextDay") else db.CityBuilding.manager.hasBuilding(map, "nextDay");
		if( hasNextDay ) {
			needed = Math.floor(needed * 0.8);
			qualityNext = Math.min(0.9, (count-needed)/needed);
			estimNext = map.getAttackTowerEstimationNoCache( qualityNext, map.days+1 );
			roughEstim(estimNext, 25);
		}
		// prévision aujourd'hui
		var quality = Math.min(maxToday,count/needed);
		var estim = map.getAttackTowerEstimationNoCache( quality );
		
		if ( quality < 0.75 ) roughEstim(estim, 5);
		
		var maxed = quality == maxToday;
		var maxedNext = qualityNext >= 0.9;
		var allMaxed = (maxed && !hasNextDay) ||(maxed && hasNextDay && maxedNext);
		// estimations foireuses le jour de l'armageddon
		if( App.isEvent("arma") ) {
			if( estim != null ) {
				estim.min *= Std.random(4)+2;
				estim.max *= Std.random(6)+6;
			}
			if( estimNext != null ) {
				estimNext.min *= Std.random(4)+1;
				estimNext.max *= Std.random(4)+5;
			}
		}
		
		return {
			hasScanner	: hasScanner,
			hasNextDay	: hasNextDay,
			count		: count,
			estim		: (estim),
			maxed		: (maxed),
			estimNext	: (estimNext),
			maxedNext	: (maxedNext),
			done		: if( doneActions != null ) doneActions.exists( "towerInspect" ) else db.ZoneAction.manager.hasDoneAction(App.user, "towerInspect"),
			required	: !allMaxed,
			tooLow		:(estim.q < 30),
		}
	}
	
	function doTower() {
		checkBuilding("tower");
		App.context.eData = getEstim( App.user.getMapForDisplay(), App.user );
	}
	
	function doTowerInspect() {
		var map = App.user.map;
		checkBuilding(map, "tower");
		if( db.ZoneAction.manager.hasDoneAction(App.user, "towerInspect") ) {
			notify( Text.get.AlreadyDone);
			App.goto("city/tower");
			return;
		}
		map.estimCount++;
		map.update();
		if( !App.DEBUG ) {
			notify( Text.get.TowerInspection );
			db.ZoneAction.add( App.user, "towerInspect" );
		}
		App.goto("city/tower");
	}
	
	/*** CATAPULTE ***/
	
	function doCatapult() {
		var map = App.user.getMapForDisplay();
		checkBuilding(map, "catapult");
		var isMaster = map.catapultMaster==App.user;
		if( isMaster ) {
			var list = Lambda.filter(App.user.getAllTools(false), function(t) {
				return t.canBeLaunched(App.user);
			});
			App.context.inv = list;
		}
		addLogs( [CL_Catapult], map );
		App.context.noMaster = needMaster();
		App.context.master = map.catapultMaster;
		App.context.isMaster = isMaster;
		App.context.width = map.width;
		App.context.height = map.width;
		var city = map._getCity();
		App.context.coords = function(x:Int,y:Int) {return MapCommon.coords(city.x, city.y, x, y);};
		App.context.cost = map.getCatapultCost();
		App.context.bestCost = map.hasCityBuilding("catapult2");
	}
	
	function needMaster() {
		var cm = App.user.map.catapultMaster;
		return cm == null || cm.dead || cm.mapId != App.user.mapId || cm.isCityBanned;
	}
	
	function doCatapultMaster() {
		checkBuilding("catapult");
		if( needMaster() ) {
			var all = Lambda.list( User.manager.getMapUsers( App.user.getMapForDisplay(), false, false ) );
			all = Lambda.filter(all, function(u:User) {
				return !u.isCityBanned;
			});
			var ulist = new List();
			// héros actifs
			if( ulist.length == 0 )
				ulist = Lambda.filter(all, function(u:User) {
					return u.hero && u.getActivityRatio() >= 0.5;
				});
			// héros
			if( ulist.length == 0 )
				ulist = Lambda.filter(all, function(u:User) {
					return u.hero;
				});
			// actifs
			if( ulist.length == 0 )
				ulist = Lambda.filter(all, function(u:User) {
					return u.getActivityRatio() >= 0.5;
				});
			// tous les joueurs
			if( ulist.length == 0 )
				ulist = all;
			// personne ??
			if( ulist.length == 0 ) {
				notify(Text.get.ImpossibleAction);
				App.goto("city/catapult");
				return;
			}
			var map = Map.manager.get(App.user.mapId, true); // lockée
			var rseed = new mt.Rand(map.id);
			var uarray = Lambda.array(ulist);
			var u = uarray[rseed.random(uarray.length)];
			map.catapultMaster = u;
			map.update();
			
			MessageActions.sendOfficialMessage( u, Text.get.MT_NewCatapMaster, Text.get.M_NewCatapMaster );
		}
		notify( Text.fmt.CatapultNewMaster({u:App.user.map.catapultMaster.print()}) );
		App.goto("city/catapult");
	}

	function doCatapultLaunch() {
		var map = App.user.getMapForDisplay();
		checkBuilding(map, "catapult");
		if( needMaster() || map.catapultMaster != App.user ) {
			notify(Text.get.Forbidden);
			App.goto("city/catapult");
			return;
		}
		
		var x = App.request.getInt("x", 0);
		var y = App.request.getInt("y", 0);
		var city = map._getCity();
		var tzone = Zone.manager._getZone(map, city.x+x, city.y-y, false);
		if( x == 0 && y == 0 || tzone == null ) {
			notify(Text.get.CatapultInvalidZone);
			App.goto("city/catapult");
			return;
		}
		
		var cost = map.getCatapultCost();
		if( !App.user.canDoTiringAction(cost) ) {
			notify(Text.fmt.NeedPA({n:cost}));
			App.goto("city/catapult");
			return;
		}
		var tool = Tool.manager.get( App.request.getInt("tid",0) );
		if( tool == null || !tool.canBeLaunched(App.user) ) {
			notify(Text.get.CatapultInvalidItem);
			App.goto("city/catapult");
			return;
		}
		
		// décalage aléatoire
		var arrival =
			if( Std.random(100) < Const.get.CatapultMiss ) {
				var rzones = new List();
				rzones.add( {x:tzone.x, y:tzone.y} );
				rzones.add( {x:tzone.x-1, y:tzone.y} );
				rzones.add( {x:tzone.x+1, y:tzone.y} );
				rzones.add( {x:tzone.x, y:tzone.y-1} );
				rzones.add( {x:tzone.x, y:tzone.y+1} );
				for( pt in rzones )
					if( pt.x < 0 || pt.x >= map.width || pt.y < 0 || pt.y >= map.width || pt.x == city.x && pt.y == city.y )
						rzones.remove(pt);
				if( rzones.length == 0 )
					return;
				var pt = Lambda.array(rzones)[ Std.random(rzones.length) ];
				Zone.manager._getZone( map, pt.x, pt.y, false );
			} else
				tzone;
		
		// transformation
		var resultItem = tool;
		if( tool.hasType(Animal) )
			resultItem = XmlData.getToolByKey("undef");
		if( tool.hasType(Alcohol) || tool.action == "grenade" || tool.key == "pharma" || tool.key == "poison" || tool.key == "coffee" )
			resultItem = XmlData.getToolByKey("broken");

		CityLog.add( CL_Catapult, Text.fmt.CL_CatapultLaunch( {u:App.user.print(), t:tool.print(), x:arrival.coord(city).x, y:arrival.coord(city).y} ), map, App.user );
		CityLog.addToZone( CL_OutsideEvent, Text.fmt.OutsideCatapultLand({t:resultItem.print()}), map, arrival );
		notify( Text.fmt.CatapultLaunch({t:tool.print(), x:arrival.coord(city).x, y:arrival.coord(city).y}) );
		ZoneItem.create(arrival, resultItem.toolId);
		App.user.doTiringAction(cost);
		tool.delete();
		App.goto("city/catapult");
	}

	/*** INSURRECTIONS ***/

	function makeRevolution() {
		var user = App.user;
		var map = user.map;
		if( !map.hasMod("BANNED") ) return;
		//
		map.conspiracy = -1;
		map.update();
		var users = db.User.manager.getMapUsers( map, false, true );
		for( u in users ) {
			if( u.isCityBanned )	u.isCityBanned = false;
			else 					u.cityBan();
			u.eventState = Type.enumIndex( ES_revolution);
			u.update();
		}
		App.reboot();
	}

	public function doConspirate() {
		var user = App.user;
		var map = user.map;
		if( !user.isCityBanned ) {
			notify(Text.get.Forbidden);
			App.goto("city/enter");
			return;
		}
		if( map.conspiracy < 0 ) {
			notify(Text.get.AlreadyRevolted);
			App.goto("city/enter");
			return;
		}
		if( db.ZoneAction.manager.hasDoneAction(user,"conspirate") ) {
			notify( Text.get.AlreadyDone);
			App.goto("city/enter");
			return;
		}
		// calcul du score de vote, pondéré par plusieurs facteurs
		var voteValue = 5.0;
		var banneds = map.countCityBanned();
		var notBanneds = map.countCityNotBanned();
		if( notBanneds == 0 ) {
			voteValue = 99999;
		} else {
			var ratio = banneds/notBanneds;
			voteValue =(voteValue * 0.3) +(0.7 * voteValue * ratio); // pondéré par ratio bannis / non-bannis,
			voteValue = voteValue * banneds; // puis pondéré par nb de bannis.
		}
		// apply vote
		map.conspiracy += voteValue;
		map.update();
		if( map.conspiracy >= 1000 ) {
			makeRevolution();
			notify( Text.get.Revolted );
		} else {
			notify( Text.get.Conspiracy );
		}
		db.ZoneAction.add( user, "conspirate" );
		App.goto("city/enter");
	}

	/*** UPGRADES DE BÂTIMENTS ***/

	public function doUpgrades() {
		var map = App.user.getMapForDisplay();
		// on récupère les bâtiments construits qui sont upgradables
		var upgrades = new List();
		var bh = CityBuilding.manager.getDoneBuildingsHash(map);
		for( b in bh ) {
			var binfos = b.getInfos();
			if ( b != null && binfos.hasLevels ) {
				var upInfos = XmlData.getCityUpgradeByParent(binfos);
				upgrades.add( {
					level	: 0,
					votes	: 0,
					data	: upInfos,
					maxLevel: upInfos.levels.length-1,
				});
			}
		}
		// on met à jour cette liste avec le level atteint et les votes
		var dbupList = db.CityUpgrade.manager.getVotes(map);
		var voteTotal = 0;
		for( dbup in dbupList ) {
			var dbBuilding = dbup.getBuilding();
			for( up in upgrades ) {
				if( up.data.parent == dbBuilding ) {
					up.level = dbup.level;
					up.votes = dbup.votes;
					voteTotal += up.votes;
					break;
				}
			}
		}
		App.context.devastated = map.devastated;
		App.context.getDescFunction = db.CityUpgrade.getUpgradeDesc;
		App.context.voteTotal = voteTotal;
		App.context.hasVoted = db.ZoneAction.manager.hasDoneAction(App.user,"voteUpgrade");
		App.context.availableUpgrades = upgrades;
		App.context.maxUpgradeLevel = Const.get.MaxUpgradeLevel;
	}

	public function doVoteUpgrade() {
		if( checkCityBan("city/upgrades", App.user) )
			return;
		if( App.user.getMapForDisplay().devastated )
			return;
		if( db.ZoneAction.manager.hasDoneAction(App.user, "voteUpgrade") ) {
			notify( Text.get.AlreadyDone);
			App.goto("city/upgrades");
			return;
		}
		if( !App.request.exists("bid") ) {
			notify(Text.get.Forbidden);
			App.goto("city/upgrades");
			return;
		}
		var building = XmlData.getBuildingById( App.request.getInt("bid", 0) );
		if( building == null ) {
			notify(Text.get.UnknownBuilding);
			App.goto("city/upgrades");
			return;
		}

		var count = db.CityUpgrade.addVote(building, App.user.map, 1);
		if( count == null ) {
			notify(Text.get.Forbidden);
			App.goto("city/upgrades");
			return;
		}
		db.ZoneAction.add( App.user, "voteUpgrade" );
		App.goto("city/upgrades");
	}

	function addDefenseInfo( map:db.Map, buildings ) {
		var zone = map._getCity();
		var items = ZoneItem.manager._getZoneItems( zone, false );
		var defInfos = map.getCityDefense( items, buildings );
		
		App.context.buildingDefense = defInfos.buildings;
		App.context.bonusDef = defInfos.bonus;
		App.context.cadaversDef = defInfos.cadavers;
		App.context.itemDefCount = defInfos.itemInfos.items;
		App.context.itemDefMul = defInfos.itemInfos.mul;
		App.context.itemDefTotal = defInfos.itemInfos.total;
		App.context.upgradeDefenseInfos = defInfos.upgradeInfos;
		App.context.tempDef = defInfos.temp;
		App.context.map = map;
		App.context.homes = defInfos.userInfos.homes;
		App.context.guards = defInfos.userInfos.guards;
		App.context.baseDefense = Const.get.BaseDefense;
		App.context.totalDefense = defInfos.total;
		App.context.itemBonus = defInfos.itemInfos.mul;
		App.context.alivePlayers = defInfos.userInfos.count;
		App.context.guardiansInfos = defInfos.guardiansInfos;
		App.context.soulsDefense = defInfos.souls;
		
		var estim = getEstim(map, App.user, buildings);
		if( !estim.tooLow ) {
			var maxEstim = estim.estim.max;
			//var probaCoef = data.Guardians.getSurvivalCoef(defInfos.guardiansInfos.def, maxEstim - defInfos.total + defInfos.guardiansInfos.def);
			//App.context.guardiansDeathChance = Math.min(100, Std.int(probaCoef * Const.get.GuardianDeathChance));
		}
		
		var ar = Lambda.array( items );
		ar.sort( function(a, b) {
			if( a.count < b.count ) return 1;
			if( a.count > b.count ) return -1;
			var ta = XmlData.getTool(a.toolId);
			if( ta == null ) throw "Tool with Id " + a.toolId + " does not exist !";
			var tb = XmlData.getTool(b.toolId);
			if( tb == null ) throw "Tool with Id " + b.toolId + " does not exist !";
			if( ta.name.toLowerCase() < tb.name.toLowerCase() ) return -1;
			if( ta.name.toLowerCase() > tb.name.toLowerCase() ) return 1;
			return Std.random(2) * 2 - 1; // randomisation pour cacher les items empoisonnés
		});
		var list = Lambda.list(ar);
		App.context.itemsCategorized = db.ZoneItem.categorizeItemList(list);
		App.context.items = list;
	}

	function expSwf( elist : List<Expedition>) {
		var list = new Array();
		for( e in elist ) {
			list.push({
				_i	: e.id,
				_n	: e.name,
				_p	: e.path,
			});
		}
		return list;
	}

	function doSetHeroMsg() {
		if( !App.user.hero || !App.user.hasHeroUpgrade("writeCityBoard") ) {
			notify(Text.get.Forbidden);
			App.goto( "city/enter" );
			return;
		}
		if( App.user.isCityBanned || App.user.muted ) {
			notify( Text.get.AnyBanForbidden );
			App.goto( "city/enter" );
			return;
		}

		var txt = tools.Utils.sanitize( App.request.get("heroMsg") , 99999 );
		if( txt == null ) {
			notify(Text.get.Forbidden);
			App.goto( "city/enter" );
			return;
		}

		var map = App.user.map;
		if( txt == "" ) {
			map.heroMsg = null;
		} else {
			var size = 500;
			do {
				map.heroMsg = txt.substr(0, size--);
			} while( !neko.Utf8.validate(map.heroMsg) && size > 490 );
		}
		map.update();
		App.goto( "city/enter" );
	}

	function doRefillWaterWeapons() {
		if( !App.user.hasCityBuilding("robinet") ) {
			notify( Text.get.Forbidden );
			return;
		}
		// on vide d'abord tous les pistolets à eau chargés
		for( t in App.user.getToolsByType(Weapon) ) {
			if( t.action == "waterGun" ) {
				var empty = t.getReplacement();
				while( empty.action=="waterGun" ) empty = empty.getReplacement();
				Tool.add( empty.toolId, App.user, t.inBag );
				t.delete();
			}
		}
		// on rempli tout ce qui peut l'être
		var filled = new List();
		for( t in App.user.getTools( )) {
			if( t.hasType(EmptyWeapon) && t.parts.length == 1 && t.parts.first() == "water" ) {
				var rep = Tool.add( t.getReplacement().toolId, App.user, t.inBag );
				filled.add(rep);
				t.delete();
			}
		}
		if( filled.length == 0 ) {
			notify( Text.get.NothingToFill );
		} else {
			notify( Text.fmt.FilledWaterWeapons({list:ToolActions.printList(filled)}) );
		}
		App.goto( "home" );
	}

	function doGiveTool() {
		var target = db.User.manager.get( App.request.getInt("uid") );
		var tool = db.Tool.manager.get( App.request.getInt("tid"), true );
		if( target == null || tool == null || !App.user.playsWithMe(target) || target.homeProtected() || !target.isOutside ) {
			notify(Text.get.Forbidden);
			App.goto("city/co");
			return;
		}
		var url = "city/seeClint?id="+target.id;
		if( tool.userId != App.user.id || tool.soulLocked || !tool.inBag ) {
			notify(Text.get.Forbidden);
			App.goto(url);
			return;
		}
		if( App.user.hasStolen ) {
			notify(Text.get.AlreadyDone);
			App.goto(url);
			return;
		}

		var map = App.user.getMapForDisplay();
		if( map.chaos ) {
			notify(Text.get.ForbiddenChaos);
			App.goto(url);
			return;
		}
		if( tool.hasType(Bag) ) {
			notify(Text.get.CantGiveThat);
			App.goto(url);
			return;
		}

		App.user.hasStolen = true;
		App.user.update();
		var newTool = Tool.add(tool.toolId, target, false);
		newTool.isBroken = tool.isBroken;
		newTool.update();
		notify( Text.fmt.GaveTool({tool:tool.print(),target:target.print()}) );
		if( !App.user.hasTool("cm_suit", true) && Std.random(100) < Const.get.GiftDetection ) {
			appendNotify(Text.get.Detected);
			CityLog.add( CL_Thief, Text.fmt.CL_GaveTool( {name:App.user.print(), tool:tool.print(), target:target.print()} ), map, App.user );
		}
		tool.delete();
		App.goto(url);
	}

	function getSinkValues(map:Map) {
		var h = new IntHash();
		// bonus
		var global = map.hasCityBuilding("humidDump") ? 1 : 0;
		var rsc = 1 + global;
		var def = 4 + global +(map.hasCityBuilding("armouredDump") ? 2 : 0);
		//Thomas dump stuff Implementation
		var weaponSink 	= {allowed:false, def:1};
		var foodSink 	= {allowed:false, def:1};
		var animalSink 	= {allowed:false, def:1};
		var woodSink 	= {allowed:false, def:0};
		var metalSink 	= {allowed:false, def:0};
		
		if( map.hasMod("IMPROVED_DUMP") ) {
			weaponSink.allowed = true;
			if( map.hasCityBuilding("weaponDump") ) weaponSink.def += 5;
			
			foodSink.allowed = true;
			if( map.hasCityBuilding("foodDump") ) foodSink.def += 3;
			
			woodSink.allowed = true;
			if( map.hasCityBuilding("woodDump") ) woodSink.def += 1;

			metalSink.allowed = true;
			if( map.hasCityBuilding("metalDump") ) metalSink.def += 1;

			animalSink.allowed = true;
			if( map.hasCityBuilding("animalDump") ) animalSink.def += 6;

		} else {
			weaponSink.allowed 	= map.hasCityBuilding("weaponDump");
			foodSink.allowed 	= map.hasCityBuilding("foodDump");
			woodSink.allowed 	= map.hasCityBuilding("woodDump");
			metalSink.allowed 	= map.hasCityBuilding("metalDump");
			animalSink.allowed 	= map.hasCityBuilding("animalDump");
			weaponSink.def = 5;
			foodSink.def = 3;
			animalSink.def =  6;
		}
		
		for( t in XmlData.tools ) {
			if(t != null) {
				if( t.hasType(Armor) && !t.hasType(Critical) && !t.hasType(Animal) && !t.hasType(Weapon) ) // objets défensifs
					h.set(t.toolId, def);
				if( woodSink.allowed && (t.key == "wood" || t.key == "wood_bad") ) // bois
					h.set(t.toolId, rsc + woodSink.def);
				if( metalSink.allowed && (t.key == "metal" || t.key == "metal_bad") ) // métal
					h.set(t.toolId, rsc + metalSink.def);
				if( animalSink.allowed && t.hasType(Animal) ) // animaux
					h.set(t.toolId, animalSink.def + global);
				if( foodSink.allowed && t.hasType(Food) ) // nourriture
					h.set(t.toolId, foodSink.def + global);
				if( weaponSink.allowed && t.hasType(Weapon) && !t.hasType(JobTool) ) // armes
					h.set(t.toolId, weaponSink.def + global );
			}
		}
		return h;
	}
	
	function doDump() {
		var map = App.user.getMapForDisplay();
		checkBuilding(map, "publicDump");
		var zone = map._getCity();
		var zoneItems = ZoneItem.manager._getZoneItems(zone, false);
		var sinkables = new Array();
		var hvalues = getSinkValues(map);
		for( zi in zoneItems )
			if( hvalues.get(zi.toolId) > 0 && zi.count > 0 && zi.visible && !zi.isBroken )
				sinkables.push( { zi:zi, tool:XmlData.getTool(zi.toolId) } );
				
		sinkables.sort(function(a,b) {
			return -Reflect.compare(hvalues.get(a.zi.toolId), hvalues.get(b.zi.toolId));
		});
		//Thomas freeDump Implementation
		App.context.paCost = map.hasCityBuilding("freeDump") ? 0 : 1;
		App.context.hvalues = hvalues;
		App.context.sinkables = sinkables;
		var buildings = db.CityBuilding.manager.getDoneBuildingsHash(map);
		addDefenseInfo( map, buildings );
		addLogs([CL_Dump], map);
	}
	
	function doDumpInstall() {
		var user = App.user;
		var map = user.getMapForDisplay();
		var city = map._getCity();
		checkBuilding(map, "publicDump");
		
		var tid = App.request.getInt("tid");
		var hvalues = getSinkValues(map);
		var zi = ZoneItem.manager.getByToolId( tid, city, false, true );
		if( zi == null || zi.count <= 0 )
			return;
		if( user.isCityBanned )
			return;
		var count = App.request.getInt("count", 1);
		if( count <= 0 || count > zi.count ) {
			notify(Text.get.TooManyItemsForDump);
			App.goto("city/dump");
			return;
		}
		//Thomas freeDump Implementation
		var pa = map.hasCityBuilding("freeDump") ? 0 : (1 * count); // c'est quoi la priorité déjà ? je suis pas sûr :)
		if( pa > 0 && !user.canDoTiringAction(pa) ) {
			notify(Text.fmt.NeedPA( { n:pa } ));
			App.goto("city/dump");
			return;
		}
		var value = hvalues.get(zi.toolId);
		if( value <= 0 )
			return;
		if( pa > 0 )
			user.doTiringAction(pa);
		zi.count -= count;
		zi.update();
		
		var map = Map.manager.get(map.id, true); // lock
		var def = value * count;
		map.tempDef += def;
		map.update();
		
		CityLog.add(CL_Dump, Text.fmt.CL_DumpedItem( {name:user.print(), t:XmlData.getTool(tid).print(), n:count, def:def} ), map, user);
		notify(Text.fmt.UsedInDump( { n:count, tool:XmlData.getTool(tid).print(), def:def } ));
		App.goto("city/dump");
	}

}
