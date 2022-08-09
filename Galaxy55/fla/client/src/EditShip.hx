import Common;
import Protocol;

class EditShip extends Game {

	var editInfos : EditShipInfos;
	var shipChanged : Bool;
	var shipValid : mt.flash.Volatile<Bool>;
	var lookup : flash.utils.ByteArray;
	var levelBytes : flash.utils.ByteArray;
	var shipStart : { x : Int, y : Int, z : Int, a : Int };
	var collideBits : flash.Vector<Int>;
	
	public function new(root, engine, api:net.Api, infos:EditShipInfos ) {
		var ginf = {
			ship : null,
			planet : api.planet,
			offline : false,
			lastPos : null,
			userId : null,
			userName : "",
			inventory : infos.inventory,
			debug : infos.debug,
			crafts : null,
		};
		super(root, engine, api, ginf);
		this.editInfos = infos;
		process.allowTransforms = false;
		lookup = new flash.utils.ByteArray();
		lookup.length = Const.TSIZE * 2;
		planet.lightHeight = infos.size.z + 1;
		planet.curve = 0.00001;
		api.onSetBlock = function(x, y, z, b) {
			shipChanged = true;
			checkShip();
		};
		shipValid = false;
	}
	
	override function init() {
		super.init();
		hero.enteringShip = -1;
		hero.invincible = true;
		
		collideBits = new flash.Vector(Block.all.length);
		var pos = -1;
		for( b in Block.all ) {
			pos++;
			if( !b.collide )
				continue;
			if( b.size == null )
				collideBits[pos] = 7;
			else {
				var x = b.size.x1 == 0 && b.size.x2 == 1;
				var y = b.size.y1 == 0 && b.size.y2 == 1;
				var z = b.size.z1 == 0 && b.size.z2 == 1;
				if( y && z )
					collideBits[pos] |= 1; // X
				if( x && z )
					collideBits[pos] |= 2; // Y
				if( x && y )
					collideBits[pos] |= 4; // Z
			}
		}
	}
	
	override function getDefaultDummyTime() {
		return 1800.; // 30 min
	}
	
	override function onChunk(x, y,bytes) {
		super.onChunk(x, y, bytes);
		checkShip();
	}
	
	inline function get(a) {
		return flash.Memory.getUI16(a << 1);
	}
	
	function getBlock(a) : Int {
		levelBytes.position = a << 1;
		return levelBytes.readUnsignedShort();
	}

	inline function set(a,v) {
		flash.Memory.setI16(a << 1,v);
	}
	
	function error( txt : String ) {
		interf.message(getText(txt),0xFF4040,0);
		shipValid = false;
	}
	
	static inline var AIR = 0xFFFF;
	static inline var NO_HULL = 0xFFFE;
	static inline var HULL = 0xFFFD;
	static inline var WALK = 0xFFFC;
	
	function checkHull( a : Int, dir : Int ) {
		var b = get(a);
		if( b >= HULL )
			return false;
		if( b == 0 ) {
			set(a, AIR);
			return true;
		}
		// this is only a partial fix, since this is the first match that will only be checked
		if( collideBits[b] & dir == 0 ) {
			set(a, AIR);
			return true;
		}
		var bd = Block.all[b];
		if( bd.matter.index != Type.enumIndex(BShipHull) ) {
			set(a, NO_HULL);
			return true;
		}
		set(a, HULL);
		return false;
	}
	
	inline function setHull( a : Int ) {
		var b = get(a);
		return if( b == 0 || b == AIR || b == HULL ) false else { set(a, HULL); true; };
	}
	
