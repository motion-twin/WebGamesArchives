package com;

import com.Protocol;
import mt.MLib;
import Data;

#if (neko && !solver_server)
	#error "Do not include com.SHotel in main index.n!"
#end

class SHotel {
	public static var WORLD_WID = 1000;
	public static var WORLD_HEI = 1000;

	public var level		: Int;
	public var name			: String;
	public var uniqClientId	: Int;
	public var seed			: Int;
	public var rooms		: Array<SRoom>;
	public var clients		: Array<SClient>;
	public var gems			: Int;
	public var money		: Int;
	public var love			: Int;
	public var tasks		: Array<Task>;
	public var inventory	: Array<Item>;
	public var lastEvent	: Float;
	public var lastRealTime	: Float;
	public var miniGameDate	: Float;
	public var miniGameCid	: Int;
	public var bossCd		: Int;
	public var tutorial		: String;
	public var clientDeck	: Array<ClientType>;
	public var cgenDeck		: Array<ClientGeneration>;
	//public var emitDeck		: Array<Affect>;
	public var flags		: Map<String,Bool>;
	public var customs		: Array<Item>;
	public var curQuests	: Array<QuestState>;
	public var messages		: Array<HotelMessage>;
	public var dailyLevel	: Int;
	public var lastDaily	: Float;

	public var stats		: Map<String,Int>;

	public function new(s:HotelState) {
		seed = 1;
		level = 0;
		bossCd = 0;
		rooms = [];
		clients = [];
		tasks = [];
		inventory = [];
		clientDeck = [];
		cgenDeck = [];
		//emitDeck = [];
		customs = [];
		curQuests = [];
		flags = new Map();
		money = 0;
		gems = 0;
		love = 0;
		dailyLevel = 1;
		lastDaily = 0;
		//luckyPoints = 0;
		lastEvent = 0;
		lastRealTime = 0;
		uniqClientId = 0;
		tutorial = "???";
		name = "???";
		stats = new Map();

		loadState(s);
	}


	// Direct methods bypass all the applyEffect system and do manipulate data directly!!
	// PROCEED WITH CAUTION!!!
	public function direct_getLove(now:Float, hid:Int, n:Int) {
		love = MLib.min( getMaxLove(), love+n );
		setTimedFlag("love_"+hid, GameData.LOVE_CD);
		addGoal("loveReceived", n);
		addGoal("visit");
	}

	public function direct_visitedByFriend(uname:String) {
		messages.push( M_Visit(uname) );
		addStat("visit");
	}




	public static function cleanUpName(str:String) {
		if( str==null || !haxe.Utf8.validate(str) )
			return GameData.DEFAULT_HOTEL_NAME;
		str = haxe.Utf8.sub(str, 0, GameData.HOTEL_NAME_MAX_LENGTH);
		str = mt.Utf8.uppercase(mt.Utf8.removeAccents(str));

		var alloweds = new Map();
		for(c in "A".code..."Z".code+1) alloweds.set(c,true);
		for(c in "0".code..."9".code+1) alloweds.set(c,true);
		for(c in ["'","\"","+","-","=","|","~","&","(",")","[","]","<",">","?","!",":"]) alloweds.set(c.charCodeAt(0),true);

		var out = new haxe.Utf8();
		haxe.Utf8.iter(str,function(c){
			if( alloweds.exists(c) )
				out.addChar( c );
			else
				out.addChar( " ".code );
		});

		var out = StringTools.trim(out.toString());
		return out.length==0 ? GameData.DEFAULT_HOTEL_NAME : out;
	}

	public function getQueueLevel() {
		for(r in rooms)
			if( r.type==R_Lobby )
				return r.level;
		return 0;
	}

	public function getQueueLength(?forcedLevel=-1) {
		return 4 + ( forcedLevel<0 ? getQueueLevel() : forcedLevel );
	}

	//public function canLevelUp() {
		//return xp>=GameData.getLevelUpXp(level);
	//}

	#if( neko || !connected )
	public static function makeNewHotelState(now:Float) : HotelState {
		var s : HotelState = {
			level		: 0,
			name		: GameData.DEFAULT_HOTEL_NAME,
			seed		: Std.random(999999),
			bossCd		: 0,
			uniqClientId: 0,
			lastNow		: now,
			lastRealTime: now,
			miniGameDate: now,
			miniGameCid	: -1,
			gems		: GameData.START_GEMS,
			money		: GameData.START_MONEY,
			love		: GameData.START_LOVE,
			tasks		: [],
			rooms		: [],
			clients		: [],
			inventory	: [],
			flags		: [],
			clientDeck	: [],
			cgenDeck	: [],
			//emitDeck	: [],
			stats		: [],
			customs		: [],
			curQuests	: [],
			messages	: [],
			dailyLevel	: 1,
			lastDaily	: now,
		}

		// Inventory
		function addToInv(i:Item, ?n=1) for(j in 0...n) s.inventory.push(i);
		addToInv(I_Heat, 2);
		addToInv(I_Cold, 2);
		addToInv(I_Noise, 2);
		addToInv(I_Odor, 2);
		addToInv(I_Light, 1);

		function addAndUnlock(i:Item, ?n=1) {
			for(j in 0...n)
				s.inventory.push(i);
			s.customs.push(i);
		}
		//addAndUnlock(I_Color("blue0"), 2);
		addAndUnlock(I_Texture(0), 2);
		addAndUnlock(I_Bed(0), 1);
		//addAndUnlock(I_Ceil(0), 1);
		addAndUnlock(I_Furn(0), 1);

		#if !neko
			#if !prod
			s.level = 10;
			s.money = 500000;
			s.gems = 100;
			s.love = 200;
			s.flags = ["client1","client2","elements", "bar", "barStock", "maxed", "laundry", "laundryPost", "items", "itemsPost", "vip", "custom", "custom2", "customPost",
				"paper", "questBuild", "quests", "questLoot", "questRefill", "cold", "happy35", "miniGame", "miniGamePost", "gems", "love", "inspect",
			];
			//s.flags = ["client1","client2","elements", "bar", "barStock", "maxed", "laundry", "laundryPost", "items", "itemsPost", "vip", "paper"];
			for(id in GameData.FEATURES.keys())
				if( GameData.FEATURES.get(id)<=s.level )
					s.flags.push("f_"+id);
			addToInv(I_LunchBoxAll, 2);
			#end

			//#if( prod && !connected )
			//s.level = 0;
			//s.gems = 100;
			//s.love = 100;
			////s.flags = ["client1","client2","skipClient","call","custom","elements","build","miniGame","savings","savings2","upgradeRoom","items","leave","love","askLove","superHappy","upgradeLobby","gems"];
			////for(id in GameData.FEATURES.keys()) s.flags.push("f_"+id);
			//#end

			#if trailer
			s.level = 15;
			s.money = 5000000;
			s.gems = 500;
			#end
		#end


		var h = new com.SHotel(s);

		// Rooms
		var lobby = h.addRoom(0,0, R_Lobby, 3);

		h.addRoom(0,-1, R_StockBoost);

		h.addRoom(0,1, R_Bedroom);
		h.addRoom(1,1, R_Bedroom);

		h.addRoom(0,2, R_Bedroom);
		h.addRoom(1,2, R_Bedroom);

		h.bossCd = DataTools.getBoss(h.level).requiredClients;

		// v41 hotfix: Christmas client fix (block client pop at low levels)
		h.setTimedFlag("christmasLock", DateTools.minutes(30));

		return h.getState();
	}
	#end


