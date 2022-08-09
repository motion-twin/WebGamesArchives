package com;

class Protocol {
	public static var DATA_VERSION = 43;

	// Protocol version => First mobile App version
	public static var APP_VERSIONS = [
		41 => "1.3.0",
		42 => "1.4.0",
		43 => "1.4.3"
	];

	#if mobile
	public static var REFUSALS_FOR_CLOUD_SAVE = 15;
	#end

	public static function init(){
		mt.net.Codec.addObfuDown( GameEffect );
		mt.net.Codec.addObfuDown( HotelData );
		mt.net.Codec.addObfuDown( ServerResponses );
		mt.net.Codec.addObfuDown( FriendRequestResult );

		mt.net.Codec.addObfuUp( ClientServerRequest );
		mt.net.Codec.addObfuUp( MiscCommand );
		#if flash
		// Uncomment to create/update obfuscation dictionary
		//mt.net.Obfuscator.createDictionary("../obfuDictionary.dat");
		#end
	}

	public static function commandNeedsMsgIdInc(c:ClientServerCommand) : Bool {
		return switch( c ) {
			case CS_BecomeMainClient(_) : false;
			case CS_AskTime, CS_GameCommand(_), CS_HotelOptions(_), CS_Settings(_) : true;
		}
	}
}


typedef HotelData = {
	var visitMode		: VisitMode;
	var curHotelId		: Int;
	var realHotelId		: Null<Int>;
	var guestId			: Null<Int>;
	var state			: HotelState;
	var lastMsgId		: Int;
	var cashProducts    : Map<String,String>;
	var facebook		: Bool;
	var inboxCount		: Int;
	var forceFriendReq	: Null<HotelFriendRequest>; // deprecated, not used anymore on v1.3+
	var forumUrl		: Null<String>;
	var musicUrl		: String;
	var owner			: String;
	var settings		: Settings;
	var serverTime		: Float;
	var admin			: Bool;
	var playedOnMobile	: Bool;
}

typedef Settings = {
	var sfx			: Bool;
	var music		: Bool;
	var lowq		: Bool;
	var confirmGems	: Bool;
	var showStocks	: Bool;
	var showStay	: Bool;
	@:optional var forcedLang	: Null<String>;
	@:optional var hideNotifs	: Bool; // API 42
}

typedef HotelOptions = {
	var name		: String;
}



// Warning: avoid changes to this typedef (stored as a SharedObject)
typedef ClientServerRequest = {
	var v			: Int;
	var msgId		: Int;
	var cid			: Int;
	var c			: ClientServerCommand;
}

enum ClientServerCommand {
	CS_GameCommand(c:GameCommand, t:Float);
	CS_AskTime;
	CS_Settings(s:Settings);
	CS_HotelOptions(s:HotelOptions);
	CS_BecomeMainClient(d:DeviceType);

	// <--- Add new enums here!
}

enum DeviceType {
	DT_Web;
	DT_Ios;
	DT_Android;
}

enum MiscCommand {
	MC_Friends(p:{fbToken:Null<String>});
	MC_Visit(uid:Int);
	MC_EndVisit;
	MC_GetLove(targetHotelId:Int, t:Float);
	MC_Log(msg:String);
	MC_DebugCmd(p0:String, p1:String);
	MC_GetMessages;
	MC_AskSync;
	MC_CloudSave(version:Int, s:HotelState);
}


typedef ServerResponses = Array<ServerResponse>;


enum ServerResponse {
	SR_CommandResults(oks:Array<Int>, refusals:Array<Int>, lastMsgId:Int, state:Null<HotelState>);
	SR_Resync(lastMsgId:Int, state:HotelState);
	SR_Visit(fh:FriendHotel, state:HotelState);
	//SR_SolverRefused(msgId:Int, e:SolverError, state:HotelState);
	SR_AlreadyProcessed(receivedId:Int);
	SR_MissedCommand(expectedId:Int, state:HotelState);
	SR_BankSync(gems:Int,gold:Int,transaction:Null<{type:String,value:Int}>);
	SR_Time(now:Float);
	SR_InboxSync(unread:Int);
	SR_ClientOutdated(receivedVersion:Int, serverVersion:Int);
	SR_Print(str:String);
	SR_FriendsHotels(arr:Array<FriendHotel>);
	SR_HotelMessages(arr:Array<HotelMessage>);
	SR_ClientIdMismatch;
}

