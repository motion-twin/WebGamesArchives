package com;

import com.Protocol;
import Data;
import mt.MLib;

class SClient {
	static var PREFIXES = [ "Gro", "Ji", "Fu", "Pon", "Tip", "Deep", "Card", "Tip", "Sko", "Hik", "Bum", "Rou", "Bo", "Ar", "Bi", "Hi", "Fat", "Buz", "Skull" ];
	static var SUFFIXES = [ "nor", "'o", "grom", "nuk", "ren", "lo", "el", "us", "night", "dum", "ix", "be", "arg", "ouf", "pok", "ko", "pion", "pew", "bone", "zard" ];

	// Not stored in state
	public var hotel			: SHotel;
	public var name				: String;
	public var room				: SRoom;

	// State
	public var id				: Int;
	public var type				: ClientType;
	public var money			: Int;
	public var likes			: Array<Affect>;
	public var dislikes			: Array<Affect>;
	public var emit				: Null<Affect>;
	public var baseHappiness	: Int;
	public var happinessMods	: Array<{ value:Int, type:HappinessMod }>;
	public var stayDuration		: Float;
	public var serviceType		: RoomType;
	public var serviceDate		: Float;
	public var done				: Bool;
	public var flags			: Map<String,Bool>;
	//public var miniGameDate		: Float;

	public function new(h:SHotel, id:Int) {
		hotel = h;
		this.id = id;

		stayDuration = DateTools.minutes(5);
		money = 0;
		name = "???";
		done = false;
		baseHappiness = 0;
		happinessMods = [];
		flags = new Map();
		type = C_Liker;
		likes = [];
		dislikes = [];
		serviceType = R_Laundry;
		serviceDate = hotel.lastEvent + DateTools.days(999);
	}

	function makeName(rndFunc:Int->Int) {
		#if neko
		return name;
		#else

		if( isVip() ) {
			// VIP special names (optional)
			for(p in getPerks())
				if( p!=Data.ClientPerkKind.Vip ) {
					var p = Data.ClientPerk.get(p);
					if( p.names.length>0 )
						return p.names[ rndFunc(p.names.length) ].name;
				}
		}

		// Normal name
		return randomName(rndFunc);
		#end
	}

	#if !neko
	public static function randomName(rndFunc:Int->Int) {
		var name = PREFIXES[rndFunc(PREFIXES.length)];
		if( rndFunc(100)<20 )
			name+="-";
		name+=SUFFIXES[rndFunc(SUFFIXES.length)];
		if( rndFunc(100)<20 ) {
			if( rndFunc(100)<40 )
				name+="-";
			name+=SUFFIXES[rndFunc(SUFFIXES.length)];
		}
		return name;
	}
	#end



	public function onInstall(now:Float) {
		var rseed = makeRandom();

		#if !disableTutorial
		// Special tuto clients
		var installed = hotel.getStat("install")+1;
		if( installed==7 ) {
			stayDuration = DateTools.days(999);
			baseHappiness = -70;
		}
		#end

		// Service request
		initService(rseed, true);
		#if !prod
		serviceDate = hotel.lastEvent;
		#end
	}

	public function getRemainingDuration(now:Float) {
		if( isWaiting() )
			return stayDuration;

		if( done )
			return 0;

		var t = hotel.getClientCompleteTask(id);
		return t!=null ? t.end - now : 0;
	}


	public function toString() return '$type#$id($room)L='+likes.join(",")+',D='+dislikes.join(",")+',E='+emit+',H='+getHappiness();

	inline function makeRandom() {
		var r = new mt.Rand(0);
		r.initSeed( hotel.seed + id );
		return r;
	}

	public function canBeSkipped(now:Float) {
		return !isVip() && getRemainingDuration(now)>=DateTools.seconds(5) && switch( type ) {
			case C_Inspector : false;
			#if !debug
			case C_Christmas : false;
			#end
			default : true;
		}
	}

	public function initNonGameplayValues() {
		var rseed = new mt.Rand(id);
		name = makeName(rseed.random);
	}

