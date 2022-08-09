import Protocol;
#if neko
import T;
import Quest;
import mt.deepnight.Range;
import Type;
import Shop;
import _Hotel;
import mt.deepnight.Lib;
#end

#if flash
	Should not be compiled in flash !
#end

class Solver {
#if neko
	static var MAX_GAME_LOG = 200;
	static var MAX_DEBUG_LOG = 100;

	public var hotel			: _Hotel;
	public var time				: Date;
	public var baseEffect		: Array<Array<List<_SourceEffect>>>;
	//public var cdClient			: Float;
	private var turnHysterics	: List<Int>;
	private var qman			: Null<QuestManager>;
	private var addedThisTurn	: Null<_Client>;

	static public function newHotel(date, fl_custom:Bool){
		var hotel = new _Hotel(date, fl_custom);

		var solver = new Solver(hotel, date);
		hotel.initWithSolver(solver,fl_custom);

		return hotel;
	}
	
	
	public static function getInitData(h:_Hotel) : InitData {
		return {
			_itemCats	: ShopXml.getShortCategories(),
			_itemUrl	: App.fullApi.getDataURL() + "/" + ShopXml.ICON_PATH,
			_extCost	: h.getExtensionCost(),
			_sroomCost	: h.getSpecialRoomCost(),
			_serverTime	: Date.now(),
			_lowq		: App.user!=null && App.user.lowQuality,
			//_clientItem	: h.getTalentRatio(TalentXml.get.clientItem)==1,
		}
	}
	
	public function addDecoItem(item:_DecoType, ?frame:Int) {
		var ditem = {
			_id			: hotel._uniqId++,
			_type		: item,
			_frame		: if(frame!=null) frame else 1,
			_x			: null,
			_y			: null,
			_floor		: null,
		}
		if(frame==null)
			ditem._frame = switch(ditem._type) {
				case DecoPlantSmall	: Std.random(14)+1;
				case DecoPlantLarge	: Std.random(7)+1;
				case DecoPaintSmall	: Std.random(10)+1;
				case DecoLight		: Std.random(2)+1;
				case DecoFurniture	: Std.random(3)+1;
				case DecoSofa		: Std.random(5)+1;
				case DecoDesk		: 1;
			}
		hotel._deco.add(ditem);
		return ditem;
	}
	
	
	public function new(hotel:_Hotel, d:Date) {
		this.hotel = hotel;
		debug("---- new solver datav="+hotel._v+" -----");
		
		if (hotel._debugDate != null)
			hotel._debugDate = DateTools.delta(hotel._debugDate, DateTools.seconds(1));
			
		if (d!=null && hotel._debugDate==null)
			time = d;
		else
			time = hotel.getDate();

		hotel.updateHotelData(time);
		hotel.checkHotelData(); // vérifications de sécurité
			
		hotel._actionLog = new List();
		clearBaseEffect();
		baseEffect = new Array<Array<List<_SourceEffect>>>();
		
		if( hotel.hasQuest() )
			qman = new QuestManager(this, hotel.getQuest());
	
		for (floor in 0...hotel._floors)
			baseEffect[floor] = new Array<List<_SourceEffect>>();
			
		for (i in 0...hotel._floors )
			for (j in 0...hotel._width )
				baseEffect[i][j] = new List<_SourceEffect>();
		
		updateAffectMap();
	}
	
	function deltaDays(now:Date, next:Date) {
		var delta = Lib.countDeltaDays(now, next);
		return
			switch(delta) {
				case 0	: DateTools.format( next, T.get.DateToday );
				case 1	: DateTools.format( next, T.get.DateTomorrow );
				case 2	: DateTools.format( next, T.get.DateDayAfter );
				//case 0	: T.format.DateToday( {_time:DateTools.format(next_, "%H:%M")} );
				//case 1	: T.format.DateTomorrow( { _days:delta, _time:DateTools.format(next_, "%H:%M") } );
				//case 2	: T.format.DateDayAfter( { _days:delta } );
				default : T.format.DateFar( { _days:delta } );
			}
	}
	
	private function getQuestHtml(q:_Quest) {
		var objectives = qman.getObjectivesInfos();
		var done = 0;
		var total = 0;
		var doneList = new List();
		var todoList = new List();
		for (o in objectives) {
			done+=o.done;
			total+=o.total;
			if (!o.complete)
				todoList.add(o);
			else
				doneList.add(o);
		}
		return template("mini/quest.mtt", {
			q			: q,
			done		: done,
			total		: total,
			doneList	: doneList,
			todoList	: todoList,
			sk			: App.session.key,
			showReset	: !hotel.reachedQuest("night"),
		});
	}
	
	public function validateGoal(g:_QGoal) {
		if ( qman!=null && qman.validateGoal(g) )
			logAction( L_QUEST( false, getQuestHtml(hotel.getQuest()) ) );
	}
	
	private function differentRandom(old, range:mt.deepnight.Range) {
		var newV = old;
		while (newV==old)
			newV = range.draw();
		return Std.int(newV);
	}
	
	function printDay(date:Date) {
		if( Config.DEBUG )
			return Std.string(date);
			
		var format = switch(Config.LANG.toLowerCase()) {
			case "fr"	: "%d %b";
			case "en"	: "%b %d";
			default		: "%b %d";
		}
		return DateTools.format(date, format);
	}
	
#end

	// **************************************************************************************
	// *	ZONE COMMUNE FLASH/NEKO
	// **************************************************************************************

	// **************************************************************************************

	
#if neko
	private function updateWidth() {
		var max = 0;
		for (row in hotel._rooms)
			if (row.length>max)
				max = row.length;
		hotel._width = max;
	}


	public function logAction(?now:Date, l:_Log) {
		var fl_insertFirst = switch(l) {
			case L_REFRESH, L_NEW_EXT_COST(_) : true;
			case L_ANIM(f,x,a) :
				switch(a) {
					case NewClient(_) : true;
					default : false;
				}
				case L_EVENT(msg) :
					logGameMsg(if (now==null) time else now, msg);
					false;
			default : false;
		}
		if (fl_insertFirst)
			hotel._actionLog.push(l); // logs prioritaires
		else
			hotel._actionLog.add(l);
	}
	
	private function logGameMsg(?date:Date, msg:String, ?className:String) {
		var str = msg;
		if(date!=null) {
			var h = date.getHours();
			var timeClass =
				if (h==0) "mid"
				else if (h>=20 || h<=6) "nig"
				else if (h<=12) "mor"
				else "aft";
			str = "<em class='"+timeClass+"'>"+DateTools.format(date,"%H:%M")+"</em> "+str;
		}
		if (className != null)
			str = "<span class='"+className+"'>"+str+"</span>";
		hotel._gameLog.add(str);
		if(Config.DEBUG)
			debug(str);
		var max = if (Config.DEBUG) 400 else MAX_GAME_LOG;
		while ( hotel._gameLog.length > max )
			hotel._gameLog.pop();
	}
	
	public function debug(?str:String, ?obj:Dynamic) {
		if(Config.DEBUG) {
			if(str!=null || obj==null)
				hotel._debugLog.add(str);
			else {
				var data = new List();
				for (k in Reflect.fields(obj))
					data.add( k+"="+Reflect.field(obj, k) );
				hotel._debugLog.add( data.join(", ") );
			}
			while ( hotel._debugLog.length > MAX_DEBUG_LOG )
				hotel._debugLog.pop();
		}
	}
	
	public inline function debugForced(str:String) {
		hotel._debugLog.add(str);
		while ( hotel._debugLog.length > MAX_DEBUG_LOG )
			hotel._debugLog.pop();
	}
	
	public function getFullName(c:_Client) {
		var r = getClientRoom(c);
		return
			if (r==null)
				c._name;
			else {
				var pt = getRoomCoord(r);
				c._name + "("+T.format.RoomNumber( {_n:_Room.getNumber(pt.floor, pt.x)} )+")";
			}
	}
	
	
	
	private function checkMoney(sum:Int) {
		if (hotel._money < sum)
			throw L_ERROR(T.format.NotEnoughMoney( { _money:sum, _currency:T.get.Currency} ));
	}

	private function applyLoss(sum:Int, ?tag:String) {
		sum = Std.int(Math.abs(sum));
		hotel._money-=sum;
		if (tag!=null)
			App.api.useGameMoney(sum, tag, tag);
	}
	
	private function applyLossAt(f,x,sum, ?reason:String) {
		applyLoss(sum, reason);
		logAction(
			L_ANIM( f, x, MoneyChange(Std.int(-Math.abs(sum))) )
		);
	}
	
	public function applyGain(sum:Int, ?tag:String) {
		sum = Std.int(Math.abs(sum));
		hotel._money+=sum;
		if (tag!=null)
			App.api.useGameMoney(sum, tag, tag);
	}
	
	public function applyFameGainAt(f,x, n:Int) {
		applyFameGain(n);
		logAction( L_ANIM(f,x, FameChange(n)) );
	}
	
	public inline function applyFameGain(n:Int) {
		hotel._fame+=n;
	}
	
	public function gainResearchPoint(n:Int) {
		if ( hotel.treeMaxed() )
			applyFameGain(Const.FAME_RESEARCH);
		else {
			hotel._rpoints+=n;
			if( hotel._rpoints==1 )
				logAction( L_HTML(template("mini/research.mtt", {n:n})) );
		}
	}
	
	public function applyGainAt(f,x,sum:Int, ?reason:String) {
		applyGain(sum, reason);
		logAction( L_ANIM(f,x,MoneyChange(sum)) );
	}
	
	public function applyShopItem(shop:ShopXml, shopItem:ShopItem) {
		switch(shopItem.effect) {
			case S_Item(item) :
				addItem(item);
			case S_Staff :
				hotel._staff.add( new _Staff(hotel._uniqId++) );
				validateGoal( G_BuyStaff );
			case S_Money(n) :
				applyGain(n);
			case S_Pack(catId) :
				for (sitem2 in shop.items)
					if ( sitem2.catId==catId && Type.enumIndex(sitem2.effect)!=Type.enumIndex(S_Pack(null)) )
						applyShopItem(shop, sitem2); // récursion
		}
	}

	private function addClientInRoomFromQueue(clientToAdd : _Client, floor : Int, x : Int) {
		for (c in hotel._clientQueue)
			if (c == clientToAdd._id) {
				registerClientInRoom(clientToAdd, floor, x, true);
				var r = getRoom(floor,x);
				if( r!=null && r._type==_TR_BEDROOM ) {
					logAction(L_ADD_A_CLIENT_IN_ROOM(clientToAdd._id, floor, x));
					logGameMsg( time, T.format.LRegisterClient({_name:clientToAdd._name, _n:_Room.getNumber(floor,x)}) );
					hotel._clientQueue.remove(clientToAdd._id);
					validateGoal(G_AddClient);
				}
			}
			
		addedThisTurn = clientToAdd;
		updateAffectMap();
	}
	
	private function moveClient(fromFloor, fromX, toFloor, toX) {
		var fromRoom = getRoom(fromFloor, fromX);
		var toRoom = getRoom(toFloor, toX);
		
		if (fromRoom==null || toRoom==null)
			throw Fatal("NoRoom");
		
		if (toRoom==fromRoom)
			throw L_ERROR(T.get.CantHostHere);
			
		var c = getClient(getRoom(fromFloor, fromX)._clientId);
		if (c==null)
			throw Fatal("NoClient");
			
		if (fromRoom._type != _TR_BEDROOM)
			throw L_ERROR(T.get.CantHostHere);
			
		if ( toRoom._type==_TR_BEDROOM && Lib.setTime(c._dateLeaving,0).getTime()==Lib.setTime(time,0).getTime() )
			throw L_ERROR(T.get.CantMoveOnLastDay);
			

		// déplacement
		registerClientInRoom(c, toFloor, toX, false); // fera un THROW si destination invalide
		fromRoom._clientId = null;
		logAction(L_MOVE_A_CLIENT(fromFloor, fromX, toFloor, toX));
		if( c._movePenalty==0 ) {
			var penalty = Std.int( Math.abs(Const.H_MOVE) - hotel.getTalent(TalentXml.get.easyMove) );
			c._movePenalty+=penalty;
		}
		if ( toRoom._type==_TR_BEDROOM )
			logGameMsg(time, T.format.LMoveClient( {_name:c._name, _from:_Room.getNumber(fromFloor, fromX), _to:_Room.getNumber(toFloor,toX)} ) );
		if ( toRoom._type==_TR_LAB )
			logGameMsg(time, T.format.LSacrified( {_name:c._name} ) );
		
		// emporte le staff avec lui !
		var staff = getStaffAt(fromFloor, fromX);
		if( staff!=null )
			if( toRoom._type!=_TR_LAB )
				staff._roomId = toRoom._id;
			else
				staff.finish(); // cas du labo
			
		updateAffectMap();
	}
	
