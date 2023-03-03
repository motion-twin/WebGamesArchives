package handler;
import db.Cadaver;
import db.Zone;
import db.ZoneAction;
import db.ZoneItem;
import db.Tool;
import db.GatheredObject;
import db.Complaint;
import db.CityLog;
import db.User;
import db.GhostReward;
import Common;


//*
// A la fin de chaque méthode, appeler go(defaultURL,tool)
// Si la requête http en cours contient une url dans son paramètre "from"
// elle bypassera automatiquement defaultURL
// La variable tool permet de locker l'action pour la zone si one peut l'effectuer qu'une seule fois

class ToolActions extends Handler<Tool>{

	private var toolActions : Hash<Tool->Void>;
	private var fl_lostCamo : Bool;

	public function new() {
		super();
		fl_lostCamo = false;

		toolActions = new Hash();

		inTown( "borrow", doBorrow );
		inTown( "borrowCadaver", doBorrowCadaver );
		inTown( "addToBag", object(  owner( doAddToBag ) , true ) );

		outside( "grabItem", doGrabItem );
		ingame( "grabHeroItem", doGrabHeroItem );

		ingame( "removeFromBag",	object(  owner( doRemoveFromBag ) , true ) );
		ingame( "emptyBag", 		doEmptyBag );
		ingame( "use",				object( owner( doUse ), true ) );

		ingame( "remoteDrop",		doRemoteDrop );
		ingame( "remoteGrab",		doRemoteGrab );
		ingame( "remoteEat",		doRemoteEat );
		ingame( "remoteDrink",		doRemoteDrink );

		toolActions.set( "drink", doDrink );
		toolActions.set( "eat", doEat );
		toolActions.set( "useDrug", doUseDrug );
		toolActions.set( "batGun", doBatGun);
		toolActions.set( "batGunUp", doBatGunUp);
		toolActions.set( "waterGun", doWaterGun);
		toolActions.set( "laserGun", doLaserGun);
		
		toolActions.set( "jerryGun", doJerryGun);
		toolActions.set( "open", doOpen) ;
		toolActions.set( "openMulti", doOpenMulti) ;
		toolActions.set( "grenade", doGrenade);
		toolActions.set( "pet", doPet);
		toolActions.set( "combatHit", doCombatHit);
		toolActions.set( "alcohol", doAlcohol);
		toolActions.set( "cider", doCider);
		toolActions.set( "coffee", doCoffee);
		toolActions.set( "rest", doRest);
		toolActions.set( "heal", doHeal);
		toolActions.set( "purifyWater", doPurifyWater);
//		toolActions.set( "purifier", doPurifier);
		toolActions.set( "playGolf", doPlayGolf );
		toolActions.set( "assemble", doAssemble );
		toolActions.set( "assembleOne", doAssembleOne );
		toolActions.set( "assembleIdenticals", doAssembleIdenticals );
		toolActions.set( "switch", doSwitch);
		toolActions.set( "radius", doRadius );
		toolActions.set( "flare", doFlare );
		toolActions.set( "calm", doCalm );
		toolActions.set( "makeCoffee", doMakeCoffee );
		toolActions.set( "vibro", doVibro );
		toolActions.set( "useWaterDrug", doUseWaterDrug  );
		toolActions.set( "repair", doRepair );
		toolActions.set( "violentRegen", doViolentRegen  );
		toolActions.set( "roll", doRoll );
		toolActions.set( "randomDrug", doRandomDrug);
		toolActions.set( "disinfect", doDisinfect);
		toolActions.set( "dig", doDig);
		toolActions.set( "drawCard", doDrawCard);
		toolActions.set( "book", doBook );
		toolActions.set( "genBook", doGenBook );
		toolActions.set( "flash", doFlash );
		toolActions.set( "hug", doHug );
		toolActions.set( "upgradeChest", doUpgradeChest );
		toolActions.set( "upgradeDef", doUpgradeDef );
		toolActions.set( "smoke", doSmoke );
		toolActions.set( "poison", doPoison );
		toolActions.set( "putOutsideDef", doPutOutsideDef );
		toolActions.set( "openSafe", doOpenSafe );
		toolActions.set( "useWaterCan", doUseWaterCan );
		toolActions.set( "beta", doBeta );
		toolActions.set( "hunt", doHunt );
		toolActions.set( "readBannedNote", doReadBannedNote );
		toolActions.set( "infect", doInfect );
		toolActions.set( "terror", doTerror );
		toolActions.set( "huntRegen", doHuntRegen );
		toolActions.set( "tamedPet", doTamedPet );
		toolActions.set( "unlockBuilding", doUnlockBuilding );
		toolActions.set( "smokeBomb", doSmokeBomb);
		toolActions.set( "throwBall", doThrowBall);
		toolActions.set( "uselessDrink", doUselessDrink);
		toolActions.set( "getBuildingPlan", doGetBuildingPlan);

		toolActions.set( "getChristmasStory", doGetChristmasStory );
		toolActions.set( "eatChristmasCandy", doEatChristmasCandy );
		
		toolActions.set( "cancelGhoul", doCancelGhoul );
		
		toolActions.set( "angrycat", doAngryCat );
		toolActions.set( "guitar", doPlayGuitar );
		
		toolActions.set("oldmagic", doOldMagic);
		toolActions.set("magic", doMagicProtection);
		toolActions.set("purifySoul", doPurifySoul);
		toolActions.set("decorateCity", doDecorateCity);
	}

	override function findObject( id , lock  ) {
		var t = Tool.manager.get( id, lock );
		if( t != null ) return t;
		return null;
	}

	override function isOwner( t : Tool ) : Bool {
        return t.userId== App.user.id;
    }

	function getZombiesCount() {
		var user = App.user;
		var zone = user.zone;
		return (user.inExplo() ) ? zone.explo.getZombies() : zone.zombies;
	}
	
	public function doUse( tool : Tool ) {
		var user = App.user;
		if( user.wasRescued ) { // cas du joueur sauvé par un héros :)
			user.wasRescued = false;
			user.update();
			notify( Text.get.RescuedByAHero );
			App.goto("city/enter");
			return;
		}

		if( user.hasLeader() ) {
			fail( Text.get.ForbiddenInEscort );
			return;
		}

		if( tool.userId!=user.id ) {
			fail(Text.get.Forbidden);
			return;
		}

		if( !toolActions.exists( tool.action ) ) {
			App.goto( getOutsideURL() );
			return;
		}

		if( !terrorCheck(tool, user) )
			return;

		if( tool.isBroken ) {
			fail(Text.get.Broken);
			return;
		}

		if( user.isCamping() ) {
			fail(Text.get.ForbiddenWhenCamping);
			return;
		}

		if( tool.hero && !App.user.hero ) {
			fail(Text.get.HeroOnly);
			return;
		}

		if( App.user.isOutside && !tool.inBag ) {
			fail(Text.get.Forbidden);
			return;
		}

		if( tool.limit != "" && tool.limit != null ) {
			if( !user.isOutside && tool.hasLimit( "outer" ) ) {
				fail(Text.get.OuterLimited);
				return;
			}
			if( user.isOutside && tool.hasLimit( "town" ) ){
				fail(Text.get.TownLimited);
				return;
			}
		}

		var url = "tool/"+tool.id+"/use";

		if( tool.lock == "day" && ZoneAction.manager.hasDoneAction(App.user, tool.action) ) {
			App.goto( if( App.request.exists("from")) url + "?from=" + App.request.get("from") else url );
			return;
		}

		if( tool.lock == "zone" && ZoneAction.manager.hasDoneActionZone( App.user, tool.action ) ) {
			App.goto( if( App.request.exists("from")) url + "?from=" + App.request.get("from") else url );
			return;
		}

		if( tool.action != "" ) {
			fl_lostCamo = false;
			if( App.user.isOutside && !App.user.inExplo() && !tool.isStealthy() )
				fl_lostCamo = App.user.loseCamo();
			toolActions.get(tool.action)( tool );
		}
	}

    function terrorCheck(t:Tool,user:User) {
		if( !t.hasType(Drug) && user.isOutside && user.isTerrorized ) {
			var zone = user.getZoneForDisplay();
			if( zone.zombies>zone.humans ) {
				if( user==App.user )
					fail(Text.get.CantActInTerror);
				else
					fail(Text.get.PetCantActInTerror);
				return false;
			}
		}
		return true;
    }
	
	function handCheck(t:Tool) {
		if( App.user.hasWound( W_Hand ) ) {
			fail( Text.fmt.WoundedItemBlocked({tool:t.print()}) );
			return true;
		}
		return false;
	}

	public static function canTakeObject( ?user:db.User, t: Tool, ?quiet:Bool ) {
		if( user == null ) user = App.user;

		if( t == null )
			return false;

		if( t.soulLocked )
			return false;

		// Cas 1 -  on a déjà un objet lourd, donc on ne peut pas ajouter un autre
		var tools = user.getInBagTools(false);

		if( t.isHeavy )
			for( tt in tools )
				if( tt.isHeavy ) {
					if( !quiet ) App.notification = Text.get.AddOnlyOneHeavyObject;
					return false;
				}

		if( t.hasType(Bag) ) {
			var fl_pockFound = false;
			for( tt in tools ) {
				if( tt.hasType(Bag) && tt.key!="pocketBelt" && t.key!="pocketBelt" ) {
					if(!quiet) App.notification = Text.get.AddOnlyOneBag;
					return false;
				}
				if( tt.key=="pocketBelt" )
					fl_pockFound = true;
			}
			if( t.key=="pocketBelt" && fl_pockFound ) {
				if( !quiet )
					App.notification = Text.get.AddOnlyOnePocketBelt;
				return false;
			}
		}

		if( t.hasType(Special) ) {
			for( tt in tools ) {
				if( tt.hasType(Special) && !user.isShaman/*user.hasThisJob("shaman")*/ ) {
					if(!quiet) App.notification = Text.get.AddOnlyOneSpecial;
					return false;
				}
			}
		}

		return true;
	}

	private function success(?t:Tool,?url:String) {
		if( url == null )
			url = getOutsideURL();
		if( App.request.exists("expand") )
			url += "?expand=" + App.request.getInt("expand");
			
		if( fl_lostCamo ) appendNotify(Text.get.LostCamo);
		
		go(url, t);
	}

	private function fail(?txt:String,?url:String,?t:Tool) {
		if( txt != null ) notify(txt);
		if( url == null )
			url = getOutsideURL();
		if( App.request.exists("expand") )
			url += "?expand="+App.request.getInt("expand");
		if( fl_lostCamo )
			App.user.getCamo();
		go(url, t);
	}

	private function go( url : String, ?t: Tool ) {

		if( t != null && (t.lock != "" || t.lock != null) && t.action != null )
			ZoneAction.add( App.user, t.action );

		if( App.request.exists( "from" ) ) {
			App.goto( App.request.get("from") );
			return;
		}

		if( !App.session.mobile )
			App.goto( url );
	}

	private function printZombies(n:Int) {
		var str = "<strong>"+n+" ";
		if(n>1) {
			str+=Text.get.ZombiePlural;
		}
		else {
			str+=Text.get.ZombieSingular;
		}
		str+="</strong>";
		return str;
	}

	/*** INVENTORY MOVEMENTS ***/

	public function doEmptyBag() { // drops everything
		emptyBag(App.user);
	}


	function emptyBag(user:User) {
		var map = user.map;
		var city = map._getCity();
		
		if ( !user.inTown() && user.zoneId == city.id ) {
			fail(Text.get.ExploCantDoAction);
			return;
		}
		
		if( !user.isOutside ) {
			var limit = user.getTrunkCapacity() - Tool.manager.countTools(user,false);
			var delayed = new List();
			for( t in user.getInBagTools(true) ) {
				if( t.soulLocked ) continue;
				if( limit>0 ) {
					if( t.hasType(Bag) ) {
						delayed.push(t);
						continue;
					}
					t.inBag=false;
					t.update();
					limit--;
				}
			}
			for( t in delayed ) {
				if( limit>0 ) {
					t.inBag = false;
					t.update();
					limit--;
				}
			}
			notify(Text.get.EmptiedBagInChest);
			success("home");
			return;
		} else {
			var fl_reboot = false;
			var oldScore = user.getControlScore();
			for( t in user.getInBagTools(true) ) {
				if( t.soulLocked ) continue;
				if( t.hasType(Radar) ) fl_reboot = true;
				var m = db.Map.manager.get( user.mapId, false ); // On évite de locker la ressource
				if( user.inExplo() ) {
					CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDropped( { name:user.print(), tool:t.print() } ), m, user.zone );//TODO faire un message spécifique pour l'exploration
					db.ExploItem.create( user.zone.explo, t.toolId, t.isBroken );
				} else {
					CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDropped( { name:user.print(), tool:t.print() } ), m, user.zone );
					ZoneItem.create( user.zone, t.toolId, t.isBroken );
				}
				t.delete();
			}
	
			var newScore = user.getControlScore();
			if( newScore != oldScore )
				OutsideActions.updateZoneControl( user.zone, newScore - oldScore, user.map );

			if( fl_reboot ) {
				success(getOutsideURL());
				return;
			}

