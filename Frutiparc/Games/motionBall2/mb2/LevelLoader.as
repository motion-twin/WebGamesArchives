import mb2.Const;
import mb2.Manager;

class mb2.LevelLoader {

	var width, height;
	var start_x, start_y;
	var dungeon;

	var bc;
	var decode_x, decode_y;

	function LevelLoader(data) {
		bc = new ext.util.MTBitcodec(data);
		width = bc.read(7);
		height = bc.read(7);
		start_x = bc.read(7);
		start_y = bc.read(7);

		var x,y;
		dungeon = new Array();
		for(x=0;x<width;x++) {
			dungeon[x] = new Array();
			for(y=0;y<height;y++)
				dungeon[x][y] = decode_room();
		}

		bc.next_part();
		decode_x = 0;
		decode_y = 0;

		if( bc.has_error() )
			Manager.error();
	}

	function decodeRoom(x,y) {
		var n = 0;
		while( decode_x < x || (decode_x == x && decode_y <= y) ) {
			n++;
			decode_incr();
		}		
	}

	function decode_incr() {
		dungeon[decode_x][decode_y].bdata = decode_room_bumpers();
		decode_y++;
		if( decode_y == height ) {
			decode_y = 0;
			decode_x++;
		}
	}

	function decode_path() {
		var p = new Object();
		p.ptype = bc.read(2);
		if( p.ptype == 3 ) // OBJECT
			p.pdata = bc.read(2);
		return p;
	}

	function decode_room() {
		var r = new Object();
		r.rtype = bc.read(3);
		switch( r.rtype ) {
		case 3: // OBJECTFOUND
		case 5: // OBJECTNEEDED
			r.rdata = bc.read(2);
			break;
		case 4: // BONUS
			r.rdata = bc.read(3);
			break;
		}
		if( r.rtype != 0 ) {
			r.paths = new Array(4);
			var d;
			for(d=0;d<4;d++)
				r.paths[d] = decode_path();
		}
		return r;
	}

	function decode_room_bumpers() {
		if( bc.read(1) == 0 )
			return null;
		var blist = new Array();
		while(true) {
			if( bc.has_error() )
				return null;
			var r = bc.read(4);
			if( r == 0 )
				break;
			var o = new Object();
			o.x = bc.read(Const.POS_NBITS);
			o.y = bc.read(Const.POS_NBITS);
			o.btype = r;
			blist.push(o);
		}
		return blist;
	}

}