	private function registerClientInRoom(c:_Client, floor:Int, x:Int, fl_fromQueue:Bool) {
		if (c==null)
			throw Fatal("NoClient");
			
		var r = hotel._rooms[floor][x];
		if (r==null)
			throw Fatal("NoRoom");
		
		if (r._type==_TR_NONE)
			throw L_ERROR( T.get.BuildBedroomFirst );

		if (r._type!=_TR_BEDROOM && r._type!=_TR_LAB)
			throw L_ERROR( T.get.CantHostHere );
				
		if (r._underConstruction != null)
			throw L_ERROR( T.get.RoomUnderConstruction );
			
		if (r._clientId!=null)
			throw L_ERROR( T.get.RoomNotVacant );
				
		if ( r._itemToTake != null)
			throw L_ERROR( T.get.ItemToPick );
		
		if ( getStaffAt(floor,x)!=null )
			throw L_ERROR( T.get.RoomNotVacant );
		
		// installation dans une chambre
		if ( r._type==_TR_BEDROOM ) {
			r._clientId = c._id;
			if ( fl_fromQueue ) {
				// init à l'entrée dans la chambre
				c.initService(hotel, time, Range.makeInclusive(1,12));
				c._activity = null;
				c.doActivity( DateTools.delta(time, DateTools.minutes(20+Std.random(50))) );
			}
		}
		
		// envoi au labo
		if ( r._type==_TR_LAB ) {
			if ( r._serviceEnd!=null && time.getTime() < r._serviceEnd.getTime() )
				throw L_ERROR(T.get.RoomUnderService);
				
			var pts = if (c._type==_MF_FRANK) Const.LAB_CLIENT_SPEC else Const.LAB_CLIENT;
			r._life += pts;
			r._serviceEnd = DateTools.delta(time, Const.LAB_DURATION);
			App.api.incrementGoal(App.GOALS.lab);
			
			// peur
			var chance = 100 - hotel.getTalentRatio(TalentXml.get.labFear)*66;
			for (hc in hotel._clients)
				if ( Std.random(100)<chance ) {
					hc._malusHappy += Const.H_LAB_HORROR;
					if ( !hotel.isStaying(hc) && hc._id!=c._id )
						logAction( L_ANIM(0,0, HappyChangeQueue(hc._id, Const.H_LAB_HORROR)) );
				}
			
			removeClient(c._id);
			logAction( L_ANIM(floor,x, ResearchUp(pts)) );
			logAction( L_ADD_A_CLIENT_IN_LAB(floor,x) );
		}
	}
	
	function moveAllDeco(f:Int, delta:Int) {
		for (d in hotel._deco)
			if (d._floor==f)
				d._x+=delta*Const.ROOM_WID;
	}

	
	public function solve(action : _PlayerAction) {
		debug("#SOLVE "+action);
		try {
			var h = time.getHours();
			var m = time.getMinutes();
			if( h==23 && m>=59 || h==0 && m<=1 )
				throw L_MSG(T.get.GameLocked);
			onBeginTurn();
			
			// on mémorise le happyness pour indiquer les changements dûs aux actions
			var oldHappyness = new IntHash();
			for (c in hotel._clients)
				oldHappyness.set(c._id, c.getHappyness());
				
			switch (action) {
				case P_DEBUG(f,x) :
					var r = getRoom(f,x);
					var c = getClient(r._clientId);
					//c.makeVip();
					var s = getStaffIn(r);
					throw L_MSG(""+s._endDate+" "+s._job+" "+s._roomId);
					
				case P_INIT:
					if ( !hotel.reachedQuest("beginning") && hotel._clientQueue.length==Const.FIRST_CLIENTS ) {
						// spécifique au tout début de partie
						logAction( L_MSG(T.get.Welcome1) );
						logAction( L_MSG(T.get.Welcome2) );
						logAction( L_QUEST( true, getQuestHtml(hotel.getQuest()) ) );
					}
					else
						if ( hotel.hasQuest() )
							logAction( L_QUEST( false, getQuestHtml(hotel.getQuest()) ) );

						
				case P_CLIENT_CALL :
					if ( !db.User.useTokens(Const.CLIENT_CALL, T.get.MuxxuBuyClient, "newcli") )
						throw L_ERROR( T.format.NotEnoughToken({_money:Const.CLIENT_CALL}) );
					var c = generateClient(time);
					logAction( L_ANIM(1,0, NewClient(c._id)) );
					
				case P_SWAP_QUEUE(cid1, cid2) :
					var idx1 = -1;
					var idx2 = -1;
					var q = Lambda.array(hotel._clientQueue);
					for (i in 0...q.length) {
						if (q[i]==cid1)	idx1 = i;
						if (q[i]==cid2)	idx2 = i;
					}
					if (idx1<0 || idx2<0)
						throw L_FATAL("error");
					while (idx1!=idx2) {
						if (idx1>idx2) {
							var tmp = q[idx1-1];
							q[idx1-1] = q[idx1];
							q[idx1] = tmp;
							idx1--;
						}
						else {
							var tmp = q[idx1+1];
							q[idx1+1] = q[idx1];
							q[idx1] = tmp;
							idx1++;
						}
					}
					hotel._clientQueue = Lambda.list(q);
					
				case P_VIEW_HOTEL(_) :
					// normalement, le solver n'est pas appelé dans ce cas ....
				
				case P_PING:
					majCdCLient(time);
					
				case P_ADD_CLIENT_FROM_QUEUE(c, f, r) :
					addClientInRoomFromQueue(getClient(c), f, r);
					hotel._active = true;
					
				case P_MOVE_CLIENT(oldF, oldR, nwF, nwR) :
					moveClient(oldF, oldR, nwF, nwR ) ;
					hotel._active = true;
					
				case P_SWAP_ROOM(f, r, t) :
					swapRoom(f, r, t);
					
				case P_TAKE_ITEM(f, r) :
					takeItem(f, r);
					
				case P_USE_ITEM(f, r, i) :
					useOneItem(f, r, i);
					
				case P_CLIENT_INFOS(cid) :
					if ( !hotel._clients.exists(cid) )
						throw Fatal(T.get.UnknownClient);
					var client = hotel._clients.get(cid);
					var room = getClientRoom(client);
					var pt = getRoomCoord(room);
					var nextService = DateTools.delta(client._serviceEnd, -Const.SERVICE_VISIBILITY);
					
					var l = L_HTML( template("mini/clientInfos.mtt", {
							client		: client,
							happyness	: client.getHappyness(),
							mrule		: T.getClientRule(client._type),
							leaveText	: deltaDays(time, client._dateLeaving),
							servMin		: if (!client.hasServiceWaiting(time)) null else Math.round((client._serviceEnd.getTime() - time.getTime()) / DateTools.minutes(1)),
							nextServ	: if( hotel.getTalent(TalentXml.get.serviceMedium)>0 && !client.hasServiceWaiting(time) && nextService.getTime()>time.getTime() && nextService.getTime()-time.getTime()<DateTools.days(1) && nextService.getTime()<client._dateLeaving.getTime() ) DateTools.format(nextService,T.get.TimeFormat),
							gain		: client.getBaseGain(hotel, room),
							money		: client._money,
						}) );
					logAction(l);
					
				case P_EXTEND_ROOF(x) :
					var cost = hotel.getExtensionCost();
					checkMoney(cost);
					if ( hotel._floors>=Const.MAX_HEIGHT )
						throw L_ERROR(T.get.HotelTooHigh);
					if (hotel._rooms[hotel._floors-1][x]._type==_TR_VOID)
						throw Fatal("illegal spot");
					var roof = new Array();
					for (x2 in 0...hotel._width) {
						var type = if (x==x2) _TR_NONE else _TR_VOID;
						roof.push( new _Room(hotel._uniqId++, type, hotel._floors) );
					}
					hotel._rooms[hotel._floors] = roof;
					hotel._floors++;
					hotel._design.set( hotel._floors-1, Reflect.copy(hotel._design.get(hotel._floors-2)) );
					validateGoal(G_ExtendAny);
					applyLossAt(hotel._floors-1, x, cost, "extend");
					//logAction(L_REFRESH);
					if( hotel.countRooms() > Const.MIN_BUILDING_SIZE_FAME )
						applyFameGainAt(hotel._floors-1, x, Const.FAME_BUILDING_SIZE);
					logAction( L_NEW_EXT_COST(hotel.getExtensionCost()) );
						

				case P_EXTEND_FLOOR_L(f) :
					var cost = hotel.getExtensionCost();
					checkMoney(cost);
					var row = hotel._rooms[f];
					if (row==null)
						throw Fatal("illegal floor");
					var replaceX = -1;
					while (row[replaceX+1]._type==_TR_VOID)
						replaceX++;
					if (replaceX<0 && hotel._width>=Const.MAX_WIDTH)
						throw L_ERROR(T.get.HotelTooLarge);
						
					//var newType = if (f==0) _TR_LOBBY_SLOT else _TR_NONE;
					var newType = _TR_NONE;
						
					if ( replaceX < 0 ) {
						row.insert(0, new _Room(hotel._uniqId++, newType, f) );
						updateWidth();
						if (hotel._width>Const.MAX_WIDTH)
							throw Fatal("hotel too large");
						for (f2 in 0...hotel._floors)
							if (f2 != f) {
								//var type = if (f2==0) _TR_LOBBY_SLOT else _TR_VOID;
								var type = _TR_VOID;
								hotel._rooms[f2].insert(0, new _Room(hotel._uniqId++, type, f2));
							}
					}
					else
						row[replaceX].setType( newType );
					moveAllDeco(f, 1);
					applyLossAt(f,0,cost, "extend");
					validateGoal(G_ExtendAny);
					if( hotel.countRooms() > Const.MIN_BUILDING_SIZE_FAME )
						applyFameGainAt(f, replaceX, Const.FAME_BUILDING_SIZE);
					logAction( L_NEW_EXT_COST(hotel.getExtensionCost()) );
					
					
				case P_EXTEND_FLOOR_R(f) :
					var cost = hotel.getExtensionCost();
					checkMoney(cost);
					var row = hotel._rooms[f];
					if (row==null)
						throw Fatal("illegal floor");
					var replaceX = row.length;
					while (row[replaceX-1]._type==_TR_VOID)
						replaceX--;
					if (replaceX>=Const.MAX_WIDTH)
						throw L_ERROR(T.get.HotelTooLarge);
						
					//var newType = if (f==0) _TR_LOBBY_SLOT else _TR_NONE;
					var newType = _TR_NONE;
						
					if (replaceX>=row.length) {
						row.push( new _Room(hotel._uniqId++, newType, f) );
						updateWidth();
						// on rempli de VOID les espaces vides créés
						for (f in 0...hotel._floors)
							for (x in 0...hotel._width)
								if (hotel._rooms[f][x]==null) {
									hotel._rooms[f][x] = new _Room(hotel._uniqId++, _TR_VOID, f);
								}
					}
					else
						row[replaceX].setType( newType );
						
					// décalage des accueils
					if ( f==0 ) {
						moveAllDeco(f, 1);
						var start = 0;
						while (hotel._rooms[f][start]._type==_TR_VOID)
							start++;
						var end = hotel._width-1;
						while (hotel._rooms[f][end]._type==_TR_VOID)
							end--;
						var r = hotel._rooms[f].splice(end,1)[0];
						hotel._rooms[f].insert(start, r);
					}
					validateGoal(G_ExtendAny);
					applyLossAt(f,replaceX, cost, "extend");
					if( hotel.countRooms() > Const.MIN_BUILDING_SIZE_FAME )
						applyFameGainAt(f, replaceX, Const.FAME_BUILDING_SIZE);
					logAction( L_NEW_EXT_COST(hotel.getExtensionCost()) );
						

				case P_SEND_STAFF(id, f, x) :
					var staff = getStaff(id);
					var job = determineJob(f, x);
					var r = getRoom(f,x);
					var c = getClient(r._clientId);
					verifyDisponibility(f, x, staff);
					staff.work(hotel, time, job, r, c);
					if (job==J_LOBBY) {
						validateGoal(G_StaffLobby);
						var prevTime = hotel._nextClient;
						majCdCLient(time);
						var mins = (hotel._nextClient.getTime() - prevTime.getTime()) / DateTools.minutes(1);
						logAction( L_ANIM(f,x, ClientTimeChange(Std.int(mins))) );
					}
					if (job==J_ATTEND_TO && staff._endDate.getTime()>=c._dateLeaving.getTime()) {
						staff.finish();
						throw L_ERROR(T.get.TooLateToAttend);
					}
					logAction( L_ADD_STAFF_IN_ROOM(f,x, staff._id, job) );
					solveStaff(time);
				
				case P_CANCEL_STAFF(floor,x) :
					var staff = getStaffAt(floor,x);
					var r = hotel._rooms[floor][x];
					if (staff==null)
						throw Fatal("NoStaff");
					if (r==null)
						throw Fatal("NoRoom");
					var prevTime = hotel._nextClient;
					var job = staff._job;
					staff.finish();
					solveStaff(time);
					majCdCLient(time);
					if (job==J_LOBBY) {
						var mins = (hotel._nextClient.getTime() - prevTime.getTime()) / DateTools.minutes(1);
						logAction( L_ANIM(floor,x, ClientTimeChange(Std.int(mins))) );
					}
					
				case P_LEVEL_UP(f,x) :
					var r = getRoom(f,x);
					if (r==null || r._underConstruction!=null)
						throw Fatal("illegal room");
					if ( r._type==_TR_BEDROOM && r._level>=Const.MAX_ROOM_LEVEL )
						throw Fatal("illegal room");
					if ( r._type==_TR_LOBBY && r._level>=Const.MAX_LOBBY_LEVEL )
						throw Fatal("illegal room");
					if ( r.isDamaged() )
						throw L_ERROR( T.get.RoomDirty );
					if ( r._type==_TR_BEDROOM ) {
						// amélioration de chambre
						var cost = Const.LEVELUP_COST[r._level+1];
						checkMoney(cost);
						r._level++;
						applyFameGainAt(f,x, Const.FAME_LUX_BEDROOM*r._level);
						r._underConstruction = DateTools.delta(time, Const.LEVELUP_DURATION);
						validateGoal( G_RoomLevel(r._level+1) );
						applyLossAt(f,x, cost, "rlvlup");
					}
					else if ( r._type==_TR_LOBBY ) {
						// amélioration de l'accueil
						var cost = Const.LEVELUP_LOBBY_COST[r._level+1];
						checkMoney(cost);
						r._level++;
						applyLossAt(f,x, cost, "rlvlup");
					}
					
				case P_REMOVE_ITEM(f,x,it) :
					var r = getRoom(f,x);
					if (r==null || !r.hasEquipment(it))
						throw Fatal("illegal room");
					r.removeEquipment(it);
					
				case P_SERVICE(f,x) :
					var r = getRoom(f,x);
					if (r==null || r._type!=_TR_BEDROOM || r._clientId==null)
						throw Fatal("illegal room");
					var c = getClient(r._clientId);
					if (c==null)
						throw Fatal("unknown client "+r._clientId);
					var sroomType = _Room.getServiceRoom(c._serviceType);
					var sroom : _Room = null;
					for (floor in hotel._rooms)
						for (r in floor)
							if (r._underConstruction==null && r._type==sroomType && r._serviceEnd==null)
								sroom = r;
					if (sroom==null)
						throw L_ERROR( T.format.NeedServiceRoom({_room:_Room.getRoomText(sroomType)._name}) );
					sroom._serviceEnd = DateTools.delta(time, DateTools.minutes(30));
					c._bonusHappy+=Const.H_SERVICE_OK;
					c.initService(hotel, time, Range.makeInclusive(12, 24));
					App.api.incrementGoal(App.GOALS.serv);
					validateGoal(G_Service);
				
				case P_SET_DECO(dlist) :
					var checkList : List<DecoItem> = haxe.Unserializer.run( haxe.Serializer.run(hotel._deco) );
					for (d in dlist) {
						var fl_found = false;
						for (d2 in checkList)
							if (d._type==d2._type && d._frame==d2._frame) {
								checkList.remove(d);
								fl_found = true;
								break;
							}
						if (!fl_found)
							throw L_ERROR("unknown item "+d._type+"("+d._type+")");
					}
					validateGoal(G_PlaceDeco);
					hotel._deco = dlist;
					
				case P_PAY_TAX :
					throw L_ERROR("disabled");
					//checkMoney(hotel.getTax());
					//payTax(time);
			}
		
			updateAffectMap();
			updateHappyness(time);

			// affichage des changements de happyness
			if( action!=P_INIT )
				for (c in hotel._clients)
					if ( oldHappyness.exists(c._id) && c.getHappyness()!=oldHappyness.get(c._id) ) {
						var pt = getRoomCoord( getClientRoom(c) );
						logAction( L_ANIM(pt.floor, pt.x, HappyChange(c._happyness-oldHappyness.get(c._id))) );
					}
				
			onEndTurn();
			hotel._lastDate = DateTools.delta(time, 1000);
			checkQuests();
}
		catch (l:_Log) {
			logAction(l);
		}
		catch (e:CriticalError) {
			switch(e) {
				case Fatal(msg) :
					logAction(L_REFRESH);
					logAction(L_FATAL(msg));
			}
		}
		//catch (e:Dynamic) {
			//throw("unknown error\n"+e);
		//}
		return hotel;
	}
	
