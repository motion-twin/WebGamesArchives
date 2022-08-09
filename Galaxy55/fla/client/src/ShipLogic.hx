import Common;

class CraftPoint {

	public var x : Int;
	public var y : Int;
	public var z : Int;
	public var w : Int;
	public var h : Int;
	public var zSize : Int;
	public var engine : CraftEngine;
	public var out : { x : Int, y : Int, z : Int };
	public var curCraft : CraftRule;
	public var curText : String;
	public var curDummy : ent.Dummy;
	public var heights : Array<Array<Int>>;
	
	public function new(x, y, z) {
		this.x = x;
		this.y = y;
		this.z = z;
		w = 1;
		h = 1;
	}
	
	public function inside(rx, ry, rz) {
		return rx >= x && ry >= y && rz >= z && rx < x + w && ry < y + h && rz < z + heights[rx - x][ry - y];
	}
	
}

class ShipLogic {

	public var x(default, null) : Int;
	public var y(default, null) : Int;
	public var z(default, null) : Int;
	public var start : Null<{ x : Int, y : Int, z : Int }>;
	
	var DX : Int;
	var DY : Int;
	var DZ : Int;
	var game : Game;
	var needRecal : Bool;
	var textActive : Bool;
	public var crafts : Array<CraftPoint>;
	
	public function new(g) {
		this.game = g;
		crafts = [];
		var s = game.infos.ship;
		x = s.x;
		y = s.y;
		z = s.z;
	}
	
	public function recalDock() {
		needRecal = true;
	}
	
	function getDummy( c : CraftPoint, ?b : Block ) {
		if( b == null ) b = Block.get(c.curCraft.out);
		return new ent.Dummy(c.out.x + DX + 0.5, c.out.y + DY + 0.5, c.out.z + DZ + 0.25, b);
	}
	
	public function addCraft( rx, ry, rz, b:Block ) {
		var cc = null;
		for( c in crafts )
			if( c.inside(rx,ry,rz) ) {
				cc = c;
				break;
			}
		if( cc == null )
			return false;
		cc.engine.add(b, rx - cc.x, ry - cc.y, rz - cc.z);
		check(cc);
		return true;
	}
	
	public function craft(x, y, z, b : Block) {
		var rx = game.real(x - DX);
		var ry = game.real(y - DY);
		var rz = z - DZ;
		var cc = null;
		for( c in crafts )
			if( c.inside(rx,ry,rz) ) {
				cc = c;
				break;
			}
		if( cc == null )
			return;
		if( b == null ) {
			game.api.craftBlock(rx, ry, rz, 0, 0);
			cc.engine.remove(rx - cc.x, ry - cc.y, rz - cc.z);
		} else {
			game.api.craftBlock(rx, ry, rz, b.index, game.interf.blockIndex - 1);
			cc.engine.add(b, rx - cc.x, ry - cc.y, rz - cc.z);
		}
		check(cc);
	}
	
	function check( cc : CraftPoint ) {
		var r = cc.engine.checkAll();
		cc.curCraft = r;
		if( cc.curDummy != null ) {
			game.dummies.remove(cc.curDummy);
			cc.curDummy = null;
		}
		if( r != null && cc.out != null ) {
			var d = getDummy(cc);
			// TODO rotation X 0.5
			d.fixed = true;
			d.active = false;
			d.time = 1e20;
			game.dummies.push(d);
			cc.curDummy = d;
		}
		var text = [];
		for( b in cc.engine.getBlocks(false) )
			text.push(b.n + "x " + b.b.getName());
		if( cc.engine.getBlocks(false).length>0 )
			if( r != null )
				text.push(" = " + (r.count > 1 ? r.count+" x ":"") + Block.get(r.out).getName());
			else
				text.push(" = "+game.getText("no_recipe"));
		if( text.length == 0 )
			cc.curText = null;
		else
			cc.curText = text.join("\n");
	}
	
