import Protocol;
import mt.deepnight.Range;

class _Client {
	public static var MAX_HAPPYNESS : Int =  10;

	#if flash
		#if local
			static var GEN		: Gen = new Gen(haxe.Resource.getString("texts.xml"));
		#else
			static var GEN		: Gen = null;
		#end
	#end
	#if neko
		static var GEN		: Gen = new Gen(neko.io.File.getContent(Config.TPL+"../../xml/"+Config.LANG+"/texts.xml"));
	#end
	public var _id			: Int;
	public var _name		: String;
	public var _job			: String;
	public var _happyness	: Int;
	public var _timeArrive 	: Date;
	public var _like		: List<_Likes>;
	public var _dislike		: List<_Likes>;
	public var _effect		: List<_EffectSpreading>;
	public var _type		: _MonsterFamily;
	public var _money 		: Int;
	public var _dateLeaving	: Date;
	public var _item 		: _Item ;
	public var _baseHappy	: Int;
	public var _bonusHappy	: Int;
	public var _malusHappy	: Int;
	public var _movePenalty	: Int;
	public var _activityEnd	: Null<Date>;
	public var _activity	: Null<_TypeRoom>;
	public var _happyLog	: List<_HL>;
	public var _serviceEnd	: Null<Date>;
	public var _serviceType	: _ServiceType;
	public var _vip			: Bool;
	public var _death		: Null<Date>;
	public var _color		: Null<Int>;
		
	#if (neko)
	/*borne a multiplier par un facteur sensi*/
	public function new (id, timeArrive, hotel:_Hotel, ?tg:TextGen) {
		_activity = null;
		_activityEnd = null;
		_baseHappy = Const.H_BASE;
		_bonusHappy = 0;
		_movePenalty = 0;
		_malusHappy = 0;
		_id = id;
		_happyLog = new List();
		_timeArrive = timeArrive;
		_like = new List();
		_dislike = new List();
		_effect = new List();
		_vip = false;
		_color = null;

		// génération
		generate(hotel, tg);
		
		// talents
		if (_type==_MF_SM)
			_baseHappy += Std.int( hotel.getTalentRatio(TalentXml.get.specSM)*2 );
		if (_type==_MF_BLOB)
			_baseHappy += Std.int( hotel.getTalentRatio(TalentXml.get.specBlob)*2 );
		
		_happyness = _baseHappy;
	}
	
	public function toString() {
		return _name+"("+_id+")[h="+_happyness+"]";
	}
	
	public function initSpreads() {
		_effect = new List();
		if(_type!=_MF_GHOST) {
			var eS = {
				_effect 		: _NEIGHBOR,
				_spreading		: CROSS,
			}
			_effect.add(eS);
		}
		

		if (_type == _MF_ZOMBIE)
			_effect.add( { _effect:_JOY, _spreading : CROSS } );
	}
	
	
	function generate(hotel:_Hotel, ?tg:TextGen) {
		generateType(hotel._level);
		initSpreads();
		generateEffect(hotel._level);
		initLikes();
		generateLikes(hotel._level);
		generateItem(hotel);
		
		if(tg!=null)
			_name = tg.get(Std.string(_type).substr(1));

		_money = Const.CLIENT_MONEY;
		_dateLeaving = makeDateLeaving(hotel, _timeArrive);
		
	}
	
	public function brainWash(hotel:_Hotel) {
		initSpreads();
		generateEffect(hotel._level);
		initLikes();
		generateLikes(hotel._level);
	}
	
	
	public static function getAvailableFx(level:Int) {
		var all = [
			_WATER,
			_FIRE,
			_ODOR,
		];
		if (level>0)
			all = all.concat([_FOOD, _NOISE]);
		return all;
	}

	
	function generateEffect(level:Int) {
		var n = if (_type == _MF_VEGETAL) 2 else if (_type==_MF_GHOST) 0 else 1;
		var allFx = getAvailableFx(level);
		
		// premiers clients forcés
		if (_id==0) {
			_effect.add( { _effect:_ODOR, _spreading:CROSS } );
			allFx.remove(_ODOR);
			n--;
		}
		if (_id==1) {
			_effect.add( { _effect:_FIRE, _spreading:CROSS } );
			allFx.remove(_NOISE);
			n--;
		}
			
		while(n>0){
			var eS : _EffectSpreading = {
				_effect 	: allFx.splice(Std.random(allFx.length),1)[0],
				_spreading 	: CROSS,
			}
			_effect.add(eS);
			n--;
		}
		
	}
	