typedef FriendRequestResult = {
	type: HotelFriendRequest,
	value: Int,
};

enum HotelFriendRequest {
	HFR_AskLove;
	HFR_ReturnLove;

	HFR_SendGem;
	HFR_SendGold;
	HFR_SendLove;

	HFR_ComeBack;
}


enum GameCommand {
	DoClientReady;
	DoPing;
	DoCompleteTutorial(id:String);
	DoUnlockFeature(id:String);
	//DoValidateLevelUp;

	DoCreateRoom(cx:Int, cy:Int, t:RoomType);
	DoDestroyRoom(cx:Int, cy:Int);
	DoBoostRoom(cx:Int, cy:Int);
	DoActivateRoom(cx:Int, cy:Int, ?setting:Dynamic);
	DoRepairRoom(cx:Int, cy:Int);
	DoRepairAll;
	DoSkipConstruction(cx:Int, cy:Int);
	DoSkipWork(cx:Int, cy:Int);
	DoUpgradeRoom(cx:Int, cy:Int);
	//DoRefillStock(cx:Int, cy:Int);

	DoMiniGame(cid:Int);
	DoInstallClient(cid:Int, cx:Int, cy:Int);
	DoSendClientToUtilityRoom(cid:Int, cx:Int, cy:Int, data:Int);
	DoValidateClient(cid:Int);
	DoValidateAll;
	DoSkipClient(cid:Int);
	DoSkipAllClients;
	DoGiveLove(cid:Int);

	DoUseItemOnRoom(cx:Int, cy:Int, i:Item);
	DoUseItem(i:Item);
	DoPickGift(cx:Int, cy:Int);

	DoService(cid:Int);
	DoBuyItem(i:Item, count:Int, ?cx:Int, ?cy:Int);
	DoBuyRandomCustom;
	DoCheat(c:CheatCommand);

	InternalCompleteClient(cid:Int);
	InternalRoomRepair(cx:Int, cy:Int);
	InternalUnsetConstructing(cx:Int,cy:Int);
	InternalUnsetWorking(cx:Int,cy:Int);
	InternalRoomTrigger(cx:Int, cy:Int);
	InternalQuestRegen;
	InternalClientSpecialAction(cid:Int);
	InternalClientPerk(cid:Int);
	InternalClientLock(type:ClientType);
	InternalSetFlag(k:String, v:Bool);

	DoClearCustomizations(cx:Int, cy:Int, ?i:Item);
	DoNewQuest;
	DoMessagesActions(msgs:Array<HotelMessage>);
	DoCancelQuest(qid:String);

	DoPrepareHotel(col:Int);
	DoGetSpecialReward(id:String);
	DoGetEventReward(id:String);

	DoBuyPremium(id:String);
	DoBeginTutorial(id:String);

	DoRate(later:Bool);
	DoLoginPopUps(timeZonedClientTime:String);
	DoHardCodedMessage(id:String);
	//DoDailyQuest(progress:Bool);

	// <--- Add new enums here!
}

enum VisitMode {
	VM_None;
	VM_VisitInGame;
	VM_VisitUrl;
}

enum CheatCommand {
	CC_Item(i:Item, n:Int);
	CC_Max(cid:Int);
	CC_Inspect;
	CC_FillCustom;
	CC_AddDay(n:Int);
	CC_Damage(cx:Int, cy:Int);
}


enum GameEffect {
	Ok(c:GameCommand);

	LevelUp;
	TutorialCompleted(id:String);
	LongAbsence;
	NewDay;
	HotelFlagSet(k:String, v:Bool);
	FeatureUnlocked(k:String);
	BossCooldownDec;
	BossCooldownReset(newLevel:Bool);
	BossArrived;
	BossResult(success:Bool);
	BossDied;