	public function activateBlock( x : Int, y : Int, z : Int, b : Block ) {
		switch( b.k ) {
		case BCrafterComputer:
			x = game.real(x - DX);
			y = game.real(y - DY);
			z -= DZ;
			var c = null;
			for( cc in crafts )
				if( cc.out != null && cc.out.x == x && cc.out.y == y && cc.out.z == z ) {
					c = cc;
					break;
				}
			if( c == null || c.curCraft == null )
				return;
			var hasInv = true;
			var blocks = c.engine.getBlocks(true);
			for( b in blocks )
				if( !game.interf.hasBlocks(b.b, b.n) ) {
					hasInv = false;
					break;
				}
			var cur = c.curCraft;
			function onResult(ok) {
				if( !ok ) return;
				var b = Block.get(cur.out);
				for( i in 0...cur.count ) {
					var d = getDummy(c,b);
					d.delay = 30;
					d.get = function() {
						var index = game.interf.addBlock(b);
						if( index >= 0 ) {
							//game.interf.bump(index);
							game.api.getDummy(b.index, index);
							return false;
						}
						return true;
					}
					game.dummies.push(d);
				}
			}
			game.api.send(CCraft(c.curCraft.id, { x : c.out.x + DX, y : c.out.y + DY, z : c.out.z + DZ }, hasInv ? null : { x : c.x, y : c.y, z : c.z, sx : c.w, sy : c.h, sz : c.zSize } ), onResult);
			if( game.api.isOffline() )
				onResult(true);
			if( hasInv ) {
				var indexes = [];
				for( b in blocks )
					indexes = indexes.concat( game.interf.useBlocksIndexes(b.b, b.n) );
				//for( i in indexes )
					//game.interf.bump(i);
			} else {
				c.engine.clear();
				game.dummies.remove(c.curDummy);
				c.curCraft = null;
				c.curDummy = null;
				c.curText = null;
				for( b in blocks )
					for( p in b.pos ) {
						var x = game.real(p.x + c.x + DX);
						var y = game.real(p.y + c.y + DY);
						var z = p.z + c.z + DZ;
						game.level.set(x,y,z,null);
						game.render.builder.updateKube(x, y, z, null);
						game.render.parts.doBreak(x, y, z, b.b);
					}
			}
		default:
			game.api.send(CActivate(x,y,z,b.index));
		}
	}
	
	public function update() {
		var level = game.level;
		var hero = game.hero;
		
		if( needRecal ) {
			z = Const.SIZE;
			while( !level.collide(x, y, z) )
				z--;
			z++;
			needRecal = false;
		}
		
		var ddx = game.realDist(x + 0.5 - hero.x);
		var ddy = game.realDist(y + 0.5 - hero.y);
		var d = Math.sqrt(ddx * ddx + ddy * ddy);
		var onShipEntry = hero.z > Const.SIZE && hero.standingBlock == Block.all[Type.enumIndex(BShipEntry)];
		if( d < 0.6 && hero.z >= z && (hero.z <= Const.SIZE || onShipEntry) && start != null ) {
			if( hero.enteringShip >= 0 && hero.standingBlock != null ) {
				hero.enteringShip += mt.Timer.tmod * 0.05;
				if( hero.enteringShip >= 1.5 )
					hero.gotoShip(!onShipEntry);
			}
		} else {
			hero.enteringShip -= mt.Timer.tmod * 0.1;
			if( hero.enteringShip < 0 )
				hero.enteringShip = 0;
		}
		
		var old = textActive;
		textActive = false;
		if( hero.z >= DZ )
			checkHero();
		if( old && !textActive )
			game.interf.message();
	}
	
	function checkHero() {
		var hero = game.hero;
		
		if( hero.standingBlock != null ) {
			hero.life += mt.Timer.tmod * 0.05;
			if( hero.life > 100 ) hero.life = 100;
		}
		
		for( c in crafts ) {
			if( c.curText == null )
				continue;
			var dx = game.realDist(c.x + DX + c.w * 0.5 - hero.x);
			var dy = game.realDist(c.y + DY + c.h * 0.5 - hero.y);
			var dz = c.z + DZ - hero.z;
			var d = Math.sqrt(dx * dx + dy * dy + dz * dz);
			if( d < Math.max(c.w,c.h) * 0.5 + 3 ) {
				game.interf.message(c.curText, (c.curCraft==null ? 0xFF1C1C : null));
				textActive = true;
			}
		}
	}
	
	public function checkSelect() {
		var select = game.select;
		var sx = game.real(select.x - DX);
		var sy = game.real(select.y - DY);
		var sz = select.z - DZ;
		for( c in crafts ) {
			if( c.inside(sx,sy,sz) ) {
				select.powerFactor = 4;
				select.requireCharge = false;
				select.ignoreMagnets = true;
				return true;
			}
		}
		if( select.b != null && (select.b.activable != null || select.b.toggle != null) ) {
			select.allowBreak = false;
			return true;
		}
		return false;
	}

