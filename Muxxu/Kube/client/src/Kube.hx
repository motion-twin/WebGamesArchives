private typedef K = flash.ui.Keyboard;
import mt.flash.Key;
import Level.Block;
import Common;

class Texts extends haxe.xml.Proxy<"client.xml",String> {
}

typedef Position = {
	var px : Float;
	var py : Float;
	var pz : Float;
	var cx : Int;
	var cy : Int;
	var a : Float;
	var kind : Int;
	var swim : Null<Float>;
	var chk : String;
}

class Kube implements haxe.Public {

	static var ZOOM = 1.0;
	static var LQLTY = 1 / 2;
	static var BOUNDS = Level.XYSIZE >> 3;
	static var DEF_AZ = -0.15;
	static var CUR_SIGN = 8310507;

	var width : Int;
	var height : Int;
	var root : flash.display.DisplayObjectContainer;
	var level : Level;
	var render : Render;
	#if flash11
	var r3d : Render3D;
	#end
	var px : mt.flash.Volatile<Float>;
	var py : mt.flash.Volatile<Float>;
	var pz : mt.flash.Volatile<Float>;
	var cx : mt.flash.Volatile<Int>;
	var cy : mt.flash.Volatile<Int>;
	var angle : mt.flash.Volatile<Float>;
	var teleported : mt.flash.Volatile<Bool>;
	var bmpFull : flash.display.Bitmap;
	var bmpHalf : flash.display.Bitmap;
	var bytes : flash.utils.ByteArray;
	var needRedraw : Bool;
	var bmpPosition : Int;
	var levelPosition : Int;
	var bgPosition : Int;
	var save : flash.net.SharedObject;
	var build : Block;
	var select : { x : Int, y : Int, z : Int, b : Block };
	var mouse : { x : Int, y : Int, last : Int, lastAZ : Float };
	var gravity : mt.flash.Volatile<Float>;
	var watches : List<Watch>;
	var fatalFlag : Bool;
	var lock : Bool;
	var swimming : mt.flash.Volatile<Bool>;
	var events : List<Void -> Void>;
	var viewZ : mt.flash.Volatile<Float>;
	var protect : Array<{ x : Int, y : Int, z : Int, build : Block, old : Block }>;
	var interf : Interface;
	var lastSave : { x : Float, y : Float, need : Bool, lock : Bool };
	var saveLock : Bool;
	var bg : { mc : flash.display.Shape, lx : Int, ly : Int, col : Int };
	var zones : Hash<ZoneInfos>;
	var drag : { x : Int, y : Int, az : Float, dx : Int, dy : Int, active : Bool };
	var angleZ : Float;
	var recalAngleZ : Bool;
	var demo : Bool;
	var swimDistance : mt.flash.Volatile<Float>;
	var fadeFX : { t : Float, col : Int, speed : Float, dz : Float, done : Void -> Void };
	var connectionOccured : Bool;
	var texts : Texts;
	var walking : Bool;
	var hidePhoto : Bool;
	var tuto : Tuto;
	var standingBlock : BlockKind;
	var lastBlock : { x : Int, y : Int, z : Int, old : Block, build : Block };
	var pushPower : Float;
	var pendingBlocks : Array<Int>;
	var pendingCancel : Bool;
	var fullScreen : Bool;
	var showFPS : flash.text.TextField;