	CreateRoom(cx:Int, cy:Int, t:RoomType);
	DestroyRoom(cx:Int, cy:Int);
	RoomRepairStarted(cx:Int, cy:Int);
	RoomRepaired(cx:Int, cy:Int, dmg:Int);
	RoomWorkSkipped(cx:Int, cy:Int);
	RoomConstructionSkipped(cx:Int, cy:Int);
	RoomActivated(cx:Int, cy:Int);
	ItemUsedOnRoom(cx:Int, cy:Int, i:Item);
	RoomUpgraded(cx:Int, cy:Int);
	StockAdded(cx:Int, cy:Int, n:Int);
	StockRemoved(cx:Int, cy:Int);
	StockMovedTo(cx:Int, cy:Int, tx:Int, ty:Int, ?fast:Bool);
	CustomizationCleared(cx:Int, cy:Int, ?i:Item);
	RoomSwitched(cx:Int, cy:Int, t:RoomType);
	RoomBoosted(cx:Int, cy:Int);
	//Accident(cx:Int, cy:Int);
	QueueAutoRefilled;

	RegenClientDeck;
	MiniGame(cid:Int, money:Int, rewardLevel:Int);
	CheckMiniGame;

	ClientArrived(?type:ClientType);
	ForcedVipArrived;
	ClientBuilt(cx:Int, cy:Int, likes:Null<Array<Affect>>, dislikes:Null<Array<Affect>>, emit:Null<Affect>);
	ClientDone(cid:Int);
	ClientValidated(cid:Int, happiness:Int);
	ClientLeft(cid:Int);
	ClientDied(cid:Int);
	ClientInstalled(cid:Int, cx:Int, cy:Int);
	ClientSentToUtilityRoom(cid:Int, toX:Int, toY:Int);
	ClientSkipped(cid:Int);
	ClientWokeUp(cid:Int);
	ClientLoved(cid:Int);
	ClientMaxHappiness(cid:Int);
	AddClientSaving(cid:Int, n:Int);
	RemoveClientSaving(cid:Int, n:Int);
	ClientSpecial(cid:Int);
	ClientPerk(cid:Int, k:String, ?data:Int);
	ClientFlagSet(cid:Int, k:String);
	ClientAffectsChange(cid:Int, likes:Array<Affect>, dislikes:Array<Affect>, emit:Affect);

	RoomDamaged(cx:Int, cy:Int, dmg:Int, forceExplosion:Bool);

	HappinessPermanentAffect(cid:Int, v:Int, type:HappinessMod, notify:Bool);
	HappinessChanged(cid:Int, v:Int, delta:Int);
	HappinessModRemoved(cid:Int, m:HappinessMod);

	AddMoney(v:Int);
	AddMoneyFromClient(cid:Int, v:Int, important:Bool);
	AddMoneyFromRoom(cx:Int, cy:Int, v:Int, important:Bool);
	RemoveMoney(v:Int);
	RemoveMoneyFromRoom(cx:Int,cy:Int, v:Int);

	AddGems(n:Int, notify:Bool);
	RemoveGem(n:Int);
	RemoveGemFromRoom(cx:Int, cy:Int, n:Int);

	AddLove(n:Int);
	RemoveLoveFromRoom(cx:Int, cy:Int, n:Int);

	AddItem(i:Item, n:Int);
	AddItemFromRoom(cx:Int, cy:Int, i:Item, n:Int);
	RemoveItem(i:Item);
	AddGift(cx:Int, cy:Int, i:Item);
	GiftPickedUp(cx:Int, cy:Int, i:Item);
	CustoUnlocked(i:Item);
	LunchBoxOpened(i:Item, isNewCustom:Bool);

	SetConstructing(cx:Int,cy:Int, v:Bool);
	SetWorking(cx:Int,cy:Int, v:Bool);

	StartTask(c:GameCommand, duration:Float);
	RemoveTask(c:GameCommand);
	ServiceDone(cid:Int, sroomX:Int, sroomY:Int, type:RoomType);
	ServiceForced(cid:Int, type:RoomType);

	TrackMoneyEvent(id:String, value:Int, reason:String);
	TrackGameplayEvent(category:String, sub:String);

	QuestStarted(qid:String);
	QuestCancelled(qid:String);
	QuestAdvanced(qid:String, n:Int);
	QuestDone(qid:String, param:Int);
	QuestBought;

