package db;
import mt.db.Types;
import Common;
import db.MapVar;
import neko.Lib;

using mt.Std;
using Lambda;
using Std;

enum MapFlags {
	SHAMAN_ELECTION;
	GUIDE_ELECTION;
}

class Map extends neko.db.Object {

	static var INDEXES = [["status"],["days"],["inPool","level"]];
	static var RELATIONS = function(){
		return [
			{ key : "catapultMasterId",	prop : "catapultMaster",	manager : User.manager, lock : false },
		];
	}
	
	static var PRIVATE_FIELDS = [ "builtBuildings", "attackLog", "cachedCityDefense" ] ;
	
    public static var manager  = new MapManager();
	
    public var id(default, null)		: SId;
	public var hardcore					: SBool;
    public var status					: SInt;
	public var days						: SInt;
	public var lastAttack				: SNull<SDateTime>; // dernière attaque dans le CRON
	public var endDate					: SNull<SDate>;
	public var event					: SNull<SInt>;
	public var name						: SString<50>;
	public var water					: SInt;
	public var diff						: SNull<SFloat>;
	public var cityId					: SInt;
	public var width					: SInt;
	public var maxZoneLevel				: SInt;
	private var doorOpened				: SBool;
	public var devastated				: SBool;
	public var countP					: SInt; // nombre de joueurs
	public var volunteers				: SInt; // nombre d'inscrits non-aléatoires
	public var level					: SInt;	// Niveau d'âme minimum pour rejoindre cette carte
	public var chaos					: SBool;
	public var inPool					: SBool; // pool
	public var forumId					: SInt;
	public var estimCount				: SInt;
	public var catapultMaster(dynamic, dynamic) : SNull<User>;
	public var conspiracy				: SFloat;
	public var affectedZones			: SNull<SBinary>;
	public var heroMsg					: SNull<SText>;
	public var availableForJoin			: SBool;
	public var password					: SNull<SString<16>>;
	public var tempDef					: SInt;
	public var builtBuildingsBlob		: SNull<SBinary>; // Bâtiments déjà contruits une fois au cours de la partie
	public var builtBuildings			: Hash<Bool>;
	public var attackLogBlob			: SNull<SBinary>;
	public var attackLog				: String;
	public var openDate					: SNull<SDateTime>;
	public var season					: SInt;
	public var flags					: SFlags<MapFlags>;

	public var cachedCityDefense(default, null) : {
			total		: Int,
			temp		: Int,
			buildings	: Int,
			upgradeInfos: {total:Int,list:Array<String>},
			itemInfos	: {total:Int, items:Int, mul:Float},
			userInfos	: {homes:Int, guards:Int, count:Int, total:Int},
			cityOnly	: Int,
			cadavers	: Int,
			guardiansInfos 	: { guardians : Int, def : Int },
			bonus		: Int 
	};
	
	public function new(?rnd:Int->Int) {
		super();
		//
		if(rnd == null) rnd = Std.random;
		//
		width = Const.get.MapWidthStd;
		status = Type.enumIndex( MapIsVirgin );
		days = 1;
		countP = 0;
		volunteers = 0;
		doorOpened = false;
		water = Const.get.MapWater + rnd(Const.get.MapRandWater);
		maxZoneLevel = 0;
		event = null;
		inPool = false;
		openDate = null;
		season = 0;
		tempDef = 0;
		flags = SFlags.ofInt(0);
		// CACHE
		builtBuildings = new Hash();
	}
	
	public function getRegenChance() {
		return	if( hasCityBuilding("regen") )
					Std.int( CityUpgrade.getValueIfAvailableByKey("regen", this, Const.get.MapBaseRegen) );
				else
					Const.get.MapBaseRegen;
	}
	
