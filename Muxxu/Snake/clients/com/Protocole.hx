typedef Protocole = {}
import mt.bumdum9.Lib;

@:build(mt.data.Mods.build("data.ods", "cartes", "id")) enum _CardType {
}


enum ClientMode {
	GAME;
	BROWSER;
	FRUIT_EDITOR;
}

enum FTag {
	Sugar;
	Red;
	Leaf;
	Small;
	Nut;
	Flower;
	Agrume;
	Green;
	Liane;
	Alien;
	Berries;
	Long;
	Courge;
	Poire;
	Blue;
	Apple;
	Shit;
	Orange;
	Yellow;
	Pink;
}

enum BonusType {
	BONUS_DYNAMITE;			// CASSE 5 cm de queue du serpent x le nombre de dynamites trouvées.
	BONUS_SCISSOR;			// CASSE 10% de la queue du serpent
	BONUS_CHEST;			// LACHE 10 FRUITS
	BONUS_FLUTE;			// Créé une série de fruit en partant d'un fruit aleatoire  dans la direction ou regarde le serpent
	BONUS_GUITAR;			// Créé 4 séries de fruit en partant d'un fruit aleatoire  dans 4 directions.
	BONUS_TRUMPET;			// Créé une série de fruit qui suit les déplacements du joueur.
	BONUS_RING;				// Créé un cercle de 12 fruits du même type autour de l'option
	BONUS_PILLULE;			// Augmente la vitesse de 100% 3000 points
	BONUS_MOLECULE;			// Augmente la frutibarre de 7%
	BONUS_BIG_MOLECULE;		// Augmente la frutibarre de 20%
	BONUS_ROD;				// Fait appraitre un tres gros fruit valeur x10
	BONUS_MATCHES;			// brule 20cm de serpent au fur et a mesure. S'arrete en cas d'acceleration.
	BONUS_GRAIN;			// fait apparaitre une multitude de fruits durants quelques secondes.
	BONUS_BELL;				// fait disparaitre 50% de la queue du serpent et la remplace par des fruits verts.
	BONUS_SHIELD;			// Ajoute 1x bouclier.
	BONUS_VIET;				// Echange queue contre fbarre
	BONUS_AMULET_RED;		// Fait apparaitre 10 fruits rouges
	BONUS_AMULET_GREEN;		// Fait apparaitre 10 fruits verts
	BONUS_AMULET_BLUE;		// Fait apparaitre 10 fruits bleus
	BONUS_CARD;				// ACTIVE/DESACTIVE une carte au hasard
	BONUS_SHIELD_BLUE;		// ACTIVE/DESACTIVE une carte au hasard
	
	BONUS_GETA;				// TODO : ralentit le serpent
	
}

enum GameType {
	GT_STANDARD;
	GT_TENNIS;		// COFFRE INFINI, Balle de tennis au départ, le jeu s'arrête quand la balle disparait
}

enum ControlType {
	CT_MOUSE;
	CT_ORTHO;
	CT_STANDARD;
	CT_BRAIN;
}

typedef _GameLog = {
	fruits:Array<Int>,
	bonus:Array<BonusType>,
	rec:haxe.io.Bytes,
	frutipowerMax:Float,
	lengthMax:Float,
	chrono:Float,
	score:Int,
}


typedef Obstacle = { x:Float, y:Float, ray:Float, collide:Void->Void };
typedef _DataCard = { _type:_CardType, _available:Bool };
typedef DataFruit = { score:Int, cal:Int, vit:Int, tags:Array<FTag>, sta:Int, rank:Int, freq:Int };
enum QueueType {
	Q_STANDARD;
	Q_RAINBOW(spc:Float, alpha:Float);
	Q_BONES;
}


#if flash
typedef LoadingBox = { base:pix.Sprite, field:TF, field2:TF, n:Int };



#end

// DATA
typedef DataCard = {
	id:_CardType,
	mojo:Int,
	freq:String,
	multi:Null<String>,
	time:Null<Int>
};
typedef DataText = {
	name:Null<String>,
	desc:Null<String>,
	fruit:String,
}


typedef _DataReplay = {
	_rec:haxe.io.Bytes,
	_id:Int,
	_sid:Int,
	_hand:Array<_CardType>,
	_player:_DataPlayer,
	_score:Int,
	_dateString:String,
}
typedef _DataPlayer = {
	_id:Int,
	_name:String,
	_avatar:String,
	_rank:Int,
}

// DATA ROOT
typedef _DataBrowser = {
	_age:Null<Int>,
	_plays:Int,
	_cards:Array<_DataCard>,
	_draft:_DataDraft,
	_me:_DataPlayer,
}

// DATA DRAFT
typedef _DataDraft = {
	_tid:Int,
	_step:_DraftStep,
	_players:Array<_DataPlayer>,
	_serverUrl:String,
	_pKey : Null<String>,
	_timeLimit:Float,
}

