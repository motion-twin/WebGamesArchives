import Protocol;
import mt.deepnight.deprecated.TalentTree;
import mt.deepnight.Range;
import Quest;

enum _CampaignEffect {
	CE_Vip(n:Int);
	CE_Client(n:Int);
}

#if neko
typedef Campaign = {
	var name	: String;
	var effect	: _CampaignEffect;
	var cost	: Int;
	var desc	: String;
}
#end

class _Hotel {
	public static var WAKEUP_HOUR = 6;
	public static var DATA_VERSION = 12;
	
	public var _createDate		: Date;
	public var _nextEvent		: Date;
	public var _rooms			: Array<Array<_Room>>;
	public var _id				: Int;
	public var _name			: String;
	public var _money			: Int;
	public var _floors			: Int;
	public var _width			: Int;
	public var _lastDate		: Date;
	public var _clientQueue		: List<Int>;
	public var _clients			: IntHash<_Client>;
	public var _actionLog		: List<_Log>;
	public var _gameLog			: List<String>;
	public var _items			: IntHash<Int>;
	public var _staff			: List<_Staff>;
	public var _lastClient		: Date;
	public var _nextClient		: Date;
	public var _maxInQueue		: Int; // TODO champ à supprimer
	public var _uniqId			: Int;
	public var _uniqClientId	: Int;
	public var _questId			: Int;
	public var _questGoals		: List<{_ok:Bool, _g:_QGoal}>;
	public var _level			: Int;
	public var _active			: Bool;
	public var _rpoints			: Int;
	public var _build			: Hash<Int>;
	public var _friends			: List<_Client>;
	public var _campaigns		: List<{id:Int, e:_CampaignEffect}>;

	public var _debugDate		: Null<Date>;
	public var _debugLog		: List<String>;
	public var _v				: Int;
	public var _design			: IntHash<FloorDesign>;
	public var _color			: Int;
	
	public var _deco			: List<DecoItem>;
	
	public var _fame			: Int;
	public var _stars			: Int;
	
	#if flash
	public function new() {}
	#end
	
	#if neko
	public function new(date:Date, fl_custom:Bool) {
		var w = if(fl_custom) 1 else 3;
		var f = if (fl_custom) 1 else 3;

		_createDate		= date;
		_id				= Std.random(999999);
		_name			= T.get.DefaultHotelName;
		_money			= Const.STARTING_MONEY;
		_floors			= f;
		_width			= w;
		_lastDate		= date;
		_rooms			= new Array();
		_clientQueue	= new List();
		_clients		= new IntHash();
		_actionLog	    = new List();
		_gameLog		= new List();
		_debugLog		= new List();
		_items			= new IntHash();
		_friends		= new List();
		_staff			= new List();
		_lastClient 	= date;
		_nextClient  	= DateTools.delta(date, DateTools.hours(8));
		//_maxInQueue		= Const.MAX_CLIENTS_IN_QUEUE;
		_questId		= -1;
		_questGoals		= new List();
		_uniqId			= 0;
		_uniqClientId	= 0;
		_debugDate		= null;
		_v				= DATA_VERSION;
		_design			= new IntHash();
		_deco			= new List();
		_level			= 0;
		_active			= false;
		_rpoints		= 0;
		_build			= new Hash();
		_fame			= 1;
		_campaigns		= new List();
		_stars			= 0;

		resetEvent(date);
		setQuest(0);

		for (floor in 0..._floors)
			_rooms[floor] = new Array();
			
		for (f in 0..._floors){
			for (x in 0..._width) {
				var tr =
					if (f==0)
						_TR_NONE;
					else
						_TR_BEDROOM;
				_rooms[f][x] = new _Room(_uniqId++, tr, f);
			}
		}
		_rooms[0][_width-1].setType(_TR_LOBBY);
		
		if(Config.DEBUG) {
			for (q in QuestXml.ALL)
				if (q._repeatable) {
					_questId = q._id;
					break;
				}
			_level = 10;
			_rpoints = Const.LAB_MAX_TREE_POINTS;
			_staff.add( new _Staff(_uniqId++) );
			_staff.add( new _Staff(_uniqId++) );
			_staff.add( new _Staff(_uniqId++) );
			_staff.add( new _Staff(_uniqId++) );
			_staff.add( new _Staff(_uniqId++) );
			_staff.add( new _Staff(_uniqId++) );
			_money = 50000;
		}

		// compensation du début custom
		if(fl_custom)
			_money += Const.BUILD_ROOM_COST*6;
		
		generateDesign();
	}
	