	/**
	 * This function considers that there's no more shaman in the city.
	 * DO NOT call it before having shaman existence tested !
	 */
	public function doElections(pIsFirstDay:Bool, ?pDeads:List<User>) {
		var needNewShaman = isShamanElection();
		var needNewGuide  = isGuideElection();
		var excludedUsers = pDeads != null ? Lambda.array(pDeads) : [];
		if( !needNewGuide && !needNewShaman )
			return [];
		
		App.configureTemplo();
		
		var elections = [];
		if( needNewShaman ) elections.push(SHAMAN_ELECTION);
		if( needNewGuide ) elections.push(GUIDE_ELECTION);
		
		var fullDialogs = new Array<ElectionDialog>();
		var dialogs:Array<{u:String,text:String,depth:Int}> = [];
		function parseDialog(xml:haxe.xml.Fast, pCitizens:Array<String>) {
			var copy = pCitizens.copy();
			var d: ElectionDialog = { t:[], a:[] };
			for ( t in xml.nodes.t ) {
				d.t.push(t.innerHTML);
			}
			
			if ( xml.has.u ) 	d.u = xml.att.u;
			else 				d.u = copy[Std.random(copy.length)];
			//that user should not be part of the discussion after that
			copy.remove(d.u);
			
			if ( xml.hasNode.a ) {
				for ( a in xml.node.a.nodes.d ) {
					var dd = parseDialog(a, copy);
					d.a.push( dd );
					copy.remove(dd.u);
				}
			}
			
			if ( xml.has.count ) 
				d.count = Std.parseInt(xml.att.count);
			return d;
		}
		
		for( election in elections ) {
			var electedUser, talker, playerA, fayot, target, target2;
			var minCitizens = 6;
			// on récupère tous les joueurs encore vivants
			var allUsers = getUsers(false, false);
			if( allUsers.length == 0 ) {
				break;
			}
			// remove deads etc..
			allUsers = Lambda.filter(allUsers, function(u) { return !Lambda.has(excludedUsers, u); } ).array();
			
			if( allUsers.length == 0 ) {
				break;
			}
			//
			var allUids = Lambda.map(allUsers, function(u) return u.id);
			var electionVotes:Array<{user:db.User, votes:Int}> = switch( election ) {
				case SHAMAN_ELECTION : db.UserVar.manager.getAll(allUids, "shamanVote").map(function(uv) return { user:uv.user, votes:uv.value }).array();
				case GUIDE_ELECTION  : db.UserVar.manager.getAll(allUids, "guideVote").map(function(uv) return { user:uv.user, votes:uv.value }).array();
			}
			electionVotes.sort( function(a, b) return b.votes - a.votes );
			// On rajoute un peu de perturbation en prenant des joueurs "actifs"
			// On ne prend que les citoyens qui sont en ville !
			var otherCitizens = Lambda.filter(allUsers, function(u) {
				for ( u2 in electionVotes )
					if ( u2.user.id == u.id )
						return false;
				if( u.isShaman || u.isGuide || u.isOutside ) 
					return false;
				return true;
			}).array();
			
			// on "complète" les joueurs qui n'ont pas votés !  La différence votants/electeurs, se répartie aléatoirement parmis un set de joueurs à élire !
			var votesSum = 0;
			for ( v in electionVotes ) {
				votesSum += v.votes;
			}
			
			var chaosCount = mt.MLib.max(0, 6 - electionVotes.length);
			for (i in 0...chaosCount) {
				//TODO find something smarter than random here. More qualified user, active, hero, in progress... anything
				var u = otherCitizens[Std.random(otherCitizens.length)];
				if ( u == null ) break;
				electionVotes.push( { user:u, votes:0 } );
				otherCitizens.remove(u);
			}
			// on calcule ici le nombre de votants qui se sont abstenus ! (ou camping etc.)
			var missingVotes = allUsers.length - votesSum;
			for ( i in 0...missingVotes ) {
				var u = electionVotes.getRandom();
				if( u != null ) u.votes ++;
			}			
			// on fait un nouveau tri - decroissant
			electionVotes.sort( function(a, b) return b.votes - a.votes);
			
			if( electionVotes.length == 0 ) {
				//no election possible
				break;
			}
			
			if (electionVotes.size() > 0) {
				electedUser = electionVotes.shift().user;
			}
			if (electionVotes.size() > 0) {
				var u = electionVotes.shift().user;
				talker = u.name;
			}
			if (electionVotes.size() > 0) {			
				var u = electionVotes.shift().user;
				playerA = u.name;
			}
			if (electionVotes.size() > 0) {
				var u = electionVotes.shift().user;
				fayot = u.name;
			}
			if (electionVotes.size() > 0) {	
				var u = electionVotes.shift().user;
				target = u.name;
			}
			if (electionVotes.size() > 0) {
				var u = electionVotes.shift().user;
				target2 = u.name;
			}
			
			var carray = otherCitizens.map(function(c) return c.name).array();
			var template = new templo.Loader("assembly_dialogs.mtt", Config.defined("cachetpl"));
			
			var context:Dynamic = { hasDied:!pIsFirstDay, minCitizens:minCitizens, talker:talker, playerA:playerA, fayot:fayot, target:target, target2:target2 };
			if( electedUser != null ) context.elected = electedUser.name;
			if( otherCitizens != null ) context.citizens = otherCitizens.length;
			
			switch( election ) {
				case SHAMAN_ELECTION : context.shaman = true;
				case GUIDE_ELECTION  : context.guide = true;
			}
			context.firstElection = fullDialogs.length == 0;
			
			var fromDialog = fullDialogs.length;
			var xml = new haxe.xml.Fast(Xml.parse(template.execute(context)).firstElement());
			for ( d in xml.nodes.d ) {
				fullDialogs.push(parseDialog(d, carray.copy()));
			}
			
			function talk(d:ElectionDialog, pCount:Int, pDepth:Int) {			
				var tcopy = d.a.copy();
				var count = pCount;
				if(d.count != null)
					count += d.count;
				
				dialogs.push({u:d.u, text:d.t[Std.random(d.t.length)], depth:pDepth});
				for(i in 0...count) {
					//condition de sortie, on a écrit le nombre de texte souhaité
					//ou bien on a plus de textes ici à afficher
					if ( count == 0 || tcopy.length == 0 ) 
						break;
					
					var r = tcopy[Std.random(tcopy.length)];
					if ( r.u == null )
						break;
					
					count = talk(r, count-1, pDepth + 1); 
					tcopy.remove(r);
				}
				return count;
			}
			
			for (i in fromDialog...fullDialogs.length) {
				var d = fullDialogs[i];
				talk(d, 1, 0 );
			}
			
			switch( election ) {
				case SHAMAN_ELECTION:
					//TODO add notifications !
					// and something to redirect the user to an explanation page !
					if (electedUser != null) {
						var u = db.User.manager.get(electedUser.id, true);
						u.isShaman = true;
						u.addCharlatanActions(Const.get.ShamanDailyActions);
						
						var tpl = new templo.Loader("msg/shaman.mtt", Config.defined("cachetpl"));
						var msgHtml = tpl.execute( { } );
						u.setAdminMsg(msgHtml, true);
						u.update();
						
						flags.unset(SHAMAN_ELECTION);
						db.UserVar.manager.deleteAllVars("shamanVote", allUids);
					}
					
				case GUIDE_ELECTION :
					if (electedUser != null) {
						var u = db.User.manager.get(electedUser.id, true);
						u.isGuide = true;
						var tpl = new templo.Loader("msg/guide.mtt", Config.defined("cachetpl"));
						var msgHtml = tpl.execute( { } );
						u.setAdminMsg(msgHtml, true);
						u.update();
						
						flags.unset(GUIDE_ELECTION);
						db.UserVar.manager.deleteAllVars("guideVote", allUids);
					}
			}
			
			if ( electedUser != null ) excludedUsers.push(electedUser);
			
		}
		
		return dialogs;
	}
	
