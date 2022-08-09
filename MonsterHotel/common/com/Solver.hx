package com;

import com.Protocol;
import mt.MLib;
import mt.RandList;
import Data;

#if (neko && !solver_server)
	#error "Do not include com.SHotel in main index.n!"
#end

class Solver {
	public static var TICK_MS = 1000;

	var hotel				: SHotel;
	var rseed				: mt.Rand;

	public var lastError	: Null<SolverError>;
	var lastEffects			: Array<GameEffect>;
	//var clientCompleteGem	: Bool;
	var realTime			: Float;

	public function new(s:HotelState, realTime:Float) {
		this.realTime = realTime;
		lastEffects = [];
		lastError = null;
		hotel = new com.SHotel(s);
		rseed = new mt.Rand(0);

		advanceToRealTime();
	}

	public static function patchState(fromVersion:Int, ?toVersion:Int, state:HotelState) {
		if( toVersion==null )
			toVersion = com.Protocol.DATA_VERSION;

		while( fromVersion<toVersion ) {
			#if( debug && flash )
			trace("PatchState "+fromVersion+" => "+(fromVersion+1));
			#end

			#if( neko && !noGoals )
			function _addGoal(id, ?n=1) {
				Goals.increment(SolverApp.CURRENT_UINFOS, id, n);
			}
			#end

			switch( fromVersion ) {
				case 38 :
					Reflect.deleteField(state, "whale");

				case 39 :
					state.dailyLevel = 1;

				case 40 :
					#if( neko && !noGoals )
					for(i in state.customs)
						switch( i ) {
							case I_Bath(f) : _addGoal("bath"+(f+1));
							case I_Bed(f) : _addGoal("bed"+(f+1));
							case I_Ceil(f) : _addGoal("ceil"+(f+1));
							case I_Furn(f) : _addGoal("furn"+(f+1));
							case I_Wall(f) : _addGoal("wall"+(f+1));
							default :
						}
					#end
					state.lastDaily = state.lastRealTime;

				case 41 :
					if( state.level >= 11 && state.flags.indexOf("f_quests") < 0 )
						state.flags.push("f_quests");

					#if( neko && !noGoals )
					for(i in state.customs) // rebelote...
						switch( i ) {
							case I_Bath(f) : _addGoal("bath"+(f+1));
							case I_Bed(f) : _addGoal("bed"+(f+1));
							case I_Ceil(f) : _addGoal("ceil"+(f+1));
							case I_Furn(f) : _addGoal("furn"+(f+1));
							case I_Wall(f) : _addGoal("wall"+(f+1));
							default :
						}
					_addGoal("level", state.level);
					#end

					// Fix booster room stock with premium upgrades
					for(r in state.rooms)
						if( r.type==R_StockBoost )
							r.data = GameData.getStockMax(r.type, r.level);

				default :
			}
			fromVersion++;
		}
	}

	function initRandom() {
		rseed.initSeed( Std.int(hotel.seed + hotel.lastEvent/1000));
	}

	public function destroy() {
		hotel.destroy();
		hotel = null;

		rseed = null;
		lastError = null;
		lastEffects = null;
	}

	static inline function seconds(n:Float) return Std.int(n*1000);
	static inline function minutes(n:Float) return Std.int(n*60*1000);
	static inline function hours(n:Float) return Std.int(n*60*60*1000);

	public inline function getLastEffectsCopy() return lastEffects.copy();
	public inline function hasEffects() return lastEffects.length>0;

	public function getHotelState() return hotel.getState();


	public function getFreeServiceRoom(t:RoomType) : SRoom {
		var best : SRoom = null;
		for(r in hotel.rooms)
			if( r.type==t && !r.working && !r.constructing && !r.isDamaged() )
				if( best==null )
					best = r;
				else if( !best.hasBoost() && r.hasBoost() )
					best = r;
		return best;
	}


	function advanceToRealTime() {
		//var deltaT = realTime - hotel.lastRealTime;
		//if( deltaT<0 )
			//deltaT = 0;

		//var now = hotel.lastEvent + deltaT;
		//if( now>=realTime )
			//now = realTime; // strange bug fix

		initRandom();
		lastEffects = [];
		lastError = null;

		//var pt = mt.deepnight.Lib.prettyTime;
		//applyPrint("advTo "+pt(realTime)+" delta="+pt(deltaT)+" last="+pt(hotel.lastNow)+" now="+pt(now));

		// Verify tasks
		var i = 0;
		while( i<hotel.tasks.length ) {
			var t = hotel.tasks[i];
			if( t.end<realTime ) {
				applyEffect( SyncLastEventTime(t.end) );
				completeTask(t.command);
			}
			else
				i++;
		}

		applyEffect(CheckMiniGame);
		checkQuests();
		checkStockRefills();
		//checkClientConsumes();

		hotel.lastRealTime = realTime;
		//hotel.lastNow = now;
		initRandom();
	}


	function trackGems(n:Int, reason:String) {
		applyEffect( TrackMoneyEvent("gems", n, reason) );
	}

	function trackGold(n:Int, reason:String) {
		applyEffect( TrackMoneyEvent("gold", n, reason) );
	}

	function trackGameplay(cat:String, sub:String) {
		applyEffect( TrackGameplayEvent(cat, sub) );
	}


	public function doCommand(c:GameCommand) {
		try {
			// Valid?
			verifyCommandConditions(c);

			// Run command
			applyCommand(c, true);

			// HappinessCombo quests detection
			var combo = 0;
			var uniqCids = new Map();
			for(e in lastEffects) {
				switch( e ) {
					case HappinessChanged(cid, v, d) :
						if( d>0 && !uniqCids.exists(cid) ) {
							uniqCids.set(cid, true);
							combo++;
						}
					default :
				}
			}
			for(q in hotel.curQuests) {
				var qdata = DataTools.getQuest(q.id);
				switch( qdata.objectiveId ) {
					case Data.QObjectiveKind.HappinessCombo :
						if( combo>=q.ocount )
							completeQuest(q, qdata);

					default :
				}
			}

			// Auto queue refill
			if( hotel.countWaitingClients()==0 && hotel.isPrepared() ) {
				applyEffect(QueueAutoRefilled);
				for(i in 0...hotel.getQueueLength())
					applyEffect( ClientArrived(null) );
			}

			return true;
		}
		catch( e:SolverError ) {
			// Command was not valid
			lastError = e;
			return false;
		}
	}


	public static function getEquipmentAffect(i:Item) : Affect {
		return switch( i ) {
			case I_Heat : Heat;
			case I_Cold : Cold;
			case I_Odor : Odor;
			case I_Noise : Noise;
			case I_Light: SunLight;
			default : null;
		}
	}


	function getNeighbours(x,y) {
		var all = [];
		var r = hotel.getRoom(x-1,y); if( r!=null && r.type==R_Bedroom && r.hasClient() ) all.push( r.getClient() );
		var r = hotel.getRoom(x+1,y); if( r!=null && r.type==R_Bedroom && r.hasClient() ) all.push( r.getClient() );
		var r = hotel.getRoom(x,y-1); if( r!=null && r.type==R_Bedroom && r.hasClient() ) all.push( r.getClient() );
		var r = hotel.getRoom(x,y+1); if( r!=null && r.type==R_Bedroom && r.hasClient() ) all.push( r.getClient() );
		return all;
	}

	function getStockRooms(t:RoomType, ?n=1) : Array<SRoom> {
		var all = hotel.rooms.filter( function(r) return r.type==t && r.data>0 && !r.constructing && !r.working && !r.isDamaged() );
		if( all.length>0 ) {
			all.sort( function(a,b) return -Reflect.compare(a.data, b.data) );
			if( all[0].data>=n )
				return [all[0]];
			else {
				var max = 0;
				for(r in all)
					max+=r.data;
				if( n>max )
					return [];

				var out = [];
				while( n>0 ) {
					var r = all.shift();
					out.push(r);
					n-=r.data;
				}
				return out;
			}
		}
		else
			return [];
	}


	public static function getHotelScore(h:HotelState) : Int {
		var v = h.level*1000;

		for(s in h.stats) {
			switch( s.k ) {
				case "maxed" : v+=2;
				case "vip" : v+=10;
				case "treas" : v+=25;
			}
		}

		for(r in h.rooms)
			switch( r.type ) {
				case R_Bedroom : v+=100;
				case R_FillerStructs, R_Lobby :
				default : v+=25;
			}

		return v;
	}



	public static function checkRoomDestructionConditions(h:SHotel, r:SRoom) : Null<SolverError> {
		if( !r.canBeDestroyed() )
			return CannotDestroyRoom;

		if( r.gifts.length>0 )
			return RoomMustBeEmpty;

		switch( r.type ) {
			case R_StockBoost, R_StockBeer, R_StockPaper, R_StockSoap :
				if( !h.roomUnlocked(r.type) )
					return IllegalAction;

				if( r.getMissingStock()>0 )
					return CannotDestroyStockIfNotFull;

			default :
		}

		if( r.working )
			return RoomCannotBeEdited;

		if( r.hasClient() )
			return RoomMustBeEmpty;

		return null;
	}




	public static function getLoveFromState(h:HotelState) : Int {
		var h = new com.SHotel(h);

		if( h.level<=0 )
			return 1;

		var base = 2;

		var l = h.level;
		var blevel =
			if( l>=25 ) 3;
			else if( l>=20 ) 2;
			else if( l>=10 ) 1;
			else 0;

		var n = 0;
		for(r in h.rooms)
			n+=r.getCustomizationBonus();
		var avg = n/h.countRooms(R_Bedroom,false);
		var bcustom =
			if( avg>=5 ) 2;
			else if( avg>=2 ) 1;
			else 0;

		return base + blevel + bcustom;
	}


	inline function requireMoney(n:Int) if( hotel.money<n ) throw NeedMoney(n);
	inline function requireLove(n:Int) if( hotel.love<n ) throw NeedLove(n);
	inline function requireGems(n:Int) if( hotel.gems<n ) throw NeedGems(n);
	inline function requireClientMoney(c:SClient, n:Int) if( c.money<n ) throw ClientNeedMoney(n);


