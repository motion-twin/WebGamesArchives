import Common;

class Tuto {

	var g : Kube;
	var phase : Int;
	var cur : String;

	// tmp variables
	var px : Float;
	var py : Float;
	var dist : Float;
	var angle : Float;
	var angleZ : Float;
	var count : Int;
	var flag : Bool;
	var zx : Int;
	var zy : Int;

	public function new(g) {
		this.g = g;
		phase = Kube.DATA._tuto;
	}

	function next() {
		phase++;
		g.command(CUpdateTuto(phase));
		touchKube = function(_) {};
	}

	function text(t) {
		if( cur == t ) return false;
		g.interf.setTuto(t);
		cur = t;
		return true;
	}

	function resetDist() {
		px = g.px + g.cx;
		py = g.py + g.cy;
		dist = 0;
	}

	function updateDist() {
		var ax = g.px + g.cx;
		var ay = g.py + g.cy;
		var dx = ax - px, dy = ay - py;
		dist += Math.sqrt(dx*dx + dy * dy);
		px = ax; py = ay;
		return dist;
	}

	function curZone() {
		return {
			x : Std.int(g.px + g.cx) >> GameConst.ZONEBITS,
			y : Std.int(g.py + g.cy) >> GameConst.ZONEBITS,
		};
	}

	public dynamic function touchKube( k : BlockKind ) {
	}

	public function update() {
		var ID = -1;
		switch( phase ) {
		case ++ID:
			if( text(g.texts.tuto_move) )
				resetDist();
			if( updateDist() > 10 )
				next();
		case ++ID:
			if( text(g.texts.tuto_turn) ) {
				angle = g.angle;
				dist = 0;
			}
			dist += Math.abs(angle - g.angle);
			angle = g.angle;
			if( dist > Math.PI )
				next();
		case ++ID:
			if( text(g.texts.tuto_jump) ) {
				flag = false;
				count = 0;
			}
			var f = (g.gravity < 0);
			if( f != flag ) {
				flag = f;
				if( !f ) count++;
			}
			if( count >= 4 )
				next();
		case ++ID:
			if( text(g.texts.tuto_take) )
				count = g.interf.inventoryCount(false);
			var cur = g.interf.inventoryCount(false);
			if( count >= 8 || cur - count >= 3 )
				next();
		case ++ID:
			text(g.texts.tuto_select);
			if( g.build != null )
				next();
		case ++ID:
			if( text(g.texts.tuto_put) )
				count = g.interf.inventoryCount(false);
			if( g.interf.inventoryCount(false) == 0 || g.interf.inventoryCount(false) - count <= -3 )
				next();
		case ++ID:
			text(g.texts.tuto_unselect);
			if( g.build == null )
				next();
		case ++ID:
			if( text(g.texts.tuto_cost) )
				resetDist();
			if( updateDist() > 0.5 )
				next();
		case ++ID:
			if( text(g.texts.tuto_look) ) {
				angle = g.angle;
				angleZ = g.angleZ;
				dist = 0;
			}
			if( g.drag != null && g.drag.active )
				dist += Math.abs(angleZ - g.angleZ) + Math.abs(angle - g.angle);
			angle = g.angle;
			angleZ = g.angleZ;
			if( dist > Math.PI * 2 )
				next();
		case ++ID:
			text(g.texts.tuto_water);
			if( g.swimming )
				next();
		case ++ID:
			if( !g.swimming ) {
				phase -= 2;
				next();
				return;
			}
			if( text(g.texts.tuto_swim) )
				resetDist();
			if( updateDist() > 5 )
				next();
		case ++ID:
			text(g.texts.tuto_water_out);
			if( g.gravity == 0 && !g.swimming )
				next();
		case ++ID:
			var z = curZone();
			if( text(g.texts.tuto_zone) ) {
				zx = z.x;
				zy = z.y;
			}
			if( z.x != zx || z.y != zy )
				next();
		case ++ID:
			var z = curZone();
			if( text(g.texts.tuto_zone_p) ) {
				zx = z.x;
				zy = z.y;
			}
			if( z.x != zx || z.y != zy ) {
				zx = z.x;
				zy = z.y;
				var z = g.zones.get(g.key(zx,zy));
				if( z != null && z._u != null )
					next();
			}
		case ++ID:
			text(g.texts.tuto_zone_pout);
			var z = curZone();
			var z = g.zones.get(g.key(z.x,z.y));
			if( z != null && z._u == null )
				next();
		case ++ID:
			text(g.texts.tuto_kubes);
			if( g.interf.inventoryCount(true) >= 4 )
				next();
		case ++ID:
			if( text(g.texts.tuto_dolmen) ) {
				var me = this;
				touchKube = function(k) switch(k) { case BDolmen: me.next(); default: };
			}
		case ++ID:
			text(g.texts.tuto_explore);
			var z = curZone();
			if( Math.abs(z.x) >= 10 || Math.abs(z.y) >= 10 )
				next();
		default:
			if( cur == null ) {
				g.tuto = null;
				return;
			}
			text(g.texts.tuto_end);
		}
		if( g.interf.power <= 0 ) {
			g.tuto = null;
			text(g.texts.tuto_energy);
		}
	}

}
