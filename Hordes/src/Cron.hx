import db.CityUpgrade;
import db.ZoneAction;
import neko.Lib;
import tools.Utils;
import db.BuildingStats;
import db.CityLog;
import db.CityBuilding;
import db.Cadaver;
import db.Tool;
import db.User;
import db.GameStat;
import db.Zone;
import db.ZoneItem;
import db.NewsInfo;
import db.Map;
import Common;
import DailyNews;

enum CronException {
	IgnoreMap;
}

using Lambda;
using mt.Std;
class Cron {

	static var CURRENT_DAY : Date = null;
	static var QUARANTINE = new List();					// Liste des erreurs des maps mises en quarantaine
	static var ALREADY_ATTACKED_TODAY : Bool = false;	// Permet de savoir si un attaque a déjà été effectuée dans la journée
	static var ATTACK_LOG : String = "";

	static function transactionLoop( f:Void->Bool ) {
		#if !tests Db.execute("COMMIT"); #end
		var ok = true;
		var i = 0;
		while( ok && i < 3 ){
			i++;
			#if !tests Db.execute("START TRANSACTION"); #end
			try {
				ok = f();
				#if !tests Db.execute("COMMIT"); #end
			} catch( e : Dynamic ) {
				#if !tests Db.execute("ROLLBACK"); #end
				if( !neko.db.Transaction.isDeadlock(e) || i >= 3 )
					neko.Lib.rethrow(e);
			}
		}
		#if !tests Db.execute("START TRANSACTION"); #end
	}
	
/*----------------------------------------MAPS--------------------------------*/
// lancé 1x par jour le matin
	public static function maps() {
		transactionLoop(function(){
			return false;
		});
	}
	
/*----------------------------------------GAMES--------------------------------*/
// lancé toutes les minutes
	public static function games() {
		transactionLoop(function() {
			// pas de gestion des parties en cours de cron
			if( db.HordeEvent.manager.isEvent( H_Attack ) )
				return false;
			// ni en maintenance !
			if( db.Version.manager.isMaintain() )
				return false;
			//
			printLog( Date.now().toString() );
			printLog( "\n");
			printLog( "\n[GLOBAL] CLOSE GAMES\n" );
			//
			closeGames();
			return false;
		});
		transactionLoop(function(){
			// pas de gestion des parties en cours de cron
			if( db.HordeEvent.manager.isEvent( H_Attack ) )
				return false;
			// ni en maintenance !
			if( db.Version.manager.isMaintain() )
				return false;
			printLog("<games>");
			refillMapPool();
			refillMapPool(); // double appel pour assurer un pool plein + une liste de parties ouvertes pleine
			printLog("</games>");
			return false;
		});
		doGather();
	}
	
	public static function doGather() {
		transactionLoop(function(){
			// pas de gestion des parties en cours de cron
			if( db.HordeEvent.manager.isEvent( H_Attack ) )
				return false;
			if( db.Version.manager.isMaintain() )
				return false;
			printLog( "\n[GLOBAL] UTILITY FUNCTIONS\n" );
			gather();
			//endUselessGames();
			return false;
		});
	}
	
	public static function refillMapPool() {
		// on crée des villes noobs s'il en manque dans le stock
		var noobPool = db.Map.manager.countMapsInPool("level=0");
		printLog("<poolRegenNoob noobPool="+noobPool+" total="+App.getDbVar("mapsInPool")+"/>");
		for( i in noobPool...db.Map.getMinNoobMap() )
			createGame(false, new neko.Random());
		
		// puis des villes "éloignées"...
		var farPool = db.Map.manager.countMapsInPool("level="+db.Version.getVar("minXp", 100));
		printLog("<poolRegenFar farPool="+farPool+" total="+App.getDbVar("mapsInPool")+"/>");
		for( i in farPool...App.getDbVar("mapsInPool") - db.Map.getMinNoobMap() )
			createGame(true, new neko.Random());
		
		// on ouvre les inscriptions sur les villes pour avoir un choix suffisant
		var open = db.Map.manager.countOpenMaps();
		var needToOpen = Std.int( Math.max(0, App.getDbVar("mapsInPool") - open) );
		printLog("<open open="+open+" total="+App.getDbVar("mapsInPool")+" needToOpen="+needToOpen+"/>");
		Map.manager.openMaps( needToOpen );
	}
	
	// Le cron s'assure d'une seule chose : qu'il y ait au moins une partie ouverte à tout moment
	public static function createGame(far:Bool, rnd:neko.Random, ?p_callbackAfterCreation:db.Map->Void) {
		var map = Map.create( XmlData.getRandomCityName(), far, rnd.int, p_callbackAfterCreation );
		
		var z = MapGenerator.generate(map, rnd);
		for( i in 0...Const.get.ZombieStartIterations )
			zombieFountainsInAction( map, Lambda.list( z ), rnd.int );

		// on ouvre les inscriptions
		map.status = Type.enumIndex( GameIsOpened );
		// le user null est une feature, puisque twinoid permet ensuite de préciser le nom souhaité (ou le compte twinoid) par lequel il sera remplacé
		createGameForums(map);
		map.update();
		return map;
	}
	
	public static function createGameForums( pMap:db.Map )
	{
		var map = pMap;
		//sécurité, pour ne pas traiter les vieilles villes, étant donné qu'elles n'auront pas le forumId != null
		if ( map.season < db.Version.getVar("season") || (map.forumId != null && map.forumId > 0) )
			return;
		
		var data = {
			lang: Config.LANG.toLowerCase(),
			forum: {
				key: "city_"+map.id,
				name: map.name,
				icon : App.IMG+"/gfx/design/bannerForumVille.gif",
			},
			posts: [ {
				user: null,
				tag: Text.get.SysId_Forum_Tag,
				title:Text.get.SysId_Bank_title,
				text: Text.get.SysId_Bank_content,
				sticky: true,
			}, {
				user: null,
				tag: Text.get.SysId_Forum_Tag,
				title:Text.get.SysId_Refinery_title,
				text: Text.get.SysId_Refinery_content,
				sticky: true,
			}, {
				user: null,
				tag: Text.get.SysId_Forum_Tag,
				title:Text.get.SysId_Buildings_title,
				text: Text.get.SysId_Buildings_content,
				sticky: true,
			}, {
				user: null,
				tag: Text.get.SysId_Forum_Tag,
				title:Text.get.SysId_Upgrades_title,
				text: Text.get.SysId_Upgrades_content,
				sticky: true,
			} ]
		};
		
		map = db.Map.manager.get(map.id, true);
		if ( !mt.db.Twinoid.callApi("forumInit", { data: haxe.Serializer.run(data) }, false) )
		{
			db.Error.create("/cron/createGame", "Impossible to initialize twinoid forums");
			map.forumId = null;
		}
		else
		{
			map.forumId = map.id;
		}
		map.update();
	}
	
/*----------------------------------------HORDE--------------------------------*/
	
