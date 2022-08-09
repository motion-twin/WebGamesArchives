import MissionGen;

typedef PInit = {
	_sfxVer		: Int,
	_musicVer	: Int,
	_startUrl	: String,
	_endUrl		: String,
	_errorUrl	: String,
	_iconsUrl	: String,
	_iconsVer	: Int,
	_sfxUrl		: String,
	_seed		: Int,
	_gl			: Int,
	_m			: MissionData,
	_decks		: List<{_name:String, _content:Array<String>}>,
	_chip		: String,
	_c			: Bool, // challenge
	_bios		: Int,
	_profile	: {
		_uname		: String,
		_ulevel		: Int,
		_low		: Bool,
		_adult		: Bool,
		_leet		: Bool,
		_cfg		: String,
		_sfx		: Bool,
		_ambiant	: Bool,
		_beat		: Bool,
	}
}

typedef PStart = {
	_error		: String,
	_init		: PInit,
}

typedef PEnd = {
	_init		: PInit,
	_success	: Bool,
	_kills		: Int,
	_rt			: Int, // temps restant, en secondes
	_valuables	: List<String>,
	_storage	: List<SimpleFile>,
	_goals		: List<{_gid:String, _n:Int}>,
	_fps		: Int, // tmod moyen
}

enum _Message {
	SEND_OK(url : String);	// une fois la partie finie, le serveur renvoie SEND_OK au client si tout s'est bien déroulé
	SEND_NOT_OK(url : String, error : String, stack : String); // le serveur dit au client qu'il a rencontré un souci et indique l'erreur et le stack
	MISSION_RESULT( end : PEnd ); // TODO Définir les infos renvoyées par le client au serveur pour enrgistrement en base
}

typedef SimpleFile = {
	_name		: String,
	_content	: String,
	_embed		: String,
}