			success();
		}
	}

	public function doAddToBag( t: Tool ) { // inv to bag
		if( !App.user.hasCapacity() ) {
			go("home");
			return;
		}
		if( !canTakeObject( t ) ) {
			go("home");
			return;
		}
		t.inBag = true;
		t.update();
		go("home");
	}

	public function doGrabItem() { // zone to bag
		var user = App.user;
		var toolId = tools.Utils.decodeToolId( App.request.getInt("id"), App.request.getInt("k") );
		var xmlTool = XmlData.getTool( toolId );
		
		if( App.user.isCamping() ) {
			fail(Text.get.ForbiddenWhenCamping);
			return;
		}
		
		if( xmlTool == null )
			return;
		
		grabItem(xmlTool, App.request.getBool("b"), App.request.getBool("v"), user);
	}

	public function doRemoteGrab() {
		if( !db.GameMod.hasMod("FOLLOW_FULL") ) return;
		var pet = db.User.manager.get( App.request.getInt("uid") );
		var tid = tools.Utils.decodeToolId( App.request.getInt( "id" ) );
		var xmlTool = XmlData.getTool( tid );
		
		if( pet == null || xmlTool == null || !pet.isFollower(App.user) )
			return;
		
		if( !pet.fullEscortMode )
			return;
		
		if( pet.zoneId == pet.getMapForDisplay().cityId )
			return;
		
		grabItem(xmlTool, App.request.getBool("b"), App.request.getBool("v"), pet);
	}

	function grabItem(xmlTool:Tool, br:Bool, vis:Bool, user:User) {
		if( xmlTool == null )
			return;
		
		if( user.isOutside && user.zoneId == user.map.cityId ) {
			App.goto(getOutsideURL());
			return;
		}
		if( !user.hasCapacity() ) {
			fail(Text.get.NoRoom);
			return;
		}
		if( !user.hasCapacity() || !canTakeObject( user, xmlTool ) ) {
			fail(Text.get.NoRoom);
			return;
		}
		var map = user.getMapForDisplay();
		var zone = user.getZoneForDisplay();
		var inExplo = user.inExplo();
		var msg;
		var t : Tool;
		if( !inExplo ) {
			var item = ZoneItem.manager._getByToolId( user.zone, xmlTool.toolId, br, vis );
			if( item == null || item.count == 0 ) {
				fail(Text.get.ItemNotFound);
				return;
			}
			if( !item.visible && !user.canDoBannedAction() ) {
				return;
			}
			
			if ( !user.isShaman && xmlTool.key == "red_soul") {
				if ( !user.magicProtection ) {
					//oups, il est mort !
					//TODO laisser le choix au joueur, mourrir ou devenir une goule ?? 
					user.haunt();
				} else {
					notify(Text.get.GrabSoulAndSurvive);
				}
			}
			
			t = Tool.add( xmlTool.toolId, user, true );
			t.isBroken = item.isBroken;
			t.update();
			item.delete();
			msg = Text.fmt.OutsideTaken( { name:user.print(), tool:t.print() } );
			if( !item.visible )
				if( db.Zone.manager.countUnbannedPlayers(zone) == 0 )
					msg = Text.fmt.OutsideTaken( {name:user.print(), tool:t.print()} );
			// On met à jour les informations de contrôle de la zone
			if( user.isOutside && t.hasType( Control ) && !user.isTerrorized )
				OutsideActions.updateZoneControl( user.zone, Std.int(t.power), map );
		} else {
			var item = db.ExploItem.manager._getByToolId( user.zone.explo, xmlTool.toolId, br );
			if( item == null || item.count == 0 ) {
				fail(Text.get.ItemNotFound);
				return;
			}
			t = Tool.add( xmlTool.toolId, user, true );
			t.isBroken = item.isBroken;
			t.update();
			item.delete();
			msg = Text.fmt.OutsideTaken( { name:user.print(), tool:t.print() } );
		}
		
		//TODO : specific message for tool found in exploration ?
		CityLog.addToZone( CL_OutsideTempEvent, msg, map, zone );
		
		if( user.loseCamo() )
			appendNotify(Text.get.LostCamo);
		
		if( t.getInfo().hasType(Radar) )
			success(getOutsideURL());
		else
			success();
	}

	public function doRemoveFromBag( t: Tool ) { // drops one inbag tool
		if( App.user.isCamping() ) {
			fail(Text.get.ForbiddenWhenCamping);
			return;
		}
		removeFromBag(t, App.user);
	}

	function removeFromBag(t:Tool, user:User) {
		if( t.soulLocked ) {
			fail(Text.get.CantDropSoulLocked, if(!user.isOutside) "home" else "" );
			return;
		}
		if( t.hasType(Bag) ) {
			emptyBag(user);
			return;
		}
		if( t.userId != user.id )
			return;

		if( user.isOutside ) {
			var inExplo = user.inExplo();
			if( !t.inBag )
				return;
			
			var map = user.getMapForDisplay();
			if( user.zone.id == map.cityId )
				return;
			
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDropped( {name:user.print(), tool:t.print()} ), map, user.zone );
			if( inExplo )
				db.ExploItem.create( user.getZoneForDisplay().explo, t.toolId, t.isBroken );
			else
				ZoneItem.create( user.getZoneForDisplay(), t.toolId, t.isBroken );
			
			user.update();
			// On met à jour les informations de contrôle de la zone
			if( !inExplo && user.isOutside && t.hasType( Control ) && !user.isTerrorized )
				OutsideActions.updateZoneControl( user.zone, Std.int(-t.power), map );
	
			t.delete();

			if( t.hasType(Radar) ) {
				success(getOutsideURL());
				return;
			}
			if( user.loseCamo() )
				appendNotify(Text.get.LostCamo);
			
			success();
		} else {
			// en ville
			if( !user.hasTrunkCapacity() ) {
				notify(Text.get.NoRoomInTrunk);
				go("home");
				return;
			}

			if( t.hasType(Furniture) && user.isNoob )
				notify(Text.get.FurnitureTutorial);
	
			t.inBag = false;
			t.update();
			go("home");
		}
	}

	public function doRemoteDrop() {

		if( !App.user.map.hasMod("FOLLOW_FULL") ) return;

		var pet = db.User.manager.get( App.request.getInt("uid") );
		var tool = db.Tool.manager.get( App.request.getInt("tid") );
		
		if( pet == null || tool == null || !pet.isFollower(App.user) )
			return;
		
		if( !pet.fullEscortMode )
			return;

		if( tool.action == "genBook" || tool.key == "postal_box" || tool.hasType(Beverage) || tool.hasType(BookBox) || tool.hasType(Bag) || tool.hasType(Weapon) && tool.hasType(Critical) || tool.hasType(Tasty) ) {
			fail( Text.fmt.PetWantToKeepThat({tool:tool.print()}) );
			return;
		}

		if( pet.zoneId == pet.getMapForDisplay().cityId )
			return;

		removeFromBag(tool,pet);
	}

	public function doBorrowCadaver() {
		var url = "city/seeCadaver?id=" + App.request.get("uid");
		var user = App.user;
		var uid = App.request.getInt("uid");
		var clint = Cadaver.manager.get( uid );
		if( clint == null) {
			go("city/co", null);
			return;
		}
		
		if( clint.mapId != App.user.mapId ) {
			fail( Text.get.Forbidden, url+"&theft=1" );
			return;
		}
		
		if( user.hasStolen ) {
			fail(Text.get.AlreadyStolen,url);
			return;
		}
		
		if( !user.hasTrunkCapacity() ) {
			fail( Text.get.NoRoomInTrunk, url+"&theft=1" );
			return;
		}

		var ctool = db.CadaverRemains.manager.get( App.request.getInt("id") );
		if( ctool == null) {
			fail( Text.get.Forbidden, url+"&theft=1" );
			return;
		}

		if( ctool.cadaverId != clint.id ) {
			fail( Text.get.Forbidden, url+"&theft=1" );
			return;
		}

		/* Test pour le sac, pas intéressant ici
		if( !canTakeObject( XmlData.getTool( ctool.toolId ) ) ){
			fail( Text.get.NoRoom, url+"&theft=1" );
			return;
		}*/
		
		// ajout de l'objet
		var tool = db.Tool.add( ctool.toolId, user, false );
		tool.isBroken = ctool.isBroken;
		tool.update();
		ctool.delete();
		
		if( !user.map.chaos && !user.hasTool("cm_suit",true) )
			user.hasStolen = true;
			
		if( !user.map.chaos && !user.hasTool("stp_suit",true) )
			user.hasStolen = true;
		
		GhostReward.gain( GR.get.plundr, user, 1 );
		var m = db.Map.manager.get( user.mapId, false ); // On évite de locker la ressource
		CityLog.add( CL_Thief, Text.fmt.CL_Plunder({name:user.print(), tool:tool.print(), victim:clint.print()} ), m, user );
		notify( Text.fmt.Plundered({tool:tool.print(),name:clint.print()}) );
		appendNotify(Text.get.InChest);
		
		user.update();
		success("city/seeCadaver?id=" + App.request.get("uid"));
	}


	public function doBorrow() { // theft
		var url = "city/seeClint?id=" + App.request.get("uid");
		var user = App.user;
		var uid = App.request.getInt("uid");
		var clint = User.manager.get( uid );
		if( clint.dead || clint == null) {
			go("city/enter");
			return;
		}
		if( !user.playsWithMe(clint) ) {
			fail(Text.get.Forbidden);
			return;
		}
		if( user.hasStolen ) {
			fail(Text.get.AlreadyStolenToday,url);
			return;
		}
		if( !user.hasCapacity() ) {
			fail( Text.get.NoRoom, url+"&theft=1" );
			return;
		}
		var item = Tool.manager.get( App.request.getInt("id") );
		if( item == null ) {
			fail(Text.get.ItemDisappeared,url);
			return;
		}
		if( !canTakeObject( item ) ){
			fail( Text.get.NoRoom, url+"&theft=1" );
			return;
		}
		if( !clint.canBeStolen() ) {
			fail(Text.fmt.CannotSteal({item:item.print()}),url);
			return;
		}
		if( item.userId == user.id ) {
			fail(Text.fmt.CannotStealMine({item:item.print()}),url);
			return;
		}
		if( item.userId != uid ) {
			fail( Text.get.AlreadyStolen, url );
			return;
		}
		if( ZoneAction.manager.hasDoneAction(user, "sentItem_"+clint.id) ) {
			fail( Text.get.SendStealProtection1, url );
			return;
		}
		if( ZoneAction.manager.countAction(user, "sentItem") >= Const.get.SendStealLimit ) {
			fail( Text.get.SendStealProtection2, url );
			return;
		}
		
		MessageActions.sendOfficialMessage( item.user, Text.get.YouGotRobbed, Text.fmt.GotRobbed({tool:item.print()}) );
		item.user = user;
		item.inBag = true;
		item.update();
		if( !user.map.chaos && !user.hasTool("cm_suit", true) )
			user.hasStolen = true;
		
		if( !user.map.chaos && !user.hasTool("stp_suit", true) )
			user.hasStolen = true;
		
		var detected = Std.random(100) <= Const.get.TheftDetection;
		var inChest = clint.getChestTools(false);
		var bomb = null;
		Lambda.iter(inChest, function(t) { if ( t.key == "trapmat" ) bomb = t; } );
		if ( bomb != null ) {
			var bomb = Tool.manager.get(bomb.id, true);
			if ( user.isWounded ) {
				//on le kill
				user.die( DT_Exploded );
				appendNotify(Text.get.YouDiedBadThief);
				return;
			} else {
				user.wound(false);
				appendNotify(Text.get.YouWoundedBadThief);
				detected = true;
			}
			bomb.delete();
		}
		
		if( user.hasTool("cm_suit", true) ) {
			// tenue du père noël
			CityLog.add( CL_Thief, Text.fmt.CL_Thief({name:Text.get.SantaClaus, item:item.print(), victim:clint.print()} ), clint.getMapForDisplay(), clint );
			appendNotify( Text.fmt.TheftChristmas({tool:item.print(),name:clint.print()}) );
			GhostReward.gain( GR.get.santac, user, 1 );
		} else if( user.hasTool("stp_suit",true) ) {
			// tenue du leprechaun pour la stpatrick
			CityLog.add( CL_Thief, Text.fmt.CL_Thief({name:Text.get.Leprechaun, item:item.print(), victim:clint.print()} ), clint.getMapForDisplay(), clint );
			appendNotify( Text.fmt.TheftLeprechaun({tool:item.print(),name:clint.print()}) );
			GhostReward.gain( GR.get.lepre, user, 1 );
		} else {
			GhostReward.gain( GR.get.theft );
			if( detected ) {
				// détecté !
				CityLog.add( CL_Thief, Text.fmt.CL_Thief({name:user.print(), item:item.print(), victim:clint.print()} ), user.getMapForDisplay(), user );
				appendNotify( Text.fmt.TheftDetected({tool:item.print(),name:clint.print()}) );
			} else {
				// pas vu...
				appendNotify( Text.fmt.TheftUnseen({tool:item.print(),name:clint.print()}) );
			}
		}
		user.update();
		success("city/seeClint?id=" + App.request.get("uid"));
	}

	public function doGrabHeroItem() {
		var url = if( App.user.isOutside ) getOutsideURL() else "home";
		if( !App.user.hero ) {
			fail(Text.get.NowYouWishedYouWereAHero,"hero");
			return;
		}
		if( App.user.isCamping() )
			return;
		if( App.user.isOutside && App.user.hasLeader() ) {
			fail( Text.get.ForbiddenInEscort );
			return;
		}
		if( App.user.usedHeroLuck ) {
			fail(Text.get.HeroAlreadyBeenLucky,url);
			return;
		}
		if( App.user.hasDoneDailyHeroAction ) {
			fail(Text.get.HeroTired,url);
			return;
		}
		var heroItems = App.user.getHeroItems();
		var tid = App.request.getInt( "id" );
		var ok = false;
		for( ht in heroItems )
			if( ht.toolId == tid )
				ok = true;
		if( !ok ) {
			fail(Text.get.UnkownHeroItem,url);
			return;
		}
		var xmlTool = XmlData.getTool( tid );
		if( xmlTool == null ) {
			// Ne devrait jamais arriver :)
			fail(Text.get.UnkownHeroItem);
			return;
		}
		var user = App.user;
		user.usedHeroLuck = true;
		user.hasDoneDailyHeroAction = true;
		db.GhostReward.gain(GR.get.heroac);
		user.update();

		if( App.user.isOutside )
			notify(Text.fmt.HeroLuck( {o:xmlTool.print()}));
		else
			notify(Text.fmt.HeroLuckInTown( {o:xmlTool.print()}));

		if( App.user.hasCapacity() && canTakeObject(xmlTool) )
			Tool.add(tid, App.user, true);
		else
			if( App.user.isOutside ) {
				// dehors
				if( App.user.inExplo() ) {
					db.ExploItem.create( App.user.zone.explo, tid );
					//TODO specific message for exploration ?
					CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDropped( { name:user.print(), tool:xmlTool.print() } ), user.getMapForDisplay(), user.getZoneForDisplay() );
				} else {
					ZoneItem.create( App.user.zone, tid );
					CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDropped( { name:user.print(), tool:xmlTool.print() } ), user.getMapForDisplay(), user.getZoneForDisplay() );
				}
				appendNotify(Text.get.NoRoomDrop);
			} else {
				// en ville
				Tool.add(tid, App.user, false);
			}
		success(url);
	}

	private function getUsedWith(?base:Tool, u:User) {
		var t = Tool.manager.get( App.request.getInt("useWith") );
		if( t == null || t.userId != u.id || t.soulLocked )
			return null;
		else {
			if( base != null ) {
				var fl_match = false;
				for( pkey in base.parts )
					if( pkey == t.key )
						fl_match = true;
				return
					if( fl_match ) t else null;
			} else
				return t;
		}
	}


	private function gainFoodReward(t:Tool, user:User) {
		if( t.hasType(HumanMeat) )
			GhostReward.gain( GR.get.cannib, user );
	}


	/*** ITEMS IMPLEMENTATION ***/

	static public function printList(list:List<Tool>, ?linkWord:String) {
		if( linkWord == null ) linkWord = Text.get.And;
		var groupedList : List<{tool:Tool, count:Int}> = new List();
		for( t in list ) {
			var found = null;
			for( gt in groupedList ) {
				if( t.toolId == gt.tool.toolId && t.isBroken == gt.tool.isBroken ) {
					found = gt;
					break;
				}
			}
			if( found != null ) {
				found.count++;
			} else {
				groupedList.add( {tool:t, count:1} );
			}
		}
		var i = 0;
		var str = "";
		for( gt in groupedList ) {
			var name = gt.tool.print() + (if(gt.count > 1) "<strong>x"+gt.count+"</strong>" else "");
			if( i == 0 ) {
				str += name;
			} else {
				if( i == list.length-1 ) {
					str += linkWord + name;
				} else {
					str += ", "+name;
				}
			}
			i++;
		}
		return str;
	}

	function consume( kind, req:Int, proba:Int, ?anyInv:Bool ) {
		if( req == 0 )
			return true;
		var list = App.user.getToolsByType(kind, false, Fake).filter( function(tool) { return !tool.isBroken && (tool.inBag==true || anyInv==true); } );
		if( list.length < req ) {
			switch(kind) {
			case Battery: fail( Text.get.NeedBattery );
			case Beverage: fail( Text.get.NeedWater );
			case Jerrycan: fail( Text.get.NeedRawWater );
			case ZombiePart: fail( Text.get.NeedZombiePart );
			default:
				fail(Text.get.UnknownError);
			}
			return false;
		}
		var fl_cons = Std.random(100) < proba;
		for( t in list ) {
			if( fl_cons ) {
				if( t.hasType(Beverage) && t.replacement != null && t.replacement.length > 0 ) {
					Tool.add( XmlData.getToolByKey(t.replacement[0]).toolId, App.user, t.inBag );
				}
				t.delete();
				req --;
				if( req <= 0 ) break;
			}
		}
		return true;
	}

	function killZombies(t:Tool, n:Float = 0) {
		var zone = App.user.zone;
		var explo = zone.explo;
		var inExplo = App.user.inExplo();
		// on le lock l'exploration que si c'est necessaire
		if( inExplo ) explo = db.Explo.manager.get(zone.id);
		var zombies = inExplo ? explo.getZombies() : zone.zombies;
		if( zombies == null ) zombies = 0;
		// % de chances de créer un item tête de zombie
		// utile pour des armes tel le club de golf
		if( Std.random(100) < Const.get.ZombiePartProba ) {
			if( inExplo )
				db.ExploItem.create( App.user.zone.explo, 68 );
			else
				ZoneItem.create( App.user.zone, 68 );
		}

		var kills = Std.int(Math.min(zombies, n));
		var prev = zombies;
		zombies -= kills;
		if( !inExplo ) {
			zone.zombies -= kills;
			zone.kills += kills;
		} else {
			var cell = explo.getCurrentCell();
			cell.zombies -= kills;
			cell.kills += kills;
		}

		var m = App.user.getMapForDisplay();
		if( inExplo ) // TODO : faire le log au niveau Exploration ou au niveau Zone ?? TODO : changer le texte !
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideKilledZ( { name:App.user.print(), n:kills, tool:t.print() } ), m, zone );
		else
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideKilledZ( { name:App.user.print(), n:kills, tool:t.print() } ), m, zone );
			
		if( zombies == 0 ) {
			if( !inExplo )
				zone.endFeist = null;
			notify( Text.fmt.KilledAllZombies( {tool:t.print()} ) );
		} else {
			if( !inExplo ) {
				var h = zone.getHumanScore();
				var z = Math.min(prev, zombies);
				// Après ce tir, les humains repassent en force
				if( h >= z )
					zone.endFeist = null;
			}
			notify( Text.fmt.KilledZombies( {tool:t.print(),n:printZombies(kills)} ) );
		}

		if( inExplo ) 	explo.update();
		else 			zone.update();
		
		GhostReward.gain(GR.get.killz, kills);
		App.user.update();
		return kills;
	}


	public function doDrink( t : Tool ) {
		var user = App.user;
		if( App.user.debt > 0 ) {
			fail(Text.get.DebtForbidden);
			return;
		}
		
		if( user.hasDrunk && !user.isDehydrated && !user.isThirsty ) {
			fail(Text.get.UselessDrink);
			return;
		}
		
		if( !user.isDehydrated && !user.isThirsty && user.paMaxed() ) {
			fail(Text.get.NotThirsty);
			return;
		}
		
		if(user.isGhoul)
			notify( Text.get.GhoulWaterWound );
		else
			if( user.hasDrunk )
				notify(Text.get.UsedWaterAgain);
			else
				if( user.isDehydrated )
					notify(Text.get.UsedWaterDehydrated);
				else
					notify(Text.get.UsedWater);
		user.drink();
		
		if( t.replacement!=null && t.replacement.length>0 )
			Tool.add( XmlData.getToolByKey(t.replacement[0]).toolId, user, t.inBag );
		t.delete();
		success(t);
	}

	public function doEat( t : Tool ) {
		var user = App.user;
		var map = user.getMapForDisplay();
		var fl_bypass = user.isGhoul && t.hasType(HumanMeat) && user.ghoulHunger > 0;
		if( !fl_bypass && !user.isTired && user.paMaxed() ) {
			fail(Text.get.NotHungry);
			return; 
		}
		
		gainFoodReward(t, user);
		var rep = t.getReplacement();
		if( rep != null )
			Tool.add(rep.toolId, user, t.inBag);
		t.delete();
		user.eat();
		// Can this tool make you a Ghoul?
		if( map.hasMod("GHOULS") && !user.isGhoul && !user.isImmune && !db.MapVar.getBool(map, "noGhoul") && t.ghoulProba != null && t.ghoulProba > 0 ) {
			var ghoulProba = t.ghoulProba;
			ghoulProba += 2 * db.MapVar.getValue( map, "lazyGhoul", 0 );
			if ( db.ZoneAction.manager.hasDoneAction(user, "cleanUp") ) 
				ghoulProba -= 3;
			// S14
			if ( map.hardcore )
				ghoulProba += 3;
				
			if( Std.random(100) < ghoulProba ) {
				user.makeGhoul(true);
				user.changeHunger(Const.get.GFoodQuality, false);
				user.update();
				notify(Text.get.UsedFood);
				App.reboot();
				return;
			}
		} else {
			if( map.hasFlag("infected") )//zone contaminée
				if( Std.random(100) <= 2 && user.infect() )
					appendNotify( Text.get.Intoxicated );
			
			if( user.isGhoul && t.hasType(HumanMeat) ) {
				// goule mangeant de la viande humaine
				var value = if (t.key == "oldCadaver") Const.get.GFoodQuality 
							else Const.get.GFoodBasic;
				
				user.changeHunger(value, false);
				notify( Text.fmt.HumanFood({food:t.print()}) );
			} else {
				if ( t.hasType(Tasty) ) {
					user.addPa(Const.get.TastyBonus);
					notify( Text.fmt.UsedTastyFood({food:t.print()}) );
				} else {
					notify(Text.get.UsedFood);
				}
			}
		}
		
		if( !user.isGhoul && t.hasType(Toxic) && Std.random(100) < t.power && user.infect() ) {
			appendNotify( Text.get.Intoxicated );
		} else if( t.hasType(HumanMeat) ) {
			appendNotify( Text.get.DisgustingFood );
		}
		
		if ( App.notification == null || App.notification == '' )
			notify(Text.get.UsedFood);
		success(t);
	}

	public function doOpen(t:Tool) {
		var opener = null;
		var user = App.user;
		var list;
		var typ = if(t.hasType(FragileBox)) Slasher else Opener;

		if(handCheck(t)) return;

		if( !t.hasType(OpenBox) ) {
			if( user.isOutside )
				list = user.getInBagTools();
			else
				list = user.getToolsByType(typ);
			for( to in list ) {
				if( to.hasType(typ) && !to.isBroken ) {
					opener = to;
					break;
				}
			}
		}
		
		var usedTechnician = false;
		//on teste le technicien qui lui peut se passer d'outil
		if( !t.hasType(OpenBox) && opener == null ) {
			if( user.getPc() > 0 ) {
				user.usePc(1);
				usedTechnician = true;
			}
		}
		
		if( t.hasType(OpenBox) || (opener!=null || usedTechnician)) {
			var xmlRep = t.getReplacement();
			if( t.hasType(OpenBox) || usedTechnician ) {
				notify( Text.fmt.BoxOpened( {box:t.print(), item:xmlRep.print()} ));
			}
			else if( t.hasType(FragileBox) ) {
				notify( Text.fmt.BoxDestroyed( {box:t.print(), opener:opener.print(), item:xmlRep.print()} ));
			}
			else {
				notify( Text.fmt.BoxOpenedWithTool( {box:t.print(), opener:opener.print(), item:xmlRep.print()} ));
			}
			if( canTakeObject(xmlRep,true) ) {
				Tool.add( xmlRep.toolId, user, t.inBag );
			}
			else {
				if( user.isOutside ) {
					if( user.inExplo() )
						db.ExploItem.create( user.getZoneForDisplay().explo, xmlRep.toolId );
					else
						ZoneItem.create( user.getZoneForDisplay(), xmlRep.toolId );
					appendNotify(Text.get.NoRoomDrop);
				}
				else {
					Tool.add( xmlRep.toolId, user, false );
					appendNotify(Text.get.NoRoomDropInChest);
				}
			}
			t.delete();
			success(t);
		}
		else {
			if( typ==Opener ) {
				fail(Text.get.NoOpener);
			}
			else {
				fail(Text.get.NoWeapon);
			}
			return;
		}
	}

	public function doOpenMulti(t:Tool) {
		var user = App.user;

		if(handCheck(t)) return;

		var repXml = t.getReplacement();
		if( t.parts.length>0 ) {
			if( t.inBag ) {
				if( !user.hasCapacity() || !canTakeObject(repXml,true) ) {
					fail( Text.fmt.MultiBoxBagFull({t:t.print()}) );
					return;
				}
			}
			else {
				if( !user.hasTrunkCapacity() ) {
					fail( Text.fmt.MultiBoxTrunkFull({t:t.print()}) );
					return;
				}
			}
		}

		var rep = Tool.add( repXml.toolId, App.user, t.inBag );
		notify(Text.fmt.MultiBox({t:t.print(),rep:rep.print()}));
		if( t.parts.length > 0 ) {
			var newBox = XmlData.getToolByKey(t.parts.first());
			Tool.add( newBox.toolId, App.user, t.inBag );
			appendNotify(Text.fmt.MultiBoxNotEmpty({t:t.print()}));
		} else {
			appendNotify(Text.fmt.MultiBoxEmpty({t:t.print()}));
		}
		t.delete();
		success(t);
	}

	public function doUseDrug( t : Tool ) {
		var user = App.user;
		var map = user.getMapForDisplay();
		var wasAddict = user.isAddict;
		if( !user.isAddict && user.paMaxed() ) {
			fail(Text.get.Useless);
			return;
		}
		if( t.hasType(Tasty) ) {
			if( t.key != "april_drug" ) {
				notify(Text.get.UsedTastyDrug);
			} else {
				notify(Text.get.UsedAprilDrug);
				db.GameAction.add(App.user, "eatenAprilDrug");
			}
		} else if( user.paMaxed() ) {
			notify( Text.fmt.UselessDrug({tool:t.print()}) );
			notify(Text.get.UsedDrug);
		}

		if ( t.hasType(Scary) && Std.random(100) < t.power) {
			user.terrorize();
			if ( user.isTerrorized )
				appendNotify( Text.get.Terrorized );
		}
		// infecté
		if( t.hasType(Toxic) && Std.random(100) < t.power && !user.isGhoul )
			if( user.infect() )
				appendNotify( Text.get.Intoxicated );

		// qualité
		if( t.hasType(Tasty) )
			user.useDrug(Const.get.TastyDrugBonus);
		else
			user.useDrug();
		
		//zone contaminée
		if( map.hasFlag("infected") )
			if( Std.random(100) <= 2 && user.infect() )
				appendNotify( Text.get.Intoxicated );

		// msg addiction
		if( user.isAddict && !wasAddict )
			appendNotify(Text.get.Addicted);

		if( t.loss_probability == null || Std.random(100) < t.loss_probability )
			t.delete();
		
		if ( App.notification == null || App.notification == '' )
			notify(Text.get.UsedDrug);
		success(t);
	}

	public function doWaterGun(t:Tool) {
		var zombies = getZombiesCount();
		if( zombies<=0 ) {
			fail( Text.get.NoZombie );
			return;
		}

		killZombies(t, t.power);
		Tool.add( t.getReplacement().toolId, App.user, t.inBag );
		t.delete();
		success(t);
	}
	
	public function doLaserGun(t:Tool) {
		var zombies = getZombiesCount();
		if( zombies<=0 ) {
			fail( Text.get.NoZombie );
			return;
		}

		killZombies(t, t.power);
		Tool.add( t.getReplacement().toolId, App.user, t.inBag );
		t.delete();
		success(t);
	}

	public function doBatGun( t : Tool ) {
		if(handCheck(t)) return;
		var zombies = getZombiesCount();
		if( zombies <= 0 ) {
			fail( Text.get.NoZombie );
			return;
		}
		
		if( t.power < 1 ) {
			if( Std.random(100) < t.power*100 ) {
				killZombies(t, 1);
			} else {
				notify( Text.fmt.CantEvenKillOneBatGun({tool:t.print()}) );
			}
		} else {
			killZombies(t,t.power);
		}

		if( Std.random(100) < t.loss_probability ) {
			Tool.add(t.getReplacement().toolId, App.user,t.inBag);
			appendNotify(Text.get.BatGunEmptied);
			t.delete();
			if( App.user.inExplo() ) {
				db.ExploItem.create(App.user.zone.explo, XmlData.getToolByKey("batt_broken").toolId);
			} else {
				ZoneItem.create(App.user.zone, XmlData.getToolByKey("batt_broken").toolId);
			}
		}
		success(t);
	}

	public function doBatGunUp( t : Tool ) {
		if(handCheck(t)) return;
		var zombies = getZombiesCount();
		if( zombies<=0 ) {
			fail( Text.get.NoZombie );
			return;
		}

		if( t.power<1 ) {
			if( Std.random(100)<t.power*100 ) {
				killZombies(t,1);
			}
			else {
				notify( Text.fmt.CantEvenKillOneBatGun({tool:t.print()}) );
			}
		}
		else {
			killZombies(t,t.power);
		}

		Tool.add(t.getReplacement().toolId,App.user,t.inBag);
		t.delete();
		if( Std.random(100) < t.loss_probability ) {
			if( App.user.inExplo() ) {
				db.ExploItem.create(App.user.zone.explo , XmlData.getToolByKey("batt_broken").toolId);
			} else {
				ZoneItem.create(App.user.zone, XmlData.getToolByKey("batt_broken").toolId);
			}
			appendNotify(Text.get.BatteryDestroyed);
		}
		else {
			if( App.user.inExplo() ) db.ExploItem.create(App.user.zone.explo, XmlData.getToolByKey("batt").toolId);
			else ZoneItem.create(App.user.zone, XmlData.getToolByKey("batt").toolId);
			appendNotify(Text.get.BatteryNotDestroyed);
		}
		success(t);
	}

	public function doJerryGun(t:Tool) {
		if(handCheck(t)) return;
		var zombies = getZombiesCount();
		if( zombies<=0 ) {
			fail( Text.get.NoZombie );
			return;
		}

		killZombies(t,t.power);
		if( Std.random(100)<Const.get.JerryGunChanceEmpty ) {
			Tool.add( t.getReplacement().toolId, App.user, t.inBag );
			t.delete();
			appendNotify( Text.get.JerryGunEmptied );
		}
		else {
			appendNotify( Text.get.JerryGunNotEmptied );
		}
		success(t);
	}

	public function doGrenade(t:Tool) {
		var zombies = getZombiesCount();
		if( zombies <= 0 ) {
			fail(Text.get.NoZombie);
			return;
		} else {
			killZombies(t, t.power+t.getRandom());
			var rep = t.getReplacement();
			if( rep != null ) {
				Tool.add(rep.toolId, App.user, t.inBag);
				appendNotify( Text.fmt.GotFromIphone({tool:rep.print()}) );
			}
			t.delete();
			success(t);
		}
	}

	public function doPet(t:Tool) {
		var user = App.user;
		if( user.isOutside ) {
			// dehors, le pet sert de grenade
			var zombies = getZombiesCount();
			if( zombies<=0 ) {
				fail(Text.get.NoZombie);
				return;
			}
			else {
				killZombies(t,t.power);
				if(Std.random(100)<t.loss_probability) {
					notify(Text.fmt.PetGrenade({pet:t.print()}));
					GhostReward.gain(GR.get.animal);
					t.delete();
				}
				else {
					notify(Text.get.PetSurvived);
				}
			}
			success(t);
		}
		else {
			if( user.hasCityBuilding("butcher") ) {
				var n=Const.get.PetConversion;
				if( t.isHeavy ) n+=2;
				var r = t.getReplacement();
				for (i in 0...n)
					Tool.add( r.toolId , App.user, false );
				notify( Text.fmt.NoMorePet({name:t.print(),n:n,rep:r.print()}) );
				GhostReward.gain(GR.get.animal);
				success(t);
				t.delete();
				return;
			}
			else {
				fail(Text.get.NeedButcher);
			}
		}
	}

	public function doCombatHit(t:Tool) {
		if( handCheck(t) )
			return;
		
		var zombies = getZombiesCount();
		if( zombies <= 0 ) {
			fail(Text.get.NoZombie);
			return;
		} else {
			if( !App.user.isTired ) {
				// kills
				if( t.power < 1 ) {
					if( Std.random(100) < t.power * 100 ) {
						killZombies(t,1);
					} else {
						notify(Text.get.CantEvenKillOne);
					}
				} else {
					killZombies(t,t.power);
				}
				if ( Std.random(100) < t.broken ) {
					var rep = t.getReplacement();
					if( rep != null ) {
						Tool.add( t.getReplacement().toolId , App.user, t.inBag );
						t.delete();
					} else {
						t.isBroken = true;
						t.update();
						GhostReward.gain( GR.get.broken );
					}
					appendNotify( Text.get.JustBroken );
				}
				App.user.dirt();
				success(t);
			} else {
				fail(Text.get.UserTired);
			}
		}
	}
	
	public function doAlcohol(t:Tool) {
		var user = App.user;
		if( !user.isTired && user.paMaxed() ) {
			fail(Text.get.Useless);
		} else {
			if( user.isDrunk || user.isHungOver ) {
				fail(Text.get.UselessAlcohol);
			} else {
				GhostReward.gain( GR.get.alcool );
				user.drinkAlcohol();
				if ( t.key == "hmbrew" )
					user.addPa(2, true);
				t.delete();
				notify(Text.get.DrunkAlcohol);
				success(t);
			}
		}
	}
	
	public function doCider(t:Tool) {
		var user = App.user;
		if( !user.isTired && user.paMaxed() ) {
			fail(Text.get.Useless);
		} else {
			user.drinkAlcohol();
			user.addPa(7, true);
			t.delete();
			notify(Text.get.DrunkAlcohol);
			success(t);
		}
	}
	
	public function doCoffee(t:Tool) {
		var user = App.user;
		if( !user.isTired && user.paMaxed() ) {
			fail(Text.get.Useless);
		} else {
			user.addPa(Const.get.CoffeeRegen,true);
			t.delete();
			notify(Text.get.DrunkCoffee);
			success(t);
		}
	}
	
	public function doRest(t:Tool) {
		return;

		// XXX > à reconsidérer
		/*
		var user = App.user;
		if( user.isOutside ) {
			fail(ForbiddenOutside);
			return;
		}

		if( user.isSleeping() ) {
			user.continueToSleep();
			return;
		}
		user.startSleeping();
		notify( StartRest );
		success(t);
		*/
	}

	public function doHeal(t:Tool) {
		var user = App.user;
		if( !user.isWounded ) {
			fail(Text.get.NotWounded);
			return;
		}

		if( user.isConvalescent ) {
			fail(Text.get.Convalescent);
			return;
		}

		user.heal();
		if( Std.random(100)<t.loss_probability ) {
			t.delete();
		}
		notify(Text.get.Healed);
		success(t);
	}

	public function doPurifyWater(t:Tool) {
		var usedPill = null;
		var user = App.user;
		var fl_canUseBuilding =
				(user.hasCityBuilding("hydro")) &&
				!user.isCityBanned;
		if( !fl_canUseBuilding || user.isOutside ){
			// on ne peut pas utiliser le bâtiment Purificateur
			usedPill = user.findTool( "purifier", if(user.isOutside) true else null );
			if( usedPill==null ) {
				fail(Text.get.NeedPurifier);
				return;
			}
			else
				usedPill.delete();
		}
		
		var maxWaterGain = if(t.key=="water_cup_part") 2 else 999;

		// Conversion
		if(usedPill == null) {
			// bâtiment utilisé (eau envoyée au puits)
			var range = if ( user.hasCityBuilding("filter") ) mt.MLib.randRange(4, 9)//Range.makeInclusive(4, 9) 
						else mt.MLib.randRange(1, 3);// Range.makeInclusive(1, 3);
			var n = Std.int( Math.min(maxWaterGain, range) );
			user.map.water += n;
			user.map.update();
			var msg = if(n==1) Text.fmt.CL_GiveWaterSingle({name:user.print()} ) else Text.fmt.CL_GiveWater({name:user.print(),n:n} );
			CityLog.add( CL_GiveWater, msg, user.getMapForDisplay(), user );
			var msg = if(n==1) Text.fmt.WaterPurifiedSingle({name:user.print()} ) else Text.fmt.WaterPurified({name:user.print(),n:n} );
			notify(msg);
		}
		else {
			// objet de purification utilisé (eau placée dans le sac)
			var range = mt.MLib.randRange(2, 3);// Range.makeInclusive(2, 3);
			var n = Std.int( Math.min(maxWaterGain, range) );
			var cap = user.getCapacity() + (if(usedPill.inBag) 1 else 0);
			for (i in 0...n) {
				Tool.add( t.getReplacement().toolId , user, (user.isOutside || cap>0) );
				cap--;
			}
			notify( Text.fmt.WaterPurifierUsed({tool:usedPill.print(),target:t.print(),n:n}) );
		}
		success(t);
		t.delete();
	}