	public function getNextImportantTask() : Null<Task> {
		var all = tasks.filter( function(t) return switch( t.command ) {
			case InternalCompleteClient(_), InternalUnsetConstructing(_), InternalUnsetWorking(_), InternalSetFlag(_),
				InternalRoomTrigger(_), InternalClientSpecialAction(_), InternalQuestRegen, InternalClientPerk(_) : true;
				//InternalClientConsume(_) : true;
			default : false;
		} );
		if( all.length==0 )
			return null;
		else {
			var closest = all[0];
			for(t in all)
				if( t.end<closest.end )
					closest = t;
			return closest;
		}
	}


	function verifyMiniGame(rseed:mt.Rand) {
		var c = getClient(miniGameCid);
		if( miniGameCid==-1 || c==null || c.done || c.isWaiting() )
			initMiniGame(lastEvent, rseed);
	}


	function initMiniGame(now:Float, rseed:mt.Rand) {
		miniGameDate = now + DateTools.seconds( rseed.range(30,60) );

		var all = [];
		for(c in clients)
			if( !c.done && !c.isWaiting() )
				all.push(c.id);

		if( all.length==0 )
			miniGameCid = -1;
		else if( all.length==1 )
			miniGameCid = all[0];
		else {
			var rseed = new mt.Rand(Std.int(now/1000));
			miniGameCid = all[rseed.random(all.length)];
		}
	}

	public function hasMiniGame(now:Float) {
		return miniGameCid>=0 && now>=miniGameDate;
	}



	public function loadState(s:HotelState) {
		// Reset
		for(r in rooms) r.destroy();
		rooms = [];

		for(c in clients) c.destroy();
		clients = [];

		// Load
		level = s.level;
		name = s.name;
		uniqClientId = s.uniqClientId;
		seed = s.seed;
		bossCd = s.bossCd;
		lastEvent = s.lastNow;
		lastRealTime = s.lastRealTime;
		gems = s.gems;
		money = s.money;
		love = s.love;
		tasks = s.tasks.copy();
		inventory = s.inventory.copy();
		clientDeck = s.clientDeck.copy();
		cgenDeck = s.cgenDeck.copy();
		customs = s.customs.copy();
		miniGameDate = s.miniGameDate;
		miniGameCid = s.miniGameCid;
		messages = s.messages.copy();
		dailyLevel = s.dailyLevel;
		lastDaily = s.lastDaily;

		curQuests = copyQuests(s.curQuests);

		stats = new Map();
		for(s in s.stats)
			stats.set(s.k, s.v);

		flags = new Map();
		for(f in s.flags)
			setFlag(f, true);

		for(r in s.rooms)
			rooms.push( SRoom.fromState(this, r) );

		for(c in s.clients)
			clients.push( SClient.fromState(this, c) );
	}


	function copyQuests(qs:Array<QuestState>) : Array<QuestState> {
		return qs.map( function(q) {
			return {
				id		: q.id,
				ocount	: q.ocount,
				oparam	: q.oparam,
			}
		});
	}

	//inline function copyObject<T>(o:T) : T {
		//return haxe.Unserializer.run( haxe.Serializer.run(o) );
	//}

	public function getState() : HotelState {
		var tf = [];
		for(k in flags.keys())
			if( flags.get(k)==true )
				tf.push(k);

		var s = [];
		for(k in stats.keys())
			s.push({ k:k, v:getStat(k) });

		var s : HotelState = {
			seed		: seed,
			level		: level,
			name		: name,
			bossCd		: bossCd,
			uniqClientId: uniqClientId,
			lastNow		: lastEvent,
			lastRealTime: lastRealTime,
			gems		: gems,
			money		: money,
			love		: love,
			tasks		: tasks.copy(),
			rooms		: rooms.map( function(r) return r.getState() ),
			clients		: clients.map( function(c) return c.getState() ),
			inventory	: inventory.copy(),
			flags		: tf,
			clientDeck	: clientDeck.copy(),
			cgenDeck	: cgenDeck.copy(),
			//emitDeck	: emitDeck.copy(),
			stats		: s,
			customs		: customs.copy(),
			curQuests	: copyQuests(curQuests),
			miniGameDate: miniGameDate,
			miniGameCid	: miniGameCid,
			messages	: messages.copy(),
			dailyLevel	: dailyLevel,
			lastDaily	: lastDaily,
		}
		return s;
	}


	public function getSkipAllClients(now:Float) {
		return clients.filter( function(c) return !c.isWaiting() && !c.done && c.canBeSkipped(now) );
	}

	public function clone() {
		return new com.SHotel( getState() );
	}


	function addItemGoal(i:Item, ?n=1) {
		switch( i ) {
			case I_Bath(f) : addGoal("bath"+(f+1), n);
			case I_Bed(f) : addGoal("bed"+(f+1), n);
			case I_Ceil(f) : addGoal("ceil"+(f+1), n);
			case I_Furn(f) : addGoal("furn"+(f+1), n);
			case I_Wall(f) : addGoal("wall"+(f+1), n);

			default :
		}
	}


	public function addGoal(id:String, ?n=1) {
		#if( neko && !noGoals )
		Goals.increment(SolverApp.CURRENT_UINFOS, id, n);
		#end
	}