	function verifyCommandConditions(c:GameCommand) : Bool {
		switch( c ) {
			case DoPing :

			//case InternalNewClient :

			case DoHardCodedMessage(id) :
				if( hotel.hasFlag(id) )
					throw Useless;

			case DoBuyPremium(id) :
				var e = Data.Premium.resolve(id);
				if( e==null )
					throw UnknownTarget;

				if( e.require!=null && !hotel.hasPremiumUpgrade(e.requireId) )
					throw IllegalAction;

				if( hotel.hasPremiumUpgrade(e.id) )
					throw Useless;

				requireGems(e.price);


			case DoClientReady :
				//updateQuest();

			//case DoDailyQuest(progress) :
				// TODO securize that a little bit

			case DoLoginPopUps(cnow) :
				var cnow = Date.fromString(cnow).getTime();
				if( MLib.fabs(realTime-cnow)>=DateTools.days(1) )
					throw TimezoneError;

			case DoRate(later) :

			case DoPrepareHotel(c) :
				if( hotel.isPrepared() )
					throw IllegalAction;

				if( c<0 || c>3 )
					throw UnknownTarget;


			case DoGetEventReward(eid) :
				#if neko
				var tolerance = true;
				#else
				var tolerance = false;
				#end
				var e = Data.Event.resolve(eid);
				if( e==null || !DataTools.hasEvent(e.id, hotel.lastEvent, tolerance) )
					throw EventRefused;

				if( hotel.hasDoneEvent(e.id) )
					throw EventAlreadyDone;


			case DoGetSpecialReward(id) :
				if( hotel.hasFlag("sp_"+id) )
					throw IllegalAction;

				#if !neko
				switch( id ) {
					case "android" : #if( !debug && !android) throw IllegalAction; #end
					case "ios" : #if( !debug && !ios ) throw IllegalAction; #end
					default : throw UnknownTarget;
				}
				#end


			case DoCompleteTutorial(id) :
				if( hotel.flags.exists(id) )
					throw IllegalAction;

			case DoBeginTutorial(id) :

			case DoUnlockFeature(id) :
				if( hotel.featureUnlocked(id) )
					throw Useless;

				if( !GameData.FEATURES.exists(id) )
					throw UnknownTarget;

				if( hotel.level<GameData.FEATURES.get(id) )
					throw IllegalAction;


			case DoNewQuest :
				var all = hotel.getDailyQuests();
				if( all.length>=hotel.getMaxDailyQuests() )
					throw Useless;

				if( !hotel.featureUnlocked("quests") )
					throw IllegalAction;

				requireGems(1);


			case DoCancelQuest(qid) :
				var q = hotel.getQuestState(qid);
				if( q==null )
					throw UnknownTarget;

				if( !DataTools.isDaily(qid) )
					throw IllegalTarget;

				if( !hotel.featureUnlocked("quests") )
					throw IllegalAction;

				requireGems(1);


			case DoValidateClient(cid) :
				var c = hotel.getClient(cid);
				if( c==null )
					throw UnknownClient;

				if( !c.done )
					throw IllegalTarget;

			case DoMiniGame(cid) :
				var c = hotel.getClient(cid);
				if( c==null )
					throw UnknownTarget;

				if( !c.hasMiniGameRequest(realTime) )
					throw IllegalTarget;


			case DoUpgradeRoom(x,y) :
				var r = hotel.getRoom(x,y);
				if( r==null )
					throw UnknownTarget;

				if( r.working || r.constructing )
					throw RoomIsLocked;

				var m = GameData.getRoomUpgradeCost(r.type, r.level);
				if( m<0 )
					throw IllegalAction;

				requireMoney(m);



			case DoCreateRoom(x,y, t) :
				if( hotel.hasRoom(x,y) ) {
					if( !hotel.featureUnlocked("roomReplace") )
						throw CannotBuildHere;

					var r = hotel.getRoom(x,y);
					if( r.type==t )
						throw Useless;

					var e = checkRoomDestructionConditions(hotel,r);
					if( e!=null )
						throw e;
				}

				if( hotel.countRooms(t)>=hotel.getMaxRoomCount(t) )
					throw RoomMaximumReached;

				var p = GameData.getRoomCost(t, hotel.countRooms(t));
				if( p<0 )
					throw IllegalAction;

				requireMoney(p);

				if( !hotel.hasRoom(x-1,y) && !hotel.hasRoom(x+1,y) && !hotel.hasRoom(x,y-1) && !hotel.hasRoom(x,y+1) )
					throw RoomMustBeConnected;

				if( !hotel.canBuildRoom(t) )
					throw IllegalAction;

				var l = hotel.getRoomsByType(R_Lobby)[0];
				if( y==l.cy && x>=l.cx )
					throw CannotBuildHere;

				switch( t ) {
					case R_FillerStructs :
						if( y<0 )
							throw NotUnderground;
					//case R_GoldMine :
						//if( y>=0 )
							//throw OnlyUnderground;

					default :
				}


			//case DoCreateSuite(x,y, dir) :
				//throw IllegalAction; // blocked
//
				//if( dir!=-1 && dir!=1 )
					//throw IllegalAction;
//
				//var r = hotel.getRoom(x,y);
				//if( r==null || r.type!=R_Bedroom )
					//throw IllegalTarget;
//
				//if( r.wid!=1 )
					//throw Useless;
//
				//if( r.hasClient() )
					//throw RoomMustBeEmpty;
//
				//if( hotel.hasRoom(x+dir, y) )
					//throw dir==-1 ? NeedEmptySpaceLeft : NeedEmptySpaceRight;
//
				//requireMoney(5000); // TODO


			case DoBuyItem(i, n, _,_) :
				var inf = GameData.getItemCost(i);
				if( inf.n<=0 )
					throw IllegalAction;

				if( inf.isGold )
					requireMoney(inf.cost*n);
				else
					requireGems(inf.cost*n);

			//case DoBuyRandomCustom(c) :
				//if( c==null )
					//requireGems( GameData.RANDOM_CUSTOM_COST_ANY );
				//else
					//requireGems( GameData.RANDOM_CUSTOM_COST_CAT );

			case DoBuyRandomCustom :
				requireGems( GameData.RANDOM_CUSTOM_COST_ANY );

			case DoCheat(_) :
				#if( neko || connected )
				throw IllegalAction;
				#end

			case DoGiveLove(cid) :
				var c = hotel.getClient(cid);
				if( c==null )
					throw UnknownClient;

				if( c.done || c.isWaiting() )
					throw IllegalTarget;

				if( c.hasHappinessMod(HM_Love) )
					throw IllegalTarget;

				requireLove(1);


			case DoValidateAll :
				var n = 0;
				for(c in hotel.clients)
					if( c.done )
						n++;
				if( n==0 )
					throw Useless;


			case DoDestroyRoom(x,y) :
				if( !hotel.hasRoom(x,y) )
					throw UnknownTarget;

				var r = hotel.getRoom(x,y);
				var e = checkRoomDestructionConditions(hotel, r);
				if( e!=null )
					throw e ;

				if( !hotel.checkConsistency(x,y) )
					throw HotelConsistencyError;



			case DoClearCustomizations(x,y, i) :
				var r = hotel.getRoom(x,y);
				if( r==null || r.type!=R_Bedroom )
					throw IllegalTarget;

				if( r.hasClient() )
					throw RoomMustBeEmpty;


			case DoSkipClient(cid) :
				var c = hotel.getClient(cid);
				if( c==null )
					throw UnknownClient;

				if( !c.canBeSkipped(hotel.lastEvent) )
					throw IllegalTarget;

				if( c.isWaiting() )
					throw IllegalAction;

				var t = hotel.getClientCompleteTask(cid);
				if( t==null || t.end<=realTime-DateTools.seconds(5) )
					throw TooLateToSkip;

				requireGems(1);

			case DoSkipAllClients :
				var all = hotel.getSkipAllClients(hotel.lastEvent);
				if( all.length==0 )
					throw IllegalAction;

				var cost = GameData.getSkipAllCost(all.length);
				requireGems(cost);


			case DoSkipConstruction(x,y) :
				var r = hotel.getRoom(x,y);
				if( r==null )
					throw UnknownTarget;

				if( !r.constructing )
					throw IllegalTarget;

				var t = hotel.getTask(InternalUnsetConstructing(x,y));
				if( t!=null && t.end-realTime<=DateTools.seconds(1) )
					throw CannotUseGemNow;

				requireGems(1);


			case DoSkipWork(x,y) :
				var r = hotel.getRoom(x,y);
				if( r==null )
					throw UnknownTarget;

				if( !r.working)
					throw IllegalTarget;

				if( !r.canSkipWork() )
					throw IllegalTarget;

				requireGems(1);


			case DoRepairAll :
				var n = 0;
				for(r in hotel.rooms)
					n+=r.damages;

				if( n==0 )
					throw Useless;


			case DoRepairRoom(x,y) :
				if( !hotel.hasRoom(x,y) )
					throw UnknownTarget;

				var r = hotel.getRoom(x,y);
				if( r.working || r.constructing )
					throw RoomIsLocked;

				if( r.hasClient() )
					throw RoomMustBeEmpty;

				if( r.damages<=0 )
					throw Useless;

				if( hotel.countStock(R_StockSoap)<r.damages )
					throw NeedStock(R_StockSoap, r.damages);


			case DoBoostRoom(x,y) :
				if( !hotel.hasRoom(x,y) )
					throw UnknownTarget;

				var r = hotel.getRoom(x,y);
				if( r.constructing )
					throw RoomIsLocked;

				if( !r.canBeBoosted() )
					throw IllegalTarget;

				if( r.hasBoost() )
					throw Useless;

				if( r.isDamaged() )
					throw RoomIsDamaged;

				switch( r.type ) {
					case R_StockBeer, R_StockPaper, R_StockSoap :
						if( r.data>=GameData.getStockMax(r.type, r.level) )
							throw Useless;

					case R_Laundry :
						if( !r.working )
							throw Useless;

					default :
				}

				var r = getStockRooms(R_StockBoost,1);
				if( r.length==0 )
					throw NeedStock(R_StockBoost, 1);


			case DoActivateRoom(x,y, s) :
				if( !hotel.hasRoom(x,y) )
					throw UnknownTarget;

				var r = hotel.getRoom(x,y);
				if( r.working || r.constructing )
					throw RoomIsLocked;

				switch( r.type ) {
					case R_Lobby :
						var mode : Int = s;
						switch( mode ) {
							case 0 : // refill
								if( hotel.waitingLineIsFull() )
									throw WaitingLineIsFull;

							case 1 : // reset

							default :
								throw IllegalAction;
						}

						requireGems(1);

					case R_StockBoost :
						if( r.data>0 )
							throw IllegalAction;

						requireGems(1);

					case R_VipCall :
						if( r.working )
							throw RoomIsLocked;

					case R_LevelUp :
						for(c in hotel.clients)
							if( c.type==C_Inspector )
								throw AlreadyHaveInspector;
						requireMoney(GameData.getLevelUpCost(hotel.level));

					default :
						throw IllegalAction;
				}



			case DoInstallClient(cid, x,y) :
				var c = hotel.getClient(cid);
				if( c==null )
					throw UnknownClient;

				if( c.done )
					throw IllegalTarget;

				var tr = hotel.getRoom(x,y);
				if( tr==null || tr.type!=R_Bedroom )
					throw IllegalTarget;

				if( tr.constructing )
					throw RoomIsLocked;

				if( tr.working && c.type!=C_Repairer )
					throw RoomIsLocked;

				if( !c.isWaiting() )
					throw IllegalAction;

				if( tr.hasClient() )
					throw AlreadyOccupied;

				//if( tr.isDamaged() && c.type!=C_Repairer )
					//throw RoomIsDamaged;

				if( tr.gifts.length>3 )
					throw PickGiftsFirst;


			case DoSendClientToUtilityRoom(cid, x,y, data) :
				var c = hotel.getClient(cid);
				if( c==null )
					throw UnknownClient;

				if( c.done )
					throw IllegalTarget;

				var tr = hotel.getRoom(x,y);
				if( tr==null )
					throw IllegalTarget;

				if( tr.type!=R_Trash && tr.type!=R_ClientRecycler && c.isWaiting() )
					throw ClientMustHaveARoom;

				switch( tr.type ) {
					case R_ClientRecycler :
						//if( !c.isWaiting() )
							//throw NoRecyclerOnInstalledClient;

						if( c.emit==null )
							throw CannotRecycleThisClient;

					case R_Bar :
						var sr = getStockRooms(R_StockBeer);
						if( sr.length==0 )
							throw NeedStock(R_StockBeer, 1);

						requireClientMoney(c, 1);

					//case R_Restaurant :
						//var sr = getStockRooms(R_StockPaper);
						//if( sr.length==0 )
							//throw NeedStock(R_StockPaper, 1);
//
						//requireClientMoney(c, 1);

					//case R_Xp :
						//if( tr.data<=0 )
							//throw NeedStock(R_Xp, 1);
//
						//requireClientMoney(c, 1);

					//case R_Psy :
						//var found = false;
						//for(m in c.happinessMods)
							//if( m.value<0 ) {
								//found = true;
								//break;
							//}
						//if( !found )
							//throw Useless;
//
						//requireClientMoney(c, 1);

					case R_Trash :
						//if( !c.isWaiting() )
							//throw NoTrashOnInstalledClient;

					//case R_AffectCold :
						//if( !c.hasLike(Cold) )
							//throw ClientDoesntLike(Cold);
						//requireClientMoney(c, 1);
//
					//case R_AffectHeat :
						//if( !c.hasLike(Heat) )
							//throw ClientDoesntLike(Heat);
						//requireClientMoney(c, 1);
//
					//case R_AffectNoise :
						//if( !c.hasLike(Noise) )
							//throw ClientDoesntLike(Noise);
						//requireClientMoney(c, 1);
//
					//case R_AffectOdor :
						//if( !c.hasLike(Odor) )
							//throw ClientDoesntLike(Odor);
						//requireClientMoney(c, 1);

					default :
						throw IllegalTarget;
				}

				if( tr.constructing || tr.working )
					throw RoomIsLocked;


			case DoUseItem(i) :
				switch( i ) {
					case I_LunchBoxAll, I_LunchBoxCusto :

					default :
						throw IllegalTarget;
				}

				if( !hotel.hasInventoryItem(i) )
					throw NeedItem(i);


			case DoUseItemOnRoom(x,y,i) :
				if( !hotel.hasRoom(x,y) )
					throw UnknownTarget;

				var r = hotel.getRoom(x,y);
				if( r.constructing )
					throw RoomIsLocked;

				if( !r.canReceivedItem(i) )
					throw CannotUseItemHere;

				var c = r.getClient();
				switch( i ) {
					case I_Cold, I_Heat, I_Noise, I_Odor, I_Light :
						if( c==null || c.done )
							throw CannotUseItemHere;

						var a = getEquipmentAffect(i);
						switch( c.type ) {
							case C_Emitter :

							default :
								if( !c.hasLike(a) )
									throw Useless;
						}

					case I_Bath(f) :
						if( r.custom.bath==f )
							throw Useless;

					case I_Bed(f) :
						if( r.custom.bed==f )
							throw Useless;

					case I_Ceil(f) :
						if( r.custom.ceil==f )
							throw Useless;

					case I_Furn(f) :
						if( r.custom.furn==f )
							throw Useless;

					case I_Wall(f) :
						if( r.custom.wall==f )
							throw Useless;

					case I_Color(id) :
						if( r.custom.color==id )
							throw Useless;

					case I_Texture(f) :
						if( r.custom.texture==f )
							throw Useless;

					case I_Money(_), I_Gem, I_LunchBoxAll, I_LunchBoxCusto, I_EventGift(_) :
						throw IllegalAction;
				}


				//switch( i ) {
					//case I_Bath(_), I_Bed(_), I_Ceil(_), I_Furn(_), I_Wall(_), I_Color(_), I_Texture(_) :
						//if( c!=null && c.done )
							//throw ValidateClientFirst;
//
					//default :
				//}

				if( !hotel.hasInventoryItem(i) )
					throw NeedItem(i);



			//case DoRemoveEquipment(x,y,e) :
				//if( !hotel.hasRoom(x,y) )
					//throw UnknownTarget;
//
				//var r = hotel.getRoom(x,y);
				//if( !r.hasEquipment(e) )
					//throw UnknownTarget;
//
				//if( !r.canBeEdited() )
					//throw RoomCannotBeEdited;


			case DoPickGift(cx,cy) :
				var r = hotel.getRoom(cx,cy);
				if( r==null )
					throw UnknownTarget;

				if( r.gifts.length==0 )
					throw UnknownTarget;


			case DoService(cid) :
				var c = hotel.getClient(cid);
				if( c==null )
					throw UnknownClient;

				if( c.isWaiting() )
					throw IllegalTarget;

				if( !c.hasServiceRequest(realTime) )
					throw IllegalTarget;

				switch( c.serviceType ) {
					case R_Laundry :
						var r = getFreeServiceRoom(R_Laundry);
						if( r==null )
							throw NoLaundryAvailable;

					case R_StockPaper, R_StockSoap :
						if( hotel.countStock(c.serviceType)==0 )
							throw NeedStock(c.serviceType, 1);

					default :
						throw IllegalAction;
				}

			case DoMessagesActions(a) :
				var hmsgs = hotel.messages.copy();
				for( m in a ) {
					var found = false;
					for(e in hmsgs)
						if( e.equals(m) ) {
							found = true;
							hmsgs.remove(e);
							break;
						}
					if( !found )
						throw UnknownTarget;
				}

			case InternalUnsetConstructing(_), InternalUnsetWorking(_), InternalRoomTrigger(_),
				InternalCompleteClient(_), InternalRoomRepair(_), InternalClientSpecialAction(_),
				InternalClientLock(_), InternalSetFlag(_), InternalClientPerk(_) :
				//InternalPaymentTick :
				throw InternalGameCommand;

			//case InternalGetLove(_) :

			case __unused0 : throw IllegalAction;
		}

		return false;
	}