	public static function horde() {
		
		if ( db.Version.manager.isGlobalQuarantine() ) {
			printLog( "<globalSiteLock />" );
			return;
		}
		
		CURRENT_DAY = Date.now();
		transactionLoop(function(){
			startHordeAttack();
			return false;
		});
		
		// DUMP
		printLog( "<mysqlDump>" );
		printLog( "<sql/>" );
		var file = "dump_hordes_"+StringTools.replace( Date.now().toString(), " ", "_" )+".sql";
		var dbconf = App.getDatabaseConfig();
		var folder = Utils.getConfigSection("dumpfolder", App.CONFIG).get("value");
		neko.Sys.command( "/usr/bin/mysqldump -a -e -q -Q -h"+dbconf.host+" -u"+dbconf.user+" -p"+dbconf.pass+" -P"+dbconf.port+" "+dbconf.database+" > "+folder+"/" + file );
		printLog( "<pigz/>" );
		neko.Sys.command( "/usr/bin/pigz "+folder+"/"+file );
		printLog( "</mysqlDump>" );
		
		transactionLoop(function() {
			if( countAllMapsPlayableForCron() <= 0 ) {
				printLog( "<noMap/>" );
				endHordeAttack();
			}
			return false;
		});
		
		#if !tests
		neko.Sys.sleep( Const.get.start );
		#end
		// attaques en local
		if( !App.PROD ) {
			Db.execute("UPDATE Map SET lastAttack=null");
		}
		// On gère le cas des maps non remplies
		var fdMaps = Map.manager.getFirstDayOpened();
		printLog("<firstDayMapsToCheck v='" +fdMaps.length + "'/>");
		for( m in fdMaps )
			if( m.countP > 0 )
				CityLog.add( CL_Attack, Text.get.CL_Attack_NotEnoughPlayers, m  );
		// On récupère les maps à checker
		db.Tool.manager.cleanup();
		var maps = Map.manager.getAllPlayableForCron();
		printLog("<mapsToCheck v='" +maps.length + "'/>");
		// On regarde si on a déjà lancé une attaque aujourd'hui
		var mapsAlreadyCheckedToday = Db.execute("SELECT Count(*) FROM Map WHERE inPool=0 AND lastAttack IS NOT NULL AND LEFT(lastAttack,10) =" + Db.quote(CURRENT_DAY.toString().substr(0,10)) ).getIntResult(0);
		printLog("<mapsAlreadyCheckedToday v='" + mapsAlreadyCheckedToday + "'/>");
		if( mapsAlreadyCheckedToday > 0 )
			ALREADY_ATTACKED_TODAY = true;
		// on détruit les villes privées qui n'ont pas réuni assez de participants
		var openCustMaps = Map.manager.getOpenCustomMaps();
		if( openCustMaps.length > 0 ) {
			for( m in openCustMaps ) {
				if( db.MapVar.getBool(m, "incomplete") ) { // on ne détruit qu'à la 2ème nuit incomplète
					printLog("<canceledMap id="+m.id+" name='"+m.name+"'/>");
					m.cancel();
				} else if( !User.manager.get( m.getVarValue("creator") ).isAdmin ) {
					db.MapVar.setValue(m, "incomplete", 1);
				}
			}
		}
		// listing des joueurs ayant un réveil activé sur eux
		var alarmClock = XmlData.getToolByKey("reveil");
		var alarmOwners = Lambda.map(Db.results("SELECT userId FROM Tool WHERE toolId="+alarmClock.toolId+" AND inBag=1 AND isBroken=0"), function(r) {
			return r.userId;
		});
		for( map in maps ) {
				if( map.isQuarantined() )
					printMapLog( map, "\n<quarantine_map id='"+map.id+"' day='"+map.days+"'>");
				else
					printMapLog( map, "\n<map id='"+map.id+"' day='"+map.days+"'>");
				try {
					#if !tests
					Db.execute("START TRANSACTION");
					#end
					db.Tool.manager.cleanup();
					map = Map.manager.get( map.id, true );
					// Si on relance le cron dans la journée, on ne rejoue pas les maps déjà jouées
					if ( map.lastAttack != null && map.lastAttack.toString().substr(0, 10) == CURRENT_DAY.toString().substr(0, 10) && map.status != Type.enumIndex(Quarantine) ) {
						printMapLog( map, "<alreadyPlayedToday/>" );
						printMapLog( map, "</map>" );
						#if !tests Db.execute("COMMIT"); #end
						throw IgnoreMap;
					}
					if ( map.days <= 1 && ALREADY_ATTACKED_TODAY ) {
						printMapLog( map, "<newMapNoNeedAttackBeforeNight/>" );
						printMapLog( map, "</map>" );
						#if !tests Db.execute("COMMIT"); #end
						throw IgnoreMap;
					}
					map.lastAttack = CURRENT_DAY;
					var deadInAttack = new List();
					
					rewardNoobsGuides(map);
					oneMoreDayForHeroes(map); // XP + 1
					
					var soulsToHaunt = getMapSoulsToHaunt(map);
					
					//we get map users, randomize them since ordered by name, and cache the current guardian infos
					var users = User.manager.getMapUsers(map, false, true);
					var guardiansInfosCache = new IntHash();
					for ( u in User.manager.getMapUsers(map, false, true) ) {
						guardiansInfosCache.set(u.id, u.cacheGuardianInfos());
					}
					
					var lostHeroes = oneLessDayForHeroes(map); // days - 1
					var outsideDeaths = killOutside(map);
					killDehydrated(map);
					killInfected(map);
					killAddict(map);
					killGhouls(map);
					
					unsetHungOver(map);
					infectWounded(map);
					setDrugged(map);
					setHungOver(map);
					setDehydrated(map);
					setThirsty(map);
					resetCampBonus(map);
					resetDrunk(map);
					resetEaten(map);
					resetTired(map);
					resetConvalescent(map);
					resetDailyThefts(map);
					resetWaterFlag(map);
					resetNewsReading(map);
					resetHeroActions(map);
					resetHeroRecommandations(map);
					resetEscorts(map);
					updateGhouls(map);
					var survivorIds = updateCamps(map);
					closeDoors(map);
					
					printMapLog(map, "<beta v='"+App.BETA+"'/>");
					resetMoves( map );
					woundedPA(map);
					
					// On reset le log de l'attaque
					map.attackLogBlob = null;
					map.attackLog = "";
					var gameStat = GameStat.addStat(map);
					var newsInfo = new NewsInfo();
					newsInfo.mapId = map.id;
					
					// on construit les upgrades votés dans la journée
					cityUpgrades(map, newsInfo);
					if( map.status == Type.enumIndex(GameIsClosed) && map.diff == null )
						map.diff = map.getDiff(); // freezes difficulty after "game-lock-day"
					
					// Le gros +1 :)
					var oldDay = map.days;
					map.days += 1;
					
					printMapLog(map, "<day from='"+oldDay+"' to='"+map.days+"'/>");
					var zombies = Horde.getTotalAttackForMap(map, map.days-1);
					printMapLog(map, "<zombies v='"+zombies+"'/>");
					gameStat.attackCount = zombies;
					var news = new DailyNews(map);
					news.data.zombies = zombies;
					CityLog.add( CL_Attack, Text.fmt.CL_Attack_ZombiesCount( { z:zombies } ), map  );
					
					//clean flag
					db.MapVar.removeValue(map, "attackPercent");
					
					var users = User.manager.getMapUsers(map, false, true).shuffle().list();
					for ( u in users ) {
						//on remet en place le cache de guarde calculé auparavant
						u.cachedGuardianInfos = guardiansInfosCache.get(u.id);
					}
					var inTownCount = Lambda.filter(users, function(u) { return u.isOutside == false;}).length;
					printMapLog(map, "<count inTownCount='"+inTownCount+"' survivors="+survivorIds.length+"/>");
					
					// centrale nucléaire
					var fl_reactorExploded = false;
					var reactor = db.CityBuilding.manager.getByKey(map, "reactor", true);
					if ( reactor != null && reactor.isDone ) {
						
						//var ratio = Range.makeInclusive(20, 50).draw();
						var ratio = mt.MLib.randRange(20, 50);
						var dmg = Std.int( reactor.maxLife * ratio/100 );
						reactor.life -= dmg;
						reactor.update();
						printMapLog(map, "<reactor dmg="+dmg+" ratio='"+ratio+"%' life="+reactor.life+"/>");
						if( reactor.life > 0 )
							CityLog.add( CL_Attack, Text.fmt.CL_ReactorDamaged( { b:reactor.getInfos().print(), d:dmg } ), map );
						
						if( reactor.life <= 0 ) {
							// explosion : on extermine tout le monde
							fl_reactorExploded = true;
							printMapLog(map, "<reactorDestroyed/>");
							CityLog.add( CL_Attack, Text.fmt.CL_ReactorDestroyed({b:reactor.getInfos().print()}), map );
							reactor.destroy(map);
							db.GhostReward.manager.gainForAll(map, GR.get.dnucl);
							var uids = User.manager.getMapUserIds(map);
							
							if( HordeAttack.isMatureMap(map) && !map.devastated ) {
								// récompenses
								var atomDeads = Lambda.filter( User.manager.getByUids(uids), function(u) return (!u.dead && !u.isOutside) );
								if( atomDeads.length > 0 ) {
									HordeAttack.initStatics(map, printMapLog);
									HordeAttack.giveLastRewards(atomDeads);
								}
							}
							var n = 0;
							if( uids.length > 0 )
								kill( map, DT_Infected, Text.get.DT_Infected, "u.id IN(" + uids.join(",") + ") AND dead=0", map.days, map.days - 1, GR.get.dinfec );
							printMapLog(map, " count="+n);
							newsInfo.article = news.generateReactorDestroyed();
							newsInfo.zombiesCount = zombies;
							news.data.deads = new List();
						}
					}
					if( !fl_reactorExploded ) {
						if( inTownCount <= 0 && survivorIds.length == 0 ) {
							// Aucun joueur en vie
							printMapLog(map, "<deadTown/>");
							printMapLog(map, "<flagMapForDeletion/>");
							map.status = Type.enumIndex( EndGame );
						} else {
							// Attaque normale
							if( inTownCount <= 0 )
								townDevastation( map, news.data );
							
/********************************** ATTACK ***********************************/
							printMapLog(map, "<attack>");
							var deads : List<User> = HordeAttack.resolve( map, zombies, users, CURRENT_DAY, gameStat, newsInfo, printMapLog );
							printMapLog(map, "</attack>");
/*********************************** END *************************************/	
							
							newsInfo.zombiesCount = zombies;
							if( deads == null )	{
								printMapLog(map, "<noDead/>");
								// régénération des cases du désert
								mapRegen(map, newsInfo);
								
								var needCouncil = false;
								// Rien à notifier
								// On spécifie la mort du chaman dans les registres
								if ( map.hasMod("SHAMAN_SOULS") && db.User.manager.getCityShaman(map) == null ) {
									if( !map.flags.get(SHAMAN_ELECTION) ) {
										news.data.deadShaman = oldDay > 1;
										map.flags.set(SHAMAN_ELECTION);
									} else {
										needCouncil = true;
									}
								}
								
								if ( db.User.manager.getCityGuide(map) == null ) {
									if( !map.flags.get(GUIDE_ELECTION) ) {
										news.data.deadGuide = oldDay > 1;
										map.flags.set(GUIDE_ELECTION);
									} else {
										needCouncil = true;
									}
								}
								
								if( needCouncil ) {
									newsInfo.cityCouncil = DailyNews.generateCouncil(map.doElections(oldDay == 1));
								}
								
								news.data.deads = new List() ;
								newsInfo.article = news.generate();
								// on dispatche les zombies
								zombieFountainsInAction( map, map._getOutsideDescription(true), true );
							} else {
								printMapLog(map, "<attackSucceed/>");
								
								if( deads.length == inTownCount ) {
									printMapLog(map, "<deadTown/>");
									// TOUT LE MONDE EST MORT EN VILLE
									for( dead in deads )
										deadInAttack.add( dead.id );
									gameStat.deathCount = deads.length;
									if( survivorIds.length > 0 )
										townDevastation( map, news.data );
									// régénération des cases du désert
									mapRegen(map, newsInfo);
									// on dispatche les zombies
									zombieFountainsInAction( map, map._getOutsideDescription(true), true );
									newsInfo.article = news.generateLast();
								} else {
									printMapLog(map, "<hasSurvivors/>");
									var dcount = 0;
									dcount = deads.length;
									gameStat.deathCount = dcount;
									var deathList = new List();
									if( dcount > 0 )
										deathList = Lambda.map( deads, function( dead: User ) return dead.name );
									news.data.deads = deathList;
									for( dead in deads ) {
										if( !dead.isAdmin || (dead.isAdmin && !dead.hasTool("shield_mt", true, true)) ) {
											deadInAttack.add( dead.id );
										}
									}
									// régénération des cases du désert
									mapRegen(map, newsInfo); 
									// on dispatche les zombies
									zombieFountainsInAction( map, map._getOutsideDescription(true), true );
									
									var needCouncil = false;
									if( map.hasMod("SHAMAN_SOULS") ) {
										var shaman = db.User.manager.getCityShaman(map);
										if( shaman != null ) {
											for( u in deads ) {
												if( u.id == shaman.id ) {
													shaman = null;
													break;
												}
											}
										}
										if (shaman == null ) {
											if( !map.flags.get(SHAMAN_ELECTION) ) {
												news.data.deadShaman = oldDay > 1;
												map.flags.set(SHAMAN_ELECTION);
											} else {
												needCouncil = true;
											}
										}
									}
									var guide = db.User.manager.getCityGuide(map);
									if( guide != null ) {
										for( u in deads ) {
											if( u.id == guide.id ) {
												guide = null;
												break;
											}
										}
									}
									if (guide == null ) {
										if( !map.flags.get(GUIDE_ELECTION) ) {
											news.data.deadGuide = oldDay > 1;
											map.flags.set(GUIDE_ELECTION);
										} else {
											needCouncil = true;
										}
									}
									
									if( needCouncil ) 
										newsInfo.cityCouncil = DailyNews.generateCouncil(map.doElections(oldDay == 1, deads));
									
									// on génère les news
									newsInfo.article = news.generate();
								}
							}
						}
					}
					
					// utilisation des effets des upgrades
					resetCheckedZones(map);
					useDailyCityUpgrades( map, newsInfo );
					// on sauvegarde le log de l'attaque
					map.attackLogBlob = neko.Lib.stringReference(neko.Lib.serialize( map.attackLog ));
					if( deadInAttack.length > 0 )
						killEaten( deadInAttack, map );
					
					if( map.hasCityBuilding("garden") )
						harvest(map);
					
					if( map.hasCityBuilding("architectoire") )
						buildingPlanDrop(map);
					
					if( map.hasCityBuilding("appletree") ) // pommier
						appleTree(map);
					
					if( map.hasCityBuilding("henhouse") ) // poulailler
						eggs(map);
					
					newsInfo.insert();
					gameStat.update();
					dropDeadTools(map);
					updateGuardsStats(map);
					noMoreGuards(map);
					if( users.length - deadInAttack.length <= Const.get.ChaosLimit )
						setChaos(map);
					resetZoneKills(map);
					updateJobRewards(map, lostHeroes);
					var zids = getZoneIds(map);
					resetExpeditions(map);
					resetUserActivity(map);
					resetTowerEstim(map);
					resetZoneActions(map,zids);
					resetZoneTags(map);
					resetZoneFlags(map);
					resetCamps(map);
					
					//SOULS
					hauntSouls(map, soulsToHaunt);
					
					updateZoneHumanScores(map);
					destroyTemporaryBuildings(map);
					processFireworks(map);
					resetCityUpgradeVotes(map);
					updateHumanScores(map);
					
					resetMapFlags(map);
					
					giveLastCampsReward(map, survivorIds);
					
					var allDead = Db.results( "SELECT userId FROM Cadaver WHERE mapId="+map.id + " AND createDate="+Db.quote(CURRENT_DAY.toString()) );
					if( allDead.length > 0 ) {
						var ids = Lambda.map( allDead, function( info:{userId:Int} ) {return info.userId;} ).join(",");
						deleteMessages(ids);
						dropComplaints(ids);
						deleteDeadJobs(ids);
						resetMapGather(ids);
					}
					// goules mortes pendant l'attaque
					var deadGhouls = Db.results( "SELECT userId FROM Cadaver WHERE isGhoul=1 AND mapId="+map.id + " AND createDate="+Db.quote(CURRENT_DAY.toString()) );
					if( deadGhouls.length > 0 ) {
						var uids = Lambda.map( deadGhouls, function( info:{userId:Int} ) {return info.userId;} );
						printMapLog(map, "<deadGhouls l='"+uids.join(",")+"'/>");
						for( uid in uids )
							if( db.GameAction.manager.countActionByUserId(uid, "devourTotal") <= 0 ) {
								// goule n'ayant dévoré personne !
								printMapLog(map, "<lazyGhoul uid="+uid+"/>");
								db.MapVar.manager.fastInc( map.id, "lazyGhoul" );
							}
					}
					
					// Dans le cas d'une simple quarantaine on repasse en mode normal
					if( map.status == Type.enumIndex( Quarantine ) ) {
						map.status = Type.enumIndex( GameIsClosed );
						map.openDoor(false);
						map.availableForJoin = false;
					}
					
					ringAlarmClock(map, alarmOwners);
					transformTools(map);
					resetTrance(map);
					resetImmunity(map);
					specialDays(CURRENT_DAY, map);
					
					if( false == map.hasMod("SAFE_MODE") )
						map.tempDef = 0;
					
					printMapLog( map, "</map>" );
					map.update();
					#if !tests Db.execute("COMMIT"); #end
					ATTACK_LOG = "";
				} catch( e : Dynamic ) {
					if( e == IgnoreMap )
						continue;
					
					var errorMsg = Std.string(e+"\n------\n" + haxe.Stack.exceptionStack() + "\n------\n");
					QUARANTINE.add(errorMsg);
					
					#if !tests
					Db.execute("ROLLBACK");
					Db.execute("START TRANSACTION");
					#end
					
					printLog( "<attackFailed e='"+errorMsg+"'/>" );
					printLog( "<quarantine/>" );
					db.Tool.manager.cleanup();
					map = Map.manager.get( map.id, true );
					map.sync();
					map.status = Type.enumIndex(Quarantine);
					
					var stack = haxe.Stack.exceptionStack().join("\n");
					map.attackLogBlob = neko.Lib.stringReference(neko.Lib.serialize( ATTACK_LOG + "<exception>" + Std.string( e ) + "<stack>" + stack + "</stack></exception>"));
					map.update();
					
					CityLog.add( CL_AttackEvent, Text.get.CL_Attack_Quarantine, map  );
					
					printLog( "<heroGetsBonus/>" );
					// On indemnise les joueurs
					var players = Db.results("SELECT id FROM User WHERE mapId="+map.id +" AND hero=1 and heroDays>0");
					if( players.length > 0 ) {
						var ids = Lambda.map( players, function ( info : {id:Int} ) { return info.id;} );
						Db.execute( "UPDATE User SET hero=1, heroDays = heroDays + 1 WHERE id IN("+ ids.join(",")+")" );
					}
					
					ATTACK_LOG = "";
					#if !tests Db.execute("COMMIT"); #end
					printLog( "</map>" );
				}
		}
		
		// Maintenance sans relation avec le fonctionnement des parties
		transactionLoop(function(){
				deleteMaps();
				cleanUpZoneItems();
				deleteXmlCache();
				teamLogCleanup();
				resetEventsForDead();
				resetGather();
				makeStats();
				if( db.GameMod.hasMod("SEASON_RANKINGS") )
					buildRankings(); // lent !
				if( db.GameMod.hasMod("SOUL_SEASON_RANKING") )
					buildSoulRanking();
				cleanup();
			return false;
		});
		
		if( QUARANTINE.length > 0 ) {
			// On envoie un mail :)
			try {
				tools.Mail.bug( QUARANTINE );
				printLog( "<sendingMailToAdmin/>" );
			} catch( e : Dynamic ) {
				printLog( "<sendMailFailed/>" );
			}
			QUARANTINE = new List();
		}
		
		// Délai avant la fin de l'attaque
		transactionLoop( function() {
			var duration = db.Version.getVar("attackDuration", 25);
			var wishedEnd = DateTools.delta( CURRENT_DAY, DateTools.minutes(duration) ) ;
			var diff = Math.ceil( ( wishedEnd.getTime() - Date.now().getTime() ) / 1000 / 60 );
			printLog( "<wait duration='"+duration+"' diff='"+diff+"' wished='"+wishedEnd.toString()+"' current='"+CURRENT_DAY+"'/>");
			if( diff > 0 ) {
				printLog( "<waitingBeforeEndingAttack minutes='"+diff+"'/>");
				#if !tests
				neko.Sys.sleep( diff * 60 );
				#end
			}
			endHordeAttack();
			return false;
		});
	}
	
	static function resetMapFlags(map:Map) {
		db.MapVar.setValue(map, "plansDroppedToday", 0);
	}
	