	public function initLikes() {
		_like = new List();
		_dislike = new List();
	}
	
	function generateLikes(level:Int) {
		// premiers clients forcés
		if (_id==0) {
			_like.add(_FIRE);
			_like.add(_NEIGHBOR);
			return;
		}
		if (_id==1) {
			_like.add(_ODOR);
			_like.add(_NEIGHBOR);
			return;
		}
			
		var tabLikes = getAvailableFx(level);
		
		var nLike = Std.random(3);
		var nDislike = 2 - nLike;
		//var nDislike = Std.random(3 - nLike) + if (nLike == 0) 1 else 0;
		//nDislike = Std.int( Math.min(2,nDislike) );
		
		for(i in 0...nLike)
			_like.add( tabLikes.splice(Std.random(tabLikes.length),1)[0] );
		for(i in 0...nDislike)
			_dislike.add( tabLikes.splice(Std.random(tabLikes.length),1)[0] );
	}
		
	function generateType(lvl) {
		var types = [
			_MF_FIRE,
			_MF_BASIC,
			_MF_BUSINESS,
		];
		if (lvl>= 2) {
			types.push(_MF_FRANK);
			types.push(_MF_ZOMBIE);
		}
		if (lvl >= 3) {
			types.push(_MF_AQUA);
			types.push(_MF_BLOB);
			types.push(_MF_FLYING);
		}
		if (lvl>=4) {
			types.push(_MF_SM);
			types.push(_MF_VEGETAL);
		}
		if (lvl >= 5) {
			types.push(_MF_GHOST);
		}
		if (lvl >= 6) {
			types.push(_MF_BOMB);
		}
		
		_type =  types[Std.random(types.length)];
		//if(Config.DEBUG) {
			//_type = _MF_BOMB;
			//_type = if (Std.random(10) <8) _MF_FLYING else _MF_BASIC;
		//}
	}
		
	public function doActivity(?act:_TypeRoom, end:Date) {
		_activity = act;
		_activityEnd = end;
	}
	
	function generateItem(hotel:_Hotel) {
		var rlist = new mt.deepnight.RandList();
		for (key in Type.getEnumConstructs(_Item)) {
			var it = Type.createEnum(_Item, key);
			rlist.add(it, hotel.getItemDropChance(it));
		}
		_item = rlist.draw();
	}
	
	public function initService(hotel:_Hotel, now:Date, range:Range) {
		if ( !hotel.hasServices() )
			_serviceEnd = DateTools.delta(now, DateTools.days(30));
		else {
			var h = Const.SERVICE_VISIBILITY + DateTools.hours(range.draw());
			_serviceEnd = DateTools.delta(now, h);
			if (_serviceEnd.getTime()>=_dateLeaving.getTime())
				_serviceEnd = DateTools.delta(_dateLeaving, DateTools.days(99));
			var serviceKeys = Type.getEnumConstructs(_ServiceType);
			var services = new Array();
			for (k in serviceKeys) {
				var s = Type.createEnum(_ServiceType,k);
				if ( hotel.canBuildRoom( _Room.getServiceRoom(s) ) )
					services.push(s);
			}
			_serviceType = services[Std.random(services.length)];
		}
	}
	
	function makeDateLeaving (hotel:_Hotel, arrival:Date) {
		var stay = new mt.deepnight.RandList();
		stay.add(1, 100);
		if(hotel._level>=2)
			stay.add(2, if(hotel._level==2) 20 else 50);
		if(hotel._level>2)
			stay.add(3, 20);
			
		var date = DateTools.delta(arrival, DateTools.days(stay.draw()));
		return mt.deepnight.Lib.setTime(date, Const.LEAVE_TIME);
	}