	public function generateGameplayValues(t:ClientType, vip:Bool) {
		var h = hotel;
		var rseed = makeRandom();

		// Type
		type = t;

		// Happiness
		baseHappiness = hotel.level>=5 ? 0 : 5;
		switch( type ) {
			case C_Dragon : baseHappiness = 0;
			default :
		}


		// Money
		var rlist = new mt.RandList(rseed.random);
		if( hotel.roomUnlocked(R_StockPaper) ) {
			rlist.add(0, 3);
			rlist.add(1, 50);
			rlist.add(2, 9);
			rlist.add(3, 1);
		}
		else {
			rlist.add(0, 3);
			rlist.add(1, 50);
			rlist.add(2, 15);
			rlist.add(3, 3);
		}
		money = rlist.draw();
		switch( type ) {
			case C_Liker : money = MLib.min(money, 1);
			case C_Dragon : money = MLib.max(money, 3);
			case C_Bomb : money = MLib.max(money, 1);
			default :
		}


		// Affects
		var base : Array<com.Affect> = [ Heat, Noise, Odor ];
		if( hotel.featureUnlocked("cold") )
			base.push(Cold);
		var gen = switch( type ) {
			case C_Plant : G_LikeLight;
			case C_Vampire : G_DislikeLight;
			case C_Spawnling : G_DislikeLight;
			case C_Emitter : G_Empty;
			case C_Disliker : G_DislikerEasy;

			default :
				var g = h.pickClientGenDeck(rseed);
				while( vip && ( g==G_LikeLight || g==G_LikeLightHard ) )
					g = h.pickClientGenDeck(rseed);
				g;
		}


		function pickAffect(?l:Array<Affect>) {
			if( l==null || l.length==0 )
				l = base;
			return l.splice(rseed.random(l.length),1)[0];
		}
		switch( gen ) {
			case G_Empty :

			case G_Double :
				var a = pickAffect();
				likes.push(a);
				emit = a;

			case G_DislikerDouble :
				var a = pickAffect();
				likes.push(a);
				emit = a;
				dislikes.push( pickAffect() );

			case G_EasyNotDouble :
				var map = new Map();
				for(c in hotel.clients)
					if( c!=this && !c.done && c.emit!=null )
						map.set(c.emit, true);
				var allEmits = [];
				for(a in map.keys()) allEmits.push(a);
				likes.push( pickAffect(allEmits) );

				var map = new Map();
				for(c in hotel.clients)
					if( c!=this && !c.done )
						for(a in c.likes)
							if( a!=SunLight )
								map.set(a, true);
				var allLikes = [];
				for(a in map.keys()) allLikes.push(a);
				var a = pickAffect(allLikes);
				while( hasLike(a) ) a = pickAffect(allLikes);
				emit = a;

			case G_EasyOrDouble :
				var map = new Map();
				for(c in hotel.clients)
					if( c!=this && !c.done && c.emit!=null )
						map.set(c.emit, true);
				var allEmits = [];
				for(a in map.keys()) allEmits.push(a);
				likes.push( pickAffect(allEmits) );

				var map = new Map();
				for(c in hotel.clients)
					if( c!=this && !c.done )
						for(a in c.likes)
							if( a!=SunLight )
								map.set(a, true);
				var allLikes = [];
				for(a in map.keys()) allLikes.push(a);
				emit = pickAffect(allLikes);

			case G_LikeLight :
				likes.push( SunLight );
				emit = pickAffect();

				var rlist = new mt.RandList(rseed.random);
				rlist.add(2, 2);
				rlist.add(3, 50);
				rlist.add(4, 8);
				money = rlist.draw();

			case G_LikeLightHard :
				likes.push( SunLight );
				dislikes.push( pickAffect() );
				emit = pickAffect();

			case G_DislikeLight :
				likes.push( pickAffect() );
				dislikes.push( SunLight );
				emit = pickAffect();

			case G_DislikerEasy :
				var map = new Map();
				for(c in hotel.clients)
					if( c!=this && !c.done && c.emit!=null )
						map.set(c.emit, true);
				var allEmits = [];
				for(a in map.keys()) allEmits.push(a);
				likes.push( pickAffect(allEmits) );

				var a = pickAffect();
				while( hasLike(a) ) a = pickAffect();
				dislikes.push(a);

				emit = pickAffect();

			case G_DislikerHard :
				likes.push( pickAffect() );
				dislikes.push( pickAffect() );
				emit = pickAffect();
		}

		setFlag(Std.string(gen));


		switch( type ) {
			case C_Inspector :
				// Inspector boss
				var data = DataTools.getBoss(hotel.level);

				if( data!=null ) {
					baseHappiness = data.happiness;
					money = data.money;
					likes = data.likes.toArrayCopy().map( function(e) return DataTools.convertAffect(e.likeId) );
					dislikes = data.dislikes.toArrayCopy().map( function(e) return DataTools.convertAffect(e.dislikeId) );
					if( data.perk!=null )
						addPerk(data.perkId);

					if( data.emit!=null )
						emit = DataTools.convertAffect(data.emitId);
				}

			case C_Liker :
				addHappinessAffect(GameData.LIKER_POWER, HM_LikerBase);

			case C_Halloween :
				addHappinessAffect(-10, HM_Unhappy);

			case C_Christmas :
				addHappinessAffect(-40, HM_Unhappy);
				addPerk( Data.ClientPerkKind.PoringCannibal );

			default :
		}


		// Duration
		stayDuration = GameData.getClientStayDuration(type, hotel);
		switch( type ) {
			case C_Spawnling :

			case C_Inspector :

			default :
				stayDuration = MLib.round( stayDuration * rseed.range(0.9, 1.1) ); // randomization
		}


		// VIP
		if( vip ) {
			addPerk(Data.ClientPerkKind.Vip);
			addHappinessAffect(-10, HM_Vip);

			var rlist = new mt.RandList(rseed.random);
			for(p in Data.ClientPerk.all)
				if( p.minLevel==null || hotel.level>=p.minLevel )
					rlist.add(p.id, DataTools.getRarityValue(p.rarityId));
			if( rlist.length()>0 )
				addPerk( rlist.draw() );

			if( hotel.level<=6 )
				stayDuration = DateTools.minutes(15);
			else
				stayDuration += DateTools.minutes(8);
		}

		#if debug
		//addPerk(Data.ClientPerkKind.DecoDropper);
		#end

		// Perk effects upon arrival in queue
		for( p in getPerks() )
			switch( p ) {
				case Data.ClientPerkKind.Squatter :
					stayDuration = DateTools.hours( rseed.irange(8,15) );
					addHappinessAffect(rseed.irange(-40,-30), HM_Vip);

				case Data.ClientPerkKind.Fast :
					stayDuration = MLib.fmin( stayDuration, DateTools.seconds(60) );

				case Data.ClientPerkKind.Depressive :
					addHappinessAffect(rseed.irange(-30,-20), HM_Vip);

				default :
			}


		#if !disableTutorial
		// Tutorial specials
		switch( id ) {
			case 0 :
				likes = [ Odor ];
				emit = Heat;
				baseHappiness = 4;
				stayDuration = DateTools.days(999);

			case 1 :
				likes = [ Heat ];
				emit = Odor;
				baseHappiness = 4;

			case 2 :
				likes = [ Heat ];
				emit = Noise;

			case 3 :
				likes = [ Noise ];
				emit = Heat;

			case 4 :
				likes = [ Odor ];
				emit = Noise;

			case 5 :
				likes = [ Noise ];
				emit = Odor;

			default :
		}
		#end
	}