	static function getMapSoulsToHaunt(map:db.Map) {
		if( !map.hasMod("SHAMAN_SOULS") )
			return { zoneSouls:new List(), exploSouls:new List(), toolSouls:new List() };
		// we include the ones inside the city
		var soul = XmlData.getToolByKey("soul");
		var l = new List();
		l.add(soul.toolId);
		
		var soulsInZone = ZoneItem.manager.getAllToolsInMap(map, soul.toolId, true);
		var soulsInExplo = db.ExploItem.manager.getAllToolsInMap(map, soul.toolId);
		var toolSouls = db.Tool.manager.getMapUserTools(map, l, true, true );
		return { zoneSouls:soulsInZone, exploSouls:soulsInExplo, toolSouls:toolSouls };
	}
	
	public static function hauntSouls( map:Map, pSouls:{zoneSouls:List<db.ZoneItem>, exploSouls:List<db.ExploItem>, toolSouls:List<db.Tool>} ) {
		if( !map.hasMod("SHAMAN_SOULS") )
			return;
		
		printLog( "<hauntSouls zoneCount='" + pSouls.zoneSouls.length + "' exploCount='" + pSouls.exploSouls.length + "'  toolSouls='"+pSouls.toolSouls.length+"' >" );
		//
		var soul = XmlData.getToolByKey("soul");
		var hauntedSoul = XmlData.getToolByKey("red_soul");
		//
		printLog( "<zoneSouls />" );
		for (soul in pSouls.zoneSouls) {
			var soul = db.ZoneItem.manager.getWithKeys( { toolId:soul.toolId, zoneId:soul.zoneId, visible:soul.visible, isBroken:soul.isBroken }, true);
			//1 chance sur 4 que cette âme errante se transforme en âme perturbée dès la deuxième nuit.
			if ( Std.random(mt.MLib.max(0, 4-soul.life)) == 0 && soul.life > 0 ) {
				// on transforme en âme perturbée
				db.ZoneItem.create(soul.zone, hauntedSoul.toolId, false, true);
				
				soul.count --;
				soul.update();
				if( soul.count == 0 )
					soul.delete();
				
				printLog( "<hauntSouls zoneId='"+soul.zoneId+"' transformed='1'/>" );
			} else {
				//on spécifie qu'une nuit s'est passée avec cette âme errante...
				//la nuit prochaine elle pourra devenir une âme perturbée.
				soul.life ++;
				soul.update();
				printLog( "<hauntSouls zoneId='"+soul.zoneId+"' life='"+soul.life+"' />" );
			}
		}
		
		printLog( "<exploSouls />" );
		for (soul in pSouls.exploSouls) {
			var soul = db.ExploItem.manager.getWithKeys( { toolId:soul.toolId, cellId:soul.cellId, zoneId:soul.zoneId, isBroken:soul.isBroken }, true);
			//1 chance sur 4 que cette âme errante se transforme en âme perturbée dès la deuxième nuit.
			if ( Std.random(mt.MLib.max(0,4 - soul.life)) == 0 && soul.life > 0 ) {
				// on transforme en âme perturbée
				db.ExploItem.create(soul.explo, hauntedSoul.toolId, true);
				
				soul.count --;
				soul.update();
				if( soul.count == 0 )
					soul.delete();
				
				printLog( "<hauntSouls exploId='"+soul.zoneId+"' transformed='1'/>" );
			} else {
				//on spécifie qu'une nuit s'est passée avec cette âme errante...
				//la nuit prochaine elle pourra devenir une âme perturbée.
				soul.life ++;
				soul.update();
				printLog( "<hauntSouls exploId='"+soul.zoneId+"' life='"+soul.life+"' />" );
			}
		}
		
		printLog( "<toolSouls />" );
		for (soul in pSouls.toolSouls) {
			var soul = db.Tool.manager.get(soul.id, true);
			//1 chance sur 4 que cette âme errante se transforme en âme perturbée dès la deuxième nuit.
			if ( Std.random(mt.MLib.max(0,4 - soul.decoPoints)) == 0 && soul.decoPoints > 0 ) {
				// on transforme en âme perturbée
				db.Tool.add(hauntedSoul.toolId, soul.user, soul.inBag);
				soul.delete();
				printLog( "<hauntSouls userId='"+soul.userId+"' transformed='1'/>" );
			} else {
				//Hack
				soul.decoPoints ++;
				soul.update();
				printLog( "<hauntSouls userId='"+soul.userId+"' life='"+soul.decoPoints+"' />" );
			}
		}
		
		map.syncHauntedSouls();
		printLog( "</hauntSouls>" );
	}
	
	public static function dropSouls( map : Map, count : Int, verbose = true ) {
		if( !map.hasMod("SHAMAN_SOULS") )
			return;
			
		printLog( "<dropSouls/>" );
		var soul = XmlData.getToolByKey("soul");
		var day = map.days;
		var coef = 	if ( map.isHardcore() ) 1.75;
					else if ( map.isFar() ) 1.25;
					else 					1.00;
		
		var maxLevel = mt.MLib.clamp(Std.int(coef * (day + 4)), 5, 20);
		var minLevel = mt.MLib.clamp(Std.int(coef * day), 4, 8);
		var zones = db.Zone.manager._getZonesByLevel(map, minLevel, maxLevel).array();
		for ( i in 0...count ) {
			var zone = null;
			do {
				zone = zones[Std.random(zones.length)];
			} while(zone.type == Zone.TYPE_CITY);
			//
			db.ZoneItem.create(zone, soul.toolId, 1);
			//
			if ( verbose ) 
				printMapLog( map, "<mapSoulsSpread maxLevel='" + (maxLevel) + "' minLevel='" + minLevel + "' zone='" + zone.id + "' />" );
		}
	}
	
/*------------------------------ GARDEN --------------------------------*/

	private static function harvest(map:Map) {
		printLog("<harvest>");
		var city = map._getCity();
		
		// légume de base
		var veg = XmlData.getToolByKey("vegetable");
		var n = if( map.hasCityBuilding("fertilizer") ) mt.MLib.randRange(6, 8) else mt.MLib.randRange(4, 6);
		ZoneItem.create(city, veg.toolId, n);
		// bonne qualité
		var vegt = XmlData.getToolByKey("vegetable_tasty");
		var nt = if( map.hasCityBuilding("fertilizer") ) mt.MLib.randRange(3, 5) else mt.MLib.randRange(0, 2);
		if( nt > 0 )
			ZoneItem.create(city, vegt.toolId, nt);
		// prod de pamplemousses explosifs
		if( map.hasCityBuilding("grapefruit") ) {
			var t = XmlData.getToolByKey("fgrenade");
			var n = if (map.hasCityBuilding("fertilizer")) mt.MLib.randRange(5, 8) else mt.MLib.randRange(3, 5);
			ZoneItem.create(city, t.toolId, n);
			CityLog.add(CL_GiveInventory, Text.fmt.CL_BuildingToInventory( { building:XmlData.getBuildingByKey("grapefruit").print(), name:t.print(), n:n } ), map);
			printLog("<generateGrapefruit/>");
		}
		CityLog.add(CL_GiveInventory, Text.fmt.CL_Garden( { n:n, nt:nt, veg:veg.print(), vegt:vegt.print() } ), map);
		printLog("<tasty v='"+n+"'/>");
		printLog("<normal v='"+nt+"'/>");
		printLog("</harvest>");
	}

/*------------------------------ BUILDING PLAN DROP --------------------------------*/

	private static function buildingPlanDrop(map:Map) {
		printLog("<buildingPlanDrop>");
		var b = XmlData.getBuildingByKey("architectoire");
		var upgrade = CityUpgrade.manager._getUpgrade(b, map, false);
		var upgradeLevel = if (upgrade != null) upgrade.level else 0;
		
		if ( upgradeLevel > 0 )
		{
			if ( map.hasFlag("building_upgrade_architectoire_" + upgradeLevel) )
			{
				upgradeLevel = 0;
			}
			else
			{
				db.MapVar.setValue(map, "building_upgrade_architectoire_" + upgradeLevel, 1);
			}
		}
		
		switch( upgradeLevel )
		{
			case 0:
				var plan = XmlData.getToolByKey("bplan_c");
				ZoneItem.create(map._getCity(), plan.toolId, 1);
				CityLog.add(CL_GiveInventory, Text.fmt.CL_Architectoire( { building:b.print(), name:plan.print() } ), map);
			case 1:
				for ( i in 0...5 )
				{
					var plan = XmlData.getToolByKey("bplan_c");
					ZoneItem.create(map._getCity(), plan.toolId, 1);
					CityLog.add(CL_GiveInventory, Text.fmt.CL_Architectoire( { building:b.print(), name:plan.print() } ), map);
				}
			case 2:
				for ( i in 0...2 )
				{
					var plan = XmlData.getToolByKey("bplan_c");
					ZoneItem.create(map._getCity(), plan.toolId, 1);
					CityLog.add(CL_GiveInventory, Text.fmt.CL_Architectoire( { building:b.print(), name:plan.print() } ), map);
				}
				for ( i in 0...2 )
				{
					var plan = XmlData.getToolByKey("bplan_u");
					ZoneItem.create(map._getCity(), plan.toolId, 1);
					CityLog.add(CL_GiveInventory, Text.fmt.CL_Architectoire( { building:b.print(), name:plan.print() } ), map);
				}
				if ( Std.random(2) == 0 )
				{
					for ( i in 0...1 )
					{
						var plan = XmlData.getToolByKey("bplan_r");
						ZoneItem.create(map._getCity(), plan.toolId, 1);
						CityLog.add(CL_GiveInventory, Text.fmt.CL_Architectoire( { building:b.print(), name:plan.print() } ), map);
					}
				}
			default:
				for ( i in 0...2 )
				{
					var plan = XmlData.getToolByKey("bplan_u");
					ZoneItem.create(map._getCity(), plan.toolId, 1);
					CityLog.add(CL_GiveInventory, Text.fmt.CL_Architectoire( { building:b.print(), name:plan.print() } ), map);
				}
				for ( i in 0...2 )
				{
					var plan = XmlData.getToolByKey("bplan_r");
					ZoneItem.create(map._getCity(), plan.toolId, 1);
					CityLog.add(CL_GiveInventory, Text.fmt.CL_Architectoire( { building:b.print(), name:plan.print() } ), map);
				}
				if ( Std.random(2) == 0 )
				{
					for ( i in 0...1 )
					{
						var plan = XmlData.getToolByKey("bplan_e");
						ZoneItem.create(map._getCity(), plan.toolId, 1);
						CityLog.add(CL_GiveInventory, Text.fmt.CL_Architectoire( { building:b.print(), name:plan.print() } ), map);
					}
				}
		}
		
		printLog("</buildingPlanDrop>");
	}
	
/*------------------------------ FOOD DROP --------------------------------*/

	static function appleTree(map:Map) {
		printLog("<appleTree/>");
		var city = map._getCity();
		var b = XmlData.getBuildingByKey("appletree");
		var food = XmlData.getToolByKey("apple");
		
		var n = mt.MLib.randRange(3, 5 );
		//var n = mt.deepnight.Range.makeInclusive( 3, 5 ).draw();
		ZoneItem.create(city, food.toolId, n);
		CityLog.add(CL_GiveInventory, Text.fmt.CL_BuildingToInventory( {building:b.print(), name:food.print(), n:n } ), map);
	}
	
	static function eggs(map:Map) {
		printLog("<eggs/>");
		var city = map._getCity();
		var b = XmlData.getBuildingByKey("henhouse");
		var food = XmlData.getToolByKey("egg");
		var n = 3;
		ZoneItem.create(city, food.toolId, n);
		CityLog.add(CL_GiveInventory, Text.fmt.CL_BuildingToInventory( {building:b.print(), name:food.print(), n:n } ), map);
	}
	
/*------------------------------ ZOMBIES SPREADING --------------------------------*/
	
	public static function zombieFountainsInAction( map : Map, baseZones : List<Zone>, ?fl_regenEmpty = false, ?rnd:Int->Int) {
		if( rnd == null ) rnd = Std.random;
		//
		var c = map._getCity();
		var center = {x:c.x,y:c.y};
		var zones = null;
		zones = Lambda.array(Lambda.filter( baseZones, function( z: Zone ) {
			if( z.camped )
				return false;
			if( z.type == 1 )
				return false;
			if( z.zombies == 0 )
				return false;
			return true;
		} ));
		// cette fonction permet de re-remplir une map qui aurait été vidée de ses zombies...
		if( fl_regenEmpty && map.days > 2 ) {
			var count = db.Zone.manager.countZombies(map);
			var min = 	if ( map.isBig() ) Const.get.MinZombiesOnMap * map.days * 0.5;
						else Const.get.MinZombiesOnSmallMap * map.days * 0.5;
			
			printMapLog(map, "<refill count="+count+" min="+min+">");
			if( count < min ) {
				var iter = Const.get.ZombieStartIterations + Math.floor(map.days/5);
				printMapLog(map, "<r iter="+iter+"/>");
				MapGenerator.createZombieFountains( map, Lambda.array(baseZones), true, rnd );
				for( i in 0...iter ) {
					printMapLog(map, "<ri i="+i+"/>");
					zombieFountainsInAction( map, baseZones, rnd );
				}
			}
			printMapLog(map, "</refill>");
		}
		// 
		while( zones.length > 0 ) {
			var randomZone = zones.pop();
			if( randomZone == null || randomZone.type == 1 )
				continue;
			var x = randomZone.x;
			var y = randomZone.y;
			if( randomZone.zombies >= Const.get.ZombieGrowThreshold ) {
				var adjacentZones = Lambda.array( Lambda.filter( baseZones, function( z: Zone ) {
					if( z.type == 1 )
						return false;
					if( z.zombies >= Const.get.ZombieGrowThreshold )
						return false;
					if( x==z.x && y==z.y )
						return false;
					if( getZoneLevel(  { x:x, y:y }, {x:z.x,y:z.y} ) == 1 )
						return true;
					return false;
				} ) );
				
				if( adjacentZones.length <= 0 ) {
					randomZone.zombies += 1;
					randomZone.update();
					continue;
				}
				
				var zombieS = Const.get.ZombieSpreaded;
				while( zombieS > 0 ) {
					var spreadZone = adjacentZones[ rnd(adjacentZones.length) ];
					var spreadedZombies = rnd( zombieS ) +1;
					spreadZone.zombies += spreadedZombies;
					spreadZone.update();
					zombieS -= spreadedZombies;
				}
				
				if( rnd(100) < Const.get.OverThresholdGrowChance ) {
					randomZone.zombies += 1;
					randomZone.update();
				}
				continue;
			}
			
			if( rnd(2) == 0 || randomZone.type > 1 ) {
				randomZone.zombies += 1;
				randomZone.update();
			}
		}
		applyKillsOnSpread(map);
		
		if( map.days > 2 && map.hasMod("EXPLORATION") ) {
			printMapLog(map, "<refillExplos>");
			var zones = Lambda.filter( baseZones, function(z) {
				return z.explo != null;
				} );
			
			for( z in zones ) {
				printMapLog(map, "<refillExplo zone=" + z.id + ">");
				
				var explo = db.Explo.manager.get(z.id);
				var maxCells = explo.width * explo.height;
				var count = Const.get.ExplorationDailyZombieGrow;
				var cells = [];
				for( i in 0...maxCells ) {
					var cell = try explo.getAtId( i ) catch(e:Dynamic) null;
					if( cell != null && cell.walkable && (cell.zombies + cell.kills) < 4 ) cells.push({id:i, c:cell});
				}
				//Give a pattern to zombie spread ? deeper, random, where zombies where killed, at doors etc...
				//For now, total random has been chosen.
				var max = 100;//to prevent too long loops
				while( count > 0 && cells.length > 0 ) {
					if( -- max <= 0 ) break;
					var info = cells[rnd(cells.length)];
					var cell = info.c;
					if( cell != null ) {
						var from = cell.zombies;
						var spread = rnd(count - 1) + 1;
						cell.zombies += spread;
						count -= spread;
						cells.remove(info);
						printMapLog(map, "<r cell=" + info.id + " from="+from+" to="+cell.zombies+" />");
					}
				}
				explo.update();
				
				printMapLog(map, "</refillExplo>");
			}
			printMapLog(map, "</refillExplos>");
		}
	}

