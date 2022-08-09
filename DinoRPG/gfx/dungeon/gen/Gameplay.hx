package gen;
import gen.Data;
import DungeonCodec;

class Branch {

	public var id : Int;
	public var start : Room;
	public var rooms : Table<Room>;
	public var subs : Array<Branch>;
	public var links : Table<Branch>;

	public function new(id,start) {
		this.id = id;
		this.start = start;
		this.rooms = new Table();
		this.subs = new Array();
		this.links = new Table();
	}

}

class Gameplay extends Generator {

	var reach : Table<Table<Int>>;
	var branchs : Table<Branch>;
	var visitedRooms : Table<Room>;
	var visitTag : Int;

	function distantPos( r : Room ) {
		for( x in r.x...r.x2 )
			for( y in r.y...r.y2 )
				reach[x][y] = 0xFFFFFF;
		for( d in r.doors )
			fillReach(r,d.x,d.y,0);
		var max = -1, mx = -1, my = -1;
		for( x in r.x...r.x2 )
			for( y in r.y...r.y2 ) {
				var r = reach[x][y];
				if( r > max && r != 0xFFFFFF ) {
					max = r;
					mx = x;
					my = y;
				}
			}
		if( max == -1 )
			throw "assert";
		return { x : mx, y : my };
	}

	function fillReach( r : Room, x, y, dist ) {
		var t = r.level.table[x][y];
		if( !t ) return;
		if( x < r.x - 1 || y < r.y - 1 || x > r.x2 || y > r.y2 )
			return;
		if( reach[x][y] < dist )
			return;
		reach[x][y] = dist;
		dist++;
		fillReach(r,x+1,y,dist);
		fillReach(r,x-1,y,dist);
		fillReach(r,x,y+1,dist);
		fillReach(r,x,y-1,dist);
	}

	public function gameplay( inf : LevelInfos ) {
		select(inf);
		this.reach = new Table(inf.width,true);
		for( x in 0...inf.width )
			reach[x] = new Table(inf.height,true);
		for( l in inf.levels )
			for( r in l.rooms ) {
				r.tag = -1;
				r.tmp = 0;
			}
		var l0 = 0;
		var r0 = inf.levels[l0].rooms.first();
		var p0 = distantPos(r0);
		inf.start = { l : l0, x : p0.x, y : p0.y };
		inf.exit = inf.start; // tmp

		branchs = new Table();
		buildBranches();

		r0.item = { x : inf.start.x, y : inf.start.y, k : null, v : -1 };

		// reach central branch
		visitedRooms = new Table();
		visitTag = 1;

		var b = branchs[r0.tag];
		var doorCount = 0;
		var scenarioCount = 0;
		while( true ) {
			// make sure that we visit some more branchs
			while( visitedRooms.length < 10 ) {
				visit(b);
				var b2 : Branch = null;
				for( l in b.links )
					if( l.id > b.id && (b2 == null || l.id > b2.id) )
						b2 = l;
				if( b2 == null )
					break;
				b = b2;
			}

			// choose the place we put the key
			doorCount++;
			var k = makeDeadEnd(doorCount * 2);
			var kpos = distantPos(k);
			k.item = { x : kpos.x, y : kpos.y, k : IKey, v : doorCount };

			// for each deadend reached, let's give a treasure
			// depending on its relative distance and visited rooms
			var dsum = 0;
			var heal = true;
			var scenario = r.random(3) == 0;
			for( r in visitedRooms )
				if( r.doors.length == 1 && r.item == null ) {
					if( scenario ) {
						var pos = distantPos(r);
						r.item = { x : pos.x, y : pos.y, k : IScenario, v : scenarioCount++ };
						scenario = false;
					} else if( heal ) {
						var pos = distantPos(r);
						r.item = { x : pos.x, y : pos.y, k : IHeal, v : 0 };
						heal = false;
					} else
						dsum += r.dist;
				}
			for( r in visitedRooms )
				if( r.doors.length == 1 && r.item == null ) {
					var pos = distantPos(r);
					var amount = Math.ceil((visitedRooms.length * 10 * r.dist) / dsum);
					r.item = { x : pos.x, y : pos.y, k : IGold, v : amount };
				}

			// reduce the visited rooms to the minimum
			while( reduceDoors() ) {
			}
			// make sure we don't have a door over a stair
			while( expandDoors() ) {
			}
			// lock doors
			var nexts = closeDoors(doorCount);

			// if we have no more rooms to explore, the it means the last
			// key is in fact the exit
			if( nexts.length == 0 ) {
				k.item = null;
				inf.exit = { l : k.level.id, x : kpos.x, y : kpos.y };
				break;
			}

			// update the distance map starting from the place we got key
			updateRoomsDist(k);

			// make sure that we visit some new branchs
			visitedRooms = new Table();
			visitTag++;
			for( r in nexts ) {
				var b2 = branchs[r.tag];
				visit(b2);
			}
			b = branchs[nexts[random(nexts.length)].tag];
		}
		// end
		r0.item = null;
	}

	function updateRoomsDist( r : Room ) {
		for( l in inf.levels )
			for( r in l.rooms )
				r.dist = 999999;
		calcRoomDist(r,0);
	}

	function calcRoomDist( r : Room, dist : Int ) {
		if( r.dist <= dist )
			return;
		r.dist = dist;
		dist++;
		for( d in r.doors )
			calcRoomDist(d.other(r),dist);
	}

	function visit(b:Branch) {
		for( r in b.rooms ) {
			if( r.tmp != 0 ) continue;
			r.tmp = visitTag;
			visitedRooms.push(r);
		}
	}