	function applyCommand(c:GameCommand, syncLastEventTime:Bool) {
		initRandom();
		applyEffect( Ok(c) );

		// Update last event time
		if( syncLastEventTime )
			switch( c ) {
				case DoPing, DoClientReady :

				default :
					applyEffect( SyncLastEventTime(realTime) );
			}

		// Apply
		switch( c ) {
			case DoPing :

			case DoClientReady :

			case DoHardCodedMessage(id) :
				applyEffect( HotelFlagSet(id, true) );


			case DoLoginPopUps(cnow) :
				if( realTime-hotel.lastDaily >= GameData.LONG_ABSENCE ) {
					// Long absence gift
					applyEffect( SyncLastEventTime(realTime) );
					for(r in hotel.rooms)
						if( r.isDamaged() )
							applyEffect( RoomRepaired(r.cx,r.cy, 99) );
					applyEffect( LongAbsence );
					applyMoneyGain( GameData.ABSENCE_GOLD );
					applyEffect( AddGems(GameData.ABSENCE_GEMS,false) );
					for(i in 0...hotel.getQueueLength()-hotel.countWaitingClients())
						applyEffect( ClientArrived(null) );
				}
				else {
					var cnow = Date.fromString(cnow).getTime();
					var tzOffset = cnow-realTime;
					// Daily quests
					var tz_now = Date.fromTime(realTime+tzOffset);
					var tz_last = Date.fromTime(hotel.lastDaily+tzOffset);
					if( tz_now.getDate()!=tz_last.getDate() ) {
						var tz_nextLast = Date.fromTime( hotel.lastDaily + tzOffset + DateTools.days(1) );
						applyEffect( SyncLastEventTime(realTime) );
						applyEffect( DailyLevelProgress(tz_now.getDate()==tz_nextLast.getDate()) );
						applyEffect( NewDay );
						var dr = DataTools.getDailyReward(hotel.dailyLevel);
						if( dr.gems>0 )
							applyEffect( AddGems(dr.gems,false) );
						if( dr.gold )
							applyEffect( AddMoney(GameData.DAILY_GOLD) );
						if( dr.lunchBoxes>0 )
							applyEffect( AddItem(I_LunchBoxCusto, dr.lunchBoxes) );
						applyEffect( AddLove(GameData.DAILY_LOVE) );
					}
				}

				// Forced friend requests
				if( !hotel.hasFlag("loginEvent") && hotel.level>=4 && !hotel.hasFlag("friendReq") ) {
					var all = new mt.RandList(rseed.random);
					all.add(HFR_SendGold, 15);
					all.add(HFR_SendGem, 1);
					var r = all.draw();
					applyEffect( SyncLastEventTime(realTime) );
					applyEffect( ShowFriendRequest(r) );
				}

				// <--- WARNING: insert new future events here, as the rate event is never displayed on web clients.
				// So it will block further events.

				// Rate us!
				if( !hotel.hasFlag("loginEvent") && hotel.level>=3 && !hotel.hasFlag("rated") && !hotel.hasFlag("rateLater") ) {
					applyEffect( SyncLastEventTime(realTime) );
					applyEffect( ShowRating );
				}

			case DoRate(later) :
				applyEffect( Rated(later) );

			case DoBuyPremium(id) :
				var e = Data.Premium.resolve(id);
				trackGems(e.price, "premium."+id);
				applyEffect( RemoveGem(e.price) );
				applyEffect( PremiumBought(id) );
				switch( e.id ) {
					case Data.PremiumKind.LobbyQueue1,
						Data.PremiumKind.LobbyQueue2,
						Data.PremiumKind.LobbyQueue3,
						Data.PremiumKind.LobbyQueue4,
						Data.PremiumKind.LobbyQueue5,
						Data.PremiumKind.LobbyQueue6,
						Data.PremiumKind.LobbyQueue7 :
							var r = hotel.getRoomsByType(R_Lobby)[0];
							applyEffect( PremiumOnRoom(id, r.cx, r.cy) );
							applyEffect( RoomUpgraded(r.cx, r.cy) );
							while( hotel.countWaitingClients()<hotel.getQueueLength() )
								applyEffect( ClientArrived(null) );

					case Data.PremiumKind.Booster1,
						Data.PremiumKind.Booster2,
						Data.PremiumKind.Booster3 :
							for(r in hotel.getRoomsByType(R_StockBoost)) {
								applyEffect( PremiumOnRoom(id, r.cx, r.cy) );
								applyEffect( RoomUpgraded(r.cx, r.cy) );
								var n = r.getMissingStock();
								if( n>0 )
									applyEffect( StockAdded(r.cx, r.cy, n) );
							}

					case Data.PremiumKind.CustoRecycler :

					case Data.PremiumKind.Bank1 :

					case Data.PremiumKind.VipRoom1 :

					case Data.PremiumKind.GetLove1,
						Data.PremiumKind.GetLove2 :

					case Data.PremiumKind.MaxLove1,
						Data.PremiumKind.MaxLove2 :
							var n = hotel.getMaxLove()-hotel.love;
							if( n>0 )
								applyEffect( AddLove(n) );

					case Data.PremiumKind.PowerOfLove1,
						Data.PremiumKind.PowerOfLove2,
						Data.PremiumKind.PowerOfLove3 :
				}

			case DoPrepareHotel(c) :
				var c1 = Data.WallColorKind.gray0;
				var c2 = Data.WallColorKind.gray0;
				switch( c ) {
					case 0 :
						c1 = Data.WallColorKind.coldBlue;
						c2 = Data.WallColorKind.blue2;
						trackGameplay("prepare","blue");

					case 1 :
						c1 = Data.WallColorKind.pink2;
						c2 = Data.WallColorKind.pink3;
						trackGameplay("prepare","pink");

					case 2 :
						c1 = Data.WallColorKind.coldGreen;
						c2 = Data.WallColorKind.green2;
						trackGameplay("prepare","green");

					case 3 :
						c1 = Data.WallColorKind.red0;
						c2 = Data.WallColorKind.red1;
						trackGameplay("prepare","red");
				}
				var c1 = c1.toString();
				var c2 = c2.toString();
				applyEffect( CustoUnlocked(I_Color(c1)) ) ;
				applyEffect( CustoUnlocked(I_Color(c2)) ) ;
				applyEffect( AddItem(I_Color(c1), 1) );
				applyEffect( ItemUsedOnRoom(0,1, I_Color(c1)) );
				applyEffect( ItemUsedOnRoom(1,1, I_Color(c2)) );
				applyEffect( ItemUsedOnRoom(0,2, I_Color(c2)) );
				applyEffect( ItemUsedOnRoom(1,2, I_Color(c1)) );
				for(r in hotel.rooms)
					if( r.type==R_Bedroom )
						applyEffect( ItemUsedOnRoom(r.cx, r.cy, I_Color((r.cx+r.cy)%2==0 ? c1 : c2)) );

				while( hotel.countWaitingClients() < hotel.getQueueLength() )
					applyEffect( ClientArrived(null) );
				applyEffect( HotelFlagSet("prepare",true) );


			case DoGetEventReward(eid) :
				applyEffect( EventRewardReceived(eid) );
				switch( Data.Event.resolve(eid).id ) {
					case Data.EventKind.ChristmasDay :
						for(r in hotel.rooms)
							if( r.type==R_Bedroom )
								applyEffect( AddGift(r.cx, r.cy, I_Gem) );

					case Data.EventKind.ChristmasPeriod :
						for(r in hotel.rooms)
							if( r.type==R_Bedroom )
								applyEffect( AddGift(r.cx, r.cy, I_Money(2000)) );
						applyEffect( ClientArrived(null) ); // should be santa automatically

					case Data.EventKind.Autumn :
						for(r in hotel.rooms)
							if( r.type==R_Bedroom )
								applyEffect( AddGift(r.cx, r.cy, I_Money( rseed.irange(500,700) ) ) );

					case Data.EventKind.NewYear :
						var r = hotel.getRoomByType(R_Lobby);
						for( i in 0...6 )
							applyEffect( AddGift(r.cx, r.cy, I_Gem) );

					//case Data.EventKind.Test :
						//for(r in hotel.rooms)
							//if( !r.isFiller() )
								//applyEffect( AddGift(r.cx, r.cy, I_Money(200)) );
				}


			case DoGetSpecialReward(id) :
				var items = switch( id ) {
					case "android" :
						[
							{n:5, i:I_Gem},
							{n:1, i:I_Furn(26)},
							{n:1, i:I_Wall(22)},
						];

					case "ios" :
						[
							{n:5, i:I_Gem},
							{n:1, i:I_Furn(25)},
							{n:1, i:I_Wall(21)},
						];

					default :
						[];
				}
				trackGameplay("special",id);

				if( items.length>0 ) {
					applyEffect( HotelFlagSet("sp_"+id, true) );
					applyEffect( SpecialRewardReceived(id, items) );

					for(i in items) {
						if( GameData.isCustomizeItem(i.i) ) {
							applyEffect( CustoUnlocked(i.i) );
						}
						switch( i.i ) {
							case I_Gem : applyEffect( AddGems(i.n, false) );
							case I_Money(n2) : applyMoneyGain( i.n*n2 );
							//case I_Money(n2) : applyEffect( AddMoney(i.n*n2) );
							default : applyEffect( AddItem(i.i, i.n) );
						}
					}
				}

			case DoBeginTutorial(id) :
				var fid = "tg_"+id;
				switch( id ) {
					case "gems" :
						if( !hotel.hasFlag(fid) ) {
							applyEffect( HotelFlagSet(fid, true) );
							applyEffect( AddGems(1, false) );
						}

					case "premium" :
						if( !hotel.hasFlag(fid) ) {
							applyEffect( HotelFlagSet(fid, true) );
							applyEffect( AddGems(1, false) );
						}
				}
				//if( !hotel.hasFlag("ts_"+id) ) {
					//applyEffect( HotelFlagSet("ts_"+id, true) );
					//switch( id ) {
						//case "gems" : applyEffect( AddGems(1, false) );
						//case "premium" : applyEffect( AddGems(1, false) );
						//default :
					//}
				//}

			case DoCompleteTutorial(id) :
				applyEffect( TutorialCompleted(id) );
				switch( id ) {
					default :
				}


			case DoUnlockFeature(id) :
				if( !hotel.featureUnlocked(id) ) {
					applyFeatureUnlock(id);
					trackGameplay("featureUnlock",id);
				}

			case DoCreateRoom(x,y,t) :
				if( hotel.hasRoom(x,y) )
					applyRoomDestruction( hotel.getRoom(x,y) );

				var nbRooms = hotel.countRooms(t);
				var p = GameData.getRoomCost(t, hotel.countRooms(t));
				applyEffect( CreateRoom(x,y,t) );
				var d = GameData.getRoomConstructionDelay(t, nbRooms);
				if( d>0 ) {
					applyEffect( StartTask(InternalUnsetConstructing(x,y), d) );
					applyEffect( SetConstructing(x,y, true) );
				}
				applyEffect( RemoveMoneyFromRoom(x,y, p) );
				trackGold(p, "room.build");

				var rid = switch( t ) {
					case R_Bedroom : "bedroom";
					case R_Bar : "bar";
					case R_StockBeer : "stockBeer";
					case R_StockBoost : "stockBoost";
					case R_StockPaper : "stockPaper";
					case R_StockSoap : "stockSoap";
					case R_Library : "library";
					case R_Laundry : "laundry";
					case R_FillerStructs : "fillerStruct";
					case R_Trash : "trash";
					case R_CustoRecycler : "custoRecycler";
					case R_ClientRecycler : "clientRecycler";
					case R_Bank : "bank";
					case R_VipCall : "vipCall";
					case R_Lobby, R_LevelUp : "unknown"+t.getIndex();
				}

				switch( t ) {
					case R_StockBoost :
						var r = hotel.getRoom(x,y);
						if( hotel.hasPremiumUpgrade(Data.PremiumKind.Booster1) ) applyEffect( RoomUpgraded(x,y) );
						if( hotel.hasPremiumUpgrade(Data.PremiumKind.Booster2) ) applyEffect( RoomUpgraded(x,y) );
						if( hotel.hasPremiumUpgrade(Data.PremiumKind.Booster3) ) applyEffect( RoomUpgraded(x,y) );
						if( r.getMissingStock()>0 )
							applyEffect( StockAdded(x, y, r.getMissingStock()) );

					default :
				}
				trackGameplay( "room","r_"+rid+"_"+hotel.countRooms(t,true) );


			//case DoCreateSuite(x,y, dir) :
				//applyEffect( SuiteCreated(x,y,dir) );
				//applyEffect( RemoveMoneyFromRoom(x,y, 5000) ); // TODO


			case DoNewQuest :
				applyEffect( RemoveGem(1) );
				trackGems(1, "quest.regen");
				applyEffect( QuestBought );
				startDailyQuest();
				checkQuests();


			case DoCancelQuest(qid) :
				trackGameplay("quest","cancel_"+qid);
				applyEffect( RemoveGem(1) );
				trackGems(1, "quest.cancel");
				applyEffect( QuestCancelled(qid) );
				applyEffect( QuestBought );
				startDailyQuest(qid);
				checkQuests();

			case DoMiniGame(cid) :
				var c = hotel.getClient(cid);
				var rewards = new mt.RandList(rseed.random);
				rewards.add({m:5, lvl:0}, 200);
				rewards.add({m:10, lvl:0}, 20);
				rewards.add({m:25, lvl:0}, 10);
				rewards.add({m:200, lvl:1}, 8);
				rewards.add({m:2500, lvl:2}, 1);
				var r = rewards.draw();
				applyEffect( MiniGame(cid, r.m, r.lvl) );
				applyMoneyGain(c, r.m, r.lvl>=1);
				//applyEffect( AddMoneyFromClient(cid, r.m, r.lvl>=1) );
				applyEffect( ClientWokeUp(cid) );
				advanceQuest(Data.QObjectiveKind.Theft);
				trackGameplay("theft", r.lvl>=2?"rare":r.lvl==1?"uncommon":"common");
				hotel.addGoal("thief");
				if( r.lvl>=2 )
					hotel.addGoal("treasure");


			case DoUpgradeRoom(x,y) :
				var r = hotel.getRoom(x,y);
				var p = GameData.getRoomUpgradeCost(r.type, r.level);
				applyEffect( RemoveMoneyFromRoom(x,y, p) );
				applyEffect( RoomUpgraded(x,y) );
				switch( r.type ) {
					case R_Bedroom :
						trackGold(p, "room.upgrade");
						var c = r.getClient();
						if( c!=null )
							addHappiness(c, 1, HM_Luxury, true);

					case R_Lobby :
						applyEffect( ClientArrived(null) );
						trackGold(p, "lobby.upgrade");

					default :
				}


			case DoClearCustomizations(x,y, i) :
				var r = hotel.getRoom(x,y);
				applyClearCustomizations(r, i);

			case DoDestroyRoom(x,y) :
				var r = hotel.getRoom(x,y);
				applyRoomDestruction(r);

			case DoBuyRandomCustom :
				var tries = 200;
				var i : Item = null;
				do {
					i = getRandomCustomItem(true);
				} while( tries-->0 && i==null );

				if( i==null ) {
					applyEffect( Print("Transaction failed, please retry (nothing was bought)") );
					applyEffect( AddStat("custFail",1) );
				}
				else {
					applyEffect( AddStat("buyCust",1) );
					applyEffect( RemoveGem(GameData.RANDOM_CUSTOM_COST_ANY) );
					trackGems(1, "custom.buy");
					applyEffect( LunchBoxOpened(i, true) );
					if( !hotel.customUnlocked(i) )
						applyEffect( CustoUnlocked(i) );
					applyEffect( AddItem(i, 1) );
				}


			case DoBuyItem(i, n, x, y) :
				var inf = GameData.getItemCost(i);
				if( inf.isGold )
					applyEffect( x!=null && y!=null ? RemoveMoneyFromRoom(x,y, inf.cost*n) : RemoveMoney(inf.cost*n) );
				else {
					applyEffect( AddStat("buyItem",n) );
					applyEffect( x!=null && y!=null ? RemoveGemFromRoom(x,y, inf.cost*n) : RemoveGem(inf.cost*n) );
				}
				applyEffect( AddItem(i, inf.n*n) );
				if( inf.isGold )
					trackGold(inf.cost*n, "item.buyWithGold");
				else
					trackGems(inf.cost*n, "item.buyWithGems");

			case DoCheat(cc) :
				//#if( !debug || connected || neko )
				//throw IllegalAction;
				//#else
				trackGameplay("cheat", Std.string(cc.getIndex()));
				switch( cc ) {
					case CC_Item(i,n) :
						switch( i ) {
							case I_Gem:
								applyEffect( AddGems(n, true) );
								trackGems(n, "cheat");

							case I_Money(m) :
								applyMoneyGain(m*n);
								//applyEffect( AddMoney(m*n) );
								trackGold(m*n, "cheat");

							case I_Cold, I_Heat, I_Odor, I_Noise, I_Light :
								applyEffect( AddItem(i,n) );

							default :
								throw IllegalAction;
						}

					case CC_Max(cid) :
						var c = hotel.getClient(cid);
						addHappiness(c, 100, HM_Love, true);

					case CC_Inspect :
						var i = DataTools.getBoss(hotel.level);
						applyEffect( ClientArrived(C_Inspector) );
						applyEffect( BossArrived );

					case CC_FillCustom :
						for(r in hotel.rooms)
							if( r.type==R_Bedroom ) {
								r.custom.bath = rseed.random(Data.Bath.all.length);
								r.custom.bed = rseed.random(Data.Bed.all.length);
								r.custom.ceil = rseed.random(Data.Ceil.all.length);
								r.custom.furn = rseed.random(Data.Furn.all.length);
								r.custom.wall = rseed.random(Data.WallFurn.all.length);
								r.custom.texture = rseed.random(Data.WallPaper.all.length);
								r.custom.color = Data.WallColor.all[ rseed.random(Data.WallColor.all.length) ].id.toString();
							}

					case CC_AddDay(_) :

					case CC_Damage(x,y) :
						applyEffect( RoomDamaged(x,y, 1, true) );
				}
				applyEffect( Cheated(cc) );
				//#end

			case DoValidateAll :
				for(c in hotel.clients.copy())
					if( c.done )
						validateClient(c.id);

			case DoValidateClient(cid) :
				validateClient(cid);

			case DoSkipClient(cid) :
				var c = hotel.getClient(cid);
				applyEffect( RemoveGemFromRoom(c.room.cx, c.room.cy, 1) );
				trackGems(1, "client.skip");
				//#if debug applyRoomDamage(c.room, 2); #end
				applyClientSkip( hotel.getClient(cid) );


			case DoSkipAllClients :
				var all = hotel.getSkipAllClients(hotel.lastEvent);
				var cost = GameData.getSkipAllCost(all.length);
				applyEffect( RemoveGem(cost) );
				var n = 0;
				for( c in all ) {
					if( !c.canBeSkipped(hotel.lastEvent) )
						continue;

					applyClientSkip(c);
					//applyEffect( ClientSkipped(c.id) );
					//applyEffect( ClientFlagSet(c.id, "skipGem") );
					//completeTask( InternalCompleteClient(c.id) );
					//validateClient(c.id);
				}
				trackGems(cost, "client.skipAll");

			case DoSkipConstruction(x,y) :
				applyEffect( RemoveGemFromRoom(x,y, 1) );
				applyEffect( RoomConstructionSkipped(x,y) );
				completeTask( InternalUnsetConstructing(x,y) );
				trackGems(1, "room.skipConstruction");

			case DoSkipWork(x,y) :
				applyEffect( RemoveGemFromRoom(x,y, 1) );
				applyEffect( RoomWorkSkipped(x,y) );
				completeTask( InternalUnsetWorking(x,y) );
				completeTask( InternalRoomRepair(x,y) );
				trackGems(1, "room.skipJob");

			case DoGiveLove(cid) :
				var c = hotel.getClient(cid);
				applyEffect( ClientLoved(cid) );
				addHappiness(c, hotel.getLovePower(), HM_Love, true);
				applyEffect( RemoveLoveFromRoom(c.room.cx, c.room.cy, 1) );
				advanceQuest(Data.QObjectiveKind.Love);
				trackGameplay("love","use");
				hotel.addGoal("love");


			case DoRepairAll :
				for(r in hotel.rooms)
					if( r.damages>0 && !r.hasClient() && !r.working && !r.constructing && hotel.countStock(R_StockSoap)>=r.damages ) {
						var x = r.cx;
						var y = r.cy;
						applyEffect( RoomRepairStarted(x,y) );
						applyStockConsumption(R_StockSoap, r.damages, r);

						var d = GameData.getRepairDuration(r.damages, r.level);
						applyWork(x,y, d);
						applyEffect( StartTask(InternalRoomRepair(x, y), d ) );
					}


			case DoRepairRoom(x,y) :
				var r = hotel.getRoom(x,y);

				applyEffect( RoomRepairStarted(x,y) );
				applyStockConsumption(R_StockSoap, r.damages, r);

				var d = GameData.getRepairDuration(r.damages, r.level);
				applyWork(x,y, d);
				applyEffect( StartTask(InternalRoomRepair(x, y), d ) );


			case DoBoostRoom(x,y) :
				var r = hotel.getRoom(x,y);
				var sr = getStockRooms(R_StockBoost,1)[0];
				applyBoost(r);
				applyEffect( StockMovedTo(sr.cx, sr.cy, r.cx, r.cy) );
				advanceQuest( Data.QObjectiveKind.Boost );

				switch( r.type ) {
					case R_StockBeer, R_StockPaper, R_StockSoap :
						while( r.getMissingStock()>0 )
							applyEffect( StockAdded(r.cx, r.cy, 1) );
						checkStockRefills();

					case R_Laundry :

					default :
				}

				switch( r.type ) {
					case R_Laundry : trackGameplay("boost","laundry");
					case R_StockBeer : trackGameplay("boost","beer");
					case R_StockPaper : trackGameplay("boost","paper");
					case R_StockSoap : trackGameplay("boost","soap");
					default :
				}

			case DoActivateRoom(x,y, s) :
				var r = hotel.getRoom(x,y);
				switch( r.type ) {
					case R_Lobby :
						applyEffect( RemoveGemFromRoom(x,y, 1) );
						var mode : Int = s;
						switch( mode ) {
							case 0 : // refill
								trackGems(1, "lobby.refill");
								applyEffect( RoomActivated(x,y) );
								for(i in 0...hotel.getQueueLength()-hotel.countWaitingClients())
									applyEffect( ClientArrived(null) );

							case 1 : // wipe!
								trackGems(1, "lobby.wipe");
								var all = hotel.getWaitingClients();
								for(c in all)
									applyClientDeath(c);

								applyEffect( RoomActivated(x,y) );
								for(i in 0...hotel.getQueueLength())
									applyEffect( ClientArrived(null) );
						}

					case R_StockBoost :
						if( r.data==0 ) {
							applyEffect( RoomActivated(x,y) );
							applyEffect( RemoveGemFromRoom(r.cx, r.cy, 1) );
							trackGems(1, "boost.refill");
							for(i in r.data...GameData.getStockMax(r.type, r.level))
								applyEffect( StockAdded(r.cx, r.cy, 1) );
						}
						checkStockRefills();

					case R_VipCall :
						applyWork(x,y, GameData.VIP_CALL_DURATION);
						applyEffect( ForcedVipArrived );

					case R_LevelUp :
						//var v = GameData.getLevelUpCost(hotel.level);
						//if( v>0 )
							//applyEffect( RemoveMoneyFromRoom(x,y, v) );
						//applyEffect( RoomActivated(x,y) );
						//applyWork(x,y, GameData.getLevelUpDuration(hotel.level));
						//applyEffect( ClientArrived(C_Inspector) );

					default :
				}



			case InternalCompleteClient(cid) :
				var c = hotel.getClient(cid);
				applyEffect( ClientDone(cid) );

				// Damages
				if( !c.skippedUsingGem() && c.type!=C_Repairer && hotel.roomUnlocked(R_StockSoap) ) {
					// Count already damaged rooms
					var n = 0;
					for(r in hotel.getRoomsByType(R_Bedroom))
						if( r.damages>0 )
							n++;
					var many =
						hotel.level<=4 ? n>=1 :
						hotel.level<=6 ? n>=2 :
						hotel.level<=8 ? n>=3 :
						n>=5;

					// Damage based on happiness
					var h = c.getCappedHappiness();
					if( h<10 )
						applyRoomDamage(c.room, 2);
					else if( h<15 && rseed.random(100) < (many?50:80) )
						applyRoomDamage(c.room, 1);
					else if( h<25 && rseed.random(100) < (many?12:60) )
						applyRoomDamage(c.room, 1);
					else if( h<hotel.getMaxHappiness() && rseed.random(100) < (many?0:10) )
						applyRoomDamage(c.room, 1);
				}

			case InternalClientLock(t) :

			case InternalSetFlag(k,v) :
				applyEffect( HotelFlagSet(k,v) );

			case InternalRoomRepair(x,y) :
				applyEffect( RoomRepaired(x,y, 99) );


			case InternalRoomTrigger(x,y) :
				var r = hotel.getRoom(x,y);
				switch( r.type ) {
					case R_StockBeer, R_StockPaper, R_StockSoap, R_StockBoost :
						if( r.data<GameData.getStockMax(r.type,r.level) ) {
							applyEffect( StockAutoRefilled(x,y) );
							applyEffect( StockAdded(r.cx, r.cy, 1) );
						}
						checkStockRefills();

					default :
				}


			case InternalQuestRegen :
				if( hotel.countDailyQuests()<hotel.getMaxDailyQuests() )
					startDailyQuest();

			case InternalClientPerk(cid) :
				var c = hotel.getClient(cid);
				if( !c.done ) {
					if( c.hasPerk(Data.ClientPerkKind.Cannibal) ) {
						var n = hotel.getNeighbours(c);
						if( n.length>0 ) {
							var t = n[rseed.random(n.length)];
							applyEffect( ClientPerk(cid, Data.ClientPerkKind.Cannibal.toString(), t.id) );
							applyClientDeath(t);
							addHappiness(c, GameData.CANNIBAL_POWER, HM_Cannibalism, true);
							applyEffect( CheckMiniGame );
						}
						applyEffect( StartTask(InternalClientPerk(cid), DateTools.minutes(rseed.range(1,2))) );
					}

					if( c.hasPerk(Data.ClientPerkKind.PoringCannibal) ) {
						var n = hotel.getNeighbours(c, C_Liker);
						if( n.length>0 ) {
							var t = n[rseed.random(n.length)];
							applyEffect( ClientPerk(cid, Data.ClientPerkKind.Cannibal.toString(), t.id) );
							applyClientDeath(t);
							addHappiness(c, GameData.PORING_CANNIBAL_POWER, HM_Cannibalism, true);
							applyEffect( CheckMiniGame );
						}
						applyEffect( StartTask(InternalClientPerk(cid), DateTools.minutes(rseed.range(0.3,0.5))) );
					}
				}

			case InternalClientSpecialAction(cid) :
				var c = hotel.getClient(cid);
				if( c!=null && !c.done ) {
					var r = c.room;
					applyEffect( ClientSpecial(cid) );
					switch( c.type ) {
						case C_Bomb :
							var h = c.getCappedHappiness();
							if( h<=0 || h>GameData.getHappinessTrigger(C_Bomb, hotel) ) {
								applyRoomDamage(r, 2);
								applyClientDeath(c);
								applyEffect( CheckMiniGame );
							}

						default :
					}
				}


			case DoInstallClient(cid, x,y) :
				var c = hotel.getClient(cid);
				var r = hotel.getRoom(x,y);

				c.onInstall(hotel.lastEvent);
				applyEffect( ClientInstalled(cid, x,y) );
				applyEffect( StartTask(InternalCompleteClient(cid), c.stayDuration) );
				computeHappiness(c);

				var needs = c.getInstallNeeds();
				for(n in needs)
					for(i in 0...n.n) {
						var sr = getStockRooms(n.t)[0];
						if( sr!=null )
							applyEffect( StockMovedTo(sr.cx, sr.cy, r.cx, r.cy) );
						else {
							applyEffect( ServiceForced(c.id, n.t) );
							addHappiness(c, -2, HM_MissingStock(R_StockPaper), true);
						}
					}

				switch( c.type ) {
					case C_Repairer :
						var n = 0;
						for(r in hotel.rooms )
							if( r.damages>0 ) {
								addHappiness(c, r.damages, HM_DirtyRoom, true);
								applyEffect( RoomRepaired(r.cx, r.cy, r.damages) );
								if( r.working ) {
									completeTask( InternalUnsetWorking(r.cx,r.cy) );
									completeTask( InternalRoomRepair(r.cx,r.cy) );
								}
								n++;
							}

					case C_MoneyGiver :
						var n = 3;
						var all = hotel.clients.filter( function(c2) return !c2.done && !c2.isWaiting() && c2!=c );
						if( all.length>0 ) {
							var distrib = all.length>=n;
							for(i in 0...n) {
								var tc = distrib ? all.splice(rseed.random(all.length),1)[0] : all[rseed.random(all.length)];
								if( tc!=null )
									applyEffect( AddClientSaving(tc.id, 1) );
							}
						}

					default :
				}

				// Perks (effect on install)
				for( p in c.getPerks() )
					switch( p ) {
						case Data.ClientPerkKind.Vip :
						case Data.ClientPerkKind.Squatter :
						case Data.ClientPerkKind.Fast :
						case Data.ClientPerkKind.Sociable :
						case Data.ClientPerkKind.AntiSocial :
						case Data.ClientPerkKind.Annoying :
						case Data.ClientPerkKind.Depressive :
						case Data.ClientPerkKind.DoubleReward :
						case Data.ClientPerkKind.Aesthete :
						case Data.ClientPerkKind.DecoHater :
						case Data.ClientPerkKind.DecoDropper :
						case Data.ClientPerkKind.IMPOSSIBLE :

						case Data.ClientPerkKind.CaveMan :
							if( r.cy<0 )
								addHappiness(c, GameData.SPECIAL_REQUEST_BONUS, HM_PerkSpecialRequest, true);
							else
								addHappiness(c, GameData.SPECIAL_REQUEST_MALUS, HM_PerkSpecialRequest, true);

						case Data.ClientPerkKind.HighestRoom :
							var best = true;
							for(or in hotel.rooms)
								if( or.type==R_Bedroom && or.cy>r.cy ) {
									best = false;
									break;
								}
							if( best )
								addHappiness(c, GameData.SPECIAL_REQUEST_BONUS, HM_PerkSpecialRequest, true);
							else
								addHappiness(c, GameData.SPECIAL_REQUEST_MALUS, HM_PerkSpecialRequest, true);

						case Data.ClientPerkKind.GoldExplosion:
							for(r in hotel.rooms)
								if( r.type==R_Bedroom && !r.constructing )
									applyEffect( AddGift(r.cx, r.cy, I_Money(GameData.GOLD_EXPLOSION_MONEY)) );

						case Data.ClientPerkKind.Generous :
							applyEffect( ClientPerk(c.id, p.toString(), 0) );
							for(c2 in hotel.clients)
								if( c2!=c && !c2.done )
									applyEffect( AddClientSaving(c2.id, 1) );

						case Data.ClientPerkKind.Cannibal :
							applyEffect( StartTask( InternalClientPerk(c.id), DateTools.minutes(rseed.range(0.5,1.5)) ) );

						case Data.ClientPerkKind.PoringCannibal :
							applyEffect( StartTask( InternalClientPerk(c.id), DateTools.minutes(rseed.range(0.3,0.5)) ) );

						case Data.ClientPerkKind.RandomExplosions :
							var n = rseed.irange(3,4);
							var all = hotel.getRoomsByType(R_Bedroom);
							n = MLib.min(n, all.length-1);
							while( n>0 ) {
								var r = all.splice(rseed.random(all.length),1)[0];
								if( r.cx==c.room.cx && r.cy==c.room.cy )
									continue;
								applyEffect( ClientPerk(c.id, p.toString(), 0) );
								applyRoomDamage(r, 2, true);
								n--;
							}

						case Data.ClientPerkKind.FloorExplosion :
							for(r in hotel.rooms)
								if( r.type==R_Bedroom && r!=c.room && r.cy==c.room.cy )
									applyRoomDamage(r, 2, true);

						case Data.ClientPerkKind.GlobalExplosions :
							for(r in hotel.rooms)
								//if( r.type!=R_StockSoap && r.type!=R_StockBoost && r.type!=R_Lobby && r!=c.room )
								if( r.type==R_Bedroom && r!=c.room )
									applyRoomDamage(r, rseed.irange(1,2), true);

						case Data.ClientPerkKind.BeerMaster :
							var r = hotel.getRoomsByType(R_StockBeer)[0];
							if( r!=null ) {
								applyEffect( ClientPerk(c.id, p.toString(), 0) );
								applyBoost(r,true);
							}

						case Data.ClientPerkKind.PaperMaster :
							var r = hotel.getRoomsByType(R_StockPaper)[0];
							if( r!=null ) {
								applyEffect( ClientPerk(c.id, p.toString(), 0) );
								applyBoost(r,true);
							}

						case Data.ClientPerkKind.SuperBooster :
							applyEffect( ClientPerk(c.id, p.toString(), 0) );
							for(r in hotel.rooms)
								if( r.canBeBoosted() )
									applyBoost(r,true);

						case Data.ClientPerkKind.LaundryMaster :
							var r = hotel.getRoomsByType(R_Laundry)[0];
							if( r!=null ) {
								applyEffect( ClientPerk(c.id, p.toString(), 0) );
								applyBoost(r,true);
							}

						case Data.ClientPerkKind.Generator:
							applyEffect( ClientPerk(c.id, p.toString(), 0) );
							for( r in hotel.getRoomsByType(R_StockBoost) ) {
								applyEffect( RoomActivated(r.cx, r.cy) );
								for(i in r.data...GameData.getStockMax(r.type, r.level))
									applyEffect( StockAdded(r.cx, r.cy, 1) );
							}

						case Data.ClientPerkKind.StockThief :
							applyEffect( ClientPerk(c.id, p.toString()) );
							var n = 0;
							for(r in hotel.rooms)
								if( !r.constructing )
									switch( r.type ) {
										case R_StockBeer, R_StockPaper, R_StockSoap :
											for(i in 0...r.data)  {
												applyEffect( StockMovedTo(r.cx, r.cy, c.room.cx, c.room.cy, true) );
												n++;
											}


										default :
									}

							if( n>0 )
								addHappiness(c, n, HM_StockThief, true);

						case Data.ClientPerkKind.Alcoholic :
							applyEffect( ClientPerk(c.id, p.toString()) );
							for( r in hotel.getRoomsByType(R_StockBeer) )
								for(i in 0...r.data) {
									applyEffect( StockMovedTo(r.cx, r.cy, c.room.cx, c.room.cy) );
									addHappiness(c, GameData.ALCOHOLIC_POWER, HM_Alcoholic, true);
								}

						case Data.ClientPerkKind.PaperThief :
							applyEffect( ClientPerk(c.id, p.toString()) );
							for( r in hotel.getRoomsByType(R_StockPaper) ) {
								for(i in 0...r.data)
									applyEffect( StockMovedTo(r.cx, r.cy, c.room.cx, c.room.cy) );
								applyRoomDamage(r, 2, true);
							}

						case Data.ClientPerkKind.Dirty :

						case Data.ClientPerkKind.Thief :
							applyEffect( ClientPerk(c.id, p.toString()) );
							for(c2 in hotel.clients) {
								if( c!=c2 && c2.money>0 && !c2.done ) {
									if( c.money<10 ) {
										var n = c2.money;
										applyEffect( RemoveClientSaving(c2.id, n) );
										applyEffect( AddClientSaving(c.id, n) );
									}
								}
							}

						case Data.ClientPerkKind.RobinHood :
							var total = 0;
							for(c2 in hotel.clients) {
								if( c!=c2 && c2.money>0 && !c2.done ) {
									var n = c2.money;
									var sum = n*200;
									total+=sum;
									applyEffect( RemoveClientSaving(c2.id, n) );
									applyEffect( AddGift(c.room.cx, c.room.cy, I_Money(sum)) );
								}
							}
							if( total>0 )
								applyEffect( ClientPerk(c.id, p.toString(), total) );
					}

				for(c2 in hotel.clients)
					if( !c2.done && !c2.isWaiting() && c2!=c ) {
						if( c2.hasPerk(Data.ClientPerkKind.Sociable) )
							addHappiness(c2, GameData.SOCIABLE_POWER, HM_Sociable, true);

						if( c2.hasPerk(Data.ClientPerkKind.AntiSocial) )
							addHappiness(c2, GameData.ANTISOCIAL_POWER, HM_Antisocial, true);
					}

				applyEffect( CheckMiniGame );
				advanceQuest(Data.QObjectiveKind.InstallClient);
				hotel.addGoal("client");



			case DoSendClientToUtilityRoom(cid, x,y, data) :
				var c = hotel.getClient(cid);
				var r = hotel.getRoom(x,y);

				applyEffect( ClientSentToUtilityRoom(cid, x,y) );

				switch( r.type ) {
					case R_ClientRecycler :
						var i = switch( c.emit ) {
							case Heat : I_Heat;
							case Cold : I_Cold;
							case Noise : I_Noise;
							case Odor : I_Odor;
							case SunLight : I_Money(200);
						}
						applyClientDeath(c);
						applyEffect( AddGift(x,y, i) );
						applyWork(x,y, GameData.RECYCLER_DURATION);
						trackGameplay("room","recycleClient");
						hotel.addGoal("kill");

					case R_Trash :
						var m = Std.int(hotel.getMaxClientPayment(c.type)*0.5);
						if( m>0 )
							applyEffect( AddGift(x,y, I_Money(m)) );
						applyClientDeath(c);
						applyWork(x,y, r.hasBoost() ? GameData.TRASH_DURATION_BOOSTED : GameData.TRASH_DURATION);
						trackGameplay("room","trashClient");
						advanceQuest( Data.QObjectiveKind.Trash );
						hotel.addGoal("kill");

					case R_Bar :
						applyEffect( RemoveClientSaving(cid, 1) );
						var n = hotel.countRooms(R_Bar, false);
						addHappiness( c, GameData.BAR_POWER+n-1, HM_HotelServices, true );
						applyEffect( ClientFlagSet(cid, "hand_beer") );

						var sr = getStockRooms(R_StockBeer,1)[0];
						applyEffect( StockMovedTo(sr.cx, sr.cy, x,y) );

						applyWork(x,y, GameData.BAR_DURATION);
						advanceQuest( Data.QObjectiveKind.Beer );

						trackGameplay("room","sendToBar");
						hotel.addGoal("beer");

					default :
				}

				applyEffect( CheckMiniGame );



			case DoPickGift(cx,cy) :
				var r = hotel.getRoom(cx,cy);
				var i = r.gifts[0];
				applyEffect( GiftPickedUp(cx,cy,i) );
				applyItemPickUpEffect(i, cx,cy);



			//case InternalNewClient :
				//if( !hotel.waitingLineIsFull() )
					//applyEffect( ClientArrived(null) );


			case InternalUnsetConstructing(cx,cy) :
				applyEffect( SetConstructing(cx,cy, false) );
				var r = hotel.getRoom(cx,cy);
				switch( r.type ) {
					case R_Bedroom :

					case R_Library :
						if( !hotel.featureUnlocked("quests") )
							applyEffect( FeatureUnlocked("quests") );

						var n = hotel.countDailyQuests() + (hotel.hasTask(InternalQuestRegen)?1:0);
						if( n < hotel.getMaxDailyQuests() )
							startDailyQuest();

					default :
				}

			case InternalUnsetWorking(cx,cy) :
				applyEffect( SetWorking(cx,cy, false) );

			case DoUseItem(i) :
				switch( i ) {
					case I_LunchBoxAll, I_LunchBoxCusto :
						applyEffect( RemoveItem(i) );
						applyLunchBox(i);

					default :
				}

			case DoUseItemOnRoom(cx,cy, i) :
				var r = hotel.getRoom(cx,cy);
				var c = r.getClient();
				if( r.type==R_CustoRecycler ) {
					// Decoration recycling
					applyEffect( StockAdded(cx,cy, 1) );
					if( r.data>=GameData.CUSTO_RECYCLING_COST ) {
						while( r.data>0 )
							applyEffect( StockRemoved(cx,cy) );
						applyEffect( AddGift(cx,cy, I_LunchBoxCusto) );
					}
				}
				else {
					switch( i ) {
						case I_Cold, I_Heat, I_Noise, I_Odor, I_Light :
							var bonus = 1;
							applyEffect( ItemUsedOnRoom(cx,cy,i) );
							if( c!=null ) {
								var a = getEquipmentAffect(i);

								if( c.type==C_Emitter && ( c.emit==null || c.emit!=a ) ) {
									// Modify emit
									applyEffect( ClientAffectsChange(c.id, [a], [], a) );
									addHappiness(c, GameData.PRESENCE_OF_LIKE+bonus, HM_PresenceOfLike(a), true);

									var n = c.room.getSunlight();
									if( a==SunLight && n>0 )
										addHappiness(c, GameData.PRESENCE_OF_LIKE*n, HM_PresenceOfLike(a), true);

									for(nc in getNeighbours(cx,cy)) {
										if( nc.hasLike(a) )
											addHappiness( nc, GameData.PRESENCE_OF_LIKE, HM_PresenceOfLike(a), true );

										if( nc.hasDislike(a) )
											addHappiness( nc, GameData.PRESENCE_OF_DISLIKE, HM_PresenceOfDislike(a), true );

										if( nc.emit==a ) {
											var pow = nc.type==C_Plant ? 2 : 1;
											if( c.hasLike(a) )
												addHappiness( c, GameData.PRESENCE_OF_LIKE*pow, HM_PresenceOfLike(a), true );

											if( c.hasDislike(a) )
												addHappiness( c, GameData.PRESENCE_OF_DISLIKE*pow, HM_PresenceOfDislike(a), true );
										}
									}
								}
								else {
									// Apply bonus
									if( c.hasLike(a) )
										addHappiness(c, GameData.PRESENCE_OF_LIKE+bonus, HM_PresenceOfLike(a), true);
								}

								switch (i) {
									case I_Cold :
										applyEffect( ClientFlagSet(c.id, "hand_cold") );
										hotel.addGoal("cold");
										trackGameplay("item","use.cold");
									case I_Heat :
										applyEffect( ClientFlagSet(c.id, "hand_heat") );
										hotel.addGoal("heat");
										trackGameplay("item","use.heat");
									case I_Odor :
										applyEffect( ClientFlagSet(c.id, "hand_odor") );
										hotel.addGoal("odor");
										trackGameplay("item","use.odor");
									case I_Noise :
										applyEffect( ClientFlagSet(c.id, "hand_noise") );
										hotel.addGoal("noise");
										trackGameplay("item","use.noise");
									case I_Light :
										applyEffect( ClientFlagSet(c.id, "hand_light") );
										hotel.addGoal("light");
										trackGameplay("item","use.light");
									default :
								}
								trackGameplay("item","use");

								advanceQuest( Data.QObjectiveKind.UseItem, 1, i.getIndex() );
							}

						case I_Bath(f) :
							if( r.custom.bath!=-1 )
								applyEffect( AddItemFromRoom(cx,cy, I_Bath(r.custom.bath), 1) );
							applyEffect( ItemUsedOnRoom(cx,cy,i) );
							if( !hotel.customUnlocked(i) )
								applyEffect( CustoUnlocked(i) );
							if( c!=null )
								computeCustomizationHappiness(c, true, false);

						case I_Bed(f) :
							if( r.custom.bed!=-1 )
								applyEffect( AddItemFromRoom(cx,cy, I_Bed(r.custom.bed), 1) );
							applyEffect( ItemUsedOnRoom(cx,cy,i) );
							if( !hotel.customUnlocked(i) )
								applyEffect( CustoUnlocked(i) );
							if( c!=null )
								computeCustomizationHappiness(c, true, false);

						case I_Ceil(f) :
							if( r.custom.ceil!=-1 )
								applyEffect( AddItemFromRoom(cx,cy, I_Ceil(r.custom.ceil), 1) );
							applyEffect( ItemUsedOnRoom(cx,cy,i) );
							if( !hotel.customUnlocked(i) )
								applyEffect( CustoUnlocked(i) );
							if( c!=null )
								computeCustomizationHappiness(c, true, false);

						case I_Furn(f) :
							if( r.custom.furn!=-1 )
								applyEffect( AddItemFromRoom(cx,cy, I_Furn(r.custom.furn), 1) );
							applyEffect( ItemUsedOnRoom(cx,cy,i) );
							if( !hotel.customUnlocked(i) )
								applyEffect( CustoUnlocked(i) );
							if( c!=null )
								computeCustomizationHappiness(c, true, false);

						case I_Wall(f) :
							if( r.custom.wall!=-1 )
								applyEffect( AddItemFromRoom(cx,cy, I_Wall(r.custom.wall), 1) );
							applyEffect( ItemUsedOnRoom(cx,cy,i) );
							if( !hotel.customUnlocked(i) )
								applyEffect( CustoUnlocked(i) );
							if( c!=null )
								computeCustomizationHappiness(c, true, false);

						case I_Color(id) :
							if( r.custom.color!="raw" && DataTools.getWallColor(r.custom.color)!=null )
								applyEffect( AddItemFromRoom(cx,cy, I_Color(r.custom.color), 1) );
							applyEffect( ItemUsedOnRoom(cx,cy,i) );
							if( !hotel.customUnlocked(i) )
								applyEffect( CustoUnlocked(i) );
							if( c!=null )
								computeCustomizationHappiness(c, true, false);

						case I_Texture(f) :
							if( r.custom.texture!=-1 && DataTools.getWallTexture(r.custom.texture)!=null )
								applyEffect( AddItemFromRoom(cx,cy, I_Texture(r.custom.texture), 1) );
							applyEffect( ItemUsedOnRoom(cx,cy,i) );
							if( !hotel.customUnlocked(i) )
								applyEffect( CustoUnlocked(i) );
							if( c!=null )
								computeCustomizationHappiness(c, true, false);

						case I_Money(_), I_Gem, I_LunchBoxAll, I_LunchBoxCusto, I_EventGift(_) :
					}
				}

				applyEffect( RemoveItem(i) );


			//case DoRemoveEquipment(cx,cy, i) :
				//applyEffect( RemoveEquipment(cx,cy, i) );
				//applyEffect( AddItemFromRoom(cx,cy, i, 1) );
				////applyHappinessUpdate();


			case DoService(cid) :
				var c = hotel.getClient(cid);
				switch( c.serviceType ) {
					case R_Laundry :
						var r = getFreeServiceRoom(R_Laundry);

						applyEffect( ServiceDone(cid, r.cx, r.cy, c.serviceType) );

						var h = hotel.getClient(cid).getHappiness();
						var m = GameData.getLaundryPayment(h, hotel.getMaxHappiness());
						applyMoneyGain( c, m, h>=8 );
						//applyEffect( AddMoneyFromClient(cid, m, h>=8) );

						applyWork(r.cx, r.cy, r.hasBoost() ? GameData.LAUNDRY_DURATION_BOOSTED : GameData.LAUNDRY_DURATION);
						advanceQuest( Data.QObjectiveKind.Laundry );
						trackGameplay("service","laundry");
						hotel.addGoal("laundry");

					case R_StockPaper :
						addHappiness(c, 1, HM_HotelServices, true);
						applyStockConsumption(c.serviceType, 1, c.room);
						applyEffect( ServiceDone(cid, c.room.cx, c.room.cy, c.serviceType) );
						trackGameplay("service","paper");

					case R_StockSoap :
						addHappiness(c, 1, HM_HotelServices, true);
						applyStockConsumption(c.serviceType, 1, c.room);
						applyEffect( ServiceDone(cid, c.room.cx, c.room.cy, c.serviceType) );
						trackGameplay("service","soap");

					default :
				}


			case DoMessagesActions(a) :
				var money = 0;
				for(m in a) {
					switch( m ) {
						case M_Visit(_) :
							money+=GameData.SOCIAL_GOLD_PER_VISITOR;

						case M_FriendRequest(_) :

						//case M_Rate :
					}
					applyEffect( MessageDiscarded(m) );
				}
				if( money>0 )
					applyMoneyGain( money );
					//applyEffect( AddMoney(money) );

		}

		checkStockRefills();
		checkSpecialClientEffects();
		checkMaxedClients();
		checkQuests();
	}


