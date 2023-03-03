import Common;
import db.User;
import db.Map;
import db.Cadaver;
import db.CityLog;
import db.ZoneItem;
import db.GameStat;
import db.NewsInfo;
import mt.MLib;

using Lambda;
using mt.Std;
class HordeAttack {

	static var MAP = null;
	static var MATURE_MAP = false;
	static var LOG = null;

	public static function initStatics( map : Map, printMapLog : db.Map -> String -> Void ) {
		MAP = map;
		LOG = printMapLog;
		MATURE_MAP = isMatureMap(MAP);
	}
	
	public static function isMatureMap(map) {
		return map.hardcore ? (map.days > (2*Const.get.BeginPeriodDays)) : (map.days > Const.get.BeginPeriodDays);
	}
	
	public static function resolve( map : Map, zombies : Int, allUsers : List<User>, CURRENT_DAY: Date, gameStat:GameStat, newsInfo:NewsInfo, printMapLog : db.Map -> String -> Void ) : List<User> {
		MAP = null;
		
		var inTownUsers = Lambda.filter(allUsers, function(u) return u.isOutside == false);
		MAP = map;
		MATURE_MAP = isMatureMap(MAP);
		LOG = printMapLog;
		
		var cityItems = db.ZoneItem.manager._getZoneItems( MAP._getCity() );
		var cityBuildings = db.CityBuilding.manager.getDoneBuildingsHash(MAP);
		var defenses = MAP.getCityDefense( cityItems, cityBuildings );
		var remainingZombies = zombies;
		var deadInAttack = new List();
		var ncCount = 0;
		var notCleaned = new List();
		logAttack("<remainingZombies v='"+remainingZombies+"'/>");
		
		/*************  PATCH  ********************/
		//On devrait patcher la defense des guardiens pour reprendre celle avant les changements d'états du cron, et qui ont été mises en cache
		//On ne le fait pas car cette donnée n'est pas utilisée
		
		/*************** DEBUT ***************/
		// Pas d'attaques des anciens le premier jour :)
		if( MAP.days > 1 )  {
			// On récupère uniquement les mort non arrosés et qui n'ont pas encore perpétré d'attaque
			notCleaned = Cadaver.manager.getUncleanedDeads(MAP);
			logAttack("<notCleaned n=" + notCleaned.length + " day=" + map.days + "/>");
			
			// Note : MAP.days -1 est utile pour les anciens citoyens étant donné que le jour de la map ne s'incrémente qu'après les décès autre que l'attaque
			var outsideZP = Lambda.filter( notCleaned, function( c: Cadaver ) return !c.diedInTown );
			var inTownZP = Lambda.filter( notCleaned, function( c: Cadaver ) return c.diedInTown );
			ncCount = notCleaned.length;
			
			logAttack("<citizenZombieFromOutside v='"+outsideZP.length+"'/>");
			logAttack("<citizenZombieFromTown v='"+inTownZP.length+"'/>");
			// les morts dehors s'ajoutent au compteur
			remainingZombies += outsideZP.length;
			logAttack("<totalZombieCount v='" + remainingZombies + "'/>");
			// les morts dehors s'ajoutent au compteur avec texte RP
			if( outsideZP.length > 0 ) {
				if( outsideZP.length == 1 )
					addLog( Text.fmt.CL_Attack_PlayerZombieOutside({z:outsideZP.pop().print()}) );
				else
					addLog( Text.fmt.CL_Attack_PlayerZombiesOutside( { z:outsideZP.length } ) );
			}
			/*************** CADAVRES NON DETRUITS ***************/
			if( inTownZP.length > 0 )  {
				logAttack("<citizenZombieFromTownAttack>");
				var bankItems = Lambda.array(ZoneItem.manager._getZoneItems( MAP._getCity(), true ) );
				addLog( Text.get.CL_Attack_PlayerZombiesMeanwhile );
				
				var alreadyKilled = new IntHash();
				for( zp in inTownZP ) {
					var chanceAttackPlayer = if( MAP.water > 0 ) 66 else 100;
					if( Std.random(100) < chanceAttackPlayer ) {// on tue un joueur
						var trY = attackPlayer( zp, inTownUsers, alreadyKilled );
						if( trY != null )
							deadInAttack.add(trY);
					} else {// on vire n unités d'eau au puits
						var loss = Math.floor( Math.min( MAP.water, Const.get.WaterLost) );
						newsInfo.waterLoss += loss;
						MAP.water -= loss;
						MAP.update();
						addLogEvent( Text.fmt.CL_Attack_PlayerZombie_WaterLoss({name:zp.print(), n:Const.get.WaterLost}) );
						logAttack("<waterLoss v='"+loss+"'/>");
					}
					logAttack("<killedCitizens v='"+deadInAttack.length+"'/>");
					logAttack("<citizenZombieFromTownAttack/>");
				}
				
				var inTownIds = Lambda.map( inTownZP, function(c) return c.id );
				flagViolentCadavers(inTownIds);
				// fin de partie
				//deadInAttack peut etre égal à 0 si tous les joueurs sont en camping.
				if( deadInAttack.length == inTownUsers.length ) {
					logAttack("<deadTown/>");
					addLogEvent(Text.get.CL_Attack_PlayerZombiesKilledAll);
					if(MATURE_MAP && !MAP.devastated)
						giveLastRewards(deadInAttack);
					else
						logAttack("<noLastGroupReward/>");
					
					if ( deadInAttack.length == allUsers.length )
					{
						closeMap();
						return deadInAttack;
					}
					else
					{
						//TODO return was applied here
					}
				}
			}
		}
		
		/*************** DEFENSES DE LA VILLE ***************/
		logAttack("<buildingAttack/>");
		addLog( Text.get.CL_Attack_Start );
		var hashUserDefense = new IntHash();
		for( u in inTownUsers )
			hashUserDefense.set( u.id, u.getHomeDefense() );
		// 2 - Si les portes de la ville sont fermées,
		// on teste les défenses de la ville
		var zombiesOnBuildings = zombies;
		if( MAP.hasDoorOpened() ) {
			logAttack("<doorOpened/>");
			addLogEvent( Text.get.CL_Attack_NoDoor );
			gameStat.defense = -1;
			newsInfo.def = 0;
		} else {
			logAttack("<doorClosed/>");
			
			var cityDefensesTotal = defenses.total - defenses.guardiansInfos.def;
			gameStat.defense = cityDefensesTotal;
			newsInfo.def = cityDefensesTotal;
			
			logAttack("<defenses total='"+cityDefensesTotal+"'>");
			logAttack("<d buildings='"+defenses.buildings+"'/>");
			logAttack("<d upgrades='"+defenses.upgradeInfos.total+"' list='"+defenses.upgradeInfos.list.join(",")+"'/>");
			logAttack("<d items total='"+defenses.itemInfos.total+"' items='"+defenses.itemInfos.items+"' mul='"+defenses.itemInfos.mul+"'/>");
			logAttack("<d users total='"+defenses.userInfos.total+"' homes='"+defenses.userInfos.homes+"' count='"+defenses.userInfos.count+"' guards="+defenses.userInfos.guards+"/>");
			logAttack("<d cityOnly='" + defenses.cityOnly + "'/>");
			logAttack("<d souls='"+defenses.souls+"'/>");
			logAttack("</defenses>");
			remainingZombies = zombies - cityDefensesTotal;
			
			zombiesOnBuildings = Std.int(Math.min(zombies, cityDefensesTotal));
			logAttack("<remainingZombies v='"+remainingZombies+"'/>");
			if( cityDefensesTotal > 0 ) {
				if( remainingZombies <= 0 ) {
					if( ncCount > 0 ) {
						if( ncCount == 1 )
							addLog( Text.fmt.CL_Attack_PlayerZombieDefeated({z:notCleaned.first().print()}) );
						else
							addLog( Text.get.CL_Attack_PlayerZombiesDefeated );
					}
					addLog( Text.get.CL_Attack_CityDefAll );
				} else {
					if( remainingZombies > 1 )
						addLog( Text.fmt.CL_Attack_CityDef({r:remainingZombies}) );
					else
						addLog( Text.get.CL_Attack_CityDefOne );
				}
			} else
				addLog( Text.get.CL_Attack_NoCityDef );
		}
		
		/*************** DEGATS SUR CHANTIERS ***************/
		if( MAP.hasMod("BUILDING_DAMAGE") && MAP.isHardcore() ) {
			logAttack("<buildingDamages z="+zombiesOnBuildings+">");
			// filtrage des bâtiments indestructibles
			var allBuildings = db.CityBuilding.manager.getDoneBuildings(MAP,true);
			var blist = new Array();
			for( b in allBuildings ) {
				var bdata = XmlData.getBuildingById(b.type);
				if(!bdata.unbreakable && !bdata.temporary)
					blist.push(b);
			}
			var ratio = Const.get.BuildingAttackDamageRatio;
			var dmg = Math.floor(zombiesOnBuildings/ratio);
			logAttack("<data dmg="+dmg+" list="+blist.length+" ratio="+ratio+"/>");
			if( blist.length > 0 ) {
				var dmgHash = tools.Utils.spreadDamages(dmg, blist.length);
				for( id in dmgHash.keys() ) {
					// on applique les dégâts en maximisant à 70% de la life d'un building
					var d = dmgHash.get(id);
					d = Math.ceil( Math.min( blist[id].maxLife*0.7, d ) );
					blist[id].life -= d;
					dmgHash.set(id, d);
				}
				// bâtiments endommagés / détruits
				var id = 0;
				for( b in blist ) {
					var dmg = dmgHash.get(id);
					if( dmg != null && dmg > 0 ) {
						var bdata = XmlData.getBuildingById(b.type);
						if( b.life <= 0 ) {
							// destruction
							logAttack(" <destroy id="+b.id+" d="+dmg+" life="+b.life+"/>");
							b.destroy(MAP);
							CityLog.add( CL_AttackEvent, Text.fmt.CL_BuildingDestroyed({name:bdata.name, n:dmg}), map );
						} else {
							// dégâts
							logAttack(" <dmg id="+b.id+" d="+dmg+" life="+b.life+"/>");
							b.update();
							CityLog.add( CL_Attack, Text.fmt.CL_BuildingDamaged({name:bdata.name, n:dmg}), map );
						}
					}
					id++;
				}
			} else {
				logAttack("<nothing/>");
			}
			logAttack("</buildingDamages>");
		}
		
		/*************** DEGATS SUR LA BANQUE ***************/
		if( MAP.hasMod("BANK_DAMAGE") && MAP.isHardcore() ) {
			// on retranche les zombies sur les buildings
			var zombiesOnBank = zombies - defenses.buildings;
			logAttack("<bankDamages z="+zombiesOnBank+">");
			var ratio = Const.get.BankAttackDamageRatio;
			var dmg = Math.floor( Math.min(zombiesOnBank/ratio, Const.get.BankAttackMaxDamage) );
			// recherche des items d'armure
			var toolIds = new List();
			for( zi in cityItems )
				if( !zi.isBroken && zi.count > 0 && XmlData.getTool(zi.toolId).hasType(Armor) )
					toolIds.add(zi.toolId);
			if( toolIds.length > 0 && dmg > 0 ) {
				// on lock les items sélectionnés
				var ziList = new Array();
				for(zi in ZoneItem.manager.getItemList(toolIds, MAP._getCity(), false))
					for(n in 0...zi.count)
						ziList.push(zi);
				logAttack(" <data dmg="+dmg+" items="+ziList.length+" ratio="+ratio+"/>");
				// on détruit [dmg] items
				var destroyed = new List();
				while(dmg > 0 && ziList.length > 0) {
					var zi = ziList.splice(Std.random(ziList.length),1)[0];
					zi.delete();
					var data = XmlData.getTool(zi.toolId);
					destroyed.add(data);
					dmg--;
				}
				logAttack("<destroyed n="+destroyed.length+"/>");
				CityLog.add( CL_Attack, Text.fmt.CL_BankDamaged({list:handler.ToolActions.printList(destroyed), n:destroyed.length}), map );
			} else
				logAttack("<nothing/>");
			logAttack("</bankDamages>");
		}
		
		var guardians = inTownUsers.filter( function (u : User ) { return (u.isCityGuard && !Lambda.has(deadInAttack, u)); } ).array();
		//shuffle to stop the ID organised process which is quite unfair for users
		guardians = guardians.shuffle();
		// bonus de defense
		var defenseBonus = 0;
		for ( g in guardians ) {
			if ( g.hasTool("chkspk", true) ) {
				defenseBonus =  2 * data.Guardians.BASE_DEF;
				g.findTool("chkspk", true).delete();
				break;
			}
		}
		// Plus de zombies, bye bye !
		if( remainingZombies <= 0 ) {
			logAttack("<noMoreZombies/>");
			if( deadInAttack == null || deadInAttack.length <= 0 )
				return null;
			else
				return deadInAttack;
		}
		
		var woundedPeople = new List();
		var terrorizedPeople = new List();
		/*************** VEILLEURS ***************/
		if( MAP.hasMod("GUARDIAN") ) {
			logAttack("<guardianAttack/>");
			var guardiansCount = guardians.length;
			if( guardiansCount <= 0 ) {
				addLog( Text.get.CL_Attack_NoGuardians );
			} else {
				if( guardiansCount == 1 ) {
					addLog( Text.get.CL_Attack_HasGuardiansSingle );
					addLog( Text.fmt.CL_Attack_GuardiansListSingle( { guardianName:guardians.first().name } ));
				} else {
					addLog( Text.fmt.CL_Attack_HasGuardians( { n:guardiansCount } ) );
					addLog( Text.fmt.CL_Attack_GuardiansList( { guardiansName: guardians.map( function(g) return g.name ).array().join(", ") } ));
				}
				//
				var killedZombies = 0;
				//don't forget to work with copy since data is modified for deads
				for( u in guardians.copy() ) {
					var uname = u.print();
					var guardianInfos = u.getGuardianInfo();
					var guardianStats = u.getGuardianStats(MAP);
					//
					var def = guardianInfos.def + defenseBonus;
					if( def < 0 )  def = 0;
					var z = def;
					var zdead = z;
					var chance = Std.random(100);
					var gdead = false;
					var deathProba 	= guardianStats.death;
					var impactProba = guardianStats.impact;
					//
					if(App.DEBUG)
						addLog("[DEBUG] probas:(" + (deathProba + "|" +impactProba) + "%) guards:"+guardiansCount+" "+Std.string(guardianInfos)+"\n");
					//
					if(chance < deathProba) {
						//il est mort ! on considere qu'il a tué tous les zombies, sauf 1, le meurtrier!
						zdead = Math.floor( Math.min( remainingZombies, zdead-1 ) );
						
						if( zdead >= 2 ) 	addLog( Text.fmt.CL_Attack_Death( { name : uname, zombies : zdead } ) );
						else  				addLog( Text.fmt.CL_Attack_Death_Fail( { name : uname } ) );
						
						deadInAttack.add( u );
						guardians.remove( u );// NO REWARD FOR DEAD GUARDIANS
						gdead = true;
					} else if(chance < (impactProba+deathProba)) {
						// Random between TERROR and WOUND
						if(Std.random(2) == 0) {
							addLog( Text.fmt.CL_Attack_WoundedGuardian( { name:uname } ) );
							handler.MessageActions.sendOfficialMessage( u, Text.get.MT_Wounded, Text.fmt.M_Wounded( { z:z } ));
							//on le fait ici, car la fonction qui applique la blessure fait une requete globale
							db.GhostReward.gainByUser( GR.get.wound, u );
							woundedPeople.add( u.id );
						} else {
							addLog( Text.fmt.CL_Attack_TerrorizedGuardian( { name:uname } ) );
							handler.MessageActions.sendOfficialMessage( u, Text.get.MT_Terrorized, Text.fmt.M_Terrorized( { d:def, z:z } ) );
							terrorizedPeople.add( u.id );
						}
					} else if(App.DEBUG) {
						addLog("[DEBUG] "+uname + " a zigouillé " + z + " Zonzons sans difficulté \n");
					}
					// gestion des objets
					for( t in u.getGuardWeapons() ) {
						if( t.soulLocked ) continue;
						if( gdead ) {
							t.delete();
						} else {
							var proba = Std.random(75 - z);
							
							if( t.hasType( ToolType.Food ) ) {
								t.delete();
							} else if( t.action == "waterGun" ) {
								var empty = t.getReplacement();
								while( empty != null && empty.action != null && empty.action == "waterGun" ) {
									empty = empty.getReplacement();
								}
								if( empty != null ) {
									db.Tool.add( empty.toolId, u, t.inBag );
								}
								t.delete();
							} else if( t.broken > 0 ) {
								if ( proba < t.broken  ) {
									
									if( t.hasType(ToolType.Animal) )
										db.GhostReward.gain(GR.get.animal);
									
									var rep = t.getReplacementAt(0);
									if( rep != null ) {
										db.Tool.add( rep.toolId, u, t.inBag );
										t.delete();
									} else { 
										t.isBroken = true;
										t.update();
										db.GhostReward.gain( GR.get.broken, u );
									}
								}
							} else {
								var rep = t.getReplacementAt(0);
								if( rep != null && !t.isReplacementAnUpgrade() && !t.hasType(Refinable) ) {
									db.Tool.add( rep.toolId, u, t.inBag );
								}
								if( t.hasType(ToolType.Animal) )
									db.GhostReward.gain(GR.get.animal, u);
								t.delete();
							}
						}
					}
					
					var killed = Math.floor( Math.min( remainingZombies, zdead ) );
					remainingZombies -= killed;
					killedZombies += killed;
				}
				
				if( woundedPeople.length > 0 ) {
					addLog( Text.get.CL_Attack_SomeWoundedGuardians );
					woundPeople( woundedPeople );
				}
				
				if( terrorizedPeople.length > 0 ) {
					addLog( Text.get.CL_Attack_SomeTerrorizedGuardians );
					Db.execute("UPDATE User SET isTerrorized=1 WHERE id IN("+terrorizedPeople.join( "," )+")");
				}
				// Plus de zombies, bye bye !
				if ( remainingZombies <= 0 ) {
					processGuardians(guardians);
					addLog( Text.get.CL_Attack_GuardianDefAll );
					return if( deadInAttack == null || deadInAttack.length <= 0 ) null else deadInAttack;
				}
				newsInfo.defGuards = killedZombies;
				addLog( Text.fmt.CL_Attack_GuardiansKillZombies( { z:killedZombies } ));
				addLog( Text.fmt.CL_Attack_ZombiesRemainAfterGuardian( { z:remainingZombies } ) );
			}
		}
		
		// on ne tue pas les joueurs déjà morts :)
		var players = inTownUsers.filter( 	function( u : User ) {
												for( d in deadInAttack ) {
													if( d.id == u.id  )
														return false;
												}
												return true;
											} 
										).array();
		
		/*************** EXCEDENT DE POPULATION ***************/
		if( players.length > Const.get.MaxPlayers ) {
			var n = players.length - Const.get.MaxPlayers;
			while( players.length > Const.get.MaxPlayers ) {
				var excess = players.pop();
				if( excess != null ) {
					addLog( Text.fmt.CL_Attack_SurplusUser( { name : excess.print() } ) );
					deadInAttack.add(excess);
				}
			}
			addLogEvent( Text.fmt.CL_Attack_OverPopulation( { n : n } ) );
		}
		var woundedPeople = new List();
		var terrorizedPeople = new List();
		
		/*************** MAISONS DE CITOYENS ***************/
		// répartition
		var attackedPlayers = players.filter( function(u) { return u != null && !u.dead && !u.isDeleted; } );
		var deadsInHouses = 0;
		if ( attackedPlayers.length > 0 ) {
			var houses = Math.max( attackedPlayers.length, 15 );
			// pour eviter les villes immortelles
			// previous mean value was 15. Since some users have been able to get a very hight personnal defense, with few people alive in the city
			// the average of damages by house was too low due to the random spread.
			var coef =  MLib.fmax(1.0, MAP.days / 10);
			var avgDamageByHouse = Std.int(MAP.days * coef);
			var zombiesOnHouses = mt.MLib.min(remainingZombies, Std.int(avgDamageByHouse * houses));
			var repartition = mt.deepnight.Lib.randomSpread(zombiesOnHouses, attackedPlayers.length);
			// sort ASC ( because used with pop() )
			repartition.sort( function( a, b ) return a - b );
			// on mélange pour que ce ne soit pas toujours les mêmes qui soient immunisés
			var attackedPlayers = mt.deepnight.Lib.shuffle(attackedPlayers);
			logAttack("<attackOverflow p='" + attackedPlayers.length + "' repart='" + repartition.join(",") + "' />");
			// on immunise une partie de la population pour limiter l'effet
			// "anéantissement total" lorsqu'il y a débordement de l'attaque
			var immuneRatio =	if( MAP.hasDoorOpened() && MAP.days <= 3 )	0.15
								else if( MAP.days <= 3 )					0.15
								else if( MAP.days <= 5 )					0.15
								else										0;
			
			var immune = Math.floor(immuneRatio * attackedPlayers.length);
			var discardedZombies = remainingZombies - zombiesOnHouses;
			var hasBamba = MAP.hasCityBuilding("bamba");
			logAttack("<attackOverflow immune='" + immune + "' discardedZombies='" +discardedZombies+ "' />");
			for( u in attackedPlayers ) {
				u = db.User.manager.get(u.id, true);
				var z = repartition.pop();
				var def = hashUserDefense.get( u.id );
				if ( immune > 0 ) {
					logAttack("<attackImmune uid='" + u.id + "' zombis='" +z+ "' def='"+def+"' />");
					discardedZombies += z;
					z = 0;
					immune --;
				}
				// on stocke le nombre de zombies qui ont attaqué le joueur
				u.lastZombieAttack = z;
				u.update();
				if( z > 0 ) {
					if( z > def ) {
						// mort
						addLog( Text.fmt.CL_Attack_Death( { name : u.print(), d : def, zombies : z } ) );
						deadInAttack.add( u );
						guardians.remove(u); // NO REWARD FOR DEAD GUARDIANS
						deadsInHouses ++;
					} else {
						// vivant
						var deco = Db.execute("SELECT SUM(decoPoints) FROM Tool WHERE userId="+u.id+" AND isBroken=0 AND inBag=0").getIntResult(0);
						var chanceTerror =	100
											- (deco > 25 ? 10 : deco) // déco maison
											- (u.hasDoneAction("cleanUp") ? 5 : 0) // rangement maison
											- (db.Tool.manager.hasTool(XmlData.getToolByKey("suit").id, u) ? 3 : 0) // tenue de citoyen lavée
											- (u.hasDoneAction("showers") ? 10 : 0) // douche (chantier rare)
											- (u.hasTool("quies", false, false ) ? 10 : 0);// boules quièsn
						
						if( u.hasTool("hifim", false, false) || (Std.random(100) < chanceTerror && !hasBamba) ) {
							// terrorisé
							handler.MessageActions.sendOfficialMessage( u, Text.get.MT_Terrorized, Text.fmt.M_Terrorized( { d:def, z:z } ) );
							terrorizedPeople.add( u.id );
						} else {
							// non-terrorisé
							handler.MessageActions.sendOfficialMessage( u, Text.get.MT_TerrorDodged, Text.fmt.M_TerrorDodged( { d:def, z:z } ) );
						}
					}
				}
			}
			if( discardedZombies > 1 )
				addLog( Text.fmt.CL_Attack_ZombiesDiscarded( { n : discardedZombies } ) );
		}
		logAttack("<userAttack attacked='"+attackedPlayers.length+"' deadsInHouses='"+deadsInHouses+"'/>");
		
		/*************** FIN ***************/
		processGuardians(guardians);
		
		logAttack("<totalKilled v='"+deadInAttack.length+"'/>" );
		logAttack("<terrorizedPeople v='"+terrorizedPeople.length+"'/>" );
		if( deadInAttack.length == 0 ) {
			if( MAP.devastated )
				addLog( Text.get.CL_Attack_NoDeathDevastated );
			else
				addLog( Text.get.CL_Attack_NoDeath );
		} else {
			if( deadInAttack.length == 1 )
				addLog( Text.get.CL_Attack_SingleDeath );
			else
				addLog( Text.fmt.CL_Attack_Deaths({n:deadInAttack.length}) );
		}
		newsInfo.terrorizeds = terrorizedPeople.length;
		
		/*************** MORT ULTIME ***************/
		if( deadInAttack.length == inTownUsers.length ) {
			logAttack("<deadTown/>");
			if( MATURE_MAP && !MAP.devastated )
				giveLastRewards(deadInAttack);
			else
				logAttack("<noLastGroupReward/>");
			if( deadInAttack.length == allUsers.length )
				closeMap();
			return deadInAttack;
		}
		// on distribue la terreur
		var remaining = allUsers.length - deadInAttack.length;
		if( remaining > 0 && terrorizedPeople.length > 0 ) {
			Db.execute("UPDATE User SET isTerrorized=1 WHERE id IN("+terrorizedPeople.join( "," )+")");
		}
		// on donne les blessures aux bléssés
		if( remaining > 0 && woundedPeople.length > 0 ) {
			woundPeople( woundedPeople );
		}

		return deadInAttack;
	}

	
	private static function processGuardians( guardians:Array<User> ) {
		// rewards des guardiens survivants
		if( guardians.length > 0 ) {
			var guids = guardians.map( function(g) return g.id );
			Db.execute(	"INSERT INTO GhostReward (rewardKey,userId,day,value) "
					+	"SELECT "+Db.quote(Std.string(GR.get.guard.ikey) )+", id, 0, 1 FROM User "
					+	"WHERE id IN (" + guids.join( ", " ) +") ON DUPLICATE KEY UPDATE value = value + 1" );
			
			var sql = 	"INSERT INTO UserVar (userId, name, value, persistOnDeath) "
					+	"SELECT id," + Db.quote("guards".toLowerCase())+", 2, 1 FROM User WHERE id IN("+guids.join( ", " )+") "
					+	"ON DUPLICATE KEY UPDATE UserVar.value = UserVar.value + 2";
			Db.execute(sql);
			logAttack("<sql id='guardians'>" + sql + "</sql>");
		}
	}
	
