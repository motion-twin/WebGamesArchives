typedef FloorDesign = {
	_wall		: Int,
	_bottom		: Int,
	_mid		: Int,
	_wallColor	: Int,
}

typedef DecoItem = {
	_id			: Int,
	_type		: _DecoType,
	_frame		: Null<Int>,
	_x			: Null<Int>,
	_y			: Null<Int>,
	_floor		: Null<Int>,
}

enum _DecoType { // ATTENTION : ajouter les équivalences de noms dans Lang.xml !!!
	DecoPlantSmall;
	DecoPlantLarge;
	DecoPaintSmall;
	DecoLight;
	DecoFurniture;
	DecoSofa;
	DecoDesk;
	// Ajouter à la fin
}

enum _ServiceType {
	ServiceWash;
	ServiceShoe;
	ServiceFridge;
	ServiceAlcool;
}


class _Staff {
	public var _endDate		: Date;
	public var _roomId		: Null<Int>;
	public var _job			: _TypeJob;
	public var _id			: Int;

	#if neko
	public function new (id:Int) {
		_id = id;
		_endDate = null;
		_roomId = null;
		_job = J_NONE;
	}
	
	public function work(hotel:_Hotel, date:Date, job:_TypeJob, room:_Room, client:_Client) {
		finish();
		switch(job) {
			case J_HOUSEWORK :
				_job = job;
				_roomId = room._id;
				_endDate = DateTools.delta(date, Const.JOB_REPAIR_DURATION);
				//var d = Const.JOB_REPAIR_DURATION;
				//if (room._life==0)
					//d*=2;
				//_endDate = DateTools.delta(date, d);
			case J_LOBBY :
				_job = job;
				_roomId = room._id;
			case J_ATTEND_TO :
				_job = job;
				_roomId = room._id;
				var duration = Const.JOB_ATTENDING_DURATION;
				duration *= 1-hotel.getTalentRatio(TalentXml.get.attendDuration)*0.5;
				if (client._type==_MF_AQUA)
					duration += DateTools.hours(3);
				_endDate = DateTools.delta(date, duration);
			case J_ADVERT	:
				_job = job;
				_roomId = room._id;
			case J_NONE :
		}
	}
	
	public function finish() {
		_endDate = null;
		_roomId = null;
		_job = J_NONE;
	}
	#end
}

enum _TypeJob {
	J_HOUSEWORK;
	J_LOBBY;
	J_ATTEND_TO;
	J_ADVERT;
	J_NONE;
}

enum _AnimType {
	Explode;
	HappyChange(n:Int);
	HappyChangeQueue(cid:Int, n:Int);
	MoneyChange(n:Int);
	ResearchUp(n:Int);
	ClientTimeChange(minuteDelta:Int);
	NewClient(cid:Int);
	FameChange(n:Int);
}


enum _PlayerAction {
	P_MOVE_CLIENT(oldFloor : Int, OldRoomNumber : Int, newFloorNumber : Int, newRoomNumber : Int);
	P_ADD_CLIENT_FROM_QUEUE(clientId : Int, floor : Int, roomNumber : Int);
	P_SWAP_ROOM(floor : Int, room : Int, type : _TypeRoom);
	P_INIT;
	P_VIEW_HOTEL(uid:Int);
	P_TAKE_ITEM(floor : Int, room : Int);
	P_USE_ITEM(floor:Int, x:Int, item:_Item);
	P_SEND_STAFF(id:Int, floor:Int, room:Int);
	P_CANCEL_STAFF(floor:Int, room:Int);
	P_PING;
	P_EXTEND_FLOOR_L(floor:Int);
	P_EXTEND_FLOOR_R(floor:Int);
	P_EXTEND_ROOF(x:Int);
	P_LEVEL_UP(floor:Int, x:Int);
	P_REMOVE_ITEM(floor:Int, x:Int, item:_Item);
	P_SERVICE(floor:Int, x:Int);
	P_CLIENT_INFOS(clientId:Int);
	P_SET_DECO(decoItems:List<DecoItem>);
	P_CLIENT_CALL;
	P_SWAP_QUEUE(c1:Int, c2:Int);
	P_DEBUG(f:Int,x:Int);
	P_PAY_TAX;
}