	public function initWithSolver(solver:Solver, fl_custom:Bool) {
		solver.initQueue(_lastDate, Const.FIRST_CLIENTS);
		var desk = solver.addDecoItem(DecoDesk);
		desk._floor = 0;
		desk._x = (_width-1)*130 + 20;
		
		var tg = new TextGen(_id);
		_name = tg.get("hotelName");
		
		if(Config.DEBUG)
			for (key in Type.getEnumConstructs(_Item))
				if ( key!="_MONEY" && key!="_RESEARCH" )
					solver.addItem( Type.createEnum(_Item, key), 99 );

		if (fl_custom) {
			// validation rapide des quêtes
			var firstRepeatable = -1;
			for (q in QuestXml.ALL)
				if( !q._repeatable )
					solver.gainQuestRewards(q);
				else
					if (firstRepeatable==-1) firstRepeatable = q._id;
			_questId = firstRepeatable;
		}

		solver.solve(P_PING);
	}
	
	public function getCampaigns(now:Date) {
		if (_level==0)
			return new Array();
		var seed = _id + Std.int(
			if ( now.getHours()<WAKEUP_HOUR )
				mt.deepnight.Lib.setTime(DateTools.delta(now, -DateTools.days(1)),0).getTime()
			else
				mt.deepnight.Lib.setTime(now,0).getTime()
		);
		var rseed = new mt.Rand(0);
		rseed.initSeed(seed);
		var tg = new TextGen(seed);
		
		var all = new Array();
		for (i in 0...Range.makeInclusive(4,6).draw(rseed.random)) {
			var name = tg.get("sponsor");
			all[i] = getCampaign(name,i);
		}
		return all;
	}
	
	public function getCampaign(name:String, i:Int) : Campaign {
		var seed = name.length;
		for (i in 0...name.length)
			seed+=name.charCodeAt(i);
		var rseed = new mt.Rand(0);
		rseed.initSeed(seed);
		
		var c : Campaign = {
			name	: name,
			effect	: null,
			cost	: 0,
			desc	: "???",
		}

		// effet
		var elist = new mt.deepnight.RandList();
		elist.add("vip",	15);
		elist.add("client",	100);
		var fl_forceVip = Date.now().getTime()>=Date.fromString("2011-04-27 00:00:00").getTime();
		var e = if(i==0 && fl_forceVip) "vip" else elist.draw(rseed.random);
		switch(e) {
			case "client" :
				// clients supplémentaires
				var n = Range.makeInclusive(2,5).draw(rseed.random);
				c.cost += Std.int( n*Const.CLIENT_MONEY*0.9 );
				c.cost += n * _stars * Range.makeInclusive(5, 20).draw(rseed.random);
				c.desc = T.format.CE_Client( { _n:n, _time:WAKEUP_HOUR+"h" } );
				c.effect = CE_Client(n);
				c.cost += Range.makeInclusive(10,80).draw(rseed.random);
				
			case "vip" :
				// clients VIP
				var rlist = new mt.deepnight.RandList();
				rlist.add(1,	120);
				rlist.add(2,	50);
				rlist.add(3,	5);
				rlist.add(4,	1);
				var n = rlist.draw(rseed.random);
				c.cost += switch(n) {
					case 1	: 300*1;
					case 2	: 290*2;
					case 3	: 275*3;
					case 4	: 260*4;
				}
				c.cost += Range.makeInclusive(10,150).draw(rseed.random);
				c.desc = T.format.CE_Vip( { _n:n, _time:WAKEUP_HOUR+"h" } );
				c.effect = CE_Vip(n);
		}
		
		return c;
	}
	