	public function init() {
		var ship = game.infos.ship;
		if( ship.data == null )
			return;
		var data = ship.data.getData();
		data.uncompress();
		var bytes = haxe.io.Bytes.ofData(data);
		var sx = bytes.get(0);
		var sy = bytes.get(1);
		var sz = bytes.get(2);
		var lvl = haxe.io.Bytes.alloc(Const.TSIZE * 2);
		var pos = 3;
		var dx = (Const.SIZE - sx) >> 1;
		var dy = (Const.SIZE - sy) >> 1;
		var dz = 1;
		var cinfos = [];
		var cout = [];
		for( y in 0...sy )
			for( x in 0...sx ) {
				var w = Const.addr( x + dx, y + dy, dz);
				lvl.blit(w << 1, bytes, pos, sz * 2);
				for( z in 0...sz ) {
					var bid = bytes.get(pos) | (bytes.get(pos + 1) << 8);
					if( bid == Type.enumIndex(BShipEntry) )
						start = { x : x + dx, y : y + dy, z : z + dz + 1 + Const.SHIP_Z };
					else if( bid == Type.enumIndex(BCrafter) ) {
						var c = new CraftPoint(x + dx, y + dy, z + dz + 1);
						var pp = pos + 2;
						while( z + c.zSize + 1 < sz && bytes.get(pp) == 0 && bytes.get(pp + 1) == 0 ) {
							c.zSize++;
							pp += 2;
						}
						cinfos[x + y * sx + z * sx * sy] = c;
					} else if( bid == Type.enumIndex(BCrafterComputer) )
						cout.push( { x : x + dx, y : y + dy, z : z + dz } );
					pos += 2;
				}
			}
		// calculate craft points sizes
		var pos = 0;
		for( z in 0...sz )
			for( y in 0...sy )
				for( x in 0...sx ) {
					var c = cinfos[pos];
					if( c == null ) {
						pos++;
						continue;
					}
					var zs = c.zSize;
					c.heights = [[zs]];
					while( true ) {
						var changed = false;
						var found = true;
						for( dy in 0...c.h )
							if( cinfos[pos + c.w + dy * sx] == null ) {
								found = false;
								break;
							}
						if( found ) {
							c.heights.push([]);
							for( dy in 0...c.h ) {
								var c2 = cinfos[pos + c.w + dy * sx];
								if( c2.zSize < zs ) zs = c2.zSize;
								c.heights[c.w][dy] = c2.zSize;
								cinfos[pos + c.w + dy * sx] = null;
							}
							c.w++;
							changed = true;
						}
						var found = true;
						for( dx in 0...c.w )
							if( cinfos[pos + c.h * sx + dx] == null ) {
								found = false;
								break;
							}
						if( found ) {
							for( dx in 0...c.w ) {
								var c2 = cinfos[pos + c.h * sx + dx];
								if( c2.zSize < zs ) zs = c2.zSize;
								c.heights[dx][c.h] = c2.zSize;
								cinfos[pos + c.h * sx + dx] = null;
							}
							c.h++;
							changed = true;
						}
						if( !changed )
							break;
					}
					c.engine = new CraftEngine();
					c.zSize = zs;
					crafts.push(c);
					pos++;
				}
		for( c in crafts ) {
			var dm = -1., best = null;
			for( o in cout ) {
				var dx = Math.abs(c.x + c.w * 0.5 - o.x);
				var dy = Math.abs(c.y + c.h * 0.5 - o.y);
				var dz = Math.abs(c.z + 0.5 - o.z) * 0.5;
				var d = Math.sqrt(dx * dx + dy * dy + dz * dz);
				if( d < dm || best == null ) {
					dm = d;
					best = o;
				}
			}
			if( best == null ) continue;
			cout.remove(best);
			c.out = best;
		}
		var extra = game.level.extra;
		extra.init(lvl.getData());
		extra.collideEmpty = false;
		extra.posX = DX = x - start.x;
		extra.posY = DY = y - start.y;
		extra.posZ = DZ = Const.SHIP_Z;
	}
}