	function checkMaxedClients() {
		for(c in hotel.clients)
			if( !c.isWaiting() && !c.done && c.happinessMaxed() ) {
				applyEffect( ClientMaxHappiness(c.id) );
				applyEffect( ClientFlagSet(c.id, "maxed") );
				//applyEffect( AddGift(c.room.cx, c.room.cy, I_Money(100)) );
				completeTask( InternalCompleteClient(c.id) );
				if( c.type==C_Inspector && !c.hasPerk(Data.ClientPerkKind.IMPOSSIBLE) ) {
					applyEffect( BossResult(true) );
					applyLevelUp();
					applyEffect(BossCooldownReset(true));
				}
				if( c.isVip() )
					advanceQuest( Data.QObjectiveKind.Vip );

				advanceQuest( Data.QObjectiveKind.MaxedHappiness);
				hotel.addGoal("maxed");
			}
	}


	function checkStockRefills() {
		for(r in hotel.rooms) {
			if( r.isDamaged() )
				continue;

			switch( r.type ) {
				case R_StockBeer, R_StockPaper, R_StockSoap, R_StockBoost :
					var hasTask = hotel.hasTask( InternalRoomTrigger(r.cx, r.cy) );
					var max = GameData.getStockMax(r.type, r.level);
					if( r.data<max && !hasTask )
						applyEffect( StartTask(InternalRoomTrigger(r.cx, r.cy), GameData.getStockRefillDuration(r.type, r.hasBoost())) );
					else if( r.data>=max && hasTask )
						applyEffect( RemoveTask(InternalRoomTrigger(r.cx, r.cy)) );

				default :
			}
		}
	}