	function sortByRoomDist(r1:Room,r2:Room) {
		return r1.dist - r2.dist;
	}

	function makeDeadEnd(k) {
		// found deads end
		var dl = new Table();
		for( l in inf.levels )
			for( r in l.rooms )
				if( r.doors.length == 1 && r.item == null )
					dl.push(r);
		// takes the random(k) nearest dead end and visit all others
		dl.sort(sortByRoomDist);
		var len : Int = dl.length;
		var pos = random(k);
		if( pos >= len )
			pos = len - 1;
		for( i in 0...pos )
			visitRec(dl[i]);
		var found = if( dl.length == 0 ) null else dl[pos];
		// this can happen if there is no deadend left
		// in that case, let's take the most far not visited room
		if( found == null ) {
			var dmin = -1;
			for( r in visitedRooms )
				r.tmp = 0;
			for( l in inf.levels )
				for( r in l.rooms )
					if( r.dist > dmin && r.tmp == 0 && r.item == null ) {
						found = r;
						dmin = r.dist;
					}
			for( r in visitedRooms )
				r.tmp = visitTag;
		}
		visitRec(found);
		return found;
	}

	function visitRec( r : Room ) {
		// make sure that we visit the corresponding branches
		while( true ) {
			var b = branchs[r.tag];
			visit(b);
			var next = null;
			for( d in r.doors ) {
				var r2 = d.other(r);
				if( r2.dist < r.dist ) {
					next = r2;
					break;
				}
			}
			if( next == null )
				break;
			r = next;
		}
	}

	function reduceDoors() {
		// we want to avoid unecessary doors
		for( r in visitedRooms ) {
			// if we are far, it's ok to reduce visited surface
			// if not, we only reduce if we can at least reduce 1 door
			var min = if( r.dist >= 5 ) 1 else 2;
			if( r.item != null || r.doors.length <= min || r.tmp == 0 ) continue;
			var count = 0;
			for( d in r.doors ) {
				var r2 = d.other(r);
				if( r2.tmp == 0 )
					count++;
			}
			if( count == r.doors.length - 1 ) {
				r.tmp = 0;
				visitedRooms.splice(visitedRooms.indexOf(r),1);
				return true;
			}
		}
		return false;
	}

	function expandDoors() {
		var found = false;
		// we can't simply stop visit on a stair...
		for( r in visitedRooms )
			for( d in r.doors ) {
				var r2 = d.other(r);
				if( r2.tmp == 0 && r.level != r2.level ) {
					r2.tmp = visitTag;
					visitedRooms.push(r2);
					found = true;
				}
			}
		return found;
	}

	function closeDoors( id ) {
		// closed doors are the one between a visited room and a non-visited one
		// if there's already one lock on the door, overwrite it since we were not
		// yet able to access the room accross the door
		var nexts = new Table();
		for( l in inf.levels )
			for( r in l.rooms ) {
				if( r.tmp == 0 )
					continue;
				for( d in r.doors ) {
					var r2 = d.other(r);
					if( r2.tmp == 0 ) {
						d.status = id;
						nexts.push(r2);
					}
				}
			}
		return nexts;
	}

	function buildBranches() {
		// build branches starting from each deadend
		for( l in inf.levels )
			for( r in l.rooms )
				if( r.tag < 0 && r.doors.length == 1 ) {
					var b = new Branch(branchs.length,r);
					branchs.push(b);
					buildBranch(r,b);
				}
		var found = true;
		while( found ) {
			found = false;
			// build metabranches (can group several branches together)
			for( l in inf.levels )
				for( r in l.rooms )
					if( r.tag < 0 ) {
						var n = 0;
						for( d in r.doors ) {
							var r2 = d.other(r);
							if( r2.tag < 0 )
								n++;
						}
						if( n <= 1 ) {
							var b = new Branch(branchs.length,r);
							found = true;
							branchs.push(b);
							for( d in r.doors ) {
								var r2 = d.other(r);
								if( r2.tag >= 0 ) {
									var bsub = branchs[r2.tag];
									b.subs.remove(bsub);
									b.subs.push(bsub);
								}
							}
							buildBranch(r,b);
						}
					}
			if( found )
				continue;
			// break cycles branches
			for( l in inf.levels ) {
				for( r in l.rooms )
					if( r.tag < 0 ) {
						// is there a cycle end at this point ?
						var count = 0;
						for( d in r.doors ) {
							var r2 = d.other(r);
							if( r2.dist <= r.dist )
								count++;
						}
						if( count > 1 ) {
							var b = new Branch(branchs.length,r);
							found = true;
							branchs.push(b);
							buildBranchConnect(r,b);
							break;
						}
					}
				if( found )
					break;
			}
		}
		// build branch links
		for( b in branchs )
			for( b2 in b.subs ) {
				b.links.push(b2);
				b2.links.push(b);
			}
	}

	function buildBranch( r : Room, b : Branch ) {
		b.rooms.push(r);
		r.tag = b.id;
		for( d in r.doors ) {
			var r2 = d.other(r);
			if( r2.tag < 0 && r2.doors.length <= 2 )
				buildBranch(r2,b);
		}
	}

	function buildBranchConnect( r : Room, b : Branch ) {
		b.rooms.push(r);
		r.tag = b.id;
		for( d in r.doors ) {
			var r2 = d.other(r);
			if( r2.tag < 0 ) {
				if( r2.doors.length <= 2 )
					buildBranchConnect(r2,b);
			} else {
				var b2 = branchs[r2.tag];
				if( b2 != b ) {
					b.subs.remove(b2);
					b.subs.push(b2);
				}
			}
		}
	}

}
