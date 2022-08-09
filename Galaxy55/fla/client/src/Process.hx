import Common;
import Protocol;

class Process {

	static inline var TRACK_FLAG = 1 << (Const.BITS * 2 + Const.ZBITS);
	static inline var TRACK_BITS = Const.BITS * 2 + Const.ZBITS + 1;
	static inline var TRACK_MASK = (1 << (TRACK_BITS - 1)) - 1;
	
	var game : Game;
	var level : Level;
	var flooding : flash.utils.ByteArray;
	var cover : Array<{ x : Int, y : Int, z : Int }>;
	var propagate : Array<{ x : Int, y : Int, z : Int, b : Block, t : Int }>;
	var time : Float;
	var frame : Int;
	var cameraOn : { x : Int, y : Int, z : Int, pos : String };
	var trackDist : flash.Vector<Int>;
	var trackBlocks : Array<Array<flash.Vector<Int>>>;
	var trackCurrent : Array<{ x : Int, y : Int, z : Int, b : Block }>;
	public var allowTransforms : Bool;
	
	var chest : ent.Chest;
	
	public function new(g) {
		time = 0;
		allowTransforms = true;
		this.game = g;
		this.level = g.level;
		cover = [];
		flooding = new flash.utils.ByteArray();
		propagate = [];
		trackCurrent = [];
		initTrack();
	}
	
	function initTrack() {
		trackDist = new flash.Vector(Block.all.length);
		for( b in Block.all )
			if( b.hasProp(PTrack) ) {
				var dist = 0;
				for( f in b.flags )
					switch( f ) {
					case BFTrack(_, d): if( d > dist ) dist = d;
					default:
					}
				trackDist[b.index] = dist;
			}
		trackBlocks = [];
		for( x in 0...level.size ) {
			trackBlocks[x] = [];
			for( y in 0...level.size )
				trackBlocks[x][y] = new flash.Vector();
		}
	}
	
	function set(x, y, z, old:Block, b:Block ) {
		x = real(x);
		y = real(y);
		level.set(x, y, z, b);
		if( z < Const.ZSIZE )
			game.api.processBlock(x, y, z, b == null ? 0 : b.index, old == null ? 0 : old.index);
		game.render.builder.updateKube(x, y, z, b);
		game.needRedraw = true;
		onSet(x, y, z, old, b);
	}
	
	public function onInitLevel( x : Int, y : Int ) {
		var tl = new flash.Vector();
		trackBlocks[x][y] = tl;
		flash.Memory.select(level.cells[x][y].t);
		var pos = 0, d = 0;
		for( i in 0...Const.TSIZE ) {
			var bid = flash.Memory.getUI16(i << 1);
			if( bid == 0 || (d=trackDist[bid]) == 0 ) continue;
			tl[pos++] = i | (d << TRACK_BITS);
		}
	}
	
	public function update(dt:Float) {
		time += dt;
		if( time < 0.1 ) return false;
		frame++;
		time -= 0.1;
		var flag = false;
		if( frame % 4 == 0 && updateFlood() )
			flag = true;
		if( updateCover() )
			flag = true;
		if( updatePropagate() )
			flag = true;
		if( cameraOn != null )
			updateCamera();
		if( chest != null && !chest.update() )
			chest = null;
		updateTrack();
		return flag;
	}
	
	var miningSpeedCount : Int;
	function trackEffect( t, on : Bool ) {
		switch( t ) {
		case TCustom:
			// nothing
		case TMiningSpeed:
			miningSpeedCount += on ? 1 : -1;
			if( miningSpeedCount <= 0 )
				game.hero.miningPower = 1;
			else
				game.hero.miningPower = 3;
		}
	}
	
	function activateTrack( x, y, z, f ) {
		if( !f ) {
			for( t in trackCurrent )
				if( t.x == x && t.y == y && t.z == z ) {
					trackCurrent.remove(t);
					for( f in t.b.flags )
						switch( f ) {
						case BFTrack(t, _):
							trackEffect(t, false);
						default:
						}
				}
			return;
		} else {
			var b = level.get(x, y, z);
			if( b != null && b.hasProp(PTrack) ) {
				trackCurrent.push( { x:x, y:y, z:z, b:b } );
				for( f in b.flags )
					switch( f ) {
					case BFTrack(t,_):
						trackEffect(t, true);
					default:
					}
			}
		}
	}
	
