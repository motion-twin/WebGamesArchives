package db;
import Common;
import tools.Utils;
import mt.db.Types;
import db.UserVar;

using Std;


class User extends neko.db.Object {


	/* ---------------------- GHOST / SCORE --------------------- */

	public var survivalCount	: SInt;	// Nombre de jours de survie total
	public var survivalPoints	: SInt;	// Score de survie total
	public var survivalDays		: SInt;	// Score de survie v2
	public var mapRegisterDay	: SInt;	// jour à partir duquel le joueur a rejoint la partie > conditionne le score
	public var lastZombieAttack	: SInt;	// nombre de zombies attaquant le joueur
	public var winnerNormal		: SBool; // ville classée première sur la saison
	public var winnerHardcore	: SBool; // ville hardcore classée première sur la saison

	/* ---------------------- CARACTERISTIQUES --------------------- */

	public var eventState		: SNull<SInt>;
	public var homeLevel		: SInt;
	public var homeMsg			: SNull<SString<65>>;
	public var customTitle		: SNull<SString<256>>;
	public var ghostMsg			: SNull<SString<200>>;
	public var woundType		: SNull<SInt>;

	/* ---------------------- CAMPING --------------------- */
	public var campStatus		: SNull<SBool>;
	public var lastCampChance	: SInt;
	public var campCount		: SInt;

	/* ---------------------- HOME --------------------- */

	public var homeDefense		: SInt;
	public var homeHidden		: SBool;
	public var homeSafe			: SBool;
	public var homeCapacity		: SInt;
	public var homeAlarm		: SBool;

	/* ---------------------- ACTIONS --------------------- */

	public var hasStolen				: SBool;	// Si le joueur a déjà volé aujourd'hui
	public var waterTaken				: SInt;
	public var hasDrunk					: SBool;	// si le joueur a bu de l'eau
	public var hasEaten					: SBool;	// si le joueur a mangé

	public var wasRescued				: SBool;	// joueur sauvé par un autre joueur
	public var usedHeroRescue			: SBool;	// si le joueur a sauvé un autre joueur
	public var usedHeroLuck				: SBool;	// si le joueur a utilisé sa chance de héros
	public var usedHeroKill				: SBool;	// si le joueur a utilisé son coup de poing
	public var usedTownPortal			: SBool;	// si le joueur a utilisé son retour en ville
	public var usedActAgain				: SBool;
	public var usedTrance				: SBool;
	public var hasDoneDailyHeroAction	: SBool;	// si le joueur a utilisé une action héroïque

	public var takes					: SNull<SString<255>>;
	public var bankBan					: SNull<SDateTime>;

	/* ---------------------- ETATS --------------------- */
	//TODO Utiliser un SFlags? plus léger, mais compliqué pour SQL CRON?
	public var dead				: SBool;
	public var isDehydrated		: SBool;
	public var isThirsty		: SBool;
	public var isTired			: SBool;
	public var isWounded		: SBool;
	public var isInfected		: SBool;
	public var isDrugged		: SBool;
	public var isAddict			: SBool;
	public var isDrunk			: SBool;
	public var isHungOver		: SBool;
	public var isTerrorized		: SBool;
	public var isConvalescent	: SBool; //?Still used?
	public var hasCamped		: SBool;
	public var hasVoted			: SBool;
	public var hasReadCityNews	: SBool;
	public var isBrave			: SBool;
	public var isCityBanned		: SBool;
	public var isCityGuard		: SBool;
	public var isInTrance		: SBool;
	public var isClean			: SBool;
	public var isGhoul			: SBool;
	public var isImmune			: SBool;
	
	/* ------------------------ ROLES -------------------- */
	public var isShaman			: SBool;
	public var isGuide			: SBool;
	
	public var magicProtection(get, set):Bool;
	
	/* ---------------------- ARMAGEDDON ----------------------*/
	
	public var armageddon		: SBool;
	public var usedArmageddon	: SBool;
	
	/* ---------------------- LA GRANDE Contamination ----------------------*/
	public var contamination	: SBool;
	public var usedContamination: SBool;
	
	/* ---------------------- STATS ----------------------*/
	
	public var activity			: SInt;
	
	/* ---------------------- OUTRE-MONDE --------------------- */
	
	public var isOutside		: SBool;
	var pa						: SInt;		// points d'action du joueur à l'extérieur
	public var steps			: SInt;		// déplacements effectués à l'extérieur
	public var endGather		: SNull<SDateTime>; // démarrage du mode gather
	public var autoJoin			: SBool;
	
	/* ---------------------- AUTO --------------------- */
	
	public var zonesBlob					: SNull<SBinary>;
	public var mapsBlob						: SNull<SBinary>;
	public var mapId(default,null)			: SNull<SInt>;
	public var map(dynamic,dynamic)			: Map;
	public var zoneId(default,null)			: SNull<SInt>;
	public var zone(dynamic,dynamic)		: Zone;
	public var teamId(default,null)			: SNull<SInt>;
	public var team(dynamic,dynamic)		: Team;
	
	/* ---------------------- ESCORTES --------------------- */
	
	public var leaderId(default,null)	: SNull<SInt>;
	public var leader(dynamic, dynamic)	: User;
	public var isWaitingLeader			: SBool;
	public var onlyEscortToTown			: SBool;
	public var fullEscortMode			: SBool;
	public var wasEscorted				: SBool;
	
	/* ---------------------- DB PRIVATES --------------------- */
	
	public var zones				: IntHash<Int>;
	public var job					: Job;
	private var doneActionsByZone	: Hash<Bool>;
	public var cachedMap			: Map;
	public var cachedZone			: Zone;
	public var bonus				: SInt;//TODO check that...
	
	/* --------------- TO MERGE IN SFLAGS -----------------*/
	public var muted			: SBool;//Sert à empêcher un joueur d'écrire des messages pour cause de boulet attitude! Peut se merger avec un SFlags!
	
	/* --------------- TO MOVE IN USERVAR -----------------*/
	public var apiKey			: SNull<SString<32>>;
	public var majorEvent		: SNull<SString<30>>;//pour prévenir le joueur qu'un ev important vient de se produire (transformation en goule et autre??) Mérite peut etre pas un champ qd meme...UserVar !
	public var slowMode			: SBool;//sert pour baisser/ralentir les animations de la map. Franchement inutile aujourd'hui?
	public var ghoulHunger		: SInt;
	
	public var cachedGuardianInfos: data.Guardians.GuardianInfo;
	
	public function reset() {
		campStatus = null;
		lastCampChance = 0;
		campCount = 0;
		hasCamped = false;
		usedArmageddon = false;
		usedContamination = false;
		leader = null;
		isWaitingLeader = false;
		onlyEscortToTown = false;
		fullEscortMode = false;
		wasEscorted = false;
		homeSafe = false;
		homeHidden = false;
		homeAlarm = false;
		homeCapacity = 0;
		homeDefense = 0;
		cachedMap = null;
		cachedZone = null;
		doneActionsByZone = null;
		isCityGuard = false;
		endGather = null;
		jobId = null;
		job = null;
		zones = new IntHash();
		lastZombieAttack = 0;
		zonesBlob = null;
		mapRegisterDay = 1;
		mapsBlob = null;
		steps = 0;
		woundType = null;
		wasRescued = false;
		usedHeroRescue = false;
		usedHeroLuck = false;
		usedHeroKill = false;
		usedTownPortal = false;
		usedActAgain = false;
		usedTrance = false;
		hasDoneDailyHeroAction = false;
		isInfected = false;
		isBrave = false;
		isThirsty = false;
		isWounded = false;
		isDehydrated = false;
		isDrugged = false;
		isAddict = false;
		isDrunk = false;
		isHungOver = false;
		isTerrorized = false;
		isConvalescent = false;
		hasDrunk = false;
		hasEaten = false;
		hasStolen = false;
		isOutside = false;
		isImmune = false;
		isShaman = false;
		isGuide = false;
		dead = false;
		mapId = null;
		pa = maxPa()+paBonus();
		hasVoted = false;
		waterTaken = 0;
		zoneId = null;
		isTired = false;
		isInTrance = false;
		isClean = true;
		isGhoul = false;
		homeLevel = 0;
		hasReadCityNews = false;
		homeMsg = null;
		takes = null;
		bankBan = null;
		isCityBanned = false;
		eventState = null;
		activity = 0;
		ghoulHunger = 0;
		bonus = 0;
		majorEvent = null;
		db.TempGather.manager.deleteTools( this );
		db.HomeUpgrade.manager.reset( this );
		Db.execute("DELETE FROM Tool WHERE userId="+id);
		Db.execute("DELETE FROM MessageThread WHERE uto=" + id );
		ZoneAction.manager.deleteForUser(this);
		GameAction.manager.deleteForUser(this);
		UserVar.manager.reset(this);
		update();
	}

