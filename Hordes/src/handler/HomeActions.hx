package handler;
import db.Tool;
import db.Complaint;
import Common;

class HomeActions extends Handler<Tool>{

	override function initialize() {
		inTown( "default",		doTools );
		inTown( "actions",		"home/actions.mtt" );
		inTown( "deco",			"home/deco.mtt", doDeco );
		inTown( "complaints",	"home/complaints.mtt", doComplaints );
		inTown( "setHomeMsg",	doSetHomeMsg );
		inTown( "clearHomeMsg",	doClearHomeMsg );
		inTown( "swap",			doSwap );
		inTown( "cinema",		doWatchCinema );
		inTown( "watchmen",		doWatchmen );
		inTown( "nap",			doHomeAction_nap );
		inTown( "cook",			doHomeAction_cook );
		inTown( "labo",			doHomeAction_labo );
		inTown( "clean",		doUselessAction_clean );
		inTown( "upgrade",		doUpgrade );
		inTown( "shower",		doTakeShower );
		
		App.context.complained = Complaint.manager.countComplaints(App.user) > 0;
		
		inTown( "preparePotion", doPreparePotion );
	}
	
	function doPreparePotion() {
		var user = App.user;
		var map = user.getMapForDisplay();
		
		if( !user.isShaman )
			return;
			
		var cost = Const.get.ShamanPotionCost;
		var charlatanActions = user.getCharlatanActions();
		
		if( cost > charlatanActions ) {
			notify(Text.get.ShamanNoMoreActions);
			App.goto("home");
			return;
		}
		
		var water = user.findTool("water");
		if ( water == null ) {
			notify(Text.get.ShamanNeedWaterToMakePotion);
			App.goto("home");
			return;
		}
		
		Tool.addByKey("potion2", user);
		water.delete();
		
		user.useCharlatanActions(cost);
		user.update();
		//
		notify(Text.get.ShamanMadePotion);
		App.goto( "home" );
	}

	override function findObject( id : Int, lock : Bool ) {
		return Tool.manager.get( id, lock );
	}

	override function isOwner( t : Tool ) : Bool {
        return t.userId == App.user.id;
    }

	function doWatchmen() {
		if( !App.user.hasCityBuilding("watchmen") || !App.user.hasThisJob("guardian") || db.ZoneAction.manager.hasDoneAction(App.user,"watchmen") )
			return;
			
		if( !App.user.canDoTiringAction(1) ) {
			notify(Text.fmt.NeedPA( { n:1 } ));
			App.goto("home");
			return;
		}
		
		db.ZoneAction.add(App.user, "watchmen");
		var def = 10;
		App.user.losePa(1);
		App.user.map.tempDef += def;
		App.user.map.update();
		notify(Text.fmt.UsedWatchmen( {n:def} ));
		App.goto("home");
	}

	//Thomas showers Implementation
	function doTakeShower() {
		var u = App.user;
		var map = u.getMapForDisplay();
		if( !map.hasCityBuilding("showers") )
			return;
		// On le flag pour l'attaque de minuit
		db.ZoneAction.add(u, "showers");
		notify(Text.get.TookShower);
		App.goto("home");
	}
	
	//Thomas cinema Implementation
	function doWatchCinema() {
		var user = App.user;
		if( !user.hasCityBuilding("cinema") )
			return;
		if( db.ZoneAction.manager.hasDoneAction(App.user, "cinema") )
			return;
		db.ZoneAction.add( App.user, "cinema" );
		notify(Text.get.Cinema);
		if( App.user.isTerrorized ) {
			appendNotify(Text.get.CinemaCancelTerror);
			App.user.isTerrorized = false;
			App.user.update();
		}
		App.goto("home");
	}
	