	public inline function roomUnlocked(r:RoomType) return GameData.roomUnlocked(this, level, r);

	public function featureUnlocked(id:String) {
		return flags.get("f_"+id)==true;
	}

	function startQuest(id:String, rseed:mt.Rand) {
		var data = DataTools.getQuest(id);

		if( data==null || hasQuest(data.id) )
			return;

		var q : QuestState = {
			id		: id,
			ocount	: data.ocount,
			oparam	: -1,
		}

		switch( data.objectiveId ) {
			case Data.QObjectiveKind.UseItem :
				var all = [ I_Noise, I_Cold, I_Heat, I_Odor ];
				q.oparam = all[rseed.random(all.length)].getIndex();

			case Data.QObjectiveKind.ExactHappiness:
				q.oparam = rseed.irange(12,21);

			case Data.QObjectiveKind.MinHappiness:
				q.oparam = rseed.irange(13,18);

			case Data.QObjectiveKind.HappinessColumn,
				Data.QObjectiveKind.HappinessLine :
				q.oparam = rseed.irange(13,21);

			default :
		}
		curQuests.push(q);
	}

	public function getQuestState(id:String) : Null<QuestState> {
		for(q in curQuests)
			if( q.id==id )
				return q;
		return null;
	}

	public function getDailyQuests() {
		return curQuests.filter( function(q) {
			return DataTools.isDaily(q.id);
		});
	}

	public function countDailyQuests() {
		var n = 0;
		for(q in curQuests)
			if( DataTools.isDaily(q.id) )
				n++;
		return n;
	}

	public function countPuzzleFriendly() {
		var n = 0;
		for(q in curQuests)
			if( DataTools.getQuest(q.id).puzzleFriendly )
				n++;
		return n;
	}

	public function hasQuest(id:Data.QuestKind) {
		for(q in curQuests)
			if( q.id==id.toString() )
				return true;
		return false;
	}

	public function hasQuestObjective(o:Data.QObjectiveKind) {
		var oid : String = o.toString();
		for(q in curQuests) {
			var q = DataTools.getQuest(q.id);
			if( q.objectiveId.toString()==oid )
				return true;
		}
		return false;
	}

	public function hasDoneQuestOnce(id:Data.QuestKind) {
		return flags.get( "q_"+id.toString() )==true;
	}


	public function getMaxDailyQuests() {
		return GameData.BASE_DAILY_QUESTS + countRooms(R_Library);
	}


	public function getMaxHappiness() {
		return
			featureUnlocked("happy50") ? 50 :
			featureUnlocked("happy45") ? 45 :
			featureUnlocked("happy40") ? 40 :
			featureUnlocked("happy35") ? 35 :
			30;
	}

	public function getMaxLove() {
		return if( hasPremiumUpgrade(Data.PremiumKind.MaxLove2) ) GameData.MAX_LOVE_2;
			else if( hasPremiumUpgrade(Data.PremiumKind.MaxLove1) ) GameData.MAX_LOVE_1;
			else GameData.MAX_LOVE_0;
	}


	public function getLovePower() {
		return
			GameData.LOVE_POWER_BASE +
			(hasPremiumUpgrade(Data.PremiumKind.PowerOfLove1) ? 1 : 0) +
			(hasPremiumUpgrade(Data.PremiumKind.PowerOfLove2) ? 1 : 0) +
			(hasPremiumUpgrade(Data.PremiumKind.PowerOfLove3) ? 1 : 0);
	}



	public function getMaxClientPayment(t:ClientType) : Int {
		var bonus = 0;
		if( featureUnlocked("happy35") ) bonus += 250;
		if( featureUnlocked("happy40") ) bonus += 250;
		if( featureUnlocked("happy45") ) bonus += 250;
		if( featureUnlocked("happy50") ) bonus += 250;
		return bonus + switch( t ) {
			case C_Liker : 350;
			case C_Neighbour : 750;
			default : 1000;
		}
	}


	public function getClientPayment(c:SClient) {
		var h = c.getClampedHappiness();
		var f = h / getMaxHappiness();

		var m = Math.pow(f,1.5) * getMaxClientPayment(c.type);
		return MLib.round(m/10)*10; // prettify
	}


	function getLobby() {
		for(r in rooms)
			if( r.type==R_Lobby )
				return r;
		return null;
	}

	function appendToDeck(t:ClientType, ?n=1) {
		for(i in 0...n)
			clientDeck.push(t);
	}

	function pickClientDeck(rseed:mt.Rand) {
		if( clientDeck.length==0 ) {
			function addIfUnlocked(t:ClientType, n:Int) {
				if( GameData.clientUnlocked(level, t) )
					appendToDeck(t,n);
			}

			addIfUnlocked( C_Neighbour, 3 );
			addIfUnlocked( C_Disliker, 2 );
			addIfUnlocked( C_Gifter, 3 );
			addIfUnlocked( C_MobSpawner, 2 );
			addIfUnlocked( C_Vampire, 3 );
			addIfUnlocked( C_Bomb, 3 );
			addIfUnlocked( C_Repairer, 2 );
			addIfUnlocked( C_Plant, 2 );
			addIfUnlocked( C_HappyLine, GameData.clientUnlocked(level, C_HappyColumn) ? 2 : 3 );
			addIfUnlocked( C_HappyColumn, GameData.clientUnlocked(level, C_HappyLine) ? 2 : 3 );
			addIfUnlocked( C_Rich, 3 );
			addIfUnlocked( C_JoyBomb, 1 );
			addIfUnlocked( C_Dragon, 2 );
			addIfUnlocked( C_Emitter, 2 );
			addIfUnlocked( C_MoneyGiver, 2 );
			addIfUnlocked( C_Liker, MLib.max(5, MLib.round(clientDeck.length*0.3)) );

			clientDeck = mt.deepnight.Lib.shuffle(clientDeck, rseed.random);
		}
		return clientDeck.shift();
	}

