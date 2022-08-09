package gen;
import gen.Data;

class Rooms extends Generator {

	var surface : Float;

	public function new( surface ) {
		super();
		this.surface = surface;
	}

	public function tryGenerate(inf:LevelInfos,n) {
		var reason = null;
		for( i in 0...n ) {
			inf.seed = Std.random(0x1000000);
			select(inf);
			reason = genLevels();
			if( reason == null )
				break;
		}
		return reason;
	}

	function genLevels() {
		var levels = new Array();
		inf.levels = levels;
		// generate levels
		for( i in 0...inf.nlevels ) {
			var l = vtry(genLevel);
			l.id = levels.length;
			levels.push(l);
		}
		// use biggest group as a start
		var l0 = levels[0];
		var g = Lambda.array(l0.groups);
		g.sort(function(g1,g2) return g2.rooms.length - g1.rooms.length);
		l0.groups = Lambda.list(g);
		// walk the level and calculate room-distance
		var r0 = l0.groups.first().rooms[0];
		var deadEnds = new Table();
		walkLevel(r0,1,deadEnds);
		while( deadEnds.length > 0 )
			makeLevelDoor(deadEnds);
		// cleanup unreachable rooms
		var rid = 0;
		for( l in levels ) {
			for( g in l.groups ) {
				if( g.rooms[0].dist == 0 ) {
					l.groups.remove(g);
					for( r in g.rooms )
						l.removeRoom(r);
				}
			}
			for( r in l.rooms )
				r.id = rid++;
		}
		// check surface
		var surf = 0;
		for( l in levels ) {
			if( l.rooms.isEmpty() )
				return "empty";
			for( r in l.rooms ) {
				initRoomDoors(r);
				surf += r.w * r.h;
			}
		}
		var surf = surf / (inf.width * inf.height);
		if( surf < Math.pow(inf.nlevels,0.7) * surface )
			return "surface "+Std.int(surf*100)+"%";
		// assign up/down doors
		for( l in levels )
			for( r in l.rooms )
				for( d in r.doors )
					if( d.x == 0 && !initLevelDoor(d) )
						return "door";
		return null;
	}

	function initLevelDoor( d : Door ) {
		var r1 = d.r1;
		var r2 = d.r2;
		var x1 = if( r1.x < r2.x ) r2.x else r1.x;
		var x2 = if( r1.x2 < r2.x2 ) r1.x2 else r2.x2;
		var y1 = if( r1.y < r2.y ) r2.y else r1.y;
		var y2 = if( r1.y2 < r2.y2 ) r1.y2 else r2.y2;
		x2--;
		y2--;
		var pos = [1,2,3,4];
		for( i in 0...50 ) {
			var p : Int = 0;
			if( pos.length > 0 ) {
				var x = random(pos.length);
				p = pos[x];
				pos.slice(x,1);
			}
			switch( p ) {
			case 0:
				d.x = rand(x1,x2);
				d.y = rand(y1,y2);
			case 1:
				d.x = x1;
				d.y = y1;
			case 2:
				d.x = x2;
				d.y = y1;
			case 3:
				d.x = x1;
				d.y = y2;
			case 4:
				d.x = x2;
				d.y = y2;
			}
			if( checkLevelDoor(d) )
				return true;
		}
		return false;
	}

	function checkLevelDoor( d : Door ) {
		for( d2 in d.r1.doors ) {
			if( d2 == d )
				continue;
			var dx = d2.x - d.x;
			var dy = d2.y - d.y;
			if( dx*dx + dy*dy <= 2 )
				return false;
		}
		for( d2 in d.r2.doors ) {
			if( d2 == d )
				continue;
			var dx = d2.x - d.x;
			var dy = d2.y - d.y;
			if( dx*dx + dy*dy <= 2 )
				return false;
		}
		return true;
	}