	function checkQuests() {
		if( !hotel.featureUnlocked("quests") )
			return;

		// Auto start base quest
		var q = Data.QuestKind.first;
		if( !hotel.hasQuest(q) && !hotel.hasDoneQuestOnce(q) )
			applyEffect( QuestStarted(q.toString()) );
		//for(q in Data.Quest.all)
			//if( q.base && !hotel.hasQuest(q.id) && !hotel.hasDoneQuestOnce(q.id) )
				//applyEffect( QuestStarted(q.id.toString()) );


		for( q in hotel.curQuests.copy() ) {
			// Kill invalid quests
			var data = DataTools.getQuest(q.id);
			if( data==null )
				applyEffect( QuestCancelled(q.id) );
			else {
				// Cap objective counter
				if( q.ocount>data.ocount ) {
					applyEffect( QuestCancelled(q.id) );
					applyEffect( QuestStarted(q.id) );
				}
			}
		}

		// Check completed quests
		var dailies = 0;
		for(q in hotel.curQuests) {
			var qdata = DataTools.getQuest(q.id);

			if( DataTools.isDaily(q.id) )
				dailies++;

			// Verify objectives
			var done = switch( qdata.objectiveId ) {
				case Data.QObjectiveKind.Bedroom :
					hotel.countRooms(R_Bedroom, false) >= q.ocount;

				case Data.QObjectiveKind.ExactHappiness :
					var n = 0;
					for(c in hotel.clients)
						if( !c.isWaiting() && c.getHappiness()==q.oparam )
							n++;
					n>=q.ocount;

				case Data.QObjectiveKind.HappinessLine :
					var all = hotel.clients.filter( function(c) return c.getHappiness()==q.oparam );
					if( all.length<q.ocount )
						false;
					else {
						var found = false;
						for(c1 in all) {
							var n = 0;
							for(c2 in all)
								if( c1.room.cy==c2.room.cy )
									n++;
							if( n>=q.ocount ) {
								found = true;
								break;
							}
						}
						found;
					}

				case Data.QObjectiveKind.HappinessColumn :
					var all = hotel.clients.filter( function(c) return c.getHappiness()==q.oparam );
					if( all.length<q.ocount )
						false;
					else {
						var found = false;
						for(c1 in all) {
							var n = 0;
							for(c2 in all)
								if( c1.room.cx==c2.room.cx )
									n++;
							if( n>=q.ocount ) {
								found = true;
								break;
							}
						}
						found;
					}

				case Data.QObjectiveKind.MinHappiness :
					var n = 0;
					for(c in hotel.clients)
						if( !c.isWaiting() && c.getHappiness()>=q.oparam )
							n++;
					n>=q.ocount;

				case Data.QObjectiveKind.MaxedHappiness :
					var n = 0;
					for(c in hotel.clients)
						if( !c.isWaiting() && !c.done && c.getHappiness()>=hotel.getMaxHappiness() )
							n++;
					n>=q.ocount;

				default :
					q.ocount<=0;
			}

			if( done ) {
				// Quest complete!
				completeQuest(q, qdata);
			}
		}

		if( hotel.canHaveDailyQuests() ) {
			var hasRegenTask = hotel.hasTask(InternalQuestRegen);
			var max = hotel.getMaxDailyQuests();
			if( dailies<max && !hasRegenTask )
				applyEffect( StartTask(InternalQuestRegen, GameData.DAILY_QUEST_REGEN) );
			if( dailies>=max && hasRegenTask )
				applyEffect( RemoveTask(InternalQuestRegen) );
		}

		#if debug
		//forceQuest(Data.QuestKind.line0);
		//forceQuest(Data.QuestKind.minHappiness);
		//forceQuest(Data.QuestKind.column0);
		//forceQuest(Data.QuestKind.exact0);
		//forceQuest(Data.QuestKind.combo0);
		#end
	}