	public function addUser(u:db.User) {
		u.reset();
		u.map = this;
		u.mapRegisterDay = days;
		u.zone = _getCity();
		countP ++;
		//
		var eVar = MapVar.manager.search( { name:"init", mapId:this.id }, true).first();
		if( eVar == null ) {
			onFirstPlayerJoin();
			db.MapVar.setValue(this, "init", 1);
		}
		
		if( UserVar.getValue(u, "mapInvit", 0) == this.id ) {
			UserVar.delete(u, "mapInvit");
		}
			
		if( hasFlag("officialMapGoal") ) {
			var goal = GR.getById(getVarValue("officialMapGoal"));
			if( goal != null )
				GhostReward.gainByUser( goal, u, 1 );
		}
		//
		u.update();
		onPlayerJoin(); //l'update se fait ici !
	}
	
	public function getVarValue( varName : String ) : Int {
		return MapVar.getValue(this, varName );
	}
	
	public function hasFlag( flagName : String ) : Bool {
		return MapVar.manager.hasVar(this, flagName.toLowerCase() );
	}
	
	public function hasRoomForVolunteers(n:Int) {
		return isCustom() || (volunteers+n) <= getMaxVolunteers();
	}
	
	public inline function getMaxVolunteers() {
		return	if( needPassword() || isHardcore() ) 40
				else Std.int( Math.min(40, Version.getVar("maxVolunteers")) );
	}
	
	public function syncHauntedSouls()
	{
		//var soul = XmlData.getToolByKey("soul");
		var hauntedSoul = XmlData.getToolByKey("red_soul");
		var l = new List();
		l.add(hauntedSoul.toolId);
		var toolSouls = db.Tool.manager.getMapUserTools(this, l, true, true);
		var zoneSouls = db.ZoneItem.manager.getAllToolsInMap(this, hauntedSoul.toolId, true);
		var soulsInExplo = db.ExploItem.manager.getAllToolsInMap(this, hauntedSoul.toolId);
		
		var count = toolSouls.length;
		for ( s in zoneSouls ) count += s.count;
		for ( s in soulsInExplo ) count += s.count;
		
		db.MapVar.setValue(this, "hauntedSouls", count);
	}
	
	public function onFirstPlayerJoin() {
		// initialisations au premier inscrit
		initBuildings();
		MapGenerator.addExploBuildings(this, _getOutsideDescription());
		season = App.getDbVar("season");
		// plans rares
		var allZones = db.Zone.manager.getZoneIds(this, Std.int(Const.get.MapWidthStd / 2), Const.get.MapWidthStd + Const.get.MaxMapWidthGrow);
		var tool = XmlData.getToolByKey("bplan_box");
		if( allZones.length > 0 ) {
			var count = 5;
			for( i in 0...count ) {
				if( MapVar.getValue(this, "bplan_box" ) >= count ) continue;
				var zone = db.Zone.manager.get( allZones.splice(Std.random(allZones.length), 1)[0], false );
				db.ZoneItem.create(zone, tool.toolId);
				MapVar.manager.fastInc( this.id, "bplan_box", 1 );
			}
		}
		// plan épique
		// Fix for RNE where there's not far enough valid zone. So we ensure that the CAS is present.
		var minDistance = Const.get.MapWidthStd - Const.get.MaxMapWidthGrow;
		var allZones = [];
		while( allZones.length == 0 )
			allZones = db.Zone.manager.getZoneIds(this, minDistance--, 99);
		
		var tool = XmlData.getToolByKey("bplan_box_e");
		if( allZones.length > 0 ) {
			var count = 2;
			for( i in 0...count ) {
				if( MapVar.getValue(this, "bplan_box_e" ) >= count ) continue;
				var zone = db.Zone.manager.get( allZones.splice(Std.random(allZones.length), 1)[0], false );
				db.ZoneItem.create(zone, tool.toolId);
				MapVar.manager.fastInc( this.id, "bplan_box_e", 1 );
			}
		}
		
		if( hasMod("FIREWORK") ) {
			// Event du "feu d'artifice toxique"
			var allZones = db.Zone.manager.getZoneIds(this, 5, 14);
			// poudre
			var zone = db.Zone.manager.get( allZones.splice(Std.random(allZones.length), 1)[0], false );
			db.ZoneItem.create( zone, XmlData.getToolByKey("firework_powder").toolId );
			// tube
			var zone = db.Zone.manager.get( allZones.splice(Std.random(allZones.length), 1)[0], false );
			db.ZoneItem.create( zone, XmlData.getToolByKey("firework_tube").toolId );
			// box 1
			var zone = db.Zone.manager.get( allZones.splice(Std.random(allZones.length), 1)[0], false );
			db.ZoneItem.create( zone, XmlData.getToolByKey("firework_box").toolId );
			// box 2
			var zone = db.Zone.manager.get( allZones.splice(Std.random(allZones.length), 1)[0], false );
			db.ZoneItem.create( zone, XmlData.getToolByKey("firework_box").toolId );
		}
		update();
	}
	