	public function pickClientGenDeck(rseed:mt.Rand) {
		if( cgenDeck.length==0 ) {
			function _add(g:ClientGeneration, n:Int) {
				for(i in 0...n)
					cgenDeck.push(g);
			}
			if( level<=2 ) {
				_add(G_EasyNotDouble, 4);
				_add(G_Double, 2);
			}
			else if( level<=4 ) {
				_add(G_EasyNotDouble, 4);
				_add(G_Double, 2);
				_add(G_LikeLight, 1);
			}
			else if( level<=6 ) {
				_add(G_EasyNotDouble, 5);
				_add(G_Double, 3);
				_add(G_LikeLight, 1);
				_add(G_DislikerEasy, 1);
			}
			else if( level<=12 ) {
				_add(G_EasyNotDouble, 6);
				_add(G_Double, 3);
				_add(G_LikeLight, 2);
				_add(G_DislikerEasy, 1);
				_add(G_DislikerHard, 1);
			}
			else {
				_add(G_EasyNotDouble, 9);
				_add(G_Double, 3);
				_add(G_LikeLight, 1);
				_add(G_LikeLightHard, 1);
				_add(G_DislikerEasy, 2);
				_add(G_DislikerHard, 1);
				_add(G_DislikerDouble, 1);
			}

			cgenDeck = mt.deepnight.Lib.shuffle(cgenDeck, rseed.random);
		}
		return cgenDeck.shift();
	}

	//public function pickEmitDeck(rseed:mt.Rand) {
		//if( emitDeck.length==0 ) {
			//var all = [Heat, Cold, Noise, Odor];
			//for(a in all)
				//for( i in 0...1 )
					//emitDeck.push(a);
//
			//emitDeck.push( all[rseed.random(all.length)] );
			//emitDeck = mt.deepnight.Lib.shuffle(emitDeck, rseed.random);
		//}
		//return emitDeck.shift();
	//}

	public function generateWaitingClient(t:ClientType, vip:Bool) {
		#if !prod
		//t = C_Emitter;
		#end

		var c = new SClient(this, uniqClientId);
		c.generateGameplayValues(t, vip);
		c.initNonGameplayValues();
		c.room = getLobby();
		clients.push(c);
		#if dprot
		//Game.ME.netLog(Std.string(c), 0x00FFFF);
		#end

		uniqClientId++;
		return c;
	}


	public function canHaveDailyQuests() return hasFlag("dailies");
	public function isPrepared() return level>0 || hasFlag("prepare");

	function setFlag(id:String, ?v=true) {
		if( v )
			flags.set(id,true);
		else
			flags.remove(id);
	}
	public function hasFlag(id:String) return flags.exists(id);
	public function hasDoneTutorial(id:String) return flags.exists(id);

	public function hasDoneEvent(eid:Data.EventKind) {
		return hasFlag("event_"+eid.toString());
	}

	public function hasPremiumUpgrade(?eid:Data.PremiumKind, ?estr:String) {
		return hasFlag("u_"+ (eid!=null ? eid.toString() : estr));
	}


	public function setTimedFlag(id:String, duration:Float) {
		setFlag(id,true);
		addTask( InternalSetFlag(id, false), lastEvent + duration );
	}

	public function hasClient(t:ClientType) {
		for(c in clients)
			if( c.type==t )
				return true;
		return false;
	}

	public function playedRecently(now:Float) {
		return lastEvent <= now+DateTools.days(7);
	}

	public function countWaitingClients() {
		var n = 0;
		for(c in clients)
			if( c.isWaiting() )
				n++;
		return n;
	}

	public function getWaitingClients() {
		return clients.filter( function(c) return c.isWaiting() );
	}

	public function canGetLoveFromHotel(hid:Int) {
		return !hasFlag("love_"+hid);
	}

	public function getVisitLoveBonus() : Int {
		return if( hasPremiumUpgrade(Data.PremiumKind.GetLove2) ) GameData.VISIT_LOVE_2;
			else if( hasPremiumUpgrade(Data.PremiumKind.GetLove1) ) GameData.VISIT_LOVE_1;
			else 0;
	}

	public function countClientsInRooms() {
		var n = 0;
		for(c in clients)
			if( !c.isWaiting() )
				n++;
		return n;
	}

	public inline function getLatestClient() return clients[clients.length-1];

	public function waitingLineIsFull() {
		return countWaitingClients() >= getQueueLength();
	}

	public function getClient(cid:Int) {
		for( c in clients )
			if( c.id==cid )
				return c;
		return null;
	}


	public function destroy() {
		for( r in rooms )
			r.destroy();
		rooms = null;

		for( c in clients )
			c.destroy();
		clients = null;
	}


	public inline function coordToId(x:Int, y:Int) return (x+Std.int(WORLD_WID*0.5)) + (y+Std.int(WORLD_HEI*0.5))*WORLD_WID;
	public inline function isValidCoord(x:Int, y:Int) return x>=-WORLD_WID*0.5 && x<WORLD_WID*0.5 && y>=-WORLD_HEI*0.5 && y<WORLD_HEI*0.5;


	public function addToInventory(it:Item, ?n=1) {
		for( i in 0...n )
			inventory.push(it);
	}

	public function removeFromInventory(it:Item, ?n=1) {
		var j = 0;
		while( j<inventory.length ) {
			if( inventory[j].equals(it) ) {
				inventory.splice(j,1);
				if( --n<=0 )
					return;
			}
			else
				j++;
		}
	}

	public function hasInventoryItem(i:Item) {
		for( i2 in inventory )
			if( i2.equals(i) )
				return true;
		return false;
	}

	public function countInventoryItem(i:Item) {
		var n = 0;
		for( i2 in inventory )
			if( i2.equals(i) )
				n++;
		return n;
	}

	public function getStackedInventory() : Map<Item,Int> {
		var map = new Map();
		for(i in inventory)
			if( !map.exists(i) )
				map.set(i, 1);
			else
				map.set(i, map.get(i)+1);
		return map;
	}


	public function addRoom(x,y, t:RoomType, ?wid=1) : SRoom {
		if( !isValidCoord(x,y) )
			throw 'Invalid coordinate $x,$y';

		if( hasRoom(x,y) )
			throw 'Already has a room $x,$y';

		var r = new com.SRoom(this, x,y, t);
		r.wid = wid;
		switch( t ) {
			case R_StockPaper, R_StockSoap, R_StockBeer, R_StockBoost:
				r.data = GameData.getStockMax(t, r.level);

			default :
		}
		rooms.push(r);
		return r;
	}


	public function getMaxRoomCount(t:RoomType) {
		return switch( t ) {
			case R_Bedroom : 40;
			default : 15;
		}
	}


