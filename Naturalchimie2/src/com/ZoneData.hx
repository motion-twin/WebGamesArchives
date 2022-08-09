import GameData._GameData ;
import MapData._MapData ;


typedef ZoneData = {
	var _region : Int ;
	var _id : String  ;
	var _name : String ;
	var _bg : String ;
	var _bginf : String ;
	var _align : String ;
	var _known : Bool ; //first visit
	var _valid : Bool ; // if false  > noway activation
	var _desc : String ;
	var _noway : {_text : String, _did : String, _redir : String} ;
	var _map : _MapData ;
	var _game : _GameData ;
	var _pnj_url : String ;
	var _object_url : String ;
	var _curquest : String ;
	var _effect : String ;
}



typedef WheelData = {
	var _nb : Int ;
	var _bg : String ;
	var _bginf : String ;
	var _pnj_url : String ;
	var _object_url : String ;
}

typedef _DialogInfos = {
	var _id : String ;
	var _gfx : String ;
	var _redir : {_url : String, _auto : Bool} ;
	var _texts : Array<{_text : String, _off : Bool, _frame : String, _fast : Int}> ;
	var _answers : List<{_text : String, _id : String, _target : String, _off : Bool}> ; 
	var _error : String ;
}