	public function getRetreatRoomReq() {
		return switch(_stars) {
			case 0 : 12;
			case 1 : 20;
			case 2 : 30;
			case 3 : 50;
			case 4 : 75;
			case 5 : 100;
			default : 150;
		}
	}
	
	public function getRetreatLevelReq() {
		return 4+_stars;
	}
	
	public function canRetreat() {
		return
			getLevelForDisplay()>=getRetreatLevelReq() &&
			_money>=3000 &&
			countRealRooms()>=getRetreatRoomReq();
	}
	
	public function canReset() {
		return _stars==0;
	}
	
	public function updateHotelData(now:Date) {
		if (_friends == null)
			_friends = new List();
			
		var fl_updated = _v<_Hotel.DATA_VERSION;
		
		while (_v < _Hotel.DATA_VERSION) {
			switch(_v) {
			}
			_v++;
		}

		//if( _nextClient.getTime() <= DateTools.delta(_lastDate, -DateTools.days(3)).getTime() )
			//_nextClient = _lastDate;

		// Bugfix: clients d'un joueur absent depuis très longtemps
		//for( cid in _clientQueue ) {
			//var c = _clients.get(cid);
			//if( c!=null && c._dateLeaving.getTime()< _lastDate.getTime() ) {
				//_clients.remove(cid);
				//_clientQueue.remove(cid);
			//}
		//}
		
		//if( !Config.DEBUG )
			//if (_debugLog.length > 0)
				//_debugLog = new List();
		return fl_updated;
	}
	
	public function checkHotelData() {
		if (_color==null || Const.NEON_COLORS[_color]==null )
			_color = 2;
			
		if ( getQuest()==null ) {
			var firstRepeat = -1;
			for (q in QuestXml.ALL)
				if (q._repeatable) {
					firstRepeat = q._id;
					break;
				}
			setQuest(firstRepeat);
		}
	}
	
	public function isEmpty() {
		return _clientQueue.length == Lambda.count(_clients);
	}
	
	public function canReceiveFriendClients() {
		var n=0;
		for (cid in _clientQueue)
			if (_clients.get(cid)._type==_MF_GIFT)
				n++;
		return n+_friends.length<Const.MAX_FRIEND_CLIENTS;
	}
	
	public function resetEvent(now:Date) {
		var d = DateTools.hours(9) + DateTools.hours(Std.random(12));
		d += DateTools.seconds( Std.random(3600) );
		//if (Config.DEBUG)
			//d = DateTools.hours(1);
		_nextEvent = DateTools.delta(now, d);
	}

	public function setQuest(id:Int) {
		_questId = id;
		if ( hasQuest() )
			_questGoals = QuestXml.ALL.get(id)._goals;
	}
	
	public function getQuest() {
		return
			if ( QuestXml.ALL.exists(_questId) ) {
				var q : _Quest = haxe.Unserializer.run( haxe.Serializer.run(QuestXml.ALL.get(_questId)) );
				try {
					if ( q._goals.length!=_questGoals.length )
						throw "length mismatch";
					for (g in q._goals) {
						var fl_found = false;
						for (g2 in _questGoals)
							if ( Type.enumEq(g._g, g2._g) ) {
								fl_found = true;
								break;
							}
						if (!fl_found)
							throw "mismatch";
					}
					q._goals = _questGoals;
				}
				catch (e:String) {
					_questGoals = q._goals; // les objectifs ne collent pas à ce qu'on a en DB
				}
				return q;
			}
			else
				null;
	}
	
	public function hasQuest() {
		return QuestXml.ALL.exists(_questId);
	}
	
	public function isInQueue(c:_Client) {
		if ( !_clients.exists(c._id) )
			return false;
		for (qid in _clientQueue)
			if (c._id==qid)
				return true;
		return false;
	}
	public function isStaying(c:_Client) { // TRUE si il a une chambre dans l'hôtel
		return
			if ( !_clients.exists(c._id) )
				false;
			else
				!isInQueue(c);
	}
	