	public function getBestUtilityRoom(t:RoomType) : Null<SRoom> {
		// Find a free room
		var avail = rooms.filter(function(r) {
			return r.type==t && !r.working && !r.constructing && !r.isDamaged();
		});
		if( avail.length>0 )
			return avail[0];

		// Find a room currenlty working
		var working = rooms.filter( function(r) return r.type==t && r.working && !r.constructing && !r.isDamaged() );
		if( working.length>0 ) {
			working.sort( function(a,b)
				return -Reflect.compare( getWorkCompleteTask(a.cx,a.cy).end, getWorkCompleteTask(b.cx,b.cy).end )
			);
			return working[0];
		}

		return null;
	}


	public function addTask(c:GameCommand, end:Float) {
		tasks.push({ command:c, start:lastEvent, end:end });
		haxe.ds.ArraySort.sort( tasks, function(a,b) {
			return Reflect.compare(a.end, b.end);
		});
	}

	public function hasTask(c:GameCommand) return getTask(c)!=null; // TODO alloc

	public function getTask(c:GameCommand) : Null<Task> {
		for( t in tasks )
			if( Type.enumIndex(t.command)==Type.enumIndex(c) && Type.enumEq(t.command, c) )
				return t;
		return null;
	}

	public function getClientCompleteTask(cid:Int) : Null<Task> {
		for(t in tasks)
			switch( t.command ) {
				case InternalCompleteClient(id) :
					if( id==cid )
						return t;

				default :
			}

		return null;
	}

	public function getWorkCompleteTask(rx:Int, ry:Int) : Null<Task> {
		for(t in tasks)
			switch( t.command ) {
				case InternalUnsetWorking(x,y) :
					if( x==rx && y==ry  )
						return t;

				default :
			}

		return null;
	}

	function terminateTask(c:GameCommand) {
		var t = getTask(c);
		if( t!=null ) {
			t.end = lastEvent;
			return true;
		}
		else
			return false;
	}

	public function getRoomTasks(rx,ry) : Array<Task> {
		return tasks.filter( function(t) {
			switch( t.command ) {
				case DoCreateRoom(x,y,_), DoDestroyRoom(x,y), InternalUnsetConstructing(x,y), InternalUnsetWorking(x,y), InternalRoomTrigger(x,y) :
					return x==rx && y==ry;

				default :
					return false;
			}
		});
	}

	public function getRoomFirstTask(rx,ry) : Null<Task> {
		for(t in tasks)
			switch( t.command ) {
				case DoCreateRoom(x,y,_), DoDestroyRoom(x,y), InternalUnsetConstructing(x,y), InternalUnsetWorking(x,y), InternalRoomTrigger(x,y) :
					if( x==rx && y==ry )
						return t;

				default :
			}
		return null;
	}

	public function removeTask(c:GameCommand) {
		var i = 0;
		while( i<tasks.length )
			if( tasks[i].command.equals(c) )
				tasks.splice(i,1);
			else
				i++;
	}

	public function hasEvent(eid:Data.EventKind) {
		return DataTools.hasEvent(eid, lastEvent, false);
	}

	public function getCurrentEvent() : Null<Data.Event> {
		for(e in Data.Event.all)
			if( hasEvent(e.id) )
				return e;

		return null;
	}


	public function removeRoom(x,y) {
		if( !isValidCoord(x,y) )
			throw "Invalid coordinate";

		if( !hasRoom(x,y) )
			throw "Already has a room";

		var r = getRoom(x,y);
		r.destroy();
		rooms.remove(r);
	}


	#if debug
	public function addAndUnlockCustom(i:Item, n:Int) {
		unlockCustom(i);
		if( n>0 )
			addToInventory(i,n);
	}
	#end


	public function unlockCustom(i:Item) {
		if( !GameData.isCustomizeItem(i) )
			return false;

		if( !customUnlocked(i) ) {
			switch( i ) {
				case I_Color(id) :
					if( DataTools.getWallColor(id)==null )
						throw "Unknown wall color "+id;

				case I_Texture(f) :
					if( DataTools.getWallTexture(f)==null )
						throw "Unknown wall texture "+f;

				default :
			}
			customs.push(i);
			return true;
		}
		else
			return false;
	}

	public function customUnlocked(i:Item) {
		for(c in customs)
			if( c.equals(i) )
				return true;
		return false;
	}


	public function canBuildHere(cx,cy) : Bool {
		return !hasRoom(cx,cy) && (hasRoom(cx-1,cy) || hasRoom(cx+1,cy) || hasRoom(cx,cy-1) || hasRoom(cx,cy+1));
	}


	public function getNeighbours(c:SClient, ?type:ClientType) : Array<SClient> {
		var all = [];
		for(r in getNeighbourRooms(c.room))
			if( r.type==R_Bedroom && r.hasClient() && !r.getClient().done )
				if( type==null || r.getClient().type==type )
					all.push( r.getClient() );
		return all;
	}


	public inline function getNeighbourRooms(r:SRoom) {
		return getNeighbourRoomsCoords(r.cx, r.cy, r.wid);
	}

	public function getNeighbourRoomsCoords(cx:Int, cy:Int, rwid:Int) {
		var neig = [];

		var r = getRoom(cx-1, cy);
		if( r!=null ) neig.push(r);

		var r = getRoom(cx+rwid, cy);
		if( r!=null ) neig.push(r);

		for(x in cx...cx+rwid) {
			var r = getRoom(x, cy-1);
			if( r!=null ) neig.push(r);

			var r = getRoom(x, cy+1);
			if( r!=null ) neig.push(r);
		}

		return neig;
	}

	public function checkConsistency(withoutX:Int, withoutY:Int) : Bool {
		// Flood-fill mark every rooms touching the Lobby
		var marks = new Map();
		var l = getRoomsByType(R_Lobby)[0];
		marks.set(coordToId(l.cx,l.cy), true);

		var open = getNeighbourRooms(l);
		while( open.length>0 ) {
			var r = open.pop();
			var id = coordToId(r.cx,r.cy);
			if( marks.exists(id) || r.cx==withoutX && r.cy==withoutY )
				continue;

			marks.set(id, true);

			for(nr in getNeighbourRooms(r))
				if( !marks.exists(coordToId(nr.cx,nr.cy)) )
					open.push(nr);
		}

		// Check
		for(r in rooms)
			if( ( r.cx!=withoutX || r.cy!=withoutY ) && !marks.exists(coordToId(r.cx, r.cy)) )
				return false;

		return true;
	}

