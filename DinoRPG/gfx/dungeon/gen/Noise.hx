package gen;
import gen.Data;

class Noise extends Generator {

	var reach : Table<Table<Bool>>;

	public function noise( inf : LevelInfos ) {
		select(inf);
		this.reach = new Table(inf.width,true);
		for( x in 0...inf.width )
			reach[x] = new Table(inf.height,true);
		for( l in inf.levels )
			for( r in l.rooms ) {
				noiseRoom(r);
				for( i in 0...inf.filtersPasses )
					if( !noiseFilter(r) )
						break;
			}
	}

	function noiseRoom( r : Room ) {
		var noise = Math.ceil(r.w*r.h*inf.noiseAmount);
		if( noise <= 0 || (inf.noNoiseProba > 0 && proba(inf.noNoiseProba)) || !proba(inf.noiseProba) )
			return;
		// hide doors
		var t = r.level.table;
		var d0 = null;
		for( d in r.doors ) {
			t[d.x][d.y] = false;
			if( d.other(r).level == r.level )
				d0 = d;
		}
		// if we don't have a side door, start from a level door
		if( d0 == null ) {
			d0 = r.doors.first();
			t[d0.x][d0.y] = true;
		}
		// select start point
		var sx = d0.x, sy = d0.y;
		if( sx < r.x )
			sx++;
		else if( sy < r.y )
			sy++;
		else if( sx == r.x2 )
			sx--;
		else if( sy == r.y2 )
			sy--;
		// if our room is a dead-end, make sure one other point the room is kept visible
		var cx = sx, cy = sy;
		if( r.doors.length == 1 ) {
			do {
				cx = rand(r.x,r.x2-1);
				cy = rand(r.y,r.y2-1);
			} while( cx == sx && cy == sy );
		}
		// add random noise while doors are reachable
		for( i in 0...noise ) {
			var x = r.x + random(r.w);
			var y = r.y + random(r.h);
			if( !t[x][y] )
				continue;
			if( x == cx && y == cy )
				continue;
			// don't make holes
			if( t[x-1][y] && t[x+1][y] && t[x][y-1] && t[x][y+1] )
				continue;
			t[x][y] = false;
			for( px in r.x-1...r.x2+1 )
				for( py in r.y-1...r.y2+1 )
					reach[px][py] = false;
			buildReach(t,sx,sy);
			var ok = reach[cx][cy];
			if( ok ) {
				for( d in r.doors )
					if( !reach[d.x][d.y] ) {
						ok = false;
						break;
					}
			}
			if( !ok )
				t[x][y] = true;
		}
		// eliminate unreachable places
		for( px in r.x-1...r.x2+1 )
			for( py in r.y-1...r.y2+1 )
				reach[px][py] = false;
		buildReach(t,sx,sy);
		for( x in r.x...r.x2 )
			for( y in r.y...r.y2 )
				if( !reach[x][y] )
					t[x][y] = false;
		// show doors
		for( d in r.doors )
			t[d.x][d.y] = true;
	}

	function noiseFilter( r : Room ) {
		var t = r.level.table;
		for( x in r.x ... r.x2 )
			for( y in r.y ... r.y2 )
				if( t[x][y] ) {
					var sum = (t[x-1][y]?1:0) + (t[x+1][y]?1:0) + (t[x][y-1]?1:0) + (t[x][y+1]?1:0);
					reach[x][y] = (sum == 1);
				} else
					reach[x][y] = false;
		for( d in r.doors ) {
			reach[d.x][d.y] = false;
			reach[d.x-1][d.y] = false;
			reach[d.x+1][d.y] = false;
			reach[d.x][d.y-1] = false;
			reach[d.x][d.y+1] = false;
		}
		var ok = false;
		for( x in r.x ... r.x2 )
			for( y in r.y ... r.y2 )
				if( reach[x][y] ) {
					t[x][y] = false;
					ok = true;
				}
		return ok;
	}

	function buildReach( t : Table<Table<Bool>>, x, y ) {
		if( reach[x][y] )
			return;
		reach[x][y] = true;
		if( !t[x][y] )
			return;
		buildReach(t,x-1,y);
		buildReach(t,x,y-1);
		buildReach(t,x+1,y);
		buildReach(t,x,y+1);
	}

}