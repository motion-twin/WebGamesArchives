package db;
import mt.db.Types;
import Common;
import data.Explo;
import data.Explo.ExploKind;
import tools.Utils;
import tools.MazeGenerator;

using mt.Std;
class Explo extends neko.db.Object
{
	static var PRIVATE_FIELDS = ["data", "kind"];
	static var TABLE_IDS = ["zoneId"];
	static var RELATIONS = function() {
		return [{ key : "zoneId", 	prop : "zone", 	manager : Zone.manager,	lock : false },
				{ key : "uid", 		prop : "user",	manager : User.manager,	lock : false } ];
	}

	public static var manager = new ExploManager();
	
	private var _data		: SNekoSerialized;
	private var _kind 		: SString<20>;
	public var data			: Array<Array<ExploCell>>;
	public var kind			: ExploKind;
	public var uid			: SNull<SInt>;
	public var width		: SInt;
	public var height		: SInt;
	public var x			: SInt;
	public var y			: SInt;
	public var inRoom		: SBool;
	public var oxygen		: SFloat;
	public var lastUpdate	: SDateTime;
	
	public var zoneId(default, null)	: SInt;
	public var zone(dynamic, dynamic) 	: Zone;
	public var user(dynamic, dynamic) 	: SNull<User>;
	
	inline public static var START_X	: Int = 8;
	inline public static var START_Y	: Int = 0;
	inline public static var DEFAULT_OXYGEN : Int = 5 * 60 * 1000;// 5 minutes
	
	public function new( p_kind : ExploKind, p_zone : db.Zone, ?pWidth, ?pHeight ) {
		super();
		kind = p_kind;
		zone = p_zone;
		data = null;
		x 	 = START_X;
		y 	 = START_Y;
		if( pWidth != null ) 	width = pWidth;
		if( pHeight != null ) 	height = pHeight;
		inRoom = false;
		oxygen = DEFAULT_OXYGEN;
	}
	
	public function isOver() {
		return (Date.now().getTime() - lastUpdate.getTime()) > oxygen;
	}
	
	public function isVisited() {
		return uid != null;
	}
	
	public function getCurrentCell() {
		return data[y][x];
	}
	
	public function getCurrentCellId() {
		return y * width + x;
	}
	
	public function getZombies() {
		return data[y][x].zombies;
	}
	
	public function getAtId(id:Int) {
		var y = Std.int(id / width);
		var x = id - (y * width);
		return data[y][x];
	}
	
	public function getAt(px:Int, py:Int) {
		if( px >= width  || px < 0 ) return null;
		if( py >= height || py < 0 ) return null;
		return data[py][px];
	}
	
	// does not update automatically !
	public function getRandomItem(?chanceBonus:Int = 0) : Tool {
		var cell = getCurrentCell();
		if( cell.room == null )
			return null;
			
		var tools = Lambda.array(cell.room.drops);
		if( tools == null || tools.length == 0 )
			return null;
		
		// On teste déjà s'il est possible de trouver qqch
		var probaEmpty = 100 - Const.get.ExplorationSearchChance;
		if( Std.random( 100 ) < probaEmpty - chanceBonus )
			return null;
		
		var t = tools[Std.random(tools.length)];
		return XmlData.getToolByKey(t);
	}
	
