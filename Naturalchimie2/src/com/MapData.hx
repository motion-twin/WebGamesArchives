typedef _MapData = {
	var _pa : Int ;
	var _pamax : Int ;
	var _ppa : Int ;
	var _siflex : Bool ;
	var _farView : Bool ;
	var _url : String ;
	var _region : Int ;
	var _regionName : String ; 
	var _cur : String ;
	var _align : Int ;
	var _regions : List<{
		_id : String,
		_iid : Int,
		_inf : String,
		_dplace : String,
		
	}>;
	var _places : List<{
		_id : String,
		_name : String,
		_inf : Null<String>,
		_known : Bool,
		_valid : Bool,
		_quests : Int,
		_schoolCup : Bool,
		_objects : Bool,
		_chain : Array<Int>
	}>;
	var _nexts : List<{
		_id : String,
		_text : String,
		_conf : Bool,
		_pa : Int,
		_from : String,
		_road : String,
		_qway : Bool
	}>;
	var _tp : Array<{
		_id : String,
		_wait : Float,
		_name : String
	}> ;
}