	public function new() {
		super();
		campStatus = null;
		lastCampChance = 0;
		campCount = 0;
		hasCamped = false;
		sortedBank = true;
		contamination = false;
		armageddon = false;
		usedArmageddon = false;
		usedContamination = false;
		leader = null;
		isWaitingLeader = false;
		onlyEscortToTown = false;
		fullEscortMode = false;
		wasEscorted = false;
		homeSafe = false;
		homeHidden = false;
		homeAlarm = false;
		homeCapacity = 0;
		homeDefense = 0;
		cachedMap = null;
		cachedZone = null;
		autoJoin = true;
		doneActionsByZone = null;
		teamId = null;
		isCityGuard = false;
		spentHeroDays = 0;
		moneyPoints = 0;
		heroDays = 0;
		jobId = null;
		job = null;
		ghostExists = false;
		mapRegisterDay = 1;
		lastZombieAttack = 0;
		survivalPoints = 0;
		survivalDays = 0;
		advBank = true;
		zones = new IntHash();
		zonesBlob = null;
		mapsBlob = null;
		woundType = null;
		wasRescued = false;
		usedHeroRescue = false;
		usedHeroLuck = false;
		usedHeroKill = false;
		usedTownPortal = false;
		usedActAgain = false;
		usedTrance = false;
		hasDoneDailyHeroAction = false;
		steps = 0;
		isInfected = false;
		isThirsty = false;
		isBrave = false;
		isDehydrated = false;
		isDrugged = false;
		isAddict = false;
		isDrunk = false;
		isHungOver = false;
		isTerrorized = false;
		isConvalescent = false;
		isWounded = false;
		isImmune = false;
		isShaman = false;
		isGuide = false;
		hasDrunk = false;
		hasEaten = false;
		createDate     = Date.now();
		loginDate      = Date.now();
		hero = false;
		isNoob = true;
		slowMode = false;
		dead = false;
		isOutside = false;
		mapId = null;
		pa = maxPa()+paBonus();
		hasVoted = false;
		waterTaken = 0;
		isTired = false;
		isInTrance = false;
		isClean = true;
		isGhoul = false;
		hasStolen = false;
		homeLevel = 0;
		//hasReadNews = Date.now();
		hasReadCityNews = true;
		homeMsg = null;
		isCityBanned = false;
		eventState = null;
		activity = 0;
		bonus = 0;
		refDays = 0;
		debt = 0;
		ghoulHunger = 0;
		takes = null;
		bankBan = null;
		majorEvent = null;
		winnerNormal = false;
		winnerHardcore = false;
		worldBan = false;
		muted = false;
		var now = DateTools.delta( Date.now(), 1000 * 60 * 60 * 24.0 );
		
		cachedGuardianInfos = null;
		if( App.session.uid != null )
			App.session.trackNewRegisteredUser = true;
	}
	
	public function inExplo() {
		if( zone == null ) return false;
		if( zone.explo == null ) return false;
		if( zone.explo.isOver() ) return false;
		return zone.explo.user == this;
	}
	
	public function hasFlag( flagName : String ) : Bool {
		return UserVar.manager.hasVar(this, flagName );
	}
	
	inline public function getVarValue( varName : String ) : Int {
		return UserVar.getValue(this, varName );
	}
	
	inline public function setVarValue( varName : String, value:Int, persist:Bool=false ) {
		UserVar.setValue(this, varName, value, persist );
	}
	
	public function payDays(d:Int) : Bool {
		if( d > heroDays )
			return false;
		heroDays -= d;
		if( heroDays <= 0 ) {
			heroDays = 0;
			hero = false;
			job = null;
			UserVar.delete( this, "buildingActions" );
		}
		update();
		return true;
	}
	
	public function getHomeMessage() {
		return Utils.cutLongWords( homeMsg, true );
	}

	public function hasTeamInvitation() {
		return db.TeamInvitation.manager.has( this );
	}

	public function leaveTeam() {
		if( team == null)
			return;

		var teamLock = db.Team.manager.get(teamId,true);
		// Le créateur perd sa coalition en la quittant
		if( this == teamLock.creator ) {
			teamLock.delete();
		} else {
			teamLock.countP--;
			teamLock.update();
			TeamLog.shout( teamLock, Text.fmt.LeaveTeamSpeech( {name:print()} ) );
			team = null;
			update();
		}
	}

	public function hasUnreadTeamPosts() {
		if( team == null ) return false;
		if( lastTeamPost == null ) {
			return team.lastPost != null;
		} else {
			return team.lastPost != null && lastTeamPost.getTime() < team.lastPost.getTime();
		}
	}

	public function getUnlockedMap() {
		return db.Map.manager.get( mapId, false );
	}

	public function hasJob() {
		return jobId != null;
	}

	public function hasThisJob(j:String) {
		return jobId != null && job.key == j;
	}
	
	public function leaveMap() {
		woundType = null;
		isWounded = false;
		isTerrorized = false;
		isCityBanned = false;
		isConvalescent = false;
		
		map = null;
		zone = null;
		dead = false;
		
		ZoneAction.manager.deleteForUser(this);
		GameAction.manager.deleteForUser(this);
		
		//nettoie les variables necessaires
		UserVar.delete(this, "guards");
		UserVar.manager.reset(this);
		GhostReward.manager.clearGame(this);
		
		updateScores(false);
		update();
	}

	public function getCrowName() {
		return makeCrowId(this.id);
	}

	public function getPetName() {
		var rseed = new mt.Rand(0);
		rseed.initSeed(id+mapId);
		return XmlData.getPetName(rseed);
	}

	public static function makeCrowId(crowUserId:Int) : String {
		var rseed = new mt.Rand( Std.int( Math.pow(crowUserId, 2) ) );
		rseed.random(crowUserId);
		return "JeuneCorbillon"+rseed.random(999);
	}
	
	public function getCoords(?city:Zone) {
		if( !isPlaying() ) {
			return {x:0, y:0};
		} else {
			if(city == null)
				city = getMapForDisplay()._getCity();
			return MapCommon.coords(city.x, city.y, zone.x, zone.y);
		}
	}
	