	function updateTrack() {
		// check block still present
		for( t in trackCurrent.copy() )
			if( level.get(t.x, t.y, t.z) != t.b )
				activateTrack(t.x, t.y, t.z, false);
		// minus 0.5 since we want to make the dist with the center of the block
		var x = game.hero.x - 0.5;
		var y = game.hero.y - 0.5;
		var z = game.hero.z + game.hero.viewZ * 0.5 - 0.5;
		for( cx in 0...level.size )
			for( cy in 0...level.size ) {
				var tl = trackBlocks[cx][cy];
				for( i in 0...tl.length ) {
					var a = tl[i];
					var ax = ((a >> Const.X) & Const.MASK) + (cx << Const.BITS);
					var ay = ((a >> Const.Y) & Const.MASK) + (cy << Const.BITS);
					var az = (a >> Const.Z) & Const.ZMASK;
					var dx = game.realDist(ax - x);
					var dy = game.realDist(ay - y);
					var dz = game.realDist(az - z);
					var active = dx * dx + dy * dy + dz * dz < (a >> TRACK_BITS) * (a >> TRACK_BITS);
					if( active != ((a & TRACK_FLAG) != 0) ) {
						tl[i] = a ^ TRACK_FLAG;
						activateTrack(ax, ay, az, active);
					}
				}
			}
	}
	
	function updateFlood() {
		if( flooding.length == 0 )
			return false;
		var wlevel = game.planet.waterLevel;
		var flood = flooding;
		flood.position = 0;
		flooding = new flash.utils.ByteArray();
		for( i in 0...Std.int(flood.length / 6) ) {
			var x : Int = flood.readUnsignedShort();
			var y : Int = flood.readUnsignedShort();
			var z : Int = flood.readUnsignedShort();
			var b = level.get(x, y, z);
			if( b == null || b.type != BTWater ) continue;
			this.flood(real(x - 1), y, z, b);
			this.flood(real(x + 1), y, z, b);
			this.flood(x, real(y - 1), z, b);
			this.flood(x, real(y + 1), z, b);
			if( z < wlevel ) this.flood(x, y, z + 1, b);
			while( z > 0 && this.flood(x, y, --z, b) ) {
			}
		}
		return true;
	}
	
	function updateCover() {
		if( cover.length == 0 || Std.random(5) != 0 )
			return false;
		var c = cover[Std.random(cover.length)];
		cover.remove(c);
		var b = level.get(c.x, c.y, c.z);
		var over = level.get(c.x, c.y, c.z + 1);
		if( b != null && b.covered != null && (over == null || over.isTransparent()) )
			set(c.x, c.y, c.z, b, b.covered);
		return true;
	}
	
	function blockBreak(x, y, z, b:Block) {
		game.blockBreak(x, y, z, b, true);
	}
	
	public function canPropagate(b:Block , bt:Block) {
		return bt == null || (!bt.collide && !b.hasProp(PLiquid)) || (switch( bt.type ) { case BTModel, BTModel2Side, BTReduced: true; default: false; }) || (b.hasProp(PLava) && (bt.hasProp(PLiquid) && !bt.hasProp(PLava)));
	}
	
	function flood(x, y, z, b) {
		var b2 = level.get(x, y, z);
		if( b2 == b )
			return false;
		if( canPropagate(b,b2) ) {
			if( b2 != null )
				blockBreak(x, y, z, b2);
			set(x, y, z, null, b);
			flooding.writeShort(x);
			flooding.writeShort(y);
			flooding.writeShort(z);
			return true;
		}
		return false;
	}
	
	inline function real(p) {
		return game.real(p);
	}
	
	function onActivateLate(x,y,z,b) {
		if( level.get(x,y,z) != b )
			return;
		onActivate(x,y,z,b,true);
	}
	
