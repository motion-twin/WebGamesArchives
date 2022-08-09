package gen;
import gen.Data;
import DungeonCodec;

class Checker {

	var keys : Array<Bool>;
	var visitedRooms : Array<Room>;

	public function new() {
		keys = new Array();
	}

	function getRoom(inf:LevelInfos,pos) {
		for( r in inf.levels[pos.l].rooms )
			if( pos.x >= r.x && pos.y >= r.y && pos.x < r.x2 && pos.y < r.y2 )
				return r;
		throw "can't find start/exit";
		return null;
	}

	public function check( inf : LevelInfos ) {
		var r0 = getRoom(inf,inf.start);
		var rexit = getRoom(inf,inf.exit);
		while( true ) {
			for( l in inf.levels )
				for( r in l.rooms )
					r.tmp = 0;
			visitedRooms = new Array();
			loop(r0);
			if( rexit.tmp != 0 ) {
				for( l in inf.levels )
					for( r in l.rooms )
						if( r.tmp == 0 )
							return "Unreachable room";
				return null;
			}
			var locked = true;
			for( r in visitedRooms )
				if( r.item != null )
					switch( r.item.k ) {
					case IKey:
						if( !keys[r.item.v] ) {
							locked = false;
							keys[r.item.v] = true;
						}
					default:
					}
			if( locked )
				return "Unreachable exit";
		}
		return null;
	}

	function loop( r : Room ) {
		if( r.tmp != 0 )
			return;
		r.tmp = 1;
		visitedRooms.push(r);
		for( d in r.doors )
			if( d.status == 0 || keys[d.status] )
				loop(d.other(r));
	}

}