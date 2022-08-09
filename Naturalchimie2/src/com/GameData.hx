
typedef _Artefact = {
	var _id : _ArtefactId ;
	var _freq : Int ;
}


typedef _GameData = {
	var _mode : String ;
	var _chain : Array<_ArtefactId> ;
	var _chWeight : Array<Int> ;
	var _chainknown : Int ;
	var _object : Int ; //autorise les objets ou pas : -1 : non. 0 oui. 1...4 : autorise x objets
	var _userobjects : Array<_ArtefactId> ;
	var _artefacts : Array<_Artefact> ;
	var _grid : Array<{_id : _ArtefactId, _x : Int, _y : Int}> ;
	var _bg : String ;
	var _spirit : Int ;
	var _texture : String ;
	var _pnj_url : String ;
	var _object_url : String ;
	var _helps : Array<{_id : _ArtefactId, _help : String}> ;
	var _qmin : Int ;
	var _playCount : Int ;
	var _quest : {	_create : {_l : Array<{_id : _ArtefactId, _qty : Int, _tot : Int}>, _cAllInOne : Bool},
				_collect : {_l : Array<{_id : _ArtefactId, _qty : Int, _tot : Int}>},
				_chain : Int,
				_score : Int} ;
	var _sound : String ;
	var _music : String ;
	var _worldMod : String ;
	var _mod : Bool ;
}



typedef CheckData = {
	var _lsize : Int ;
	var _object : Int ;
	var _chain : Array<_ArtefactId> ;
	var _artefacts : Array<_Artefact> ;
	var _rcode : Int ;
	var _qmin : Int ;
}

typedef StartData = {
	var _id : Int ;
	var _token : Int ; 
	var _gold : Int ;
	var _goldScore : Int ; 
	var _rcheck : Int ;
	var _error : String ;
}


typedef GameLog = {
	var _id : Int ;
	var _infos : _GameData ;
	var _level : Int ;
	var _score : Int ;
	var _grid : Array<Array<_ArtefactId>> ;
	var _counters : Array<{_o : _ArtefactId, _nb : Int}> ;
	var _srewards : Array<{_by : _ArtefactId, _got : _ArtefactId, _nb : Int}> ;
	var _v : String ;
}


typedef SaveResult = {
	var _endUrl : String ;
}


typedef QuestPlayMod = {
	var _mode : String ; //changement du mode de jeu
	var _objects : Int ; //autorise les objets ou pas : -1 : non. 0 oui. 1...4 : autorise x objets
	var _forceuo : Array<_ArtefactId> ;
	var _artefacts : Array<_Artefact> ; //ajout d'artefacts à ceux de la zone
	var _replace : Bool ; //true si on ecrase les artefacts, false si on les ajoute juste
	var _replaceDefault : Bool ; //true si on remplace les elements par defaut ( Elts(2, null) et Elts(2, Neutral) )
	var _chain : Array<{_id : _ArtefactId, _index : Int}> ; //modif de la chaine
	var _hideIndex : Int ; //force une chaine d'éléments inconnus à partir de l'index x
	var _grid : Array<{ _id : _ArtefactId, _x : Int, _y : Int}> ; //grille de départ
}



enum _ProductData {
	_Col(id : String) ;
	_Fx(id : String) ;
	_Art(id : _ArtefactId, _qty : Int) ;
	_Recipe(c : Int) ;
	_Special(id : String) ;
	
}


enum _ArtefactId {	
	//éléments simples
	_Elt(e : Int) ;
	//groupe d'éléments à jouer
	_Elts(nb : Int, p : _ArtefactId) ; //p parasit
	
	// artefacts 
	_Alchimoth ;
	_Destroyer(e : Int) ;
	_Dynamit(v : Int) ;
	_Protoplop(level : Int) ;
	_PearGrain(level : Int) ;
	_Dalton ;
	_Wombat ;
	_MentorHand ;
	_Jeseleet(level : Int) ;
	_Delorean(level : Int) ;
	_Dollyxir(level : Int) ;
	_RazKroll ;
	_Detartrage ;
	_Grenade(level : Int) ;
	_Teleport ;
	_Tejerkatum ;
	_PolarBomb ;
	_Pistonide ;
	_Patchinko ;
	
	
	//auto falls 
	_Block(level : Int) ;
	_Neutral ;
	
	//utils
	_Pa ; //potion de vigueur
	_Surprise(level : Int) ;
	_Stamp ; //chouette timbres
	_Joker ; //joker pour les recettes : n'importe quel élément accepté dans le chaudron
	_Empty ;
	_Catz ;
	
	
	//quest artefacts
	_QuestObj(id : String) ; //objects spéciaux pour les quêtes, jamais ajoutés à l'inventaire
	_CountBlock(level : Int) ;
	
	//gameModes
	_DigReward(o : _ArtefactId) ;
	
	_Unknown;
	_GodFather ;
	_Pumpkin(id : Int) ;
	_Gift ;
	_SnowBall ;
	_Choco ;
	_NowelBall ;

	//race artefacts
	_Sct(id : String) ; //objets spéciaux utilisés autour du puit (ex : lot  de 1800 kubors) ou dans le coffre (tps quotidiens)
	_Slide(level : Int) ;
	_Skater ;
}