	public function onPlayerJoin() {
		// fermeture des inscriptions !
		if( countP >= Const.get.MaxPlayers ) {
			status = Type.enumIndex( GameIsClosed );
			flags.set(SHAMAN_ELECTION);
			flags.set(GUIDE_ELECTION);
			availableForJoin = false;
			//
			if( !hasFlag("resetZonesScores") ) {
				db.Zone.manager.syncZonesScores(this);	
				db.MapVar.setValue(this, "resetZonesScores", 1);
			}
		}
		
		if ( forumId == null || forumId == 0 )
			Cron.createGameForums(this);
		
		update();
		// on ouvre une autre ville APRÈS l'update, sinon le count SQL ne prend pas
		// en compte la fermeture de cette ville dans openMaps().
		if( !availableForJoin )
			Map.manager.openMaps(1);
	}
	
	public function cancel() {
		for( u in User.manager.getMapUsers(this, false, true) ) {
			u.leaveMap();
			u.setAdminMsg(Text.get.CustMapCancelled);
		}
		// remboursement ville privée
		var creator = User.manager.get(MapVar.getValue(this, "creator", 0));
		var cost = MapVar.getValue(this, "creationCost", 0);
		if( creator != null && cost > 0 ) {
			creator.heroDays += cost;
			creator.update();
		}
		status = Type.enumIndex(GameIsClosed);
		update();
	}
	
	public function isCreator( u : User ) : Bool {
		if( !isCustom() ) return false;
		return getVarValue("creator") == u.id;
	}
	
	public function hasMod(mod:String):Bool {
		return 	if( hasFlag("MOD_"+mod) ) getVarValue("MOD_"+mod) == 1
				else db.GameMod.hasMod(mod);
	}
	
	public static function getMinNoobMap() {
		var targetCount = App.getDbVar("noobMapsInPool");
		var minCount = Math.ceil(App.getDbVar("mapsInPool") * Const.get.MinNoobMap / 100);
		if ( targetCount < minCount )
			targetCount = minCount;
		return targetCount;
	}
	
	public function isFar() {
		return level >= Version.getVar("minXp");
	}
	
	//changement: en pandémonium on peut à nouveau voler la nuit pour plus de trahison!
	public function canRobBank() {
		return hasMod("NIGHTMODS") /*&& !isHardcore() */ && isFar() && App.isNight();
	}

	public function canUseAggression() {
		return isFar() || isHardcore() || hasMod("GHOULS");
	}
	
	public function getAggressionWoundChance() {
		return	if( !hasMod("GHOULS") )
					5;
				else
					if(isHardcore()) 	50
					else				25;
	}
	
	public function getAggressionCost() {
		return	if( hasMod("GHOULS") && !isHardcore() )	5;
				else									4;
	}
	
	public function getInTownRatio(ignoredPeople:Int) {
		return (db.User.manager.getInTownCount(this)-ignoredPeople) / db.User.manager.getAlivePlayersCount(this);
	}
	
	public function getGhoulDetectChance() {
		var c = Math.round(getInTownRatio(1)*100) - 10;
		c-= if( hasMod("NIGHTMODS") && App.isNight() ) 10 else 0;
		return Math.max(10, c);
	}
	
	public function openedYet() {
		return openDate==null || Date.now().getTime()>=openDate.getTime();
	}
	
	public function isBig() {
		return hasMod("BIG_MAPS") && width>=20;
	}
	
	public function getDoorOpened() {
		return devastated || doorOpened;
	}
	
	public function hasDoorOpened() {
		if( devastated )
			return true;
		if( hasCityBuilding("bigDoor") ) {
			var now = Date.now();
			var cronHour = App.getNextCronDate();
			//Thomas autoDoor Implementation
			var delay = hasCityBuilding("autoDoor") ? 1 : Const.get.BigDoorLockMin;
			var lockHour = DateTools.delta( cronHour, -DateTools.minutes(delay) );
			if( now.getTime() > lockHour.getTime() && now.getTime() <= cronHour.getTime() ) {
				if( doorOpened ) {
					var m = manager.get( id, true );
					m.doorOpened = false;
					m.update();
					CityLog.add( CL_CloseDoor, Text.fmt.CL_BigDoorLock({user:App.user.print()}), this );
					return false;
				}
			}
		}
		return doorOpened;
	}
	
	public inline function needPassword() {
		return password != null;
	}
	
	public function isCustom() {
		return hasMod("CUSTOM_MAP") && MapVar.getBool(this, "custom");
	}
	
	public function isBannedFromRanking() {
		return !isFar() || isCustom();
	}
	
	public inline function isHardcore() {
		return hasMod("HARDCORE") && hardcore;
	}
	
	public function getDiff() {
		var c = countP;
		if( diff == null ) {
			return Math.max( Const.get.MinMapDifficulty/100, Math.min(1, 2*c/Const.get.MaxPlayers) );
		} else {
			return diff;
		}
	}
	
	public function getAttackTowerEstimationNoCache(quality:Float, ?d:Int) {
		if( d == null ) d = days;
		var est = Horde.getTotalAttackTowerEst(this, d, quality);
		return { q:Math.round(quality * 100), min:est.min, max:est.max};
	}
	