//	public function doPurifier(t:Tool) {
//		var user = App.user;
//		var jlist = user.getToolsByType(Jerrycan);
//		if( jlist.length==0 ) {
//			fail(Text.get.NeedJerrycan);
//			return;
//		}
//
//		if( !user.hasTrunkCapacity() ) {
//			fail(Text.get.NoMoreRoomInTrunk);
//			return;
//		}
//
//		var cap = user.getTrunkCapacity();
//		var jer = jlist.first();
//		var n = Std.int( Math.min( Std.random(Const.get.JerrycanConversion)+2, cap ) );
//		for (i in 0...n) {
//			Tool.add( jer.getReplacement().toolId , App.user, false );
//		}
//		notify( Text.fmt.WaterPurifierUsed({tool:t.print(),target:jer.print(),n:n}) );
//		jer.delete();
//		t.delete();
//		success(t);
//	}

	function doPlayGolf( t : Tool ) {
		var zombies = getZombiesCount();
		if( zombies<=0 ) {
			fail( Text.get.NoZombie );
			return;
		}
		if( consume(ZombiePart, 1, t.loss_probability) ) {
			killZombies(t,t.power);
			success(t);
			return;
		}
	}

	public function doAssemble(t:Tool) {
		var user = App.user;
		var founds = new List();
		var parts = new List();
		var fl_needWater = false;
		for( pkey in t.parts ) {
			var xmlPart = XmlData.getToolByKey(pkey);
			if( xmlPart.key == "water" ) fl_needWater = true;
			parts.push(xmlPart);
			var ut = user.findTool(xmlPart.key, !user.inTown());
			if( ut != null && !ut.isBroken ) {
				founds.push(ut);
			}
		}
		
		if( user.hasCityBuilding("robinet") ) {
			if( t.hasType(EmptyWeapon) && !user.isOutside && fl_needWater && parts.length == 1 ) {
				fail(Text.get.RobinetIsBetter);
				return;
			}
		}
		
		if( founds.length >= parts.length ) {
			var xmlRep : Tool = t.getReplacement();
			if( xmlRep.hasType(Bag) ) {
				var ok = true;
				for( tt in user.getInBagTools(false) ) {
					if( tt.hasType(Bag) ) {
						App.notification = Text.get.AddOnlyOneHeavyObject;
						ok = false;
						break;
					}
				}
				if( ok ) {
					Tool.add( xmlRep.toolId , App.user, t.inBag );
				} else {
					if( App.user.isOutside ) {
						if( user.inExplo() ) db.ExploItem.create( App.user.zone.explo, xmlRep.toolId );
						else 				 ZoneItem.create( App.user.zone, xmlRep.toolId );
					} else {
						Tool.add( xmlRep.toolId , App.user, false );
					}
				}
			} else {
				Tool.add( xmlRep.toolId , App.user, t.inBag );
			}
			parts.push(t);
			notify(Text.fmt.Assembled({name:xmlRep.print(),list:printList(parts)}));
			if( user.isNoob && xmlRep.hasType(Furniture) ) {
				appendNotify(Text.get.FurnitureTutorialBuilt);
			}
			for( req in founds ) {
				req.delete();
			}
			if(t.key == "sawPart")			db.GhostReward.gain(GR.get.tronco);
			if(t.key == "watGun3k_part")	db.GhostReward.gain(GR.get.watgun);
			if(t.key == "jerrygun_part")	db.GhostReward.gain(GR.get.watgun);
			if(t.key == "pilegun_upkit")	db.GhostReward.gain(GR.get.batgun);
			if(t.key == "big_pgun_part")	db.GhostReward.gain(GR.get.batgun);
			if( user.isCityBanned && t.hasType(BannedTool) ) {
				db.GhostReward.gain(GR.get.solban);
			}
			// On met à jour les informations de contrôle de la zone
			var map = user.getMapForDisplay();
			if( user.isOutside && user.zoneId != map.cityId && xmlRep.hasType( Control ) && !user.isTerrorized ) {
				OutsideActions.updateZoneControl( user.zone, Std.int(xmlRep.power), map );
			}
			t.delete();
			success();
		} else {
			fail(Text.fmt.NotAllRequired({list:printList(parts)} ));
			return;
		}
	}

	public function doAssembleOne(t:Tool) {
		var user = App.user;
//		var founds = new Array();
//
//		for (pkey in t.parts) {
//			var xmlPart = XmlData.getToolByKey(pkey);
//			var ut = user.findTool(xmlPart.key,!user.inTown());
//			if( ut!=null && !ut.isBroken ) {
//				founds.push(ut);
//			}
//		}
//
//		if( founds.length>=1 ) {
//			var second = founds[Std.random(founds.length)];
//			var skey = XmlData.getTool( App.request.getInt("useWith") );
		var second = getUsedWith(t,user);
		if( second==null || second.isBroken ) {
			var list = new List();
			for (pkey in t.parts) {
				list.add( XmlData.getToolByKey(pkey) );
			}
			fail(Text.fmt.CantAssemble({tool:t.print(),list:printList(list, Text.get.Or)} ));
		}
		else {
			var xmlRep : Tool = t.getReplacement(second.key);
			Tool.add( xmlRep.toolId , App.user, t.inBag );
			notify(Text.fmt.AssembledWithOne({name:xmlRep.print(),first:t.print(),second:second.print()}));
			if(t.key=="poison" || t.key=="infect_poison") {
				appendNotify( Text.fmt.MadePoison({tool:second.print()}) );
			}

			if( user.isCityBanned && t.hasType(BannedTool) ) {
				db.GhostReward.gain(GR.get.solban);
			}

			second.delete();
			t.delete();
			success();
		}
	}


	public function doAssembleIdenticals(t:Tool) {
		var user = App.user;
		var fl_force = ZoneAction.manager.hasDoneAction(App.user, "forcePharmaMix");
		if( t.key=="pharma" ) {
			if( !user.isOutside && db.HomeUpgrade.manager.hasAvailableAction( user, "labo" ) ) {
				if( !fl_force ) {
					fail(Text.get.LaboIsBetter);
					appendNotify(Text.get.ActionCanBeForced);
					ZoneAction.add( App.user, "forcePharmaMix" );
					return;
				}
			}
		}
		else {
			fl_force = false;
		}

		var list = user.getTools().filter( function(tool) {
			return tool.toolId==t.toolId && tool.id!=t.id && ( user.isOutside && tool.inBag || !user.isOutside );
		});
		var comb = list.pop();
		if( comb==null ) {
			fail( Text.fmt.NoCombination({tool:t.print()}) );
			return;
		}
		else {
			var r = t.getReplacement();
			Tool.add( r.toolId, user, t.inBag );
			notify( Text.fmt.AssembledIdenticals({tool:r.print(), base:t.print()}) );
			if( fl_force ) {
				appendNotify( Text.get.LaboIsBetter );
			}
			if( user.isCityBanned && t.hasType(BannedTool) ) {
				db.GhostReward.gain(GR.get.solban);
			}
			comb.delete();
			t.delete();
			success();
		}
	}


	public function doRadius( t : Tool ) {
		var user = App.user;
		var zone = user.zone;
		var c = {x:zone.x,y:zone.y};
		var zonesToCheck = Lambda.list( Zone.manager._getZonesForMap( user.map, false ));

		var zones = Lambda.filter( zonesToCheck, function(z:Zone) {
				if( z == null )
					return false;

//				if( z.tempChecked )
//					return false;

				if( Cron.getZoneLevel( c, {x:z.x,y:z.y} ) == 1 )
					return true;

				return false;
			} );

		if( zones.length <= 0 ) {
			App.reboot();
			return;
		}

		var ztc = Lambda.filter( zonesToCheck, function(z:Zone) { return Cron.getZoneLevel( c, {x:z.x,y:z.y} ) == 1; } );
		for( zz in ztc ) {
			user.zones.set( zz.id, 0 );
		}
		user.update();

		var ids = Lambda.map( zones, function( zone : Zone ) { return zone.id; } );
		Zone.manager.globalCheck( ids, user.map );

		notify(Text.get.ZoneEnlightened);
		if( Std.random(100)<t.loss_probability ) {
			var newTool = t.getReplacementKey();
			if( newTool!=null ) {
				appendNotify(Text.get.EnlighterDepleted);
				Tool.addByKey( newTool, App.user, t.inBag );
			}
			t.delete();
		}
		App.reboot();
	}

	public function doFlare( t : Tool ) {
		var user = App.user;
		var zone = user.zone;
		var zones = Lambda.array( Lambda.filter( Zone.manager._getZonesByLevel( user.map, 3, 99, true ), function(z:Zone) {
			return z != null && !z.checked && !z.tempChecked;
		} ) );

		var z = zones[Std.random( zones.length -1 )];
		z.tempChecked = true;
		z.update();
		user.zones.set( z.id, 0 );
		user.update();

		if( z.type > 0 )
			notify(Text.fmt.ZoneFlaredBuilding( {building:XmlData.getOutsideBuilding( z.type ).name, x:z.x,y:z.y} ) );
		else
			notify(Text.fmt.ZoneFlared( {x:z.x,y:z.y} ) );

		t.delete();
		App.reboot();
	}

	public function doSwitch(t:Tool) {
		if(t.key == "camoVest_off" && App.user.isOutside) {
			var zone = App.user.zone;
			if( zone.isInFeist() ) {
				fail(Text.get.CantHideNow);
				return;
			}
			var n = db.User.manager.countSquad(App.user);
			if( n > 0 ) {
				fail( Text.fmt.CantHideWithEscort({n:n}) );
				return;
			}
		}
		
		if(t.key == "reveil_off" && !App.user.winnerNormal && !App.user.winnerHardcore) {
			fail( Text.get.ReservedToWinners );
			return;
		}

		if( t.parts.length>=0 ) {
			var founds = new List();
			var parts = new List();
			
			for (pkey in t.parts) {
				var xmlPart = XmlData.getToolByKey(pkey);
				parts.push(xmlPart);
				var t = App.user.findTool(xmlPart.key,!App.user.inTown());
				if( t!=null ) {
					founds.push(t);
				}
			}
			if( founds.length<parts.length ) {
				fail(Text.fmt.NotAllRequired({list:printList(parts)} ));
				return;
			}
			else {
				switch(t.key) {
					case "camoVest_off"	: notify(Text.get.Hidden);
					case "suit_dirt"	: notify( Text.fmt.CleanedUp({tool:t.print()}) );
					default				: notify( Text.fmt.Transformed({old:t.print(),tool:XmlData.getToolByKey(t.getReplacementKey()).print()}) );
				}
			}
		}
		var newTool = Tool.addByKey( t.getReplacementKey() , App.user, t.inBag );
		success(t);
		t.delete();
	}


	public function doCalm(t:Tool) {
		var user = App.user;
		var wasAddict = user.isAddict;
		if( user.isTerrorized ) {
			user.calmDown(false);
			notify(Text.get.CalmedDown);
		} else {
			notify( Text.fmt.UselessDrug({tool:t.print()}) );
		}
		user.raiseAddiction();
		if( user.isAddict && !wasAddict ) {
			appendNotify(Text.get.Addicted);
		}
		success();
		t.delete();
	}

	public function doMakeCoffee(t:Tool) {
		var user = App.user;
		if( !user.hasCapacity(1) && !user.hasTrunkCapacity(1) ) {
			fail(Text.get.NoRoom);
			return;
		}

		var founds = new List();
		var parts = new List();
		for( pkey in t.parts ) {
			var xmlPart = XmlData.getToolByKey(pkey);
			parts.push(xmlPart);
			var t = user.findTool(xmlPart.key,!user.inTown());
			if( t != null ) {
				founds.push(t);
			}
		}
		if( founds.length < parts.length ) {
			fail(Text.fmt.NotAllRequired({list:printList(parts)} ));
			return;
		} else {
			var xmlCoffee = XmlData.getToolByKey("coffee");
			var fl_full = t.inBag && !user.hasCapacity();
			for( r in founds )
				r.delete();
			notify(Text.fmt.MadeCoffee({name:xmlCoffee.print(),list:printList(parts)}));
			Tool.add( xmlCoffee.toolId, App.user, user.hasCapacity(1) );
			if(fl_full) doRemoveFromBag(xmlCoffee);
			success();
		}
	}

	public function doVibro(t:Tool) {
		var user = App.user;
		if( !user.isTerrorized ) {
			fail(Text.get.Useless);
		} else {
			db.GhostReward.gain( GR.get.maso );
			user.calmDown();
			notify( Text.get.UsedVibro );
			Tool.add(t.getReplacement().toolId, user, t.inBag);
			t.delete();
			success();
		}
	}

	public function doUseWaterDrug( t : Tool ) {
		var user = App.user;
		var wasAddict = user.isAddict;
		if( !user.isDehydrated && !user.isThirsty ) {
			notify( Text.fmt.UselessDrug({tool:t.print()}) );
		} else {
			notify(Text.get.UsedWaterDrug);
		}
		if( user.isDehydrated ) {
			user.isDehydrated = false;
			user.isThirsty = true;
		}
		else {
			user.isThirsty = false;
		}
		user.raiseAddiction();
		if( user.isAddict && !wasAddict ) {
			appendNotify(Text.get.Addicted);
		}
		t.delete();
		success(t);
	}