	private static function woundPeople( woundedPeoples : List<Int> ) {
		var a = new Array();
		for( i in 0...100 ) {
			a.push( Std.random( Type.getEnumConstructs( WoundType ).length )  );
		}
		logAttack("<woundGuards v='" + woundedPeoples.length + "'/>");
		//-1 PA because of wound
		Db.execute( "UPDATE User SET pa=GREATEST(0,LEAST(pa,"+(Const.get.PA-1)+")), isWounded=1, woundType=" + a[Std.random( a.length )] + " WHERE id IN("+woundedPeoples.join(",")+")");
	}

	private static function attackPlayer( zp : Cadaver, ulist:List<User>, alreadyDead : IntHash<User>) {
		var uarr = new Array();
		for( u in ulist )
			if( !alreadyDead.exists(u.id) )
				uarr.push(u);
		
		if( uarr.length == 0 )
			return null;
		
		var ap = uarr[Std.random(uarr.length)];
		logAttack("<killPlayer uid='"+ap.id+"'/>");
		alreadyDead.set( ap.id, ap );
		CityLog.add( CL_Attack, Text.fmt.CL_Attack_PlayerZombie_KilledCitizen( { name:zp.print(), p:ap.print() } ), MAP );
		return ap;
	}

	private static function addLog( text ) {
		CityLog.add( CL_Attack, text, MAP );
	}