	function completeQuest(q:QuestState, qdata:Data.Quest) {
		if( !hotel.featureUnlocked("quests") )
			return;

		applyEffect( QuestDone(q.id, q.oparam) );
		if( qdata.rewards.length==0 )
			applyEffect( AddItem(I_LunchBoxAll,1) );
		else
			for(r in qdata.rewards) {
				var n = MLib.max(1, r.count);
				switch( r.rewardId ) {
					case Data.QRewardKind.LunchBoxAll : applyEffect( AddItem(I_LunchBoxAll,n) );
					case Data.QRewardKind.LunchBoxCusto : applyEffect( AddItem(I_LunchBoxCusto,n) );
					case Data.QRewardKind.Gem : applyEffect( AddGems(n, true) );
					case Data.QRewardKind.Gold : applyMoneyGain(n);
					//case Data.QRewardKind.Gold : applyEffect( AddMoney(n) );
					case Data.QRewardKind.EnableDailyQuests :
						applyEffect( HotelFlagSet("dailies", true) );
						//while( hotel.countDailyQuests()<hotel.getDailyQuestMax() )
							//startDailyQuest();
				}
			}

		for(next in qdata.nextQuests)
			applyEffect( QuestStarted(next.nextId.toString()) );

		if( DataTools.isDaily(qdata.id) ) {
			advanceQuest( Data.QObjectiveKind.CompleteDailyQuestBugged );
			checkQuests();
		}

		hotel.addGoal("quest");
	}

	#if debug
	function forceQuest(id:Data.QuestKind) {
		if( !hotel.hasQuest(id) )
			applyEffect( QuestStarted(id.toString()) );
	}
	#end


	function startDailyQuest(?exceptId:String) {
		if( !hotel.featureUnlocked("quests") )
			return;

		var pool = new mt.RandList(rseed.random);

		var all = Data.Quest.all.toArrayCopy().filter( function(q) return q.minLevel==null || hotel.level>=q.minLevel );

		if( hotel.getMaxDailyQuests()==1 ) {
			// Pick any quest
			for(q in all)
				if( !hotel.hasQuestObjective(q.objectiveId) )
					pool.add(q, DataTools.getRarityValue(q.rarityId));
		}
		else {
			// Prioritize at least 1 puzzle friendly
			if( hotel.countPuzzleFriendly()==0 ) {
				// Pick a puzzle friendly quest
				for(q in all)
					if( q.puzzleFriendly && !hotel.hasQuestObjective(q.objectiveId) )
						pool.add(q, DataTools.getRarityValue(q.rarityId));
			}
			else {
				// Pick a random daily quest
				for(q in all)
					if( !q.puzzleFriendly && !hotel.hasQuestObjective(q.objectiveId) )
						pool.add(q, DataTools.getRarityValue(q.rarityId));
			}
		}

		if( pool.length()>0 ) {
			var q = pool.draw();
			while( exceptId!=null && pool.length()>1 && q.id.toString()==exceptId )
				q = pool.draw();
			applyEffect( QuestStarted(q.id.toString()) );
		}
	}