	public static function removeUnderscores(o:Dynamic) {
		var cs = new CustomSerializer();
		cs.serialize(o);
		return haxe.Unserializer.run( cs.toString() );
	}
	
	private function template( file:String, ?data:Dynamic ){
		var context = new Context();
		context.data_url = App.fullApi.getDataURL();
		context.hotel = hotel;
		
		if( data!=null ) {
			// on vire les leading "_" sur les noms de champs
			var data = removeUnderscores(data);
			//var cs = new CustomSerializer();
			//cs.serialize(data);
			//data = haxe.Unserializer.run( cs.toString() );
			
			// copie des champs dans ctx
			for (key in Reflect.fields(data))
				Reflect.setField(context, key, Reflect.field(data, key));
		}
			
		App.configureTemplo();
		
		var html = new templo.Loader(file).execute(context);
		//html = StringTools.replace(html, "\t", "");
		html = StringTools.replace(html, "\r\n", "");
		return html;
	}
	
	private function swapRoom(f:Int, x:Int, t:_TypeRoom) {
		var r = hotel._rooms[f][x];
		if (r._type==_TR_LOBBY)
			throw Fatal("CantSwapLobby");
		
		// limitations par level
		if ( !hotel.canBuildRoom(t) )
			throw Fatal("illegal action");
			
		var all = _Room.getBuildList(f, r._type);
		if (!all.remove(t))
			throw Fatal("illegal action");
			
		/*
		if (t==_TR_LOBBY) {
			// un lobby se construit automatiquement sur le premier slot dispo
			var slots = new List();
			for (r2 in hotel._rooms[0])
				if (r2._type==_TR_LOBBY_SLOT)
					slots.add(r2);
			//if (slots.length <= 1)
				//throw L_MSG( T.get.TooManyLobby );
			var lobbyCpt = Lambda.filter(hotel._rooms[0], function(r) { return r._type==_TR_LOBBY; }).length;
			if (hotel._staff.length<=lobbyCpt*Const.MAX_LOBBY_CAPACITY)
				throw L_ERROR( T.format.NotEnoughStaffForLobby({_n:Const.MAX_LOBBY_CAPACITY}) );
			r = slots.last();
		}*/
		
		if (r._itemToTake != null)
			throw L_ERROR( T.get.ItemToPick );
			
		if (r._serviceEnd != null )
			throw L_ERROR( T.get.RoomUnderService );
			
		if (r._underConstruction != null )
			throw L_ERROR( T.get.RoomUnderConstruction );
			
		if ( r.isDamaged() )
			throw L_ERROR( T.get.RoomDirty );
		
		if (r._clientId != null)
			throw L_ERROR( T.get.RoomNotVacant );
		
		for (g in hotel._staff)
			if (g._roomId == r._id)
				throw L_ERROR( T.get.RoomNotVacant );
				
		if ( t==_TR_LAB && hotel.countRooms(t)>=2 )
			throw L_ERROR(T.format.RoomCountLimit({_n:2}));

		if ( _Room.isSpecialRoom(t) && hotel.countRooms(t)>=3 )
			throw L_ERROR(T.format.RoomCountLimit({_n:3}));

		var cost = if(_Room.isSpecialRoom(t)) hotel.getSpecialRoomCost() else _Room.getRoomCost(t);
		checkMoney(cost);
		
		r._effectSpread = new List();
		r.removeEquipments();
		r._itemToTake = null;
		r._level = 0;
		r.setType(t);
		if( hotel._level>0 )
			App.api.incrementGoal(App.GOALS.room);
		
		logAction(time, L_NEW_SROOM_COST(hotel.getSpecialRoomCost()) );
		
		if (t==_TR_LAB)
			r._life = 0;
			
		if (t==_TR_LOBBY)
			addDecoItem(DecoDesk); // bureau gratuit !
		if(t==_TR_BEDROOM)
			r._underConstruction = DateTools.delta(time, Const.BUILD_BEDROOM_DURATION);
		else
			r._underConstruction = DateTools.delta(time, Const.BUILD_SPECIAL_DURATION);
		if ( t!=_TR_LOBBY )
			validateGoal( G_BuildRoom );
		applyLossAt(f,x,cost, "rbuild");
	}
	
	
	private function getStaffAt(f, x) {
		var list = getStaffListAt(f,x);
		if (list.length==0)
			return null;
		else
			return list.first();
	}

	private function getStaffIn(r:_Room) {
		for (s in hotel._staff)
			if (s._roomId == r._id)
				return s;
		return null;
	}

	private function getStaffListAt(f, x) {
		var list = new List();
		for (s in hotel._staff)
			if (s._roomId == getRoom(f, x)._id)
				list.add(s);
		return list;
	}
	
	private function determineJob(f:Int, x:Int) {
		var r = hotel._rooms[f][x];
		if (r._type == _TR_LOBBY) {
			// accueil
			if (getStaffListAt(f,x).length >= Const.MAX_LOBBY_CAPACITY[r._level])
				throw L_ERROR( T.get.LobbyFull );
			else
				return J_LOBBY;
		}
		if (r._type == _TR_BEDROOM) {
			if (r._clientId== null) {
				// nettoyage
				if ( !r.isDamaged() )
					throw L_ERROR( T.get.UselessCleaning );
				return J_HOUSEWORK;
			}
			
			// câlins
			if (r._clientId!=null)
				return J_ATTEND_TO;
		}
		if (r._type != _TR_BEDROOM && r._type != _TR_NONE && r._clientId!=null)
			throw L_ERROR( T.get.NoJobInSpecial );
		throw L_MSG( T.get.NoJob );
	}
	
	//private function useStaff(staff:_Staff, job:_TypeJob, floor, x ) {
		//var r = getRoom(floor, x);
		//if ( staff._endDate!=null && time.getTime() < staff._endDate.getTime() )
			//throw Fatal("StaffNotAvailable");
		//if (idToClient(r._clientId) == null && job == J_ATTEND_TO)
			//throw Fatal("NoClient");
		//if (job != J_LOBBY)
			//if (getStaff(floor,x)!=null)
				//throw L_MSG( T.get.OnlyOneStaff );
				//
		//staff.work(time, job, r);
	//}
	
	//private function groomIsWorking(id:Int) {
		//for (g in hotel.staff_list)
			//if (g.roomId == id)
				//return true;
		//return false;
	//}
	
	function solveDeaths(now:Date) {
		var n = 0;
		for (c in hotel._clients)
			if ( c.isUnstable() && now.getTime()>=c._death.getTime() ) {
				// explosion
				var r = getClientRoom(c);
				var pt = getRoomCoord(r);
				if ( c._happyness <= 0 )
					logGameMsg(now, T.format.LExplodedAngry({_name:c._name}) );
				else
					logGameMsg(now, T.format.LExplodedHappy({_name:c._name}) );
				mess(pt.floor,pt.x,-100);
				r.removeEquipments();
				var staff = getStaffAt(pt.floor,pt.x);
				if ( staff!=null )
					staff.finish();
				removeClient(hotel._rooms[pt.floor][pt.x]._clientId);
				logAction( L_ANIM(pt.floor,pt.x, Explode) );
				n++;
			}
		return n;
	}
	
