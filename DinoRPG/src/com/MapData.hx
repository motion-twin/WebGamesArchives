typedef MapData = {
	var _lang : String;
	var _zone : Int;
	var _cur : String;
	var _places : List<{
		_id : String,
		_name : String,
		_inf : String,
	}>;
	var _nexts : List<{
		_id : String,
		_text : String,
		_conf : Bool,
	}>;
	@:optional var _state : Null<Int>;
}