	public function onActivate(x, y, z, b:Block,?rec=false) {
		switch( b.k ) {
		case BArtiBomb:
			var ray = 8;
			var d = (game.hero.x-x)*(game.hero.x-x) + (game.hero.y-y)*(game.hero.y-y) + (game.hero.z-z)*(game.hero.z-z);
			var pow = 1-d/(ray*ray);
			game.hero.hit( Math.ceil(130*pow)+20 );
			game.shake = 1;
			var oldFade = game.fadeFX;
			game.fadeFX = { t:0., speed : 2.5, col : mt.deepnight.Color.interpolateInt(0xFFFFFF,0xFF0000,pow), done : oldFade.done, dz : oldFade.dz, getAlpha : function(t) {
				return (Math.random()*0.1 + 0.9) * (1-t);
			}};
			for( dx in -ray...ray )
				for( dy in -ray...ray )
					for( dz in -ray...ray ) {
						var d = dx * dx + dy * dy + dz * dz;
						if( d > ray * ray ) continue;
						var x = x + dx, y = y + dy, z = z +dz;
						if( z >= Const.SHIP_Z ) continue;
						var old = level.get(x, y, z);
						if( old != null && !(b.requiredPower < 0) ) {
							set(x, y, z, old, null);
							game.render.parts.doBreak(x, y, z, old);
							if( old.activable != null && (dx != 0 || dy != 0 || dz != 0) )
								switch( old.activable ) {
								case WEverywhere, WOnPlanet:
									haxe.Timer.delay(callback(onActivateLate,x, y, z, old),1);
								default:
								}
						}
					}
		case BCamera:
			if( rec || game.infos.planet.id <= 0 )
				return;
			var hero = game.hero;
			var ox = hero.x, oy = hero.y, oz = hero.z, oa = hero.angle, oaz = hero.angleZ, ovz = hero.viewZ;
			var hud = game.hudOn, mouse = game.mouseControls();
			game.interf.showInventory(false);
			game.hudOn = false;
			game.controlType = CLASSIC;
			if( game.drag != null ) game.drag.active = true;
			hero.x = x + 0.5;
			hero.y = y + 0.5;
			hero.oldSpeedX = 0;
			hero.oldSpeedY = 0;
			hero.z = z;
			hero.lock = true;
			hero.angleSpeed = 0.15;
			hero.viewZ = 0.45;
			cameraOn = { x : x, y : y, z : z, pos : null };
			game.onAction = function() {
				game.interf.showInventory(true);
				game.laser.wait = true;
				game.onAction = null;
				game.controlType = mouse?MOUSE:CLASSIC;
				game.hudOn = hud;
				hero.x = ox;
				hero.y = oy;
				hero.z = oz;
				hero.angle = oa;
				hero.angleZ = oaz;
				hero.viewZ = ovz;
				hero.lock = false;
				hero.angleSpeed = 1;
				cameraOn = null;
				game.showHelpTip();
			};
		default:
			if( rec )
				return;
			if( b.hasProp(PContainer) ) {
				if( chest != null ) {
					if( chest.x == x && chest.y == y && chest.z == z )
						return;
					chest.close();
					chest = null;
				}
				chest = new ent.Chest(game, x, y, z);
				chest.open();
				return;
			}
			game.api.send(CActivate(x, y, z, b.index));
		}
	}
	
	static var BASE64 = new haxe.BaseCode(haxe.io.Bytes.ofString("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_"));
	
	function updateCamera() {
		var o = new haxe.io.BytesOutput();
		var b = new format.tools.BitsOutput(o);
		b.writeBits(24, game.infos.planet.id);
		b.writeBits(24, game.infos.userId == null ? 0 : game.infos.userId);
		b.writeBits(6 + game.infos.planet.size, real(cameraOn.x));
		b.writeBits(6 + game.infos.planet.size, real(cameraOn.y));
		b.writeBits(Const.ZBITS, cameraOn.z);
		var hero = game.hero;
		var a = Math.round(hero.angle/(Math.PI*2) * 512) & 511;
		var az = Math.round((hero.angleZ + Math.PI / 2) * 256 / Math.PI) & 255;
		b.writeBits(9, a);
		b.writeBits(8, az);
		b.flush();
		var pos = BASE64.encodeBytes(o.getBytes()).toString();
		if( pos != cameraOn.pos ) {
			cameraOn.pos = pos;
			game.showHelpTip("camera_link", { _pos : pos });
		}
	}

	public function toggle(x, y, z, b:Block) {
		while( level.get(x, y, z - 1) == b )
			z--;
		while( level.get(x,y,z) == b ) {
			set(x, y, z, b, b.toggle);
			z++;
		}
	}
	
	public function onSet(x, y, z, old:Block, b:Block) {

		// can append with toggle -> set
		if( z >= Const.SHIP_Z )
			return;
			
		if( (old != null && old.hasProp(PTrack)) || (b != null && b.hasProp(PTrack)) )
			checkTrack(x, y, z);
		
		var over = level.get(x, y, z + 1);
		var under = level.get(x, y, z - 1);
		
		checkBroken(x, y, z, -1, 0, 0, b);
		checkBroken(x, y, z, 1, 0, 0, b);
		checkBroken(x, y, z, 0, -1, 0, b);
		checkBroken(x, y, z, 0, 1, 0, b);
		checkBroken(x, y, z, 0, 0, 1, b);
		checkBroken(x, y, z, 0, 0, -1, b);
		
		if( b == null ) {
			// cover if we create hole
			if( under != null && under.covered != null )
				cover.push( { x : x, y : y, z : z - 1 } );
			// destroy detail over
			if( over != null && over.hasFlag(BFDetail) ) {
				set(x, y, z + 1, over, null);
				over = null;
			}
			// auto break anchored blocks
			if( over != null && over.hasAnchor(Down) )
				game.blockBreak(x, y, z + 1, over);
			if( under != null && under.hasAnchor(Up) )
				game.blockBreak(x, y, z - 1, under);
		} else {
			// cover if we put under hole/transparent
			if( b.covered != null && (over == null || over.isTransparent())  )
				cover.push( { x : x, y : y, z : z } );
			// uncover block under
			if( under != null && under.uncover != null && !b.isTransparent() )
				set(x, y, z - 1, under, under.uncover);
			// propagate
			if( b.propagate != null )
				propagate.push( { x:real(x), y:real(y), z:z, b:b, t : 2+Std.random(3) } );
			// handle special effects
			switch( b.k ) {
			case BFreezer:
				if( allowTransforms ) {
					var ice = Block.get(BIce);
					var lavaRock = Block.get(BLavaRock);
					var d = 4;
					for( dx in -d...d+1 )
						for( dy in -d...d+1 )
							for( dz in -d...d+1 ) {
								var e = (dx / d) * (dx / d) + (dy / d) * (dy / d) + (dz / d) * (dz / d);
								if( e < 1 ) {
									var x = game.real(x + dx);
									var y = game.real(y + dy);
									var z = z + dz;
									var b = level.get(x, y, z);
									if( b == null ) continue;
									if( b.hasProp(PLava) )
										set(x, y, z, b, lavaRock);
									else if( b.hasProp(PLiquid) )
										set(x, y, z, b, ice);
								}
							}
				}
			default:
			}
		}
		// special
		if( old != null )
			for( f in old.flags )
				switch( f ) {
				case BFTransform(t, p):
					if( allowTransforms && (p == null || Math.random() < p) )
						set(x, y, z, b, Block.get(t));
				default:
				}
	}
	