	private function solveStaff(now:Date) {
		// JOB
		for (s in hotel._staff) {
			switch(s._job) {
				case J_HOUSEWORK : // TODO : à recoder
					if (now.getTime() >= s._endDate.getTime() ) {
						var r = idToRoom(s._roomId);
						var cost = Const.REPAIR_COST;
						//if (r._life==0)
							//cost*=2;
						if ( r._level==1 )
							cost = Math.ceil(cost*1.5);
						if ( r._level==2 )
							cost = Math.ceil(cost*2);
						cost = Math.ceil(cost * (1 - hotel.getTalentRatio(TalentXml.get.repairCost)*0.50));
						var pt = getRoomCoord(r);
						applyLossAt(pt.floor, pt.x, cost, "repair");
						r.tidy(1);
						logAction(L_ROOM_CHANGE_LIFE(pt.floor, pt.x));
						if ( r.isDamaged() ) {
							// pas complètement réparé
							logGameMsg(now, T.format.LRepair( { _n:_Room.getNumber(pt.floor, pt.x), _money:cost } ));
							s.work(hotel, now, J_HOUSEWORK, r, null);
						}
						else {
							// finir
							logGameMsg(now, T.format.LEndRepair( { _n:_Room.getNumber(pt.floor, pt.x), _money:cost } ));
							s.finish();
						}
					}
				case J_LOBBY :
					
				case J_ATTEND_TO :
					if (now.getTime() >= s._endDate.getTime() ) {
						// fini
						var room = idToRoom(s._roomId);
						var pt = getRoomCoord(room);
						var idc = room._clientId;
						var c = getClient(idc);
						if (c==null) {
							s.finish();
							continue;
						}
						var cost = Math.ceil( Const.ATTENDING_COST * (1-hotel.getTalentRatio(TalentXml.get.attendCost)*0.60));
						var chance = Const.BASE_ATTENDING_CHANCE + hotel.getTalentRatio(TalentXml.get.attendChance)*30;
						if (Std.random(100) < chance) {
							c._bonusHappy += Const.H_STAFF_ATTENDANT;
							logGameMsg(now, T.format.LAttendingSuccess({_name:getFullName(c), _gain:Const.H_STAFF_ATTENDANT, _money:-cost}) );
							logAction( L_ANIM(pt.floor, pt.x, HappyChange(Const.H_STAFF_ATTENDANT)) );
						}
						else
							logGameMsg(now, T.format.LAttendingFail({_name:getFullName(c), _money:-cost}) );
						applyLossAt(pt.floor, pt.x, cost, "attend");
						s.finish();
					}
				case J_ADVERT :
				case J_NONE :
			}
		}
	}
	
	
	private function verifyDisponibility(f:Int , r:Int, groom:_Staff) {
		var room = getRoom(f, r);
		if (room._underConstruction != null)
			throw L_ERROR( T.get.RoomUnderConstruction );
		if (room._type == _TR_LOBBY)
			return true;
		for (g in hotel._staff){
			if (g == groom)				continue;
			if (g._roomId == room._id)	throw L_ERROR( T.get.OnlyOneStaff );
		}
		return true;
	}
	
	function updateHappyness(now:Date) {
		var allClients = new List();
		for (i in 0...hotel._floors) {
			for (j in 0...hotel._width) {
				var r = hotel._rooms[i][j];
				var c = getClient(r._clientId);
				if ( c!=null && r._type==_TR_BEDROOM ) {
					allClients.add(c);
						
					var h = c._happyness;
					c._happyLog = new List();
					c._happyLog.add( { _mod:M_BASE,		_n:c._baseHappy,		_present:true } );
					c._happyLog.add( { _mod:M_MALUS,	_n:c._malusHappy,		_present:true } );
					c._happyLog.add( { _mod:M_BONUS,	_n:c._bonusHappy,		_present:true } );
					c._happyLog.add( { _mod:M_MOVE,		_n:-c._movePenalty,		_present:true } );
					c._happyLog.add( { _mod:M_ROOM,		_n:r.getRoomStats(c),	_present:true } );
					
					c._happyness =
						calcLikes(c, i, j)
						+ c._baseHappy
						+ c._malusHappy
						+ c._bonusHappy
						- c._movePenalty
						+ r.getRoomStats(c);
				}
			}
		}

		verifyHysteria(allClients);
		verifyBombs(now);
	}
	
	private function verifyHysteria(all:List<_Client>) {
		var alreadyActive = new List();
		for (c in all)
			if (c._type==_MF_SM && c._happyness <= Const.HYSTERIA_LIMIT)
				alreadyActive.add(c);
				
		for(c in alreadyActive)
			hysteria(all, c._id);
	}
	
	private function hysteria(all:List<_Client>, ?hystId:Int) {
		var triggered = new List();
		// pénalité à tous les autres
		var loss = Std.int( Math.abs(Const.H_HYSTERIC) );
		for (c in all)
			if (c._id!=hystId ) {
				if (c._type==_MF_SM) {
					// ca touche une autre hystérique
					var newh = c._happyness-loss;
					if (c._happyness > Const.HYSTERIA_LIMIT && newh <= Const.HYSTERIA_LIMIT)
						triggered.add(c);
				}
				c._happyness -= loss;
				c._happyLog.add( { _mod:M_HYSTERIA,	_n:-loss, _present:true } );
			}
		for (c in triggered) {
			hysteria(all, c._id);
		}
	}
	
	//private function feedHappyLog(base:Int, roomState:Int, hysterie:Int, client : _Client ) {
		//client._happyLog = new List();
		//var c = [base, roomState, -hysterie];
		//var m = [M_BASE, M_MOVE, M_ROOM, M_HYSTERIE];
		//for (i in 0...c.length) {
			//var fl:HL = {
				//n	: c[i],
				//mod	: m[i],
			//}
			//client._happyLog.add(fl);
		//}
	//}
	
	private function calcHysteria(idClient:Int) {
		var cpt1 = 0;
		var cpt2 = 0;
		for (f in 0...hotel._floors) {
			for (x in 0...hotel._width) {
				var r = hotel._rooms[f][x];
				if (r._type != _TR_BEDROOM)
					continue;
				var c = getClient(r._clientId);
				if ( c!=null && c._type==_MF_SM) {
					if (c._id == idClient)
						continue;
					if (c._happyness > 0 && c._happyness < 5)
						cpt1 ++;
					else if (c._happyness <= 0)
						cpt2 ++;
				}
			}
		}
		return [cpt1, cpt2];
	}
	
	
	
	
	
	private function calcLikes(client:_Client, floor, room) {
		// TODO : implémenter joie de vivre des zombies
		var total = 0;
		
		// effets spéciaux
		for (e in baseEffect[floor][room])
			switch(e._effect) {
				case _JOY :
					total += Const.H_JOY;
					client._happyLog.add( { _n:Const.H_JOY, _mod:M_LIKE(e._effect), _present:true } );
				default :
			}
		
		// likes
		for (like in client._like) {
			var listStackEffect = new List();
			listStackEffect = isOn(like, baseEffect[floor][room]);
			if (!listStackEffect.isEmpty()) {
				for (e in listStackEffect) {
					total += Const.H_LIKE_OK;
					client._happyLog.add( { _n:Const.H_LIKE_OK, _mod:M_LIKE(like), _present:true } );
				}
			}
			else {
				total += Const.H_LIKE_NOK;
				client._happyLog.add( { _n: Const.H_LIKE_NOK, _mod:M_LIKE(like), _present:false } );
			}
		}
		
		// dislikes
		for (dislike in client._dislike) {
			var listStackEffect = new List();
			listStackEffect = isOn(dislike, baseEffect[floor][room]);
			if (!listStackEffect.isEmpty()) {
				for (e in listStackEffect) {
					total += Const.H_DISLIKE_NOK;
					client._happyLog.add( { _n:Const.H_DISLIKE_NOK, _mod:M_LIKE(dislike), _present:true } );
				}
			}
			else {
				total += Const.H_DISLIKE_OK;
				client._happyLog.add( { _n:Const.H_DISLIKE_OK, _mod:M_LIKE(dislike), _present:false } );
			}
		}
		return total;
	}
	
	private function verifyBombs(now:Date) {
		for (f in 0...hotel._floors)
			for (x in 0...hotel._width) {
				var r = hotel._rooms[f][x];
				if (r._type!=_TR_BEDROOM)
					continue;
				var c = getClient(r._clientId);
				if (c==null || c._type!=_MF_BOMB)
					continue;
				if (c._happyness>=_Client.MAX_HAPPYNESS || c._happyness <= 0) {
					// saturation
					if ( !c.isUnstable() ) {
						logGameMsg(now, T.format.LBecameUnstable( { _name:c._name } ));
						c._death = DateTools.delta(now, DateTools.hours(3));
					}
				}
				else
					// stable
					if ( c.isUnstable() ) {
						logGameMsg(now, T.format.LBecameStable( { _name:c._name } ));
						c._death = null;
					}
					//if ( c._happyness <= 0 )
						//logGameMsg(time, T.format.LExplodedAngry({_name:c._name}) );
					//else
						//logGameMsg(time, T.format.LExplodedHappy({_name:c._name}) );
					//mess(f,x,-100);
					//r.removeEquipments();
					//var staff = getStaffAt(f,x);
					//if ( staff!=null )
						//staff.finish();
					//removeClient(hotel._rooms[f][x]._clientId);
					//logAction( L_ANIM(f,x, Explode) );
			}
	}
	
	
	private function countHours(?min:String ) {
		var h = 0;
		var ld = hotel._lastDate;
		var p = DateTools.parse(time.getTime() - ld.getTime());
		var hours = p.days * 24 + p.hours;
		if (min == "min")
			return p.minutes;
		return hours;
	}
	
	private function fmt(date:Date) {
		return DateTools.format(date, "(%d) %H:%M:%S");
	}
	
	private function getActiveHysterics() {
		var list = new List();
		for (floor in hotel._rooms)
			for (r in floor) {
				var c = getClient(r._clientId);
				if (c != null && r._type==_TR_BEDROOM && c._type==_MF_SM && c._happyness <= 5)
					list.add(c._id);
			}
		return list;
	}
	
