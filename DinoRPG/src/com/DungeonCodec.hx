enum DungeonItem {
	IKey;
	IGold;
	IHeal;
	IScenario;
}

typedef DungeonRoom = {
	var id : Int;
	var x : Int;
	var y : Int;
	var w : Int;
	var h : Int;
	var doors : Array<{ x : Int, y : Int, up : Null<Bool>, key : Null<Int> }>;
	var item : Null<{ x : Int, y : Int, k : DungeonItem, v : Int }>;
}

typedef DungeonLevel = {
	var table : Table<Table<Bool>>;
	var rooms : Array<DungeonRoom>;
}

typedef DungeonStruct = {
	var width : Int;
	var height : Int;
	var levels : Array<DungeonLevel>;
	var start : { x : Int, y : Int, l : Int };
	var exit : { x : Int, y : Int, l : Int };
}

private typedef Table<T> = #if flash10 flash.Vector<T> #else Array<T> #end;

class DungeonCodec {

	public var d : DungeonStruct;
	var bc : mt.BitCodec;

	public function new() {
	}

	function saveBits(b:mt.BitCodec,nbits,k) {
		if( k < 4 ) {
			b.write(1,0);
			b.write(2,k);
		} else if( k <= 8 ) {
			b.write(2,2);
			b.write(3,k-1);
		} else {
			b.write(2,3);
			b.write(nbits,k-1);
		}
	}

	function encodeTable( t : Table<Table<Bool>>, px : Int, py : Int, w : Int, h : Int ) {
		var nbits = nbits(w * h - 1);
		var c = false;
		var k = 0;
		for( x in 0...w )
			for( y in 0...h )
				if( t[px+x][py+y] == c )
					k++;
				else {
					saveBits(bc,nbits,k);
					k = 1;
					c = !c;
				}
		saveBits(bc,nbits,k);
	}

	function nbits(v) {
		var nbits = 1;
		while( v >= (1 << nbits) )
			nbits++;
		return nbits;
	}

	function decodeTable(t:Table<Table<Bool>>,px,py,w,h) {
		var nbits = nbits(w * h - 1);
		var x = px, y = py, c = false;
		w += px;
		h += py;
		while( x < w ) {
			var k;
			if( bc.read(1) == 0 )
				k = bc.read(2);
			else if( bc.read(1) == 0 )
				k = bc.read(3) + 1;
			else
				k = bc.read(nbits) + 1;
			while( k > 0 ) {
				t[x][y] = c;
				k--;
				y++;
				if( y == h ) {
					y = py;
					x++;
				}
			}
			c = !c;
		}
	}

	public function encode() : String {
		bc = new mt.BitCodec(null,true);
		bc.write(8,d.width);
		bc.write(8,d.height);
		var nrooms = 0, nmonsters = 0, nscenarios = 0, nkeys = 0;
		for( l in d.levels )
			nrooms += l.rooms.length;
		bc.write(8,d.levels.length);
		var rbits = nbits(nrooms);
		bc.write(5,rbits);
		var xybits = nbits((d.width > d.height) ? d.width : d.height);
		var whbits = xybits - 1;
		for( l in d.levels ) {
			bc.write(rbits,l.rooms.length);
			for( r in l.rooms ) {
				bc.write(xybits,r.x);
				bc.write(xybits,r.y);
				bc.write(whbits,r.w);
				bc.write(whbits,r.h);
				encodeTable(l.table,r.x,r.y,r.w,r.h);
				bc.write(5,r.doors.length);
				for( d in r.doors ) {
					bc.write(xybits,d.x);
					bc.write(xybits,d.y);
					bc.write(2,(d.up == null)?((d.key == null)?2:3):(d.up?1:0));
					if( d.key != null )
						bc.write(6,d.key);
					else if( d.up == null )
						nmonsters++;
				}
				if( r.item != null ) {
					bc.write(1,1);
					bc.write(xybits,r.item.x);
					bc.write(xybits,r.item.y);
					bc.write(4,Type.enumIndex(cast r.item.k));
					bc.write(8,r.item.v);
					switch( r.item.k ) {
					case IKey: nkeys++;
					case IScenario: nscenarios++;
					default:
					}
				} else
					bc.write(1,0);
			}
		}
		bc.write(xybits,d.start.x);
		bc.write(xybits,d.start.y);
		bc.write(8,d.start.l);
		bc.write(xybits,d.exit.x);
		bc.write(xybits,d.exit.y);
		bc.write(8,d.exit.l);
		var sign = d.width+"x"+d.height+"x"+d.levels.length+" "+nrooms+"R "+nmonsters+"M "+nscenarios+"S "+nkeys+"K";
		return "[["+sign+"]]" + bc.toString() + bc.crcStr();
	}

	public function removeSignature( s : String ) {
		if( s.substr(0,2) == "[[" )
			s = s.substr(s.indexOf("]]") + 2);
		return s;
	}

	public function decode( s : String ) {
		s = removeSignature(s);
		bc = new mt.BitCodec(s,true);
		var width = bc.read(8);
		var height = bc.read(8);
		var nlevels = bc.read(8);
		var rbits = bc.read(5);
		var xybits = nbits((width > height) ? width : height);
		var whbits = xybits - 1;
		var levels = new Array();
		d = {
			width : width,
			height : height,
			levels : levels,
			start : { x : 0, y : 0, l : 0 },
			exit : { x : 0, y : 0, l : 0 },
		};
		var ikind = Lambda.array(Lambda.map(
			Type.getEnumConstructs(DungeonItem),
			function(k) return Type.createEnum(DungeonItem,k)
		));
		var rid = 0;
		for( i in 0...nlevels ) {
			var t = new Table();
			for( x in 0...width )
				t[x] = new Table(#if flash9 height #end);
			var rooms = new Array();
			for( i in 0...bc.read(rbits) ) {
				var x = bc.read(xybits);
				var y = bc.read(xybits);
				var w = bc.read(whbits);
				var h = bc.read(whbits);
				var doors = new Array();
				var item = null;
				decodeTable(t,x,y,w,h);
				for( i in 0...bc.read(5) ) {
					var up : Null<Bool>, key : Null<Int> = null;
					var x = bc.read(xybits);
					var y = bc.read(xybits);
					switch( bc.read(2) ) {
					case 0: up = false;
					case 1: up = true;
					case 2: up = null;
					default: up = null; key = bc.read(6);
					};
					doors.push({ x : x, y : y, up : up, key : key });
					t[x][y] = true;
				}
				if( bc.read(1) == 1 ) {
					var x = bc.read(xybits);
					var y = bc.read(xybits);
					var k = ikind[bc.read(4)];
					var v = bc.read(8);
					item = { x : x, y : y, k : k, v : v };
				}
				rooms.push({ id : rid++, x : x, y : y, w : w, h : h, doors : doors, item : item });
			}
			levels.push({ table : t, rooms : rooms });
		}
		d.start.x = bc.read(xybits);
		d.start.y = bc.read(xybits);
		d.start.l = bc.read(8);
		d.exit.x = bc.read(xybits);
		d.exit.y = bc.read(xybits);
		d.exit.l = bc.read(8);
		return bc.crcStr() == s.substr(s.length-4,4);
	}

}
