import Common.PlanetInfos;

typedef BlockInventory = Array<Null<{ k : Int, n : Int }>>; //kind of blocks, nb blocks
typedef UserCharges = Array<{ c : Int, n : Int }>;

typedef InventoryInfos = {
	var maxWeight : Int;
	var t : BlockInventory;
	var charges : UserCharges;
}

enum UserFlags {
	Flying;
	ReturnToShip;
	CameraMode;
	Invincible;
}

enum Controls
{
	CLASSIC;
	MOUSE;
	MOUSE_LOCK;
}

typedef UserPos = {
	var x : Float;
	var y : Float;
	var z : Float;
	var a : Float;
	var life : Float;
	var az : Float;
	var flags : haxe.EnumFlags<UserFlags>;
	var mouseCtrl : Bool;
}

typedef GameInfos = {
	var planet : PlanetInfos;
	var lastPos : UserPos;
	var inventory : InventoryInfos;
	var debug : Bool;
	var offline : Bool;
	var userId : Null<Int>;
	var userName : String;
	var ship : Null<{ x : Int, y : Int, z : Int, data : haxe.io.Bytes }>;
	var crafts : Null<Array<{ addr : Int, bid : Int }>>;
}

typedef EditShipInfos = {
	var inventory : InventoryInfos;
	var size : { x : Int, y : Int, z : Int };
	var ship : haxe.io.Bytes;
	var debug : Bool;
}

typedef UserStats = {
	var soft : Bool;
	var fps : Float;
	var chunkTime : Float;
	var multi : Bool;
}

enum LootKind {
	LKBlock;
	LKCharge;
}

@:native('_M')
enum ClientMode {
	MGame( inf : GameInfos );
	MEditShip( inf : EditShipInfos );
	MExplore( inf : ExploreProtocol.ExploreInfos );
}

typedef LootContent = Array<{ k : Int, v : Int, n : Int }>;// lootKind, value of id , nb

typedef LootInfos = {
	var x : Float;
	var y : Float;
	var z : Float;
	var k : Int;		// Type de block affiché !
	var content : LootContent;
	var time : Float;
}

typedef QueueMessage = { uid : Int, a : ServerAction };

typedef BlockProperties = {
	var id : Int;
	var max : Int;
	var content : BlockInventory;
}

@:native('_A')
enum ClientAction {
	CRequestChunk( pid : Null<Int>, x : Int, y : Int );
	CSavePos( p : UserPos, s : UserStats );
	CSet( blocks : haxe.io.Bytes );
	CReturnShip( manual : Bool, x : Float, y : Float, z : Float );
	CPickLoot( id : Int, c : LootContent );
	CBlockIcon( k : Int, b : haxe.io.Bytes );
	CDrop( index : Int, x : Float, y : Float, z : Float );
	CSetLootPos( id : Int, x : Float, y : Float, z : Float );
	CEditShip;
	CSaveShip( data : haxe.io.Bytes, inv : InventoryInfos );
	CReturnGame;
	CActivate( x : Int, y : Int, z : Int, b : Int );
	CCraft( id : Int, out : { x : Int, y : Int, z : Int }, ?pos : { x : Int, y : Int, z : Int, sx : Int, sy : Int, sz : Int } );
	CVersion( v : Int, a : ClientAction );
	CEnterSpace;
	CConnect( pid : Int, isVisible : Bool );
	CTalk( msg:String );
	CGetProperties( x : Int, y : Int, z : Int );
	CMoveContent( id : Int, user : BlockInventory, kube : BlockInventory );
}

@:native('_C')
enum ServerAction {
	SOk;
	
	SMult( a : Array<ServerAction> );
	SRedir( url : String );
	SUploadPlanet( id : Int );
	SChunk( x : Int, y : Int, data : haxe.io.Bytes, cmp : Bool, diff : haxe.io.Bytes );
	SReduceWater;
	SLoadModule( url : String, ?inventory : Bool );
	SExitModule;
	SSetInventory( inv : InventoryInfos );
	SSetPos( p : UserPos );
	SAddLoot( id : Int, inf : LootInfos );
	
	SResult( v : Dynamic );
	SGotoShip;
	SMessage( msg : String, c : ServerAction );
	SToraResult( c : ServerAction );
	SChanges( cx : Int, cy : Int, data : haxe.io.Bytes );
	SUserJoin( uid : Int, name : String );
	SUserLeave( uid : Int );
	SConnect( url : String );
	STalk( uid : Int, msg:String );
	
	SDeleteLoot( id: Int );
	
	SSetResult( b : haxe.io.Bytes );
}