	private function getNextImportantDate(now:Date) {
		var stamps = new List();
		
		// clients
		stamps.add( hotel._nextClient.getTime() );
		for (c in hotel._clients) {
			if (c._activityEnd != null)
				stamps.add( c._activityEnd.getTime() );
			stamps.add( c._dateLeaving.getTime() );
			if( c._serviceEnd!=null )
				stamps.add( c._serviceEnd.getTime() );
			if( c._death!=null )
				stamps.add( c._death.getTime() );
		}
		
		// rooms
		for (f in 0...hotel._rooms.length)
			for (x in 0...hotel._rooms[f].length) {
				var r = hotel._rooms[f][x];
				if ( r._underConstruction != null )
					stamps.add( r._underConstruction.getTime() );
				if ( r._serviceEnd!=null )
					stamps.add( r._serviceEnd.getTime() );
			}
			
		// staff
		for (s in hotel._staff)
			if(s._endDate!=null)
				stamps.add( s._endDate.getTime() );
				
		// minuit
		stamps.add( DateTools.delta( Lib.setTime(now, 0), DateTools.days(1) ).getTime() );
		
		// ouverture du matin
		var wakeUp = Lib.setTime(now, _Hotel.WAKEUP_HOUR).getTime();
		if ( now.getTime()<wakeUp ) stamps.add(wakeUp);
		
		// départ de clients
		var leaveDate = Lib.setTime(now, Const.LEAVE_TIME).getTime();
		if ( now.getTime()<leaveDate ) stamps.add(leaveDate);
				
		// filtrage
		var closest = DateTools.delta(now, DateTools.days(1)).getTime();
		var now = now.getTime();
		for (d in stamps)
			if ( d>now && d<closest )
				closest = d;
				
		var now = Date.fromTime(now);
		var list = new List();
		for (s in stamps)
			list.add( Date.fromTime(s).toString() );
		
		return Date.fromTime(closest);
	}
	
	
	private function onBeginTurn() {
		//hotel._lastDate = DateTools.delta(hotel._lastDate, -DateTools.days(365));
		//hotel._lastDate = Date.fromString("2012-12-25 08:00:00");
		debug("--- onBeginTurn last=" + sdate(hotel._lastDate) + " now=" + sdate(time) + " ----------");
		
		addedThisTurn = null;
		
		if( hotel.hasQuest() )
			qman = new QuestManager(this, hotel.getQuest());
		else
			qman = null;
			
		// clients envoyés par des amis
		var recentFriendClients = new IntHash();
		if (hotel._friends.length > 0) {
			if (hotel._friends.length==1)
				logAction( L_MSG(T.get.GotFriendClient) );
			else
				logAction( L_MSG(T.get.GotFriendClients) );
			while ( hotel._friends.length > 0 ) {
				var c = hotel._friends.pop();
				c._dateLeaving = DateTools.delta(Lib.setTime(time,Const.LEAVE_TIME), DateTools.days(1));
				recentFriendClients.set(c._id, true);
				addInQueue(time, c);
			}
		}
		
		// on répertorie les hystérics actuels
		turnHysterics = getActiveHysterics();
		
		// avancement du temps
		var ld = Date.fromString( hotel._lastDate.toString() ); // copie
		var emptyDays = 0;
		var loops = 0;
		var fl_absence = time.getTime()-hotel._lastDate.getTime() >= Const.ABSENCE_DURATION;
		while (ld.getTime() <= time.getTime()) {
			//var next = DateTools.delta(	ld, timeStep);
			debug("ld="+DateTools.format(ld,"%m-%d %H:%M"));
			//if ( next.getTime() > time.getTime() )
				//next = Date.fromString(time.toString());
			playTurn(ld);
		
			// ouverture
			var wakeUp = Lib.setTime(ld, _Hotel.WAKEUP_HOUR);
			if ( ld.getTime() == wakeUp.getTime() )
				onWakeUp(ld);

			var midnight = Lib.setTime(ld, 0);
			if ( ld.getTime() == midnight.getTime() ) {
				// minuit
				debugForced(
					"midnight ("+printDay( DateTools.delta(midnight, -DateTools.days(1)) )+"-"+printDay(midnight)+")"+
					"last="+hotel._lastDate+" ld="+ld+"("+ld.getTime()+") time="+time+" mid="+midnight+"("+midnight.getTime()+")"
				);
				validateGoal( G_Midnight );
				logGameMsg(T.format.LMidnight({
					_date1	: printDay( DateTools.delta(midnight, -DateTools.days(1)) ),
					_date2	: printDay(midnight),
				}), "fat");
				payment(midnight);
				clearQueue(recentFriendClients);
				hotel._lastClient = wakeUp;
				hotel._nextClient = wakeUp;
				
				if ( hotel.isEmpty() ) {
					emptyDays++;
					if ( emptyDays>=2 && !Config.DEBUG )
						hotel._gameLog = new List();
				}
	
				// fin de semaine
				if ( hotel._active &&  Lib.getDay(DateTools.delta(ld,-DateTools.days(1)))==Const.TAX_NIGHT )
					payTax(midnight);
			}

			var prev = ld;
			ld = getNextImportantDate(ld);
			if (loops++>=8000) {
				// Longue absence (infinite loop)
				ld = time;
				fl_absence = true;
				hotel._lastDate = time;
				hotel._lastClient = time;
				hotel._nextClient = time;
				hotel._debugLog = new List();
				hotel._gameLog = new List();
				clearQueue(recentFriendClients);
				break;
			}
		}
		
		// longue absence
		if ( fl_absence )
			welcomeBack();
	}
	
	function playTurn(now:Date) {
		majRoom(now);
		solveStaff(now);

		if ( solveDeaths(now)>0 ) {
			updateAffectMap();
			updateHappyness(now);
		}
		
		popClients(now, false);
		if ( clientDepartures(now)>0 ) {
			updateAffectMap();
			updateHappyness(now);
		}
		playIAClient(now);

		// évènements
		if ( now.getTime()>=hotel._nextEvent.getTime() )
			playRandomEvent(now);
		
		updateServices(now);
	}
	
	private function countInFloor(f:Int, t:_TypeRoom) {
		var n = 0;
		for (r in hotel._rooms[f])
			if (r._type == t)
				n++;
		return n;
	}
	
	function playRandomEvent(now:Date) {
		
		var rl = new mt.deepnight.RandList();
		rl.add("room_bad",	 	100);
		rl.add("room_happy",	80);
		rl.add("floor_happy",	5);
		rl.add("vip",			5);
		if ( hotel._level == 0 )
			rl.add("",		60);
		else {
			rl.add("room_accident", 	100);
			rl.add("theft",	5);
		}
		if (hotel._level>=3) {
			rl.add("floor_accident",	2);
			rl.add("sblurb",			5);
		}
		
		
		var e = rl.draw().toLowerCase();
		if ( hotel.isEmpty() )
			e = "";
			
		//if ( Config.DEBUG ) {
			//e = "sblurb";
			//logAction( L_MSG(now.toString() + " : event="+e+" \n"+rl.print().join("\n")) );
		//}
		
		var tg = new TextGen( Std.random(999999) );
		switch(e) {
			case "" : // rien
			case "sblurb" :
				// changement de tous les likes
				var me = this;
				var rooms = Lambda.array( Lambda.filter( getRooms(_TR_BEDROOM), function(r) { return r._clientId != null; } ) );
				if (rooms.length > 0) {
					var r = rooms[Std.random(rooms.length)];
					var pt = getRoomCoord(r);
					var c = getClient(r._clientId);
					c.brainWash(hotel);
					logAction( now, L_EVENT(T.format.EventSblurb( { _name:c._name, _room:_Room.getNumber(pt.floor,pt.x)} )) );
				}
				
			case "vip" :
				// vip caché
				var me = this;
				var rooms = Lambda.array( Lambda.filter( getRooms(_TR_BEDROOM), function(r) { return r._clientId != null && !me.getClient(r._clientId)._vip; } ) );
				if (rooms.length > 0) {
					var r = rooms[Std.random(rooms.length)];
					var pt = getRoomCoord(r);
					var c = getClient(r._clientId);
					c.makeVip();
					logAction( now, L_EVENT(T.format.EventVip( { _name:c._name, _room:_Room.getNumber(pt.floor,pt.x)} )) );
				}
			
			case "room_accident" :
				// explosion
				var list = getRooms(_TR_BEDROOM);
				if (list.length > 0) {
					var r = Lambda.array(list)[ Std.random(list.length) ];
					var pt = getRoomCoord(r);
					mess(pt.floor, pt.x, -3);
					var tg = new TextGen( Std.int(now.getTime()) );
					logAction( now, L_EVENT(T.format.EventRoomFailure({_n:_Room.getNumber(pt.floor, pt.x), _event:tg.get("roomAccident")})) );
					logAction( L_ANIM(pt.floor, pt.x, Explode) );
				}
				
			case "floor_accident" :
				// explosion d'un étage entier
				var floors = new Array();
				for (i in 1...hotel._floors)
					if ( countInFloor(i, _TR_BEDROOM) >= 1 )
						floors.push(i);
				if(floors.length>0) {
					var f = floors[Std.random(floors.length)];
					hotel._design.get(f)._wallColor = -2;
					hotel._design.get(f)._wall = 0;
					logAction( now, L_EVENT(T.format.EventFloorFailure( { _f:f, _event:tg.get("floorAccident") } )) );
					for(r in hotel._rooms[f]) {
						var pt = getRoomCoord(r);
						mess(pt.floor, pt.x, -3);
						if(r._clientId!=null)
							removeClient(r._clientId);
						logAction( L_ANIM(pt.floor, pt.x, Explode) );
					}
				}
				
			case "theft" :
				// client voleur
				var rooms = Lambda.array( Lambda.filter( getRooms(_TR_BEDROOM), function(r) { return r._clientId != null; } ) );
				if (rooms.length > 0) {
					var r = rooms[Std.random(rooms.length)];
					var pt = getRoomCoord(r);
					var c = getClient(r._clientId);
					var loss = 15 + Std.random(50);
					r.removeEquipments();
					var staff = getStaffIn(r);
					if (staff!=null)
						staff.finish();
					logAction( now, L_EVENT(T.format.EventTheft( { _name:c._name, _loss:loss, _room:_Room.getNumber(pt.floor,pt.x), _currency:T.get.Currency} )) );
					removeClient(r._clientId);
					applyLossAt(pt.floor, pt.x, loss, "theft");
				}
				
			case "floor_happy" :
				// client câlin avec tout l'étage
				var rooms = Lambda.array( Lambda.filter( getRooms(_TR_BEDROOM), function(r) { return r._clientId != null; } ) );
				if (rooms.length > 0) {
					var r = rooms[Std.random(rooms.length)];
					var pt = getRoomCoord(r);
					var gain = 2;
					logAction( now, L_EVENT(T.format.EventLove( { _gain:gain, _room:_Room.getNumber(pt.floor, pt.x), _gift:tg.get("gift") } )) );
					for (r2 in hotel._rooms[pt.floor])
						if ( r2._clientId != null && r2._type == _TR_BEDROOM ) {
							var c = getClient(r2._clientId);
							c._bonusHappy += gain;
							var pt = getRoomCoord(r2);
							logAction( L_ANIM(pt.floor, pt.x, HappyChange(gain)) );
						}
				}
				
			case "room_bad" :
				// client ayant un petit accident
				var rooms = Lambda.array( Lambda.filter( getRooms(_TR_BEDROOM), function(r) { return r._clientId != null; } ) );
				if (rooms.length > 0) {
					var r = rooms[Std.random(rooms.length)];
					var pt = getRoomCoord(r);
					var loss = 1;
					var c = getClient(r._clientId);
					c._malusHappy -= loss;
					logAction( now, L_EVENT(T.format.EventSad( { _loss:loss, _room:_Room.getNumber(pt.floor, pt.x), _accident:tg.get("smallAccident") } )) );
					logAction( L_ANIM(pt.floor, pt.x, HappyChange(-loss)) );
				}
					
			case "room_happy" :
				// client ayant un petit événement heureux
				var rooms = Lambda.array( Lambda.filter( getRooms(_TR_BEDROOM), function(r) { return r._clientId != null; } ) );
				if (rooms.length > 0) {
					var r = rooms[Std.random(rooms.length)];
					var pt = getRoomCoord(r);
					var gain = 1;
					var c = getClient(r._clientId);
					c._bonusHappy+=gain;
					logAction( now, L_EVENT(T.format.EventHappy( { _gain:gain, _room:_Room.getNumber(pt.floor, pt.x), _event:tg.get("smallHappyEvent") } )) );
					logAction( L_ANIM(pt.floor, pt.x, HappyChange(gain)) );
				}
				
			default :
				logAction( L_ERROR("Unknown event " + e) );
		}
		
		updateAffectMap();
		updateHappyness(now);
		hotel.resetEvent(now);
	}
	
	private function onEndTurn() {
		debug("onEndTurn");
		
		// hypno chat
		if ( addedThisTurn != null && addedThisTurn._type == _MF_FLYING && addedThisTurn.getHappyness()>=Const.HYPNO_MIN_HAPPYNESS ) {
			var c = generateClient(time, _MF_FLYING);
			logAction( L_ANIM(1,0, NewClient(c._id)) );
		}
		
		// hystériques
		var endHyst = getActiveHysterics();
		var calmed = new List();
		for (cid in turnHysterics)
			if ( !endHyst.remove(cid) )
				calmed.add(cid);
		// nouveaux hysterics
		for (cid in endHyst) {
			var c = getClient(cid);
			if(c!=null)
				logGameMsg(time, T.format.LStartHysteria({_name:c._name}));
		}
		// ceux qui se sont calmés dans le tour
		for (cid in calmed) {
			var c = getClient(cid);
			if(c!=null)
				logGameMsg(time, T.format.LEndHysteria({_name:c._name}));
		}
		
		// si l'action du solve a altéré la date du nextClient, il faut la vérifier à nouveau sur endTurn !
		popClients(time, true);
	}
	