	public function new(root,w,h,htexts:Hash<String>) {
		demo = (DATA != null && DATA._replay != null);
		if( demo )
			w += Interface.WIDTH;
		w -= 20;
		h -= 20;
		w = Std.int(w / ZOOM);
		h = Std.int(h / ZOOM);
		if( htexts == null )
			htexts = new Hash();
		texts = new Texts(htexts.get);
		pushPower = 0.0;
		swimming = false;
		teleported = false;
		swimDistance = 0.0;
		viewZ = 1.5;
		angleZ = DEF_AZ;
		save = flash.net.SharedObject.getLocal("pos");
		var k : Position = save.data;
		var pow;
		if( DATA == null ) {
			if( Math.isNaN(k.px) ) {
				cx = 192;
				cy = 256;
				var mid = (Level.XYSIZE - 1) / 2;
				px = mid;
				py = mid;
				angle = 0.0;
			} else {
				cx = k.cx;
				cy = k.cy;
				px = k.px;
				py = k.py;
				angle = k.a;
				Level.FORCE = k.kind;
			}
			pow = GameConst.POWER * 100;
		} else {
			if( k.chk != makeCheck(k) )
				DATA._force = true;
			px = DATA._x / GameConst.PREC;
			py = DATA._y / GameConst.PREC;
			pz = DATA._z / GameConst.PREC;
			pow = DATA._pow;
			if( DATA._swim != null ) {
				swimming = true;
				swimDistance = DATA._swim / GameConst.PREC;
			}
			angle = k.a;
			if( Math.isNaN(angle) ) angle = 0;
			var rx = k.cx + k.px;
			var ry = k.cy + k.py;
			var dx = rx - px, dy = ry - py;
			if( Math.sqrt(dx*dx+dy*dy) < GameConst.SAVE_DIST && (k.swim == null || k.swim > swimDistance) && !DATA._force ) {
				px = rx;
				py = ry;
				pz = k.pz;
				if( k.swim != null ) {
					swimming = true;
					swimDistance = k.swim;
				}
			}
			cx = Std.int(px) - (Level.XYSIZE>>1);
			cy = Std.int(py) - (Level.XYSIZE>>1);
			px -= cx;
			py -= cy;
			if( demo ) {
				cx = 0;
				cy = 0;
				px = 128;
				py = 128;
			}
		}
		lastSave = { x : px + cx, y : py + cy, need : false, lock : false };
		this.root = root;
		this.level = new Level();
		if( this.level.sign != CUR_SIGN ) {
			if( DATA == null )
				throw "new sign "+this.level.sign;
			return;
		}
		this.width = w;
		this.height = h;
		gravity = 0;
		events = new List();
		protect = new Array();
		zones = new Hash();
		mouse = { x : 0, y : 0, last : 0, lastAZ : 0. };
		var fov = demo ? 80 : 60;
		render = new Render(level, fov * (Math.PI / 180));
		bmpFull = new flash.display.Bitmap(new flash.display.BitmapData(width,height,true,0));
		bmpFull.scaleX = ZOOM;
		bmpFull.scaleY = ZOOM;
		bmpHalf = new flash.display.Bitmap(new flash.display.BitmapData(Std.int(width*LQLTY),Std.int(height*LQLTY),true,0));
		bmpHalf.scaleX = ZOOM * width / bmpHalf.width;
		bmpHalf.scaleY = ZOOM * height / bmpHalf.height;
		bmpHalf.filters = [new flash.filters.BlurFilter(2.5,1.5,2)];
		bmpFull.filters = [new flash.filters.BlurFilter(1.5, 0.5, 3)];
		bg = {
			mc : new flash.display.Shape(),
			lx : 0xFFFFFF,
			ly : 0xFFFFFF,
			col : 0,
		};
		bg.mc.x = if( demo ) 10 else Interface.WIDTH + 10;
		bg.mc.y = if( demo ) 10 else 10;
		bmpFull.x = bmpHalf.x = bg.mc.x;
		bmpFull.y = bmpHalf.y = bg.mc.y;
		bg.mc.scaleX = bg.mc.scaleY = ZOOM;
		root.addChild(bg.mc);
		updateBgColor();
		root.addEventListener(flash.events.Event.ENTER_FRAME, update);
		root.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, function(e:flash.events.KeyboardEvent) if( e.keyCode == K.HOME || e.keyCode == K.ENTER ) toggleFullScreen());
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN,callback(click,false));
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP,callback(click,true));
		var me = this;
		var inv = (DATA == null) ? [] : DATA._inv;
		if( DATA == null ) {
			for( b in [BInvisible,BAmethyste,BEmeraude,BRubis,BSaphir,BFog,BShade,BLight,BLava] )
				inv[Type.enumIndex(b) + 1] = 5;
		}
		interf = new Interface(this);
		interf.init(inv,pow);
		interf.onBlockSelect = function(b) me.build = b;
		Codec.displayError = interf.logError;
		showFPS = new flash.text.TextField();
		showFPS.width = 200;
		showFPS.mouseEnabled = false;
		showFPS.visible = false;
		showFPS.textColor = 0xFFFFFF;
		showFPS.x = Interface.WIDTH + 10;
		showFPS.y = 10;
		root.addChild(showFPS);
		#if flash11
		r3d = new Render3D(this, fov);
		bmpHalf.visible = bmpFull.visible = bg.mc.visible = false;
		#end
		if( DATA == null ) {
			initLevel();
			initBytes();
			update(null);
		} else
			updateWatch();
	}

	var pingId : Int;
	var ping : Float;
	var max : Float;
	var errors : Int;
	var started : Bool;
	var nextPing : Null<Int> -> Void;
	function startPing() {
		if( demo || started ) return;
		started = true;
		var me = this;
		var pingStart = flash.Lib.getTimer();
		var pid = pingId++;
		nextPing = function(id) {
			if( id != pid ) {
				me.errors++;
			} else {
				var dt = flash.Lib.getTimer() - pingStart;
				if( Math.isNaN(me.ping) ) {
					me.ping = dt;
					me.max = dt;
				} else {
					me.ping = me.ping * 0.7 + 0.3 * dt;
					if( dt > me.max ) me.max = dt;
				}
			}
			haxe.Timer.delay(function() { me.started = false; me.startPing(); },200);
			var text = "PING#"+id+" "+Math.ceil(me.ping);
			text += " MAX "+me.max;
			if( me.errors > 0 ) text += " ERR "+me.errors;
			try untyped me.interf.js._setTuto.call([text]) catch( e : Dynamic ) {}
		};
		command(CPing(pid));
	}
	
	function toggleFullScreen() {
		fullScreen = !fullScreen;
		var stage = flash.Lib.current.stage;
		#if !flash11
		stage.fullScreenSourceRect = new flash.geom.Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		#else
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		#end
		stage.displayState = fullScreen ? flash.display.StageDisplayState.FULL_SCREEN_INTERACTIVE : flash.display.StageDisplayState.NORMAL;
		#if flash11
		r3d.setFullScreen(fullScreen);
		interf.bg.scaleX = fullScreen ? (stage.stageWidth - Interface.WIDTH) / interf.bg.width : 1.0;
		interf.bg.scaleY = fullScreen ? stage.stageHeight / interf.bg.height : 1.0;
		var mm = interf.minigfx;
		mm.root.y = mm.root.mask.y = stage.stageHeight - 188;
		mm.root.visible = fullScreen;
		if( fullScreen ) interf.forceUpdateMap();
		#end
	}

	function hasFlag(f) {
		return DATA != null && (DATA._flags & f) != 0;
	}

	function makeCheck( k : Position ) {
		var infos = [k.px,k.py,k.pz,k.cx,k.cy,k.swim];
		return haxe.Md5.encode(haxe.Serializer.run(infos)).substr(2,6);
	}

	public function getCurBgPosition() {
		return bgPosition - Std.int(bg.mc.y - 10) * 4;
	}

	function updateBgColor() {
		var lx = Std.int(px+cx)>>2;
		var dy = angleZ / (Math.PI / 2);
		if( dy < 0 ) dy = 0;
		bg.mc.y = (dy - 1) * height + 10;
		var ly = Std.int(py+cy)>>2;
		if( lx == bg.lx && ly == bg.ly )
			return;
		var tmp = new flash.display.BitmapData(1,1);
		var p = new flash.geom.Point(lx << 2,ly << 2);
		tmp.perlinNoise(512,512,4,156,false,true,7,false,[p,p,p,p]);
		var col : Int = tmp.getPixel(0,0);
		tmp.dispose();
		bg.lx = lx;
		bg.ly = ly;
		if( col == bg.col )
			return;
		var col2 = (col >> 1) & 0x7F7F7F;
		var g = bg.mc.graphics;
		var m = new flash.geom.Matrix();
		m.createGradientBox(width,height*2,Math.PI/2);
		g.clear();
		g.beginGradientFill(flash.display.GradientType.LINEAR,[col2,col,0xFFFFFF],null,[0,100,255],m);
		g.drawRect(0,0,width,height*2);
		g.endFill();
		bg.col = col;
		if( bgPosition != 0 )
			updateBgBits();
	}

	function updateBgBits() {
		var tmp = new flash.display.BitmapData(1,height*2);
		tmp.draw(bg.mc);
		var bgbytes = tmp.getVector(tmp.rect);
		tmp.dispose();
		var k = bgPosition;
		for( col in bgbytes ) {
			flash.Memory.setByte(k++,(col>>>24)&0xFF);
			flash.Memory.setByte(k++,(col>>16)&0xFF);
			flash.Memory.setByte(k++,(col>>8)&0xFF);
			flash.Memory.setByte(k++,col&0xFF);
		}
	}

	function getWatch(x,y) {
		for( w in watches )
			if( w.x == x && w.y == y )
				return w;
		return null;
	}

	function key(x:Int,y:Int) {
		return x+"/"+y;
	}

	inline function getZone(x,y) {
		return zones.get(key(x,y));
	}

	inline function getCurrentWatch( cur : Watch, px, py ) {
		var x = px >> GameConst.XYBITS;
		var y = py >> GameConst.XYBITS;
		return if( cur != null && cur.x == x && cur.y == y ) cur else getWatch(x,y);
	}

	function updateWatch() {
		var x0 = cx >> GameConst.XYBITS;
		var y0 = cy >> GameConst.XYBITS;
		if( watches == null )
			watches = new List();
		if( DATA == null )
			return;
		for( w in watches )
			w.updated = false;
		for( x in x0...x0+2 )
			for( y in y0...y0+2 ) {
				var w = getWatch(x,y);
				if( w != null ) {
					w.updated = true;
					continue;
				}
				w = new Watch(level,x,y);
				w.updated = true;
				watches.add(w);
				if( demo ) {
					var bytes = switch( key(x,y) ) {
					case key(0,0): DATA._replay._z0;
					case key(1,0): DATA._replay._z1;
					case key(0,1): DATA._replay._z2;
					case key(1,1): DATA._replay._z3;
					default:
						var b = new flash.utils.ByteArray();
						b.length = 1 << (GameConst.XYBITS * 2 + GameConst.ZBITS);
						for( x in 0...1<<GameConst.XYBITS )
							for( y in 0...1<<GameConst.XYBITS )
								b[level.addr(x,y,0)] = 1;
						b.compress();
						haxe.io.Bytes.ofData(b);
					}
					haxe.Timer.delay(callback(onMessage,AMap(x,y,bytes,null,[])),100);
				} else {
					var cmd : _Cmd = CWatch(x,y);
					w.waitAnswers++;
					w.proto = Codec.connect(DATA._s,cmd,callback(onWatchMessage,w));
					w.proto.onDisconnect = callback(onDisconnect,w);
				}
			}
		lock = false;
		for( w in watches ) {
			if( !w.updated ) {
				if( w.proto != null ) {
					if( w.waitAnswers == 0 ) {
						w.proto.close();
						watches.remove(w);
					} else
						w.waitClose = true;
				} else
					watches.remove(w);
			} else if( w.data == null )
				lock = true;
		}
		if( lock )
			interf.message(texts.loading_world);
		else
			interf.message();
	}

	function onWatchMessage( w : Watch, a : _Answer ) {
		switch( a ) {
		case ASet(_,_,_,_), ASetMany(_): // this is not an answer to one of our messages
		default: w.waitAnswers--;
		}
		onMessage(a);
		if( w.waitClose && w.waitAnswers == 0 ) {
			watches.remove(w);
			w.proto.close();
		}
	}

	function onDisconnect( w : Watch ) {
		if( w.data == null || w.waitAnswers > 0 ) {
			if( connectionOccured )
				interf.logError(texts.disconnect);
			else
				flash.Lib.getURL(new flash.net.URLRequest("/connectFail"),"_self");
			return;
		}
		watches.remove(w);
		updateWatch();
	}

	function gameStart() {
		interf.initMiniMap();
		initLevel();
		initBytes();
		lock = false;
		interf.message();
		update(null);
		if( tuto == null )
			tuto = new Tuto(this);
	}

	function onMessage( msg : _Answer ) {
		connectionOccured = true;
		switch( msg ) {
		case AMap(x,y,data,patches,zones):
			var bytes = data.getData();
			bytes.uncompress();
			var w = getWatch(x,y);
			w.data = haxe.io.Bytes.ofData(bytes);
			if( patches != null ) {
				var p = 0;
				while( p < patches.length ) {
					var x = patches.get(p++);
					var y = patches.get(p++);
					var z = patches.get(p++);
					var b = patches.get(p++);
					if( z == 0 ) break;
					w.data.set(level.addr(x,y,z),b);
				}
			}
			var zmax = 1 << (GameConst.XYBITS - GameConst.ZONEBITS);
			for( dx in 0...zmax )
				for( dy in 0...zmax )
					this.zones.set(key(w.x * zmax + dx,w.y * zmax + dy),zones.shift());
			w.initMap();
			for( w in watches )
				if( w.data == null )
					return;
			gameStart();
		case ASet(x,y,z,k):
			var w = getWatch(x >> GameConst.XYBITS,y >> GameConst.XYBITS);
			// received a bit too early...
			if( w != null && w.data == null )
				return;
			// update watch
			if( w != null && w.update(x - (w.x << GameConst.XYBITS),y - (w.y << GameConst.XYBITS),z,k) )
				interf.updateMinimap(x,y);
			// update level (if displayed)
			if( !level.outside(x - cx,y - cy,z) ) {
				level.set(levelPosition, x - cx, y - cy, z, level.blocks[k]);
				#if flash11
				r3d.updateKube(x - cx, y - cy, z);
				#end
				if( select != null && select.x == x - cx && select.y == y - cy && select.z == z )
					select.b = level.blocks[k];
				needRedraw = true;
			}
			// if a block was put next to the last kube, prevent undo (multiplayer undo hack)
			if( lastBlock != null && Math.abs(lastBlock.z-z)+Math.abs(lastBlock.x-x)+Math.abs(lastBlock.y-y) == 1 )
				lastBlock = null;
		case ASetMany(blocks):
			while( blocks.length > 0 ) {
				var x = blocks.shift();
				var y = blocks.shift();
				var z = blocks.shift();
				var b = blocks.shift();
				onMessage(ASet(x,y,z,b));
			}
		case AGenerate(x,y):
			addEvent(callback(generateLevel,getWatch(x,y)));
		case ARedirect(url):
			flash.Lib.getURL(new flash.net.URLRequest(url),"_self");
		case ANothing:
		case AMessage(msg,err):
			if( err )
				interf.warning(msg);
			else
				interf.notice(msg);
		case AValue(v):
			// ignore
		case AShowError(e):
			interf.logError(e);
		case APong(id):
			nextPing(id);
		case APosSaved:
			lastSave.lock = false;
		case ABlocks(blocks):
			for( bid in blocks ) {
				var p = protect.shift();
				if( bid == null ) {
					onMessage(ASet(p.x,p.y,p.z,(p.build == null)?0:Type.enumIndex(p.build.k)+1));
					checkBlockAfterPut(p);
				} else {
					onMessage(ASet(p.x,p.y,p.z,bid));
					if( p.build != null )
						interf.updateInventory(p.build,1);
					if( p.old != null )
						interf.updateInventory(p.old,-1);
					interf.power += GameConst.BLOCK_POWER;
				}
			}
			if( pendingBlocks != null ) {
				if( pendingBlocks.length > 0 ) {
					command(CSetBlocks(pendingBlocks));
					pendingBlocks = new Array();
				} else {
					pendingBlocks = null;
					if( pendingCancel ) {
						pendingCancel = false;
						cancelLastBlock();
					}
				}
			}
		}
	}

	function checkBlockAfterPut( p : { x : Int, y : Int, z : Int, build : Block, old : Block } ) {
		if( p.build == null ) return;
		var b = p.build.parent.k;
		switch( b ) {
		case BDolpart, BSaphir, BRubis, BEmeraude, BGold, BAmethyste, BShade, BLight, BTeleport, BMulticol, BMTwin, BCrate:
			var cur = null;
			while( true ) {
				p.x--;
				cur = getCurrentWatch(cur,p.x,p.y);
				if( cur.getBlock(p.x,p.y,p.z) != b ) {
					p.x++;
					break;
				}
			}
			while( true ) {
				p.y--;
				cur = getCurrentWatch(cur,p.x,p.y);
				if( cur.getBlock(p.x,p.y,p.z) != b ) {
					p.y++;
					break;
				}
			}
			while( p.z > 0 ) {
				p.z--;
				cur = getCurrentWatch(cur,p.x,p.y);
				if( cur.getBlock(p.x,p.y,p.z) != b ) {
					p.z++;
					break;
				}
			}
			if( isFilled(p.x,p.y,p.z,3,b) )
				command(CDoCheck(p.x,p.y,p.z));
		default:
		}
	}

	function isFilled( px : Int, py : Int, pz : Int, size : Int, k : BlockKind ) {
		if( DATA == null )
			return false;
		if( pz < 0 || pz + size > Level.ZSIZE )
			return false;
		var cur = null;
		for( x in px...px+size )
			for( y in py...py+size ) {
				cur = getCurrentWatch(cur,x,y);
				for( z in pz...pz+size )
					if( cur.getBlock(x,y,z) != k )
						return false;
			}
		return true;
	}

	function hasBlockAround( px : Int, py : Int, pz : Int ) {
		px -= cx;
		py -= cy;
		if( level.outside(px,py,pz) )
			return false;
		if( pz < Level.ZSIZE-1 && level.get(px,py,pz+1) != null )
			return true;
		if( pz > 1 && level.get(px,py,pz-1) != null )
			return true;
		for( x in px-1...px+2 )
			for( y in py-1...py+2 ) {
				if( level.outside(x,y,0) || (x == px && y == py) )
					continue;
				if( level.get(x,y,pz) != null )
					return true;
			}
		return false;
	}

	function mouseLock(b) {
		interf.lockButtons(b);
		if( b ) flash.ui.Mouse.hide(); else flash.ui.Mouse.show();
		#if flash11
		try root.stage.mouseLock = b catch( e : Dynamic ) {}
		#end
	}
	
	function startGameOver(reason) {
		if( fadeFX != null ) return;
		var color = switch( reason ) {
		case GOWater: 0x0000FF;
		case GOLava: 0xFF0000;
		}
		var me = this;
		fadeFX = { t : 0., speed : 1., dz : 0.2, col : color, done : function() {
			me.lock = true;
			if( DATA != null )
				haxe.Timer.delay(callback(me.command,CGameOver(reason)),1000);
		}};
	}

	function click(up,event) {
		if( demo )
			return;
		if( up ) {
			var old = drag;
			drag = null;
			if( old != null && old.active ) {
				mouseLock(false);
				return;
			}
		} else {
			drag = {
				x : Std.int(root.mouseX),
				y : Std.int(root.mouseY),
				dx : 0,
				dy : 0,
				az : 0.,
				active : false,
			};
			return;
		}
		if( lock || select == null )
			return;

		if( interf.power <= 0 ) {
			if( build == null && event != null && select.b.parent.k == BMessage ) {
				//pass
			} else {
				interf.warning(texts.cannot_act);
				return;
			}
		}

		var wait = 0;
		if( watches != null )
			for( w in watches )
				wait += w.waitAnswers;
		if( wait >= 10 || pendingCancel || (pendingBlocks != null && pendingBlocks.length/5 > 10) ) {
			interf.warning(texts.server_wait);
			return;
		}

		var s = select;
		var absX = s.x + cx, absY = s.y + cy, absZ = s.z;

		// before checking rights and only if not automatic remove
		if( build == null ) {
			if( tuto != null )
				tuto.touchKube(s.b.parent.k);
			switch( s.b.parent.k ) {
			case BDolmen:
				command(CActiveKube(absX,absY,absZ));
				return;
			case BMessage:
				if( event != null ) {
					command(CActiveKube(absX,absY,absZ));
					return;
				}
			default:
			}
		}

		var z = getZone(absX >> GameConst.ZONEBITS,absY >> GameConst.ZONEBITS);
		if( z != null && !((build == null) ? z._g : z._p) ) {
			interf.warning(texts.cant_edit_zone);
			return;
		}

		for( p in protect )
			if( p.x == absX && p.y == absY && p.z == absZ )
				return;

		var bridge = absZ == 1 && (z == null || z._u == null);

		if( build != null ) {
			if( bridge && !hasBlockAround(absX,absY,absZ) ) {
				interf.warning(texts.cant_put_on_water);
				return;
			}
			if( build.k != BFixed )
				for( dy in 0...2 ) {
					var z = s.z - (dy + 1);
					if( z > 0 && level.get(s.x,s.y,z) == BFixed && !hasFlag(GameConst.FLAG_ADMIN) ) {
						interf.warning(texts.fixed_block);
						return;
					}
				}
		}

		if( build == null ) {
			switch( s.b.parent.k ) {
			case BLava:
				if( !hasFlag(GameConst.FLAG_LAVA_P) ) {
					startGameOver(GOLava);
					return;
				}
			case BFixed:
				var can = (z != null && z._u != null && z._g) || hasFlag(GameConst.FLAG_ADMIN);
				if( !can ) {
					interf.warning(texts.take_fixed_block);
					return;
				}
			case BChest:
				command(CActiveKube(absX,absY,absZ));
				return;
			default:
			}
			if( !interf.updateInventory(s.b.parent,1) ) {
				interf.warning(texts.inv_full);
				return;
			}
		} else {
			switch( build.k ) {
			case BFixed:
				if( !hasFlag(GameConst.FLAG_ADMIN) ) {
					if( level.get(s.x-1,s.y,s.z) != BFixed && level.get(s.x+1,s.y,s.z) != BFixed &&
						level.get(s.x,s.y-1,s.z) != BFixed && level.get(s.x,s.y+1,s.z) != BFixed &&
						level.get(s.x,s.y,s.z-1) != BFixed && level.get(s.x,s.y,s.z+1) != BFixed ) {
						interf.warning(texts.put_fixed_block);
						return;
					}
				}
			default:
			}
			if( !interf.updateInventory(build,-1) ) {
				interf.warning(texts.inv_empty);
				return;
			}
		}
		interf.power -= GameConst.BLOCK_POWER;
		level.set(levelPosition, s.x, s.y, s.z, build);
		#if flash11
		r3d.updateKube(s.x,s.y,s.z);
		#end
		needRedraw = true;
		select = null;
		if( DATA == null )
			return;
		var old = (s.b == null) ? null : s.b.parent;
		lastBlock = {
			x : absX,
			y : absY,
			z : absZ,
			build : build,
			old : old,
		};
		protect.push(lastBlock);
		var bindex = function(b:Block) return (b == null) ? 0 : Type.enumIndex(b.k) + 1;
		var infos = [absX,absY,absZ,bindex(old),bindex(build)];
		if( pendingBlocks != null ) {
			for( i in infos )
				pendingBlocks.push(i);
		} else {
			command(CSetBlocks(infos));
			pendingBlocks = new Array();
		}
	}

	function cancelLastBlock() {
		var last = lastBlock;
		if( last == null ) return;
		if( pendingBlocks != null ) {
			if( pendingCancel )
				interf.warning(texts.server_wait);
			pendingCancel = true;
			return;
		}
		lastBlock = null;
		protect.push(last);
		command(CUndo);
	}

	function command( cmd : _Cmd ) {
		var proto = null;
		for( w in watches )
			if( w.proto != null && !w.waitClose ) {
				w.waitAnswers++;
				proto = w.proto;
				break;
			}
		Codec.send(proto,DATA._s,cmd);
	}

	function addEvent( f : Void -> Void ) {
		events.add(f);
		if( events.length == 1 )
			haxe.Timer.delay(nextEvent,100);
	}

	function nextEvent() {
		var e = events.pop();
		if( e == null ) return;
		e();
	}

	function generateLevel( w : Watch ) {
		var g = new Generator(DATA._u);
		var t = g.generate(w.x * Level.XYSIZE,w.y * Level.XYSIZE);
		level.init(t);
		var bytes = new flash.utils.ByteArray();
		bytes.writeBytes(level.t);
		bytes.compress();
		var bytes = haxe.io.Bytes.ofData(bytes);
		var me = this;
		command(CGenLevel(w.x,w.y,bytes));
		haxe.Timer.delay(nextEvent,100);
	}

	function initLevel() {
		if( DATA == null ) {
			level.init(new Generator(0).generate(cx,cy));
			level.updateShades(0);
			recallZ(0);
			return;
		}
		var t = new flash.utils.ByteArray();
		t.length = Level.XYSIZE * Level.XYSIZE * Level.ZSIZE;
		// copy from zones data
		var cur = null;
		for( x in 0...Level.XYSIZE )
			for( y in 0...Level.XYSIZE ) {
				var px = x + cx;
				var py = y + cy;
				var w = getCurrentWatch(cur,px,py);
				if( w != cur ) {
					if( w == null )
						throw "Missing watch";
					flash.Memory.select(w.data.getData());
					cur = w;
				}
				var a0 = level.addr(px - (cur.x << GameConst.XYBITS),py - (cur.y << GameConst.XYBITS),0);
				var a1 = level.addr(x,y,0);
				for( z in 0...Level.ZSIZE ) {
					t[a1] = flash.Memory.getByte(a0);
					a0 += 1 << Level.Z;
					a1 += 1 << Level.Z;
				}
			}
		flash.Memory.select(t);
		level.t = t;
		level.updateShades(0);
		recallZ(Std.int(pz));
	}

	function initBytes() {
		bytes = new flash.utils.ByteArray();
		bytes.endian = flash.utils.Endian.BIG_ENDIAN; // used for setPixels()
		bytes.writeBytes(level.tbytes);
		levelPosition = bytes.length;
		bytes.writeBytes(level.t);
		bmpPosition = bytes.length;
		bytes.length += width * height * 4;
		bgPosition = bytes.length;
		bytes.length += height * 2 * 4;
		flash.Memory.select(bytes);
		updateBgBits();
		level.forceScroll();
		#if flash11
		r3d.initKubes();
		#end
		needRedraw = true;
	}

	function recallZ(h:Int) {
		var ix = Std.int(px);
		var iy = Std.int(py);
		if( h < 0 ) h = 1;
		while( level.has(ix,iy,h) )
			h++;
		while( h > 1 && !level.has(ix,iy,h-1) )
			h--;
		pz = h;
	}

	inline function maxSwimDistance() {
		return (hasFlag(GameConst.FLAG_SWIMSUIT) ? GameConst.SWIM_SUIT_MULT : 1.0) * GameConst.SWIM_MAX_DIST;
	}

	function doTeleport(x,y,z) {
		var found = new Array();
		for( d in 1...32*3 ) {
			if( level.getOpt(x+d,y,z) == BTeleport )
				found.push({ x : d, y : 0, z : 0, a : 0. });
			if( level.getOpt(x-d,y,z) == BTeleport )
				found.push({ x : -d, y : 0, z : 0, a : 0. });
			if( level.getOpt(x,y+d,z) == BTeleport )
				found.push({ x : 0, y : d, z : 0, a : 0. });
			if( level.getOpt(x,y-d,z) == BTeleport )
				found.push({ x : 0, y : -d, z : 0, a : 0. });
			if( level.getOpt(x,y,z-d) == BTeleport )
				found.push({ x : 0, y : 0, z : -d, a : 0. });
			if( level.getOpt(x,y,z+d) == BTeleport )
				found.push({ x : 0, y : 0, z : d, a : 0. });
		}
		for( f in found.copy() )
			if( level.has(x+f.x,y+f.y,z+1) || level.has(x+f.x,y+f.y,z+2) )
				found.remove(f);
		if( found.length == 0 ) {
			interf.warning(texts.cant_teleport);
			return;
		}
		angle %= Math.PI * 2;
		if( angle < -Math.PI )
			angle += Math.PI * 2;
		if( angle > Math.PI )
			angle -= Math.PI * 2;
		for( f in found ) {
			if( f.z != 0 ) {
				f.a = Math.PI * 2 + Math.abs(f.z);
				continue;
			}
			var a = (Math.atan2(f.y,f.x) - this.angle) % (Math.PI * 2);
			if( a < -Math.PI )
				a += Math.PI * 2;
			if( a > Math.PI )
				a -= Math.PI * 2;
			f.a = Math.abs(a);
		}
		found.sort(function(f1,f2) {
			return (f1.a == f2.a) ? (f1.x*f1.x + f1.y*f1.y) - (f2.x*f2.x + f2.y*f2.y) : ((f1.a > f2.a)?1:-1);
		});
		var target = found[0];
		var me = this;
		fadeFX = {
			t : 0.,
			speed : 6.,
			dz : 1.0,
			col : 0x808080,
			done : function() {
				me.px = target.x + x + 0.5;
				me.py = target.y + y + 0.5;
				me.pz = target.z + z + 0.01;
				me.teleported = true;
			},
		};
	}

	function doMove( dt : Float, speed : Float, strafe : Float ) {
		if( demo ) {
			gravity -= dt;
			if( gravity <= 0 ) {
				var ray = 5;
				var d = (1 << (GameConst.XYBITS - 1)) + ray;
				var px, py;
				do {
					px = Std.random(512 - d*2) + d;
					py = Std.random(512 - d*2) + d;
					var w = getWatch(px >> GameConst.XYBITS,py >> GameConst.XYBITS);
					var map = w.topMap.get(level.addr(px&(Level.XYSIZE-1),py&(Level.XYSIZE-1),0));
					if( map != Type.enumIndex(BWater)+1 )
						break;
				} while( true );
				cx = 0;
				cy = 0;
				angle = Std.random(Math.ceil(Math.PI*2*1000)) / 1000;
				this.px = px - Math.cos(angle) * ray;
				this.py = py - Math.sin(angle) * ray;
				pz = 0;
				gravity += 50;
				needRedraw = true;
			}
			angleZ = 0;
			recalAngleZ = false;
			return;
		}
		pz -= gravity * dt;

		// update angle with strafe
		var a = angle;
		if( speed != 0 || strafe != 0 ) {
			var s = Math.sqrt(speed*speed+strafe*strafe);
			a += Math.atan2(strafe / s,speed / s);
			speed = s;
			lastBlock = null;
		}

		// foot collide points
		var foots = new Array();
		for( da in [0,Math.PI*2/3,-Math.PI*2/3] )
			foots.push({ ix : Std.int(px + Math.cos(a+da)*0.1), iy : Std.int(py + Math.sin(a+da)*0.1) });

		// head collision
		if( gravity < 0 ) {
			if( pz > Level.ZSIZE - 1.5 ) {
				pz = Level.ZSIZE - 1.5;
				gravity = -gravity;
			} else {
				var found = false;
				var iz = Std.int(pz+1.5);
				for( f in foots )
					if( level.has(f.ix,f.iy,iz) ) {
						found = true;
						break;
					}
				if( found ) {
					pz = iz - 1.5;
					gravity = -gravity;
				}
			}
		}

		// foot collision
		var col = false;
		for( f in foots )
			if( level.has(f.ix,f.iy,Std.int(pz-0.01)) ) {
				col = true;
				break;
			}

		if( !col ) {
			standingBlock = null;
			gravity += 0.03 * dt;
			if( gravity > 0.9 ) gravity = 0.9;
		} else {
			// recall foots
			var h = Std.int(pz);
			while( true ) {
				var found = false;
				for( f in foots )
					if( level.has(f.ix,f.iy,h) ) {
						found = true;
						break;
					}
				if( !found ) break;
				h++;
			}
			pz = h;
			var old = swimming;
			var feet = level.get(Std.int(px),Std.int(py),h-1);
			if( feet != null )
				swimming = (feet == BWater);
			if( !swimming )
				swimDistance = 0;
			if( feet != standingBlock ) {
				standingBlock = feet;
				if( feet == BTeleport )
					doTeleport(Std.int(px),Std.int(py),h-1);
			}
			gravity = 0;
			if( (Key.isToggled(K.SPACE) || Key.isToggled(K.CONTROL) || pushPower > 1.4) && interf.power > 0 && fadeFX == null ) {
				if( swimDistance < maxSwimDistance() )
					gravity = swimming ? -0.35 : -0.27;
				pushPower = 0;
			}
			if( feet == BLava && !hasFlag(GameConst.FLAG_LAVA_P) )
				startGameOver(GOLava);
			if( feet == BJump && gravity >= 0 )
				gravity = -0.7;
		}

		// move
		var dist = speed * dt;
		var ox = px, oy = py;
		px += dist * Math.cos(a);
		py += dist * Math.sin(a);
		if( swimming ) {
			swimDistance += dist;
			var max = maxSwimDistance();
			if( swimDistance > max ) {
				swimDistance = max;
				if( gravity == 0 )
					startGameOver(GOWater);
			}
		}

		// enable small recal
		if( dist == 0 ) dist = 0.01;

		// recall position
		var s = null;
		var old = pushPower;
		for( dz in swimming ? [0,0.5,0.9] : (walking ? [-0.2,0,0.5,1,1.3] : [0,0.5,1,1.3]) ) {
			var iz = Std.int(pz + dz);
			if( select != null && select.b == null && select.z == iz )
				s = select;
			var recal = 20;
			while( --recal > 0 ) {
				var r = false;
				for( k in 0...16 ) {
					var a2 = a + ((k & 1) * 2 - 0.99) * (k >> 1) * Math.PI / 8;
					var px2 = px + Math.cos(a2) * 0.45, py2 = py + Math.sin(a2) * 0.45;
					var ix = Std.int(px2);
					var iy = Std.int(py2);
					if( level.has(ix,iy,iz) == (dz < 0) )
						continue;
					px -= Math.cos(a2) * dist / 20;
					py -= Math.sin(a2) * dist / 20;
					pushPower += dist / 20;
					r = true;
				}
				if( !r ) break;
			}
		}
		ox -= px;
		oy -= py;
		dist = Math.sqrt(ox*ox+oy*oy);

		if( walking || pushPower == old || dist > speed * dt * 0.5 )
			pushPower = 0;
	}

	function savePosition(move) {
		var dx = (px + cx) - lastSave.x;
		var dy = (py + cy) - lastSave.y;
		var dist = Math.sqrt(dx*dx+dy*dy);
		if( dist > GameConst.SAVE_DIST )
			lastSave.need = true;
		if( !lastSave.need ) {
			if( move && !swimming )
				return;
			if( Std.random(30) != 0 )
				return;
		}
		angle = angle % (Math.PI * 2);
		var pos : Position = {
			px : px,
			py : py,
			pz : pz,
			cx : cx,
			cy : cy,
			a : angle,
			kind : Level.FORCE,
			swim : swimming ? swimDistance : null,
			chk : null,
		};
		pos.chk = makeCheck(pos);
		for( f in Reflect.fields(pos) )
			save.setProperty(f,Reflect.field(pos,f));
		if( lastSave.need && !lastSave.lock ) {
			lastSave = { x : px + cx, y : py + cy, need : false, lock : true };
			if( DATA != null ) {
				var me = this;
				var px = Std.int(lastSave.x*GameConst.PREC);
				var py = Std.int(lastSave.y*GameConst.PREC);
				var pz = Std.int(pz*GameConst.PREC);
				var s = swimming ? Std.int(swimDistance * GameConst.PREC) : null;
				command((teleported?CTeleport:CSavePos)(px,py,pz,s));
			}
		}
	}

	function update(_) {
		if( fullScreen && root.stage.displayState == flash.display.StageDisplayState.NORMAL )
			toggleFullScreen();
		
		mt.Timer.update();
		if( lock )
			return;

		// basic controls
		var speed = 0.;
		var move = false, strafe = 0.;
		if( Key.isDown(K.RIGHT) || Key.isDown("D".code) || Key.isDown(K.NUMPAD_4) ) {
			if( drag != null && drag.active )
				strafe += 0.15;
			else
				angle += 0.04 * mt.Timer.tmod;
			move = true;
		}
		if( Key.isDown(K.LEFT) || Key.isDown("A".code) || Key.isDown("Q".code) || Key.isDown(K.NUMPAD_6) ) {
			if( drag != null && drag.active )
				strafe -= 0.15;
			else
				angle -= 0.04 * mt.Timer.tmod;
			move = true;
		}
		if( Key.isDown(K.UP) || Key.isDown("W".code) || Key.isDown("Z".code) || Key.isDown(K.NUMPAD_8) ) {
			speed += 0.15;
			move = true;
			recalAngleZ = true;
		} else
			pushPower = 0.0;
		if( Key.isDown(K.DOWN) || Key.isDown("S".code) || Key.isDown(K.NUMPAD_2) ) {
			speed -= 0.15;
			move = true;
			recalAngleZ = true;
		}
		if( Key.isToggled(K.ESCAPE) || Key.isToggled(K.TAB) )
			interf.defaultAction();
		if( Key.isToggled("P".code) && hasFlag(GameConst.FLAG_PHOTO_4X) ) {
			hidePhoto = !hidePhoto;
			interf.notice(hidePhoto ? texts.hide_photo_on : texts.hide_photo_off);
		}
		if( Key.isToggled("U".code) && lastBlock != null )
			cancelLastBlock();
		if( Key.isToggled("T".code) && hasFlag(GameConst.FLAG_ADMIN) )
			startPing();
		if( Key.isToggled("F".code) )
			showFPS.visible = !showFPS.visible;

		// remove previous selection
		var prev = select;
		#if !flash11
		if( select != null )
			level.set(levelPosition,select.x,select.y,select.z,select.b);
		#end
	
		// update position
		walking = gravity == 0 && Key.isDown(K.SHIFT);
		if( swimming || walking ) {
			speed *= 0.3;
			strafe *= 0.3;
		}
		if( interf.power == 0 && (speed != 0 || strafe != 0) ) {
			interf.warning(texts.cannot_act);
			speed = strafe = 0;
		}
		if( fadeFX != null ) {
			speed = strafe = 0;
			fadeFX.t += mt.Timer.tmod * fadeFX.speed / 100;
			move = true;
			needRedraw = true;
			if( fadeFX.t > 1.0 ) {
				fadeFX.t = 1.0;
				var done = fadeFX.done;
				fadeFX = null;
				done();
				return;
			}
		}

		var k = Math.ceil(mt.Timer.tmod * 10);
		var dt = mt.Timer.tmod / k;
		if( gravity != 0 )
			move = true;
		for( i in 0...k )
			doMove(dt,speed,strafe);
		if( gravity != 0 )
			move = true;
		if( demo )
			move = false;

		// recall view zone
		var mid = Level.XYSIZE >> 1;
		var update = false;
		while( px < mid - BOUNDS ) {
			cx -= BOUNDS;
			px += BOUNDS;
			update = true;
		}
		while( px > mid + BOUNDS ) {
			cx += BOUNDS;
			px -= BOUNDS;
			update = true;
		}
		while( py < mid - BOUNDS ) {
			cy -= BOUNDS;
			py += BOUNDS;
			update = true;
		}
		while( py > mid + BOUNDS ) {
			cy += BOUNDS;
			py -= BOUNDS;
			update = true;
		}

		// special keys
		if( DATA == null ) {
			if( mt.flash.Key.isToggled(K.F1) ) {
				var tags = new flash.Vector(256);
				tags[Type.enumIndex(BWater)] = true;
				haxe.Log.setColor(0xFF0000);
				haxe.Log.trace(Generator.KINDS[Level.FORCE],null);
				for( x in 0...Level.XYSIZE )
					for( y in 0...Level.XYSIZE )
						for( z in 0...Level.ZSIZE ) {
							var b = level.get(x,y,z);
							if( b == null || tags[Type.enumIndex(b)] ) continue;
							haxe.Log.trace(Type.enumConstructor(b),null);
							tags[Type.enumIndex(b)] = true;
						}
			}
			if( mt.flash.Key.isToggled(K.F2) ) {
				if( Level.FORCE == null )
					Level.FORCE = 0;
				else {
					Level.FORCE++;
					Level.FORCE %= Generator.KINDS.length;
				}
				update = true;
				haxe.Log.clear();
			}
			if( mt.flash.Key.isToggled(K.F3) )
				for( b in 0...Type.getEnumConstructs(BlockKind).length )
					interf.updateInventory(level.blocks[b+1],10);
		}

		// do we need to regen the level ?
		if( update ) {
			updateWatch();
			if( lock ) return;
			initLevel();
			initBytes();
			select = null;
		}

		if( DATA != null && !demo )
			interf.updateInfos();

		// scroll textures
		if( !demo && level.updateTextures() ) {
			needRedraw = true;
			#if flash11
			r3d.updateTextures();
			#end
		}

		// update point-of-view
		var targetZ = swimming ? ((gravity < 0) ? 0.9 : 0.2) : 1.5;
		if( fadeFX != null )
			targetZ -= fadeFX.t * fadeFX.dz;
		if( viewZ != targetZ ) {
			var p = Math.pow((viewZ < targetZ) ? 0.8 : 0.9,mt.Timer.tmod);
			viewZ = viewZ * p + targetZ * (1-p);
			if( Math.abs(viewZ-targetZ) < 0.01 )
				viewZ = targetZ;
			move = true;
		}

		// update drag-n-view
		if( recalAngleZ && angleZ != DEF_AZ ) {
			angleZ -= DEF_AZ;
			angleZ = angleZ * Math.pow(0.8,mt.Timer.tmod);
			move = true;
			if( Math.abs(angleZ) < 0.0001 )
				angleZ = 0;
			angleZ += DEF_AZ;
		}
		if( drag != null ) {
			var dx = Std.int(root.mouseX - drag.x);
			var dy = Std.int(root.mouseY - drag.y);
			if( !drag.active ) {
				drag.active = Math.sqrt(dx*dx+dy*dy) > 10;
				if( drag.active ) {
					mouseLock(true);
					drag.az = angleZ;
				}
			}
			if( drag.active ) {
				recalAngleZ = false;
				drag.x += dx;
				angle += dx / 100.0;
				angleZ = drag.az - dy / 100.0;
				var amax = Math.PI / 2.01;
				if( angleZ < -amax )
					angleZ = -amax;
				else if( angleZ > amax )
					angleZ = amax;
				if( dx != drag.dx || dy != drag.dy ) {
					move = true;
					drag.dx = dx;
					drag.dy = dy;
				}
			}
		}

		// select render bitmap
		var bmp, other;
		var doSave = false;
		if( move ) {
			updateBgColor();
			bmp = bmpHalf;
			other = bmpFull;
			needRedraw = true;
		} else {
			bmp = bmpFull;
			other = bmpHalf;
			move = needRedraw;
			needRedraw = false;
		}
		var b = bmp.bitmapData;

		// save position
		if( !demo )
			savePosition(move);

		// point of view
		var px = px - Math.cos(angle) * 0.44;
		var py = py - Math.sin(angle) * 0.44;
		var pz = pz + viewZ;
		if( pz >= Level.ZSIZE ) {
			viewZ = Level.ZSIZE - (pz + 0.001);
			pz = this.pz + viewZ;
		}

		// update selection
		var mx = Std.int(root.stage.mouseX);
		var my = Std.int(root.stage.mouseY);
		var mcur = level.addr(Std.int(px),Std.int(py),Std.int(pz));
		if( mouse.x != mx || mouse.y != my || mouse.last == mcur || mouse.lastAZ != angleZ ) {
			mouse.x = mx;
			mouse.y = my;
			mouse.last = mcur;
			mouse.lastAZ = angleZ;
			var mx = Std.int(bmp.mouseX), my = Std.int(bmp.mouseY);
			if( mx < 0 || (drag != null && drag.active) )
				select = null;
			else
				#if flash11
				select = r3d.pick(px, py, pz, build != null);
				#else
				select = render.pick(levelPosition, b.width, b.height, px, py, pz, angle, mx, my, angleZ, build != null);
				#end
		} else {
			mouse.last = -1;
			select = null;
		}
		if( demo || fadeFX != null )
			select = null;
		if( select != null ) {
			var dx = this.px - select.x, dy = this.py - select.y, dz = this.pz - select.z;
			var ix = Std.int(this.px), iy = Std.int(this.py), iz = Std.int(this.pz);
			if( Math.sqrt(dx*dx+dy*dy+dz*dz) > 6 || select.z == 0
				|| (select.x == ix && select.y == iy && (select.z == iz || select.z == iz + 1))
			)
				select = null;
		}
		if( select != null ) {
			var b = if( build != null ) build else select.b;
			var bs = level.bselect;
			bs.k = b.k;
			bs.tlr = b.tlr;
			bs.tu = b.tu;
			bs.td = b.td;
			bs.shadeUp = b.shadeUp + 128;
			bs.shadeDown = b.shadeDown + 128;
			bs.shadeX = b.shadeX + 128;
			bs.shadeY = b.shadeY + 128;
			#if !flash11
			level.set(levelPosition, select.x, select.y, select.z, level.bselect);
			#end
		}

		if( (prev == null) != (select == null) || (select != null && level.addr(prev.x,prev.y,prev.z) != level.addr(select.x,select.y,select.z)) )
			needRedraw = true;

		// redraw
		if( move || needRedraw ) {
			#if !flash11
			render.render(bmpPosition, levelPosition, getCurBgPosition(), (bmp == bmpHalf)?3:2, b.width, b.height, px, py, pz, angle, angleZ);
			#else
			r3d.render(px,py,pz,angle,angleZ);
			#end
			bytes.position = bmpPosition;
			b.setPixels(b.rect,bytes);
		}
		
		#if flash11
		if( showFPS.visible )
			showFPS.text = r3d.driverName()+" "+Std.int(r3d.triCount/1000) + ".KTri @" + (Std.int(mt.Timer.fps()*10)/10) + " fps";
		#end

		if( fadeFX != null ) {
			var bmp = b;
			var t = fadeFX.t;
			var r = (fadeFX.col >> 16) * t / 255.0;
			var g = ((fadeFX.col >> 8) & 0xFF) * t / 255.0;
			var b = (fadeFX.col & 0xFF) * t / 255.0;
			bmp.colorTransform(bmp.rect,new flash.geom.ColorTransform(1+r*2,1+g*2,1+b*2,1,r*50,g*50,b*50,0));
		}

		if( bmp.parent == null ) {
			if( other.parent != null ) root.removeChild(other);
			root.addChildAt(bmp,1);
		}

		if( tuto != null ) tuto.update();
	}

	static var inst : Kube;
	static var DATA : GameData;

	static function checkVersion() {
		var vreg = ~/^[^ ]+ ([0-9]+),([0-9]+),([0-9]+)/;
		if( !vreg.match(flash.system.Capabilities.version) )
			return true;
		var maj = Std.parseInt(vreg.matched(1));
		var min = Std.parseInt(vreg.matched(2));
		var build = Std.parseInt(vreg.matched(3));
		var v = maj * 1000 * 1000 + min * 1000 + build;
		return v > 10000012; // 10.0.12
	}

	static function main() {
		Codec.VERSION = GameConst.VERSION;
		if( !checkVersion() ) {
			flash.Lib.getURL(new flash.net.URLRequest("/help?fplayer=1#fplayer"),"_self");
			return;
		}
		var stage = flash.Lib.current.stage;
		if( stage.stageWidth <= 0 ) {
			haxe.Timer.delay(main,1);
			return;
		}
		var k = 0;
		var texts : Hash<String> = null;
		try k = haxe.Unserializer.run(flash.Lib.current.loaderInfo.parameters.k) catch( e : Dynamic ) {};
		if( k != 654 ) {
			DATA = Codec.getData("data");
			var tstr = flash.Lib.current.loaderInfo.parameters.texts;
			if( tstr != null ) texts = haxe.Unserializer.run(tstr);
		}
		#if (debug && !flash11)
		ZOOM *= 2;
		#end
		mt.Timer.maxDeltaTime = 10;
		mt.Timer.tmod_factor = 0.9;
		var root = new flash.display.MovieClip();
		flash.Lib.current.addChild(root);
		var mc = new flash.display.Sprite();
		root.addChild(mc);
		inst = new Kube(mc,stage.stageWidth - Interface.WIDTH,stage.stageHeight,texts);
		mt.flash.Key.init();
		mt.flash.Key.enableJSKeys("kube");
	}

}