	function checkShip() {
		var t0 = flash.Lib.getTimer();
		var pos = null;
		var engines = [], computers = [], craft = [], craftOut = [];
		var c0 = level.cells[0][0];
		var sx = editInfos.size.x;
		var sy = editInfos.size.y;
		var sz = editInfos.size.z;
		lookup.position = 0;
		levelBytes = c0.t;
		lookup.writeBytes(c0.t, 0, Const.TSIZE * 2);
		flash.Memory.select(lookup);
		// lookup for ship entry
		for( x in 0...sx )
			for( y in 0...sy )
				for( z in 0...sz ) {
					var a = Const.addr(x + 2, y + 2, z + 1);
					var b = get(a);
					if( b == Type.enumIndex(BShipEntry) ) {
						if( pos != null ) {
							error("multiple_spawn");
							return;
						}
						pos = { x : x + 2, y : y + 2, z : z + 1, a : a };
					} else switch( b )  {
						case Type.enumIndex(BShipEngine):
							engines.push(a);
						case Type.enumIndex(BShipComputer):
							computers.push(a);
						case Type.enumIndex(BCrafter):
							craft.push(a);
						case Type.enumIndex(BCrafterComputer):
							craftOut.push(a);
						default:
					}
				}
		if( pos == null ) {
			error("no_spawn");
			return;
		}
		if( get(pos.a + Const.DZ) != 0 || get(pos.a + Const.DZ * 2) != 0 ) {
			error("no_spawn_air");
			return;
		}
		// check hull safety
		set(pos.a + Const.DZ, AIR);
		shipStart = pos;
		var changed;
		do {
			changed = false;
			for( x in 0...sx )
				for( y in 0...sy ) {
					var a = Const.addr(x + 2, y + 2, 1);
					for( z in 0...sz ) {
						var b = get(a);
						if( b < NO_HULL ) {
							a += Const.DZ;
							continue;
						}
						if( x == 0 || y == 0 || z == 0 || x == sx - 1 || y == sy - 1 || z == sz - 1 ) {
							error("hull_hole");
							return;
						}
						if( checkHull(a - Const.DX, 1) )
							changed = true;
						if( checkHull(a + Const.DX, 1) )
							changed = true;
						if( checkHull(a - Const.DY, 2) )
							changed = true;
						if( checkHull(a + Const.DY, 2) )
							changed = true;
						if( checkHull(a - Const.DZ, 4) )
							changed = true;
						if( checkHull(a + Const.DZ, 4) )
							changed = true;
						a += Const.DZ;
					}
				}
		} while( changed );
		// propagate total hull
		var changed;
		do {
			changed = false;
			for( x in 0...sx )
				for( y in 0...sy ) {
					var a = Const.addr(x + 2, y + 2, 1);
					for( z in 0...sz ) {
						if( get(a) != HULL ) {
							a += Const.DZ;
							continue;
						}
						if( setHull(a + Const.DX) )
							changed = true;
						if( setHull(a - Const.DX) )
							changed = true;
						if( setHull(a + Const.DY) )
							changed = true;
						if( setHull(a - Const.DY) )
							changed = true;
						if( setHull(a + Const.DZ) )
							changed = true;
						if( setHull(a - Const.DZ) )
							changed = true;
						a += Const.DZ;
					}
				}
		} while( changed );
		// total ship size
		var total = 0, air = 0, other = 0;
		for( x in 0...sx )
			for( y in 0...sy ) {
				var a = Const.addr(x + 2, y + 2, 1);
				for( z in 0...sz ) {
					switch( get(a) ) {
					case 0:
					case AIR: air++;
					case HULL: total++;
					default: other++;
					}
					a += Const.DZ;
				}
			}
		// calculate walk map
		walkRec(pos.a + Const.DZ);
		if( other > 0 ) {
			error("separate_part");
			return;
		}
		var engineCount = 0;
		for( e in engines )
			if( get(e - Const.DX) == 0 )
				engineCount++;
		if( engineCount == 0 ) {
			error( engines.length > 0 ? "need_engine_out" : "need_engine" );
			return;
		}
		
		if( engineCount < 2 ) {
			error("need_engines_min2");
			return;
		}
		
		if( total / engineCount > 70 ) {
			error("need_engines");
			return;
		}
		
		if( computers.length == 0 ) {
			error("need_computer");
			return;
		}
		if( craft.length == 0 ) {
			error("need_craft");
			return;
		}
		if( craftOut.length == 0 ) {
			error("need_craft_computer");
			return;
		}
		var sides = [Const.DX, -Const.DX, Const.DY, -Const.DY];
		function access(a) {
			return get(a) == WALK && getBlock(a) == 0;
		}
		if( !Lambda.exists(computers, function(c) return access(c+Const.DX) || access(c-Const.DX) || access(c+Const.DY) || access(c-Const.DY) || access(c-Const.DZ) || access(c+Const.DZ)) ) {
			error("access_computer");
			return;
		}
		if( !Lambda.exists(craft, function(c) return get(c + Const.DZ) == WALK) ) {
			error("access_craft");
			return;
		}
		if( !Lambda.exists(craftOut, function(c) return (get(c) == AIR || get(c) == WALK) && (access(c + Const.DX) || access(c - Const.DX) || access(c - Const.DY) || access(c + Const.DY) || access(c + Const.DZ))) ) {
			error("access_craft_computer");
			return;
		}
		shipValid = true;
		interf.message(getText("ship_valid",{ _speed : Const.shipSpeed(engineCount, total) }),0xFF00,0.5);
	}
	