	function onWakeUp(now:Date) {
		//for( i in 0...Std.int(hotel.getTalent(TalentXml.get.advert)) )
			//generateClient(now);
			
		for (c in hotel._campaigns) {
			switch(c.e) {
				case CE_Client(n) :
					for (i in 0...n)
						generateClient(now);

				case CE_Vip(n) :
					for (i in 0...n)
						generateClient(now, true);
			}
		}
		hotel._campaigns = new List();
			
		// effet hypno-chat
		//for (c in hotel._clients)
			//if( c._type==_MF_FLYING && !hotel.isInQueue(c) )
				//generateClient(now);
	}
	
	function payTax(date:Date) {
		debug("------- END OF WEEK ---------------");
		var tax = hotel.getTax();
		var data = {
			level		: hotel.getLevelForDisplay(),
			tax			: tax,
			before		: hotel._money,
			after		: -1,
			success		: false,
			help		: 0,
			discount	: 0,
			active		: hotel._active,
			date1		: printDay( DateTools.delta(date, -DateTools.days(7)) ),
			date2		: printDay( DateTools.delta(date, -DateTools.days(1)) ),
		}
		var fame = hotel.getTaxFame();
		if (hotel._active) {
			// paiement
			if (hotel._money>=tax) {
				// progression
				applyLoss(tax, "tax");
				hotel._level++;
				data.success = true;
			}
			else
				if ( hotel._money<100 && hotel._level<=2 ) {
					// aide
					var help = 300-hotel._money;
					applyGain(help, "taxhlp");
					data.help = help;
				}
		}
		data.after = hotel._money;
		logAction( L_HTML(template("mini/week.mtt", data)) );
		hotel._active = false;
		
		if (data.success) {
			// level up (post-process)
			var unlockedRooms = new List();
			for (key in Type.getEnumConstructs(_TypeRoom)) {
				var tr = Type.createEnum(_TypeRoom, key);
				if ( !_Hotel._canBuildRoom(tr, hotel._level-1) && hotel.canBuildRoom(tr) )
					unlockedRooms.add( _Room.getRoomText(tr) );
			}
			logAction( L_HTML(template("mini/levelUp.mtt", {
				level			: hotel.getLevelForDisplay(),
				realLevel		: hotel._level,
				//score			: hotel.getScores(),
				unlockedRooms	: unlockedRooms,
				fame			: fame,
			})) );
			applyFameGain(fame);
			validateGoal(G_Level);
		}
	}
	
	function welcomeBack() {
		hotel._actionLog = new List();
		for (floor in hotel._rooms)
			for (r in floor)
				r.tidy(_Room.MAX_LIFE);
		var sum = Const.ABSENCE_BONUS;
		if (hotel._money<0)
			hotel._money=0;
		applyGain(sum);
		logAction(L_HTML(
			template("mini/welcomeBack.mtt", {
				money	: sum,
			})
		));
		while (hotel._clientQueue.length<5)
			generateClient(time);
	}
	
	function updateServices(now:Date) {
		for (floor in 0...hotel._floors)
			for (room in 0...hotel._width) {
				var r = hotel._rooms[floor][room];
				if (r._clientId == null || r._type!=_TR_BEDROOM)
					continue;
			
				var number = _Room.getNumber(floor,room);
				var client = getClient(r._clientId);
				if ( now.getTime() >= client._serviceEnd.getTime() ) {
					// service manqué
					client._bonusHappy -= Std.int(Math.abs(Const.H_SERVICE_NOK));
					logGameMsg(client._serviceEnd, T.format.LServiceFail({_name:getFullName(client)}));
					client.initService(hotel, now, Range.makeInclusive(7,15));
				}
			}
	}
	
	public function gainQuestRewards(q:_Quest) {
		for (r in q._rewards)
			switch(r) {
				case R_Money(n) :
					applyGain(n, "quest");
				case R_Item(i) :
					addItem(i);
				case R_Client :
					var c = generateClient(time);
					logAction( L_ANIM(1,0, NewClient(c._id)) );
				case R_Research :
					gainResearchPoint(1);
				case R_Fame :
					applyFameGainAt(hotel._width-1, 0, Const.FAME_QUEST);
			}
	}
	
	public function countItem(i:_Item) {
		var k = Type.enumIndex(i);
		return if(hotel._items.exists(k)) hotel._items.get(k) else 0;
	}
	
	public function countItems() {
		var total = 0;
		for (n in hotel._items)
			total+=n;
		return total;
	}
	
	public function addItem(i:_Item, ?n=1) {
		var k = Type.enumIndex(i);
		if ( !hotel._items.exists(k) )
			hotel._items.set(k, n);
		else
			hotel._items.set(k, hotel._items.get(k)+n);
	}
	
	function checkQuests() {
		var q = hotel.getQuest();
		if (q!=null && qman!=null && qman.isDone()) {
			// récompenses
			if( q._rewards.length>0 )
				logAction(L_MSG(T.get.QuestComplete+"\n"+qman.getRewardText(hotel)));
			gainQuestRewards(q);
				
			// on passe à la suivante
			if( !q._repeatable && QuestXml.ALL.exists(hotel._questId+1) ) {
				// série normale
				hotel.setQuest( hotel._questId+1 );
			}
			else {
				// quêtes répétables aléatoire
				var oldQuestId = hotel._questId;
				var qlist = Lambda.array( QuestXml.getRepeatables() );
				var qid = oldQuestId;
				while (qid==oldQuestId)
					qid = qlist[Std.random(qlist.length)]._id;
				hotel.setQuest(qid);
			}

			// démarrage
			var q = hotel.getQuest();
			qman = new QuestManager(this, q);
			logAction( L_QUEST( true, getQuestHtml(q) ) );
		}
	}
	
	private function majRoom(now:Date ) {
		for (floor in 0...hotel._floors)
			for (x in 0...hotel._width){
				var r = hotel._rooms[floor][x];
				if (r._serviceEnd!=null && now.getTime() >= r._serviceEnd.getTime()) {
					r._serviceEnd = null;
					if (r._type==_TR_LAB) {
						// laboratoire
						if ( r._life>=Const.LAB_NEEDED_POINTS ) {
							// terminé
							if( hotel.treeMaxed() ) {
								dropItem(floor, x, _RESEARCH_GOLD);
								logAction( L_MSG(T.get.GotResearchMaxed) );
							}
							else {
								dropItem(floor, x, _RESEARCH);
								logAction( L_MSG(T.get.GotResearchPoint) );
							}
							r._life = 0;
						}
						else if ( Std.random(100) < hotel.getTalentRatio(TalentXml.get.decoLab) * 10 ) {
							dropItem(floor, x, _RANDDECO);
							logAction( L_MSG(T.get.GotDeco) );
						}
					}
				}
				if (r._underConstruction!=null && now.getTime() >= r._underConstruction.getTime()) {
					logGameMsg(now, T.format.LEndConstruction({_room:_Room.getRoomText(r._type)._name}));
					r._underConstruction = null;
					validateGoal(G_EndConstruction);
				}
			}
	}
	
	private function clientDepartures(now:Date) {
		var leftCount = 0;
		for (floor in 0...hotel._floors) {
			for (x in 0...hotel._width) {
				var r = hotel._rooms[floor][x];
				if (r._clientId == null || r._type!=_TR_BEDROOM)
					continue;
			
				//var number = _Room.getNumber(floor,x);
				var client = getClient(r._clientId);
				
				if ( now.getTime() < client._dateLeaving.getTime() )
					continue;
				
				leftCount++;
				if (client._happyness > 0) {
					// pas trop mécontent...
					var chanceBreakItem = Const.BASE_BREAK_CHANCE - hotel.getTalentRatio(TalentXml.get.strongItems)*20;
					var chanceDrop = Const.BASE_DROP_CHANCE + hotel.getTalentRatio(TalentXml.get.itemDrop)*20;
					var chanceDirt = Const.BASE_DIRT_CHANCE - hotel.getTalentRatio(TalentXml.get.strongRooms)*20;
					
					// mods de chances
					if (client._type == _MF_BUSINESS)
						chanceDrop += 30;
					if ( r.hasEquipment(_LABY_CUPBOARD) )
						chanceDrop += 30;
					if (client._type == _MF_FIRE) {
						chanceBreakItem += 100;
						chanceDirt += 100 - hotel.getTalentRatio(TalentXml.get.specFire)*75;
					}
					//if (r._item == _MATTRESS)
						//chanceBreakItem = 100;
					//if ( r.hasEquipment(_ISOLATION) )
						//chanceBreakItem = 100;
					
					// ajustements selon le level
					if ( hotel._level<=0 )
						chanceDirt = Math.round(chanceDirt*0.5);
					if ( hotel._level<=0 && countItems()<=4 )
						chanceDrop = 999;
						
					// paiement au départ
					var gain = clientPay(client, r);
					applyGainAt(floor,x, gain, "leave");
						
					// dégâts
					if ( Std.random(100) <= chanceDirt )
						mess(floor, x, if(client._type==_MF_FIRE) -100 else -1);

					// prestige
					var fame =
						if (client._vip) {
							if (client._happyness>=_Client.MAX_HAPPYNESS)
								Const.FAME_VIP;
							else if (client._happyness>=_Client.MAX_HAPPYNESS*0.7)
								Std.int(Const.FAME_VIP*0.25);
							else
								1;
						}
						else {
							if (client._happyness>=_Client.MAX_HAPPYNESS)
								Const.FAME_CLIENT_HAPPY;
							else
								0;
						}
					
						
					if( fame>0 )
						applyFameGainAt(floor, x, fame);
						
					// goals
					App.api.incrementGoal(App.GOALS.hosted);
					if (client._happyness>=_Client.MAX_HAPPYNESS*0.6)
						if(client._vip)
							App.api.incrementGoal(App.GOALS.okvip);
						else
							App.api.incrementGoal(App.GOALS.okbase);
					if (client._type==_MF_GIFT && client._happyness>=_Client.MAX_HAPPYNESS*0.6)
						App.api.incrementGoal(App.GOALS.okfrnd);
					
					
					// message du log
					var msg =
						if (client._happyness <= _Client.MAX_HAPPYNESS*0.5)
							T.format.LClientLeaveHappyLow({_name:getFullName(client)});
						else
							if( client._happyness>= _Client.MAX_HAPPYNESS )
								T.format.LClientLeaveHappyMaxed({_name:getFullName(client)});
							else
								T.format.LClientLeaveHappyNormal( { _name:getFullName(client) } );
								
					var gainsTxt = new List();
					gainsTxt.add( T.format.LClientMoney({_gain:gain}) );
					if (fame>0)
						gainsTxt.add( T.format.LClientFame({_fame:fame}) );
					
					logGameMsg(now, msg+" "+ T.get.LClientGains + gainsTxt.join(", ") +"." );

					// casse d'équipement
					if ( r.hasEquipment() )
						if( Std.random(100) < chanceBreakItem )
							breakAllEquipment(r, floor, x, now);
						//else
							//logGameMsg( client._dateLeaving, T.format.LClientItemNotBroken({_number:number, _item:T.getItemText(r._item)._name}) );
					if(r.hasEquipment(_WALLET))
						r.removeEquipment(_WALLET);
					if(r.hasEquipment(_ISOLATION))
						r.removeEquipment(_ISOLATION);
						
					// drop d'item
					if (Std.random(100) < chanceDrop ) {
						dropItem(floor, x, client._item);
						logGameMsg( now, T.format.LClientLeaveItem({_name:client._name, _item:T.getItemText(client._item)._name}) );
					}
				}
				else {
					// vraiment pas content !
					logGameMsg(now, T.format.LClientLeaveAngry({_name:getFullName(client)}) );
					mess(floor, x, -100);
					if(r.hasEquipment())
						breakAllEquipment(r, floor, x, now);
				}
				
				validateGoal( G_Satisfy(client.getHappyness()) );
				if ( client.getHappyness() >= _Client.MAX_HAPPYNESS )
					validateGoal( G_SatisfyMax );
				
				// départ effectif
				logAction(L_CLIENT_LEFT(floor, x));
				removeClient(r._clientId);
				var s = getStaffAt(floor, x);
				if (s != null)
					s.finish();
			}
		}
		
		// garbage collector pour bug de clients fantomes (TODO: le corriger ?)
		for (c in hotel._clients)
			if ( getClientRoom(c)==null && !hotel.isInQueue(c) )
				removeClient(c._id);
				
		return leftCount;
	}
	