	public function doSwap() {
		var user = App.user;
		if( !App.request.exists("b") ) {
			doTools();
			return;
		}
		if( !App.request.exists("t") ) {
			doTools();
			return;
		}
		var fromBag = Tool.manager.get( App.request.getInt( "b" ) );
		if( fromBag == null ){
			doTools();
			return;
		}
		var fromTrunk = Tool.manager.get( App.request.getInt( "t" ) );
		if( fromTrunk == null ){
			doTools();
			return;
		}
		if( fromBag.soulLocked || fromTrunk.soulLocked ) {
			notify( Text.get.CantDropSoulLocked );
			doTools();
			return;
		}
		if( fromBag.hasType(Bag) ) {
			notify( Text.get.CantSwapBag );
			doTools();
			return;
		}
		if ( user.hasBagOverflow() || user.hasTrunkOverflow() ) {
			notify(Text.get.CantSwapOverflow);
			doTools();
			return;
		}
		if( fromTrunk.hasType(Bag) ) {
			for( tt in user.getInBagTools(false) ) {
				if( tt.hasType(Bag) && tt.key != "pocketBelt") {
					notify( Text.get.AddOnlyOneHeavyObject );
					doTools();
					return;
				}
			}
		}
		if( fromTrunk.isHeavy ) {
			for( tt in user.getInBagTools(false) ) {
				if( tt.isHeavy ) {
					notify( Text.get.AddOnlyOneHeavyObject );
					doTools();
					return;
				}
			}
		}

		fromBag.inBag = false;
		fromBag.update();
		fromTrunk.inBag = true;
		fromTrunk.update();
		doTools();
	}

	public function doUpgrade() {
		var user = App.user;
		prepareTemplate(  "home/upgrade.mtt" );
		var fl_devast = user.getMapForDisplay().devastated;
		
		if( App.request.exists("hk") && !fl_devast ) {
			// On récupère le niveau accessible de l'upgrade en cours
			var upgrade = HomeUpgradeXml.getByKey( App.request.get("hk") );
			if( upgrade == null )
				notify( Text.get.H_UnknownUpgrade );
			else {
				var done = db.HomeUpgrade.manager.getUpgradeByUser( user, upgrade );
				if( done == null )
					// cas du premier niveau de cet upgrade
					tryToUpgrade( upgrade, upgrade.level, user, 1 );
				else {
					// cas des niveaux supérieurs
					var level = done.level;
					var maxPossibleLevels = upgrade.levels.length + 1;
					// on a déjà atteint le niveau max, on ne peut pas aller plus haut
					if( level >= maxPossibleLevels ) {
						notify( Text.fmt.H_MaxLevelReached( { n:upgrade.name } ) );
					}
					else { // on peut aller plus haut
						var i = 1;
						for( l in upgrade.levels ) {
							if( i++ == level ){
								tryToUpgrade( upgrade, l, user, i );
								break;
							}
						}
					}
				}
			}
		}

		var all = HomeUpgradeXml.getAll();
		var done = db.HomeUpgrade.manager.getUpgradesByUser( user );
		var remaining = all;
		var au = new List();
		var userTools = user.getTools();
		var alreadyDone = new Hash();

		// on récupère la liste des niveaux d'upgrade à réaliser
		if( done.length > 0 ) {
			for( upgrade in remaining ) {
				for( d in done ) {
					var dkey = mt.db.Id.decode(d.upkey);
					alreadyDone.set( dkey, true );
					if( dkey == upgrade.key ) {
						var reqsOk = true;
						// S'il n'y a qu'un level, on l'ajoute pour montrer qu'il a été réalisé
						if( upgrade.levels.length <= 0 ) {
							var paOK = upgrade.level.pa <= user.getPa();
							au.add(  { done:true, infolevel : upgrade.level, next:false, info:upgrade, level : 1, paOK : paOK, reqsOK : reqsOk } );
							continue;
						}
						
						// si on a déjà atteint le dernier niveau d'un upgrade
						if( d.level == upgrade.levels.length + 1) {
							var paOK = upgrade.level.pa <= user.getPa();
							au.add(  { done:true, infolevel: upgrade.level, next:false, info:upgrade, level : upgrade.levels.length + 1, paOK : paOK, reqsOK : reqsOk } );
							continue;
						}
						
						// si on a encore des levels sur un upgrade, on affiche les prochains à réaliser
						var i = 1;
						for( l in upgrade.levels ) {
							var currentLevel = i + 1;
							if( currentLevel > d.level ) {
								var paOK = upgrade.level.pa <= user.getPa();
								au.add(  { done:false, infolevel: l, next:true, info:upgrade, level : currentLevel, paOK : paOK, reqsOK : reqsOk } );
								break;
							}
							i++;
						}
					}
				}
			}
		}

		// on récupère la liste des autres upgrades à débuter
		for( upgrade in remaining ) {
			if( alreadyDone.exists( upgrade.key ) ) continue;

			var paOK = upgrade.level.pa <= user.getPa();
			var reqsOk = true;
			var reqs = upgrade.level.reqs;
			if( reqs.length > 0 ) {
				for( req in reqs ) {
					var tool = XmlData.getToolByKey( req.key );
					if( tool != null ) {
						if( !user.hasToolCount( req.key, req.n ) ) {
							reqsOk = false;
							break;
						}
					}
				}
			}
			au.add(  { done:false, infolevel: upgrade.level, next:true, info : upgrade, level : 1, paOK : paOK, reqsOK : reqsOk} );
		}
		
		var auArray = Lambda.array(au);
		auArray.sort( function(a,b) {
			if ( a.info.name>b.info.name ) return 1;
			if ( a.info.name<b.info.name ) return -1;
			return 0;
		});
		
		App.context.upgrades = all;
		App.context.availableUpgrades = auArray;
		App.context.devastated = fl_devast;
		
		// On récupère enfin l'upgrade global de maison
		var hu = XmlData.homeUpgrades[App.user.homeLevel+1];
		if ( hu!=null )
			App.context.hu = hu;
	}