	public function getCityDefenseItems( zitems : List<ZoneItem>, buildings) : {total:Int, items:Int, mul:Float}  {
		var def = 0, itemCount = 0;
		
		if( zitems == null ) {
			return { total:0, items:0, mul:0.0 };
		}
		
		var list = Lambda.filter(zitems, function(zi) {
			return zi.isBroken == false;
		});
		
		if( list.length <= 0 ) {
			return { total:0, items:0, mul:0.0 };
		}
		
		for( zi in list ) {
			var tool = XmlData.getTool(zi.toolId);
			if( tool != null && tool.hasType(Armor) ) {
				def += zi.count;
			}
		}
		
		itemCount = def;
		//MODIFY HERE TO CHANGE ODD BEHAVIOUR
		var upgrade = db.CityUpgrade.getValueIfAvailableByKey( "defOptim", this, 0 );
		if( upgrade == 0 && buildings.exists("defOptim") ) {
			upgrade = 0.5;
		}
		var itemDefMul = 1.0 + upgrade;
		def = Math.floor( def * itemDefMul );
		
		//Clamp pour éviter les abus!
		if ( def > Const.get.MaxOddCityDefense ) def = Const.get.MaxOddCityDefense;
		return {total:def, items:itemCount, mul:itemDefMul};
	}
	
	public function getCityDefenseBuildings() : Int {
		var def = 0;
		var list = CityBuilding.manager.getDoneBuildings(this);
		for( b in list ) {
			var data = XmlData.getBuildingById(b.type);
			if( data != null )
				def += CityBuilding.getDef(data.def, b.life, b.maxLife);
		}
		return def;
	}
	
	public function getCityDefenseUsers() {

		var results = Db.results("SELECT homeLevel, homeDefense, jobId, hero, isOutside FROM User WHERE mapId="+id+" AND dead=0");
		if( results.length <= 0 ) return {homes:0, guards:0, count:0, total:0};

		// On récupère les points bonus home level
		//Thomas watchmen Implementation
		var guardDef = 5 + if(hasCityBuilding("watchmen")) 10 else 0;
		var ud = 0;
		var gd = 0;
		var count = 0;
		for( r in results ) {
			count++;
			if( r.jobId != null ) {
				ud += XmlData.homeUpgrades[r.homeLevel].def;
				ud += r.homeDefense;
				ud += if (r.hero) Const.get.HeroDefBonus else 0;
				if( r.jobId==4 && !r.isOutside )
					gd += guardDef;
			}
		}
		//Thomas roundSection Implementation
		var ratio = hasCityBuilding("roundSection") ? 0.8 : 0.4;
		ud = Math.floor(ud*ratio);
		return {
			homes	: ud,
			guards	: gd,
			count	: count,
			total	: ud+gd,
		};
	}
	
	function getUpgradeDefense(upName:String, upgrades) : Int {
		var b = XmlData.getBuildingByKey( upName );
		if( upName == "aquaTurret" && water < db.CityUpgrade.getValueIfAvailable( b, 3, this, 0, upgrades ) )
			return 0;
			
		var d = db.CityUpgrade.getValueIfAvailable( b, this, 0, upgrades );
		if( d > 0 && b.def != null )
			d -= b.def;
		
		return Math.floor(d);
	}
	
	public function getCityDefenseUpgrades() {
		var upgrades : Hash<CityUpgrade> = db.CityUpgrade.manager.getUpgradesHash(this);
		var digDef = if( !upgrades.exists("dig" ) ) 0 else Std.int( getUpgradeDefense("dig", upgrades) );
		var wallDef = if( !upgrades.exists("wallEvo" ) ) 0 else Std.int( getUpgradeDefense("wallEvo", upgrades) );
		var aquaDef = if( !upgrades.exists("aquaTurret" ) ) 0 else Std.int( getUpgradeDefense("aquaTurret", upgrades) );
		return {
			total	: digDef + wallDef + aquaDef,
			list	: ["digDef="+digDef, "wallDef="+wallDef, "aquaDef="+aquaDef], // utilisé seulement pour du trace dans le cron
		}
	}
	
	function getCityDefenseGuardians() : { guardians : Int, def : Int } {
		var info = { guardians:0, def:0 };
		if ( !hasMod( "GUARDIAN" ) ) return info;
		
		var hasSpeech = false;
		var lguards = db.User.manager.getGuards(this);
		info.guardians = lguards.length;
		for ( g in lguards ) {
			info.def += g.getGuardianInfo().def;
			if ( g.hasTool("chkspk", true) ) 
				hasSpeech = true;
		}
		//check if a guard has a tool : chkspk which impacts all the guards defense
		if ( hasSpeech )
			info.def += lguards.length * (2 * data.Guardians.BASE_DEF);
		return info;
	}
	
	public function getCityDefense( items : List<ZoneItem>, buildings) {
		//Thomas support Implementation
		var bonus = 1.0;
		if ( hasCityBuilding("support") ) {
			var upgradeLevel = db.CityUpgrade.getValueIfAvailableByKey( "support", this, 10 );
			if ( upgradeLevel == null ) bonus += 0.1;
			else bonus += (0.01 * upgradeLevel);
		}
		var userDef = getCityDefenseUsers();
		var itemDefInfos = getCityDefenseItems(items,buildings);
		var buildDef = getCityDefenseBuildings();
		var upgradeDefInfos = getCityDefenseUpgrades();
		var guardiansDefInfos = getCityDefenseGuardians();
		//Thomas lockedGrave Implementation
		var cadavers = 0, cadaversCount = 0;
		if( hasCityBuilding("lockedGrave") ) {
			cadaversCount = db.Cadaver.manager.getMapCount(this);
			cadavers = cadaversCount * if(hasCityBuilding("springCoffin")) 20 else 10;
		}
		
		var soulsDef = 5 * getVarValue("purifiedSouls");
		
		var cityOnly = Const.get.BaseDefense + tempDef + itemDefInfos.total + buildDef + upgradeDefInfos.total;
		return {
			total		: Std.int(bonus * (cityOnly + userDef.total + guardiansDefInfos.def + cadavers + soulsDef)),
			temp		: tempDef,
			buildings	: buildDef,
			upgradeInfos: upgradeDefInfos,
			itemInfos	: itemDefInfos,
			userInfos	: userDef,
			cityOnly	: cityOnly,
			cadavers	: cadavers,
			souls		: soulsDef,
			guardiansInfos 	: guardiansDefInfos,
			bonus		: Std.int((bonus - 1.0) * 100),
		}
	}
	