	function checkSpecialClientEffects() {
		var repeat = false;

		for( c in hotel.clients.copy() ) {
			if( c.isWaiting() || c.done )
				continue;

			switch( c.type ) {
				case C_JoyBomb :
					if( !c.hasFlag("trigger") && c.getCappedHappiness()>=GameData.getHappinessTrigger(c.type,hotel) ) {
						applyEffect( ClientFlagSet(c.id, "trigger") );
						for(c2 in hotel.clients)
							if( c2!=c && !c2.done && !c2.isWaiting() ) {
								addHappiness(c2, 1, HM_JoyBomb, true);
								repeat = true;
							}
					}

				case C_Gem :
					if( !c.skippedUsingGem() && !c.hasFlag("trigger") && c.getCappedHappiness()>=GameData.getHappinessTrigger(c.type,hotel) ) {
						applyEffect( ClientFlagSet(c.id, "trigger") );
						applyEffect( ClientSpecial(c.id) );
						applyEffect( AddGift(c.room.cx, c.room.cy, I_Gem) );
					}

				case C_Gifter :
					if( !c.hasFlag("trigger") && c.getCappedHappiness()>=GameData.getHappinessTrigger(c.type,hotel) ) {
						applyEffect( ClientFlagSet(c.id, "trigger") );
						applyEffect( ClientSpecial(c.id) );

						var rlist = new mt.RandList(rseed.random);
						if( hotel.featureUnlocked("cold") )
							rlist.add( I_Cold );
						rlist.add( I_Heat );
						rlist.add( I_Noise );
						rlist.add( I_Odor );
						applyEffect( AddGift(c.room.cx, c.room.cy, rlist.draw()) );
					}

				case C_MobSpawner :
					if( !c.hasFlag("trigger") && c.getCappedHappiness()>=GameData.getHappinessTrigger(c.type,hotel) ) {
						applyEffect( ClientFlagSet(c.id, "trigger") );
						applyEffect( ClientSpecial(c.id) );
						applyEffect( ClientArrived(C_Spawnling) );
					}

				case C_Rich:
					if( !c.hasFlag("trigger") && c.getCappedHappiness()>=GameData.getHappinessTrigger(c.type,hotel) ) {
						applyEffect( ClientFlagSet(c.id, "trigger") );
						applyEffect( ClientSpecial(c.id) );
						applyEffect( AddGift(c.room.cx, c.room.cy, I_Money(GameData.RICH_MONEY)) );
					}

				case C_Vampire:
					if( !c.hasFlag("trigger") && c.getCappedHappiness()>=GameData.getHappinessTrigger(c.type,hotel) ) {
						applyEffect( ClientFlagSet(c.id, "trigger") );
						applyEffect( ClientSpecial(c.id) );
						applyEffect( AddGift(c.room.cx, c.room.cy, I_Light) );
					}

				case C_Spawnling:
					if( !c.hasFlag("trigger") && c.getCappedHappiness()>=GameData.getHappinessTrigger(c.type,hotel) ) {
						applyEffect( ClientFlagSet(c.id, "trigger") );
						applyEffect( ClientSpecial(c.id) );
						applyEffect( AddGift(c.room.cx, c.room.cy, I_Money(GameData.SPAWNLING_MONEY)) );
					}

				case C_Disliker:
					if( !c.hasFlag("trigger") && c.hasHappinessMod(HM_PresenceOfDislike(c.dislikes[0])) ) {
						var r = c.room;
						applyEffect( ClientFlagSet(c.id, "trigger") );
						applyEffect( ClientSpecial(c.id) );
						applyRoomDamage(r, 2);
						applyEffect( AddGift(r.cx, r.cy, I_Money(1)) );
						applyClientDeath(c);
						applyEffect( CheckMiniGame );
					}

				case C_Bomb :
					var h = c.getCappedHappiness();
					var max = GameData.getHappinessTrigger(C_Bomb, hotel);
					// Ignition!
					if( !c.done && !c.skippedUsingGem() && (h<=0 || h>max) && !hotel.hasTask(InternalClientSpecialAction(c.id)) )
						applyEffect( StartTask( InternalClientSpecialAction(c.id), GameData.EXPLOSION_WARNING ) );

					// Calm down
					if( ( c.done || h>0 && h<=max ) && hotel.hasTask(InternalClientSpecialAction(c.id)) )
						applyEffect( RemoveTask( InternalClientSpecialAction(c.id) ) );

				default :
			}
		}

		if( repeat )
			checkSpecialClientEffects();
	}

	function completeTask(c:GameCommand) {
		if( hotel.hasTask(c) ) {
			applyEffect( RemoveTask(c) );
			applyCommand(c, false);
		}
	}

	function advanceQuest(oid:Data.QObjectiveKind, ?n=1, ?param=-1) {
		if( !hotel.featureUnlocked("quests") )
			return;

		var oid = oid.toString();
		for(q in hotel.curQuests)
			if( DataTools.getQuest(q.id).objectiveId.toString()==oid && q.ocount>0 && q.oparam==param )
				applyEffect( QuestAdvanced(q.id, n) );
	}


	function getRandomCustomItem(?cat:Item, ?excludeUnlockeds=false) : Null<Item> {
		var rlist : RandList<Item> = new mt.RandList(rseed.random);

		if( cat==null ) {
			var allCats = new mt.RandList(rseed.random);
			allCats.add(I_Bath(0),		8);
			allCats.add(I_Bed(0),		10);
			allCats.add(I_Ceil(0),		5);
			allCats.add(I_Color(""),	10);
			allCats.add(I_Texture(0),	10);
			allCats.add(I_Furn(0),		10);
			allCats.add(I_Wall(0),		10);
			cat = allCats.draw();
		}

		switch( cat ) {
			case I_Bed(_) :
				for(f in 0...Data.Bed.all.length)
					if( !excludeUnlockeds || !hotel.customUnlocked(I_Bed(f)) )
						rlist.add( I_Bed(f), DataTools.getRarityValue( Data.Bed.all[f].rarityId ));

			case I_Bath(_) :
				for(f in 0...Data.Bath.all.length)
					if( !excludeUnlockeds || !hotel.customUnlocked(I_Bath(f)) )
						rlist.add( I_Bath(f), DataTools.getRarityValue( Data.Bath.all[f].rarityId ));

			case I_Ceil(_) :
				for(f in 0...Data.Ceil.all.length)
					if( !excludeUnlockeds || !hotel.customUnlocked(I_Ceil(f)) )
						rlist.add( I_Ceil(f), DataTools.getRarityValue( Data.Ceil.all[f].rarityId ));

			case I_Furn(_) :
				for(f in 0...Data.Furn.all.length)
					if( !excludeUnlockeds || !hotel.customUnlocked(I_Furn(f)) )
						rlist.add( I_Furn(f), DataTools.getRarityValue( Data.Furn.all[f].rarityId ));

			case I_Wall(_) :
				for(f in 0...Data.WallFurn.all.length)
					if( !excludeUnlockeds || !hotel.customUnlocked(I_Wall(f)) )
						rlist.add( I_Wall(f), DataTools.getRarityValue( Data.WallFurn.all[f].rarityId ));


			case I_Texture(_) :
				for(f in 0...Data.WallPaper.all.length)
					if( !excludeUnlockeds || !hotel.customUnlocked(I_Texture(f)) )
						rlist.add( I_Texture(f), DataTools.getRarityValue( Data.WallPaper.all[f].rarityId ));

			case I_Color(_) :
				for(i in 0...Data.WallColor.all.length) {
					var c = Data.WallColor.all[i];
					if( !excludeUnlockeds || !hotel.customUnlocked(I_Color(c.id.toString())) )
						rlist.add( I_Color(c.id.toString()), DataTools.getRarityValue(c.rarityId));
				}

			default :
				throw "unknown cat "+cat;
		}

		return rlist.length()==0 ? null : rlist.draw();
	}


	function applyLunchBox(i:Item) {
		var ic = getRandomCustomItem();
		var rlist = new mt.RandList(rseed.random);

		// Decoration item
		if( ic!=null )
			rlist.add(function() {
				applyEffect( LunchBoxOpened(ic, !hotel.customUnlocked(ic)) );
				applyEffect( AddItem(ic, 1) );
				if( !hotel.customUnlocked(ic) )
					applyEffect( CustoUnlocked(ic) );
			},30);

		// Gold
		if( ic==null || i==I_LunchBoxAll )
			rlist.add( function() {
				applyEffect( LunchBoxOpened(I_Money(GameData.LUNCHBOX_GOLD), false) );
				applyMoneyGain( GameData.LUNCHBOX_GOLD );
				//applyEffect( AddMoney(GameData.LUNCHBOX_GOLD) );
			}, 17);

		// Gem
		if( i==I_LunchBoxAll )
			rlist.add( function() {
				applyEffect( LunchBoxOpened(I_Gem,false) );
				applyEffect( AddGems(1,false) );
			}, 1);

		rlist.draw()();
	}

	function applyClientSkip(c:SClient) {
		var cid = c.id;
		applyEffect( ClientSkipped(cid) );
		applyEffect( ClientFlagSet(cid, "skipGem") );

		#if debug
		//applyRoomDamage(c.room, 2);
		#end

		checkSpecialClientEffects();
		completeTask( InternalCompleteClient(cid) );
		validateClient(cid);
		hotel.addGoal("skip");

	}

	function applyClientDeath(c:SClient) {
		var t = c.type;
		applyEffect( ClientDied(c.id) );

		switch( t ) {
			case C_Inspector :
				applyEffect( BossDied );
				applyEffect( BossCooldownReset(false) );

			default :
		}
	}

	function applyPrint(str:Dynamic) {
		applyEffect( Print(Std.string(str)) );
	}

	function applyStockConsumption(st:RoomType, n:Int, to:SRoom) {
		var stockRooms = getStockRooms(st, n);
		if( stockRooms.length==0 )
			return false;

		var base = n;

		while( n>0 && stockRooms.length>0 ) {
			var rs = stockRooms[0];
			applyEffect( StockMovedTo(rs.cx, rs.cy, to.cx, to.cy) );
			if( rs.data<=0 )
				stockRooms.shift();
			n--;
		}

		switch( st ) {
			case R_StockPaper : advanceQuest( Data.QObjectiveKind.Paper, base );
			case R_StockSoap : advanceQuest( Data.QObjectiveKind.Soap, base );
			case R_StockBeer : advanceQuest( Data.QObjectiveKind.Beer, base );
			default :
		}

		return n==0;
	}

	function applyClearCustomizations(r:SRoom, ?i:Item) {
		if( r.countCustomizations()==0 )
			return;

		var x = r.cx;
		var y = r.cy;
		var f = 0;

		if( i==null || i.getIndex()==I_Bath(-1).getIndex() ) {
			f = r.custom.bath;
			if( f>=0 ) applyEffect( AddItemFromRoom(x,y, I_Bath(f), 1) );
		}

		if( i==null || i.getIndex()==I_Bed(-1).getIndex() ) {
			f = r.custom.bed;
			if( f>=0 ) applyEffect( AddItemFromRoom(x,y, I_Bed(f), 1) );
		}

		if( i==null || i.getIndex()==I_Ceil(-1).getIndex() ) {
			f = r.custom.ceil;
			if( f>=0 ) applyEffect( AddItemFromRoom(x,y, I_Ceil(f), 1) );
		}

		if( i==null || i.getIndex()==I_Furn(-1).getIndex() ) {
			f = r.custom.furn;
			if( f>=0 ) applyEffect( AddItemFromRoom(x,y, I_Furn(f), 1) );
		}

		if( i==null || i.getIndex()==I_Wall(-1).getIndex() ) {
			f = r.custom.wall;
			if( f>=0 ) applyEffect( AddItemFromRoom(x,y, I_Wall(f), 1) );
		}

		if( i==null || i.getIndex()==I_Color(null).getIndex() ) {
			var id = r.custom.color;
			if( id!="raw" ) {
				if( GameData.getItemCost(I_Color(id)).n>0 )
					applyEffect( AddItemFromRoom(x,y, I_Color(id), 1) );
			}
		}

		if( i==null || i.getIndex()==I_Texture(-1).getIndex() ) {
			f = r.custom.texture;
			if( f>=0 ) {
				if( GameData.getItemCost(I_Texture(f)).n>0 )
					applyEffect( AddItemFromRoom(x,y, I_Texture(f), 1) );
			}
		}

		applyEffect( CustomizationCleared(x,y, i) );
	}

	function applyRoomDestruction(r:SRoom) {
		var m = GameData.getRoomResellValue( r, hotel.countRooms(r.type), r.constructing );

		applyClearCustomizations(r);
		applyEffect( DestroyRoom(r.cx, r.cy) );

		if( m>0 )
			applyMoneyGainWithoutBonus(m);
			//applyEffect( AddMoney(m) );
		trackGameplay("room","destroy");
	}


	function applyRoomDamage(r:SRoom, d:Int, ?explode=false) {
		if( hotel.featureUnlocked("bigDamages") )
			d = MLib.min(2-r.damages, d);
		else
			d = MLib.min(1-r.damages, d);

		if( d>0 ) {
			applyEffect( RoomDamaged(r.cx, r.cy, d, explode) );

			completeTask( InternalUnsetWorking(r.cx, r.cy) );
			applyEffect( RemoveTask(InternalRoomTrigger(r.cx, r.cy)) );
			applyEffect( RemoveTask(InternalUnsetWorking(r.cx, r.cy)) );
			applyEffect( RemoveTask(InternalRoomTrigger(r.cx, r.cy)) );

			var c = r.getClient();
			if( c!=null && !c.done && !c.isWaiting() && d>0 ) {
				if( !c.hasPerk(Data.ClientPerkKind.Dirty) && c.type!=C_Repairer )
					addHappiness(c, GameData.PRESENCE_OF_DIRT*d, HM_DirtyRoom, true);
			}
		}
	}

	function applyWork(cx,cy, d:Float) {
		if( d>0 ) {
			applyEffect( SetWorking(cx, cy, true) );
			applyEffect( StartTask(InternalUnsetWorking(cx, cy), d) );
		}
	}

	function applyFeatureUnlock(id:String) {
		applyEffect( HotelFlagSet("f_"+id, true) );
		applyEffect( FeatureUnlocked(id) );
	}

	function applyItemPickUpEffect(i:Item, cx:Int, cy:Int) {
		switch( i ) {
			case I_Cold, I_Heat, I_Noise, I_Odor, I_Light :
				applyEffect( AddItemFromRoom(cx,cy, i, 1) );

			case I_Money(n) :
				applyMoneyGain(hotel.getRoom(cx,cy), n, n>=500);
				//applyEffect( AddMoneyFromRoom(cx,cy, n, n>=500) );

			case I_LunchBoxAll, I_LunchBoxCusto :
				applyLunchBox(i);

			case I_Gem :
				applyEffect( AddGems(1, false) );

			case I_EventGift(i) :
				applyEffect( EventGiftOpened(i) );
				applyItemPickUpEffect(i, cx,cy);

			case I_Bath(_), I_Bed(_), I_Ceil(_), I_Furn(_), I_Wall(_), I_Color(_), I_Texture(_) :
				if( !hotel.customUnlocked(i) )
					applyEffect( CustoUnlocked(i) );
				applyEffect( AddItemFromRoom(cx,cy, i, 1) );
		}
	}

	function applyMoneyGainWithoutBonus(?c:SClient, ?r:SRoom, n:Int, ?important=false) {
		if( c!=null )
			applyEffect( AddMoneyFromClient(c.id, n, important) );
		else if( r!=null )
			applyEffect( AddMoneyFromRoom(r.cx, r.cy, n, important) );
		else
			applyEffect( AddMoney(n) );
	}

