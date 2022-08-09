import Datas;
import mt.bumdum.Lib;



typedef GameParam = { id:Int, read:Float, canal:Int };


class Param {//}

	public static var VERSION = 1.2;
	public static var IGHelp = true;
	public static var so:flash.SharedObject;

	public static var game:GameParam;

	public static var tecModels:Array<TecModel>;
	public static var flags:Array<Bool>;

	public static function load(){
		so = flash.SharedObject.getLocal("skywar");

		// INIT PARAMS
		if( so.data.version < VERSION || so.data.version == null ) initParams();
		loadGameParam();

		//
		//tecModels = so.data.tecModels;
		flags = so.data.flags;
	}

	static function initParams(){
		Inter.me.trace("[PARAMS] Passage de la version "+so.data.version+" à la version "+VERSION);
		so.data.version = VERSION;
		so.data.games = [];
		//so.data.tecModels = [];

		// FLAGS
		so.data.flags = [
			true,
			false,false,true,true,false,
			true,false,
			true,true,true,
			false,false
		];
		so.flush();


	}

	static function loadGameParam(){
		var gid = Game.gameId;

		//
		var a:Array<GameParam> = so.data.games;
		for( g in a ){
			if( g.id == gid ){
				game = g;
				break;
			}
		}

		//
		if( game == null ){
			game = { id:gid, read:null, canal:255 };
			a.push(game);
			if(a.length>10)a.shift();
			so.flush();
		}
	}

	// FLAGS
	public static function is(f:_ParamFlag){
		return flags[Type.enumIndex(f)];
	}
	public static function toggleFlag(id){
		flags[id] = !flags[id];

		var cons = Type.getEnumConstructs(_ParamFlag);
		var en = Type.createEnum(_ParamFlag,cons[id]);

		switch(en){
			case PAR_FAST_LINK :
				if( !flags[id] )flags[Type.enumIndex(PAR_FAST_LINK_SELF)] = false;
			case PAR_FAST_LINK_SELF :
				if( flags[id] )flags[Type.enumIndex(PAR_FAST_LINK)] = true;

			default:

		}

		so.flush();
	}

	// TEC MODELS
	public static function addTecModel(name,list,raceId){
		tecModels.push( {_name:name,_list:list,_raceId:raceId} );
		Api.saveTecModels();
	}
	public static function removeTecModel(id){
		tecModels.splice(id,1);
		Api.saveTecModels();
	}

	// CHAT
	public static function readUntil(n:Float){
		if(n==null)return;
		// trace("readUntil("+n+")!");
		if( game.read<n || game.read ==null ){
			game.read = n;
			so.flush();
		}
	}
	public static function lastRead(){
		return game.read;
	}

	public static function setCanal(n){
		game.canal = n;
		so.flush();
	}







//{
}