	function initRoomDoors( r1 : Room ) {
		for( d in r1.doors ) {
			var r2 = d.other(r1);
			if( r2.level != r1.level ) {
				continue;
			} else if( r2.x2 < r1.x ) {
				d.x = r1.x - 1;
				var y1 = if( r1.y < r2.y ) r2.y else r1.y;
				var y2 = if( r1.y2 < r2.y2 ) r1.y2 else r2.y2;
				d.y = rand(y1,y2-1);
				r1.level.table[d.x][d.y] = true;
			} else if( r2.y2 < r1.y ) {
				d.y = r1.y - 1;
				var x1 = if( r1.x < r2.x ) r2.x else r1.x;
				var x2 = if( r1.x2 < r2.x2 ) r1.x2 else r2.x2;
				d.x = rand(x1,x2-1);
				r1.level.table[d.x][d.y] = true;
			}
		}
	}

	function cleanDoors( g : Group, r : Room, prev : Room ) {
		r.group = g;
		for( d in r.doors ) {
			var r2 = d.other(r);
			if( r2 == prev )
				continue;
			// already visited ?
			if( r2.group == g ) {
				if( proba(2) ) {
					r.doors.remove(d);
					r2.doors.remove(d);
				}
			} else
				cleanDoors(g,r2,r);
		}
	}

	function genLevel() {
		var l = new Level(0,inf.width,inf.height);
		ntry(callback(generateRoom,l),inf.roomsPerLevel);
		l.groups = buildRoomGroups(l);
		for( r in l.rooms )
			r.group = null;
		for( g in l.groups )
			cleanDoors(g,g.rooms[random(g.rooms.length)],null);
		return l;
	}

	function buildRoomGroups( l : Level ) {
		for( r in l.rooms )
			r.doors = new List();
		for( r1 in l.rooms ) {
			for( r2 in l.rooms )
				if( r2.id > r1.id && r1.touch(r2) ) {
					var d = new Door(r1,r2);
					r1.doors.push(d);
					r2.doors.push(d);
				}
		}
		var groups = new List();
		for( r in l.rooms )
			if( r.group == null ) {
				var g = new Group(groups.length);
				r.addGroupRec(g);
				groups.push(g);
			}
		return groups;
	}

	function generateRoom(l:Level) {
		var w = rand(inf.roomMinSize,inf.roomMaxSize);
		var h = rand(inf.roomMinSize,inf.roomMaxSize);
		var x = rand(1,inf.width - (w + 1));
		var y = rand(1,inf.height - (h + 1));
		for( px in x-1...x+w+1 )
			for( py in y-1...y+h+1 )
				if( l.table[px][py] )
					return false;
		for( px in x...x+w )
			for( py in y...y+h )
				l.table[px][py] = true;
		l.rooms.push(new Room(l,l.rooms.length,x,y,w,h));
		return true;
	}

	function walkLevel( r : Room, dist : Int, deadEnds : Table<Room> ) {
		// don't loop unless we can reduce distance
		if( r.dist != 0 && dist >= r.dist )
			return false;
		var walk = (r.dist != 0);
		r.dist = dist;
		for( d in r.doors ) {
			var r2 = d.other(r);
			if( walkLevel(r2,dist + 1,deadEnds) )
				walk = true;
		}
		// dead-end
		if( !walk )
			deadEnds.push(r);
		return true;
	}

	function makeLevelDoor( deadEnds : Table<Room> ) {
		deadEnds.sort(function(r1,r2) return r2.dist - r1.dist);
		var r = deadEnds.shift(); // most distant one
		for( n in [1,-1] ) {
			var l2 = inf.levels[r.level.id + n];
			if( l2 == null ) continue;
			for( r2 in l2.rooms )
				if( r2.dist == 0 && r2.over(r,2) ) {
					var d = new Door(r,r2);
					r2.doors.push(d);
					r.doors.push(d);
					walkLevel(r2,r.dist+1,deadEnds);
					return;
				}
			}
	}

}
