package gen;
import DungeonCodec.DungeonItem;

typedef Table<T> = flash.Vector<T>;

class Group {
	public var id : Int;
	public var rooms : Table<Room>;
	public function new(id) {
		this.id = id;
		rooms = new Table();
	}
}

class Door {
	public var r1 : Room;
	public var r2 : Room;
	public var x : Int;
	public var y : Int;
	public var status : Int;
	public function new(r1,r2) {
		this.r1 = r1;
		this.r2 = r2;
		this.status = 0;
	}
	public inline function other(r) {
		return (r1 == r) ? r2 : r1;
	}

	public function toString() {
		return "DOOR["+r1+","+r2+"]";
	}
}

class Room {
	public var level : Level;
	public var id : Int;
	public var x : Int;
	public var y : Int;
	public var w : Int;
	public var h : Int;
	public var x2(default,null) : Int;
	public var y2(default,null) : Int;
	public var doors : List<Door>;
	public var group : Group;
	public var dist : Int;
	public var tag : Int;
	public var tmp : Int;
	public var item : Null<{ x : Int, y : Int, k : DungeonItem, v : Int }>;

	public function new(level,id,x,y,w,h) {
		this.level = level;
		this.id = id;
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.x2 = x + w;
		this.y2 = y + h;
	}

	public function touch(r:Room) {
		return ((x == r.x2 + 1 || r.x == x2 + 1) && y < r.y2 && r.y < y2)
			|| ((y == r.y2+ 1 || r.y == y2 + 1) && x < r.x2 && r.x < x2);
	}

	public function over(r:Room,n:Int) {
		return x + n <= r.x2 && r.x + n <= x2 && y + n <= r.y2 && r.y + n <= y2;
	}

	public function addGroupRec(g:Group) {
		if( group == g ) return;
		if( group != null ) throw "assert";
		group = g;
		g.rooms.push(this);
		for( d in doors )
			d.other(this).addGroupRec(g);
	}

	public function toString() {
		return "{"+x+","+y+":"+w+"x"+h+":"+id+"}";
	}

}

class Level {

	public var id : Int;
	public var table : Table<Table<Bool>>;
	public var rooms : List<Room>;
	public var groups : List<Group>;

	public function new(id,w,h) {
		this.id = id;
		table = new Table(w,true);
		for( x in 0...w )
			table[x] = new Table(h,true);
		rooms = new List();
	}

	public function removeRoom(r) {
		if( !rooms.remove(r) )
			return false;
		for( x in r.x ... r.x2 )
			for( y in r.y ... r.y2 )
				table[x][y] = false;
		return true;
	}
}

class LevelInfos {

	// input
	public var width : Int;
	public var height : Int;
	public var nlevels : Int;
	public var roomsPerLevel : Int;
	public var roomMinSize : Int;
	public var roomMaxSize : Int;

	// noise
	public var noiseAmount : Float;
	public var noNoiseProba : Int;
	public var noiseProba : Int;
	public var filtersPasses : Int;

	// output
	public var seed : Int;
	public var levels : Array<Level>;
	public var start : { l : Int, x : Int, y : Int };
	public var exit : { l : Int, x : Int, y : Int };

	public function new(w,h,n) {
		width = w;
		height = h;
		nlevels = n;
		roomMinSize = 3;
		roomMaxSize = 10;
		roomsPerLevel = Math.ceil((w * h) / 30);
		noiseAmount = 0;
		noNoiseProba = 0;
		noiseProba = 0;
		filtersPasses = 0;
	}

}