	public function generateExplo(p_map:db.Map, p_width, p_height, pRooms, zombies) {
		this.width = p_width;
		this.height = p_height;
		
		var maze = new tools.ExploMaze(width, height, pRooms);
		maze.generate(START_X, START_Y);
		var maxDistance = maze.getMaxDistance();
		var defaultCount = 7;
		var count = defaultCount;
		var lData = maze.getData();
		//
		var cells = [];
		var rooms = [];
		var drops = [];
		//
		for ( i in 0...height ) {
			cells[i] = [];
			for ( j in 0...width ) {
				var n = lData[i][j];
				var w = n.type != MazeNodeType.Wall;
				var z = 0;
				if( w && Std.random(count--) == 0 && zombies > 0 ) {
					z = 1 + Std.random(Std.int(n.distance / 10));
					zombies -= z;
					count = defaultCount;
				}
				cells[i][j] = {
					walkable: w,
					zombies : z,
					kills	: 0,
					room 	: null,
					details : Std.random(0xFFFF),
				};
				if( n.special == MazeNodeSpecialType.Room ) {
					var room : ExploRoom = {
						locked 		: (n.distance > 10) ? true : false,
						doorKind	: Type.createEnumIndex(ExploDoorKind, (n.distance <= 10) ? 0 : (Std.random(3)+1)),
						drops 		: new List(),
						distance	: n.distance,
					};
					rooms.push(room);
					cells[i][j].room = room;
				}
			}
		}
		
		// drops
		var prePlan = switch( kind )  {
			case ExploKind.Bunker 	: "bunker_";
			case ExploKind.Hospital : "hospital_";
			case ExploKind.Hotel 	: "hotel_";
		};
		for( i in 0...Const.get.MaxExploPlanDropUncommon )
			drops.push( XmlData.getToolByKey( prePlan + "bplan_u" ) );
		for( i in 0...Const.get.MaxExploPlanDropRare )
			drops.push( XmlData.getToolByKey( prePlan + "bplan_r" ) );
		for( i in 0...Const.get.MaxExploPlanDropEpic )
			drops.push( XmlData.getToolByKey( prePlan + "bplan_e" ) );
		//
		var rareCount = Std.int(pRooms / 2);
		var unusualCount = Std.int(1.5 * pRooms);
		var commonCount = 3 * pRooms;
		for( i in 0...rareCount )
			drops.push( tools.ExploTool.getRandomResource( kind, ExploResourceKind.Rare ) );
		for( i in 0...unusualCount )
			drops.push( tools.ExploTool.getRandomResource( kind, ExploResourceKind.Unusual ) );
		for( i in 0...commonCount )
			drops.push( tools.ExploTool.getRandomResource( kind, ExploResourceKind.Common ) );
		// on mélange le tout
		drops = Utils.shuffle(drops);
		//
		var offset = 0;
		var defaultRsc = Const.get.DefaultExploRoomRscDrop;
		for( room in rooms ) {
			var count = defaultRsc + offset + Std.random(3) - Std.random(3);
			var offset = defaultRsc - count;
			for( i in 0...count ) {
				if( drops.length > 0 ) {
					room.drops.add( drops.pop().key );
				}
			}
		}
		
		var openRooms = [];
		var closedRooms = [];
		function getRoomKeyKind(r) {
			return switch( r.doorKind ) {
				case ClassicKey	: "bumpKey";
				case MagneticKey: "magneticKey";
				case BumpKey	: "classicKey";
				case Normal		: throw "Error, no key type for that door";
			}
		}
		Lambda.iter( rooms, function(r) r.locked ? closedRooms.push(r) : openRooms.push(r) );
		openRooms.sort( function(r1, r2) return r1.distance - r2.distance );
		closedRooms.sort( function(r1, r2) return r1.distance - r2.distance );
		// we make sure a locked room remains closed without the technician special capability
		closedRooms.pop();
		// place keys
		for( room in closedRooms ) {
			var availableRooms = Lambda.array(Lambda.filter( openRooms, function(r) return r.distance <= room.distance ));
			var targetRoom = availableRooms[Std.random(availableRooms.length)];
			targetRoom.drops.add( getRoomKeyKind(room) );
			// we do not drop several keys in the same room
			openRooms.remove(targetRoom);
			// this room can now be considered as an opened one
			openRooms.push( room );
		}
		// on ajout le vaccin
		if ( kind == ExploKind.Hospital && p_map.hasMod("GHOULS") && p_map.hasMod("GHOUL_VACCINE")) {
			var room = rooms[Std.random(rooms.length)];
			// on s'assure que l'objet existe en passant par XmlData
			room.drops.push( XmlData.getToolByKey("ghoul_vaccine").key );
		}
		
		return cells;
	}
}

private class ExploManager extends neko.db.Manager<Explo> {
	public function new() {
		super(Explo);
	}

	override function make( explo : Explo ) {
		var explo2 : { private var _kind : String; private var _data : SNekoSerialized; } = explo;
		explo.data = 	try neko.Lib.localUnserialize(neko.Lib.bytesReference(explo2._data)) catch ( e : Dynamic ) throw Std.string(e) + " #" + explo.zoneId;
		explo.kind = Reflect.field(ExploKind, explo2._kind);
	}

	override function unmake( explo : Explo ) {
		var explo2 : { private var _kind : String; private var _data : SNekoSerialized; } = explo;
		explo2._data = 	try neko.Lib.stringReference(neko.Lib.serialize(explo.data))  catch ( e : Dynamic ) throw Std.string(e) + " #" + explo.zoneId;
		explo2._kind = Std.string(explo.kind);
	}
}