	public function hasLike(a:Affect) {
		for( a2 in likes )
			if( a2==a )
				return true;
		return false;
	}

	public function hasDislike(a:Affect) {
		for( a2 in dislikes )
			if( a2==a )
				return true;
		return false;
	}


	public function getInstallNeeds() : Array<{ t:RoomType, n:Int }> {
		return [];
		//return switch( type ) {
			//case C_Rich, C_Gem, C_Plant: [{ t:R_StockPaper, n:1 }, { t:R_StockSoap, n:1 }];
			//default : [{ t:R_StockPaper, n:1 }];
		//}
	}

	public static function fromState(h:SHotel, s:ClientState) : SClient {
		var c = new SClient(h, s.id);

		for(m in s.hmods)
			c.addHappinessAffect( m.v, m.t );

		for(k in s.flags)
			c.flags.set(k, true);

		c.room = h.getRoom(s.rx, s.ry);
		c.type = s.type;
		c.baseHappiness = s.baseHappiness;
		c.likes = s.likes.copy();
		c.dislikes = s.dislikes.copy();
		c.emit = s.emit;
		c.stayDuration = s.stayDuration;
		c.serviceDate = s.serviceDate;
		c.serviceType = s.serviceType;
		c.done = s.done;
		c.money = s.money;

		c.initNonGameplayValues();

		return c;
	}

	public function hasFlag(k) return flags.get(k)==true;
	public function setFlag(k) return flags.set(k,true);

	public function skippedUsingGem() return hasFlag("skipGem");


	public function addPerk(p:Data.ClientPerkKind) {
		setFlag("pk_"+p.toString());
	}

	public function hasPerk(p:Data.ClientPerkKind) {
		return hasFlag("pk_"+p.toString());
	}

	public function getPerks() : Array<Data.ClientPerkKind> {
		var all = [];
		for(k in flags.keys())
			if( k.indexOf("pk_")==0 ) {
				var p = Data.ClientPerk.resolve(k.substr(3));
				if( p!=null )
					all.push(p.id);
			}
		return all;
	}

	public function getVipPerk() : Null<Data.ClientPerkKind> {
		for( p in getPerks() )
			if( p!=Data.ClientPerkKind.Vip )
				return p;
		return null;
	}

	public function hasAnyPerk() {
		for(k in flags.keys())
			if( k.indexOf("pk_")==0 )
				return true;
		return false;
	}

	public inline function isVip() return hasPerk(Data.ClientPerkKind.Vip);



	public function hasHappinessMod(t:HappinessMod) {
		for( m in happinessMods )
			if( m.type.equals(t) )
				return true;
		return false;
	}