	function applyMoneyGain(?c:SClient, ?r:SRoom, n:Int, ?important=false) {
		applyMoneyGainWithoutBonus(c,r,n,important);

		// Bank bonus
		if( n>0 && ( c!=null || r!=null && r.type!=R_Bank ) )
			for(r in hotel.rooms)
				if( r.type==R_Bank ) {
					var m = Std.int( n * GameData.BANK_BONUS*(r.hasBoost()?2:1)/100 );
					if( m>0 ) {
						applyEffect( AddGift(r.cx, r.cy, I_Money(m)) );
						break;
					}
				}
	}

	function applyEffect(e:GameEffect) {
		hotel.applyEffect(e);
		lastEffects.push(e);
	}


	function applyBoost(r:SRoom, ?long=false) {
		var x = r.cx;
		var y = r.cy;

		applyEffect( RoomBoosted(x,y) );

		switch( r.type ) {
			case R_StockBeer, R_StockPaper, R_StockSoap :
				applyEffect( RemoveTask(InternalRoomTrigger(x,y)) );

			default :
		}

		if( r.working ) {
			applyEffect( RoomWorkSkipped(x,y) );
			completeTask( InternalUnsetWorking(x, y) );
		}

		applyEffect( HotelFlagSet("boost_"+x+"_"+y, true) );
		applyEffect( StartTask(InternalSetFlag("boost_"+x+"_"+y, false), GameData.BOOST_DURATION * (long?3:1)) );
	}


	//function scheduleTaskMs(c:GameCommand, delayMs:Float) {
		//applyEffect( StartTask(c, hotel.lastNow+delayMs) );
	//}


	function validateClient(cid:Int) {
		var c = hotel.getClient(cid);
		var h = c.getHappiness();
		var ch = c.getCappedHappiness();
		var x = c.room.cx;
		var y = c.room.cy;

		applyEffect( ClientValidated(cid, h) );

		// Bomb
		if( c.type==C_Bomb && h>=GameData.getHappinessTrigger(c.type, hotel) )
			applyEffect( AddGift(c.room.cx, c.room.cy, I_Money(1250)) );

		// Money
		var v = c.skippedUsingGem() ? hotel.getMaxClientPayment(c.type) : hotel.getClientPayment(c);
		applyMoneyGain( c.room, v, c.skippedUsingGem() || ch>=hotel.getMaxHappiness()*0.5 );
		//applyEffect( AddMoneyFromRoom(c.room.cx, c.room.cy, v, c.skippedUsingGem() || ch>=hotel.getMaxHappiness()*0.5) );
		applyEffect( AddStat("cincome", v) );

		// Halloween
		if( c.type==C_Halloween && c.happinessMaxed() ) {
			var rlist = new mt.RandList(rseed.random);
			rlist.add( I_Money(2000) );
			applyEffect( AddGift(c.room.cx, c.room.cy, I_EventGift(rlist.draw())) );
		}

		// Christmas
		if( c.type==C_Christmas && c.happinessMaxed() ) {
			var rlist = new mt.RandList(rseed.random);
			rlist.add( I_Texture(35), 8 );
			rlist.add( I_Bed(26), 10 );
			rlist.add( I_Bath(15), 7 );
			rlist.add( I_Ceil(13), 10 );
			rlist.add( I_Furn(27), 8 );
			rlist.add( I_Wall(23), 10 );
			//#if debug
			//for(i in rlist.getItems())
				//applyEffect( AddGift(c.room.cx, c.room.cy, I_EventGift(i)) );
			//#else
			applyEffect( AddGift(c.room.cx, c.room.cy, I_EventGift(rlist.draw())) );
			//#end
		}

		// VIP reward
		if( c.isVip() && c.happinessMaxed() ) {
			if( hotel.featureUnlocked("custom") ) {
				applyEffect( AddGift(x,y, I_LunchBoxAll) );
				if( c.hasPerk(Data.ClientPerkKind.DecoDropper) )
					applyEffect( AddGift(x,y, I_LunchBoxAll) );
			}
			var m = GameData.VIP_MONEY;
			if( c.hasPerk(Data.ClientPerkKind.DoubleReward) )
				m*=2;
			applyEffect( AddGift(x,y, I_Money(m)) );
		}

		if( c.type==C_Inspector && c.happinessMaxed() ) {
			if( hotel.featureUnlocked("custom") )
				applyEffect( AddGift(x,y, I_LunchBoxCusto) );

			for( i in 0...2 )
				applyEffect( AddGift(c.room.cx, c.room.cy, I_Gem) );
		}

		if( h<=0 )
			hotel.addGoal("furious");

		// Boss cooldown
		if( c.type==C_Inspector && !c.happinessMaxed() ) {
			applyEffect( BossResult(false) );
			applyEffect( BossCooldownReset(false) );
		}

		if( c.type!=C_Inspector )
			applyBossCdDec();

		// Clean up
		applyEffect( ClientLeft(cid) );
		applyEffect( CheckMiniGame );

		// Boss arrival!
		if( hotel.inspectorReady() && !hotel.hasClient(C_Inspector) ) {
			var i = DataTools.getBoss(hotel.level);
			if( i.perk==null || i.perk.id!=Data.ClientPerkKind.IMPOSSIBLE ) {
				applyEffect(ClientArrived(C_Inspector));
				applyEffect(BossArrived);
			}
		}
	}


	function applyBossCdDec() {
		for( c in hotel.clients )
			if( c.type==C_Inspector && !c.done )
				return;

		applyEffect( BossCooldownDec );
	}


	function applyLevelUp() {
		applyEffect( LevelUp );

		applyEffect( RegenClientDeck );

		for( id in GameData.FEATURES.keys() )
			if( !hotel.featureUnlocked(id) && GameData.FEATURES.get(id)!=0 && hotel.level>=GameData.FEATURES.get(id) ) {
				applyFeatureUnlock(id);
			}

		for(t in Type.getEnumConstructs(ClientType).map(function(k) return Type.createEnum(ClientType,k)) )
			if( !GameData.clientUnlocked(hotel.level-1, t) && GameData.clientUnlocked(hotel.level, t) )
				applyEffect( ClientArrived(t) );
	}


	function addHappiness(c:SClient, n:Int, r:HappinessMod, notifyChange:Bool, ?notifyPermanentAffect=true) {
		if( n==0 )
			return;

		// Liker bonus
		switch( c.type ) {
			case C_Liker :
				if( r.getIndex()==HM_PresenceOfLike(null).getIndex() )
					n = Std.int(n*1.5);

			default :
		}

		// Anti-exploit
		var capped = switch( r ) {
			case HM_Row, HM_Column, HM_JoyBomb :
				var total = c.getHappinessMod(HM_Row) + c.getHappinessMod(HM_Column) + c.getHappinessMod(HM_JoyBomb);
				if( total>=GameData.ZONE_EFFECT_LIMIT*GameData.LINE_POWER )
					true;
				else
					false;

			default : false;
		}

		if( capped ) {
			n = 0;
			applyEffect( HappinessModCapped(c.id, r) );
		}
		else {
			applyEffect( HappinessPermanentAffect(c.id, n, r, notifyPermanentAffect) );
			if( notifyChange && n>0 )
				applyEffect( HappinessChanged(c.id, c.getHappiness(), n) );
		}

	}


	function computeCustomizationHappiness(c:SClient, notify:Bool, notifyPermanentAffect:Bool) {
		if( c.done )
			return;

		var old = c.getHappiness();

		// Clear
		applyEffect( HappinessModRemoved(c.id, HM_Customization) );

		// Compute
		var n = c.room.getCustomizationBonus();
		if( c.hasPerk(Data.ClientPerkKind.DecoHater) ) {
			if( n>0 )
				addHappiness(c, n*GameData.DECOHATER_POWER, HM_Customization, false, notifyPermanentAffect);
		}
		else {
			if( c.hasPerk(Data.ClientPerkKind.Aesthete) )
				n*=GameData.AESTHETE_POWER;
			if( n>0 )
				addHappiness(c, n, HM_Customization, false, notifyPermanentAffect);
		}

		// Detect changes
		if( notify ) {
			var h = c.getHappiness();
			var delta = h-old;
			if( delta!=0 ) {
				applyEffect( HappinessChanged(c.id, h, delta) );
			}
		}
	}


	function computeHappiness(c:SClient) {
		// Store previous happiness
		var oldHappiness = new Map();
		for(c in hotel.clients)
			oldHappiness.set(c.id, c.getHappiness());

		var x = c.room.cx;
		var y = c.room.cy;
		var r = c.room;


		// Customization
		computeCustomizationHappiness(c, false, true);

		// Isolation
		var n = r.getIsolation();
		if( n>0 )
			addHappiness(c, n*GameData.ISOLATION_POWER, HM_Isolation, false);

		// Underground
		//if( r.cy<0 )
			//addHappiness(c, GameData.UNDERGROUND_POWER, HM_Underground, false);

		// Altitude
		//if( r.cy>=2 )
			//addHappiness(c, GameData.ALTITUDE_POWER, HM_Altitude, false);

		// Dirt
		if( c.room.isDamaged() ) {
			if( c.hasPerk(Data.ClientPerkKind.Dirty) )
				addHappiness( c, GameData.SPECIAL_REQUEST_BONUS, HM_PerkSpecialRequest, false );
			else if( c.type!=C_Repairer )
				addHappiness( c, GameData.PRESENCE_OF_DIRT*c.room.damages, HM_DirtyRoom, false );
		}
		else if( c.hasPerk(Data.ClientPerkKind.Dirty) )
				addHappiness( c, GameData.SPECIAL_REQUEST_MALUS, HM_PerkSpecialRequest, false );



		// Luxury
		if( c.room.level>0 )
			addHappiness( c, c.room.level, HM_Luxury, false );

		// Global-effect clients
		var bombs = 0;
		var annoy = 0;
		for(c2 in hotel.clients) {
			if( c2!=c && !c2.done && !c2.isWaiting() ) {
				if( c2.type==C_JoyBomb && c2.getHappiness()>=GameData.getHappinessTrigger(c2.type,hotel) )
					bombs++;

				if( c2.hasPerk(Data.ClientPerkKind.Annoying) )
					annoy++;
			}
		}
		if( bombs>0 )
			addHappiness(c, bombs*1, HM_JoyBomb, false);
		if( annoy>0 )
			addHappiness(c, -annoy*GameData.ANNOYING_POWER, HM_Annoying, false);

		// Annoying
		if( c.hasPerk(Data.ClientPerkKind.Annoying) )
			for(c2 in hotel.clients)
				if( c2!=c && !c2.done && !c2.isWaiting() )
					addHappiness(c2, -GameData.ANNOYING_POWER, HM_Annoying, true);

		// Row/cols bonus
		for(r in hotel.rooms) {
			if( !r.hasClient() )
				continue;

			var nc = r.getClient();
			if( nc.done || nc.isWaiting() )
				continue;

			// Row bonus
			if( r.cx!=x && r.cy==y ) {
				if( c.type==C_HappyLine )
					addHappiness(nc, GameData.LINE_POWER, HM_Row, false );

				if( nc.type==C_HappyLine )
					addHappiness(c, GameData.LINE_POWER, HM_Row, false );
			}

			// Column bonus
			if( r.cx==x && r.cy!=y ) {
				if( c.type==C_HappyColumn )
					addHappiness(nc, GameData.COL_POWER, HM_Column, false );

				if( nc.type==C_HappyColumn )
					addHappiness(c, GameData.COL_POWER, HM_Column, false );
			}
		}


		// Sunlight
		var pow = c.room.getSunlight();
		if( pow>0 ) {
			if( c.hasLike(SunLight) )
				addHappiness( c, GameData.PRESENCE_OF_LIKE*pow, HM_PresenceOfLike(SunLight), false );
			else if( c.hasDislike(SunLight) )
				addHappiness( c, GameData.PRESENCE_OF_DISLIKE*pow, HM_PresenceOfDislike(SunLight), false );
		}


		// Basic neighbour effect
		var dislikesNotMet = c.dislikes.copy();
		for(nc in getNeighbours(x,y)) {
			if( nc.done )
				continue;

			// Nice neighbour effect
			if( nc.type==C_Neighbour )
				addHappiness(c, GameData.NEIGHBOUR_POWER, HM_NiceNeighbour, false);

			if( c.type==C_Neighbour )
				addHappiness(nc, GameData.NEIGHBOUR_POWER, HM_NiceNeighbour, false);

			// Current -> Neighbour
			var a = c.emit;
			var pow = c.type==C_Plant?2:1;
			if( nc.hasLike(a) )
				addHappiness( nc, GameData.PRESENCE_OF_LIKE*pow, HM_PresenceOfLike(a), false );

			if( nc.hasDislike(a) )
				addHappiness(nc, GameData.PRESENCE_OF_DISLIKE*pow, HM_PresenceOfDislike(a), false );

			// Neighbour -> current
			var a = nc.emit;
			var pow = nc.type==C_Plant?2:1;
			if( c.hasLike(a) )
				addHappiness( c, GameData.PRESENCE_OF_LIKE*pow, HM_PresenceOfLike(a), false );

			if( c.hasDislike(a) ) {
				addHappiness( c, GameData.PRESENCE_OF_DISLIKE*pow, HM_PresenceOfDislike(a), false );
				dislikesNotMet.remove(a);
			}

		}

		// Sunlight dislikers
		if( c.hasDislike(SunLight) && r.getSunlight()>0 )
			dislikesNotMet.remove(SunLight);

		// Dislikes-not-met bonus
		for(a in dislikesNotMet)
			addHappiness( c, GameData.ABSENCE_OF_DISLIKE, HM_AbsenceOfDislike(a), false );




		// Detect changes
		for(c in hotel.clients) {
			var h = c.getHappiness();
			if( oldHappiness.exists(c.id) && h!=oldHappiness.get(c.id) ) {
				applyEffect( HappinessChanged(c.id, h, h-oldHappiness.get(c.id)) );
			}
		}
	}


	//function applyHappinessUpdate() {
		//// Save previous happiness values
		//var oldHappiness = new Map();
		//for(c in hotel.clients)
			//oldHappiness.set(c.id, c.getHappiness());
//
//
		//// Update
		//applyEffect( HappinessUpdate );
//
		//// Detect changes
		//for(c in hotel.clients) {
			//var h = c.getHappiness();
			//if( oldHappiness.exists(c.id) && h!=oldHappiness.get(c.id) )
				//applyEffect( HappinessChanged(c.id, h, h-oldHappiness.get(c.id)) );
		//}
//
	//}
}