	public function doTools() {
		prepareTemplate( "home/tools.mtt");

		var user = App.user;
		var tools = user.getTools();
		App.context.actions = user.getToolActions("town",tools);
		App.context.homeActions = db.HomeUpgrade.manager.getAvailableActions( user );
		App.context.rescueList = db.User.getRescueList(user, user.getMapForDisplay());
		App.context.hasRobinet = user.hasCityBuilding("robinet");
		App.context.hasWatchmen = user.hasCityBuilding("watchmen") && user.hasThisJob("guardian") && !db.ZoneAction.manager.hasDoneAction(user,"watchmen");
		//Thomas cinema Implementation
		App.context.hasCinema = user.hasCityBuilding("cinema") && !db.ZoneAction.manager.hasDoneAction(user, "cinema");
		//Thomas infirmary Implementation
		App.context.hasInfirmary = user.hasCityBuilding("infirmary") && !db.ZoneAction.manager.hasDoneAction(user,"infirmary") && (user.isWounded||user.isInfected);
		//Thomas showers Implementation
		App.context.hasShowers = user.hasCityBuilding("showers") && !db.ZoneAction.manager.hasDoneAction(user, "showers");
		//Thomas scouts Implementation
		App.context.hasScouts = user.hasThisJob("eclair") && user.hasCityBuilding("scouts") && !db.ZoneAction.manager.hasDoneAction(user, "scouts");
		
		App.context.townPortalLimit = Const.get.MaxTownPortalDistance;
		App.context.inv = Lambda.filter( tools, function( t : Tool ) { if ( t.inBag ) return false; return true; } );
		
		var hasWater = false;
		for( t in tools ) {
			if( t.hasType( Beverage ) ) {
				hasWater = true;
				break;
			}
		}
		App.context.hasWater = hasWater;
		// active le swap d'objets
		var hasTrunkCapacity = !user.hasTrunkCapacity();
		App.context.hasTrunkCapacity = hasTrunkCapacity;
		App.context.exchangeMode = !user.hasCapacity() && hasTrunkCapacity;
		App.context.def = user.getHomeDefense();
		App.context.deco = user.getDecoScore();
		App.context.day = user.getMapForDisplay().days;

		CityActions.addLogs(user, user.getMapForDisplay());
	}