	private static function addLogEvent( text ) {
		CityLog.add( CL_AttackEvent, text, MAP );
	}
	
	public static function giveLastRewards(deadsList:List<User>) {
		if( deadsList == null || deadsList.length == 0 ) return;
		var deads = Lambda.array(deadsList);
		giveRewardToLastGroup( Lambda.map( deads, function(u : User) { return u.id; } ) );
		giveRewardToLastOne( deads[Std.random( deads.length )] );
	}

	static function giveRewardToLastOne(user:User) {
		if( user == null ) {
			logAttack("<noRewardForLastOne uid='null'/>");
			return;
		}
		logAttack( user.ultimateDeath(MAP) );
	}

	static function giveRewardToLastGroup( ids : List<Int>) {
		if( ids != null && ids.length > 0 ) {
			logAttack( "<giveRewardToLastGroup>" + ids.join( "," ) + "</giveRewardToLastGroup>");
			Db.execute("INSERT INTO GhostReward ( rewardKey,userId,day,value ) "+
						"SELECT "+Db.quote(Std.string(GR.get.surgrp.ikey) )+",id,0,1 FROM User "+
						"WHERE id IN (" + ids.join( "," ) +") "+
						"ON DUPLICATE KEY UPDATE value=value+1" );
		}
	}

	public static function closeMap() {
		logAttack("<flagMapForDeletion/>");
		MAP.status = Type.enumIndex( EndGame );
		MAP.update();
	}
	
	static function logAttack( msg : String ) {
		LOG( MAP, msg );
	}

	static function flagViolentCadavers(list:List<Int>) {
		logAttack("<flagViolentCadavers n="+list.length+"/>");
		Db.execute("UPDATE Cadaver SET attackedCity=1 WHERE id IN ("+list.join(",")+")");
	}
}