	private function clientPay(client:_Client, room:_Room) {
		var pt = getRoomCoord(room);
		return client.getBaseGain(hotel, room);
	}
	
	
	// appelé chaque nuit
	private function payment(now:Date) {
		var results = new List();
		var moneyBefore = hotel._money;
		var gainTotal = 0;
		var nclients = 0;
		//var delayedLog = new List();
		for (floor in 0...hotel._floors) {
			for (x in 0...hotel._width) {
				var room = hotel._rooms[floor][x];
				var client = getClient(room._clientId);
				if ( client!=null && room._type==_TR_BEDROOM ) {
					nclients++;
					playNightItem(floor, x); // TODO à déplacer hors de Payment !
					updateHappyness(now);
					var gain = clientPay(client, room);
					if(gain>0)
						logGameMsg(now, T.format.LClientNightGain({_name:client._name, _gain:gain, _happy:client.getHappyness()}) );
					else if (gain==0)
						logGameMsg(now, T.format.LClientNightNull({_name:client._name, _gain:gain, _happy:client.getHappyness()}) );
					else
						logGameMsg(now, T.format.LClientNightLoss({_name:client._name, _gain:gain, _happy:client.getHappyness()}) );
					gainTotal+=gain;
					if(gain!=0)
						applyGainAt(floor,x, gain);
					results.add({
						name		: client._name,
						happyness	: client.getHappyness(),
						gain		: gain,
					});
				}
			}
		}
		
		// debriefing
		if( results.length>0 )
			logAction( L_HTML( template("mini/midnight.mtt", {
					date1	: printDay( DateTools.delta(now,-DateTools.days(1)) ),
					date2	: printDay( now ),
					results	: results,
					gain	: gainTotal,
				}))
			);
			
		App.api.useGameMoney(gainTotal, "night", "night");
	
		if ( gainTotal!=0 )
			logGameMsg(now, T.format.LNightPayment( { _gain:gainTotal, _clients:nclients} ));
		
		// on ajoute les events après l'affichage du debrief
		//for (log in delayedLog)
			//logAction(log);
		
	}
	
	private function removeClient(cid:Int) {
		if (cid==null)
			return;
			
		// queue
		for (id in hotel._clientQueue)
			if (id==cid)
				hotel._clientQueue.remove(id);
			
		// liste
		hotel._clients.remove(cid);
		
		// rooms
		for (floor in hotel._rooms)
			for (room in floor)
				if (room._clientId==cid)
					room._clientId = null;
	}
	
	private function playNightItem(f:Int, x:Int) {
		var r = getRoom(f, x);
		if (!r.hasEquipment())
			return;
		for(i in r._equipments) {
			switch (i) {
				case _PRESENT :
				case _PRESENT_XL :
				
				case _MATTRESS :
					getClient(hotel._rooms[f][x]._clientId)._bonusHappy += Const.H_MATTRESS;
				
				case _FIREWORKS :
					getClient(hotel._rooms[f][x]._clientId)._bonusHappy += Const.H_FIREWORK;
					mess(f, x, -3);
					r.removeEquipments();
					
				case _BUFFET 		:
				case _RADIATOR 		:
				case _STINK_BOMB 	:
				case _HUMIDIFIER	:
				case _HIFI_SYSTEM	:
				case _OLD_BUFFET	:
				case _DJ			:
				case _LABY_CUPBOARD	:
				case _WALLET		:
				case _FRIEND		:
				case _REPAIR		:
				case _MONEY			:
				case _ISOLATION		:
				case _RANDPAINT		:
				case _RANDPAINTWARM	:
				case _RANDPAINTCOOL	:
				case _RANDBOTTOM	:
				case _RANDTEXTURE	:
				case _RANDDECO		:
				case _RESEARCH		:
				case _RESEARCH_GOLD	:
			}
		}
		
	}
	
	private function mess(floor, room, ?life=-1) {
		getRoom(floor, room).mess(life);
		logAction(L_ROOM_CHANGE_LIFE(floor, room));
	}
	
	private function dropItem(f, x, i) {
		hotel._rooms[f][x]._itemToTake = i;
		logAction(L_NEW_ITEM(f,x,i));
	}
	
	private function breakAllEquipment(r:_Room, f:Int , x:Int, date:Date) {
		var r = hotel._rooms[f][x];
		var number = _Room.getNumber(f, x);
		for(it in r._equipments) {
			removeAffect(f, x, it);
			logGameMsg( date, T.format.LClientBreakItem( { _number:number, _item:T.getItemText(it)._name } ) );
		}
		r.removeEquipments();
		
	}
	
	private function removeAffect(f:Int, r:Int, i:_Item) {
		var t = getItemEffect(i);
		for(x in 0...t.length){
			var eS = {
				_effect 		: t[x],
				_sourceFloor 	: f,
				_sourceRoomNb 	: r,
			}
			baseEffect[f][r].remove(eS);
		}
	}
	
	private function takeItem(f, x) {
		var r = hotel._rooms[f][x];
		if (r._itemToTake == null)
			throw Fatal("NoItemToTake");
		
		var i = r._itemToTake;
		if (i==_MONEY) {
			// l'argent se joue au pickup
			logAction( L_MSG(T.format.MoneyFound({_money:Const.MONEY_PICKUP, _currency:T.get.Currency})) );
			applyGainAt(f, x, Const.MONEY_PICKUP);
			validateGoal(G_PickItem);
			App.api.incrementGoal(App.GOALS.pick);
		}
		else if (i==_RESEARCH) {
			// idem pour les points de talent
			gainResearchPoint(1);
			validateGoal(G_DropResearch);
		}
		else if (i==_RESEARCH_GOLD) {
			// idem pour les fioles d'or
			logAction( L_MSG(T.format.ResearchFameFound( { _fame:Const.FAME_RESEARCH } )) );
			applyFameGainAt(f,x,Const.FAME_RESEARCH);
			validateGoal(G_DropResearch);
		}
		else {
			logAction( L_MSG(T.format.ItemFound({_item:T.getItemText(i)._name})) );
			addItem(i);
			validateGoal(G_PickItem);
			App.api.incrementGoal(App.GOALS.pick);
		}
		logAction(L_TAKE_ITEM(i));
		r._itemToTake = null;
	}
	
	public function initQueue(now:Date, nb:Int) {
		hotel._clientQueue = new List();
		for ( i in 0...nb)
			generateClient(now);
	}
	
	
	public function generateClient(now:Date, ?vip:Bool, ?excludedType:_MonsterFamily) {
		var tg = new TextGen( hotel._id + Std.random(999999) );
		var id = hotel._uniqClientId++;
		var c : _Client;
		do {
			c = new _Client(id, now, hotel, tg);
		} while (excludedType!=null && Type.enumIndex(excludedType) == Type.enumIndex(c._type));
		
		if ( vip || Std.random(100)<1 )
			c.makeVip();
			
		addInQueue(now, c);
		return c;
	}
	
	private function addInQueue(now:Date, c:_Client) {
		if(c._vip)
			logGameMsg(now, T.format.LPopClientVip( { _name:c._name } ) );
		else
			logGameMsg(now, T.format.LPopClient( { _name:c._name } ) );
		hotel._clients.set(c._id, c);
		hotel._clientQueue.add(c._id);
		// limite de longueur
		//while ( hotel._clientQueue.length > hotel._maxInQueue )
			//removeClient( hotel._clientQueue.first() );
	}
	
	private function majCdCLient(now:Date) {
		if ( _Hotel.isClosedTime(now) ) {
			hotel._lastClient = Lib.setTime(now, _Hotel.WAKEUP_HOUR);
			hotel._nextClient = Lib.setTime(now, _Hotel.WAKEUP_HOUR);
		}
		else {
			var nstaff = hotel.countStaffDoing(J_LOBBY);
			hotel._nextClient = DateTools.delta(hotel._lastClient, hotel.getClientDelay(nstaff));
			if ( _Hotel.isClosedTime(hotel._nextClient) )
				hotel._nextClient = Lib.setTime(hotel._nextClient, _Hotel.WAKEUP_HOUR);
		}
		debug("majCDclient "+hotel._nextClient);
	}
	
	private function clearQueue(recentFriendClients:IntHash<Bool>) {
		for (qid in hotel._clientQueue)
			for (c in hotel._clients)
				if ( c._id==qid && !recentFriendClients.exists(c._id) )
					hotel._clients.remove(qid);
		hotel._clientQueue = new List();
	}
	
	private function getRoomCoord(r:_Room) {
		for (f in 0...hotel._floors)
			for (x in 0...hotel._width)
				if (r == hotel._rooms[f][x])
					return {floor:f, x:x};
		return null;
	}

	private function getRoom(floor : Int, roomNumber : Int ) {
		return hotel._rooms[floor][roomNumber];
	}
	
	private function getRooms(t:_TypeRoom) {
		var list = new List();
		for (floor in hotel._rooms)
			for (r in floor)
				if ( Type.enumIndex(r._type) == Type.enumIndex(t) )
					list.add(r);
		return list;
	}
	
	private function getClient(id : Int) : _Client {
		if ( id!=null && hotel._clients.exists(id) )
			return hotel._clients.get(id);
		else
			return null;
	}
	
	private function getClientRoom(c:_Client) {
		for (f in hotel._rooms)
			for (r in f)
				if (r._clientId==c._id)
					return r;
		return null;
	}
	
	private function getStaff(id:Int) {
		for (staff in hotel._staff)
			if (staff._id == id)
				return staff;
		return null;
	}

	private function idToRoom(id:Int) {
		for (f in 0...hotel._floors){
			for (r in 0...hotel._width) {
				if (id == hotel._rooms[f][r]._id){
					return hotel._rooms[f][r];
				}
			}
		}
		return null;
	}
	
	
	public function getHotel() {
		return hotel;
	}
	
	private function updateAffectMap() {
		clearBaseEffect();
		var hlevel = hotel.getLevelForDisplay();
		for (f in 0...hotel._floors) {
			for (x in 0...hotel._width ) {
				var r = hotel._rooms[f][x];
				if ( r!=null && r._type==_TR_BEDROOM ) {
					// reçus des voisins
					for (eS in r._effectSpread )
						applyAffect(f, x, eS);
						
					if ( r._clientId!=null ) {
						// émissions
						if( !r.hasEquipment(_ISOLATION) )
							for (eS in getClient(r._clientId)._effect)
								applyAffect(f, x, eS);
						// équipement installé
						for(item in r._equipments)
							applyItemAffect(f, x, item);
						// niveau de la chambre
						if (hlevel<=3 && r._level>0 || hlevel>2 && r._level>1) {
							var sE = {
								_effect 		: _LUX_ROOM,
								_sourceFloor 	: f,
								_sourceRoomNb 	: x,
							}
							baseEffect[f][x].add(sE);
						}
					}
				}
			}
		}
	}
	
	private function clearBaseEffect() {
		baseEffect = new Array();
		for (i in 0...hotel._floors ) {
			baseEffect[i] = new Array();
			for (j in 0...hotel._width )
				baseEffect[i][j] = new List();
		}
	}
	
	private function isOn(effect:_Likes, list:List<_SourceEffect>) {
		return Lambda.filter(list, function(e) { return Type.enumEq(effect, e._effect); } );
		//var list = new List();
		//for (e in list2) {
			//if (Type.enumEq(element, e._effect))
				//list.add(e);
		//}
		//return list;
	}
	
	/*Application des effect*/
	private function applyAffect(nbFloor : Int, nbRoom : Int, eS : _EffectSpreading) {
		var sE : _SourceEffect = {
				_effect 		: eS._effect,
				_sourceFloor 	: nbFloor,
				_sourceRoomNb 	: nbRoom,
			}
		
		switch(eS._spreading){
			case UP :
				setTabEffect(nbFloor + 1, nbRoom, sE);
			case DOWN  :
				setTabEffect(nbFloor -1, nbRoom, sE);
			case HORIZONTAL :
				for (i in 0...hotel._width) {
						if ( i == nbRoom )
							continue;
						baseEffect[nbFloor][i].add(sE);
					}
			case LEFT_RIGHT :
				setTabEffect(nbFloor, nbRoom +1, sE);
				setTabEffect(nbFloor, nbRoom - 1, sE);
			case CROSS :
				setTabEffect(nbFloor, nbRoom +1, sE);
				setTabEffect(nbFloor, nbRoom - 1, sE);
				setTabEffect(nbFloor + 1, nbRoom, sE);
				setTabEffect(nbFloor - 1, nbRoom, sE);
			case MYSELF :
				setTabEffect(nbFloor, nbRoom, sE);
		}
	}