	public function doDeco() {
		var dlist = App.user.getToolsByType(Furniture);
		App.context.deco = dlist.filter( function(tool) {
			return !tool.inBag;
		});
	}

	function doComplaints() {
		var cc = Lambda.list( Complaint.manager.getComplaints(App.user) );
		var cpt = 0;
		for( c in cc ) {
			cpt += c.cpt;
		}
		App.context.complaints = cc;
		App.context.cpt = cpt;
	}

	function doSetHomeMsg() {
		if( App.user.muted ) {
			notify( Text.get.Muted );
			App.goto( "home");
			return;
		}

		var msg = tools.Utils.sanitize( App.request.get("msg",""), 65 );
		App.user.homeMsg = if(msg != "") msg else null;
		App.user.update();
		if( msg != "" )
			notify( Text.get.ChangedHomeMessage );
		App.goto("home");
	}

	function doClearHomeMsg() {
		App.user.homeMsg = null;
		App.user.update();
		App.goto("home");
	}

	function tryToUpgrade( upgrade : HUpgrade, level :HUpgradeLevel, user : db.User, levelIndex ) {
		if( !user.hero ) {
			notify(Text.get.NowYouWishedYouWereAHero);
			return;
		}

		if(  (user.getPc()+user.getPa()) < level.pa ) {
			notify( Text.fmt.H_NotEnoughPA( { n:upgrade.name, l:levelIndex, pa : level.pa - user.getPa() } ) );
			return;
		}

		var ok = true;
		var tools = user.getTools(true);
		if( level.reqs.length > 0 ) {
			// pas de ressources
			if( tools.length <= 0 )
				ok = false;
			else {
				// les ressources sont-elles suffisantes ?
				for( r in level.reqs ) {
					var found = 0;
					var rt = XmlData.getToolByKey( r.key );
					for( t in tools )
						if( t.key == rt.key && !t.isBroken )
							found++;
					if( found < r.n ) {
						ok = false;
						break;
					}
				}
			}
			// pas assez de ressources
			if( !ok ) {
				notify( Text.fmt.H_NotEnoughReqs( { n:upgrade.name, l:levelIndex } ) );
				return;
			}
		}

		db.HomeUpgrade.add( user, upgrade );
		user.homeDefense += level.def;
		if( level.hide ) user.homeHidden = true;
		if( level.lock ) user.homeSafe = true;
		if( level.alarm ) user.homeAlarm = true;
		user.homeCapacity += level.cap;
		
		var neededPa = level.pa;
		var pc = user.getPc();
		if( pc > 0 ) {
			var pcCost = mt.MLib.min(neededPa, pc);
			user.usePc(pcCost);
			neededPa -= pcCost;
		}
		user.losePa( neededPa ); // l'update est compris :)
		// on vire les objets si nécessaire
		if( level.reqs.length > 0 ) {
			for( r in level.reqs ) {
				var need = r.n;
				var key = r.key;
				for( t in tools ) {
					if( need <= 0 )
						break;
					if( t.key == key && need > 0 && !t.isBroken) {
						t.delete();
						need--;
					}
				}
			}
		}
		db.GhostReward.gain(GR.get.hbuild);
		notify( Text.fmt.H_UpgradeDone( { n:upgrade.name, l:levelIndex } ) );
	}

	function canDoHomeAction(act, upgrade) {
		var limit = HomeUpgradeXml.getLimit(upgrade.info,upgrade.level);
		//trace("limit="+limit);
		var user = App.user;
		if( !user.hero ) {
			notify( Text.get.NowYouWishedYouWereAHero );
			App.goto("home");
			return false;
		}
		if( !db.HomeUpgrade.manager.hasAvailableAction( user, act ) ) {
			notify( Text.get.Forbidden );
			App.goto("home");
			return false;
		}
		if( db.ZoneAction.manager.hasDoneCountedActionZone(user,act,limit) ) {
			if( limit==1 )
				notify( Text.get.AlreadyDone);
			else
				notify( Text.fmt.AlreadyDoneCounted({n:limit}) );
			App.goto("home");
			return false;
		}
		return true;
	}