	Print(str:String);
	SyncLastEventTime(t:Float);

	MessageDiscarded(m:HotelMessage);

	AddStat(k:String, v:Int);

	SpecialRewardReceived(id:String, items:Array<{n:Int, i:Item}>);
	EventRewardReceived(id:String);

	PremiumBought(id:String);
	PremiumOnRoom(id:String, cx:Int, cy:Int);
	DailyLevelProgress(raise:Bool);

	Cheated(c:CheatCommand);
	Rated(later:Bool);
	ShowFriendRequest(f:HotelFriendRequest);
	ShowRating;

	EventGiftOpened(i:Item);
	StockAutoRefilled(x:Int, y:Int);

	HappinessModCapped(cid:Int, r:HappinessMod);
}

typedef FriendHotel = {
	owner: {
		id:		Int,
		name:	String,
		avatar:	Null<String>,
	},
	hotel: {
		id:		Int,
		name:	String,
		level:	Int,
		score:	Int,
	},
	friend: Null<{
		id:		String,
		net:	Int,
	}>
};

typedef HotelState = {
	var level		: Int;
	var name		: String;
	var bossCd		: Int;
	var gems		: Int;
	var money		: Int;
	var uniqClientId: Int;
	var seed		: Int;
	var lastNow		: Float;
	var lastRealTime: Float;
	var miniGameDate: Float;
	var miniGameCid	: Int;
	var love		: Int;
	var tasks		: Array<Task>;
	var rooms		: Array<RoomState>;
	var clients		: Array<ClientState>;
	var inventory	: Array<Item>;
	var flags		: Array<String>;
	var clientDeck	: Array<ClientType>;
	var cgenDeck	: Array<ClientGeneration>;
	var stats		: Array<{ k:String, v:Int }>;
	var curQuests	: Array<QuestState>;
	var customs		: Array<Item>;
	var messages	: Array<HotelMessage>;
	var dailyLevel	: Int;
	var lastDaily	: Float;
}

typedef RoomState = {
	var type		: RoomType;
	var cx			: Int;
	var cy			: Int;
	var wid			: Int;
	var level		: Int;
	var constructing: Bool;
	var working		: Bool;
	var gifts		: Array<Item>;
	var damages		: Int;
	var data		: Int;
	var custom		: RoomCustomization;
}

typedef RoomCustomization = {
	var color		: String;
	var texture		: Int;
	var bath		: Int;
	var bed			: Int;
	var ceil		: Int;
	var furn		: Int;
	var wall		: Int;
}

typedef ClientState = {
	var id					: Int;
	var type				: ClientType;
	var baseHappiness		: Int;
	var money				: Int;
	var likes				: Array<Affect>;
	var dislikes			: Array<Affect>;
	var emit				: Affect;
	var rx					: Int;
	var ry					: Int;
	var hmods				: Array<{ v:Int, t:HappinessMod }>;
	var flags				: Array<String>;
	var stayDuration		: Float;
	var serviceType			: RoomType;
	var serviceDate			: Float;
	var done				: Bool;
}

typedef QuestState = {
	var id		: String;
	var ocount	: Int;
	var oparam	: Int;
}

//enum QuestEvent {
	//Q_Host;
	//Q_MaxHappy;
	//Q_Love;
	//Q_Theft;
	//// <--- Add new enums here!
//}

enum HotelMessage {
	#if connected
	M_FriendRequest(id:Int,	f:mt.net.FriendRequest.Friend, type:Int, d:Null<String>);
	#else
	M_FriendRequest(id:Int,	f:Dynamic, type:Int, d:Null<String>);
	#end
	M_Visit(name:String);

	// <--- Add new enums here!
}

enum RoomType {
	R_Lobby;
	R_Bedroom;
	R_Trash;
	R_Bar;
	R_Laundry;
	R_ClientRecycler;

	R_StockPaper;
	R_StockSoap;
	R_StockBeer;
	R_StockBoost;

	R_Library;
	R_LevelUp;
	R_FillerStructs;
	R_CustoRecycler;
	R_Bank;
	R_VipCall;

	// <--- Add new enums here!
}