	function checkTrack(x, y, z) {
		x = real(x);
		y = real(y);
		var addr = Const.addr(x & Const.MASK, y & Const.MASK, z);
		var b = level.get(x, y, z);
		var tl = trackBlocks[x >> Const.BITS][y >> Const.BITS];
		if( b != null && b.hasProp(PTrack) ) {
			var val = addr | (trackDist[b.index] << TRACK_BITS);
			for( i in 0...tl.length )
				if( tl[i] & TRACK_MASK == addr ) {
					tl[i] = val;
					return;
				}
			tl.push(val);
		} else {
			for( i in 0...tl.length )
				if( tl[i]&TRACK_MASK == addr ) {
					tl.splice(i, 1);
					return;
				}
		}
	}
	
	function checkBroken(x, y, z, dx, dy, dz, b : Block) {
		x += dx;
		y += dy;
		z += dz;
		var b = level.get(x, y, z);
		if( b == null )
			return;
		if( b.type == BTWater ) {
			flooding.writeShort(real(x));
			flooding.writeShort(real(y));
			flooding.writeShort(z);
		} else if( b.propagate != null )
			propagate.push( { x:real(x), y:real(y), z:z, b:b, t : 2+Std.random(3) } );
	}
	
	function updatePropagate() {
		var old = propagate;
		if( old.length == 0 )
			return false;
		propagate = [];
		for( p in old ) {
			if( p.t-- >= 0 ) {
				propagate.push(p);
				continue;
			}
			var x = p.x;
			var y = p.y;
			var z = p.z;
			var b = p.b;
			// check still there
			if( level.get(x, y, z) != b )
				continue;
			// check removal
			var remove = b.hasFlag(BFNoDrop) || b.hasFlag(BFNoPick);
			var other;
			if( remove && (other=level.get(x, y, z + 1)) != null && (other.propagate == b || other == b) )
				remove = false;
			if( remove && (other=level.get(x - 1, y, z)) != null && other != b && other.propagate == b )
				remove = false;
			if( remove && (other=level.get(x + 1, y, z)) != null && other != b && other.propagate == b )
				remove = false;
			if( remove && (other=level.get(x, y - 1, z)) != null && other != b && other.propagate == b )
				remove = false;
			if( remove && (other=level.get(x, y + 1, z)) != null && other != b && other.propagate == b )
				remove = false;
			if( remove ) {
				set(x, y, z, b, null);
				continue;
			}
			// check propagate under
			var under = level.get(x, y, z - 1);
			if( canPropagate(b,under) ) {
				var tb = b.hasFlag(BFFallCopy) ? b : b.propagate;
				if( under != null )
					blockBreak(x, y, z-1, under);
				set(x, y, z-1, null, tb);
				continue;
			} else if( under == b || under == b.propagate )
				continue;
			// propagate LR
			if( b.propagate == b )
				continue;
			for( d in [[ -1, 0], [1, 0], [0, 1], [0, -1]] ) {
				var tx = real(x + d[0]);
				var ty = real(y + d[1]);
				var tz = z;
				var t = level.get(tx, ty, tz);
				if( canPropagate(b, t) ) {
					if( t != null )
						blockBreak(tx, ty, tz, t);
					set(tx, ty, tz, null, b.propagate);
				} else {
					var k = b.propagate;
					if( t != k ) {
						k = k.propagate;
						while( k != null ) {
							if( k == t ) {
								set(tx, ty, tz, t, b.propagate);
								break;
							}
							if( k.propagate == k )
								break;
							k = k.propagate;
						}
					}
				}
			}
		}
		return true;
	}
	
}