	private static function applyKillsOnSpread(map:Map) {
		var ratio = Const.get.KillsDeducedFromZombies/100;
		Db.execute("UPDATE Zone SET zombies=zombies-round(kills*"+ratio+") WHERE mapId="+map.id+" AND kills>0");
	}
	
/*------------------------------ MAP REGENERATION --------------------------------*/
	
	public static function mapRegen(map:Map,newsInfo) {
		var dir = Std.random(8);
		var minLevel = 	if( map.isBig() )
							Std.random(3)+3;
						else
							Std.random(2);
		var zones = Zone.manager._getZonesByDirection( map, dir, minLevel, true );
		var chance = map.getRegenChance();
		printMapLog( map, "<mapRegen dir='"+dir+"' minLevel='"+minLevel+"' zones='"+zones.length+"'/>" );
		var count = 0;
		for( z in zones )
			if( z.regen(chance) )
				count++;
		newsInfo.regenDir = if( count == 0 ) -1 else dir;
	}
	
	public static function getZoneLevel( v1 : {x:Int,y:Int}, v2 : {x:Int,y:Int} ) {
		var ax = Math.abs( v1.x - v2.x );
		var ay = Math.abs( v1.y - v2.y );
		return Math.round( Math.sqrt( ax * ax + ay * ay ) );
	}
	
	public static function getDirection( from:{x:Int,y:Int}, to:{x:Int,y:Int} ) {
		var sector = 0;
		var angRad = Math.atan2( from.x-to.x, from.y-to.y );
		var ang = angRad*180/Math.PI;
		if (ang<0) ang = 360-Math.abs(ang);
		ang = Math.round(ang);
		if (ang>27 && ang<63 )			sector = 2; // north-west
		if (ang>=63 && ang<=117)		sector = 3; // west
		if (ang>117 && ang<153)			sector = 4; // south-west
		if (ang>=153 && ang<=207)		sector = 5; // south
		if (ang>207 && ang<243 )		sector = 6; // south-east
		if (ang>=243 && ang<=297)		sector = 7; // east
		if (ang>297 && ang<333)			sector = 0; // north-east
		if (ang>=333 && ang<=359 || ang<=27)	sector = 1; // north
		return sector;
	}

/*----------------------------------------REQUETES SQL--------------------------------*/

	public static function specialDays(date:Date,map:Map) {
		for (tool in getSpecialDaysTools(date)) {
			printLog("<specialevent t="+tool.name+"/>");
			Db.execute("INSERT INTO Tool (userId, toolId, inBag) SELECT id,"+tool.toolId+",0 FROM User WHERE mapId="+map.id);
		}
		
	}
	
	public static function getSpecialDaysTools(date:Date) {
		var list = new List();
		var month = date.getMonth()+1;
		var day = date.getDate();
		
		if( App.isEvent("christmas") )
			list.add( XmlData.getToolByKey("chest_christmas_3") );
		
		if( App.isEvent("new_year") ) // jour de l'an
			list.add( XmlData.getToolByKey("book_gen_1") );
		
		return list;
	}
	
	static function townDevastation( map:Map, ndata:DailyNewsData ) {
		if( map.devastated ) {
			ndata.deadTown = true;
			return;
		} else {
			printMapLog(map, "<townDevastation>");
			CityLog.add( CL_AttackEvent, Text.get.CL_Attack_Devastation, map  );
			// gazette spéciale le jour de la dévastation
			ndata.wasDevastated = true;
			printMapLog(map, "<devastationNews/>");
			// maisons
			Db.execute( "UPDATE User SET homeLevel=0 WHERE homeLevel>0 AND mapId="+map.id );
			// divers
			map.destroyDoor(false);
			map.chaos = true;
			map.water = Math.floor(map.water*0.3);
			//TODO Call setChaos since help says so, and espacially for people who where banned !
			setChaos(map, true);
			printMapLog(map, "</townDevastation>");
		}
	}
	
	static function countAllMapsPlayableForCron() {
		return Db.execute( "SELECT count(*) FROM Map WHERE status = " + Type.enumIndex( GameIsClosed ) + " AND inPool = 0 AND status != "+ Type.enumIndex( EndGame)).getIntResult(0);
	}
	
	static function destroyTemporaryBuildings(map:Map) {
		printLog( "<destroyTemporaryBuildings/>");
		// destruction
		var toDestroy = CityBuilding.manager.getTemporaryBuildings(map);
		for (b in toDestroy) {
			CityLog.add( CL_Attack, Text.fmt.CL_Attack_BuildingDestroyed( { name:b.getInfos().name } ), map);
			b.destroy(map);
		}
		map.builtBuildingsBlob = null; // On force la regénération du cache dès la prochaine reconnexion
	}

	static function teamLogCleanup() {
		if( !ALREADY_ATTACKED_TODAY ) {
			printLog("<teamLogCleanup/>");
			Db.execute("DELETE FROM TeamLog WHERE date < NOW() - INTERVAL 15 DAY");
			return;
		}
		printLog("<noTeamLogCleanup/>");
	}

	static function oneMoreDayforOpenedGames() {
		printLog("<oneMoreDayforOpenedGames/>");
		Db.execute("UPDATE Map SET days = days + 1 "
					+ " WHERE days = 1 "
					+ " AND inPool = 0 "
					+ " AND status=" + Type.enumIndex( GameIsOpened ) );
	}

	static function closeGames() {
		printLog("<closeGames/>");
		Db.execute("UPDATE Map SET availableForJoin=0, status=" + Type.enumIndex( GameIsClosed)
					+ " WHERE countP >=" + Const.get.MaxPlayers
					+ " AND status=" + Type.enumIndex( GameIsOpened ) );
		Db.execute("UPDATE Map SET availableForJoin=0, status=" + Type.enumIndex( GameIsClosed)
					+ " WHERE countP >=" + Const.get.MaxPlayers
					+ " AND days >="+Const.get.BeginPeriodDays
					+ " AND status=" + Type.enumIndex( GameIsOpened ) );
		// on ferme les cartes déjà en mode chaos alors que le nombre de joueurs n'est pas suffisant
		Db.execute("UPDATE Map SET availableForJoin=0, status=" + Type.enumIndex( GameIsClosed)
					+ " WHERE chaos = 1 AND status=" + Type.enumIndex( GameIsOpened ) );
	}

	static function dropComplaints(ids:String) {
		printLog("<dropComplaints/>");
		Db.execute( "DELETE FROM Complaint WHERE suspect IN ( "+ids+" )" );
	}

	static function deleteMessages(ids:String) {
		printLog("<deleteMessages/>");
		Db.execute("DELETE FROM MessageThread WHERE uto IN( "+ids+" )" );
	}

	static function deleteDeadJobs(ids:String) {
		printLog("<deleteDeadJobs/>");
		// pour l'affichage en ville quand le joueur n'a pas encore validé sa mort
		Db.execute("UPDATE User set jobId=NULL WHERE id IN( "+ids+")");
	}

