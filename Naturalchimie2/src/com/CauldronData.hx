import GameData._ArtefactId ;
import ZoneData._DialogInfos ;
import MapData._MapData ;

typedef CauldronData = {
	var _id : String  ;
	var _name : String ;
	var _bg : String ;
	var _bginf : String ;
	var _known : Bool ; //first visit
	var _valid : Bool ; // if false  > noway activation
	var _noway : {_text : String, _did : String, _bg : String, _redir : String} ;
	var _map : _MapData ;
	var _pnj_url : String ;
	var _object_url : String ;
	var _curquest : String ;
	var _effect : String ;
	var _type : String ;
	var _raceLevel : Int ;
	var _raceNeedState : Array<{_o : _ArtefactId, _qty : Int}> ;
	var _dialogKey : String ;
	
	var _elements : Array<{_o : _ArtefactId, _qty : Int}> ;
	var _objects : Array<{_o : _ArtefactId, _qty : Int}> ;
	var _keeper : {_name : String, 
				_gfx : String,
				_frame : String, 
				_dialogAutoId : String} ;
}


typedef _CauldronSubmit = {
	var _objects : Array<{_o : _ArtefactId, _qty : Int}> ;
	var _v : String ;

}


enum _CResult {
	_Add(o : _ArtefactId, qty : Int, questQty : Int) ;
	
	_Win(token : Int, gold : Int) ;
	
	_Avatar(a : Int, b : Int, icon : String) ;
	_AvatarRand(a : Int, rMax : Int, p : Int) ;
	_AvatarInc(a : Int, s : Int) ;
	_AvatarList(l : Array<_CResult>, icon : String) ;
	_AvatarTemp(fx : String, avatar : Array<_CResult>, icon : String) ;
	
	_Temp(fx : String, time : Int) ;
	_Kaboom(fx : String) ;
	_KeeperGoOut(fx : String, done : Bool) ;
	
	_Smiley(img : String, nb : Int) ; //nb = nombre d'exemplaires en stock
	_Color(c : Int, days : Int) ; // days = nombre de jours de disponibilité
	_Texture(t : String) ;
	
	_Fail ;
}


typedef CauldronResult = {
	var _rid : String ;
	var _name : String ;
	var _result : _CResult ;
	var _flash : Bool ;
	var _specialist : Bool ; // specialist proc
	var _gotRank : String ;
	var _newLevel : String ;
	var _rAgain : Bool ;
	var _rRank : Int ;
	var _uses : Int ;
	var _isForb : Bool ;
	var _dialog : _DialogInfos ;
	var _backFire : _ArtefactId ;
	var _activeDouble : Bool ;
	var _error : String ; 
}

typedef _RaceSubmit = {
	var _curLevel : Int ;
	var _objects : Array<{_o : _ArtefactId, _qty : Int, _from : Int}> ;
	var _v : String ;
}

typedef RaceResult = {
	var _done : Bool ;
	var _toMaj : Array<{_id : String, _qty : Int, _given : Int, _ok : Bool, _o : _ArtefactId}> ;
	var _url : String ;
	var _error : String ;

}