enum _DraftStep {
	DST_WAIT ;
	DST_SUBSCRIBE ;
	DST_DRAFT ;
	DST_PLAY(players:Array<_DraftPlayer>) ;
}


/*
typedef _GSubscribeSend = {
	_id:String
}
typedef _GSubscribeReceive = {
	_ok:Bool,
	_nomoney:Bool,
	_full:Bool,
}*/

enum _DraftCmd {
	CMD_HELLO ;
	CMD_CHOOSE(t:_CardType) ;
	CMD_PING(id : Int) ;
	CMD_SUBSCRIBE(id : String) ;
}

enum _DraftMsg {
	MSG_INIT( cards:Array<_CardType>, players:Array<_DraftPlayer>) ;
	MSG_PACK(a:Array<_CardType>, to : Int, peremption:Float ) ;
	MSG_PICK(type:_CardType, by : Int) ;
	MSG_PASS(pid:Int, to : Int, cards:Int) ;
	MSG_NEW_PLAYER(data:_DraftPlayer) ;
	MSG_END_DRAFT ;
	MSG_MULTI(m : Array<_DraftMsg>) ;
	MSG_PINGED(id : Int) ;
	MSG_OK ;
	MSG_ABORTED ;
	MSG_SUBSCRIBE(ok : Bool, nomoney : Bool, full : Bool) ;
}

typedef _DraftPlayer = {
	_data:_DataPlayer,
	_cards:Int,
	_cardDetails:Array<_DataCard>,
	_packs:Int,
	_score:Int,
	_per:Null<Float>,
}

/*
typedef _DraftPlayer2 = {
	_data:_DataPlayer,
	_cards:Array<_DataCard>,
	_hiscore:Int,
}
*/



// DATA ENVOI/RECEPTION
typedef _GStartSend = {
	_cards:Array<_CardType>
}
typedef _GStartReceive = {
	_id:Null<Int>,
	_gid:Int,
	_cards:Array<_CardType>
}
typedef _GEndSend = {
	_id:Int,
	_score:Int,
	_fruits:Array<Int>,
	_record:haxe.io.Bytes,
	_tr:Int,				// RETRY sur l'envoi
	_pt:Float,				// PLAYTIME ( temps de jeu pour le joueur )
	_tra:Float,				// TIME RATIO 1.0 = OK		2.0 = ralenti
}
typedef _GEndReceive = {
	_progression:Array<{_id:Int,_lvl:Int}>,
	_err : Int
	//_progression:Array<{id:Int,lvl:Int}>,
	//titems:Array<Int>,
}


// ENCYCLOPEFRUIT
typedef _FruitPage = {
	_list:Array<Int>,
}

// QUEST
typedef _QuestPage = {
	_list:Array<_DataQuest>,
}
typedef _DataQuest = {
	_id:_CardType,
	_desc:String,
	_success:Bool,
	_visible:Bool,
}

// SHOP
typedef _DataCollection = {
	_priceCard:Int,
	_pricePack:Int,
	_priceTicket:Int,
	_tickets:Int,
	_totalTickets:Int,
	_lotteryCard:_CardType,
	_lotteryWinner: { _name:String, _url:String },
	_deal:_BazarDeal,
	_cards:Array< {_type:_CardType,_num:Int} >,
	
}

typedef _ShopRequest = {
	_type:_ShopRequestType,
}
typedef _ShopItem = {
	_a : Array<_CardType>
}
enum _ShopRequestType {
	CRT_SINGLE;
	CRT_PACK;
	CRT_TICKET;
}

typedef _BazarDeal = {
	_card:_CardType,	// _card = null > no more deal for today
	_price:Int,
}

enum _BazarRequest {
	BRT_NO;
	BRT_MORE;
	BRT_OK;
}

typedef _BazarResult = {
	_price:Int,				// -1 == or >=
	_next:_BazarDeal,		// _next = null > QUIT
}



// SCORE
typedef _HallOfFame = {
	_me:String,
	_sections:Array<_ScoreSection>,
}

typedef _ScorePage = {
	_list:Array<_PlayerScore>,
}
typedef _ScoreCall = {
	_s:_ScoreSection
}
typedef _PlayerScore = {
	_name:String,
	_avatar:String,
	_score:Array<_ScoreData>,
}
typedef _ScoreData = {
	_score:Int,
	_replayId:Int,
	_cards:Array<_CardType>,
}

enum _ScoreSection {
	SS_FRIENDS;
	SS_GROUP(name:String);
	SS_ARCHIVE;
	SS_TOP;
	SS_MY_DRAFT ; //draft en cours
	SS_DRAFT(id : Int, n : Int) ; //autres drafts du jour
	SS_RAINBOW ; //classement rainbow du jour
}

/*
 		var pos = 				Reflect.field(params, "pos");
		var name = 				Reflect.field(params, "name");
		var score = 			Reflect.field(params, "score");
		var avatar = 			Reflect.field(params, "avatar");
		var cardString:String =	Reflect.field(params, "cards");

*/


// TODO urlReplay:String