	public inline function hasCityBuilding(key : String) {
		return CityBuilding.manager.hasBuilding( this, key );
	}
	
	public function getCityItems() {
		if( cityId == null ) {
			return null;
		}
		var ar = Lambda.array(_getCity().getItems());
		ar.sort( function(a,b) {
			if (a.count<b.count) return 1;
			if (a.count>b.count) return -1;
			return 0;
		});
		return Lambda.list(ar);
	}
	
	public function getUsers(?lock:Bool, ?includeDeads:Bool=false):Array<db.User> {
		return User.manager.getMapUsers( this, includeDeads, lock );
	}
	
	public function getAllMods():Hash<Int>
	{
		var allMods = new Hash<Int>();
		for ( m in db.GameMod.getAllMods() )
			allMods.set(m.name, db.GameMod.hasMod(m.name) ? 1 : 0);
		
		var allVars = db.MapVar.manager.getAllVars(this, false);
		for( v in allVars )
		{
			if( StringTools.startsWith(v.name, "mod_") )
			{
				allMods.set(v.name.toUpperCase(), v.value);
			}
		}
		return allMods;
	}
	
	public static function create(name, far:Bool, ?rnd:Int->Int, ?p_configureMap:db.Map->Void) { // ATTENTION : utiliser plutôt Cron.createGame pour créer une map !
		if( rnd == null ) rnd = Std.random;
		//
		var map = new Map(rnd);
		map.level = if( far ) db.Version.getVar("minXp") else 0;
		map.name = name;
		map.insert();
		
		db.MapVar.setValue(map, "season", App.getDbVar("season"));
		
		var mods = db.GameMod.getAllMods();
		for( mod in mods.keys() )
		{
			if( mod.substr(0,3).toUpperCase() != "MOD")
				continue;
			
			var m = mods.get(mod);
			//events MODS
			if ( m.beginDate != null || m.endDate != null ) 
				continue;
				
			var isActive = db.GameMod.hasMod(mod) ? 1 : 0;
			switch( mod )
			{
				case "MOD_SAFE_MODE": //nothing
				case "MOD_CASH_PARAMS"://nothing
				case "MOD_CHRISTMAS", "MOD_CHRISTMAS_2012", "MOD_CHRISTMAS_2011", "MOD_CHRISTMAS_2010"://nothing
				case "MOD_EASTER"://nothing
				case "MOD_LONG_SUBSCRIP": //nothing
				case "MOD_XML", "MOD_XML_CACHE": //nothing
				
				//EN RNE on coupe quelque mods !
				case "MOD_SHAMAN_SOULS":
					if ( far ) db.MapVar.setValue(map, mod, isActive);
					else db.MapVar.setValue(map, mod, 0);
				
				case "MOD_CAMP":
					if ( far ) db.MapVar.setValue(map, mod, isActive);
					else db.MapVar.setValue(map, mod, Config.LANG.toLowerCase() == "en" ? 1 : 0);
				
				case "MOD_EXPLORATION":
					if ( far ) db.MapVar.setValue(map, mod, isActive);
					else db.MapVar.setValue(map, mod, 0);
				
				default: 
					db.MapVar.setValue(map, mod, isActive);
			}
		}
		
		if( map.hasMod("BIG_MAPS") && far )
		{
			map.width = Const.get.BigMapWidth + rnd( Const.get.MaxMapWidthGrow );
			db.MapVar.setValue(map, "RE", 1);
		}
		else
		{
			map.width = Const.get.MapWidthStd + rnd( Const.get.MaxMapWidthGrow );
			db.MapVar.setValue(map, "RNE", 1);
		}
		
		if( p_configureMap != null ) p_configureMap(map);
		
		map.update();
		return map;
	}
	
	public function openDoor(?fl_update = true) {
		if ( forumId == null || forumId == 0 )
			Cron.createGameForums(this);
		
		if( doorOpened )
			return false;
		doorOpened = true;
		if( fl_update )
			update();
		return true;
	}
	
	public function closeDoor(?fl_update = true) {
		if ( forumId == null || forumId == 0 )
			Cron.createGameForums(this);
		
		if( !doorOpened )
			return false;
		doorOpened = false;
		if( fl_update )
			update();
		return true;
	}
	
	public function destroyDoor(?fl_update=true) {
		doorOpened = true;
		devastated = true;
		if ( fl_update )
			update();
	}
	
	public function getPickLimit() {
		if ( chaos )
			return Math.floor(Const.get.AbusePicksLimit*2);
		else
			return Const.get.AbusePicksLimit;
	}
	
	public function startEvent( eventState : EventState ) {
		if( eventState == null )
			throw "Invalid Map Event";

		event = Type.enumIndex( eventState );
		update();
		User.manager.updateEventState( Type.enumIndex(cast event), this );
	}
	