enum SolverError {
	InternalGameCommand;
	IllegalAction;
	IllegalTarget;
	UnknownTarget;
	UnknownClient;
	Useless;
	WaitingLineIsFull;
	CannotUseGemNow;
	NoTrashOnInstalledClient;
	NoRecyclerOnInstalledClient;
	ClientMustHaveARoom;
	TooLateToSkip;
	PickGiftsFirst;
	CannotRecycleThisClient;
	ValidateClientFirst;
	AlreadyHaveInspector;

	RoomMustBeEmpty;
	RoomIsLocked;
	RoomIsDamaged;
	RoomCannotBeEdited;
	AlreadyOccupied;
	CannotBuildHere;
	HotelConsistencyError;
	RoomMustBeConnected;
	NoLaundryAvailable;
	CannotCustomizeThisRoom;
	NeedEmptySpaceLeft;
	NeedEmptySpaceRight;
	CannotDestroyStockIfNotFull;
	CannotDestroyRoom;
	RoomMaximumReached;

	NeedMoney(n:Int);
	NeedGems(n:Int);
	NeedLove(n:Int);
	NeedItem(i:Item);

	NeedStock(t:RoomType, n:Int);

	ClientNeedMoney(n:Int);
	ClientDoesntLike(a:Affect);
	CannotUseItemHere;
	AlreadyUsedItemOnEmitter;

	InvalidTimeStamp;
	NotUnderground;

	EventRefused;
	EventAlreadyDone;

	TimezoneError;
}

enum Affect {
	Heat;
	Cold;
	Odor;
	Noise;
	SunLight;
}

enum HappinessMod {
	HM_PresenceOfLike(a:Affect);
	HM_PresenceOfDislike(a:Affect);
	HM_AbsenceOfLike(a:Affect);
	HM_AbsenceOfDislike(a:Affect);
	HM_DirtyRoom;
	HM_Moved;
	HM_Row;
	HM_Column;
	HM_Present(i:Item);
	HM_Luxury;
	HM_Love;
	HM_LikerBase;
	HM_HotelServices;
	HM_JoyBomb;
	HM_Vip;
	HM_Gem;
	HM_Customization;
	HM_MissingStock(t:RoomType);
	HM_Isolation;
	HM_Altitude;
	HM_Underground;
	HM_AbsenceOfSunlight;
	HM_NiceNeighbour;
	HM_Cannibalism;
	HM_Annoying;
	HM_Sociable;
	HM_StockThief;
	HM_Alcoholic;
	HM_Antisocial;
	HM_PerkSpecialRequest;
	HM_Unhappy;

	// <--- Add new enums here!
}


typedef Task = {
	var start	: Float;
	var end		: Float;
	var command	: GameCommand;
}

enum ClientType {
	C_Liker;
	C_Disliker;
	C_MobSpawner;
	C_Spawnling;
	C_Vampire;
	C_Custom;
	C_Bomb;
	C_Repairer;
	C_Plant;
	C_HappyLine;
	C_HappyColumn;
	C_Inspector;
	C_Gifter;
	C_Gem;
	C_Rich;
	C_Dragon;
	C_JoyBomb;
	C_Emitter;
	C_MoneyGiver;
	C_Neighbour;

	C_Halloween;
	C_Christmas;

	// <--- Add new enums here!
}

enum Item {
	I_Heat;
	I_Cold;
	I_Odor;
	I_Noise;
	I_Money(n:Int);
	I_Gem;
	//I_Xp(n:Int);
	I_Light;

	I_Color(id:String);
	I_Texture(f:Int);

	I_Bed(f:Int);
	I_Bath(f:Int);
	I_Ceil(f:Int);
	I_Furn(f:Int);
	I_Wall(f:Int);

	I_LunchBoxAll;
	I_LunchBoxCusto;
	I_EventGift(i:Item);

	// <--- Add new enums here!
}

enum ClientGeneration {
	G_Empty;
	G_Double;
	G_EasyNotDouble;
	G_EasyOrDouble;

	G_LikeLight;
	G_DislikeLight;
	G_LikeLightHard;

	G_DislikerEasy;
	G_DislikerHard;
	G_DislikerDouble;

	// <--- Add new enums here!
}



