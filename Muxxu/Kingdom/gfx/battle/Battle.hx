import data.Battle;
typedef MC = flash.display.MovieClip;

class U {
	public var id : Int;
	public var x : Int;
	public var y : Int;
	public var life : Int;
	public function new(id,life,x,y) {
		this.id = id;
		this.life = life;
		this.x = x;
		this.y = y;
	}
}

class Unit {
	public var id : Int;
	public var mc : MC;
	public var life : Int;
	public function new(id) {
		this.id = id;
	}
}

class Pair {
	public var u1 : Unit;
	public var u2 : Unit;
	public var dy : Int;
	var t1 : Float;
	var t2 : Float;
	var dt1 : Float;
	var dt2 : Float;
	var shake1 : Float;
	var shake2 : Float;

	public function new() {
		reset1();
		reset2();
		shake1 = 0;
		shake2 = 0;
	}

	function reset1() {
		t1 = 0;
		dt1 = Math.random() * Math.random() + 0.5;
	}

	function reset2() {
		t2 = 0;
		dt2 = Math.random() * Math.random() + 0.5;
	}

	public function update() {
		t1 += dt1 * 0.1;
		t2 += dt2 * 0.1;
		var m1 = Math.abs(Math.sin(t1));
		var m2 = Math.abs(Math.sin(t2));
		u1.mc.x = Std.int(250 - 16 + m1 * 5);
		u2.mc.x = Std.int(250 + 16 - m2 * 5);
		u1.mc.y = dy + Math.round(shake1);
		u2.mc.y = dy + Math.round(shake2);
		if( Math.abs(shake1) < 0.5 )
			shake1 = 0;
		else
			shake1 = -shake1 * 0.7;
		if( Math.abs(shake2) < 0.5 )
			shake2 = 0;
		else
			shake2 = -shake2 * 0.7;
		if( (m1 > 0.8 && m2 > 0.8 && Std.random(4) == 0) || Std.random(100) == 0 ) {
			if( Std.random(2) == 0 ) {
				shake1 = 0.49 + Math.random();
				reset1();
			}
			if( Std.random(2) == 0 ) {
				shake2 = 0.49 + Math.random();
				reset2();
			}
		}
	}
}

class Battle {

	var root : MC;
	var units : Array<flash.display.MovieClip>;
	var front : flash.display.BitmapData;
	var pairs : Array<Pair>;
	var dm : mt.DepthManager;
	var life : {> MC, bar : MC };

	function new(root) {
		this.root = root;
		this.dm = new mt.DepthManager(root);
		var bg = dm.attach(__unprotect__("bg"),0);
		front = new flash.display.BitmapData(Math.round(bg.width),Math.round(bg.height),true,0);
		dm.add(new flash.display.Bitmap(front),0);
		life = cast flash.Lib.attach(__unprotect__("life"));
		initUnits();
		drawUnits();
		initPairs();
	}

	function newUnit(x) {
		var mc = flash.Lib.attach(__unprotect__("units"));
		mc.gotoAndStop(x+1);
		return mc;
	}

	function attachShade(x) {
		var mc = flash.Lib.attach(__unprotect__("shade"));
		mc.gotoAndStop(x+1);
		return mc;
	}

	function initUnits() {
		units = new Array();
		var mc = newUnit(0);
		for( i in 0...mc.totalFrames )
			units.push(newUnit(i));
	}

	function initPairs() {
		pairs = new Array();
		var count = 1;
		for( p in DATA._pairs ) {
			var u1 = new Unit(p._u1._k);
			u1.life = p._u1._l;
			u1.mc = newUnit(u1.id);
			u1.mc.addChildAt(attachShade(u1.id),0);
			dm.add(u1.mc,1);
			var u2 = new Unit(p._u2._k);
			u2.life = p._u2._l;
			u2.mc = newUnit(u2.id);
			u2.mc.addChildAt(attachShade(u2.id),0);
			u2.mc.scaleX = -1;
			dm.add(u2.mc,1);
			var p = new Pair();
			p.u1 = u1;
			p.u2 = u2;
			p.dy = Std.int(110 + (count++) * 350 / (DATA._pairs.length + 2));
			p.update();
			pairs.push(p);
			mt.flash.Event.over.bind(u1.mc,callback(showLife,u1,true));
			mt.flash.Event.out.bind(u1.mc,callback(showLife,u1,false));
			mt.flash.Event.over.bind(u2.mc,callback(showLife,u2,true));
			mt.flash.Event.out.bind(u2.mc,callback(showLife,u2,false));
		}
	}

	function showLife( u : Unit, flag : Bool ) {
		if( !flag ) {
			if( life.parent != null )
				life.parent.removeChild(life);
			return;
		}
		u.mc.addChild(life);
		var lmax = DATA._lifes[u.id];
		life.scaleX = u.mc.scaleX * (lmax / 80);
		life.bar.scaleX = u.life / lmax;
	}

