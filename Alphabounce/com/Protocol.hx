enum _ServerRequest {
	_AskInfos;
	_Play(x:Int, y:Int);
	_EndGame(x:Int, y:Int, victory:Bool, mineral:Int, missiles:Int, itemId:Int, shopItems:Array<Int>);
	_BuyItem(itemId:Int);
	_SubmitLevel(str:String);

	_PlayLander(x:Int, y:Int);
	_EndLander(victory:Bool, mineral:Int, missiles:Int, caps:Int, itemId:Int, travel:_Travel, flMarkHouse:Bool);

	_AskPendingLevels(x:Int,y:Int);
	_SelectPendingLevel(x:Int,y:Int,id:Int);
	_DeletePendingLevels(x:Int,y:Int);
	_ResetLevel(x:Int,y:Int);

	_EndStory(choice:Int,itemId:Int);

	_Wrap;
}

enum _ServerResponse {
	_Confirm();
	_ConfirmMove(x:Int, y:Int, hasMineral:Bool, levelData:String);
	_ConfirmLander(hasMineral:Bool, capsType:Int, visited:Bool);
	_Error(str:String);
	_SetInfos(str:String, key:String, knb:Int);
	_PendingLevels(a:Array<String>);
}

typedef _Travel = {
	public var _name : String;
	public var _sx : Int;
	public var _sy : Int;
	public var _ex : Int;
	public var _ey : Int;
	public var _start : Int;
	public var _dest : Int;
}

typedef _PlayerData = {
	public var _flAdmin:Bool;
	public var _flEditor:Bool;
	public var _pid:Int;
	public var _ox : Int;
	public var _oy : Int;
	public var _x : Int;
	public var _y : Int;
	public var _chl : Int; // liquid hydrogen (temporary)
	public var _chs : Int; // solid hydrogen (persistant)
	public var _minerai : Int;
	public var _missions : Array<Int>;
	public var _missile : Int;
	public var _missileMax : Int;
	public var _engine : Int;
	public var _radar : Int;
	public var _life : Int;
	public var _drone : Int;
	public var _items : Array<Int>;
	public var _shopItems : Array<Int>;
	public var _fog : Array<Int>;
	public var _comp : Array<Int>;
	public var _square : Array<Int>;
	// *_* NEW *_*
	public var _travel : Array<_Travel>;
	public var _pendingLevels : Int;	// nombres de niveaux en attente ( -1 si niveau deja validé );

}