	public function stopEvent() {
		event = null;
		update();
		User.manager.updateEventState( Common.NO_EVENT, this );
	}
	
	public function hasEvent() {
		return event != null;
	}
	
	public function _getOutsideDescription(?lock=false) {
		var zones = Zone.manager._getZonesForMap( this, lock );
		return zones;
	}
	
	public function _getCity() : Zone {
		return Zone.manager.get( cityId, false );
	}
	
	public function countSurvivors() : Int {
		return User.manager.getAlivePlayersCount(this);
	}
	
	public function countCityBanned() {
		return User.manager.countCityBanned(this, true);
	}
	
	public function countCityNotBanned() {
		return User.manager.countCityBanned(this, false);
	}
	
	public function getExtractedBuildings() {
		return Zone.manager.getExtractedBuildings( this );
	}
	
	public function getAllCadavers() {
		return Cadaver.manager.getList( this );
	}
	
	public function getCadavers( deathType : DeathType, ?exclude : Bool) {
		if( exclude )
			return Cadaver.manager.getFilteredExcludeList( this, deathType, days-1 );
		return Cadaver.manager.getFilteredList( this, deathType, days );
	}
	
	public function getCadaversByDay( deathType : DeathType, day:Int, ?exclude : Bool) {
		if( exclude )
			return Cadaver.manager.getFilteredExcludeList( this, deathType, day );
		return Cadaver.manager.getFilteredList( this, deathType, day );
	}
	
	public function getKnownZones(?lock) {
		var zones = Zone.manager.getKnownZones( this, lock );
		return zones;
	}
	
	public function addBuilding(key) {
		builtBuildings.set( key, true );
	}
	
	public function isRevolted() {
		return conspiracy<0;
	}
	
	public function printHeroMsg() {
		if( heroMsg == null ) return "";
		var str = heroMsg;
		str = StringTools.replace(str, " !", "&nbsp;!");
		str = StringTools.replace(str, " :", "&nbsp;:");
		var list = str.split("\n");
		return "<p>"+list.join("</p><p>")+"</p>";
	}
	
	public function isQuarantined() {
		return (status == 4);
	}
	
	public function getCatapultCost() {
		if( hasCityBuilding("catapult2") )
			return Const.get.CatapultCost;
		else
			return Const.get.CatapultCost*2;
	}
	
	public function initBuildings() {
		CityBuilding.manager.resetMap(this);
		
		for( binfos in XmlData.buildings )
			if( binfos != null && binfos.drop == data.Drop.b )
				CityBuilding.unlock(this, binfos, false);
		
		if( !isFar() ) {
			estimCount = 10;
		}
		
		if( !isFar() && !hasFlag("noBuilding") ) {
			// les villes RNE bénéficient d'aides spéciales
			CityBuilding.giveBuilding(this, XmlData.getBuildingByKey("doorLock"));
			CityBuilding.giveBuilding(this, XmlData.getBuildingByKey("command"));
			CityBuilding.giveBuilding(this, XmlData.getBuildingByKey("tower"));
			CityBuilding.unlock(this, XmlData.getBuildingByKey("regen"));
			estimCount = 10;
		}
	}
	
	public function isShamanElection() {
		return hasMod("SHAMAN_SOULS") && flags.get(SHAMAN_ELECTION);
	}
	
	public function isGuideElection() {
		return flags.get(GUIDE_ELECTION);
	}
}

/*** MANAGER ***/
private class MapManager extends neko.db.Manager<Map>
{
	public function new() {
		super(Map);
	}

	override private function make( m : Map )
	{
		if( m.attackLogBlob != null ) {
			var z = neko.Lib.localUnserialize( neko.Lib.bytesReference(m.attackLogBlob) );
			if( z != null ) {
				m.attackLog = z;
			}
		}
	}
	
	public function _getAccessibleMaps( uid : Int, playedMaps : List<Int>, noob : Bool) {
		var sqlPm = if( playedMaps.length > 0 ) " AND id not in( " + playedMaps.join( ",") + ")" else "";
		var sql = "status=" + Type.enumIndex( GameIsOpened ) + " AND availableForJoin=1 AND event IS NULL " + sqlPm;
		var m = objects(selectReadOnly( sql ), false);
		if( m.length <= 0 )
			return new List();

		var maps = Lambda.filter( m, function( o ) {
			if( o.days > Const.get.BeginPeriodDays )
				return false;

			if( o.countP >= Const.get.MaxPlayers )
				return false;

			if( noob ) {
				if( o.level < db.Version.getVar("minXp") )
					return true;
				return false;
			}

			if( !noob ) {
				if( o.level >= db.Version.getVar("minXp") )
					return true;
				return false;
			}

			return true;
			} );

		if( maps.length <= 0 )
			return new List();

		var m2 = Lambda.array( maps );
		m2.sort( function( o1, o2 ) { if( o1.countP > o2.countP ) return -1; if( o2.countP > o1.countP ) return 1; return 0; } );
		return Lambda.list( m2 );
	}

	public function _countAccessibleMaps( uid : Int, playedMaps : List<Int>) {
		var sqlPm = if( playedMaps.length > 0 ) " AND id not in( " + playedMaps.join( ",") + ")" else "";
		var sql = "SELECT COUNT(*) FROM Map WHERE status=" + Type.enumIndex( GameIsOpened )
					+ " AND inPool = 0 AND event IS NULL AND availableForJoin=1 " + sqlPm
					+ " AND days <= " + Const.get.BeginPeriodDays
					+ " AND countP < " + Const.get.MaxPlayers;

		return execute( sql ).getIntResult(0) > 0;
	}