//	public function doRepair(kit:Tool) {
//		if(handCheck(kit)) return;
////		var target = getUsedWith(App.user);
////		if( target==null || !target.isBroken )
//		if( App.request.exists("target") ) {
//			makeRepair(kit, Tool.manager.get(App.request.getInt("target")) );
//			return;
//		}
//		if( App.user.isTired ) {
//			fail(Text.get.UserTired);
//			return;
//		}
//		App.goto("tool/repair?id="+kit.id);
//	}


	function doRepair(kit:Tool) {
		var user = App.user;
		if(handCheck(kit)) return;

		var t = getUsedWith(user);

		if(!terrorCheck(t,user))
			return;

		if( !user.canDoTiringAction(Const.get.PA_Repair) ) {
			fail( Text.fmt.NeedPA({n:Const.get.PA_Repair}) );
			return;
		}
		if( kit.hero && !App.user.hero ) {
			fail(Text.get.HeroOnly);
			return;
		}

		if( t==null || !t.isBroken || kit.userId!=user.id || !kit.inBag && !user.inTown() ) {
			fail(Text.get.ImpossibleAction);
			return;
		}

		GhostReward.gain(GR.get.repair);
		t.isBroken = false;
		t.update();
		var newKit = kit.getReplacementKey();
		if( newKit!=null ) {
			Tool.addByKey( newKit, App.user, kit.inBag );
		}
		kit.delete();
		user.doTiringAction(Const.get.PA_Repair);
		notify( Text.fmt.Repaired({tool:t.print(),kit:kit.print(),cost:Const.get.PA_Repair}) );
		if( user.inTown() ) {
			success();
			return;
		}
		App.goto( getOutsideURL() );
	}
	
	public function doViolentRegen( t : Tool ) {
		var user = App.user;
		if( user.paMaxed() ) {
			fail(Text.get.Useless);
			return;
		}
		if( user.isWounded ) {
			fail(Text.get.CantDoWhenWounded);
			return;
		}

		user.wound(false);
		db.GhostReward.gain( GR.get.maso );
		user.refillMoves();
		Tool.add(t.getReplacement().toolId, user, t.inBag);
		t.delete();
		notify(Text.get.ViolentRegen);
		success(t);
	}
	
	function doRoll(t:Tool) { // dice
		if( App.user.getPa()>App.user.maxPa() ) {
			fail(Text.get.Useless);
			return;
		}
		var draw = new Array();
		draw.push(Std.random(6)+1);
		draw.push(Std.random(6)+1);
		draw.push(Std.random(6)+1);
		notify( Text.fmt.Rolled({a:draw[0],b:draw[1],c:draw[2]}) );
		if(draw[0]==draw[1] && draw[1]==draw[2]) {
			appendNotify(Text.get.RolledTriple);
			App.user.addPa(1);
		}
		else if(draw[0]==draw[1] || draw[1]==draw[2] || draw[0]==draw[2]) {
			appendNotify(Text.get.RolledDouble);
		}
		else {
			draw.sort( function(a,b) {
				if(a<b) return -1;
				if(a>b) return 1;
				return 0;
			});
			if( draw[0]==1 && draw[1]==2 && draw[2]==4 ) {
				appendNotify(Text.get.Rolled421);
				App.user.addPa(1);
			}
			if( draw[0]==draw[1]-1 && draw[1]==draw[2]-1 ) {
				appendNotify(Text.get.RolledSuite);
				App.user.addPa(1);
			}
		}
		success(t);
	}

	function doRandomDrug(t:Tool) {
		var user = App.user;
		var wasAddict = user.isAddict;
		GhostReward.gain(GR.get.cobaye);

		var n = Std.random(5);
		switch( n ) {
			case 0	: {
				user.useDrug();
				notify(Text.get.UsedDrug);
			}
			case 1	: {
				user.useDrug();
				notify(Text.get.UsedDrug);
			}
			case 2	: {
				user.terrorize(false);
				user.raiseAddiction();
				notify( Text.fmt.RandDrugTerror({tool:t.print()}) );
			}
			case 3	: {
				user.isAddict = true;
				wasAddict = true;
				user.useDrug(Const.get.TastyBonus);
				notify( Text.fmt.RandDrugPowerful({tool:t.print()}) );
			}
			case 4	: {
				notify( Text.fmt.RandDrugNothing({tool:t.print()}) );
			}
		}
		if( user.isAddict && !wasAddict ) {
			appendNotify(Text.get.Addicted);
		}
		t.delete();
		success(t);
	}

	function doDisinfect(t:Tool) {
		var user = App.user;
		var map = user.getMapForDisplay();	
		var wasAddict = user.isAddict;
		if( !user.isInfected )
			notify( Text.fmt.UselessDrug({tool:t.print()}) );
		else
			notify( Text.fmt.Disinfected({tool:t.print()}) );
		
		user.isInfected = false;
		// immunité
		user.isImmune = true;
		appendNotify(Text.get.Immune);
		
		user.changeHunger(Const.get.GFoodDrug, false);
		user.raiseAddiction(); // update
		if( user.isAddict && !wasAddict )
			appendNotify(Text.get.Addicted);
		
		t.delete();
		success(t);
	}

	function doDig(t:Tool) {
		if(handCheck(t)) return;
		var user = App.user;
		var zone = user.zone;
		if( zone.diggers==null || zone.diggers<=0 ) {
			fail(Text.get.Useless);
			return;
		}
		var cpt = Math.round(t.power) + t.getRandom();
		zone.diggers = Math.floor( Math.max(0,zone.diggers-cpt) );
		zone.update();
		var m = user.getMapForDisplay();
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideDiggedWithTool( {name:user.print(),n:cpt,t:t.print()} ), m, user.zone );
		t.delete();
		if( zone.hasBuildingExtracted() ) {
			CityLog.addToZone( CL_OutsideEvent, Text.fmt.OutsideDiggedDone( {building:XmlData.getOutsideBuilding(zone.type).name} ), m, user.zone );
			App.reboot();
		}
		else {
			if( cpt>1 )
				notify( Text.fmt.UsedDiggerMany({tool:t.print(),n:cpt}) );
			else
				notify( Text.fmt.UsedDigger({tool:t.print()}) );
			success(t);
		}
	}


	function doDrawCard(t:Tool) {
		if( App.user.getPa()>App.user.maxPa() ) {
			fail(Text.get.Useless);
			return;
		}
		var card = tools.Utils.drawCard();
		var special = Std.random(56);
		if( special == 0 ) {
			notify( Text.get.DrawRuleCard );
			App.user.addPa(1);
		} else if( special == 1 ) {
			notify( Text.get.DrawDoomedCard);
			App.user.terrorize();
		} else {
			notify( Text.fmt.DrawCard({type:card.typeName,color:card.colorName}) );
			if( card.type == 0 ) {
				appendNotify( Text.get.NiceCard );
				App.user.addPa(1);
			}
			if( card.type == 11 && card.col == 0 ) {
				appendNotify( Text.get.LoveCard );
				App.user.addPa(1);
			}
		}
		success(t);
	}
	
	function doBook(t:Tool) {
		var user = App.user;
		var map = user.map;
		var bdata = db.Book.generateBookData();
		if( bdata == null ) {
			fail( Text.get.UnknownError );
			return;
		}
		var res = db.Book.create(App.user, bdata);
		notify( Text.fmt.UnlockedBook({tool:t.print(), title:res.b.print()}) );
		t.delete();
		if( res.newBook ) {
			appendNotify( Text.get.UnlockedBookNew );
			//specific case of day 1, since players were doing suicide in order to get them faster !
			var g = GhostReward.gain( GR.get.rp );
			if ( map.days <= 2 ) {
				g.day = map.days;
				g.update();
			}
			App.goto("ghost/city?go=ghost/books?bkey="+bdata.key);
		} else {
			appendNotify( Text.get.AlreadyHaveBook );
			success(t);
		}
	}
	
	public function doGenBook(t:Tool) {
		var rep = t.getReplacement();
		notify( Text.fmt.FoundBookInBox({book:rep.print(), from:t.print()}) );
		Tool.add(rep.toolId, App.user, t.inBag);
		t.delete();
		success(t);
	}
	
	function doFlash(t:Tool) {
		var user = App.user;
		var zone = user.zone;
		var inExplo = user.inExplo();
		var usefull = (inExplo) ? zone.explo.getZombies() > 0 : zone.isInFeist();
		if( !usefull ) {
			notify( Text.get.Useless );
		} else {
			if( t.key.indexOf("photo_") == 0 && !App.user.hero ) {
				fail(Text.get.NowYouWishedYouWereAHero);
				return;
			}
			if( t.random <= 0 || Std.random(100) < t.random ) {
				if( inExplo ) {
					var explo = db.Explo.manager.get(zone.id);
					var cell = explo.getCurrentCell();
					var zombies = cell.zombies;
					var maxLoop = zombies * 100;
					while( zombies > 0 ) {
						//get random cell around current one
						var deltaX = 1 + Std.random(5);
						var deltaY = 1 + Std.random(5);
						deltaX *= (Math.random() > .5) ? 1 : -1;
						deltaY *= (Math.random() > .5) ? 1 : -1;
						var target = explo.getAt( explo.x + deltaX, explo.y + deltaY );
						if( target != null && target.walkable ) {
							target.zombies ++;
							zombies --;
						}
						if( --maxLoop <= 0 ) break;
					}
					var afraid = cell.zombies - zombies;
					cell.zombies = zombies;// au cas ou
					explo.update();
					notify( Text.fmt.ExploUsedFlashTool( { tool:t.print(), count:afraid } ) );
				} else {
					var base = if( zone.endFeist != null ) zone.endFeist else Date.now();
					zone.endFeist = DateTools.delta( base, DateTools.seconds(t.power) + 2000 );
					var d = if( t.power < 120 ) Text.fmt.Seconds({n:t.power}) else Text.fmt.Minutes({n:Math.floor(t.power/60)});
					zone.update();
					notify( Text.fmt.UsedFlashTool({tool:t.print(),d:d}) );
					var m = db.Map.manager.get( App.user.mapId, false ); // On évite de locker la ressource
					CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideFlash( { name:App.user.print(), d:d, tool:t.print() } ), m, App.user.zone );
				}
			} else
				fail(Text.fmt.FlashToolFailed( { tool:t.print() } ));
			var rep = t.getReplacement();
			if( rep != null )
				Tool.add(rep.toolId, App.user, t.inBag);
			t.delete();
		}
		success(t);
	}

	public function doHug(t:Tool) {
		var user = App.user;
		if( user.isTerrorized ) {
			if( Std.random(100) <= Const.get.TeddyBearChance ) {
				user.calmDown();
				notify( Text.fmt.Hugged({tool:t.print()}) );
				success(t);
			} else {
				notify( Text.fmt.HuggedFailed({tool:t.print()}) );
				success(t);
			}
		} else {
			fail(Text.get.Useless);
		}
	}

	public function doUpgradeChest(t:Tool) {
		notify( Text.fmt.ChestUpgraded({t:t.print(),n:t.power}) );
		App.user.homeCapacity+=Math.ceil(t.power);
		App.user.update();
		GhostReward.gain( GR.get.hbuild );
		t.delete();
		success(t);
	}

	public function doUpgradeDef(t:Tool) {
		notify( Text.fmt.DefUpgraded({t:t.print(),n:t.power}) );
		App.user.homeDefense+=Math.ceil(t.power);
		App.user.update();
		GhostReward.gain( GR.get.hbuild );
		t.delete();
		success(t);
	}

	function getOutsideURL() {
		var user = App.user;
		var map = user.getMapForDisplay();
		if( user.zoneId == map.cityId )
			return "outside/doors";
		return "outside/refresh";
	}

	function doSmoke(t:Tool) {
		var matches = App.user.findTool(t.parts.first());
		if( matches==null ) {
			fail( Text.fmt.Need({t:XmlData.getToolByKey(t.parts.first()).print()}) );
			return;
		}

		if( !App.user.isTerrorized ) {
			fail( Text.get.Useless );
			return;
		}

		notify(Text.get.SmokedCig);

		if( Std.random(100)<Const.get.CigaretChance ) {
			if( Std.random(2)==0 ) {
				t.delete();
				appendNotify(Text.get.LastCig);
			} else {
				matches.delete();
				appendNotify(Text.get.LastMatch);
			}
		}
		App.user.calmDown();
		success(t);
	}
	
	function doPoison(t:Tool) {
		// limitation des suicides J1
		var map = App.user.getMapForDisplay();
		if(t.key=="cyanure" && map.days<=1) {
			fail(Text.fmt.TooEarlyToUse({n:2}));
			return;
		}
		
		t.delete();
		switch(t.key) {
			case "cyanure"	: App.user.die(DT_Cyanure);
			default			: App.user.die(DT_Poison);
		}
		App.reboot();
	}
	
	function doPutOutsideDef(t:Tool) {
		if( !App.user.map.hasMod("CAMP") )
			return;
		
		var zone = App.user.zone;
		if( !App.user.canDoTiringAction(1) ) {
			fail( Text.fmt.NeedPA({n:1}) );
			return;
		}
		
		if( zone.id == App.user.getMapForDisplay()._getCity().id ) {
			fail(Text.get.PutDefenseForbidden);
			return;
		}
		
		if( zone.defense >= Const.get.CampMaxDefense ) {
			fail( Text.get.CampMaxed );
			return;
		}
		
		App.user.doTiringAction(1);
		//ODD?
		zone.defense += Const.get.CampUpgradeItem;
		zone.update();
		notify( Text.fmt.PutDefense({tool:t.print(),n:1}) );
		appendNotify( Text.fmt.UsedPA({n:1}) );
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsidePutDefense( {name:App.user.print(),tool:t.print()} ), App.user.getMapForDisplay(), zone );
		t.delete();
		success(t);
	}

	function doGetChristmasStory(t:Tool) {
		var bdata = Std.random(2) == 0 ? XmlData.getBookData("xmasst") : XmlData.getBookData("Epitc");
		var res = db.Book.create(App.user,bdata);
		notify( Text.fmt.UnlockedBook({tool:t.print(), title:res.b.print()}) );
		if(res.newBook) {
			appendNotify( Text.get.UnlockedBookNew );
			GhostReward.gain( GR.get.rp );
		}
		t.delete();
		App.goto("ghost/city?go=ghost/books?bkey="+res.b.data.key);
	}
	
	function doEatChristmasCandy(t:Tool) {
		var n = Std.random(100);
		notify( Text.fmt.ChristmasCandy( { tool:t.print() } ) );
		db.GhostReward.specialGain( GR.get.cobaye, App.user, 1);
		t.delete();
		if(n < 50) {
			App.user.terrorize(false);
			appendNotify(Text.get.ChristmasCandy_Terrorized);
		} else if(n < 80) {
			if(App.user.infect(false))
				appendNotify(Text.get.ChristmasCandy_Infected);
		} else if(n < 98) {
			App.user.isAddict = true;
			appendNotify(Text.get.ChristmasCandy_Addicted);
		} else {
			App.user.die(DT_Poison);
			App.reboot();
			return;
		}
		App.user.addPa(8);
		App.user.update();
		success(t);
	}
	
	function doOpenSafe(t:Tool) {
		if( !App.user.canDoTiringAction(1) ) {
			fail( Text.fmt.NeedPA({n:1}) );
			return;
		}
		
		App.user.doTiringAction(1);
		if( Std.random(100) < t.broken ) {
			var rep = Tool.add( t.getReplacement().toolId, App.user, t.inBag );
			var code = Std.random(8999)+1000;
			notify( Text.fmt.FoundSafeCode({code:code, tool:rep.print()}) );
			appendNotify( Text.fmt.UsedPA({n:1}) );
			t.delete();
			success(t);
		} else
			fail( Text.get.CantFindSafeCode );
	}
	
	function doUseWaterCan(t:Tool) {
		var fl_inBag = if(App.user.isOutside) true else null;
		var list = App.user.getTools(true);
		var water = null;
		for( tt in list ) {
			if( tt.key == "water" ) {
				if( !App.user.isOutside || App.user.isOutside && tt.inBag ) {
					water = tt;
					break;
				}
			}
		}
		if( water == null ) {
			doDrink(t);
		} else {
			var rep = Tool.add( XmlData.getToolByKey(t.replacement[1]).toolId, App.user, t.inBag );
			var parts = new List();
			parts.add(water);
			parts.add(t);
			notify( Text.fmt.Assembled({name:rep.print(),list:printList(parts)}) );
			water.delete();
			t.delete();
		}
		success(t);
	}
	
	function doBeta(t:Tool) {
		if( !App.BETA ) {
			fail(Text.get.Forbidden);
			return;
		}
		var n = 30;
		App.user.steps = -n;
		App.user.addPa(n);
		t.delete();
		notify( Text.fmt.GainedPA({n:n}) );
		success(t);
	}
	
	function doRemoteEat() {
		if( !App.user.map.hasMod("FOLLOW") ) return;
		var pet = db.User.manager.get( App.request.getInt("uid") );
		if( !pet.isFollower(App.user) ) {
			notify( Text.get.Forbidden );
			App.goto("outside/refresh");
			return;
		}
		
		if( pet.getPa()>=pet.maxPa() || pet.hasEaten || ZoneAction.manager.hasDoneAction(pet,"eat") ) {
			notify( Text.get.Useless );
			App.goto("outside/refresh");
			return;
		}
		
		// récupération des items utilisables pour cette action
		var list = pet.getToolsByType(Food,true,true);
		list = Lambda.filter( list, function(t) {
			return !t.hasType(Toxic) && !t.hasType(Fake);
		} );
		if( list.length==0 ) {
			notify( Text.get.PetHasNoFood );
			App.goto("outside/refresh");
			return;
		}
		
		var food = list.first();
		// priorité aux bouffes "tasty"
		for (f in list)
			if(f.hasType(Tasty) ) {
				food = f;
				break;
			}
		if( !terrorCheck(food,pet) ) {
			App.goto("outside/refresh");
			return;
		}
		
		pet.eat();
		gainFoodReward(food, pet);
		ZoneAction.add( pet, "eat" );
		if( pet.isGhoul && food.hasType(HumanMeat) ) {
			// goule mangeant de la viande humaine
			var value = if(food.key == "oldCadaver") Const.get.GFoodQuality else Const.get.GFoodBasic;
			pet.changeHunger(value, false);
		}
		else
			if( food.hasType(Tasty) )
				pet.addPa(Const.get.TastyBonus);
		notify( Text.fmt.PetEaten({user:pet.print(),tool:food.print()}) );
		food.delete();
		App.goto("outside/refresh");
	}
	
	function doRemoteDrink() {
		if( !App.user.map.hasMod("FOLLOW") ) return;
		
		var pet = db.User.manager.get( App.request.getInt("uid") );
		if( !pet.isFollower(App.user) ) {
			fail( Text.get.Forbidden );
			return;
		}
		
		var list = pet.getToolsByType(Beverage, true);
		list = Lambda.filter( list, function(t) {
			return !t.hasType(Toxic) && !t.hasType(Fake);
		} );
		if( list.length==0 ) {
			fail(Text.get.PetHasNoWater);
			return;
		}
		var water = list.first();
		if( !terrorCheck(water,pet) ) {
			App.goto("outside/refresh");
			return;
		}
		
		if( pet.hasDrunk && !pet.isDehydrated && !pet.isThirsty ) {
			fail(Text.get.PetUselessDrink);
			return;
		}
		if( pet.debt>0 ) {
			fail(Text.get.DebtForbidden);
			return;
		}
		if( !pet.isDehydrated && !pet.isThirsty && pet.paMaxed() ) {
			fail(Text.get.PetNotThirsty);
			return;
		}
		
		// msg
		if( pet.hasDrunk )
			notify(Text.get.PetUsedWaterAgain);
		else
			if( pet.isDehydrated )
				notify(Text.get.PetUsedWaterDehydrated);
			else
				notify(Text.get.PetUsedWater);
		
		if(water.key == "potion2") {
			pet.magicProtection = (Std.random(100) <= Const.get.ShamanMagicPotionChance); // < 98
		}
		
		pet.drink();
		if( water.replacement!=null && water.replacement.length>0 )
			Tool.add( XmlData.getToolByKey(water.replacement[0]).toolId, pet, water.inBag );
		
		water.delete();
		App.goto("outside/refresh");
	}
	
	function doHunt(t:Tool) {
		if( !App.user.map.hasMod("HUNTER") ) return;
		var zone = App.user.getZoneForDisplay();
		var found = zone.getSpecialDropListItem(9995, Const.get.HunterSearchChance);
		if( found != null ) {
			notify( Text.fmt.FoundObject({item:found.print()}) );
			if( App.user.hasCapacity(1) ) {
				Tool.add(found.toolId, App.user, true );
			} else {
				ZoneItem.create(zone, found.toolId, false);
				appendNotify(Text.get.NoRoomDrop);
			}
			success(t);
		} else {
			fail(Text.get.NothingFound);
		}
	}
	
	function doReadBannedNote(t:Tool) {
		if( !App.user.map.hasMod("BANNED") ) {
			notify( Text.get.BannedNoteEmpty );
			t.delete();
			success(t);
		} else {
			var map = App.user.getMapForDisplay();
			var list = db.ZoneItem.manager.getZonesWithHiddenTools( map );
			var zid = Lambda.array(list)[ Std.random(list.length) ];
			var zone = db.Zone.manager.get(zid);
			if( zone == null ) {
				notify( Text.get.BannedNoteEmpty );
			} else {
				var city = map._getCity();
				var pt = MapCommon.coords(city.x, city.y, zone.x, zone.y);
				notify( Text.fmt.BannedNote({x:pt.x, y:pt.y}) );
			}
			t.delete();
			success(t);
		}
	}