	public function getHappinessMod(t:HappinessMod) : Int {
		for( m in happinessMods )
			if( m.type.equals(t) )
				return m.value;
		return 0;
	}


	public function getState() : ClientState {
		// ATTENTION: ne pas oublier de casser les références (copy, serialize)
		var f = [];
		for(k in flags.keys())
			f.push(k);

		var s : ClientState = {
			id			: id,
			rx			: room.cx,
			ry			: room.cy,
			type		: type,
			baseHappiness: baseHappiness,
			likes		: likes.copy(),
			dislikes	: dislikes.copy(),
			emit		: emit,
			hmods		: happinessMods.map( function(m) return { v:m.value, t:m.type } ),
			stayDuration: stayDuration,
			serviceDate : serviceDate,
			serviceType	: serviceType,
			done		: done,
			flags		: f,
			money		: money,
		}
		return s;
	}

	public function getHappiness() {
		var h = baseHappiness;
		for( m in happinessMods )
			h+=m.value;
		//return mt.MLib.max(0,h);
		return h;
	}

	public function getCappedHappiness() {
		return MLib.min( getHappiness(), hotel.getMaxHappiness() );
		//return MLib.clamp( getHappiness(), 0, GameData.MAX_HAPPINESS );
	}

	public function getClampedHappiness() {
		return MLib.clamp( getHappiness(), 0, hotel.getMaxHappiness() );
	}

	public inline function happinessMaxed() return hasFlag("maxed") || getHappiness()>=hotel.getMaxHappiness();

	public function hasServiceRequest(nowMs:Float) {
		return !isWaiting() && !done && nowMs>=serviceDate && hotel.hasRoomType(serviceType);
	}

	public function initService(rseed:mt.Rand, first:Bool) {
		var all = new mt.RandList(rseed.random);
		var hasPaper = hotel.roomUnlocked(R_StockPaper);
		var hasSoap = hotel.roomUnlocked(R_StockSoap);
		if( first ) {
			// First service after installed
			if( hasPaper && hasSoap ) {
				all.add(R_StockPaper, 20);
				all.add(R_StockSoap, 4);
				all.add(R_Laundry,1);
			}
			if( !hasPaper && hasSoap ) {
				all.add(R_StockSoap, 1);
				all.add(R_Laundry,9);
			}
			if( !hasPaper && !hasSoap )
				all.add(R_Laundry,1);

			serviceDate = hotel.lastEvent + DateTools.seconds( rseed.range(5, 20) );
		}
		else {
			// All other services
			if( hasPaper && hasSoap ) {
				all.add(R_StockPaper, 10);
				all.add(R_StockSoap, 4);
				all.add(R_Laundry,15);
			}
			if( !hasPaper && hasSoap ) {
				all.add(R_StockSoap, 1);
				all.add(R_Laundry,9);
			}
			if( !hasPaper && !hasSoap )
				all.add(R_Laundry,1);

			var d = stayDuration>=DateTools.minutes(10) ?
				DateTools.minutes( rseed.range(1,5) ) :
				DateTools.minutes( rseed.range(0.5,2) );
			serviceDate = hotel.lastEvent + d;
		}

		serviceType = all.draw();
	}

	//public function advanceService(rseed:mt.Rand) {
		//var all = new mt.RandList(rseed.random);
		////all.add(R_Laundry, 20);
		//all.add(R_StockPaper, 8);
		//all.add(R_StockSoap, 1);
//
		//serviceType = all.draw();
		//serviceDate += DateTools.minutes( rseed.range(0.75,2) );
	//}

	public function forceService(t:RoomType) {
		serviceType = t;
		serviceDate = hotel.lastEvent;
	}

	public function hasMiniGameRequest(now:Float) {
		return !done && !isWaiting() && now>=hotel.miniGameDate && hotel.miniGameCid==id;
	}
//
	//public function advanceMiniGame(rseed:mt.Rand) {
		//miniGameDate =
			//hotel.lastEvent +
			//MLib.fmax(DateTools.minutes(1), rseed.range(0.2, 0.7) * stayDuration);
	//}

	public function addHappinessAffect(v:Int, type:HappinessMod) {
		for(m in happinessMods)
			if( m.type.equals(type) ) {
				m.value+=v;
				return;
			}

		happinessMods.push({
			value		: v,
			type		: type,
		});
	}

	public inline function at(x,y) return x>=room.cx && x<room.cx+room.wid && y==room.cy;

	public inline function isWaiting() {
		if( room==null )
			return false;
		else
			return switch( room.type ) {
				case R_Lobby, R_ClientRecycler : true;
				default : false;
			}
	}

	public function destroy() {
		name = null;
		room = null;
	}
}