	public function getDate() {
		return if (_debugDate!=null) _debugDate else _lastDate;
	}

	public function generateDesign() {
		var odd = Std.random(999);
		var even = Std.random(999);
		var dhash = new IntHash();
		for (f in 0..._floors) {
			var d : FloorDesign = {
				_wall		: 0,
				_wallColor	: -1,
				_bottom		: -1,
				_mid		: -1,
			}
			dhash.set(f, d);
		}
		_design = dhash;
	}

	public function getStaffCost() {
		var n = _staff.length;
		var d = {
			money	: 0,
			tokens	: 0,
		}
		switch(n) {
			case 0 : d.money = 150;
			case 1 : d.money = 250;
			case 2 : d.money = 500;
			case 3 : d.money = 1000;
			default :
				d.tokens = 15*(n-1);
		}
		return d;
	}

	public static function isClosedTime(d:Date) {
		var stamp = d.getTime();
		return stamp>=mt.deepnight.Lib.setTime(d,0).getTime() && stamp<mt.deepnight.Lib.setTime(d,WAKEUP_HOUR).getTime();
	}
	
	public function getTaxFame() {
		var l = getLevelForDisplay();
		return Const.FAME_TAX * if (l<=10) l else 10;
	}
	
	public function getTax() {
		var t =
			if (_level<=0)
				100
			else if( _level<=4)
				_level*500;
			else if( _level==5)
				_level*600;
			else if( _level==6)
				_level*700;
			else if( _level==7)
				_level*800;
			else if( _level==8)
				_level*1000;
			else
				_level*1500;
		t -= Math.round( t*getTalentRatio(TalentXml.get.taxDiscount)*0.20 );
		return
			if (_level<=0)
				Math.floor( Math.max(1, Math.min(1,_Hotel.countDaysUntilTax(_createDate)/6)*t / 10 ) ) * 10;
			else
				t;
	}
	
	public inline static function getItemText(it:_Item) {
		return T.getItemText(it);
	}
	
	public function getItemDropChance(i:_Item) {
		var meta = haxe.rtti.Meta.getFields(_Item);
		return Reflect.field(meta,Std.string(i)).rand[0];
	}
	
	public static function countDaysUntilTax(now:Date) {
		return mt.deepnight.Lib.countDaysUntil(now, Const.TAX_NIGHT);
	}
	
	public function getTree() {
		return new mt.deepnight.deprecated.TalentTree(TalentXml.ALL, _build, 99);
	}
	
	public function countRealRooms() {
		var n = 0;
		for (f in 0..._floors)
			for (x in 0..._width) {
				var t = _rooms[f][x]._type;
				if ( t!=_TR_VOID && t!=_TR_NONE && t!=_TR_LOBBY )
					n++;
			}
		return n;
	}
	
	public function countRooms(?t:_TypeRoom) {
		var n = 0;
		for (f in 0..._floors)
			for (x in 0..._width) {
				var rt = _rooms[f][x]._type;
				if ( rt!=_TR_VOID && (t==null || t==rt) )
					n++;
			}
		return n;
	}
	
	public function getExtensionCost() {
		var n = countRooms();
		// +1 pour le coût de la room suivante, -1 pour ne pas compter le Lobby
		var cost : Float =
			if (n<=9)
				0;
			else if (n<=12)
				50;
			else if (n<=15)
				250;
			else if (n<=18)
				500;
			else
				Std.int(n*n*3/100)*100;
				//Math.pow(nb,2.8)*1.5;
		cost *= 1 - (getTalentRatio(TalentXml.get.extendCost)*0.20);
		return Math.ceil(cost/10)*10;
	}
	
	public function getSpecialRoomCost() {
		var n = 0;
		for (floor in _rooms)
			for (r in floor)
				if (r._type!=_TR_VOID && _Room.isSpecialRoom(r._type))
					n++;
		return 200 + 100*n;
	}

	public function getTalent(t:Talent) {
		return if (_build.exists(t.id)) _build.get(t.id) else 0;
	}
	