	public static function getRescueList( rescuer : User, map : Map) {
		var usefulZones = Zone.manager.getRescueZones(map, Const.get.RescueDistance);
		return Lambda.list( Db.results( "SELECT id, twinId, name, zoneId
							FROM User
							WHERE isOutside = 1 AND dead=0 AND id != "+rescuer.id+"
							AND zoneId IN ("+Lambda.map(  usefulZones, function( z: Zone ) { return z.id; } ).join( "," )+")") );
	}
	
	public function getHeroItems() {
		var listId = if(hasHeroUpgrade("powerSuperTools")) 9997 else 9998;
		return Lambda.map( XmlData.getOutsideBuilding( listId ).tools, function( key : { p : Int, t : String  }) { return XmlData.getToolByKey( key.t );} );
	}
	
	public function getGhostMsg() {
		return tools.Utils.miniTemplate(Utils.cutLongWords(ghostMsg,true));
	}
	
	public function playsWithMe( u:User ) {
		if( u == null )
			return false;
		return !dead && !u.dead && ( mapId == u.mapId );
	}
	
	public function playsWithMeNoLock( uid : Int ) {
		if( uid == null )
			return false;
		if( dead )
			return false;
		if( mapId == null )
			return false;
		return Db.execute("SELECT count(*) FROM User WHERE id="+uid+" AND dead=0 and mapId="+mapId).getIntResult(0) > 0;
	}
	
	public function isAtDoors() {
		return isOutside && zoneId == map.cityId;
	}
	
	public static function isAtDoorsStatic(user, cityId) {
		return user.isOutside && user.zoneId == cityId;
	}
	
	public function hangDown() {
		CityBuilding.destroyHanger( getMapForDisplay() );
		var recup = getBanItems(true);
		if( App.isEvent("paques") )
			die( DT_Crucified );
		else
			die( DT_HangedDown );
		return recup;
	}
	
	public function sendToMeatCage() {
		var recup = getBanItems(true);
		die( DT_MeatCage );
		return recup;
	}
	
	public function finalizeJoinGame() {
		if( map == null )
			throw "finalizeJoinGame : No Map!";
		
		Tool.addByKey("suit", this, true); // tenue de citoyen pour tous !
		Tool.addByKey("chest_citizen",this,false);
		
		if( armageddon )
			Tool.addByKey("food_armag",this,false);
		else
			Tool.addByKey("food_bag",this,false);
		
		if( hasHeroUpgrade("food") )
			Tool.addByKey("food_bag",this,false);
		
		if( hasHeroUpgrade("tool") )
			Tool.addByKey("chest_hero",this,false);
		
		if( hasHeroUpgrade("disinfect") )
			Tool.addByKey("disinfect",this,false);
			
		if( hasHeroUpgrade("architect") )
			Tool.addByKey("bplan_c", this, false);
		
		if( winnerHardcore || winnerNormal )
			Tool.addByKey("reveil_off",this,true);
		
		if( longSubscriber )
			Tool.addByKey("photo_3", this, true);
		
		pa = maxPa() + paBonus(); // bonus éclaireur
		
		var m = db.Map.manager.get( mapId, false ); // On évite de locker la ressource
		CityLog.add( CL_NewUser, Text.fmt.CL_NewUser( {name:print(),j:job.print()} ), m );
		
		// distinction "clean"
		var gr = GhostReward.gain(GR.get.nodrug);
		gr.value = map.days;
		gr.update();
		
		hasReadCityNews = true;
		eventState = null;
		update();
	}

	public inline function hasCityBuilding(key:String) {
		return getMapForDisplay().hasCityBuilding(key);
	}

	public static function getCityLogs( ?user:User, ?keys: Array<CityLogKey>, m:Map, ?limit:Int ) {
		if( limit == null )
			return CityLog.manager.getLogs( m, user, keys );
		else
			return CityLog.manager.getLogs( m, user, keys, limit );
	}

	public function getLastActivity() {
		var lastAct = db.CityLog.manager.getLastActivity(this);
		return	if( lastAct != null && lastAct.getTime() > loginDate.getTime() )
					lastAct;
				else
					loginDate;
	}

	public function validateActivity(id:Int) { // id = numéro de bit entre 0 et 4 compris
		var bit = Math.floor( Math.pow(2, id) );
		activity = activity | bit;
		update();
	}

	public function hasDoneActivity(id:Int) {
		var bit = Std.int( Math.pow(2, id) );
		return (activity & bit) > 0;
	}

	public function getActivity() {
		var score = 0;
		for( i in 0...5 ) {
			var bit = Math.floor( Math.pow(2, i) );
			score += if( (activity & bit) != 0 ) 1 else 0;
		}
		return score;
	}

	public function getActivityRatio() { // renvoie 1 si tous les bits sont activés
		var n = 0;
		var max = 5;
		for( i in 0...max )
			if( activity & Math.floor(Math.pow(2,i)) != 0 )
				n++;
		return n / max;
	}

	public function dominationAdjust() {
		return if(hasTool("camoVest", true)) Const.get.RangerDomination else 0;
	}

	public function loseCamo(?force:Bool) {
		var l = getToolsByType(Camo);
		if( l.length > 0 ) {
			if ( force == null && !zone.isInFeist() ) {
				return false;
			}
			for( t in l ) {
				Tool.addByKey( t.getReplacementKey() , this, t.inBag );
				t.delete();
			}
			return true;
		} else {
			return false;
		}
	}

	public function dirt(?fl_update=true) {
		var list = getInBagTools(true);
		for( tool in list ) {
			if( tool.key == "suit" ) {
				var rep = tool.getReplacement();
				tool.toolId = rep.toolId;
				tool.update();
			}
		}
		if( fl_update ) update();
	}

	public function getCamo() {
		var l = getInBagTools().filter( function(t:Tool) {
			return t.getInfo().key=="camoVest_off";
		});
		
		if( l.length > 0 ) {
			for( t in l ) {
				var newTool = Tool.addByKey( t.getInfo().getReplacementKey(), this, t.inBag );
				t.delete();
			}
		}
	}

	public function getGatherChance(fl_farMap:Bool) {
		var c = if( job.key == "collec" ) Const.get.GatherChance + Const.get.GathererBonus else Const.get.GatherChance;
		if( hasWound(W_Eye) )
			c = Math.round(c*0.5);
		if( isDrunk )
			c -= 15;
		if( hasCamped )
			c += 10;
		if( map.hasMod("NIGHTMODS") && fl_farMap && App.isNight() ) {
			var lampIds = Lambda.map( XmlData.getToolsByType(Lamp), function(t) { return t.id; } );
			if( db.ZoneItem.manager.countItemsInZone(zoneId, lampIds) == 0 )
				c -= 20;
			else
				c -= 5;
		}
		if( c < 0 )
			c = 0;
		return c;
	}

	public function getGatherTime() {
		return Math.floor( endGather.getTime() - Date.now().getTime() );
	}
	
	public function canGather() {
		return endGather != null;
	}
	
	public function hasDoneCountedActionZone( a, n : Int ) {
		return ZoneAction.manager.hasDoneCountedActionZone( this, a, n );
	}
	
	public function hasDoneActionZone( a ) {
		if( doneActionsByZone == null ) {
			doneActionsByZone = ZoneAction.manager.getDoneActionsByZone( this );
		}
		return doneActionsByZone.exists( a );
	}
	
	public function hasDoneAction( a ) {
		var doneActions = getDoneActions();
		if( doneActions == null || doneActions.length <= 0 )
			return false;
		for( action in doneActions )
			if( action == a )
				return true;
		return false;
	}
	
	public function hasUnreadMessages() {
		return db.MessageThread.manager.isPending( this );
	}
	
	public function raiseAddiction() {
		GhostReward.gain(GR.get.drug);
		GhostReward.lose(GR.get.nodrug);
		if( isClean ) {
			isClean = false;
			if( zoneId != map.cityId && hero && hasHeroUpgrade("drugclean") )
				handler.OutsideActions.updateZoneControl(zone,-1,map);
		}
		if( isDrugged )
			isAddict = true;
		else
			isDrugged = true;
		update();
	}
	
	public function useDrug(?bonus:Int) {
		pa = maxPa();
		if( bonus != null ) pa += bonus;
		isTired = false;
		raiseAddiction();
	}
	
	public function eat() {
		if( hasEaten )
			return false;
		hasEaten = true;
		pa = maxPa();
		isTired = false;
		update();
		return true;
	}

	public function refillMoves(?fl_update=true) {
		pa = maxPa();
		isTired = false;
		if( fl_update )
			update();
	}
	
	public function drink() {
		steps = 0;
		if( isGhoul ) {
			wound(false, W_Head);
		} else {
			if( isDehydrated ) {
				isDehydrated = false;
				isThirsty = true;
			} else {
				if( !hasDrunk ) {
					if( isTired || !paMaxed() ) {
						pa = maxPa();
						isTired = false;
					}
					hasDrunk = true;
				}
				if( isThirsty ) {
					isThirsty = false;
				}
			}
		}
		update();
	}

	public function changeHunger(delta:Int, fl_bypassViolentRule:Bool) {
		if( map.hasMod("GHOULS") && delta != 0 )
			if( fl_bypassViolentRule || !db.MapVar.getBool(getMapForDisplay(), "violentGhoul") )
				ghoulHunger = Std.int( Math.min(100, Math.max(0, ghoulHunger + delta) ) );
		update();
	}

	public function drinkAlcohol() {
		if( isDrunk ) return;
		isDrunk = true;
		refillMoves();
		isTired = false;
		update();
	}

	public function setTired() {
		isTired = true;
		pa = 0;
		update();
	}

	public function getBanItems(?all=false) {
		var fl_inTown = inTown();
		var tools = Lambda.filter( getTools(), function(t:Tool) {
			return	(fl_inTown || (!fl_inTown && !t.inBag)) &&
					!t.soulLocked &&
					( all || t.hasType(Critical) || t.hasType(Armor) );
		});
		var recup = new Array();
		for (t in tools) {
			db.ZoneItem.addToCity( map, t );
			recup.push(t.print());
			t.delete();
		}
		return recup;
	}

	public function cityBan() {
		var recup = getBanItems();
		GhostReward.gain( GR.get.ban, this );
		isCityBanned = true;
		db.Complaint.manager.clear(this);
		update();
		if( hasHeroUpgrade("revenge") && getMapForDisplay().days >= Const.get.MinRevengeDay ) {
			Tool.add( XmlData.getToolByKey("poison").toolId, this, true);
			Tool.add( XmlData.getToolByKey("poison").toolId, this, true);
		}
		return recup;
	}

	public function setMajorEvent(e:String, ?fl_update=true) {
		majorEvent = e;
		if( fl_update )
			update();
	}
	public function clearMajorEvent(?fl_update=true) {
		majorEvent = null;
		if( fl_update )
			update();
	}

	public function losePa( n: Int) {
		pa = Std.int(Math.max(0, pa-n));
		if(pa <= 0) isTired = true;
		update();
	}

	public function canDoTiringAction(cost:Int) {
		return (pa-cost) >= 0 && !isTired;
	}

	public function doTiringAction(cost) {
		if( !canDoTiringAction(cost) )
			return;
		pa -= cost;
		if( pa <= 0 )
			setTired();
		else
			update();
	}

	public function hasTrunkCapacity(?needed=1) {
		return getTrunkCapacity() - Tool.manager.countTools(this) >= needed;
	}

	public function getTrunkCapacity() {
		var cap = Const.get.DefaultTrunkCapacity;
		if( hasHeroUpgrade("chest1") ) cap++;
		if( hasHeroUpgrade("chest2") ) cap++;
		return cap + homeCapacity + (if(hero) 1 else 0);
	}

	public function hasTrunkOverflow() {
		return Tool.manager.countTools(this) > getTrunkCapacity();
	}

	public function hasBagOverflow() {
		return Tool.manager.countTools(this, true) > getBagCapacity();
	}

	public function hasHeroUpgrade(key) {
		return XmlData.hasHeroUpgrade(this, key);
	}

	public function getBagCapacity() {
		var cap = Const.get.DefaultBagCapacity;
		if( hero ) cap++;
		if( hasHeroUpgrade("bag") ) cap++;
		return cap;
	}

	public function getCapacity() {
		var cap = getBagCapacity();
		for( tool in getInBagTools() ) {
			if( !tool.hero || tool.hero && hero ) {
				cap += tool.transport;
			}
			if( !tool.soulLocked ) {
				cap -= 1;
			}
		}
		return cap;
	}

	public function hasCapacity(?neededSlots:Int) {
		return 	if( neededSlots == null ) 	getCapacity() > 0;
				else 						getCapacity() >= neededSlots;
	}

	public function canMailAll() {
		return hero && hasHeroUpgrade("mailAll");
	}

	public function canPickTool(t:Tool) {
		if( t.isHeavy ) {
			for( tt in getInBagTools() ) {
				if( tt.isHeavy )
					return false;
			}
		}
		return hasCapacity();
	}
	
	public function getHomeDefenseItems() {
		var count = 0;
		for( t in getTools() ) {
			if ( t == null ) continue;
			if ( t.isBroken || t.inBag ) continue;
			//
			if( t.key == "soul" || t.key == "red_soul" ) {
				count += 2;
			} else if ( t.hasType(Armor) ) {
				count ++;
			}
		}
		//
		return count;
	}

	public function getWeaponsScore() : Float{
		var me = this;
		var l = getToolsByType(Weapon, null, true);
		if( l.length == 0 ) return 0;
		var list = l.filter( function(t) {
			return !t.isBroken && t.inBag && (!t.hero || (t.hero && me.hero)) && t.power > 0;
		});
		var points : Float = 0.0;
		for( a in list ) {
			points += a.power;
		};
		return points;
	}
	
	public function getGuardWeapons() {
		var tt = getTools(true);
		if( tt == null || tt.length <= 0)
			return new List();
		
		return tt.filter( function( tool ) {
			if( tool == null )
				return false;
			var guard = tool.getGuard(this.map);
			if( guard == null || guard == 0 )
				return false;
			if( tool.hero && !hero )
				return false;
			if( !tool.inBag )
				return false;
			return true;
		});
	}
	
	public function getHomeDefense() {
		return getHomeDefenseInfos().total;
	}

	public function getHomeDefenseInfos() {
		var level = getHome().def;
		var up = homeDefense;
		
		var items = getHomeDefenseItems();
		var heroBonus = if(hero) Const.get.HeroDefBonus else 0;
		var job = if(jobId != null && job.key == "guardian") Const.get.GuardianHomeDefBonus else 0;
		return {
			level	: level,
			up		: up,
			items	: items,
			hero	: heroBonus,
			job		: job,
			total	: if(jobId == null && hero) 0 else up + level + items + heroBonus + job,
		}
	}

	public function addPa( n : Int, ?fl_caped=false ) {
		pa += n;
		if( fl_caped && pa > maxPa() )
			pa = maxPa();
		if( isTired )
			isTired = false;
		if( pa > 30 )
			pa = 30;
		update();
	}

	public inline function getPa() {
		return pa;
	}
	
	public inline function getPc() {
		return 	if( map.hasMod("JOB_TECH") ) UserVar.getValue(this, "buildingActions", 0 );
				else 0;
	}
	
	public inline function usePc(pcount:Int) {
		if( !map.hasMod("JOB_TECH") ) throw "invalid call, restricted to technician";
		var v = db.UserVar.manager.getVar(this, "buildingActions", true); // lock requis
		if( v.value < pcount ) throw "invalid action : not enough pc";
		v.value -= pcount;
		v.update();
		db.GhostReward.gain(GR.get.buildr, this, pcount);
	}
	
	public inline function getCharlatanActions() {
		return 	if ( isShaman ) db.UserVar.getValue(this, "charlatanActions", 0 );
				else 0;
	}
	
	public inline function addCharlatanActions(pCount:Int=1) {
		return 	if ( isShaman ) db.UserVar.manager.fastInc(this.id, "charlatanActions", pCount );
				else 0;
	}
	
	public inline function useCharlatanActions(pCount:Int=1) {
		return 	if ( isShaman ) db.UserVar.manager.fastInc(this.id, "charlatanActions", -pCount );
				else 0;
	}

	public function setPa(n) {
		pa = n;
		if( n > 0 && isTired )
			isTired = false;
		update();
	}

	public function maxPa() : Int {
		var n = Const.get.PA;
		n -= if (isWounded) 1 else 0;
		return Math.floor( Math.max(0, n) );
	}

	public function paBonus() {
		return 	if (jobId != null && job.key =="eclair")	Const.get.RangerBonus;
				else										0;
	}

	public function paMaxed() {
		return getPa() >= maxPa();
	}

	public function terrorize(?map:Map, ?fl_update=true) {
		if( !isPlaying() || isTerrorized ) return;
		if( hasTool("lilbook", true) ) return;
		
		if( isOutside ) {
			map = if(map == null) getMapForDisplay() else map;
			if( zoneId != map.cityId )
				handler.OutsideActions.updateZoneControl(zone, -getControlScore(), map);
		}
		isTerrorized = true;
		if( fl_update ) update();
	}

	public function calmDown(?map:Map, ?fl_update=true) {
		if( !isPlaying() || !isTerrorized ) return;
		isTerrorized = false;
		if( isOutside ) {
			map = if(map == null) getMapForDisplay() else map;
			if( zoneId != map.cityId )
				handler.OutsideActions.updateZoneControl(zone, getControlScore(), map);
		}
		if( fl_update ) update();
	}

	public function getAllTools(?lock=false) {
		return sortTools( getTools(lock) );
	}

	public function getInBagTools(?lock=false) {
		if( lock )
			return sortTools( Lambda.filter( getTools(true), function( t : Tool ) { return t.inBag; } ) );
		else
			return sortTools( Lambda.filter( getTools(), function( t : Tool ) { return t.inBag; } ) );
	}

	public function getChestTools(?lock=false) {
		if( lock )
			return sortTools( Lambda.filter( getTools(true), function( t : Tool ) { return !t.inBag; } ) );
		else
			return sortTools( Lambda.filter( getTools(), function( t : Tool ) { return !t.inBag; } ) );
	}

	public static function sortTools(list ) {
		var arr = Lambda.array(list);
		arr.sort( function(a:Tool, b:Tool) {
			if( a.soulLocked && b.soulLocked ) {
				return tools.Utils.compareStrings(a.name, b.name);
			}
			if( a.soulLocked ) return -1;
			if( b.soulLocked ) return 1;
			if( a.name.toLowerCase() < b.name.toLowerCase() ) return -1;
			if( a.name.toLowerCase() > b.name.toLowerCase() ) return 1;
			return Std.random(3) - 1; // randomisation pour cacher les items empoisonnés
		} );
		return Lambda.list(arr);
	}

	public function getOutsideLimited() {
		var tools = getTools(false);
		var outsideLimited = Lambda.array( Lambda.filter( tools, function( t: db.Tool ) {
			if( t.action == null || t.action == "" ) return false;
			if( !t.inBag ) return false;
			if( t.limit == "town" ) return false;
			return true; }
		) );
		return sortActions( outsideLimited );
	}

	public function sortActions(arr:Array<Tool>) {
		arr.sort( function(a:Tool,b:Tool) {
			if( a.soulLocked && b.soulLocked ) {
				if(a.name > b.name) return -1;
				if(a.name < b.name) return 1;
				return 0;
			}
			if( a.soulLocked ) return -1;
			if( b.soulLocked ) return 1;
			if( a.name > b.name ) return 1;
			if( a.name < b.name ) return -1;
			return Std.random(3) - 1; // randomisation pour cacher les items empoisonnés
		});
		return arr;
	}

	public function getLimitedInBagTools(from) {
		var l = new List();
		for( t in getInBagTools() )
			if( t.action != "" && (t.limit == from || t.limit == "") )
				l.add( t );
		return l;
	}

	public function hasDoorOpened() {
		return 	if( mapId == null )	false;
				else 				map.hasDoorOpened();
	}

	public function getInTownTools() {
		return sortTools( Tool.manager.getInTownTools(this) );
	}

	public function getLimitedInTownTools() {
		var l = new List();
		for( t in getInTownTools() ) {
			if( t.action != "" && t.limit!="outer" )
				l.add( t );
		}
		return l;
	}

	public function getToolActions(from,tools : List<Tool>) {
		var l = new Array();
		for (t in tools)
			if( t.action != "" && (t.limit==from || t.limit=="") )
				l.push(t);
		l = sortActions(l);
		return l;
	}

	public function getInTownOrderedTools() {
		var tlist = getInTownTools();
		var a = new List();
		var ol = new Array();
		for( tool in tlist ) {
			if( ol[tool.toolId] == null ) {
				ol[tool.toolId] = { tool:tool, stock:1 };
			} else {
				ol[tool.toolId].stock++;
			}
		}
		var i=0;
		while( i < ol.length ) {
			if( ol[i] == null ) {
				ol.splice(i, 1);
			} else {
				i++;
			}
		}
		var arr = Lambda.array(ol);
		arr.sort( function(a,b) {
			return tools.Utils.compareStrings(a.tool.name,b.tool.name);
		});
		return arr;
	}

	public function getDeco() {
		return Lambda.filter(getTools(), function(t: Tool) {return (!t.isBroken && t.deco > 0 );});
	}
	
	public function getControlScore() {
		if( isTerrorized ) 
			return 0;
		
		var score = 0.0 + Const.get.UserControl;
		for( t in getInBagTools(false) ) {
			var s = if(t.hasType(Control)) t.power else 0;
			score += s;
		}
		if( hasHeroUpgrade("control") ) {
			score += 1;
		}
		if( isClean && hasHeroUpgrade("drugclean") ) {
			score += 1;
		}
		if( isGuide && zone != null ) {
			score += zone.countPlayers();
		}
		return Math.floor(score);
	}

	public function getDecoScore() {
		return getDecoScoreFromUserDefinedList( getToolsByType(Furniture) );
	}

	public function getDecoScoreFromUserDefinedList( f : List<Tool> ) {
		if( f == null ) return 0;
		var deco = f.filter( function(tool) {
			return !tool.inBag && !tool.isBroken;
		});
		var total = 0;
		for( tool in deco ) total += tool.deco;
		return total;
	}

	public function hasTool( key : String, ?inBag : Bool, ?lock ) {
		if( inBag ) {
			var ibt = getInBagTools(lock);
			if( ibt == null || ibt.length <= 0 ) {
				return null;
			}
			for( t in ibt ) {
				if( t.key == key )
					return true;
			}
			return false;
		}
		
		for( t in getTools() ) {
			if( t == null )
				continue;
			if( t.key == key )
				return true;
		}
		return false;
	}

	public function hasToolCount( key : String, n:Int ) {
		var found = 0;
		for( t in getTools(true) ) { // force le lock pour qu'il n'y ait pas d'ation en parrallèle
			if( t.key == key && !t.isBroken )
				found++;
		}
		return found >= n;
	}
	
	public function getGuardianInfo() {
		return if ( cachedGuardianInfos != null ) {
			cachedGuardianInfos;
		} else {
			var gInfos : data.Guardians.GuardianInfo = {
				def:0,
				base:data.Guardians.BASE,
				survivalBonus:0,
				job : if( jobId == null ) data.Guardians.getEmptyJobInfo() else data.Guardians.getJobInfo( job.key ),
				tools : new List(),
				status : new List(),
			};
			
			var status = ["isClean", "isWounded", "isConvalescent", "isTired", "isDehydrated", "isInfected", "isDrugged", "isAddict", "isTerrorized", "isHaunted", "isGhoul", "isDrunk", "isHungOver"];
			for( s in status ) {
				if( Reflect.getProperty(this, s) == true ) {
					var statusInfo = data.Guardians.getStatusInfo(s);
					if( statusInfo == null ) throw "Invalid status " + s + ", nothing is corresponding in ODS";
					gInfos.status.add( statusInfo );
				}
			}
			
			for( t in getGuardWeapons() ) {
				if( t.isBroken ) continue;
				gInfos.tools.add( data.Guardians.getToolInfo( t.key, this.map ) );
			}
			
			//CHECK JOB
			if( gInfos.job == null ) throw "Invalid job key " + job.key + ", nothing is corresponding in ODS";
			// DEF
			gInfos.def = gInfos.base.baseDef;
			gInfos.def += gInfos.job.def;
			gInfos.tools.map( function(t) gInfos.def += t.def );
			gInfos.status.map( function(s) gInfos.def += s.def );
			// SURVIVAL BONUS
			gInfos.survivalBonus += gInfos.job.survivalBonus;
			gInfos.status.map( function(s) gInfos.survivalBonus += s.survivalBonus );
			gInfos;
		}
	}
	
	public function cacheGuardianInfos()
	{
		cachedGuardianInfos = Reflect.copy( getGuardianInfo() );
		return cachedGuardianInfos;
	}

	public function findTool( key : String, ?inBag : Bool ) {
		if( inBag ) {
			for( t in getInBagTools() ) {
				if( t.key == key )
					return t;
			}
			return null;
		}

		for( t in getTools() ) {
			if( t == null )
				continue;
			if( t.key == key )
				return t;
		}
		return null;
	}

	public function countToolsByType( type : ToolType, ?inBag:Bool ) {
		return getToolsByType(type,inBag).length;
	}

	public function getTools(?lock=false) {
		return Tool.manager._getUserTools(this, lock);
	}

	public function hasToolsByType( type : ToolType, ?inBag:Bool ) {
		var found = getToolsByType(type, inBag);
		return found.length > 0;
	}

	public function getToolsByType( tpe : ToolType, ?inBag:Bool, ?ignoreType:ToolType, ?lock : Bool ) {
		var type = Std.string( tpe );
		var tt = getTools(lock);
		if( tt == null || tt.length <= 0)
			return new List();

		var me = this;
		return tt.filter( function( tool ) {
			if( tool == null )
				return false;

			if( tool.types == null )
				return false;

			if( tool.hero && !me.hero )
				return false;

			if( inBag!=null && tool.inBag!=inBag )
				return false;

			if( ignoreType!=null && tool.hasType(ignoreType) )
				return false;

			for( t in tool.types ) {
				if( t == type ) {
					return true;
				}
			}

			return false;
		});
	}

	public function hidesTools() {
		return homeHidden;
	}

	public function homeProtected() {
		return hasToolsByType(Lock, false) || homeSafe || XmlData.homeUpgrades[homeLevel].hasLock || hasTool("dfhifi", false);
	}

	public function canBeStolen() {
		return dead || !inTown() && !homeProtected();
	}

	public function cooledDownAction() {
		var limit = map.getPickLimit();
		var now = Date.now().getTime();
		var range = DateTools.minutes(15);
		var banLength = DateTools.minutes(Const.get.AbuseBan);
		var extraBanLength = DateTools.minutes(Const.get.AbuseExtraBan);

		// ban terminé ?
		if( bankBan != null && now > bankBan.getTime() )
			bankBan = null;

		if( bankBan != null ) {
			// ban en cours
			bankBan = DateTools.delta( bankBan, extraBanLength);
		} else {
			// liste des N dernières prises
			var list = if(takes==null) new Array() else takes.split(",");
			var takeList : Array<Float> = new Array();
			for(t in list)
				takeList.push( Std.parseFloat(t) );
			takeList.sort(function(a,b) { return Reflect.compare(a,b); });
			takeList.push( now );

			// on filtre les prises trop vieilles
			while( takeList.length > 0 && now-takeList[0] > range )
				takeList.splice(0, 1);

			if( now-takeList[0] <= range && takeList.length > limit ) {
				// trop de prises en moins de X minutes
				if( bankBan == null )
					bankBan = DateTools.delta( Date.now(), banLength); // début du ban
				else
					bankBan = DateTools.delta( bankBan, extraBanLength); // ban prolongé
				takes = null;
			} else
				takes = ""+takeList.join(",");
		}

		// sauvegarde
		update();
		return bankBan==null;
	}

	public function isOnline() {
		var now = DateTools.delta( Date.now(), -DateTools.minutes(Const.get.OnlineStatusMinutes) );
		var minTime = DateTools.format( now, "%Y-%m-%d %H:%M" );
		return Db.execute("SELECT count(*) FROM Session WHERE uid="+id+" AND mtime>='"+minTime+"'").getIntResult(0) > 0;
	}

	public function getHome() {
		return XmlData.homeUpgrades[homeLevel];
	}

	public function getHomeUpgrades() {
		var list = db.HomeUpgrade.manager.getUpgradesByUser(this);
		var olist = new List();
		for( up in list ) {
			var info = HomeUpgradeXml.getByKey( mt.db.Id.decode(up.upkey) );
			if( info != null ) {
				olist.push({info:info,level:up.level});
			}
		}
		return olist;
	}
	
	public function getAccessibleMaps() {
		var wantNoobmaps = survivalPoints < db.Version.getVar("minXp");
		var playedMaps = Lambda.map( Cadaver.manager.getPlayedMapsIds( this ), function(info : {mapId:Int}) {return info.mapId;} );
		var list = Map.manager._getAccessibleMaps( id, playedMaps, wantNoobmaps );
		return list;
	}

	public function hasAccessibleMaps() {
		var playedMaps = Lambda.map( Cadaver.manager.getPlayedMapsIds( this ), function(info : {mapId:Int}) {return info.mapId;} );
		return Map.manager._countAccessibleMaps( id, playedMaps );
	}


	public function getAvailableMaps( fl_onlyCustomMaps : Bool ) {
		var playedMaps = Lambda.map( Cadaver.manager.getPlayedMapsIds( this ), function(info : {mapId:Int}) {return info.mapId;} );
		return Map.manager.getAvailableMaps(playedMaps, fl_onlyCustomMaps);
	}

	public function canHaveWater() {
		return waterTaken == 0;
	}
	
	public function hideCommercials() {
		return survivalPoints < 30;
	}

	/* ---------------------- VOTE --------------------- */

	public function hasVisited( zone : Zone ) {
		if( zone.type == 1 ) {
			return true;
		} else {
			return hasVisitedByZoneId( zone.id );
		}
	}

	public function hasVisitedByZoneId( id : Int ) {
		if( zones == null )
			return false;
		return zones.exists( id );
	}

	public function changeZone( newZone : Zone ) {
		endGather = null;
		isOutside = true;
		isBrave = false;
		zone = newZone;
		zones.set( newZone.id, 0 );
		pa -= 1;
		
		if( pa<=0 ) {
			isTired = true;
		}
		if( steps++ >= Const.get.StepsForThirst && !isGhoul ) {
			steps = 0;
			if( isDehydrated ) {
				die( DT_Dehydrated );
				App.reboot();
				return;
			} else if( isThirsty ) {
				isThirsty = false;
				isDehydrated = true;
			} else
				isThirsty = true;
		}
		update();
	}

	public function hasPaToMove() {
		return pa > 0;
	}

	public function canMove(?zone:Zone) {
		if( zone == null ) zone = getZoneForDisplay();
		var h = zone.humans;
		var z = zone.zombies;
		
		if( isCamping() )
			return false;
		if( !zone.isInFeist() )
			return true;
		else if( hasTool("camoVest",true) )
			return true;
		else if( isBrave )
			return true;

		return false;
	}

	public function getMapForDisplay() {
		if( mapId == null )
			return null;
		if( cachedMap == null )
			cachedMap = Map.manager.get( mapId, false );
		return cachedMap;
	}

	public function getZoneForDisplay() {
		if( mapId == null || zoneId == null || dead )
			return null;
		if ( cachedZone == null )
			cachedZone = Zone.manager.get(zoneId, false);
		return cachedZone;
	}

	public function inTown() {
		if( mapId == null )
			throw UserHasNoMap;
		if( isOutside )
			return false;
		var m = getMapForDisplay();
		return m.cityId == zoneId;
	}

	public function getCity() {
		if( mapId == null )
			return null;
		var m = getMapForDisplay();
		return m._getCity();
	}

	public function getCityItems() {
		if( mapId == null )
			return null;
		return map.getCityItems();
	}

	public function getOutsideMap()  {
		return map._getOutsideDescription();
	}

	public function hasWound( w : WoundType ) {
		return isWounded && woundType == Type.enumIndex(w);
	}

	public function getWoundType() {
		if( woundType == null )
			return Text.get.W_Unknown;

		switch( woundType ) {
			case Type.enumIndex( W_Arm ): return Text.get.W_Arm;
			case Type.enumIndex( W_Hand ): return Text.get.W_Hand;
			case Type.enumIndex( W_Head ): return Text.get.W_Head;
			case Type.enumIndex( W_Foot ): return Text.get.W_Foot;
			case Type.enumIndex( W_Leg ): return Text.get.W_Leg;
			case Type.enumIndex( W_Eye ): return Text.get.W_Eye;
		}
		
		return Text.get.W_Unknown;
	}

	public function infect(?fl_update = true) {
		if( isGhoul )
			return false;
		
		if( isImmune )
			return false;
			
		if( isInfected )
			return false;
			
		if( contamination && !usedContamination ) {
			usedContamination = Std.random(2) == 0;
			
			var text = usedContamination ? Text.get.UsedContamination : Text.get.UsedContaminationFailed;
			if( App.notification==null ) App.notification = text;
			else App.notification += " <p>" + text + "</p>";		
			
			if( usedContamination ) {
				if( fl_update )
					update();
				return false;
			}
		}
		
		isInfected = true;
		
		if( fl_update )
			update();
		
		return true;
	}

	inline function get_magicProtection():Bool {
		return getVarValue("magicProtection") == 1;
	}
	
	inline function set_magicProtection(v:Bool):Bool {
		this.setVarValue("magicProtection", v ? 1 : 0);
		return v;
	}
	
	public function wound(?fl_update=true, ?wtype:WoundType) {
		if( isWounded )
			return false;
		if( !dead && map != null )
			db.GhostReward.gainByUser( GR.get.wound, this );
		isWounded = true;
		if( wtype == null )
			woundType = Std.random( Type.getEnumConstructs( WoundType ).length );
		else
			woundType = Type.enumIndex(wtype);
		if( fl_update )
			update();
		return true;
	}

	public function updateScores(?fl_update = true) {
		var oldPoints = survivalPoints;
		survivalCount = 0;
		survivalPoints = 0;
		var cadavers = db.Cadaver.manager.getUserCadavers( this );
		if( cadavers.length > 0 ) {
			var d = 0;
			var pts = 0;
			var sd = 0;
			for( c in cadavers ) {
				d += c.survivalDays;
				pts += c.getSurvivalPoints();
				sd 	+= c.getSurvivalPoints();
			}
			survivalCount = d;
			survivalPoints = pts;
			survivalDays = sd;
		}
		
		var experiencedPoints = db.Version.getVar("minXp");
		if( db.GameMod.hasMod("EXPERIENCED_BONUS") && oldPoints < experiencedPoints && survivalPoints >=  experiencedPoints ) {
			UserVar.setValue(this, "experiencedBonus", 2, true);
		}
		if ( oldPoints < experiencedPoints && survivalPoints >=  experiencedPoints ) {
			this.setVarValue("newlyExperienced", 1, true);
		}
	//DEBUG	
	//	this.setVarValue("experiencedPoints", experiencedPoints, true);
	//	this.setVarValue("oldPoints", oldPoints, true);
	//	this.setVarValue("survivalPoints", survivalPoints, true);
		
		if( fl_update )
			update();
	}
	
	public function cancelGhoul(?fl_update = true) {
		if( isGhoul ) {
			isGhoul = false;
			majorEvent = null;
			ghoulHunger = 0;
			if( fl_update )
				update();
			return true;
		}
		return false;
	}
	
	public function getGuardianStats(?p_map:Map): { death:Int, impact:Int }
	{
		var lMap = if ( p_map != null ) p_map else this.map;
		//
		var guardianInfos = getGuardianInfo();
		var deathProba:Float = 	if ( lMap.isHardcore() ) 	(Const.get.GuardianHardcoreDeathChance - guardianInfos.survivalBonus);
								else 						(Const.get.GuardianDeathChance - guardianInfos.survivalBonus);
		//
		var impactCoef = (lMap.hasCityBuilding("catapult3") ? 0.75 : 1.0);
		var impactProba:Float = if ( lMap.isHardcore() ) 	(Const.get.GuardianHardcoreImpactChance - guardianInfos.survivalBonus);
								else 						(Const.get.GuardianImpactChance - guardianInfos.survivalBonus);
		impactProba = Std.int( impactProba * impactCoef);
		//effet cumulatif
		var guardsCount = db.UserVar.getValue(this, "guards", 0);
		if ( guardsCount < 0 ) guardsCount = 0;//Just in case...
		
		// effet cumulatif réduit pour les supers héros
		var guardsFactor = hasHeroUpgrade("guardian") ? 0.5 : 1.0;
		
		if ( lMap.isHardcore() )
		{
			deathProba 	+= Const.get.GuardianChanceLost * guardsCount * guardsFactor;
			impactProba += Const.get.GuardianPandemoniumChanceLost * guardsCount * guardsFactor;			
		}
		else
		{
			deathProba 	+= Const.get.GuardianChanceLost * guardsCount * guardsFactor;
			impactProba += Const.get.GuardianChanceLost * guardsCount * guardsFactor;
		}
		return { death:mt.MLib.clamp(Std.int(deathProba), 0, 100), impact:mt.MLib.clamp(Std.int(impactProba), 0, 100) };
	}
	
	public function makeGhoul(?fl_update = true)
	{
		isGhoul = true;
		isInfected = false;
		isThirsty = false;
		isDehydrated = false;
		isWounded = false;
		var map = getMapForDisplay();
		if( map.isHardcore() )
			ghoulHunger = Std.int( .5 * Const.get.GhoulMaxHunger );
		else if( map.isFar() )
			ghoulHunger = Std.int( .3 * Const.get.GhoulMaxHunger );
		else
			ghoulHunger = 0; // jamais affamée au début en RNE
		setMajorEvent("ghoul", fl_update);
		if( fl_update )
			update();
	}

	public function heal(?fl_update=true) {
		if( !isWounded ) return false;
		if( isConvalescent ) return false;
		isWounded = false;
		woundType = null;
		isConvalescent = true;
		if( fl_update ) update();
		return true;
	}

	public function isPlaying() : Bool {
		return isLogged() && mapId != null && !dead;
	}

	public function isInGame() : Bool {
		return isPlaying() && jobId != null;
	}

	public function isLogged() : Bool {
		return (id != 0 && id != null && twinId != null);
	}

	public override function update() : Void {
		if( id == null ) return;
		super.update();
	}

	public function haunt() {
		if ( !map.hasMod("SHAMAN_SOULS") )
			return;
		die(DT_Haunted);
		App.reboot();
	}
	
	// /!\ WARNING : si les règles de mort changent, modifier également les requêtes SQL dans le CRON
	public function die( deathType : DeathType ) {
		if( mapId != null ) {
			//zone.changeHumanScore( -getControlScore() );
			zone.recalcHumanScore([this], true);
			//
			if( map.hasMod("EXPLORATION") ) {
				if( zone.explo != null && zone.explo.user == this ) {
					var explo = Explo.manager.get(zone.id);
					handler.ExploActions.onUserFailsExplo(explo);
					explo.update();
				}
			}
			if( deathType == DT_HangedDown )	GhostReward.gain(GR.get.dhang, this);
			if( deathType == DT_Crucified ) 	GhostReward.gain( GR.get.paques, this);
			if( getDecoScore() > 0 )			GhostReward.gain(GR.get.deco, this, getDecoScore());
			
			if( deathType == DT_GhoulAttack && isOutside )
				ZoneItem.create(zone, XmlData.getToolByKey("bone_meat").toolId);
			
			if( deathType == DT_Dehydrated )
				GhostReward.gain( GR.get.dwater, this );
			
			var inTown = !isOutside;
			var c = Cadaver.create( map, this, name, Type.enumIndex( deathType ), map.days, map.days - 1 - (mapRegisterDay-1), inTown );
			c.homeLevel = homeLevel;
			c.mapName = map.name;
			c.createDate = Date.now();
			if( deathType == DT_MeatCage || deathType == DT_Abandon )
				c.garbaged = Text.get.Someone;
			dropAll(c);
			c.update();
			
			if( (map.countSurvivors() - 1) <= 0 ) { // Dernier joueur ?
				db.UserLog.insert( this, KLastDead, "No reward MAPDAY=" + map.days, true, map ); // attention ce log sert pour déterminer qui est mort ultime dans l'historique d'âme
				map.status = Type.enumIndex( EndGame );
			} else {
				var m = getMapForDisplay();
				CityLog.add( CL_Death, Text.fmt.CL_Death( {name:name,reason:c.getDeathReason()} ), m, this );
				if( deathType != DT_HangedDown && deathType != DT_Crucified && deathType != DT_MeatCage )
					CityLog.addToZone( CL_OutsideEvent, Text.fmt.OutsideDeath( {name:print(), reason:c.getDeathReason()} ), m, zone );
				if( zone.countPlayers() == 1 )
					CityLog.manager.clearLogs(zone.id);
					
				Cron.dropSouls(map, 1);
			}
			
			if( map.hasMod("GHOULS") && isGhoul ) {
				// goule qui meure sans avoir tué personne = abus !
				var victims = db.GameAction.manager.countAction(this, "devourTotal");
				if( victims <= 0 ) {
					db.MapVar.manager.fastInc( mapId, "lazyGhoul" );
				}
			}
			
			// S14
			if( map.hardcore )
				db.GhostReward.specialGain(GR.get.pande, this, Std.int(Math.pow(Math.max(0, map.days - 1 - 3), 1.5)));
			
			map.update();
		}
		dropEscort();
		dropAllSquad();
		dead = true;
		clearMajorEvent(false);
		update();
		
		db.ZoneAction.manager.deleteForUser(this);
		db.UserVar.delete(this, "guards");
		Db.execute("DELETE FROM MessageThread WHERE uto = "+id);
		Db.execute("DELETE FROM Complaint WHERE suspect = "+id );
	}

	// /!\ WARNING : si les règles de dropALL changent, modifier également les requêtes SQL dans le CRON
	public function dropAll( c : Cadaver ) {
		if( c.user != this )
			throw "dropAll sur un user différent";

		db.Tool.manager.deleteSoulLockedTools( this );
		if( c.diedInTown ) {
			// Tous les objets (maison et sac) restent dans les ruines de la maison
			// suppression automatique des objets Tool
			db.CadaverRemains.manager.convertTools( this, c );
		} else {
			// Tous les objets de la maison restent dans les ruines de la maison
			// suppression automatique des objets Tool
			db.CadaverRemains.manager.convertTools( this, c, true );
			// Tous les objets du sac sont dropés dans la zone
			db.ZoneItem.manager.dropUserTools(  this, zone );
			// Tous les objets (Tool) sont supprimés
			Db.execute("DELETE FROM Tool WHERE userId="+id);
		}
	}

	public function getDoneActions() {
		return ZoneAction.manager.getDoneActions( this );
	}
	
	public function print() {
		return "<strong>"+name+"</strong>";
	}
	
	public function printFull() {
		return print() + if(job != null) " (" + "<img src='"+App.IMG+"/gfx/icons/item_"+job.icon+".gif' alt='"+job.name+"'/>" + ")" else "";
	}
	
	// [!!] Attention, en cas de modification de ce gameplay : modifier également l'implémentation dans Cron.hx dans la méthode gather
	public function getGatherDuration() {
		return if(job.key == "collec") Const.get.GatherTimeShort else Const.get.GatherTime;
	}

	public function getGarbageSearchLimit() {
		var n = Const.get.MaxGarbageSearches;
		return if(job.key == "collec") n+1 else n;
	}

	public function getFellowGuards() {
		return manager.getGuards( map );
	}


	/******* ESCORTES ***/
	//{region Escortes
	public function follow(?master:User) {
		if( !map.hasMod("FOLLOW") || !(master.hero||master.isGuide) || master.id==id || master.hasLeader() || hasLeader() || master.zoneId!=zoneId || !playsWithMe(master) )
			return false;
		isWaitingLeader = false;
		leader = master;
		update();
		return true;
	}

	public function isFollower(?master:User) {
		if( !map.hasMod("FOLLOW") ) return false;
		if( master==null ) master = App.user;
		return (master.isGuide||master.hero) && playsWithMe(master) && zoneId==master.zoneId && leaderId!=null && leaderId==master.id;
	}

	public function hasLeader() {
		return map.hasMod("FOLLOW") && leaderId!=null;
	}

	public function squadCanMove(?squad, zone:db.Zone) {
		if( !map.hasMod("FOLLOW") ) return true;
		if( squad == null ) squad = manager.getSquad(this);
		if( squad.length == 0 ) return true;
		for( pet in squad ) {
			if( pet.getPa()<=0 ) return false;
			if( pet.getPa()<=0 ) return false;
			if( !pet.canMove(zone) ) return false;
			if( !pet.isFollower(this) || !pet.isOutside ) {
				// escorte invalide (plus dans la même zone), on le drop
				pet.dropEscort();
				return false;
			}
		}
		return true;
	}

	public function dropEscort() {
		if( !hasLeader() ) return;
		leader = null;
		wasEscorted = true;
		if( isOutside )
			isWaitingLeader = true;
		update();
	}

	public function dropAllSquad() {
		manager._dropAllSquad(this);
	}

	public function getLeaderName() {
		if( !hasLeader() ) {
			return null;
		} else {
			return manager.getLeaderName(this);
		}
	}

	public function canDoBannedAction(?map:Map) {
		if( map == null ) map = getMapForDisplay();
		if( !map.hasMod("BANNED") ) return false;
		return isCityBanned || map.chaos;
	}


	/******* CAMPING ***/
	//{region Camping

	public function getCampingChance(specialBonus:Int) {
		var c = 0;
		var czone = getZoneForDisplay();
		if( czone == null )
			return c;
		var cmap = getMapForDisplay();
		var log = new List();

		// camping précédents
		var campChances =
			if( cmap.isHardcore() )
				if( hasHeroUpgrade("camper") )
					[50,45,40,30,20,10,0];
				else
					[50,30,20,10,0];
			else
				if( hasHeroUpgrade("camper") )
					[80,70,60,40,30,20,0];
				else
					[80,60,35,15,0];
		campChances = campChances.concat( [-50, -100, -200, -400, -1000, -2000, -5000] );
		var tries = campCount;
		log.add("tries="+tries);
		c += campChances[ Std.int(Math.min(campChances.length-1, tries)) ];
		log.add("c="+c+" (tries)");

		if( specialBonus>0 ) {
			c += specialBonus;
			log.add("c="+c+" (specialBonus)");
		}

		// hardcore
		if( cmap.isHardcore() ) {
			c -= 40;
			log.add("c="+c+" (hardcore)");
		}

		// building + chances de la zone
		if( czone != null ) {
			c += czone.getDefense();
			log.add("c=" + c + " (zone)");
		}

		// phare
		if( cmap.hasCityBuilding("headlight") ) {
			c += 25;
			log.add("c="+c+" (lighthouse)");
		}
		
		// zone non-déblayée
		if( czone != null && czone.isBuilding() && !czone.hasBuildingExtracted() ) {
			c+=15;
			log.add("c="+c+" (undigged building)");
		}

		// items
		var count = countToolsByType(CampBonus);
		c += count*Const.get.CampBagItem;
		log.add("c="+c+" (items, found "+count+")");


		// zombies
		if( czone != null ) {
			c -= czone.zombies * if( hasTool("camoVest",true) ) 3 else 7;
			log.add("c=" + c + " (zombies)");
		}

		// campeurs
		var campers = Zone.manager.countCampingPlayers(czone);
		if( campers > 0 ) {
			var crowdChances = [0,-10,-30,-50,-70];
			var cc = crowdChances[ Std.int(Math.min(crowdChances.length-1, campers-1)) ];
			if( cc==null )
				cc = crowdChances[crowdChances.length-1];
			c += cc;
			log.add("c="+c+" (crowd)");
		}

		// nuit
		if( map.hasMod("NIGHTMODS") && App.isNight() )
			c += Const.get.CampNightBonus;

		// distance de la ville
		var distChances = [-100, -75, -50, -25, -10, 0, 0, 0, 0, 0, 0, 0, 5, 7, 10, 15, 20];
		c += distChances[ Std.int(Math.min(distChances.length-1, czone.level)) ];
		log.add("c="+c+" (city distance)");

		// ville dévastée
		if( cmap.devastated )
			c -= 50;

		// ermite
		var max = if(hasThisJob("hunter") && map.hasMod("JOB_HUNTER") ) 100 else 90;
		c = Std.int( Math.max(0, Math.min(max,c)) );
		log.add("c="+c+" (RESULT)");
		return c;
	}

	public function loseCamp(?fl_update=true) {
		if( !map.hasMod("CAMP") )
			return;
		if( campStatus == null )
			return;
		campStatus = null;
		lastCampChance = 0;
		if( fl_update )
			update();
	}

	public function isCamping() {
		return map.hasMod("CAMP") && isOutside && campStatus!=null;
	}

	
}



/******* MANAGER ***/
class UserManager extends neko.db.Manager<User>
{
	public function new() {
		super(User);
	}

	override private function make( u : User ) {
		// On récupère la liste des zones dans laquelle est passé le joueur
		if( u.zonesBlob != null && u.zonesBlob != "") {
			var z = neko.Lib.localUnserialize( neko.Lib.bytesReference(u.zonesBlob ));
			if( z != null )
				u.zones = z;
			else
				u.zones = new IntHash();
		}

		if( u.jobId != null ) {
			u.job = XmlData.getJob( u.jobId );
		}
	}

	public function getAll(req:String) {
		return objects( selectReadOnly(req), false );
	}

	override private function unmake( u : User ) {
		u.zonesBlob = neko.Lib.stringReference(neko.Lib.serialize( u.zones ));
	}

	public function updateEventState( state : Int, map : Map ) {
		execute("UPDATE User SET eventState = " + state + " WHERE mapId=" + map.id);
	}

	public function getPlayersByZoneAndPriority( zone : Zone, ?user : User, ?lock:Bool) {
		var sql = "zoneId="+zone.id+" AND dead=0" ;
		if( user != null )
			sql += " AND id != " + user.id ;
		var rs = null;
		if( lock ) {
			rs = Lambda.array( objects(select(sql), true) );
		} else {
			rs = Lambda.array( objects(selectReadOnly(sql), false) );
		}
		rs.sort( function(o1, o2) { return tools.Utils.compareStrings( o1.name, o2.name ); } );
		return rs;
	}
	
	public function getMapUsers( map : Map, includeDeads:Bool, lock:Bool) {
		var rs = null;
		var filter = "";
		if( !includeDeads ) filter = " AND dead=0 ";
		
		if( lock )
			rs = Lambda.array( objects( select("mapId="+map.id+filter), true) );
		else
			rs = Lambda.array( objects( selectReadOnly("mapId="+map.id+filter), false) );
		rs.sort( function(o1, o2) { return Utils.compareStrings(o1.name, o2.name); } );
		return rs;
	}

	public function getMapUserIds(map:Map):List<Int> {
		var rs = results("SELECT id FROM User WHERE mapId="+map.id+" AND dead=0");
		var list = Lambda.map(rs, function(r) { return r.id; });
		return list;
	}

	public function getCityShaman( map:Map ) :Null<db.User> {
		return object( selectReadOnly( "isShaman=1 AND dead=0 AND mapId ="+map.id), false );
	}
	
	public function getCityGuide( map:Map ) :Null<db.User> {
		return object( selectReadOnly( "isGuide=1 AND dead=0 AND mapId ="+map.id), false );
	}
	
	public function getDeathCount( mid : Int ) : Int {
		return execute("SELECT COUNT(*) FROM User WHERE dead=1 AND mapId="+mid).getIntResult(0);
	}

	public function getWounded(map : Map) {
		return objects( selectReadOnly( "isWounded = true AND mapId ="+map.id + " ORDER BY woundType ASC"), false );
	}

	public function getInTownCount(map:Map) {
		return execute("SELECT COUNT(*) FROM User WHERE dead=0 AND isDeleted=0 AND isOutside=0 AND mapId="+map.id ).getIntResult(0);
	}

	public function getAlivePlayersCount(map:Map) : Int {
		return execute("SELECT COUNT(*) FROM User WHERE dead=0 AND isDeleted=0 AND mapId=" + map.id ).getIntResult(0);
	}

	public function getDoorMan(map:Map) : {u:User,date:Date} {
		var r = result( "SELECT userId,dateLog FROM CityLog WHERE zoneId IS null AND userId IS NOT null AND mapId="+map.id+" AND ckey IN ('CL_OpenDoor','CL_CloseDoor') ORDER BY id DESC LIMIT 1" );
		if( r == null || r.length == 0 ) {
			return null;
		} else {
			return {
				u		: get(r.userId),
				date	: r.dateLog,
			};
		}
	}

	public function getMapJobs( map : Map ) : List<{name : String, id: Int, count : Int}> {
		var rs = results("SELECT jobId FROM User WHERE mapId="+map.id+" AND jobId IS NOT NULL AND dead = 0");
		if( rs.length <= 0  )
			return null;
		var h = new IntHash();
		for( r in rs ) {
			if( h.exists( r.jobId ) ) {
				h.set( r.jobId, h.get(r.jobId) + 1 );
				continue;
			}
			h.set( r.jobId, 1 );
		}
		var results : List<{name : String, id: Int, count : Int}> = new List();
		for( key in h.keys() )
			results.add( { name : XmlData.jobs[key].name, id : key, count : h.get(key) } );
		return results;
	}
	
	public function seasonRankings( pSeason : Int, start : Int, limit : Int ) {
		if( start + limit > Const.get.MaxRanking )
			limit = Const.get.MaxRanking - start;
		var sql = "SELECT User.id, User.twinId, User.name, User.customTitle, R.points as survivalDays FROM User, UserRankCache_"+pSeason+" as R WHERE User.id=R.userId AND User.survivalDays>0 AND User.isAdmin=0 AND User.isDeleted=0 ORDER BY R.id, User.id DESC LIMIT "+start+","+limit;
		return cast objects( sql, false );
	}
	
	public function countSeasonRankings( pSeason : Int ) {
		var r = execute("SELECT count(*) FROM UserRankCache_"+pSeason+"").getIntResult(0);
		if( r > 1000 )
			return 1000;
		return r;
	}
	
	public function rankings( start : Int, limit : Int ) {
		if( start + limit > Const.get.MaxRanking )
			limit = Const.get.MaxRanking - start;
		return objects(selectReadOnly("survivalDays>0 AND isDeleted=0 AND isAdmin=0 ORDER BY survivalDays DESC, id DESC LIMIT "+start+","+limit),false);
	}

	public function countRankings() {
		var r = execute("SELECT count(*) FROM User WHERE survivalDays>0 AND isAdmin=0 AND isDeleted=0").getIntResult(0);
		if( r > 1000 )
			return 1000;
		return r;
	}

	public function getTopPlayers(minScore:Int, limit:Int) {
		return results("SELECT id, twinId, name, survivalDays, ghostMsg, customTitle FROM User WHERE survivalDays>="+minScore+" AND isDeleted=0 ORDER BY survivalDays DESC, id DESC LIMIT "+limit);
	}

	public function countByRef(user:User) {
		return execute("SELECT COUNT(*) FROM User WHERE ref="+user.id).getIntResult(0);
	}

	public function getByRef( id : Int) {
		return objects( selectReadOnly("isDeleted=0 AND ref="+id), false );
	}

	public function getGuards( map: Map ) {
		return objects( "SELECT * FROM User where mapId="+map.id+" AND isCityGuard=1 AND dead=0", false );
	}

	public function getByTeam( t : Team ) {
		var rs = Lambda.array( objects( "SELECT * FROM User WHERE teamId = "+t.id, false ) );
		rs.sort( function( o1,o2) { return tools.Utils.compareStrings( o1.name, o2.name ); } );
		return Lambda.list( rs );
	}

	public function getFreeByTeam( t : Team ) {
		var date = DateTools.delta(Date.now(), -DateTools.days(5));
		return objects( select( "teamId="+t.id+" AND dead=0 AND mapId IS NULL AND debt<=0 AND autoJoin=1 AND loginDate>="+quote(date.toString()) ), true );
	}
	
	/*
	public function getFreeByTeam( ) {
		var date = DateTools.delta(Date.now(), -DateTools.days(5));
		return objects( select( "teamId="+t.id+" AND dead=0 AND mapId IS NULL AND debt<=0 AND autoJoin=1 AND loginDate>="+quote(date.toString()) ), true );
	}
	*/

	public function getNameAndIdByMap( map : Map ) {
		var rs = Lambda.array( results( "SELECT id, name, dead FROM User WHERE dead=0 AND mapId="+map.id ) );
		rs.sort( function( o1 : {id:Int,name:String,dead:Bool}, o2: {id:Int,name:String,dead:Bool}) { return tools.Utils.compareStrings( o1.name, o2.name ); } );
		return rs;
	}

	public function countCityBanned( map:Map, isCityBanned:Bool ) {
		return execute( "SELECT COUNT(*) FROM User WHERE mapId="+map.id+" AND dead=0 AND isCityBanned="+(if (isCityBanned) 1 else 0) ).getIntResult(0); // TODO à optimiser ?
	}

	public function invertCityBan(map:Map) {
		execute("UPDATE User SET isCityBanned=NOT isCityBanned WHERE mapId="+map.id);
	}
	
	public function getName(uid:Int) {
		return execute("SELECT name FROM User WHERE id="+uid).getResult(0);
	}

	public function getRandomCitizenExcepting(exceptUids:Array<Int>,map:Map):Int {
		var res = execute("SELECT id FROM User WHERE mapId="+map.id+" AND dead=0 AND id NOT IN ("+exceptUids.join(",")+")");
		var a = new Array();
		for( r in res )
			a.push(r.id);
		if( a.length == 0 )
			return null;
		else
			return a[Std.random(a.length)];
	}

	public function getSquad(user:User, ?lock=false) {
		if( !user.map.hasMod("FOLLOW") ) return new List();
		if( lock )
			return objects( select("leaderId="+user.id+" AND dead=0"), true );
		else
			return objects( selectReadOnly("leaderId="+user.id+" AND dead=0"), false );
	}

	public function countSquad(user:User) {
		if( !user.map.hasMod("FOLLOW") )
			return 0;
		else
			return execute("SELECT count(*) FROM User WHERE leaderId="+user.id).getIntResult(0);
	}

	public function _dropAllSquad(user:User) {
		execute("UPDATE User SET leaderId=null, isWaitingLeader=1, wasEscorted=1 WHERE leaderId="+user.id);
	}

	public function getLeaderName(user:User) {
		return execute("SELECT name FROM User WHERE id="+user.leaderId).getResult(0);
	}

	public function getOutsidePlayers(zoneId:Int, ?lock=false) {
		return
			if( lock )
				objects( select("zoneId="+zoneId+" AND isOutside=1 AND dead=0"), true );
			else
				objects( selectReadOnly("zoneId="+zoneId+" AND isOutside=1 AND dead=0"), false );
	}

	public function getOneNeighbour(map:Map, ?except:db.User, ?criteria:String) {
		var reqExcept = if(except!=null) " AND id!="+except.id+" " else "";
		var reqCrit = if (criteria!=null) " AND "+criteria+" " else "";
		var req = "mapId="+map.id+" AND dead=0 AND jobId IS NOT NULL "+reqCrit+reqExcept;
		var list = objects( selectReadOnly(req), false );
		if( list.length == 0 ) {
			return null;
		} else {
			return Lambda.array(list)[Std.random(list.length)];
		}
	}

	public function getDeadCampers(map:Map) {
		return objects( selectReadOnly("isOutside=1 AND campStatus!=1 AND mapId="+map.id), false );
	}

	public function getDeadOutside(map:Map) {
		return objects( selectReadOnly("isOutside=1 AND mapId="+map.id), false );
	}

	public function getGhoulCandidates(map:Map) {
		return objects( select("mapId="+map.id+" AND isGhoul=0 AND isInTrance=0 AND dead=0 AND isImmune=0 AND isDeleted=0"), true);
	}

	public function countGhouls(map:Map) {
		return execute("SELECT count(*) FROM User WHERE mapId="+map.id+" AND isGhoul=1 AND dead=0 AND isDeleted=0").getIntResult(0);
	}

	public function resetWinners() {
		execute("UPDATE User SET winnerHardcore=0 WHERE winnerHardcore!=0");
		execute("UPDATE User SET winnerNormal=0 WHERE winnerNormal!=0");
	}

	public function setWinners(uids:List<Int>, fl_hardcore:Bool) {
		var fieldName = if(fl_hardcore) "winnerHardcore" else "winnerNormal";
		execute("UPDATE User SET "+fieldName+"=1 WHERE id IN ("+uids.join(",")+")");
	}
	
	public function getAnyone() {
		return object(select("isDeleted=0 AND mapId IS NULL AND dead=0 AND isAdmin=0 LIMIT 1"), true);
	}
	
	public function getByUids(uids:List<Int>) {
		return
		if( uids.length == 0 )
			new List();
		else
			objects(select("id IN ("+uids.join(",")+")"),true);
	}
	
	public function exists( ?name:String, ?uid:Int ) {
		if( name != null )
			return execute("SELECT count(*) FROM User WHERE name="+quote(name)).getIntResult(0)>0;
		if( uid != null )
			return execute("SELECT count(*) FROM User WHERE id="+uid).getIntResult(0)>0;
		return false;
	}
	
	public function byName( name : String, ?lock=false ) {
		if( name == null )
			return null;
		if( lock )
			return search({ name: name }, true).first();
		else
			return search({ name: name }, false).first();
	}
}