	static function updateJobRewards(map:Map, lostHeroes:List<Int>) {
		printLog("<updateJobRewards lostHeroes="+lostHeroes.join(",")+"/>");
		// chaque jour on donne un point de plus
		Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value )
						SELECT "+Db.quote(Std.string(GR.get.jcolle.ikey) )+", id, 0, 1 FROM User as u WHERE hero=1 AND jobId=2 AND dead=0 AND mapId="+map.id+" ON DUPLICATE KEY UPDATE value=value+1" );
		Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value )
						SELECT "+Db.quote(Std.string(GR.get.jrangr.ikey) )+", id, 0, 1 FROM User as u WHERE hero=1 AND jobId=3 AND dead=0 AND mapId="+map.id+" ON DUPLICATE KEY UPDATE value=value+1" );
		Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value)
						SELECT "+Db.quote(Std.string(GR.get.jguard.ikey ))+", id, 0, 1 FROM User WHERE hero=1 AND jobId=4 AND dead=0 AND mapId="+map.id+" ON DUPLICATE KEY UPDATE value=value+1" );
		Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value)
						SELECT "+Db.quote(Std.string(GR.get.jermit.ikey ))+", id, 0, 1 FROM User WHERE hero=1 AND jobId=5 AND dead=0 AND mapId="+map.id+" ON DUPLICATE KEY UPDATE value=value+1" );
		Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value)
						SELECT "+Db.quote(Std.string(GR.get.jtamer.ikey ))+", id, 0, 1 FROM User WHERE hero = 1 AND jobId = 6 AND dead = 0 AND mapId = "+map.id+" ON DUPLICATE KEY UPDATE value = value + 1" );
		Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value)
						SELECT "+Db.quote(Std.string(GR.get.jtech.ikey ))+", id, 0, 1 FROM User WHERE hero = 1 AND jobId = 7 AND dead = 0 AND mapId = "+map.id+" ON DUPLICATE KEY UPDATE value = value + 1" );
		Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value)
						SELECT "+Db.quote(Std.string(GR.get.jsham.ikey ))+", id, 0, 1 FROM User WHERE hero=1 AND jobId=8 AND dead=0 AND mapId="+map.id+" ON DUPLICATE KEY UPDATE value=value+1" );
		// FIX 2.4.13 : on crédite aussi les joueurs venant de perdre leur dernier jour héros
		if( lostHeroes != null && lostHeroes.length > 0 ) {
			var res = Db.results("SELECT userId, value FROM UserVar WHERE userId IN ("+lostHeroes.join(",")+") AND name='lastjobid'");
			var lastJobIds = new IntHash();
			for( r in res )
				lastJobIds.set(r.userId, r.value);
			
			giveGhostRewardFiltered(map, lostHeroes, lastJobIds, 2, GR.get.jcolle);
			giveGhostRewardFiltered(map, lostHeroes, lastJobIds, 3, GR.get.jrangr);
			giveGhostRewardFiltered(map, lostHeroes, lastJobIds, 4, GR.get.jguard);
			giveGhostRewardFiltered(map, lostHeroes, lastJobIds, 5, GR.get.jermit);
			giveGhostRewardFiltered(map, lostHeroes, lastJobIds, 6, GR.get.jtamer);
			giveGhostRewardFiltered(map, lostHeroes, lastJobIds, 7, GR.get.jtech);
			giveGhostRewardFiltered(map, lostHeroes, lastJobIds, 8, GR.get.jsham);
		}
		//à l'époque : ROUND( POW( spentHeroDays, 1.3 ) )
	}
	
	#if tests public #end
	static function rewardNoobsGuides( map:Map ) {
		if( !map.hasMod("RNE_REWARD_RESTRICTED") ) return;
		if( map.isBig() ) return;
		//
		var mapUsers = map.getUsers(false);
		var guides = Lambda.filter( mapUsers, function(u) return u.survivalPoints >= db.Version.getVar("minXp") ).map( function(u) return u.id );
		if( guides.length == 0 || (guides.length/mapUsers.length) > (Const.get.MinNoobRatioForReward / 100) ) {
			printLog("<rewardGuides guides="+guides.join(",")+" value='0' canceled='1' ratio='"+(guides.length/mapUsers.length)+"'/>");
			return;
		}
		
		var value = Std.int((map.days + 1) * .5 * map.days);
		printLog("<rewardGuides guides="+guides.join(",")+" value="+value+"/>");
		// chaque jour on donne un point de plus
		Db.execute(	"INSERT INTO GhostReward ( rewardKey,userId,day,value ) "+
					"SELECT " + Db.quote(Std.string(GR.get.guide.ikey) ) + ",id, 0, " + value + " FROM User as u WHERE mapId=" + map.id + " AND dead=0 AND id IN(" + guides.join(',') + ") "+
					"ON DUPLICATE KEY UPDATE value=value+VALUES(value)" );
	}
	
	static function giveGhostRewardFiltered(map:Map, lostHeroes:List<Int>, lastJobIds:IntHash<Int>, lastJobId:Int, gr:GhostRewardData) {
		var list = new List();
		for( uid in lostHeroes )
			if( lastJobIds.exists(uid) && lastJobIds.get(uid) == lastJobId )
				list.add(uid);
		printLog("<giveGhostRewardFiltered gr="+gr.key+" u=["+list.join(",")+"]/>");
		if( list.length == 0 )
			return;
		Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value )"
						+" SELECT "+Db.quote(Std.string(gr.ikey))+",id, 0, 1 FROM User as u"
						+" WHERE id IN ("+list.join(",")+") AND dead=0 AND mapId="+map.id
						+" ON DUPLICATE KEY UPDATE value=value+1" );
	}
	
	static function giveLastCampsReward(map:Map, survivors:List<Int>) {
		if( !map.hasMod("CAMP") )
			return;
		if( !map.devastated || map.days <= Const.get.LastCampsRewardDay || survivors.length == 0 ) {
			printLog("<noLastCampsReward/>");
		} else {
			printLog("<giveLastCampsReward survivors="+survivors.join(",")+"/>");
			Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value )
							SELECT "+Db.quote(Std.string(GR.get.cmplst.ikey) )+",id, 0, 1 FROM User as u
							WHERE id IN ("+survivors.join(",")+") AND dead=0 AND mapId="+map.id+"
							ON DUPLICATE KEY UPDATE value=value+1" );
		}
	}
	
	// Récupère uniquement les cadavres du jour et vire leurs objets
	static function dropDeadTools(map:Map) {
		printLog( "<dropDeadTools>");
		// 1 - Suppression　objets SoulLocked
		Db.execute("DELETE FROM Tool WHERE soulLocked=1 AND userId IN( SELECT id FROM User WHERE dead=1 AND mapId="+map.id+")");
		printLog( "<i>SoulLocked Tools erased</i>");
		// Calcul des points de deco
		Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value )
						SELECT "+Db.quote(Std.string(GR.get.deco.ikey) )+",u.id,0,t.decoPoints FROM Tool as t, User as u
							WHERE t.userId = u.id
							AND t.isBroken=0
							AND t.inBag = 0
							AND u.dead=1 AND u.mapId="+map.id+" ON DUPLICATE KEY UPDATE value=value+t.decoPoints" );
							// ATTENTION : ce SELECT est dupliqué dans HordeAttack
		var allCadavers = new List();
		allCadavers = Db.results("	SELECT c.id AS cid, u.id AS uid, u.isOutside AS isOutside, u.isCityBanned AS isCityBanned FROM Cadaver as c, User as u
									WHERE c.createDate="+Db.quote(CURRENT_DAY.toString())+"
									AND c.userId = u.id
									AND u.dead = 1 AND u.mapId = "+map.id);
		//
		if( allCadavers.length <= 0 ) {
			printLog( "<i>NOTHING TO DROP</i>");
			return;
		}
		// on dépose uniquement les objets de la maison pour les morts en extérieur
		var outsideCadavers = Lambda.filter( allCadavers, function( info : {cid:Int,uid:Int,isOutside:Bool,isCityBanned:Bool} ) {return info.isOutside;} );
		if( outsideCadavers.length > 0 ) {
			printLog( "<i>DROP HOME TOOLS FOR OUTSIDE</i>");
			var hashC = new IntHash();
			for( i in outsideCadavers )
				hashC.set( i.uid, i.cid );
			for( key in hashC.keys() ) {
				//printLog( "[DROP] Objects FROM " + key + "");
				Db.execute("INSERT INTO CadaverRemains ( cadaverId, toolId, isbroken )
							SELECT "+hashC.get(key)+" ,toolId,isbroken FROM Tool WHERE inBag = 0 AND userId = "+ key);
			}
		}
		var bannedCadavers = Lambda.filter( allCadavers, function( info : {cid:Int,uid:Int,isOutside:Bool,isCityBanned:Bool} ) {return info.isCityBanned;} );
		if( bannedCadavers.length > 0 ) {
			printLog( "<i>DROP HOME TOOLS FOR BANNED CADAVERS</i>");
			var hashC = new IntHash();
			if ( map.hasMod("BANNED") ) {
				for( i in bannedCadavers ) {
					var note = XmlData.getToolByKey("banned_note");
					Db.execute("INSERT INTO CadaverRemains ( cadaverId, toolId, isbroken ) VALUES ("+i.cid+", "+note.toolId+", 0)");
				}
			}
		}
		// on dépose tous le sobjets ( sac+coffre) pour les joueurs dévorés
		var insideCadavers = Lambda.filter( allCadavers, function( info ) {return !info.isOutside;} );
		if( insideCadavers.length > 0 ) {
			printLog( "<i>DROP HOME TOOLS FOR INSIDE</i>");
			var hashC = new IntHash();
			for( i in insideCadavers ) {
				hashC.set( i.uid, i.cid );
			}
			for( key in hashC.keys() ) {
				//printLog( "[DROP] Objects FROM " + key );
				Db.execute("INSERT INTO CadaverRemains ( cadaverId, toolId, isbroken )
							SELECT "+hashC.get(key)+" ,toolId,isbroken FROM Tool WHERE userId = "+ key);
			}
		}
		// 4 - Récupération des cadavres de l'extérieur
		if( outsideCadavers.length > 0 ) {
			// 6 - on dépose tous les objets dans le sac du mort dans le désert
			var userIds = Lambda.map( outsideCadavers, function (info ) { return info.uid; } );
			var sql = "INSERT INTO ZoneItem (zoneId, toolId, isbroken, visible, count)
						SELECT u.zoneId,t.toolId,t.isbroken,1,1
							FROM Tool as t, User as u
							WHERE t.userId = u.id AND t.soulLocked = 0 AND t.inBag=1 AND u.dead=1 AND u.isOutside=1 AND u.mapId = " +map.id +" ON DUPLICATE KEY UPDATE count = count + 1 ";
			Db.execute(sql);
			printLog( "<i>Deads' tools dropped outside</i>");
			// 7 - on dépose des bouts de morts à l"extérieur
			var bone = XmlData.getToolByKey("bone_meat");
			for(c in outsideCadavers) {
				var u = db.User.manager.get(c.uid,false);
				Db.execute(
					"INSERT INTO ZoneItem (zoneId, toolId, isbroken, visible, count) VALUES "+
					"("+u.zoneId+", "+bone.toolId+", 0, 1, 1) ON DUPLICATE KEY UPDATE count = count + 1 "
				);
//						 SELECT u.zoneId,"+bone.toolId+",false,1,1
//							FROM User as u WHERE u.dead=1 AND u.isOutside=1 AND u.mapId = " +map.id +" ON DUPLICATE KEY UPDATE count = count + 1 ";
//				);
			}
//			var sql = "INSERT INTO ZoneItem (zoneId, toolId, isbroken, visible, count)
//						 SELECT u.zoneId,"+bone.toolId+",false,1,1
//							FROM User as u WHERE u.dead=1 AND u.isOutside=1 AND u.mapId = " +map.id +" ON DUPLICATE KEY UPDATE count = count + 1 ";
//			Db.execute(sql);
		}
		// 8 - On supprime tous les anciens objets des joueurs
		printLog( "<i>DELETING CADAVER TOOLS</i>");
		Db.execute("DELETE FROM Tool WHERE userId IN( SELECT id FROM User WHERE dead=1 AND mapId="+map.id +")");
		printLog( "</dropDeadTools>");
	}
	
	static function resetEventsForDead() {
		printLog( "<resetEventsForDead/>");
		Db.execute("UPDATE User SET eventState=null WHERE eventState=0");
	}

	static function kill( map:Map, reason : DeathType, reasonText : String, whereClause, mapDay:Int, survivalDay:Int, ?gr:GhostRewardData ) {
		// Insère les cadavres en base
		printLog("<kill reason='"+reason+"'>");
		var res = Db.execute(
			"INSERT INTO Cadaver (userId,mapId, zoneId, homeLevel, deathType, mapName,oldMapId, mapDay, survivalDays, createDate, diedInTown, isGhoul, hardcore, season, banned, custom )"
				+ " SELECT u.id, u.mapId, u.zoneId, u.homeLevel, "+Type.enumIndex( reason )+", m.name,u.mapId, "+mapDay+" , "+survivalDay+" - (u.mapRegisterDay-1), "
				+ Db.quote( CURRENT_DAY.toString() ) + ", IF(u.zoneId = m.cityId && !u.isOutside,1,0), u.isGhoul, "
				+ (map.isHardcore()?1:0)+", "+map.season+", "+(map.isBannedFromRanking()?1:0)+", "+(map.isCustom()?1:0)
				+ " FROM User as u, Map as m "
				+ " WHERE " + whereClause + " AND u.dead = 0 AND u.mapId IS NOT NULL AND m.id = u.mapId"
		);
		var count = if(res == null) 0 else res.length;
		// Génère les rewards en conséquence
		if( gr != null && count > 0 ) {
			printLog("<k giveRewards='"+gr.key+"' whereClause='"+whereClause+"' />");
			Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value )
							(SELECT "+Db.quote(Std.string(gr.ikey))+",id,0,1 FROM User AS u
							 WHERE " + whereClause + " AND u.dead = 0 AND u.mapId IS NOT NULL)
						ON DUPLICATE KEY UPDATE value = value + 1");
		} else {
			printLog("<k/>");
		}
		
		// S14 pandemonium special
		if ( map.isHardcore() ) {
			var pandePts = Std.int(Math.pow(Math.max(0, survivalDay - 3), 1.5));
			printLog("<k giveRewards='"+GR.get.pande.key+"' value='"+pandePts+"' whereClause='"+whereClause+"' />");
			if( pandePts > 0 ) {
				Db.execute("INSERT INTO GhostReward(rewardKey,userId,day,value)
								(SELECT "+Db.quote(Std.string(GR.get.pande.ikey))+", id, 0, "+pandePts+" FROM User AS u
								 WHERE " + whereClause + " AND u.dead = 0 AND u.mapId IS NOT NULL)
							ON DUPLICATE KEY UPDATE value = value + "+pandePts);
			}
		}
		
		// tue les joueurs concernés
		Db.execute(	"UPDATE User as u SET dead=1, majorEvent=null, leaderId=null, isWaitingLeader=0, wasEscorted=0"
				   +" WHERE " + whereClause + " AND u.dead = 0 AND u.mapId IS NOT NULL" );
		
		printLog("</kill>");
		//
		if( count > 0 )
			dropSouls(map, count);
		
		return count;
	}

	public static function deleteMaps() {
		printLog( "<deleteMaps>");
		if( Db.execute( "SELECT COUNT(*) FROM Map WHERE inPool=0 AND countP <=0 AND status=1").getIntResult(0) > 0)
			Db.execute("DELETE FROM Map WHERE inPool=0 AND status = 1 AND countP <=0 AND days>=" + Const.get.BeginPeriodDays );
		// On  les cartes pour exploration ultérieure :)
		if( !App.BETA ) {
			var mapIds = Lambda.map(
				Db.results( "SELECT id FROM Map WHERE status="+Type.enumIndex( EndGame ) ),
				function(info:{id:Int} ) { return info.id; }
			);
			if ( mapIds.length>0 ) {
				printLog("<del mapIds="+mapIds.length+"/>");
				printLog("<log/>");
				Db.execute("DELETE FROM CityLog WHERE mapId IN ("+mapIds.join(",")+")");
				printLog("<zone/>");
				Db.execute("DELETE FROM Zone WHERE mapId IN ("+mapIds.join(",")+")");
				printLog("<map/>");
				Db.execute("DELETE FROM Map WHERE id IN ("+mapIds.join(",")+")");
			} else
				printLog("<none/>");
		}
		printLog( "</deleteMaps>");
	}
	
	static function deleteXmlCache() {
		printLog( "<deleteXmlCache/>");
		Db.execute("DELETE FROM XmlCache" );
	}
	
	static function noGatherForDeadPeople() {
		printLog( "<noGatherForDeadPeople/>");
		Db.execute("UPDATE User SET EndGather= null where dead=1 and mapId is not null");
	}
	
	static function closeDoors(map:Map) {
		var hasBigDoor = map.hasCityBuilding("bigDoor");
		// Si la partie était en quarantaine on s'assure que les portes sont fermées en compensation
		var inQuarantine = map.status == Type.enumIndex(Quarantine);
		// On ferme les portes automatiquement, on va éviter que le poisson d'avril devienne une vraie mauvaise blague
		var isAprilFoolEvent = App.isEvent("aprilfool_over");
		// Un mode de sécurité qui force les portes à se fermer pour éviter les drâmes. Cela n'est pas souhaitable en cas de ville dévastée qui n'a plus de portes
		var autoClose = !map.devastated && map.hasMod("SAFE_MODE");
		
		if( hasBigDoor || inQuarantine || isAprilFoolEvent || autoClose ) {
			map.closeDoor(false);
			printLog( "<closeDoor hasBigDoor="+hasBigDoor+" inQuarantine="+inQuarantine+" isAprilFoolEvent="+isAprilFoolEvent+" autoClose="+autoClose+" />");
		}
	}
	
	static function processFireworks(map:Map) {
		// feux d'artifice toxiques
		if( map == null || !map.hasMod("FIREWORK")) return;
		var fireworks = db.CityBuilding.manager.getByKey(map, "fireworks", true);
		if( fireworks == null || !fireworks.isDone ) return;
		var dmg = 20;
		fireworks.life -= dmg;
		fireworks.update();
		printMapLog(map, "<fireworks dmg='"+dmg+"' life='"+fireworks.life+"'/>");
		if( fireworks.life > 0 )
			CityLog.add( CL_Attack, Text.fmt.CL_BuildingDamaged( { name:fireworks.getInfos().print(), n:dmg } ), map );
		
		if( fireworks.life <= 0 ) {
			// explosion : ça va faire peur
			printMapLog(map, "<fireworksDestroyed/>");
			CityLog.add( CL_Attack, Text.fmt.CL_FireworksDestroyed({b:fireworks.getInfos().print()}), map );
			fireworks.destroy(map);
			//Bonus : réduit l'attaque du lendemain
			db.MapVar.setValue(map, "attackPercent", 85);
			//Bonus : réduit les zombies sur les zones avoisinantes
			// 10% pour la zone la plus lointaine, 90% pour la plus proche
			var zones = db.Zone.manager._getZonesByLevel(map, 1, 10, true);
			for(zone in zones ) {
				var k = Math.ceil(0.1 * (10 - zone.level) * zone.zombies);
				if( k > 0 ) {
					zone.kills += k;
					zone.zombies -= k;
				}
				zone.update();
			}
			//Malus : Infecte les joueurs
			var city = map._getCity();
			Db.execute("UPDATE User SET isInfected=IF(FLOOR(RAND()*4)>0, 0, 1) WHERE isInfected=0 AND isGhoul=0 AND zoneId=" + city.id);
			
			//explosion, donc pas mal de points de défense !
			map.tempDef = 700;
			map.update();
		}
	}
	
	static function oneMoreDayForHeroes(map:Map) {
		printLog( "<oneMoreDayForHeroes/>");
		Db.execute( "UPDATE User SET spentHeroDays=spentHeroDays+1"+
					" WHERE dead=0 AND hero=1 AND mapId="+map.id+
					" AND jobId IS NOT null AND jobId>"+XmlData.getJobByKey("basic").id
		);
	}
	
	static function oneLessDayForHeroes(map:Map) {
		function fmap( r : { id:Int } ) { return r.id; }
		//
		printMapLog(map, "<oneLessDayForHeroes>");
		Db.execute("UPDATE User SET heroDays=heroDays-1 WHERE dead=0 AND hero=1 AND mapId="+map.id+" AND heroDays>0");
		
		// On vire les joueurs
		printLog("<i>FORMER HEROES LOOSE THEIR STATUS</i>");
		var lostHeroes = Db.results("SELECT id FROM User WHERE hero=1 AND mapId="+map.id+" AND heroDays<=0").map(fmap).list();
		if( lostHeroes.length > 0 )
			Db.execute("UPDATE User SET hero=0, heroDays=0, jobId=null WHERE id IN ("+lostHeroes.join(",")+")" );
		printMapLog(map, "<lostHeroes v='"+lostHeroes.length+"'/>");
		
		// suppression des objets de métier
		printLog("<i>FORMER HEROES LOOSE THEIR TOOLS</i>");
		var res = Db.results("SELECT id FROM User WHERE mapId="+map.id+" AND hero=0 AND jobId IS NULL");
		var uids = Lambda.map(res, fmap);
		if( uids.length > 0 ) {
			var tids = XmlData.getJobToolIds();
			Db.execute("DELETE FROM Tool WHERE toolId IN (" + tids.join(",") + ") AND userId IN (" + uids.join(",") + ")" );
			//clean user vars
			Db.execute("DELETE FROM UserVar WHERE userId IN (" + uids.join(",") + " ) AND name=" + Db.quote("buildingActions"));
			printMapLog(map, "<deletedFormerHeroesTools uids='"+uids.join(":")+"'/>");
		}
		
		
		printLog( "</oneLessDayForHeroes>");
		return lostHeroes;
	}
	
	static function cleanup() {
		if( !ALREADY_ATTACKED_TODAY ) {
			printLog( "<cleanup/>");
			Db.execute("UPDATE User SET heroDays = 0 WHERE heroDays < 0" );
			Db.execute("UPDATE Zone set zombies=0 WHERE zombies<0");
		} else
			printLog( "<cleanupAlreadyDone/>");
	}
	
	public static function buildSoulRanking() {
		var season = App.getDbVar("season");
		printLog("<buildSoulRanking season=" + season + "/>");
		
		Db.execute("DROP TABLE IF EXISTS UserRankCache_" + season);
		Db.execute("CREATE TABLE UserRankCache_"+season+" (	`id` int(11) NOT NULL AUTO_INCREMENT"+
															",	`userId` int(11) NOT NULL"+
															",	`points` int(11) NOT NULL"+
															",	 PRIMARY KEY (`id`)"+
															"	) ENGINE=InnoDB ");
		Db.execute("ALTER TABLE UserRankCache_" + season + " ADD INDEX pouet(userId)");
		Db.execute("INSERT INTO UserRankCache_" + season + "(userId, points) (SELECT User.id as userId, SUM(((Cadaver.survivalDays+1)*0.5*Cadaver.survivalDays)) as points FROM User, Cadaver WHERE Cadaver.userId=User.id AND Cadaver.season=" + season + " GROUP BY User.id ORDER BY points DESC, User.id DESC)");
	}
	
	public static function buildRankings(?pSeason:Null<Int>=null) {
		var season = if ( pSeason == null ) App.getDbVar("season") else pSeason;
		
		var countingUsers = db.Version.getVar("usersRank_season_" + season, 40);
		
	//	printLog("<buildRankings season="+season+"/>");
		// cleanup
		Db.execute("DROP TABLE IF EXISTS RankingCache_"+season);
		// listing des cadavres de la saison
		// on évite de prendre en compte les morts des joueurs admins suicidés
		// Attention on ne peut pas trier par ID simplement, car parfois (morts caché/pas caché) des morts J29 se mélangent aux morts J30, cassant le tri par ID. Donc on prend par survivalDays.
		var data = Db.results("SELECT oldMapId, mapName, survivalDays, hardcore FROM Cadaver WHERE season="+season+" AND banned=0 AND deathType!="+Type.enumIndex(DT_Abandon)+" ORDER BY survivalDays DESC");
		var mapHash : IntHash<{
			mapName		: String,
			oldMapId	: Int,
			survivalDays: Int,
			score		: Int,
			hardcore	: Bool,
			deads		: Int,
		}> = new IntHash();
		for( c in data ) {
			if( !mapHash.exists(c.oldMapId) ) {
				mapHash.set(c.oldMapId, {
					mapName		: c.mapName,
					oldMapId	: c.oldMapId,
					survivalDays: c.survivalDays,
					score		: c.survivalDays,
					hardcore	: c.hardcore,
					deads		: 1,
				} );
			} else {
				var m = mapHash.get(c.oldMapId);
				m.deads ++;
				if( c.survivalDays > m.survivalDays )
					m.survivalDays = c.survivalDays;
					
				if( m.deads <= countingUsers )
					m.score += c.survivalDays;
			}
		}
		// création de la table ranking
		var table = "RankingCache_"+season;
		Db.execute(
			"CREATE TABLE "+table
			+" (oldMapId INT, mapName VARCHAR(100), survivalDays INT, score INT, hardcore TINYINT, deads INT)"
		);
		Db.execute("ALTER TABLE " + table + " ADD INDEX pouet(hardcore,score)");
		for( m in mapHash ) {
			if( m.deads >= 40 ) {
				//var extra =  db.MapVar.manager.search( { mapId:m.oldMapId, name:"extraPoints" }, false).first();
				//if( extra != null ) m.score += extra.value;
				Db.execute("INSERT INTO RankingCache_"+season
					+" (oldMapId, mapName, survivalDays, score, hardcore, deads)"
					+" VALUES (" + m.oldMapId + ", " + Db.quote(m.mapName) + ", " + m.survivalDays + ", " + m.score + ", " + (m.hardcore?1:0) +", " + m.deads + ")");
			}
		}
	//	printLog("<buildRankings custom='1'/>");
		// cleanup
		var table = "RankingCache_custom";
		Db.execute("DROP TABLE IF EXISTS "+table);
		// listing des cadavres de la saison
		// on évite de prendre en compte les morts des joueurs admins suicidés
		var data = Db.results("SELECT oldMapId, mapName, survivalDays, hardcore FROM Cadaver WHERE custom=1 AND deathType!="+Type.enumIndex(DT_Abandon)+" ORDER BY survivalDays DESC");
		var mapHash : IntHash<{
			mapName		: String,
			oldMapId	: Int,
			survivalDays: Int,
			score		: Int,
			hardcore	: Bool,
			deads		: Int,
		}> = new IntHash();
		for( c in data ) {
			if( !mapHash.exists(c.oldMapId) ) {
				mapHash.set(c.oldMapId, {
					mapName		: c.mapName,
					oldMapId	: c.oldMapId,
					survivalDays: c.survivalDays,
					score		: c.survivalDays,
					hardcore	: c.hardcore,
					deads		: 1,
				} );
			} else {
				var m = mapHash.get(c.oldMapId);
				m.deads++;
				if( c.survivalDays > m.survivalDays )
					m.survivalDays = c.survivalDays;
				
				if ( m.deads <= countingUsers )
					m.score += c.survivalDays;
			}
		}
		// création de la table ranking
		Db.execute( "CREATE TABLE "+table+" (oldMapId INT, mapName VARCHAR(100), survivalDays INT, score INT, hardcore TINYINT, deads INT)");
		Db.execute("ALTER TABLE " + table + " ADD INDEX pouet(hardcore,score)");

		for( m in mapHash ) {
			if( m.deads >= 40 ) {
				//var extra =  db.MapVar.manager.search( { mapId:m.oldMapId, name:"extraPoints" }, false).first();
				//if( extra != null ) m.score += extra.value;
				Db.execute("INSERT INTO "+table+" "
						+" (oldMapId, mapName, survivalDays, score, hardcore, deads)"
						+" VALUES (" + m.oldMapId + ", " + Db.quote(m.mapName) + ", " + m.survivalDays + ", " + m.score + ", " + (m.hardcore?1:0) +", " + m.deads + ")");
			}
		}
	}

	static function resetMapGather(ids) {
		printLog( "<resetMapGather/>");
		Db.execute("UPDATE User SET endGather = null WHERE id IN("+ids+")");
	}
	
	static function resetGather() {
		printLog( "<resetGather/>");
		Db.execute("UPDATE User SET endGather = null WHERE endGather IS NOT null AND mapId IS NULL");
	}
	
	static function setChaos(map:Map, noRestriction:Bool = false) {
		printLog( "<setChaos/>");
		if( noRestriction || map.days > Const.get.BeginPeriodDays ) {
			map.chaos = true;
			Db.execute("UPDATE User SET isCityBanned=0 WHERE isCityBanned=1 AND mapId ="+map.id);
		}
	}
	
	static function updateGuardsStats(map:Map) {
		printLog("<resetGuardsChance/>");
		Db.execute("UPDATE UserVar LEFT JOIN User ON (UserVar.userId=User.id) SET UserVar.value=GREATEST(0,UserVar.value-1) WHERE User.mapId=" + map.id + " AND User.isCityGuard=0 AND UserVar.name=" + Db.quote("guards"));
	}
	
	static function noMoreGuards(map:Map) {
		printLog( "<noMoreGuards/>");
		Db.execute( "UPDATE User SET isCityGuard=0 WHERE mapId="+map.id+" AND isCityGuard=1" );
	}
	
	public static function updateGhouls(map:Map) {
		if( !map.hasMod("GHOULS") )
			return;
		printLog("<updateGhouls/>");
		var gain = if(map.devastated) Const.get.GhoulMidnightHungerDevast else Const.get.GhoulMidnightHunger;
		Db.execute("UPDATE User SET ghoulHunger=ghoulHunger+"+gain+" WHERE dead=0 AND isGhoul=1 AND mapId="+map.id);
	}
	
	
	static function killInfected(map : Map) {
		printMapLog( map, "<killInfected/>");
		var chance = if( map.isHardcore() ) 0.75 else 0.5;
		var ids = Lambda.map(
			Db.results( "SELECT id FROM User WHERE dead=0 AND isGhoul=0 AND isInTrance=0 AND isInfected = 1 AND RAND()<="+chance+" AND mapId=" + map.id),
			function(info:{id:Int}) { return info.id; }
		);
		if( ids.length <= 0 )
			return;
		var n = kill( map, DT_Infected, Text.get.DT_Infected, "u.id IN("+ids.join(",")+")", map.days, map.days-1, GR.get.dinfec );
		printMapLog(map, "  count="+n);
	}
	
	static function killAddict(map : Map) {
		printMapLog( map, "<killAddict/>");
		var n = kill( map, DT_Drugged, Text.get.DT_Drugged, "u.isInTrance=0 AND u.isAddict=1 AND u.isDrugged=0 AND u.mapId=" + map.id, map.days, map.days-1, GR.get.ddrug );
		printMapLog(map, "  count="+n);
	}
	
	static function killGhouls(map : Map) {
		if( !map.hasMod("GHOULS") )
			return;
		printMapLog( map, "<killGhouls/>");
		var n = kill( map, DT_GhoulHungry, Text.get.DT_GhoulHungry, "u.isGhoul=1 AND isInTrance=0 AND u.ghoulHunger>"+Const.get.GhoulMaxHunger+" AND u.mapId="+map.id, map.days, map.days-1 );
		printMapLog(map, "  count="+n);
	}
/*
	static function killObjectiveMissed(map : Map) {
		if( !map.hasMod("OBJECTIVES") )
			return;
		printMapLog( map, "<killObjectiveMissed/>");
		var n = kill( map, DT_Abandon, Text.get.DT_Abandon, "u.objectiveId IS NOT NULL AND u.objectiveDay>0 AND u.objectiveDay<"+map.days+" AND u.mapId=" + map.id, map.days, map.days-1 );
		printMapLog(map, "  count="+n);
	}
*/
	
	static function killDehydrated(map : Map) {
		printMapLog( map, "<killDehydrated/>");
		var n = kill( map, DT_Dehydrated, Text.get.DT_Dehydrated, "u.isInTrance=0 AND u.isDehydrated=1 AND isGhoul=0 AND u.mapId=" + map.id, map.days, map.days-1, GR.get.dwater );
		printMapLog(map, "  count="+n);
	}
	
	static function killOutside(map: Map) {
		var n = 0;
		var list = new List();
		if( map.hasMod("CAMP") ) {
			printMapLog( map, "<killOutside with camp/>");
			list = db.User.manager.getDeadCampers(map);
			// ceux qui ont au moins essayé de camper reçoivent days...
			var day = if(map.devastated) map.days else map.days-1;
			n = kill( map, DT_KilledOutside, Text.get.DT_KilledOutside, "u.isOutside=1 AND campStatus=0 AND u.mapId=" + map.id, map.days, day, GR.get.doutsd );
			// ...les autres days-1
			n += kill( map, DT_KilledOutside, Text.get.DT_KilledOutside, "u.isOutside=1 AND campStatus IS null AND u.mapId=" + map.id, map.days, map.days-1, GR.get.doutsd );
		} else {
			printMapLog( map, "<killOutside without camp/>");
			list = db.User.manager.getDeadOutside(map);
			n = kill( map, DT_KilledOutside, Text.get.DT_KilledOutside, "u.isOutside=1 AND u.mapId=" + map.id, map.days, map.days-1, GR.get.doutsd );
		}
		
		// process the gather action so that objects aren't lost completely
		for ( u in list ) {
			handler.OutsideActions.gather(u);
		}
		
		printMapLog(map, "  count="+n);
		return list;
	}
	
	static function killEaten( ids : List<Int>, map : Map) {
		printLog( "<killEaten/>");
		if( ids.length <= 0 )
			return;
		var n = kill( map, DT_Eaten, Text.get.DT_Eaten, "u.mapId = "+map.id+" AND u.id IN("+ids.join(",")+")", map.days-1, map.days-1, GR.get.dcity );
		printMapLog(map, "  count="+n+" map.days="+map.days+"-1");
	}
	
	static function resetDailyThefts(map:Map){
		printLog( "<resetDailyThefts/>");
		Db.execute("UPDATE User SET hasStolen = 0 WHERE hasStolen=1 AND dead=0 AND mapId ="+map.id);
	}
	
	static function getZoneIds(map:Map):List<Int> {
		var list = Db.results( "SELECT id FROM Zone WHERE mapId=" + map.id );
		if( list.length > 0 ) {
			return Lambda.map(list, function(info:{id:Int}) {return info.id; } );
		} else {
			return new List();
		}
	}
	
	static function resetZoneActions(map:Map, zids:List<Int>) {
		printLog( "<resetZoneActions/>");
		if( zids.length > 0 )
			Db.execute("DELETE FROM ZoneAction WHERE zoneId IN("+zids.join(",")+")");
	}
	
	static function updateCamps(map:Map) {
		printMapLog(map, "<updateCamps>");
		var zoneIds:List<Int>;
		var survivorIds:List<Int> = new List();
		if ( map.hasMod("CAMP") ) {
			var res = Db.results("SELECT id, zoneId FROM User WHERE mapId="+map.id+" AND dead=0 AND campStatus=1");
			survivorIds = Lambda.map(res, function(r):Int { return r.id; } ); // ID des campeurs survivants
			zoneIds = Lambda.map(res, function(r):Int { return r.zoneId; } ); // ID des zones campées avec succès
			printMapLog(map, " count="+survivorIds.length+" list="+survivorIds.join(",")+" zones="+zoneIds.join(","));
			if( survivorIds.length > 0 ) {
				// user
				printLog("<updateUser/>");
				Db.execute("UPDATE User SET campCount=campCount+1, hasCamped=1 WHERE id IN ("+survivorIds.join(",")+")");
				// GhostReward
				printLog("<GhostReward/>");
				Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value )
							SELECT "+Db.quote(Std.string(GR.get.camp.ikey) )+",id, "+map.days+", 1 FROM User as u WHERE id IN ("+survivorIds.join(",")+") ON DUPLICATE KEY UPDATE value=value+1" );
			}
		} else {
			var res = db.Zone.manager.getZonesWithBuilding(map);
			zoneIds = Lambda.map(res, function(z):Int { return z.id; } );
		}
		// drop de plans
		if( zoneIds.length > 0 ) {
			for( z in db.Zone.manager.getZonesWithDiggedBuildingById(zoneIds) ) {
				if( z.canDropPlan(map) ) {
					db.MapVar.setValue(map, "campPlanDropped_"+z.id, 1); // un bâtiment donné ne peut donner qu'un seul plan pour toute la partie
					var bplan = if (z.level < 10) 	XmlData.getToolByKey("bplan_u") 
								else 				XmlData.getToolByKey("bplan_r");
					ZoneItem.create(z, bplan.toolId, 1);
					printLog("<campOnBuilding z="+z.id+" t="+bplan.key+"/>");
				}
			}
		}
		// réduction naturelle de la défense des zones
		printLog("<updateZone/>");
		Db.execute("UPDATE Zone SET defense = GREATEST(0, defense-"+Const.get.CampLoss+") WHERE defense>0 AND mapId="+map.id);
		printMapLog(map,"</updateCamps>");
		return survivorIds;
	}
	
	static function resetCamps(map:Map) {
		if( !map.hasMod("CAMP") )
			return;
		printMapLog(map,"<resetCamps/>");
		Db.execute("UPDATE User SET campStatus=null WHERE campStatus IS NOT null AND mapId="+map.id);
	}
	
	static function getCampSurvivors(map:Map) {
		if( !map.hasMod("CAMP") )
			return new List();
		var res = Db.execute("SELECT id FROM User WHERE mapId="+map.id+" AND dead=0 AND campStatus=1");
		var list = new List();
		for( r in res )
			list.add(r.id);
		return list;
	}
	
	static function infectWounded(map : Map) {
		printLog( "<infectWounded/>");
		Db.execute("UPDATE User SET isInfected=1 WHERE isWounded = 1 AND isGhoul=0 AND mapId="+map.id+" AND dead=0 ");
	}
	
	static function setDrugged(map:Map) {
		printLog( "<setDrugged/>");
		Db.execute("UPDATE User SET isDrugged=0 WHERE isDrugged = 1 AND mapId ="+map.id+" AND dead=0 ");
	}
	
	static function setDehydrated(map:Map) {
		printLog( "<setDehydrated/>");
		Db.execute("UPDATE User SET isDehydrated=1, isTired=1 WHERE isInTrance=0 AND isThirsty=1 AND hasDrunk=0 AND isGhoul=0 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function setThirsty(map:Map) {
		printLog( "<setThirsty/>");
		Db.execute("UPDATE User SET isThirsty=1, isTired=1 WHERE isInTrance=0 AND isThirsty=0 AND isDehydrated=0 AND hasDrunk=0 AND isGhoul=0 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function resetCampBonus(map:Map) {
		if( !map.hasMod("CAMP") )
			return;
		printLog( "<resetCampBonus/>");
		Db.execute("UPDATE User SET hasCamped=0 WHERE hasCamped=1 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function resetDrunk(map:Map) {
		printLog( "<resetDrunk/>");
		Db.execute("UPDATE User SET hasDrunk=0 WHERE hasDrunk=1 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function resetEaten(map:Map) {
		printLog( "<resetEaten/>");
		Db.execute("UPDATE User SET hasEaten=0 WHERE hasEaten=1 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function resetImmunity(map:Map) {
		printLog( "<resetImmunity/>");
		Db.execute("UPDATE User SET isImmune=0 WHERE isImmune=1 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function resetTired(map:Map) {
		printLog( "<resetTired/>");
		Db.execute("UPDATE User SET isTired=0 WHERE isTired=1 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function resetConvalescent(map:Map) {
		printLog( "<resetConvalescent/>");
		Db.execute("UPDATE User SET isConvalescent=0 WHERE isConvalescent=1 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function resetMoves( map: Map) {
		printLog( "<resetMoves/>" );
		Db.execute("UPDATE User SET steps=0, pa=" + (Const.get.PA) + " WHERE mapId=" + map.id + " AND dead=0");
		if( map.hasMod("JOB_TECH") ) {
			printLog( "<resetTechnicianActions />" );
			var jobId = XmlData.getJobByKey("tech").id;
			var sql = "INSERT INTO UserVar (userId, name, value, persistOnDeath) SELECT id, " + Db.quote("buildingActions".toLowerCase()) + ", " + Const.get.TechnicianBuildingActions + ", 0 FROM User WHERE mapId=" + map.id + " AND jobId=" + jobId + " AND dead=0 ON DUPLICATE KEY UPDATE UserVar.value=" + Const.get.TechnicianBuildingActions;
			printLog("<sql>" + sql + "</sql>");
			Db.execute(sql);
		}
		
		if( map.hasMod("SHAMAN_SOULS") ) {
			printLog( "<resetShamanActions />" );
			var sql = "INSERT INTO UserVar (userId, name, value, persistOnDeath) SELECT id, " + Db.quote("charlatanActions".toLowerCase()) + ", " + Const.get.ShamanDailyActions + ", 0 FROM User WHERE mapId=" + map.id + " AND isShaman=1 AND dead=0 ON DUPLICATE KEY UPDATE UserVar.value=" + Const.get.ShamanDailyActions;
			printLog("<sql>" + sql + "</sql>");
			Db.execute(sql);
		}
	}
	
	static function woundedPA(map:Map) {
		printLog( "<woundedPA/>");
		Db.execute("UPDATE User SET pa=pa-1 WHERE isWounded=1 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function setHungOver(map:Map) {
		printLog( "<setHungOver/>");
		Db.execute("UPDATE User SET isHungOver=1, isDrunk=0 WHERE isDrunk=1 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function unsetHungOver(map:Map) {
		printLog( "<unsetHungOver/>");
		//removed isDrunk=0  since both state can be present when an hungover ghoul eats someone  drunk
		Db.execute("UPDATE User SET isHungOver=0 WHERE isHungOver=1 AND mapId="+map.id+" AND dead=0");
	}
	
	static function resetWaterFlag(map:Map){
		printLog( "<resetWaterFlag/>");
		Db.execute("UPDATE User SET waterTaken = 0 WHERE waterTaken>0 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function resetHeroActions(map:Map){
		printLog( "<resetHeroActions/>");
		Db.execute("UPDATE User SET hasDoneDailyHeroAction=0 WHERE hasDoneDailyHeroAction=1 AND mapId ="+map.id+" AND dead=0");
	}
	
	static function resetHeroRecommandations(map:Map){
		printLog( "<resetHeroRecommandations/>");
		Db.execute("UPDATE CityBuilding SET heroVotes=0 WHERE heroVotes>0 AND zoneId="+map.cityId);
	}
	
	static function resetEscorts(map:Map) {
		printLog("<resetEscorts/>");
		Db.execute("UPDATE User SET leaderId=null, isWaitingLeader=0, wasEscorted=0 WHERE dead=0 AND mapId="+map.id );
	}
	
	static function resetUserActivity(map :Map){
		printLog( "<resetUserActivity/>");
		Db.execute("UPDATE User SET activity=0 WHERE mapId="+map.id+" AND activity>0");
	}
	
	static function resetExpeditions( map : Map ){
		printLog( "<resetExpeditions/>");
		Db.execute("DELETE FROM Expedition WHERE mapId=" + map.id);
	}
	
	static function resetZoneTags(map:Map){
		printLog( "<resetZoneTags/>");
		// tag inutiles d'un jour sur l'autre
		var tlist = new List();
		tlist.add( IT_Help );
		tlist.add( IT_Secured );
		tlist.add( IT_Zombie5 );
		tlist.add( IT_Zombie9 );
		tlist.add( IT_Camp );
		var list = new List();
		for( t in tlist )
			list.add( Type.enumIndex(t) );
		Db.execute("UPDATE Zone SET infoTag=0 WHERE mapId="+map.id+" AND infoTag IN ("+list.join(",")+")");
	}
	
	static function resetZoneFlags(map:Map){
		printLog( "<resetZoneFlag/>");
		Db.execute("UPDATE Zone SET endFeist=null WHERE endFeist is not null AND mapId="+map.id);
	}
	
	static function updateZoneHumanScores(map:Map) {
		printLog( "<updateZoneHumanScores>");
		var t = db.Zone.manager.updateHumanScores(map);
		printLog( "duration = "+t+"ms");
		printLog( "</updateZoneHumanScores>");
	}
	
	static function resetTowerEstim(map:Map){
		printLog( "<resetTowerEstim/>");
		map.estimCount = if( map.isFar() ) 0 else 10; // les RNE ont droit à une estimation de base chaque jour
	}
	
	static function resetTrance(map:Map) {
		printLog( "<resetTrance/>");
		Db.execute("UPDATE User SET isInTrance=0 WHERE mapId="+map.id+" AND isInTrance=1");
	}
	
	static function cleanUpZoneItems() {
		printLog("<cleanUpZoneItems/>");
		Db.execute( "DELETE FROM ZoneItem WHERE count=0" );
		printLog("<cleanUpExploItems/>");
		Db.execute( "DELETE FROM ExploItem WHERE count=0" );
	}
	
	public static function resetZoneKills(?map:Map){
		if( map != null )
			printMapLog( map, "<resetZoneKills/>");
		else
			printLog( "<resetZoneKills/>");
		//
		if( map == null ) {
			Db.execute("UPDATE Zone SET kills=floor(kills*0.4) WHERE kills>0");
		} else {
			// utile seulement pour une adminAction
			Db.execute("UPDATE Zone SET kills=floor(kills*0.4) WHERE kills>0 AND mapId="+map.id);
		}
	}
	
	static function startHordeAttack() {
		
		db.UserVar.manager.deleteAllVars("quarantineRequest");
		db.Version.manager.removeGlobalQuarantine();
		
		printLog( "<attack date='" + CURRENT_DAY.toString()+"'>");
		printLog( "<deleteFromSession/>");
		Db.execute("DELETE FROM Session");
		printLog( "<addHordeEvent/>");
		Db.execute("INSERT INTO HordeEvent (event) VALUES ( " +Type.enumIndex(H_Attack) + ")");
		printLog( "<changeMapStatus/>");
		Db.execute("UPDATE Map SET event="+Type.enumIndex(ES_horde)+" WHERE status != " + Type.enumIndex( EndGame ) );
		printLog( "<changeUserEventStatus/>");
		Db.execute("UPDATE User SET eventState="+Type.enumIndex(ES_horde)+" WHERE mapId IS NOT NULL and dead=0");
		printLog( "<changeUserEventStatus/>");
	}
	
	static function endHordeAttack() {
		if( !ALREADY_ATTACKED_TODAY ) {
			printLog( "<optimizeTables/>");
			Db.execute("OPTIMIZE TABLE CityLog");
			printLog( "<cleanErrorLog/>");
			Db.execute("DELETE FROM Error WHERE date < NOW() - INTERVAL 3 DAY");
			Db.execute("DELETE FROM CadaverRemains WHERE cadaverId in ( SELECT id FROM Cadaver WHERE mapId IS NULL )");
			deleteUnusedNewsInfo();
		} else {
			printLog( "<alreadyAttackedSoNoOptimization/>");
		}
		printLog( "<resetMapStatus/>");
		Db.execute("UPDATE User SET eventState=null WHERE mapId IS NOT NULL and dead=0");
		Db.execute("UPDATE Map SET event=NULL WHERE event="+Type.enumIndex(ES_horde));
		printLog( "<resetHordeEvent/>");
		Db.execute("DELETE FROM HordeEvent");
		printLog( "</attack>");
	}
	
	static function deleteUnusedNewsInfo() {
		printLog( "<deleteUnusedNewsInfo/>");
		Db.execute("DELETE FROM NewsInfo WHERE mapId IS NULL");
	}
	
	static function resetNewsReading(map:Map) {
		printLog( "<resetNewsReading/>");
		Db.execute("UPDATE User SET hasReadCityNews = 0 WHERE hasReadCityNews = 1 AND dead=0 AND mapId="+map.id );
	}
	
	static function resetCheckedZones(map:Map) {
		printLog( "<resetCheckedZones/>");
		Db.execute("UPDATE Zone SET tempChecked=0 WHERE tempChecked=1 AND mapId="+map.id );
	}
	
	public static function gather() {
		// XXX les collecteurs ont un % de chance dans les zones épuisées dans la liste normale
		var now = Date.now();
		var dateToUse = new Date( now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes(), 0 );
		var std = Db.results("SELECT id, zoneId, endGather, jobId FROM User WHERE mapId IS NOT NULL AND dead=0 AND jobId != " + XmlData.getJobByKey("collec").id + " AND endGather IS NOT NULL AND endGather <= "+Db.quote( dateToUse.toString() )+" ORDER BY endGather");
		var coll = Db.results("SELECT id, zoneId, endGather, jobId FROM User WHERE mapId IS NOT NULL AND dead=0 AND jobId = " + XmlData.getJobByKey("collec").id + " AND endGather IS NOT NULL AND endGather <= "+Db.quote( dateToUse.toString() )+" ORDER BY endGather");
		if( std.length <= 0 && coll.length <= 0 )
			return;
		printLog( "[G] " + std.length + " CITIZENS\n");
		printLog( "[G] " + coll.length + " COLLECTORS\n" );
		var zones : List<Int>= new List();
		var normal = new List();
		var all : Array<{id:Int, zoneId:Int, endGather:Date, jobId : Int}> = new Array();
		for( i in std ) {
			zones.add( i.zoneId );
			all.push( cast i);
			normal.add( i.id );
		}
		var collectors = new List();
		for( i in coll ) {
			zones.add( i.zoneId );
			all.push( cast i);
			collectors.add( i.id );
		}
		if( zones.length <= 0 ) {
			printLog( "[G] NO ZONES TO CHECK\n" );
			return;
		}
		all.sort( function( i1, i2 ) { return Reflect.compare( i1.endGather, i2.endGather ); } );
		// on récupère la liste des items probables de base
		var list = XmlData.getDropList();
		var dropList = new Array();
		for( tool in list )
			for( i in 0...tool.proba )
				dropList.push(tool.key);
		// on récupère la liste des objets issus des ressources
		var dlist = XmlData.getOutsideBuilding( 9996 );
		var toolList = dlist.tools;
		var tProba = new Array();
		for( t in toolList ) {
			for( i in 0...t.p ) {
				tProba.push( t.t );
			}
		}
		// on récupère les zones
		var zonesO = db.Zone.manager._getZonesFromIds( zones, false );
		if( zonesO.length <= 0 ) {
			printLog( "[WARNING !] NO ZONES FOUND FROM USER ZONE INFO !\n" );
			return;
		}
		for( zz in zonesO ) {
			printLog( "[G] STARTING ZONE#"+zz.id+"\n" );
			if( zz.zombies > zz.humans ) { // ajouté par seb
				printLog( "[G] --> NO CONTROL ON THIS ZONE, GATHER SKIPPED (h="+zz.humans+" z="+zz.zombies+")" );
				continue;
			}
			var users = Lambda.filter( all, function( k : {id:Int, zoneId:Int, endGather:Date, jobId : Int} ) { return k.zoneId == zz.id; } );
			printLog( "[G] "+users.length+" USER(S) TO CHECK\n" );
			var fl_farMap = db.Map.manager.isFar(zz.mapId);
			var z = Zone.manager.get( zz.id );
			var update = false;
			for( uu in users ) {
				// locker user pour s'assurer que user est bien à jour
				var u = User.manager.get( uu.id );
				if( u.jobId == null )
					continue;
				if( u.dead )
					continue;
				if( u.endGather == null )
					continue;
				if( u.endGather.getTime() > dateToUse.getTime() )
					continue;
				// mise à jour du timer du joueur concerné
				u.endGather = 	if( u.jobId == 2 )
									DateTools.delta( dateToUse, DateTools.minutes( Const.get.GatherTimeShort ) )
								else
									DateTools.delta( dateToUse, DateTools.minutes( Const.get.GatherTime ) );
				u.update();
				if( z.dropCount > 0 ) {
					var chance = u.getGatherChance(fl_farMap);
					if( Std.random( 100 ) >= chance ) {
						db.TempGather.add( User.manager.get( u.id ), null );
						continue;
					}
					var tool = XmlData.getToolByKey( dropList[ Std.random(dropList.length) ] );
					if( tool != null && tool.key == "bplan_drop" && db.MapVar.manager.fastInc(u.mapId, "plansDroppedToday") > Const.get.MaxDailyPlanDrop )
						tool = XmlData.getToolByKey("wood");
					db.TempGather.add( User.manager.get( u.id ), tool.toolId );
					z.dropCount--;
					update = true;
					continue;
				}
				var chance = Const.get.OverflowGatherChance;
				if( Std.random( 100 ) >= chance ) {
					db.TempGather.add( User.manager.get( u.id ), null );
					continue;
				}
				var tool = XmlData.getToolByKey( tProba[Std.random(tProba.length-1)] );
				db.TempGather.add( User.manager.get( u.id ), tool.toolId );
				z.dropCount = 0;
				update = true;
			}
			if( update ) {
				z.update();
				printLog("\n[G] UPDATING ZONE#"+z.id+"\n");
			}
			// je rend le lock
			#if !tests
			Db.cx.commit();
			Db.cx.startTransaction();
			#end
		}
	}
	
	static function cityUpgrades( map : Map, newsInfo:NewsInfo ) {
		printMapLog( map, "<cityUpgrade>");
		// on récupère les votes > 0 et on incrémente le level
		var bestVote = db.CityUpgrade.manager.getBestVote( map );
		if( bestVote == null ) {
			printMapLog( map, "NO VOTE</cityUpgrade>" );
			return;
		}
		var building = XmlData.getBuildingById( bestVote.bid );
		if( building == null ){
			printMapLog( map, "ERROR : BUILDING UNKNOWN</cityUpgrade>" );
			return;
		}
		var upgrade = XmlData.getCityUpgradeByParent( building );
		if( upgrade == null ){
			printMapLog( map, "ERROR : UPGRADE UNKNOWN</cityUpgrade>" );
			return;
		}
		// on augmente le niveau de la structure
		var level = bestVote.level;
		bestVote.level += 1;
		bestVote.update();
		var key = upgrade.parent.key;
		// On joue l'action correspondante
		switch( key ) {
			case "pump" :
				printLog( "pump " + bestVote.level + ":" + upgrade.parent.name );
				var cur = upgrade.levels[bestVote.level];
				if( cur != null ) {
					var value = Std.int( cur.value);
					map.water += value;
					printMapLog( map, "<pump>"+value+"</pump>" );
				 } else {
					printLog( "</level_unknown>" );
				 }
		}
		newsInfo.upgradeVoted = bestVote;
		printMapLog( map, key+":"+ bestVote.level +"</cityUpgrade>" );
	}
	
	static function useDailyCityUpgrades( map : Map, newsInfo:NewsInfo ) {
		printMapLog( map, "<useDailyCityUpgrades>" );
		var upgrades = Db.results( "SELECT bid, level FROM CityUpgrade WHERE mapId=" + map.id );
		if( upgrades.length <= 0 ) {
			printMapLog( map, "<n>NOTHING DONE</n>");
			return;
		}
		for( u in upgrades ) {
			if( u.level == 0 )
				continue;
			var building = XmlData.getBuildingById( u.bid );
			if( building == null ) {
				printMapLog( map, "<e>UNKNOWN BUILDING (bid="+u.bid+")</e>" );
				continue;
			}
			var upgrade = XmlData.getCityUpgradeByParent( building );
			if( upgrade == null ) {
				printMapLog( map, "<e>UNKNOWN UPGRADE (bid="+u.bid+")</e>" );
				continue;
			}
			switch( building.key ) {
				case "tower" :
					printMapLog( map, "<tower level='"+u.level+"'>");
					var cur = upgrade.levels[u.level];
					var value = Std.int( cur.value );
					printMapLog( map, "  <tower value="+value+"/>");
					Db.execute( "UPDATE Zone SET tempChecked=1, checked=1 WHERE mapId="+map.id+" AND level <=" + value );
					printMapLog( map, "</tower>");
				case "aquaTurret" :
					var req = Math.floor( db.CityUpgrade.getValueIfAvailableByKey( "aquaTurret", 3, map, 0 ) );
					printMapLog( map, "<msg>aquaTurret : req="+req+" map.water="+map.water+"</msg>" );
					if ( map.water>=req ) {
						map.water-=req;
						newsInfo.waterLoss += req;
					}
			}
		}
		printMapLog( map, "</useDailyCityUpgrades>" );
	}
	
	static function resetCityUpgradeVotes(map:Map) {
		printLog( "<resetCityUpgradeVotes />");
		Db.execute( "UPDATE CityUpgrade SET votes=0 WHERE mapId="+map.id+" AND votes>0" );
	}
	
	static function updateHumanScores(map:Map) {
		printLog("<updateHumanScores />");
		db.Zone.manager.updateHumanScores(map);
	}
	
	static function ringAlarmClock(map:Map, uids:List<Int>) {
		printLog("<ringAlarmClock/>");
		if( uids.length>0 )
			Db.execute("UPDATE User SET pa=pa+1 WHERE mapId="+map.id+" AND dead=0 AND isDeleted=0 AND (winnerNormal=1 OR winnerHardcore=1) AND id IN ("+uids.join(",")+") ");
	}
	
	public static function transformTools(map:Map) {
		var uids = db.User.manager.getMapUserIds(map);
		var zids = db.Zone.manager.getZoneIds(map, 0, 99);
		printLog( "<transformTools z="+zids.length+" u="+uids.length+"/>");
		transformTool( uids,zids, XmlData.getToolByKey("torch"), XmlData.getToolByKey("torch_off") );
		transformTool( uids,zids, XmlData.getToolByKey("tamed_pet_off"), XmlData.getToolByKey("tamed_pet") );
		transformTool( uids,zids, XmlData.getToolByKey("tamed_pet_drug"), XmlData.getToolByKey("tamed_pet") );
		transformTool( uids,zids, XmlData.getToolByKey("lamp_on"), XmlData.getToolByKey("lamp") );
		transformTool( uids,zids, XmlData.getToolByKey("maglite_1"), XmlData.getToolByKey("maglite_off") );
		transformTool( uids,zids, XmlData.getToolByKey("maglite_2"), XmlData.getToolByKey("maglite_1") );
		transformTool( uids,zids, XmlData.getToolByKey("reveil"), XmlData.getToolByKey("reveil_off") );
	}
	
	public static function transformTool(uids:List<Int>, zids:Array<Int>, from:Tool, to:Tool) {
		Db.execute("INSERT INTO ZoneItem (zoneId,toolId,count,isBroken,visible) SELECT zoneId,"+to.toolId+",count,0,1 FROM ZoneItem AS b WHERE toolId="+from.toolId+" AND zoneId IN("+zids.join(",")+") ON DUPLICATE KEY UPDATE ZoneItem.count=ZoneItem.count+VALUES(count)");
		Db.execute("DELETE FROM ZoneItem WHERE toolId=" + from.toolId + " AND zoneId IN(" + zids.join(",") + ")");
		Db.execute("INSERT INTO ExploItem (zoneId,toolId,count,isBroken) SELECT zoneId,"+to.toolId+",count,0 FROM ExploItem AS b WHERE toolId="+from.toolId+" AND zoneId IN("+zids.join(",")+") ON DUPLICATE KEY UPDATE ExploItem.count=ExploItem.count+VALUES(count)");
		Db.execute("DELETE FROM ExploItem WHERE toolId=" + from.toolId + " AND zoneId IN(" + zids.join(",") + ")");
		if( uids.length > 0 )
			Db.execute("UPDATE Tool SET toolId="+to.toolId+" WHERE toolId="+from.toolId+" AND userId IN ("+uids.join(",")+")");
		Db.execute("UPDATE CadaverRemains SET toolId="+to.toolId+" WHERE toolId="+from.toolId);
	}
	
	public static function makeStats() {
		Db.execute("DELETE FROM Version WHERE name='stat1' OR name='stat2' OR name='stat3'");
		Db.execute("INSERT INTO Version (name, version) SELECT 'stat1', count(*) FROM Cadaver");
		Db.execute("INSERT INTO Version (name, version) SELECT 'stat2', SUM(value) FROM GhostReward WHERE rewardKey="+GR.get.killz.ikey);
		Db.execute("INSERT INTO Version (name, version) SELECT 'stat3', SUM(value) FROM GhostReward WHERE rewardKey="+GR.get.cannib.ikey);
	}
	
	static function deleteTools(key:String) {
		var tool = XmlData.getToolByKey(key);
		if( tool == null ) return;
		Db.execute("DELETE FROM ZoneItem WHERE toolId=" + tool.toolId);
		Db.execute("DELETE FROM ExploItem WHERE toolId="+tool.toolId);
		Db.execute("DELETE FROM Tool WHERE toolId="+tool.toolId);
	}
	
	static function printLog( msg ) {
		#if tests return; #end
		var now = Date.now();
		var hour = now.getHours();
		var min = now.getMinutes();
		var sec = now.getSeconds();
		var date = hour + ":" + min + ":" + sec;
		neko.Lib.print("<now>"+date+"</now>" + msg + "\n");
	}
	
	static function printMapLog( map : Map, log : String ) {
		#if tests return; #end
		if( map.attackLog == null ) map.attackLog = "";
		map.attackLog += log;
		ATTACK_LOG += log;
		printLog( log );
	}
}