	private function setTabEffect(f, x, v) {
		if (f<0 || f>=hotel._floors || x<0 || x>=hotel._width)
			return;
		var room = hotel._rooms[f][x];
		//if ( room!=null && room._item!=_ISOLATION)
		if ( room!=null && !room.hasEquipment(_ISOLATION) )
			baseEffect[f][x].add(v);
	}
	
	private function sdate(date:Date) {
		return DateTools.format(date, "[%d] %H:%M:%S");
	}
	
	private function popClients(now:Date, fl_anim:Bool) {
		if ( _Hotel.isClosedTime(now) )
			return;
			
		if ( now.getTime() < hotel._nextClient.getTime() )
			return;
		
		var popDate = hotel._nextClient;
		hotel._lastClient = popDate;
		var c = generateClient(popDate);
		validateGoal( G_ClientPop );
		if( fl_anim )
			logAction( L_ANIM(0,0,NewClient(c._id)) );
		
		majCdCLient(now);
	}
	
	private function itemCanEquipOccupiedRoom(i:_Item) {
		return
			switch(i) {
				case _MONEY : false;
				default	:
					true;
			}
	}
	
	private function useOneItem(f:Int,x:Int, i:_Item) {
		var r = hotel._rooms[f][x];
		if( i!=_RANDDECO ) {
			if( Const.isEquipment(i) ) {
				if ( r._clientId!=null && !itemCanEquipOccupiedRoom(i) )
					throw L_ERROR( T.get.CantEquipOccupiedRoom );
				if (r._type == _TR_NONE)
					throw L_ERROR( T.get.BuildBedroomFirst );
				if (r._type != _TR_BEDROOM )
					throw L_ERROR( T.get.InvalidRoom );
				if (r._underConstruction != null)
					throw L_ERROR( T.get.RoomUnderConstruction );
				if (!r.hasRoomForEquipment() )
					throw L_ERROR( T.get.TooManyEquipments );
				if ( r.hasEquipment(i) )
					throw L_ERROR( T.get.EquipmentAlreadyInstalled);
			}
			if (r._type ==_TR_VOID )
				throw L_ERROR( T.get.InvalidRoom );
		}
		
		// recherche & utilisation
		if( countItem(i)>0 )
			useItemFromInventory(f, x, i);
	}
	
	
	
	private function useItemFromInventory(f,x, i : _Item) {
		var r = hotel._rooms[f][x];
		if (i==_REPAIR) {
			if ( !r.isDamaged() )
				throw L_ERROR( T.get.RoomNotDirty );
			r.tidy(100);
		}
		else if (i==_RANDPAINT) {
			var d = hotel._design.get(f);
			var colors = Const.allWallColors();
			d._wallColor = differentRandom(d._wallColor, Range.makeNonInclusive(0, colors.length));
			validateGoal(G_ChangeDeco);
		}
		else if (i==_RANDPAINTWARM) {
			var d = hotel._design.get(f);
			var colors = Const.WALL_COLORS_WARM;
			d._wallColor = differentRandom(d._wallColor, Range.makeNonInclusive(0, colors.length));
			validateGoal(G_ChangeDeco);
		}
		else if (i==_RANDPAINTCOOL) {
			var d = hotel._design.get(f);
			var colors = Const.WALL_COLORS_COOL;
			var baseIdx = Const.WALL_COLORS_WARM.length;
			d._wallColor = differentRandom(d._wallColor, Range.makeNonInclusive(baseIdx, baseIdx+colors.length));
			validateGoal(G_ChangeDeco);
		}
		else if (i==_RANDTEXTURE) {
			var d = hotel._design.get(f);
			d._wall = differentRandom(d._wall, Range.makeNonInclusive(1, Const.WALL_PAPERS));
			validateGoal(G_ChangeDeco);
		}
		else if (i==_RANDBOTTOM) {
			//if (f==0)
				//throw L_MSG(T.get.InvalidRoom);
			var d = hotel._design.get(f);
			d._bottom = differentRandom(d._bottom, Range.makeNonInclusive(0,Const.WALL_BOTTOMS));
			d._mid = differentRandom(d._mid, Range.makeNonInclusive(0, Const.WALL_MIDS));
			validateGoal(G_ChangeDeco);
		}
		else if (i==_RANDDECO) {
			var rl = new mt.deepnight.RandList();
			rl.add(DecoPlantSmall, 9);
			rl.add(DecoPlantLarge, 7);
			rl.add(DecoPaintSmall, 9);
			rl.add(DecoLight, 6);
			rl.add(DecoFurniture, 5);
			rl.add(DecoSofa, 4);
			rl.add(DecoDesk, 0);
			var ditem = addDecoItem(rl.draw());
			var name = T.getByKey( Std.string(ditem._type) );
			logAction( L_MSG(T.format.NewDeco({_name:name})) );
		}
		else if (i==_PRESENT) {
			var c = getClient(r._clientId);
			if (c==null)
				throw L_ERROR( T.get.InvalidRoom );
			if (c._bonusHappy>0)
				throw L_ERROR( T.get.PresentForbidden );
			c._bonusHappy+=Const.H_PRESENT;
		}
		else if (i==_PRESENT_XL) {
			var c = getClient(r._clientId);
			if (c==null)
				throw L_ERROR( T.get.InvalidRoom );
			if (c._bonusHappy>0)
				throw L_ERROR( T.get.PresentForbidden );
			c._bonusHappy+=Const.H_PRESENT_XL;
		}
		else {
			applyItemAffect(f,x,i);
			updateHappyness(time);
			r.installEquipment(i);
			validateGoal( G_InstallItem );
		}
		hotel._items.set( Type.enumIndex(i), hotel._items.get(Type.enumIndex(i))-1 );
	}
	
	
	private function applyItemAffect(f,x, i : _Item) {
		var r = hotel._rooms[f][x];
		var t =  getItemEffect(i);
		for (x2 in 0...t.length) {
			var sE = {
				_effect 		: t[x2],
				_sourceFloor 	: f,
				_sourceRoomNb 	: x,
			}
			baseEffect[f][x].add(sE);
		}
	}

	private function getItemEffect(i:_Item) {
		return
			switch(i) {
				case _BUFFET		: [_FOOD];
				case _RADIATOR		: [_FIRE];
				case _STINK_BOMB	: [_ODOR];
				case _HUMIDIFIER 	: [_WATER];
				case _HIFI_SYSTEM	: [_NOISE];
				case _OLD_BUFFET	: [_FOOD, _ODOR];
				case _DJ			: [_NOISE, _FIRE];
				case _PRESENT		: [];
				case _PRESENT_XL	: [];
				case _LABY_CUPBOARD	: [];
				case _MATTRESS		: [];
				case _FIREWORKS 	: [];
				case _WALLET 		: [];
				case _FRIEND 		: [_NEIGHBOR];
				case _REPAIR		: [];
				case _MONEY			: [];
				case _ISOLATION		: [];
				case _RANDPAINT		: [];
				case _RANDPAINTWARM	: [];
				case _RANDPAINTCOOL	: [];
				case _RANDBOTTOM	: [];
				case _RANDTEXTURE	: [];
				case _RANDDECO		: [];
				case _RESEARCH		: [];
				case _RESEARCH_GOLD	: [];
			}
	}
	
	private function makeEffect(f, r, l : _Likes ) {
		var se = {
			effect 			: l,
			sourceFloor 	: f,
			sourceRoomNb 	: r,
		}
		return se;
	}
	
	private function apply(c:_Client, f:Int, r:Int) {
		for (eS in c._effect)
			applyAffect(f, r, eS);
	}
	
	private function initRoomAffet() {
		for (f in 0...hotel._floors) {
			for (r in 0...hotel._width) {
				var e = getRoomAffect(f, r);
				if(e != null){
					var se = {
						_effect 		: e,
						_sourceFloor 	: f,
						_sourceRoomNb 	: r,
					}
					baseEffect[f][r].add(se);
				}
			}
		}
	}
	
	private function getRoomAffect(f:Int,r:Int){
		//if (f == 1)					_FLOOR_DOWN;
		//if (f == hotel._floors-1)	_FLOOR_TOP;
		//if (r == 0)					_FLOOR_LEFT;
		//if (r == hotel._width-1) 	_FLOOR_RIGHT;
		return null;
	}
	
	private function stopActivity(c:_Client) {
		for (f in 0...hotel._floors)
			for (x in 0...hotel._width) {
				var r = hotel._rooms[f][x];
				// on supprime le(s) clone(s) dans les salles spéciales
				if (r._clientId==c._id && r._type != _TR_BEDROOM) {
					r._clientId = null;
					return r;
				}
			}
		return null;
	}
	
	private function playIAClient(now:Date) {
		for (f in 0...hotel._floors)
			for (x in 0...hotel._width) {
				var r = hotel._rooms[f][x];
				var c = getClient(r._clientId);
				if (c==null || r._type!=_TR_BEDROOM)
					continue;
				if ( c._activityEnd!=null && now.getTime() >= c._activityEnd.getTime() ) {
					c._activityEnd = null;
					if (c._activity != null) {
						// fini une vraie activité
						var sum = Const.SPECIAL_ROOM_GAIN;
						//sum += Math.round( hotel.getTalentRatio(TalentXml.get.specialGain)*5 );
						if( Const.H_SPECIAL_ROOM>0 )
							logGameMsg(now, T.format.LEndActivityHappy({_name:c._name, _room:_Room.getRoomText(c._activity)._name, _gain:sum, happy:Const.H_SPECIAL_ROOM }));
						else
							logGameMsg(now, T.format.LEndActivity({_name:c._name, _room:_Room.getRoomText(c._activity)._name, _gain:sum}));
						var actRoom = stopActivity(c);
						var pt = getRoomCoord(actRoom);
						c.doActivity( DateTools.delta(now, Const.ACTIVITY_DURATION * 2.5) );
						c._bonusHappy+=Const.H_SPECIAL_ROOM;
						if (Const.H_SPECIAL_ROOM>0)
							logAction( L_ANIM(pt.floor,pt.x, HappyChange(Const.H_SPECIAL_ROOM)) );
						if (sum!=0)
							applyGainAt(pt.floor, pt.x, sum, "activi" );
						continue;
					}
					else {
						// fini d'attendre sans rien faire, il cherche une room spéciale dispo
						for (l in c._like) {
							var fav = getFavoriteRoom(l);
							var target = getEmptyRoomByType(fav);
							if (target!=null) {
								// démarre une activité dans une room spéciale
								target._clientId = c._id;
								c._activityEnd = DateTools.delta(now, Const.ACTIVITY_DURATION + DateTools.minutes(Std.random(60)) );
								c._activity = fav;
								break;
							}
						}
					}
				}
				
				if (c._activity==null && c._activityEnd==null) {
					// n'a rien trouvé à faire...
					c._activityEnd = DateTools.delta(now, DateTools.minutes(10+Std.random(30)) );
				}
			}
	}
	
	private function mix(t:Array<_Client>) {
		var t2 = new Array();
		while(t.length>0)
			t2.push( t.splice(Std.random(t.length),1)[0] );
		return t2;
	}
	
	private function getEmptyRoomByType(type:_TypeRoom) {
		if (type==null)
			return null;
		for (f in 0...hotel._floors)
			for (x in 0...hotel._width) {
				var r = hotel._rooms[f][x];
				if ( r._type==type && r._clientId==null && r._underConstruction==null)
					return r;
			}
		return null;
	}
	
	
	private function getFavoriteRoom(like:_Likes) {
		return
			switch(like) {
				case _NOISE		: _TR_DISCO;
				case _WATER		: _TR_POOL;
				case _FIRE		: _TR_FURNACE;
				case _ODOR		: _TR_BIN;
				case _FOOD		: _TR_RESTAURANT;
				case _LUX_ROOM	: null;
				case _NEIGHBOR	: null;
				case _JOY		: null;
				//case	_FLOOR_TOP :	 null;
				//case	_FLOOR_DOWN : null;
				//case	_FLOOR_LEFT : null;
				//case	_FLOOR_RIGHT : null;
			}
	}
	
#end
}