	public function getBaseGain(hotel:_Hotel, room:_Room) {
		var h = getHappyness();
		var factor : Float = switch(h) {
			//case 0 : 0;
			//case 1 : 0.05;
			//case 2 : 0.1;
			//case 3 : 0.15;
			//case 4 : 0.2;
			//case 5 : 0.25;
			//case 6 : 0.3;
			//case 7 : 0.5;
			//case 8 : 0.65;
			//case 9 : 0.75;
			//case 10: 1.0;
			case 0 : 0;
			case 1 : 0.05;
			case 2 : 0.1;
			case 3 : 0.15;
			case 4 : 0.2;
			case 5 : 0.3;
			case 6 : 0.45;
			case 7 : 0.55;
			case 8 : 0.7;
			case 9 : 0.8;
			case 10: 1.0;
		}
		if (h<=0)
			factor = 0;
		if (h>=MAX_HAPPYNESS)
			factor = 1;
			
		// base
		var gain = _money * factor;

		// blob
		if ( _type == _MF_BLOB )
			if(h>=10)
				gain = Math.round(gain*1.7);
			else
				gain = Math.round(gain*0.5);
		
		// talents
		gain *= 1 + switch(_type) {
			case _MF_AQUA		: hotel.getTalentRatio(TalentXml.get.specAqua)*1;
			case _MF_BLOB		: 0;
			case _MF_FIRE		: 0;
			case _MF_BOMB		: hotel.getTalentRatio(TalentXml.get.specBomb)*1;
			case _MF_GHOST		: 0;
			case _MF_BUSINESS	: 0;
			case _MF_SM			: 0;
			case _MF_VEGETAL	: hotel.getTalentRatio(TalentXml.get.specVegetal)*1;
			case _MF_FRANK		: 0;
			case _MF_GIFT		: 0;
			case _MF_BASIC		: 0;
			case _MF_ZOMBIE		: 0;
			case _MF_FLYING		: 0;
		}
				
		// niveau de room
		if (room._level==1)
			gain *= 1.2;
		if (room._level==2)
			gain *= 1.6;

		// lit diamant
		if ( room.hasEquipment(_WALLET) )
			gain *= 1.25;
	
		return Math.floor(gain);
	}
	
	public function makeVip() {
		if (_vip)
			return;
		_vip = true;
		_baseHappy -= Const.H_LIKE_OK; // on compense le gain qu'apportera la chambre de luxe
		_like.add(_LUX_ROOM);
	}

	#end
	
	
	
	// *** FLASH COMMON *****************************************
	
	public function isUnstable() {
		return _death!=null;
	}

	public function getHappyness() {
		return Std.int( Math.max(0, Math.min(MAX_HAPPYNESS, _happyness)) );
	}
	
	public static function printHappyLog(hl:_HL) {
		var value = "<span class='value'>"+(hl._n > 0?"+":"")+hl._n+"</span> ";
		var reason =
			switch(hl._mod) {
				case M_BASE 	: T.get.HappyBase;
				case M_BONUS	: T.get.HappyBonus;
				case M_MALUS	: T.get.HappyMalus;
				case M_ROOM		: T.get.HappyRoomState;
				case M_HYSTERIA	: T.get.HappyHystery;
				case M_MOVE		: T.get.HappyMove;
				case M_LIKE(l)	:
					var base = "<strong>"+_Client.getLikeName(l)+"</strong>";
					if (!hl._present)
						T.get.LikeMissing +" : "+ base;
					else
						T.get.LikePresent +" : "+ base;
			}
		return
			"<span class='"+(if(hl._n<0) "negative" else "positive")+"'>"+
			value + reason+
			"</span>";
	}
	
	public static function getLikeName(l:_Likes) {
		var lstr = (""+l).substr(1);
		return T.getByKey("Like"+lstr);
	}
	
	public function hasServiceWaiting(now:Date) {
		if (_serviceEnd==null)
			return false;
		var nowT = now.getTime();
		var endT = _serviceEnd.getTime();
		return
			nowT <= endT &&
			nowT >= DateTools.delta(_serviceEnd, -Const.SERVICE_VISIBILITY).getTime() &&
			nowT < endT;
	}
	
}

