package db;
import mt.db.Types;

typedef Combo = {
	var x : Int;
	var y : Int;
	var h : Bool;
	var count : Int;
	var v : Int;
}

class Puzzle extends neko.db.Object {

	public static inline var MAX_ACTIONS = 100;
	public static inline var ACTION_MINUTES = 30;

	static inline var SIZE = 8;
	static var PRIVATE_FIELDS = ["t"];
	static function RELATIONS() {
		return [{ prop : "city", key : "id", manager : City.manager }];
	}
	public static var manager = new PuzzleManager(Puzzle);

	var id : SInt;

	public var city(dynamic,dynamic) : db.City;
	public var swaps : SInt;
	public var turns : SInt;
	public var data : SBinary;
	public var lastUpdate : SDateTime;
	public var actions : SInt;
	public var lostActions : SInt;

	public var t : Array<Array<Int>>;

	public function new( c : db.City ) {
		super();
		city = c;
		turns = swaps = 0;
		lastUpdate = Date.now();
		actions = MAX_ACTIONS;
		fullReset();
	}

	public function getActionTime() {
		return DateTools.minutes(Std.int(ACTION_MINUTES/city.map.getSpeed()));
	}

	public function updateActions() {
		actions += Rules.updateTime(this,Std.int(getActionTime()/DateTools.minutes(1)),0);
		if( actions > MAX_ACTIONS ) {
			lostActions += actions - MAX_ACTIONS;
			actions = MAX_ACTIONS;
		}
	}

	// -------------- PUZZLE LOGIC -------------------

	function fill( px : Int, py : Int ) {
		var prob = Rules.getPuzzleProbas(city,t);
		var me = this;
		var checkAlign = function(dx,dy) {
			var p1 = me.t[px + dx][py + dy];
			var p2 = me.t[px + dx*2][py + dy*2];
			if( p1 == p2 && p1 != null ) prob[p1] = 0;
		};
		if( px > 1 ) checkAlign(-1,0);
		if( py > 1 ) checkAlign(0,-1);
		if( px < 6 ) checkAlign(1,0);
		if( py < 6 ) checkAlign(0,1);
		var tot = 0;
		for( p in prob )
			tot += p;
		var k = Std.random(tot);
		for( i in 0...prob.length ) {
			k -= prob[i];
			if( k < 0 ) {
				t[px][py] = i;
				return i;
			}
		}
		throw "assert";
	}

	public function swap( s, x, y, h ) {
		if( s != swaps || actions <= 0 )
			return false;
		var dx = h ? 1 : 0;
		var dy = h ? 0 : 1;
		var tmp = t[x][y];
		t[x][y] = t[x+dx][y+dy];
		t[x+dx][y+dy] = tmp;
		swaps++;
		turns++;
		actions--;
		return true;
	}

	function addVCombo( combos : List<Combo>, c : Combo ) {
		for( c2 in combos ) {
			if( !c2.h ) break;
			// if combo intersects
			if( c.x >= c2.x && c.x < c2.x + c2.count && c.y <= c2.y && c.y + c.count > c2.y ) {
				if( c.count <= c2.count ) return;
				combos.remove(c2);
			}
		}
		combos.add(c);
	}

	public function explode() {
		var t = this.t;
		var combos = new List();
		// horizontal check
		for( y in 0...SIZE ) {
			var count = 0;
			var cur = null;
			for( x in 0...SIZE ) {
				var v = t[x][y];
				if( v == cur ) {
					count++;
					continue;
				}
				if( count >= 3 )
					combos.add({ h : true, x : x - count, y : y, count : count, v : cur });
				count = 1;
				cur = v;
			}
			if( count >= 3 )
				combos.add({ h : true, x : SIZE - count, y : y, count : count, v : cur });
		}
		// vertical check
		for( x in 0...SIZE ) {
			var count = 0;
			var cur = null;
			for( y in 0...SIZE ) {
				var v = t[x][y];
				if( v == cur ) {
					count++;
					continue;
				}
				if( count >= 3 )
					addVCombo(combos,{ h : false, x : x, y : y - count, count : count, v : cur });
				count = 1;
				cur = v;
			}
			if( count >= 3 )
				addVCombo(combos,{ h : false, x : x, y : SIZE - count, count : count, v : cur });
		}
		// destroy
		for( c in combos )
			for( i in 0...c.count )
				t[c.x + (c.h?i:0)][c.y + (c.h?0:i)] = null;
		return combos;
	}

	public function gravity() {
		for( x in 0...SIZE ) {
			var dy = 0;
			var y = SIZE - 1;
			var tx = t[x];
			while( y >= 0 ) {
				var v = tx[y];
				if( v == null )
					dy++;
				else if( dy > 0 ) {
					tx[y] = null;
					tx[y+dy] = v;
				}
				y--;
			}
		}
	}

	public function refill() {
		var fl = new Array();
		for( x in 0...SIZE )
			for( y in 0...SIZE )
				if( t[x][y] == null )
					fl.push(fill(x,y));
		return fl;
	}

	function same(x,y,k) {
		var tx = t[x];
		return if( tx == null ) false else tx[y] == k;
	}

	function checkSwapH(x,y,d) {
		var ak = t[x][y];
		var a1 = same(x+d,y-1,ak);
		var a2 = same(x+d,y+1,ak);
		return ( a1 && a2 )
		|| (a1 && same(x+d,y-2,ak))
		|| (a2 && same(x+d,y+2,ak))
		|| (same(x+d*2,y,ak) && same(x+d*3,y,ak));
	}

	function checkSwapV(x,y,d) {
		var ak = t[x][y];
		var a1 = same(x-1,y+d,ak);
		var a2 = same(x+1,y+d,ak);
		return ( a1 && a2 )
		|| (a1 && same(x-2,y+d,ak))
		|| (a2 && same(x+2,y+d,ak))
		|| (same(x,y+d*2,ak) && same(x,y+d*3,ak));
	}

	public function swapPossible() {
		for( x in 0...SIZE )
			for( y in 0...SIZE )
				if( checkSwapH(x,y,1) || checkSwapH(x,y,-1) || checkSwapV(x,y,1) || checkSwapV(x,y,-1) )
					return true;
		return false;
	}

	public function fullReset() {
		var r = new Array();
		t = new Array();
		for( x in 0...SIZE )
			t.push([]);
		for( x in 0...SIZE )
			for( y in 0...SIZE )
				r.push(fill(x,y));
		return r;
	}

}

class PuzzleManager extends neko.db.Manager<Puzzle> {

	override function make( c : Puzzle ) {
		c.t = neko.Lib.localUnserialize(neko.Lib.bytesReference(c.data));
	}

	override function unmake( c : Puzzle ) {
		c.data = neko.Lib.stringReference(neko.Lib.serialize(c.t));
	}

}
