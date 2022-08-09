#if solver_server
import com.Protocol;
typedef UserInfos = Dynamic;
#else
typedef HotelState = Dynamic;
typedef UserInfos = db.UserInfos;
#end

typedef CommonData = {
	admin: Bool,
	realHotelId: Int,
	guestId: Int,
	facebook: Bool,
	forumUrl: String,
	musicUrl: String,
	playedOnMobile: Bool
};

typedef ServerSettings = com.Protocol.Settings;

enum PushEvent {
	PE_ClientsReady;
	PE_DailyReward;
	PE_LongAbsence;
}

interface ServerMainApi {
	// These functions are based on current logged user
	function getCommon() : CommonData;
	function setSettings( solver:ServerSolverApi, settings : ServerSettings ) : Void ;
	function getSettings( solver:ServerSolverApi ) : ServerSettings ;
	function getFriendReqCount() : Int;

	// TODO type!
	function getFriends( mySolver:ServerSolverApi, params:Dynamic ) : Dynamic;

	// These functions are based on current hotel (and hotel owner)
	function getState( solver : ServerSolverApi, forUpdate: Bool ) : HotelState;
	function saveState( solver:ServerSolverApi, state : HotelState, savedByOwner: Bool ) : Void ;
	function updateHotel() : Void;

	function getHotelId() : Int;
	function getOwner() : UserInfos;
	function getOwnerName() : String;

	function getLastMsgId() : Int;
	function getLastClientId() : Int;
	function setLastMsgId( msgId : Int ) : Int;
	function setLastClientId( clientId : Int ) : Int;
	function setOwnerDeltaTZ( delta : Float ) : Void;
	function getOwnerDeltaTZ( ) : Null<Float>;


	// These functions are complicated

	function getFriendHotel( mySolver:ServerSolverApi, uid : Int ) : { hotelId: Int, state: HotelState, owner: Dynamic };
	function visitFriendHotel( visitorSolver : ServerSolverApi, hotelId : Int ) : Null<Int>;
}