enum _Log {
	L_ADD_A_CLIENT_IN_ROOM(clientId : Int, floor : Int, room : Int);
	L_MOVE_A_CLIENT(oldFloor : Int, OldRoomNumber : Int, newFloorNumber : Int, newRoomNumber : Int); // TODO : à utiliser à la place de L_ADD_A_CLIENT_IN_ROOM dans le cas dun move de client !
	L_NEW_FLOOR;
	L_SWAP_ROOM(floor : Int, room : Int, type : _TypeRoom);
	L_ERROR(msg:String);
	L_MSG(msg:String);
	L_FATAL(msg:String);
	L_CLIENT_LEFT(floor : Int, room : Int);
	L_ROOM_CHANGE_LIFE(floor : Int, room : Int);
	//L_CHANGE_MONEY(nb:Int);
	L_NEW_ITEM(floor : Int, room : Int, i : _Item);
	L_TAKE_ITEM(i : _Item);
	//L_TIDY_ROOM(floor : Int, room : Int);
	L_ADD_STAFF_IN_ROOM(f:Int,r:Int,id:Int,job:_TypeJob);
	L_REFRESH;
	L_HTML(html:String);
	L_NEW_EXT_COST(cost:Int);
	L_QUEST(fl_newQuest:Bool, html:String);
	L_ANIM(f:Int, x:Int, a:_AnimType);
	L_ADD_A_CLIENT_IN_LAB(f:Int, x:Int);
	L_EVENT(msg:String);
	L_NEW_SROOM_COST(cost:Int);
}


enum _Likes {
	_NOISE;
	_WATER;
	_FIRE;
	_ODOR;
	_FOOD;
	_NEIGHBOR;
	_JOY;
	_LUX_ROOM;
	//_FLOOR_TOP;
	//_FLOOR_DOWN;
	//_FLOOR_LEFT;
	//_FLOOR_RIGHT;
}

enum _TypeRoom {
	_TR_VOID;
	_TR_BEDROOM;
	_TR_NONE;
	_TR_LOBBY;
	//_TR_LOBBY_SLOT;
	_TR_POOL;
	_TR_RESTAURANT;
	_TR_FURNACE;
	_TR_BIN;
	_TR_DISCO;
	_TR_SERV_WASH;
	_TR_SERV_SHOE;
	_TR_SERV_FRIDGE;
	_TR_SERV_ALCOOL;
	_TR_LAB;
}

enum _MonsterFamily {
	_MF_FIRE;
	_MF_AQUA;
	_MF_BLOB;
	_MF_GHOST;
	_MF_SM;
	_MF_BOMB;
	_MF_VEGETAL;
	_MF_BUSINESS;
	_MF_FRANK;
	_MF_GIFT;
	_MF_BASIC;
	_MF_ZOMBIE;
	_MF_FLYING;
}

typedef _EffectSpreading = {
	_effect		: _Likes,
	_spreading	: _TypeSpread,
}

typedef _SourceEffect = {
	_effect 		: _Likes,
	_sourceFloor 	: Int,
	_sourceRoomNb 	: Int,
}

typedef Rsult = {
	_h			: _Hotel,
	_rslt		: _RsltEnum,
	_d			: Date,
}

enum _RsltEnum {
	R_INIT(idata:InitData);
	R_SPECTATOR(idata:InitData);
	R_ACTION(fl_shapeChanged:Bool);
}

typedef InitData = {
	_itemCats	: IntHash<String>,
	_itemUrl	: String,
	_extCost	: Int,
	_sroomCost	: Int,
	_serverTime	: Date,
	_lowq		: Bool,
	//_clientItem	: Bool,
}

enum _TypeSpread {
	HORIZONTAL;
	LEFT_RIGHT;
	CROSS;
	UP;
	DOWN;
	MYSELF;
}

enum _Item { // ******** ATTENTION : ne pas modifier l'ordre des éléments de cet enum !!
	@rand(10)	_BUFFET;			// 1
	@rand(10)	_RADIATOR;
	@rand(10)	_STINK_BOMB;
	@rand(10)	_HUMIDIFIER ;
	@rand(10)	_HIFI_SYSTEM;	// 10
	@rand(0)	_OLD_BUFFET;
	@rand(0)	_DJ;
	@rand(20)	_PRESENT;
	@rand(4)	_LABY_CUPBOARD;
	@rand(4)	_MATTRESS;		// 10
	@rand(4)	_FIREWORKS;
	@rand(4)	_WALLET;
	@rand(10)	_FRIEND;
	@rand(2)	_REPAIR;
	@rand(5)	_MONEY;
	@rand(4)	_ISOLATION;
	@rand(0)	_RANDPAINT;
	@rand(0)	_RANDBOTTOM;
	@rand(0)	_RANDTEXTURE;
	@rand(2)	_RANDDECO;
	@rand(0)	_RANDPAINTWARM;
	@rand(0)	_RANDPAINTCOOL;
	@rand(0)	_RESEARCH;
	@rand(0)	_RESEARCH_GOLD;
	@rand(0)	_PRESENT_XL;
	// ajouter ici les nouveaux items
}

enum CriticalError {
	Fatal(msg:String);
}

enum _Modifier {
	M_BASE;
	M_BONUS;
	M_MOVE;
	M_ROOM;
	M_HYSTERIA;
	M_LIKE(l : _Likes);
	M_MALUS;
}

typedef _HL = {
	_n			: Int,
	_mod		: _Modifier,
	_present	: Bool,
}
