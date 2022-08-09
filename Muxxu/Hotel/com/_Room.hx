import Protocol;

class _Room {
	public static var MAX_LIFE		= 5;
	public var _id					: Int;
	public var _level				: Int;
	public var _type				: _TypeRoom;
	public var _life				: Int;
	public var _clientId			: Null<Int>;
	public var _underConstruction	: Date;
	public var _effectSpread		: List<_EffectSpreading>;
	public var _floor				: Int;
	public var _equipments			: List<_Item>;
	public var _itemToTake			: _Item;
	public var _serviceEnd			: Null<Date>;

	
	#if (neko || local)

	public function new(id:Int, type : _TypeRoom, floor) {
		_equipments = new List();
		_effectSpread = new List();
		_floor = floor;
		_id = id;
		_clientId = null;
		_level = 0;
		_life = MAX_LIFE;
		_underConstruction = null;
		setType(type);
	}
	
	public function tidy(gain:Int) {
		_life += gain;
		if (_life > MAX_LIFE)
			_life = MAX_LIFE;
	}
	
	public function mess(loss:Int) {
		_life -= Std.int(Math.abs(loss));
		if (_life<0)
			_life = 0;
	}
	
	public function toString() {
		return _type + " (" + ((_clientId==null)?"--":""+_clientId)+")";
	}
	
	public function getRoomStats(c:_Client) {
		return
			(c._vip ? 2 : 1)*
			switch (_life) {
				case 0 	: -5;
				case 1 	: -4;
				case 2 	: -3;
				case 3	: -2;
				case 4	: -1;
				case 5	: 0;
				default : throw("error, anormal room life");
			}
			
	}
	
	public function setType(tr:_TypeRoom) {
		_type = tr;
	}
	
	#end
	
	public function hasEquipment(?it:_Item) {
		if (it==null)
			return _equipments.length>0;
		else {
			for (i in _equipments)
				if (i==it)
					return true;
			return false;
		}
	}
	
	public inline function installEquipment(it:_Item) {
		if (hasEquipment(it))
			throw "already installed";
		_equipments.add(it);
	}
	
	public inline function removeEquipment(it:_Item) {
		if (!hasEquipment(it))
			throw "not found";
		_equipments.remove(it);
	}
	
	public inline function removeEquipments() {
		_equipments = new List();
	}
	
	public inline function hasRoomForEquipment() {
		return _equipments.length<2;
	}
	
	public static function getBuildList(floor:Int, rtype:_TypeRoom) {
		var list = new List();
		list.add(_TR_BEDROOM);
		list.add(_TR_RESTAURANT);
		list.add(_TR_BIN);
		list.add(_TR_DISCO);
		list.add(_TR_FURNACE);
		list.add(_TR_POOL);
		list.add(_TR_SERV_WASH);
		list.add(_TR_SERV_SHOE);
		list.add(_TR_SERV_ALCOOL);
		list.add(_TR_SERV_FRIDGE);
		list.add(_TR_LAB);
		if (floor==0)
			list.remove(_TR_BEDROOM);
		switch(rtype) {
			case _TR_LOBBY :
				list = new List();
				
			case _TR_VOID :
				list = new List();
				
			default :
		}
		list.remove(rtype);
		return list;
	}
	
	public static function getNumber(f,x) {
		return f*100 + (x+1);
	}
	
	public function isDamaged() {
		return _type==_TR_BEDROOM && _life<MAX_LIFE;
	}

	public static function isServiceRoom(tr:_TypeRoom) {
		return Std.string(tr).toLowerCase().indexOf("serv_")>=0;
	}
	
	public static function isSpecialRoom(tr:_TypeRoom) {
		return switch(tr) {
			case
				_TR_NONE, _TR_VOID, _TR_BEDROOM, _TR_LOBBY,
				_TR_SERV_ALCOOL, _TR_SERV_FRIDGE, _TR_SERV_SHOE, _TR_SERV_WASH,
				_TR_LAB : false;
			case
				_TR_BIN, _TR_DISCO, _TR_FURNACE, _TR_RESTAURANT, _TR_POOL : true;
		}
	}

	public static function getRoomCost(tr:_TypeRoom) {
		return
			if (tr==_TR_BEDROOM)
				Const.BUILD_ROOM_COST;
			else if (tr==_TR_LAB)
				Const.BUILD_LAB_COST;
			else
				if ( isServiceRoom(tr) )
					Const.BUILD_SERVICE_COST;
				else
					666;
	}
	
	public static function getServiceRoom(s:_ServiceType) {
		return switch(s) {
			case ServiceWash	: _TR_SERV_WASH;
			case ServiceShoe	: _TR_SERV_SHOE;
			case ServiceFridge	: _TR_SERV_FRIDGE;
			case ServiceAlcool	: _TR_SERV_ALCOOL;
		}
	}
	
	public static function getRoomText(type:_TypeRoom) {
		var raw = T.getByKey( Std.string(type).substr(1) );
		if (raw.indexOf("|")<0)
			raw+="||";
		raw = StringTools.replace( raw, "| ", "|" );
		var slist = raw.split("|");
		return {
			_name		: StringTools.trim(slist[0]),
			_ambiant	: StringTools.trim(slist[1]),
			_rule		: StringTools.trim(slist[2]),
		}
	}
}
