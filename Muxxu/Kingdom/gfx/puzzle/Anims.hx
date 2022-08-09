import Level;

private typedef MC = flash.MovieClip;

class SwapAnim {

	var s : { x : Int, y : Int, horiz : Bool };
	var p1 : Piece;
	var p2 : Piece;
	var t : Float;

	public function new() {
		var p = Puzzle.inst;
		var s = p.select;
		this.s = { x : s.x, y : s.y, horiz : s.horiz };
		p1 = p.level.tbl[s.x][s.y];
		p2 = p.level.tbl[s.x+(s.horiz?1:0)][s.y+(s.horiz?0:1)];
		t = 0;
	}

	public function update() {
		var end = false;
		t += mt.Timer.tmod / 10.0;
		var dx = s.horiz ? 1 : 0;
		var dy = s.horiz ? 0 : 1;
		var d = Math.pow(t * 20,1.5);
		if( d > Piece.SIZE ) {
			end = true;
			d = Piece.SIZE;
		}
		p1.animate(d * dx, d * dy);
		p2.animate(-d * dx, -d * dy);
		if( end ) {
			var p = Puzzle.inst;
			p.level.swap(s.x,s.y,s.horiz);
			p.explode();
		}
		return !end;
	}

}

class FadeAnim {

	var mc : MC;

	public function new(mc) {
		this.mc = mc;
	}
	public function update() {
		mc._alpha -= 15 * mt.Timer.tmod;
		if( mc._alpha <= 0 ) {
			mc.removeMovieClip();
			return false;
		}
		return true;
	}

}

class DestroyAnim {

	var t : Float;
	var combos : List<Array<Piece>>;
	var counts : Array<Int>;

	public function new(combos,counts) {
		t = 0;
		this.combos = combos;
		this.counts = counts;
		Puzzle.inst.level.destroy(combos);
	}

	public function update() {
		t += mt.Timer.tmod;
		var k = (1 + (t / 5)) * 100;
		var ct = {};
		Reflect.setField(ct,"ra",k);
		Reflect.setField(ct,"ga",k);
		Reflect.setField(ct,"ba",k);
		for( c in combos )
			for( p in c ) {
				p.animate(Std.random(5)-2,Std.random(5)-2);
				p.mc._rotation = Std.random(10) - 5;
				p.mc.filters = [new flash.filters.GlowFilter(0xFFFFFF,1,t,t,10)];
				new flash.Color(p.mc).setTransform(ct);
			}
		if( t < 5 )
			return true;
		t -= 5;
		if( combos.length == 0 ) {
			Puzzle.inst.gravity();
			return false;
		}
		var c = combos.pop();
		for( p in c )
			Puzzle.inst.anims.add(new FadeAnim(p.mc));
		var mc : {> MC, smc : {> MC, icon : MC, value : flash.TextField } }= cast Puzzle.inst.dm.attach("pop",3);
		var h0 = c[(c.length - 1)>> 1].mc;
		var h1 = c[c.length >> 1].mc;
		mc._x = (h0._x + h1._x) / 2;
		mc._y = (h0._y + h1._y) / 2;
		mc.smc.icon.gotoAndStop(Type.enumIndex(c[0].k) + 1);
		mc.smc.value.text = Std.string(counts.shift());
		var b = mc.getBounds(flash.Lib.current);
		if( b.xMin < 0 )
			mc._x += -b.xMin;
		if( b.xMax > 288 )
			mc._x -= (b.xMax - 288);
		return true;
	}

}

class GravityAnim {

	var t : Float;

	public function new() {
		t = 0;
	}

	public function update() {
		var tbl = Puzzle.inst.level.tbl;
		var fall = false;
		t += t / 10 + mt.Timer.tmod * 2;
		for( x in 0...Level.SIZE )
			for( y in 0...Level.SIZE ) {
				var p : Piece = tbl[x][y];
				if( p == null || p.fall == 0 ) continue;
				fall = true;
				var dy = t - Piece.SIZE * p.fall;
				if( dy >= 0 ) {
					dy = 0;
					p.fall = 0;
				}
				p.animate(0,Std.int(dy));
			}
		if( !fall ) {
			Puzzle.inst.refill();
			return false;
		}
		return true;
	}

}

class GrowAnim {

	var mc : MC;

	public function new(mc) {
		this.mc = mc;
	}

	public function update() {
		var s = mc._xscale + 10 * mt.Timer.tmod;
		if( s > 100 ) s = 100;
		mc._xscale = mc._yscale = s;
		return s < 100;
	}

}

class RefillAnim {

	var pieces : Array<Int>;
	var t : Float;

	public function new(pieces) {
		this.pieces = pieces;
		t = 0;
	}

	public function update() {
		var p = Puzzle.inst;
		t += mt.Timer.tmod;
		if( pieces.length == 0 ) {
			p.explode();
			return false;
		}
		if( t < 3 ) return true;
		t -= 3;
		var me = this;
		var pc = p.level.refill(function(x,y) return Puzzle.inst.initPiece(me.pieces.shift(),x,y));
		pc.mc._xscale = pc.mc._yscale = 10;
		p.anims.add(new GrowAnim(pc.mc));
		return true;
	}

}

class WaitAnim {

	var callb : Void -> Void;

	public function new(callb) {
		this.callb = callb;
	}

	public function update() {
		if( Puzzle.inst.anims.length == 1 ) {
			callb();
			return false;
		}
		return true;
	}

}