	function drawUnits() {
		var cattTotal = 0, cdefTotal = 0;
		var cattCount = 0, cdefCount = 0;
		for( c in DATA._camps ) {
			if( c._def )
				cdefCount++;
			else
				cattCount++;
			if( c._def )
				cdefTotal++;
			else
				cattTotal++;
			for( k in c._units )
				if( c._def )
					cdefTotal += k.length;
				else
					cattTotal += k.length;
		}
		var cattPos = 110, cdefPos = 110;
		var r = new mt.Rand(0);
		var m = new flash.geom.Matrix();
		var me = this;
		m.identity();
		var shade = attachShade(0);
		for( c in DATA._camps ) {
			var units = new Array<U>();
			var ucount = 1;
			for( k in c._units )
				ucount += k.length;
			var h = 50 + Std.int(ucount * (270-(c._def?cdefCount:cattCount)*50) / (c._def?cdefTotal:cattTotal));
			var w = 170;
			var ybase, xbase = 20;
			if( c._def ) {
				ybase = cdefPos;
				cdefPos += h;
				xbase = 500 - (w + xbase);
			} else {
				ybase = cattPos;
				cattPos += h;
			}
			ybase += 20;
			h -= 40;
			if( h < 20 ) h = 20;
			var hmax = ucount * 4;
			if( h > hmax ) {
				var dy = (h - hmax) >> 1;
				ybase += dy;
				h = hmax;
				if( c._def ) cdefPos += dy else cattPos += dy;
			}
			units.push(new U(c._units.length,0,xbase + (w>>1), ybase + (h>>1)));
			for( i in 0...c._units.length ) {
				for( life in c._units[i] ) {
					if( life == 0 ) continue;
					var minDist = 30 * 30;
					var x = 0,y = 0;
					while( true ) {
						var d;
						do {
							x = r.random(w);
							y = r.random(h);
							var dx = (x - (w>>1)) * 2 / w;
							var dy = (y - (h>>1)) * 2 / h;
							d = dx*dx+dy*dy;
						} while( d > 1 );
						x += xbase;
						y += ybase;
						var near = false;
						for( u in units ) {
							var dx = u.x - x;
							var dy = u.y - y;
							if( dx * dx + dy * dy < minDist ) {
								near = true;
								break;
							}
						}
						if( !near ) break;
						minDist -= 10;
					}
					units.push(new U(i,life,x,y));
				}
			}
			units.sort(sortUnits);
			m.a = c._def ? -1 : 1;
			for( u in units ) {
				m.tx = u.x;
				m.ty = u.y;
				shade.gotoAndStop(u.id+1);
				this.front.draw(shade,m);
			}
			for( u in units ) {
				m.tx = u.x;
				m.ty = u.y;
				this.front.draw(this.units[u.id],m);
			}
			var shape = dm.empty(2);
			shape.graphics.beginFill(0,0);
			shape.graphics.drawEllipse(xbase-10,ybase-30,w+20,h+30);
			shape.addEventListener(flash.events.MouseEvent.CLICK,function(_) me.onSelectCamp(c));
			shape.buttonMode = true;
		}
	}

	function onSelectCamp( c : { _id : Int } ) {
		if( DATA._campUrl != null )
			flash.Lib.getURL(new flash.net.URLRequest(DATA._campUrl.split("::id::").join(Std.string(c._id))),"_self");
	}

	function sortUnits( u1 : U, u2 : U ) {
		return u1.y - u2.y;
	}

	function update() {
		for( p in pairs )
			p.update();
	}

	static function initDebugData() : BattleData {
		var CID = 0;
		var lifes = [50,80,90,120,90,100,110,70,70];
		var ucount = lifes.length;
		var r = new mt.Rand(54);
		var camp = function(def,n) {
			var u = [];
			for( i in 0...ucount )
				u.push([]);
			for( i in 0...n ) {
				var k = r.random(u.length);
				u[k].push(r.random(lifes[k]));
			}
			return {
				_id : CID++,
				_def : def,
				_units : u,
			};
		};
		var unit = function() {
			var k = r.random(ucount);
			return { _c : r.random(CID), _k : k, _l : r.random(lifes[k]) };
		};
		var pair = function() {
			return { _u1 : unit(), _u2 : unit() };
		};
		return {
			_campUrl : null,
			_lifes : lifes,
			_camps : [camp(false,10),camp(true,50),camp(true,10),camp(true,100)],
			_pairs : Lambda.list([pair(),pair(),pair(),pair(),pair(),pair(),pair()]),
		};
	}

	static var DATA : BattleData;
	static var inst : Battle;
	static function main() {
		DATA = Codec.getData("data");
		if( DATA == null ) DATA = initDebugData();
		var root = new MC();
		flash.Lib.current.addChild(root);
		inst = new Battle(root);
		root.addEventListener(flash.events.Event.ENTER_FRAME,function(_) inst.update());
	}

}