	public function getTalentRatio(t:Talent):Float {
		return if (_build.exists(t.id)) _build.get(t.id)/t.max else 0;
	}

	/*public function getScores() {
		// décoration (placée)
		var deco = 0;
		for (di in _deco)
			if (di._floor!=null)
				deco++;
				
		// pièces
		var rscore = 0;
		for (floor in _rooms)
			for (r in floor) {
				switch(r._type) {
					case _TR_BEDROOM		: rscore+=r._level;
					case _TR_BIN, _TR_DISCO, _TR_FURNACE, _TR_RESTAURANT, _TR_POOL:
						rscore+=2;
					case _TR_SERV_ALCOOL	: rscore--;
					case _TR_SERV_FRIDGE	: rscore--;
					case _TR_SERV_SHOE		: rscore--;
					case _TR_SERV_WASH		: rscore--;
					case _TR_LOBBY			: rscore+=2;
					case _TR_LAB			: rscore--;
					case _TR_VOID, _TR_NONE, _TR_LOBBY_SLOT :
				}
				if ( r.hasEquipment() ) // équipement
					rscore+=r._equipments.length;
			}
		rscore*=2;
		
		var bscore = _rpoints*5 + getTree().used*5;
		var lscore = (getLevelForDisplay()-1)*20;
		return {
			level	: lscore,
			deco	: deco,
			rooms	: rscore,
			build	: bscore,
			total	: bscore + rscore + deco + lscore,
		}
	}*/
	
	
	public function reachedQuest(stepName:String ) {
		if (!QuestXml.steps.exists(stepName))
			throw "unknown step "+stepName+" ["+haxe.Stack.callStack().join("\n")+"]";
		return _questId>=QuestXml.steps.get(stepName);
	}
	
	public inline function getTreeMax() {
		return Const.LAB_MAX_TREE_POINTS + _stars*5;
	}
	
	public function treeMaxed() {
		return getTree().used + _rpoints >= getTreeMax();
	}
	
	#end
	
	
	
	#if flash
	public function canUseBuildMode() {
		return _questId>=7; // ATTENTION : maintenir cette valeur à jour !
	}
	#end
	
	
	// *** FLASH COMMON PART ******************************
		
	public inline function getNeonColor() {
		return Const.NEON_COLORS[_color].c;
	}
	public inline function getTextColor() {
		return Const.NEON_COLORS[_color].t;
	}

	public function countStaffDoing(job:_TypeJob) {
		return Lambda.filter(_staff, function(s) { return s._job==job; }).length;
	}
	
	public function getClientDelay(nstaff:Int) {
		var hours = switch(nstaff) {
			case 0	: 8;
			case 1	: 5;
			case 2	: 4;
			case 3	: 3;
			case 4	: 2;
			case 5	: 1;
			default	: 45/60;
		}
		return DateTools.hours(hours);
	}

	public inline function getLevelForDisplay() {
		return if (_level<=0) 1 else _level+1;
	}

	//public function reachedQuest(?qid:Null<Int>, ?stepName:String ) {
		//return
			//if (qid!=null) _questId>=qid
			//else if (stepName!=null) _questId>=QuestXml.steps.get(stepName)
			//else false;
	//}
	
	public function canBuildRoom(r:_TypeRoom) {
		return _canBuildRoom(r, _level);
	}
	public static function _canBuildRoom(r:_TypeRoom, l:Int) {
		return switch(r) {
			case _TR_LAB			: l>=1;
			case _TR_SERV_WASH		: l>=1;
			case _TR_SERV_SHOE		: l>=3;
			case _TR_SERV_FRIDGE	: l>=4;
			case _TR_SERV_ALCOOL	: l>=5;
			case _TR_BIN,_TR_DISCO, _TR_FURNACE, _TR_RESTAURANT, _TR_POOL :
				l>=2;
			default : true;
		}
	}

	//public function hasSpecialRooms() { // resto, discothèque ...
		//return _level>=2;
	//}
	//
	public function hasServices() { // linge, cirage, ...
		return _level>=1;
	}
}