	public function canBuildRoom(t:RoomType) : Bool {
		return roomUnlocked(t) && GameData.getRoomCost(t, countRooms(t))>=0;
	}

	public function countStock(t:RoomType) {
		var n = 0;
		for(r in rooms)
			if( r.type==t && !r.constructing && !r.working && !r.isDamaged() )
				n+=r.data;
		return n;
	}

	public function hasRoom(x,y, ?t:RoomType) {
		for( r in rooms )
			if( y==r.cy && x>=r.cx && x<r.cx+r.wid )
				if( t==null )
					return true;
				else
					return r.type==t;
		return false;
	}

	public function hasRoomExceptFiller(x,y) {
		for( r in rooms )
			if( y==r.cy && x>=r.cx && x<r.cx+r.wid && !r.isFiller() )
				return true;
		return false;
	}

	public function hasRoomType(t:RoomType, ?inclConstructing=false) {
		for(r in rooms)
			if( r.type==t && ( inclConstructing || !r.constructing ) )
				return true;
		return false;
	}

	public inline function getRoomsByType(t:RoomType) : Array<SRoom> {
		return rooms.filter( function(r) return r.type==t );
	}

	public function getRoomByType(t:RoomType) : Null<SRoom> {
		for(r in rooms)
			if( r.type==t )
				return r;
		return null;
	}

	public inline function countRooms(t:RoomType, ?inclConstructing=true) : Int {
		var n = 0;
		for(r in rooms)
			if( r.type==t && ( inclConstructing || !r.constructing ) )
				n++;
		return n;
	}

	public function getAvailableRoom(t:RoomType) {
		for(r in rooms)
			if( r.type==t && !r.working && !r.constructing )
				return r;
		return null;
	}

	public function getRoom(x,y) : Null<SRoom> {
		for( r in rooms )
			if( x>=r.cx && x<r.cx+r.wid && y==r.cy )
				return r;
		return null;
	}

	public function addStat(k:String, ?v=1) {
		stats.set( k, getStat(k)+v );
	}

	public function clearStat(k:String) {
		stats.remove(k);
	}

	public function decStat(k:String) {
		var v = getStat(k);
		if( v==1 )
			clearStat(k);
		else if( v>1 )
			stats.set(k, stats.get(k)-1);
	}

	public function getStat(k:String) {
		return stats.exists(k) ? stats.get(k) : 0;
	}

	public inline function countHostedClients() return getStat("client");


	public function mergeItemStacks(r:SRoom, item:Item) {
		var total = 0;
		for(i in r.gifts)
			if( Type.enumIndex(i)==Type.enumIndex(item) )
				switch( i ) {
					case I_Money(n) : total+=n;
					default : throw "cannot merge "+i;
				}

		if( total>0 ) {
			r.gifts = r.gifts.filter( function(i) return Type.enumIndex(i)!=Type.enumIndex(item) );
			r.gifts.push( Type.createEnumIndex(Item, item.getIndex(), [total]) );
		}
	}

	public function inspectorReady() {
		return bossCd<=0 && !hasFlag("bossLock");
	}