/*
	function doAcid(t:Tool) {
		var user = App.user;
		if( user.objective != "delrsc" || user.isObjectiveTooLate() ) {
			fail(Text.get.NoUse);
			return;
		}

		var rsc = user.getODataTool(0);
		var count = user.getODataInt(1);
		var list = Lambda.filter( user.getTools(true) , function(t) {
			return	( t.key == rsc.key ) &&
					( !user.isOutside || user.isOutside && t.inBag );
		} );

		if( list.length == 0 ) {
			fail( Text.fmt.Need({t:rsc.print()}) );
			return;
		}

		var target = list.first();
		Tool.add( XmlData.getToolByKey("destroyed_rsc").toolId, user, target.inBag );
		target.delete();
		count--;
		user.setOData( 1, count );

		notify( Text.fmt.RscBurnt({tool:target.print()}) );
		if( count <= 0 ) {
			appendNotify( Text.fmt.Depleted({tool:t.print()}) );
			t.delete();
		}
		success(t);
	}

	function doObjective(t:Tool) {
		if( App.user.hasObjective() ) {
			fail(Text.get.Useless);
			return;
		}
		App.user.generateObjective();
		notify(Text.get.GotNewObjective);
		t.delete();
		success(t);
	}
*/
	function doInfect(t:Tool) {
		if( App.user.isGhoul ) {
			fail(Text.get.Forbidden);
			return;
		}
		App.user.infect();
		notify( Text.fmt.Infected({tool:t.print()}) );
		t.delete();
		success(t);
	}

	function doTerror(t:Tool) {
		App.user.terrorize();
		notify( Text.get.Terrorized );
		success(t);
	}

	function doHuntRegen(t:Tool) {
		if( !App.user.map.hasMod("JOB_HUNTER") ) return;
		var wanted = App.request.get("info");
		if( wanted != "water" && wanted != "food" )
			return;
		var user = App.user;
		var map = user.map;
		
		if( user.debt > 0 ) {
			fail(Text.get.DebtForbidden);
			return;
		}
		
		if( App.user.map.hasMod("HUNTER_RESTRICTED") ) {
			var city = map._getCity();
			var coords = user.getCoords();
			if( Math.sqrt( coords.x * coords.x + coords.y * coords.y ) < 3 ) {
				fail(Text.fmt.NeedToBeFar( {n:3} ) );
				return;
			}

			var proba = if( map.days < 5 ) 			100
						else if( map.days < 10 ) 	85
						else if( map.days < 13 ) 	80
						else if( map.days < 15 ) 	70
						else if( map.days < 20 ) 	60
						else 						50;
			if( map.devastated )
				proba = 25;
			
			var success = Std.random(100) < proba;
			if( !success ) {
				fail( Text.get.HunterBookFailed, t );
				return;
			}
		}
		
		switch(wanted) {
			case "water" :
				// boire
				if( !user.isThirsty && !user.isDehydrated && user.paMaxed() ) {
					fail(Text.get.Useless);
					return;
				}
				if( user.isGhoul ) {
					notify( Text.get.GhoulWaterWound );
				} else {
					notify( Text.get.HuntedWater );
					if( !user.hasDrunk )
						if( !user.isDehydrated )
							appendNotify( Text.get.HunterRegen );
						else
							appendNotify( Text.get.HunterRegenDehydrated );
				}
				user.drink();
			case "food" :
				// manger
				if( user.hasEaten ) {
					fail(Text.get.AlreadyEaten);
					return;
				}
				if( user.paMaxed() ) {
					fail(Text.get.Useless);
					return;
				}
				notify( Text.get.HuntedFood );
				appendNotify( Text.get.HunterRegen );
				db.ZoneAction.add(user, "eat");
				user.eat();
		}
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideHunt( {name: user.print()} ), user.getMapForDisplay(), user.getZoneForDisplay() );
		success(t);
	}

	function doTamedPet(t:Tool) {
		var user = App.user;
		var map = user.getMapForDisplay();
		if( !map.hasMod("JOB_TAMER") ) return;

		var target = App.request.get("info");
		if( target != "chest" && target != "bank" && target != "drug" )
			return;
		// action : droguer le toutou
		if( target == "drug" ) {
			if( t.key != "tamed_pet" )
				return;
			var drug = user.findTool("steroid", true);
			if( drug == null ) {
				fail( Text.fmt.Need({t:XmlData.getToolByKey("steroid").print()}) );
				return;
			}
			Tool.add(XmlData.getToolByKey("tamed_pet_drug").toolId, user, t.inBag);
			t.delete();
			notify( Text.fmt.TamedPetDrug({pet:user.getPetName(), drug:drug.print()}) );
			drug.delete();
			success(t);
			return;
		}
		// action : ramener des items en ville
		var inBag = Lambda.filter( user.getInBagTools(true), function(t) { return !t.soulLocked; } );
		var inChest = user.getChestTools(false);
		if( inBag.length <= 0 ) {
			fail( Text.fmt.TamedPetNothing({pet:user.getPetName()}) );
			return;
		}
		if( !map.getDoorOpened() ) {
			fail( Text.fmt.TamedPetDoorClosed({pet:user.getPetName()}) );
			return;
		}
		// le pet non-drogué ne peut pas prendre d'encombrant
		if( t.key == "tamed_pet" )
			for( bt in inBag )
				if( bt.isHeavy ) {
					fail( Text.fmt.TamedPetCantPickUpHeavy({pet:user.getPetName()}) );
					return;
				}
		var count = inBag.length;
		switch(target) {
			case "chest" :
				// chez soi
				if( !user.hasTrunkCapacity(inBag.length) ) {
					fail( Text.fmt.NoRoomInTrunkWithCount({pet:user.getPetName(), n:inBag.length, max:user.getTrunkCapacity()-inChest.length}) );
					return;
				}
				for( bt in inBag ) {
					bt.inBag = false;
					bt.update();
				}
				notify( Text.fmt.TamedPetToChest({pet:user.getPetName()}) );
			case "bank" :
				// dans la banque
				for( bt in inBag ) {
					var i = ZoneItem.addToCity( map, bt );
					CityLog.add(
						CL_GiveInventory,
						Text.fmt.CL_GiveInventoryTamedPet({pet:user.getPetName(), name:user.print(), item:bt.print()} ),
						map,
						user );
					bt.delete();
				}
				notify( Text.fmt.TamedPetToBank({pet:user.getPetName()}) );
		}
		CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsidePetToCity( {name:App.user.print(), n:count} ), map, user.getZoneForDisplay() );
		// -> fatigué
		var rep = t.getReplacement();
		Tool.add(rep.toolId, user, t.inBag);
		t.delete();
		success(t);
	}

	function doSmokeBomb(t:Tool) {
		var zone = App.user.getZoneForDisplay();
		var map = App.user.getMapForDisplay();
		if( zone.id == map._getCity().id ) {
			fail(Text.get.ForbiddenAtDoors);
			return;
		}
		var limit = DateTools.delta( Date.now(), -DateTools.minutes(3) );
		db.CityLog.manager.replaceRecent(zone, limit, Text.get.OutsideSmoked);
		CityLog.addToZone( CL_OutsideTempEvent, Text.get.OutsideSmokeBomb, map, zone );
		ZoneAction.add( App.user, "smokeBomb");
		notify(Text.get.UsedSmokeBomb);
		success(t);
		t.delete();
	}
	
	function doThrowBall(t:Tool) {
		if( !db.GameMod.hasMod("CHRISTMAS") )
			return;
		var zone = App.user.getZoneForDisplay();
		var map = App.user.getMapForDisplay();
		if( zone.id == map._getCity().id ) {
			fail(Text.get.ForbiddenAtDoors);
			return;
		}
		var cd = 30;
		if( db.GameAction.manager.getTimeElapsed(App.user, "receivedSandBall") <= DateTools.minutes(cd) ) {
			fail( Text.fmt.SandBallDelay({n:cd}) );
			return;
		}
		var all = Lambda.list(zone.getPlayers());
		all = Lambda.filter(all, function(u) {
			return db.GameAction.manager.getTimeElapsed(u, "receivedSandBall") >= DateTools.minutes(cd);
		});
		var target : User = mt.deepnight.Lib.drawExcept(all, App.user);
		if(target == null) {
			fail(Text.fmt.BallNoTarget({n:cd}));
			return;
		}
		var target = User.manager.get(target.id, true);
		var fl_wound = map.isHardcore() && Std.random(100) < 300;
		GhostReward.gain( GR.get.sandb );
		db.GameAction.add(target, "receivedSandBall", 1);
		notify(Text.fmt.UsedSandBall( { target:target.print(), t:t.print() } ));
		if( fl_wound ) {
			target.wound(true, W_Head);
			appendNotify(Text.get.SandBallWound);
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideSandBallWound({target:target.print(), from:App.user.print()}), map, zone );
		} else
			CityLog.addToZone( CL_OutsideTempEvent, Text.fmt.OutsideSandBall({target:target.print(), from:App.user.print()}), map, zone );
		success(t);
		t.delete();
	}
	
	function doUselessDrink(t:Tool) {
		if( !db.GameMod.hasMod("CHRISTMAS") )
			return;
		notify(Text.get.DrankUselessThing);
		t.delete();
		success(t);
	}

	function doUnlockBuilding(t:Tool) {
		var user = App.user;
		var map = user.getMapForDisplay();
		if( user.isOutside ) {
			fail(Text.get.UsePlanInTown);
			return;
		}
		// tirage
		var knownHash = db.CityBuilding.manager.getKnownBuildingsHash(map);
		var rarity = switch(t.key) {
			case "bplan_c"	: data.Drop.c;
			case "bplan_u", "bunker_bplan_u", "hospital_bplan_u", "hotel_bplan_u"	: data.Drop.u;
			case "bplan_r", "bunker_bplan_r", "hospital_bplan_r", "hotel_bplan_r"	: data.Drop.r;
			case "bplan_e", "bunker_bplan_e", "hospital_bplan_e", "hotel_bplan_e"	: data.Drop.e;
			default		: throw "invalid blueprint !";
		}
		
		var pool = switch(t.key) {
			case "bunker_bplan_u", "bunker_bplan_r", "bunker_bplan_e" :
				Lambda.filter( tools.ExploTool.getBuildings( Bunker ), function(b) {
					return b != null && b.drop == rarity && !knownHash.exists(b.key) && (b.parent == "" || knownHash.exists(b.parent));
				});
			case "hospital_bplan_u", "hospital_bplan_r", "hospital_bplan_e" :
				Lambda.filter( tools.ExploTool.getBuildings( Hospital ), function(b) {
					return b != null && b.drop == rarity && !knownHash.exists(b.key) && (b.parent == "" || knownHash.exists(b.parent));
				});
			case "hotel_bplan_u",  "hotel_bplan_r", "hotel_bplan_e" :
				Lambda.filter( tools.ExploTool.getBuildings( Hotel ), function(b) {
					return b != null && b.drop == rarity && !knownHash.exists(b.key) && (b.parent == "" || knownHash.exists(b.parent));
				});
			case "bplan_c", "bplan_u", "bplan_r", "bplan_e":
				Lambda.filter( XmlData.buildings, function(b) {
					return b != null && b.drop == rarity && !knownHash.exists(b.key) && (b.parent == "" || knownHash.exists(b.parent));
				});
			default	: throw "invalid plan !";
		}

		if( pool.length == 0 ) {
			fail(Text.get.NoBuildingLeft);
			t.delete();
		} else {
			var binfos = Lambda.array(pool)[ Std.random(pool.length) ];
			if( !knownHash.exists(binfos.key) ) {
				// nouveau chantier !
				db.CityBuilding.unlock(map, binfos);
				var deps = binfos.printParents();
				notify( Text.fmt.UnlockedBuilding({b:binfos.print(), deps:deps}) );
				CityLog.add( CL_NewBuilding, Text.fmt.CL_UnlockedBuilding({user:user.print(), b:binfos.print(), deps:deps}), map, user);
			} else {
				// déjà connu :(
				notify( Text.fmt.BuildingAlreadyUnlocked({b:binfos.print()}) );
				CityLog.add( CL_NewBuilding, Text.fmt.CL_BuildingAlreadyUnlocked({user:user.print(), b:binfos.print()}), map, user);
			}
			success(t);
			t.delete();
		}
	}
	
	function doGetBuildingPlan( t : Tool ) {
		var map = App.user.getMapForDisplay();
		var rlist = new mt.deepnight.RandList();
		rlist.setFastDraw();
		rlist.add(XmlData.getToolByKey("bplan_c"), 1000);
		rlist.add(XmlData.getToolByKey("bplan_u"), 600);
		rlist.add(XmlData.getToolByKey("bplan_r"), 150);
		// limitation des plans epiques par partie
		var epicDrops = db.MapVar.getValue(map, "epicDrops", 0);
		if( epicDrops < 5 )
			rlist.add(XmlData.getToolByKey("bplan_e"), 50);
		else
			rlist.add(XmlData.getToolByKey("bplan_r"), 20);
		
		var plan = rlist.draw();
		if( plan.key == "bplan_e" )
			db.MapVar.setValue(map, "epicDrops", epicDrops + 1);
		Tool.add(plan.id, App.user, t.inBag);
		notify(Text.fmt.GotPlan( {t:plan.print()} ));
		success(t);
		t.delete();
	}
	
	function doCancelGhoul(t:Tool) {
		var user = App.user;
		if( !user.map.hasMod("GHOUL_VACCINE") )
			return;
		
		if( handCheck(t) ) return;
		if( !user.cancelGhoul() ) {
			fail( Text.get.CantVaccineNoGhoul );
			return;
		}
		notify( Text.get.GetVaccinatedFromGhoul );
		success(t);
		t.delete();
		//TODO add a log ?
	}

	/**
	 * Action du chaman qui consiste à pouvoir hanter une âme pure. 
	 * Cela ayant pour but de contaminer un autre citoyen qui viendrait à manipuler cette objet.
	 */
	function doHauntSoul(t:Tool) {
		var user = App.user;
		var map = user.map;
		if( !db.GameMod.hasMod("SHAMAN_SOULS") )
			return;
		
		if ( !user.isShaman )
			return;
		
		var actions = user.getCharlatanActions();
		if ( actions < Const.get.ShamanHauntSoulCost ) {
			//TODO changer message d'erreur
			fail( Text.fmt.ExploCantUSeObject( { name:t.name } ), t );
			return;
		}
		//TODO transform the tool to the friend one
		user.useCharlatanActions(Const.get.ShamanHauntSoulCost);
		user.update();		
		success(t);
		//on remplace par l'autre objet mais  hanté
		var rep = t.getReplacement();
		if( rep != null )
			Tool.add(rep.toolId, user, t.inBag);
		t.delete();
	}
	
	function doAngryCat( t: Tool ) {
		var user = App.user;
		/*
		if( user.inExplo() ) {
			fail( Text.fmt.ExploCantUSeObject( { name:t.name } ), t );
			return;
		}
		*/
		
		if ( user.isOutside ) {
			if( Std.random(100) < 70 ) {
				// dehors, le chaton furieux nettoie toute la zone
				var zombies = getZombiesCount();
				if( zombies <= 0 ) {
					fail(Text.get.NoZombie);
					return;
				} else {
					killZombies(t, zombies);
					GhostReward.gain(GR.get.animal);
					t.delete();
					
					notify(Text.get.LittleCatCleanedArea);
				}
				success(t);
			} else {
				//autrement il vous a sauté à la tête, vous blessant
				user.wound(true);
				t.delete();
				
				notify(Text.get.LittleCatWound);
				success(t);
			}
		} else {
			//autrement il se comporte comme tout autre animal
			doPet( t );
		}
	}

	function doPlayGuitar( t: Tool ) {
		var user = App.user;
		var map = user.map;
		//devrait pas pouvoir arriver si XMl bien définit, mais on sécurise un peu plus
		if ( user.isOutside ) {
			return;
		}
		
		//var city = user.getCity();
		//if ( ZoneAction.manager.countLocksForZone( city, "guitar" ) > 0 ) {
		var guitarDay = db.MapVar.getValue(map, "guitar", 0);
		if( guitarDay == map.days ) {
			fail(Text.get.GuitarAlreadyUsed);
			return;
		}
		
		var allUsers = map.getUsers(true);
		var inTownUsers = Lambda.filter(allUsers, function(u) return u.isOutside == false);
		//TODO secure to not be able to use it more than once per day
		var totalPA = 0;
		for ( citizen in inTownUsers ) {
			//on crédite les joueurs d'un PA
			var paCredit = 	if( citizen.isDrugged || citizen.isDrunk || citizen.isAddict ) 2
							else 1;
			var canCredit = citizen.maxPa() - citizen.getPa();
			if( canCredit > 0 )
			{
				paCredit = mt.MLib.min(paCredit, canCredit);
				citizen.addPa(paCredit, true);
			}
			else
			{
				paCredit = 0;
			}
			totalPA += paCredit;
		}
		
		db.MapVar.setValue(map, "guitar", map.days);
		
		notify(Text.fmt.GuitarGaveCitizenEnergy( { pa:totalPA } ));
		success(t);
	}
	
	function doOldMagic(tool:db.Tool)
	{
		throw "old magic doesn't exists anymore";
	}
	
	function doMagicProtection( tool : Tool ) {
		var user = App.user;
		if( !user.magicProtection ) {
			user.magicProtection = (Std.random(100) <= Const.get.ShamanMagicPotionChance); // < 98
		} else {
			appendNotify(Text.get.ShamanMagicPotionAlreadyProtected);
		}
		
		user.drink();
		user.update();
		
		tool.delete();
		appendNotify( Text.get.ShamanMagicPotionDrink );
		success(tool);
	}
	
	function doPurifySoul( t:Tool ) {
		var u = App.user;
		var map = u.getMapForDisplay();
		
		if(!map.hasMod("SHAMAN_SOULS") || u.isOutside) {
			return;
		}
		
		if(!map.hasCityBuilding("spa4souls")) {
			fail(Text.fmt.BuildingRequired({building:XmlData.getBuildingByKey("spa4souls").name}));
			return;
		}
		
		db.GhostReward.manager.gainForAll(map, GR.get.mystic);
		db.GhostReward.gain(GR.get.collec, u, 1);
		t.delete();
		
		db.MapVar.manager.fastInc(map.id, "purifiedSouls", 1);
		map.syncHauntedSouls();
		
		appendNotify(Text.get.PurifiedSoul);
		success(t, "/home");
	}
	
	function doDecorateCity(t:Tool) {
		var user = App.user;
		var map = user.getMapForDisplay();
		var count = db.MapVar.manager.fastInc(map.id, "xmasdecorations", 1);
		
		if ( count % 5 == 0 )
		{
			var gift = 1;
			var survivors = map.getUsers(true);
			for ( c in survivors )
			{
				if ( c.dead ) continue;
				c.addHeroDays( gift, gift, false);
				c.onReceivedHeroDays();
				c.update();
			}
			CityLog.add( CL_Special, Text.fmt.CL_SpecialXMasGift({user:user.print()}), map, user);
		}
		t.delete();
		appendNotify(Text.get.XMasDecorationDone);
		success(t, "/home");
	}
}
