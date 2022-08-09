enum _GatherSkin {
	SCueille;
	SHunt;
	SFish;
	SFouille;
	SEnergy;
	SSnow;
	SParrain;
	STreasure;
	SLabodo;
	SAnniv;
	SFete;
	SSombre;
}

typedef GatherData = {
	var _d : Array<Array<Bool>>;
	var _size : Int;
	var _clicks : Int;
	var _url : String;
	var _skin : _GatherSkin;

	var _txt_loading	: String;
	var _txt_wait		: String;
	var _txt_success	: String;
	var _txt_fail		: String;
	var _txt_exit		: String;
}

typedef GatherRequest = List<{ _x : Int, _y : Int }>;

typedef GatherItem = { _name : String, _url : String };

typedef GatherResponse = List<GatherItem>;

typedef GatherInternal = {
	var d : Array<Array<Bool>>;
	var found : Array<Int>;
}