	public function applyEffect(e:GameEffect, ?isPlayback=false) {
		var rseed = new mt.Rand( Std.int(seed+lastEvent/1000) );
		switch( e ) {
			case Ok(_) :

			case ShowRating :
				setTimedFlag("loginEvent", GameData.LOGIN_EVENT_CD);

			case ShowFriendRequest(_) :
				setTimedFlag("friendReq", rseed.range(GameData.FRIEND_REQUEST_DELAY_MIN, GameData.FRIEND_REQUEST_DELAY_MAX) );
				setTimedFlag("loginEvent", GameData.LOGIN_EVENT_CD);

			case Rated(later) :
				if( later )
					setTimedFlag("rateLater", DateTools.hours(20));
				else
					setFlag("rated", true);

			case Cheated(cc) :
				switch( cc ) {
					case CC_AddDay(n) :
						lastDaily-=DateTools.days(n);

					default :
				}

			case Print(_) :

			case PremiumBought(id) :
				setFlag("u_"+id, true);

			case PremiumOnRoom(_) :

			case SyncLastEventTime(t) :
				lastEvent = t;

			case QueueAutoRefilled :

			case AddStat(k,v) :
				addStat(k,v);

			case BossResult(_), BossArrived, BossDied :

			case SpecialRewardReceived(_) :

			case EventRewardReceived(id) :
				setTimedFlag("event_"+id, DateTools.days(60));

			case BossCooldownDec :
				if( bossCd>0 && featureUnlocked("inspect") )
					bossCd--;

			case BossCooldownReset(newLevel) :
				var data = DataTools.getBoss(level);
				if( newLevel ) {
					bossCd = data.requiredClients;
					setTimedFlag("bossLock", DateTools.hours(data.minDelayHours));
				}
				else {
					if( data.minDelayHours>=0.5 ) {
						bossCd = MLib.ceil(data.requiredClients*0.3);
						setTimedFlag("bossLock", DateTools.hours(data.minDelayHours*0.2));
					}
					else
						bossCd = 10;
				}

			case RoomBoosted(_) :
				addStat("boost");

			case MessageDiscarded(m) :
				for( e in messages )
					if( e.equals(m) ) {
						messages.remove(e);
						break;
					}


			case LunchBoxOpened(_) :

			case EventGiftOpened(_) :

			case FeatureUnlocked(_) :

			//case QuestUpdated(q) :
				//for(q2 in quests)
					//if( q2.id==q.id )
						//quests.remove(q2);
				//quests.push(q);

			case HotelFlagSet(k,v) :
				setFlag(k,v);

			case LongAbsence :
				lastDaily = lastEvent;
				dailyLevel = 1;
				setTimedFlag("loginEvent", GameData.LOGIN_EVENT_CD);
				//for( r in rooms )
					//r.damages = 0;

			case NewDay :
				setTimedFlag("loginEvent", GameData.LOGIN_EVENT_CD);

			case DailyLevelProgress(ok) :
				lastDaily = lastEvent;
				if( ok ) {
					dailyLevel++;
					if( dailyLevel>Data.DailyReward.all.length )
						dailyLevel = 1;
				}
				else
					dailyLevel = 1;

			case TrackMoneyEvent(id,v,details) :
				#if( connected && !neko )
				if( !isPlayback )
					mt.device.EventTracker.creditSpent(id, v, details);
				#end

			case TrackGameplayEvent(cat,sub) :
				#if( connected && !neko )
				if( !isPlayback )
					mt.device.EventTracker.track(cat, sub);
				#end

			case CreateRoom(x,y, t) :
				addRoom(x,y, t);

			//case SuiteCreated(x,y, dir) :
				//var r = getRoom(x,y);
				//r.wid = 2;
				//if( dir==-1 )
					//r.cx--;


			case TutorialCompleted(id) :
				setFlag(id, true);
				switch( id ) {
					case "elements" :
						for(c in clients)
							if( !c.done && !c.isWaiting() ) {
								c.stayDuration = DateTools.seconds(15);
								var t = getClientCompleteTask(c.id);
								t.start = lastEvent;
								t.end = lastEvent + c.stayDuration;
							}
				}


			case LevelUp :
				level++;
				addStat("lvl");
				addGoal("level");
				#if connected
				mt.device.User.syncGoals();
				#end

			case RoomUpgraded(x,y) :
				getRoom(x,y).level++;

			case DestroyRoom(x,y) :
				var r = getRoom(x,y);
				for(t in getRoomTasks(x,y))
					tasks.remove(t);
				removeRoom(x,y);

			case RoomSwitched(x,y,t) :
				var r = getRoom(x,y);
				r.type = t;
				r.data = 0;

			case RoomRepairStarted(_) :

			case RoomRepaired(x,y, d) :
				var r = getRoom(x,y);
				r.damages-=d;
				if( r.damages<0 )
					r.damages = 0;

			case RoomDamaged(x,y,d, _) :
				var r = getRoom(x,y);
				r.damages+=d;
				if( r.damages>2 )
					r.damages = 2;

			case RegenClientDeck :
				clientDeck = [];

			case MiniGame(cid, m, l) :
				addStat("theft");
				if( l>=2 )
					addStat("treas");

			case ClientWokeUp(cid) :
				initMiniGame(lastEvent, rseed);

			case ClientLoved(_) :

			case ClientSpecial(_) :

			case ClientPerk(_) :

			case ClientMaxHappiness(cid) :
				addStat("maxed");
				var c = getClient(cid);
				if( c.isVip() )
					addStat("vip");

			case ClientFlagSet(cid,k) :
				var c = getClient(cid);
				if( k.indexOf("hand_")==0 ) {
					var rem = [];
					for(k in c.flags.keys())
						if( k.indexOf("hand_")==0 )
							rem.push(k);
					for(k in rem)
						c.flags.remove(k);
				}
				c.setFlag(k);

			case RemoveClientSaving(cid, n) :
				var c = getClient(cid);
				c.money = MLib.max(0, c.money-n);

			case AddClientSaving(cid, n) :
				var c = getClient(cid);
				c.money += MLib.iabs(n);

			case RoomActivated(x,y) :
				var r = getRoom(x,y);
				switch( r.type ) {
					case R_Lobby :
						addStat("call");

					case R_StockBoost :
						addStat("brefill");

					case R_LevelUp:
						addStat("inspect");

					default :
				}


			case AddLove(n) :
				love = MLib.min( getMaxLove(), love+n );
				addStat("lincome",n);

			case RemoveLoveFromRoom(_,_, n) :
				love = MLib.max( 0, love-n );
				addStat("love",n);

			case ItemUsedOnRoom(x,y,i) :
				var r = getRoom(x,y);
				switch( i ) {
					case I_Color(id) : r.custom.color = id;
					case I_Texture(f) : r.custom.texture = f;

					case I_Bath(f) : r.custom.bath = f;
					case I_Bed(f) : r.custom.bed = f;
					case I_Ceil(f) : r.custom.ceil = f;
					case I_Furn(f) : r.custom.furn = f;
					case I_Wall(f) : r.custom.wall= f;

					case I_Heat, I_Cold, I_Odor, I_Noise, I_Light :
					case I_Money(_), I_Gem :
					case I_LunchBoxAll, I_LunchBoxCusto :
					case I_EventGift(_) :
				}

			case CustoUnlocked(i) :
				if( unlockCustom(i) ) {
					addGoal("custo"); // ATTENTION: en cas de reset, tout est recompté en double
					addItemGoal(i);
				}

			case CustomizationCleared(x,y,i) :
				var r = getRoom(x,y);
				if( i==null ) {
					r.custom.bath = -1;
					r.custom.bed = -1;
					r.custom.ceil = -1;
					r.custom.color = "raw";
					r.custom.furn = -1;
					r.custom.texture = -1;
					r.custom.wall = -1;
				}
				else
					switch( i ) {
						case I_Bath(_) : r.custom.bath = -1;
						case I_Bed(_) : r.custom.bed = -1;
						case I_Ceil(_) : r.custom.ceil = -1;
						case I_Color(_) : r.custom.color = "raw";
						case I_Furn(_) : r.custom.furn = -1;
						case I_Texture(_) : r.custom.texture = -1;
						case I_Wall(_) : r.custom.wall = -1;
						default :
					}

			case AddGems(n, _) :
				gems+=n;
				addStat("gincome",n);

			case RemoveGem(n), RemoveGemFromRoom(_,_,n) :
				gems-=n;
				addStat("gem",n);

			case RoomWorkSkipped(x,y) :
				addStat("wskip");

			case RoomConstructionSkipped(x,y) :
				addStat("bskip");
				//if( !terminateTask( InternalUnsetConstructing(x,y) ) ) {
					//if( terminateTask( InternalUnsetWorking(x,y) ) ) {
						//var r = getRoom(x,y);
						//switch( r.type ) {
							//case R_Bedroom :
								//terminateTask( InternalRoomRepair(x,y) );
//
							//default :
						//}
					//}
				//}


			case ClientSkipped(cid) :
				addStat("cskip");
				var c = getClient(cid);
				var h = c.getHappiness();
				var d = getMaxHappiness()-h;
				if( d>0 )
					getClient(cid).addHappinessAffect(d, HM_Gem);

			case ClientDone(cid) :
				getClient(cid).done = true;

			case CheckMiniGame :
				verifyMiniGame(rseed);


			case ClientAffectsChange(cid, l,d,a) :
				var c = getClient(cid);
				c.likes = l.copy();
				c.dislikes = d.copy();
				c.emit = a;


			case ClientArrived(t) :
				if( t==null ) {

					//if( hasEvent(Data.EventKind.Halloween) && !hasFlag("halloweenLock") ) {
						//// Halloween client
						//setTimedFlag("halloweenLock", GameData.HALLOWEEN_CLIENT_DELAY);
						//generateWaitingClient(C_Halloween, false);
					//}
					if( level>=GameData.getFeatureUnlockLevel("inbox") && hasEvent(Data.EventKind.ChristmasPeriod) && !hasFlag("christmasLock") ) {
						// Christmas client
						setTimedFlag("christmasLock", GameData.CHRISTMAS_CLIENT_DELAY);
						generateWaitingClient(C_Christmas, false);
					}
					else if( GameData.clientUnlocked(level, C_Gem) && !hasFlag("gemLock") ) {
						// Force gem client
						setTimedFlag("gemLock", GameData.GEM_CLIENT_DELAY);
						generateWaitingClient(C_Gem, false);
					}
					else if( featureUnlocked("vip") && getStat("vipLock")<=0 && !hasFlag("vipCd") ) {
						// VIPs generation
						var t = pickClientDeck(rseed);
						if( t!=C_Bomb ) {
							addStat( "vipLock", MLib.round(GameData.VIP_CLIENTS_CD * rseed.range(1,1.25)) );
							setTimedFlag("vipCd", GameData.getVipCooldown(this) * rseed.range(0.9, 1.1));
							generateWaitingClient( t, true );
						}
						else
							generateWaitingClient( t, false );
					}
					else if( uniqClientId<=3 ) {
						// Starting clients
						generateWaitingClient( C_Liker, false );
					}
					else {
						// Normal (random client)
						generateWaitingClient( pickClientDeck(rseed), false );
					}
				}
				else
					generateWaitingClient(t, false);


			case ForcedVipArrived :
				var t = pickClientDeck(rseed);
				while( t==C_Bomb )
					t = pickClientDeck(rseed);
				generateWaitingClient( t, true );


			case ClientBuilt(x,y, l,d,e) :
				var c = generateWaitingClient(C_Custom, false);
				if( l!=null )
					c.likes = l.copy();

				if( d!=null )
					c.dislikes = d.copy();

				if( e!=null )
					c.emit = e;

			case ClientInstalled(cid, x,y) :
				var c = getClient(cid);
				c.room = getRoom(x,y);
				addStat("install");

			case ClientSentToUtilityRoom(cid,x,y) :
				var r = getRoom(x,y);
				switch( r.type ) {
					case R_Bar : addStat("beer");
					default :
				}

			case ClientValidated(cid,h) :
				addStat("client");
				decStat("vipLock");

			case ClientLeft(cid) :
				var c = getClient(cid);
				c.destroy();
				clients.remove(c);
				removeTask( InternalClientPerk(cid) );
				removeTask( InternalClientSpecialAction(cid) );
				removeTask( InternalCompleteClient(cid) );

			case ClientDied(cid) :
				var c = getClient(cid);
				c.destroy();
				clients.remove(c);
				removeTask( InternalClientPerk(cid) );
				removeTask( InternalClientSpecialAction(cid) );
				removeTask( InternalCompleteClient(cid) );
				addStat("kill");

			case StartTask(c, duration) :
				addTask(c, lastEvent+duration);

			case RemoveTask(c) :
				removeTask(c);

			case HappinessModCapped(_) :

			case HappinessModRemoved(cid,t) :
				var c = getClient(cid);
				c.happinessMods = c.happinessMods.filter( function(m) {
					return !m.type.equals(t);
				});

			case HappinessPermanentAffect(cid,v,t, notif) :
				var c = getClient(cid);
				c.addHappinessAffect(v,t);

			case HappinessChanged(_) :

			case AddGift(cx,cy,i) :
				var r = getRoom(cx,cy);
				r.gifts.push(i);

				mergeItemStacks( r, I_Money(0) );

			case GiftPickedUp(cx,cy, i) :
				getRoom(cx,cy).gifts.remove(i);

			case AddItem(i, n), AddItemFromRoom(_,_,i,n) :
				switch( i ) {
					case I_Gem :
						gems+=n;

					default :
						addToInventory(i, n);
				}

			case RemoveItem(i) :
				removeFromInventory(i);

			case AddMoney(v), AddMoneyFromClient(_,v,_), AddMoneyFromRoom(_,_,v,_) :
				money+=v;
				addStat("income",v);

			case RemoveMoney(v), RemoveMoneyFromRoom(_,_,v) :
				money-=v;
				addStat("gold",v);
				addGoal("gold",v);

			//case AddSlimeFromRoom(x,y,v) :
				//slime+=v;
//
			//case RemoveSlime(v) :
				//slime-=v;
//
			//case RemoveSlimeFromRoom(x,y,v) :
				//slime-=v;

			case SetConstructing(x,y,v) :
				getRoom(x,y).constructing = v;

			case SetWorking(x,y,v) :
				getRoom(x,y).working = v;

			case ServiceDone(cid,x,y, t) :
				var c = getClient(cid);
				c.initService(rseed, false);

				switch( t ) {
					case R_Laundry : addStat("laundry");
					case R_StockPaper : addStat("paper");
					case R_StockSoap : addStat("soap");
					default :
				}

			case ServiceForced(cid,t) :
				getClient(cid).forceService(t);

			case StockAutoRefilled(_) :

			case StockAdded(x,y,n) :
				getRoom(x,y).data += n;

			case StockMovedTo(x,y,_,_), StockRemoved(x,y) :
				getRoom(x,y).data--;


			case QuestBought :

			case QuestStarted(id) :
				startQuest(id, rseed);

			case QuestCancelled(id) :
				for(q in curQuests)
					if( q.id==id ) {
						curQuests.remove(q);
						break;
					}

			case QuestAdvanced(id,n) :
				for(q in curQuests)
					if( q.id==id )
						q.ocount = MLib.max(0, q.ocount-n);

			case QuestDone(id, _) :
				setFlag("q_"+id, true);
				for(q in curQuests)
					if( q.id==id ) {
						curQuests.remove(q);
						break;
					}

			//case AllDailyQuestsComplete :
		}
	}

}