	/*------------------------------------------------------------------------
	SPECIAL HOME ACTIONS (upgrades)
	------------------------------------------------------------------------*/
	public function doHomeAction_nap() {
		var actName = "nap";
		var up = db.HomeUpgrade.manager.getUpgradeByKey(App.user,actName);
		if( up==null ) {
			App.goto("home");
			return;
		}
		if( !canDoHomeAction(actName,up) ) return;

		if( App.user.paMaxed() ) {
			notify(Text.get.Useless);
			App.goto("home");
			return;
		}

		db.ZoneAction.add( App.user, actName, true );
		var chance = if(up.level<3) up.level*33 else 100;
		if( Std.random(100)<chance ) {
			notify( Text.fmt.NapSuccess({n:Const.get.NapGain}) );
			App.user.addPa(Const.get.NapGain);
		} else {
			notify( Text.get.NapFailed );
		}
		App.goto("home");
	}


	public function doHomeAction_cook() {
		var actName = "cook";
		var up = db.HomeUpgrade.manager.getUpgradeByKey(App.user,actName);
		if( up == null ) {
			App.goto("home");
			return;
		}
		if( !canDoHomeAction(actName,up) ) return;
		
		var foods = App.user.getToolsByType(Food, false, Fake);
		foods = Lambda.filter(foods, function(t) {
			return t.key!="dish" && !t.hasType(Tasty) && !t.inBag;
		});
		if( foods.length==0 ) {
			notify( Text.get.NeedFood );
			App.goto("home");
			return;
		}
		db.ZoneAction.add( App.user, actName, true );
		var chance = up.level * 33 + 1;
		var base = foods.first();
		var dish : Tool;
		if( Std.random(100) < chance ) {
			dish = XmlData.getToolByKey("dish_tasty");
			db.GhostReward.gain(GR.get.cookr);
		} else {
			dish = XmlData.getToolByKey("dish");
		}
		Tool.add( dish.toolId, App.user, base.inBag );
		notify( Text.fmt.Cooked({t:base.print(), dish:dish.print()}) );
		base.delete();
		App.goto("home");
	}

	public function doHomeAction_labo() {
		var actName = "labo";
		var up = db.HomeUpgrade.manager.getUpgradeByKey(App.user,actName);
		if( up == null ) {
			App.goto("home");
			return;
		}
		if ( !canDoHomeAction(actName,up) ) return;

		var drug = null;
		var drug2 = null;
		for( t in App.user.getTools(true) ) {
			if( !t.inBag && t.key == "pharma" ) {
				if( drug == null ) {
					drug = t;
				} else {
					drug2 = t;
					break;
				}
			}
		}
		if( drug == null || drug2 == null ) {
			notify( Text.fmt.NeedInChest({t:XmlData.getToolByKey("pharma").print(),n:2}) );
			App.goto("home");
			return;
		}

		db.ZoneAction.add( App.user, actName, true ); // no limit (sauf les stocks)
		var chance = Math.min(100, up.level * 25);
		var result : Tool;
		if( Std.random(100) < chance ) {
			result = XmlData.getToolByKey("tastyDrug");
			notify( Text.fmt.CookedDrugSuccess( { t:drug.print(), n:2, result:result.print() } ) );
			db.GhostReward.gain(GR.get.drgmkr);
		} else {
			result = drug.getReplacement();
			notify( Text.fmt.CookedDrugFailed({t:drug.print(), n:2, result:result.print()}) );
		}
		Tool.add( result.toolId, App.user, false );
		drug.delete();
		drug2.delete();
		App.goto("home");
	}


	public function doUselessAction_clean() {
		if( db.ZoneAction.manager.hasDoneAction(App.user, "cleanUp") )
			return;
		db.ZoneAction.add( App.user, "cleanUp" );
		notify( Text.get.CleanedUpHome );
		App.goto("home");
	}
}