	public function getFirstPooled( hd : Bool) {
		return	if( hd )
					object(select( "inPool = 1 AND level >=" + db.Version.getVar("minXp") ), true );
				else
					object(select( "inPool = 1 AND level <" + db.Version.getVar("minXp") ), true );
	}


	/* ------------------- CRON uniquement !! -------------------------*/

	public function getAllPlayableForCron() {
		return objects(selectReadOnly("status IN( " + Type.enumIndex( GameIsClosed ) +", " + Type.enumIndex( Quarantine ) +" ) AND inPool = 0 "),false);
	}

	public function getFirstDayOpened() {
		return objects(select("status=" + Type.enumIndex( GameIsOpened ) +" AND inPool = 0 AND countP > 0"), true);
	}


	public function makeMapsAvailable(mapIds:List<Int>) {
		if( mapIds == null || mapIds.length == 0 ) return;
		Db.execute("UPDATE Map SET availableForJoin=1 WHERE availableForJoin=0 AND id IN ("+mapIds.join(",")+")");
	}


	public function makeMapAvailable(map:Map) {
		if( map == null ) return;
		Db.execute("UPDATE Map SET availableForJoin=1 WHERE availableForJoin=0 AND id="+map.id);
	}
	
	/***** NOUVELLE VERSION PLUS SIMPLE *****/

	private function getBaseOpenCondition() {
		return " status="+ Type.enumIndex( GameIsOpened ) +" AND event IS null AND availableForJoin=1 AND countP<"+Const.get.MaxPlayers+" ";
	}
	
	public function openMaps(n:Int) {
		if( n <= 0 )
			return;
		
		var minXp = db.Version.getVar("minXp");
		// trop de maps ouvertes déjà
		var open = countOpenMaps();
		if( open >= App.getDbVar("mapsInPool") )
			return;
		// villes pour nouveaux joueurs
		var noobNeeded = db.Map.getMinNoobMap() - countOpenMaps("level<"+minXp);
		if( n > 0 && noobNeeded > 0 ) {
			Db.execute(
				"UPDATE Map SET availableForJoin=1 WHERE level=0 AND event IS null AND availableForJoin=0 AND status="+Type.enumIndex( GameIsOpened )+" ORDER BY id LIMIT "+Math.min(n,noobNeeded)
			);
			n -= noobNeeded;
		}
		// villes hardcore
		var hardNeeded = Const.get.MinHardcoreMap - countOpenMaps("hardcore=1");
		if( db.GameMod.hasMod("HARDCORE") && n > 0 && hardNeeded > 0 ) {
			Db.execute(
				"UPDATE Map SET availableForJoin=1, hardcore=1, water=ROUND(water*0.66) WHERE level="+minXp+" AND event IS null AND availableForJoin=0 AND status="+Type.enumIndex( GameIsOpened )+" ORDER BY id LIMIT "+Math.min(n,hardNeeded)
			);
			n -= hardNeeded;
		}
		// villes "régions éloignées"
		if( n > 0 )
			Db.execute("UPDATE Map SET availableForJoin=1 WHERE level="+minXp+" AND event IS null AND availableForJoin=0 AND status="+Type.enumIndex( GameIsOpened )+" ORDER BY id LIMIT "+n);
	}
	
	public function countMapsInPool(cond:String) {
		return Db.execute(
			"SELECT count(*) FROM Map WHERE status="+ Type.enumIndex( GameIsOpened ) +" AND event IS NULL AND availableForJoin=0 AND "+cond
		).getIntResult(0);
	}
	
	public function countOpenMaps(?cond:String) {
		if( cond == null )
			return Db.execute( "SELECT count(*) FROM Map WHERE password IS NULL AND "+getBaseOpenCondition() ).getIntResult(0);
		else
			return Db.execute( "SELECT count(*) FROM Map WHERE password IS NULL AND "+getBaseOpenCondition()+" AND "+cond ).getIntResult(0);
	}
	
	public function getAvailableMaps(playedMaps:List<Int>, fl_onlyCustomMaps:Bool) {
		var sqlPM = if( playedMaps.length > 0 ) " AND id not in( " + playedMaps.join( ",") + ")" else "";
		sqlPM += if(fl_onlyCustomMaps) " AND password IS NOT NULL" else " AND password IS NULL";
		var list = objects( selectReadOnly(
			getBaseOpenCondition() + sqlPM
		), false);
		return list;
	}
	
	public function countAvailableForUser(playedMaps:List<Int>) {
		var sqlPM = if( playedMaps.length > 0 ) " AND id NOT IN( " + playedMaps.join( ",") + ")" else "";
		var count = Db.execute(
			"SELECT count(*) FROM Map WHERE"
			+ getBaseOpenCondition() + sqlPM
		).getIntResult(0);
		return count;
	}
	
	public function isFar(mapId:Int) {
		var level = Db.execute("SELECT level FROM Map WHERE id="+mapId).getIntResult(0);
		return level == db.Version.getVar("minXp");
	}
	
	public function getOpenCustomMaps() {
		var mapIds = MapVar.manager.getMapIds("custom",1);
		return	if( mapIds.length > 0 )
					objects(select("id IN ("+mapIds.join(",")+") AND status="+Type.enumIndex(GameIsOpened)), true);
				else
					new List();
	}
	
	public function getAllActiveMaps(fl_lock=false) {
		return	if (fl_lock)
					objects( select("status!="+Type.enumIndex(EndGame)), true );
				else
					objects( selectReadOnly("status!="+Type.enumIndex(EndGame)), false );
	}
}