	function walkRec(a, jump = 0) {
		// fall
		while( get(a - Const.DZ) == AIR )
			a -= Const.DZ;
		if( get(a) == WALK && get(a + Const.DZ) == WALK )
			return;
		set(a, WALK);
		set(a + Const.DZ, WALK);
		if( canWalk(a-Const.DX) )
			walkRec(a - Const.DX);
		if( canWalk(a + Const.DX) )
			walkRec(a + Const.DX);
		if( canWalk(a - Const.DY) )
			walkRec(a - Const.DY);
		if( canWalk(a + Const.DY) )
			walkRec(a + Const.DY);
		if( jump < 3 && get(a + Const.DZ * 2) == AIR )
			walkRec(a + Const.DZ, jump + 1);
	}
	
	function canWalk(a) {
		var b1 = get(a);
		var b2 = get(a + Const.DZ);
		if( b1 == AIR && b2 == AIR )
			return true;
		var b1 = Block.all[getBlock(a)];
		var b2 = Block.all[getBlock(a + Const.DZ)];
		var s1 = b1.index == 0 ? { z2 : 0. } : b1.size;
		var s2 = b2.index == 0 ? { z1 : 1. } : b2.size;
		if( s1 == null || s2 == null )
			return false;
		var space = s2.z1 + 1 - s1.z2;
		return space > 1.7;
	}
	
	override function getMiningPower() {
		return if( infos.debug ) 3 else super.getMiningPower();
	}
	
	override public function getJsApi():Dynamic {
		var o : Dynamic = super.getJsApi();
		o._returnShip = function() {
		};
		return o;
	}

	override function returnToShip(manual:Bool) {
		lock = true;
		if( shipChanged ) {
			if( !shipValid )
				ask("exit_ship_no_save", function(b) if( b ) api.send(CReturnGame) else lock = false);
			else
				api.send(CSaveShip(null,interf.inv));
		} else
			api.send(CReturnGame);
	}
	
	override function checkSelect()	{
		if( select == null )
			return;
		var size = editInfos.size;
		if( select.x <= 1 || select.y <= 1 || select.x > size.x+1 || select.y > size.y+1 || select.z <= 0 || select.z > size.z )
			select = null;
		if( select != null && select.b == null && interf.getCurrentBlock().propagate != null )
			select = null;
	}
	
	override function update() {
		super.update();
		
		if( mt.flash.Key.isDown(flash.ui.Keyboard.SHIFT) && mt.flash.Key.isToggled("R".code) ) {
			for( x in 0...editInfos.size.x )
				for( y in 0...editInfos.size.y )
					for( z in 0...editInfos.size.z ) {
						var b = level.get(x + 2, y + 2, z + 1);
						if( b != null )
							this.blockBreak(x + 2, y + 2, z + 1, b);
					}
		}
		
		if( hero.standingBlock != null && hero.standingBlock.k == BShipEntry && !api.isOffline() ) {
			if( hero.enteringShip >= 0 ) {
				hero.enteringShip += mt.Timer.tmod * 0.03;
				if( hero.enteringShip > 1 ) {
					lock = true;
					hero.enteringShip = -1;
					returnToShip(true);
				}
			}
		} else {
			if( hero.enteringShip > 0 )
				hero.enteringShip -= mt.Timer.tmod * .1;
			if( hero.enteringShip < 0 )
				hero.enteringShip = 0;
		}
		
		if( shipValid && level.getLightAt(shipStart.x, shipStart.y, shipStart.z + 1,1) == 0 ) {
			error("no_spawn_light");
			return;
		}
	}

}