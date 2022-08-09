import ServerMainApi;
#if solver_server
import com.Protocol;
#end

interface ServerSolverApi {
	// Standard functions, not necessarily applied on current hotel

	function init() : HotelState;
	function unserialize( serialized:haxe.io.BytesData ) : HotelState;
	function patchState( state:HotelState, fromVersion:Int, owner:ServerMainApi.UserInfos ) : Void;
	function serialize( state : HotelState ) : haxe.io.BytesData;

	function admSerialize( state : HotelState ) : neko.NativeString;
	function admUnserialize( str : neko.NativeString ) : HotelState;

	function getVersion() : Int;
	function getLevel( state : HotelState ) : Int;
	function getGems( state : HotelState ) : Int;
	function getGold( state : HotelState ) : Int;
	function getCustoms( state : HotelState ) : Array<{k: String,n: Int}>;
	function addGems( state : HotelState, gems : Int ) : Void;
	function addGold( state : HotelState, gold : Int ) : Void;
	function getNextPushEvent( state : HotelState ) : Null<{time: Float, type: Int}>;
	function getLoveFromState( state : HotelState ) : Int;

	// TODO type!
	function getHotelForFriend( hotelId: Int, state: HotelState ) : Dynamic;


	// Current Hotel specific functions

	function getCurrentState( forUpdate: Bool ) : HotelState;
	function makeHotelData( cashProducts: Map<String,String>, isVisit: Bool ) : neko.NativeString;
	function acceptReqGems() : Int;
	function acceptReqGold() : Int;
	function visitedByFriend( visitorName : String ) : HotelState;
	function getTmpUpdatedState( t : Float ) : HotelState;

	// Directly print result
	function doCmd( subApi:{setAndroid:Void->Void, setIos:Void->Void} ) : Void;
	function doMiscCmd() : Void;
	function doInboxSync() : Void;
	function doBankSync( lt:Dynamic ) : Void;

}
