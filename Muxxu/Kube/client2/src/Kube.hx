private typedef K = flash.ui.Keyboard;
import mt.flash.Key;
import Level.Block;
import Common;

class Texts extends haxe.xml.Proxy<"client.xml",String> {
}

class Kube implements haxe.Public {

	var width : Int;
	var height : Int;
	var root : flash.display.DisplayObjectContainer;
	var level : Level;
	var process : Process;
	var r3d : Render3D;
	var needRedraw : Bool;
	var build : Block;
	var select : { x : Int, y : Int, z : Int, b : Block };
	var selectPower : Float;
	var fatalFlag : Bool;
	var lock : Bool;
	var events : List<Void -> Void>;
	var protect : Array<{ x : Int, y : Int, z : Int, build : Block, old : Block }>;
	var interf : Interface;
	
	var drag : { x : Int, y : Int, az : Float, dx : Int, dy : Int, active : Bool };
	var fadeFX : { t : Float, col : Int, speed : Float, dz : Float, done : Void -> Void };
	var connectionOccured : Bool;
	var texts : Texts;
	var pendingBlocks : Array<Int>;
	var pendingCancel : Bool;
	var fullScreen : Bool;
	var showFPS : flash.text.TextField;
	
	var hero : Hero;
	
	var planetSize : Int;
	var sunPower : Int;
	var time : Float;
	var bgColor : Int;
	var waterLevel : Int;
	var animWater : { width : Float, scale : Float, speed : Float };
	
	var dummies : Array<Dummy>;

	public function new(root, w, h, htexts:Hash<String>) {
		inst = this;
		
		var planetSeed = 8;
		var climate = 0;
		planetSize = 128 * 2;
		bgColor = 0x5D55D2;
		animWater = { width : 0.5, scale : 0.3, speed : 0.5 };
		sunPower = 10;
		waterLevel = 32;
		
		var inv = (DATA == null) ? [] : DATA._inv;
		if( DATA == null ) {
			for( b in [BLight] )
				inv[Type.enumIndex(b) + 1] = 5;
		}
	
		mt.Timer.tmod_factor = 0.98;
		
		time = 0;
		selectPower = 0;
		this.root = root;
		this.level = new Level(planetSize >> Const.BITS);
		this.width = w;
		this.height = h;
		if( htexts == null ) htexts = new Hash();
		texts = new Texts(htexts.get);
		dummies = new Array();
		process = new Process(this);
		hero = new Hero();
		events = new List();
		protect = new Array();
		r3d = new Render3D(this);

		root.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, function(e:flash.events.KeyboardEvent) if( e.keyCode == K.HOME || e.keyCode == K.ENTER ) toggleFullScreen());
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN,callback(click,false));
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, callback(click, true));
		
		interf = new Interface(this);
		interf.init(inv);
		interf.onBlockSelect = function(b) build = b;
		
		showFPS = new flash.text.TextField();
		showFPS.width = 200;
		showFPS.mouseEnabled = false;
		showFPS.visible = false;
		showFPS.textColor = 0xFFFFFF;
		showFPS.x = 10;
		showFPS.y = 10;
		showFPS.filters = [new flash.filters.GlowFilter(0, 1, 2, 2, 10)];
		root.addChild(showFPS);
		
		if( DATA == null ) {
			var gen = new gen.Generator(planetSize, Const.ZSIZE, planetSeed);
			waterLevel = gen.generate(climate);
			var gt = gen.getBytes();
			var blocks = [BFixed, BWater, BSoilTree];
			var bids = new flash.Vector<Int>();
			bids.push(0);
			for( b in blocks )
				bids.push(Type.enumIndex(b) + 1);
			for( gx in 0...planetSize >> Const.BITS )
				for( gy in 0...planetSize >> Const.BITS ) {
					var t = new flash.utils.ByteArray();
					t.length = Const.TSIZE * 2;
					flash.Memory.select(t);
					var write = 0;
					for( y in 0...Const.SIZE ) {
						var read = (gx * Const.SIZE + (gy * Const.SIZE + y) * planetSize) * Const.ZSIZE;
						for( i in 0...Const.SIZE * Const.ZSIZE ) {
							flash.Memory.setI16(write, bids[gt[read++]]);
							write += 2;
						}
					}
					level.add(gx, gy, t);
				}
			if( !hero.flying )
				hero.recallZ(waterLevel);
		}
				
		needRedraw = true;
		update(null);
		root.addEventListener(flash.events.Event.ENTER_FRAME, update);
	}

	var pingId : Int;
	var ping : Float;
	var max : Float;
	var errors : Int;
	var started : Bool;
	var nextPing : Null<Int> -> Void;
	function startPing() {
		if( started ) return;
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
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.displayState = fullScreen ? flash.display.StageDisplayState.FULL_SCREEN_INTERACTIVE : flash.display.StageDisplayState.NORMAL;
		r3d.setFullScreen(fullScreen);
	}

	function onMessage( msg : _Answer ) {
		connectionOccured = true;
		throw msg;
	}

	function mouseLock(b) {
		interf.lockButtons(b);
		if( b ) flash.ui.Mouse.hide(); else flash.ui.Mouse.show();
		//try root.stage.mouseLock = b catch( e : Dynamic ) {}
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
		if( up ) {
			var old = drag;
			drag = null;
			if( old != null && old.active )
				mouseLock(false);
		} else {
			drag = {
				x : Std.int(root.mouseX),
				y : Std.int(root.mouseY),
				dx : 0,
				dy : 0,
				az : 0.,
				active : false,
			};
		}
	}
	
	
	function checkAction() {
		
		if( drag == null || drag.active || lock || select == null || hero.actionPause > 0 )
			return;

		if( hero.power <= 0 ) {
			interf.warning(texts.cannot_act);
			return;
		}

		if( pendingCancel || (pendingBlocks != null && pendingBlocks.length/5 > 10) ) {
			interf.warning(texts.server_wait);
			return;
		}

		var s = select;
		var x = real(s.x), y = real(s.y), z = real(s.z);

		for( p in protect )
			if( p.x == x && p.y == y && p.z == z )
				return;

		if( build == null ) {
			var power = 10;
			selectPower += power / s.b.requiredPower;
			hero.actionPause = power;
			hero.power -= power;
			needRedraw = true;
			if( selectPower < 1 )
				return;
			var d = new Dummy(x, y, z, s.b);
			dummies.push(d);
			/*
			if( !interf.updateInventory(s.b,1) ) {
				interf.warning(texts.inv_full);
				return;
			}
			*/
		} else {
			if( !interf.updateInventory(build,-1) ) {
				interf.warning(texts.inv_empty);
				return;
			}
		}
		
		level.set(x, y, z, build);
		process.set(x, y, z, build);
		r3d.builder.updateKube(x,y,z,build);
		
		needRedraw = true;
		select = null;
		if( DATA == null )
			return;
		var old = s.b;
		var bindex = function(b:Block) return (b == null) ? 0 : Type.enumIndex(b.k) + 1;
		var infos = [x,y,z,bindex(old),bindex(build)];
		if( pendingBlocks != null ) {
			for( i in infos )
				pendingBlocks.push(i);
		} else {
			command(CSetBlocks(infos));
			pendingBlocks = new Array();
		}
	}

	function command( cmd : _Cmd ) {
		//Codec.send(proto,DATA._s,cmd);
	}
	
	public inline function real( p : Int ) {
		return (p + planetSize) % planetSize;
	}

	public function getPlanetCurve() {
		// this will make a good sinus approximation once multiplied with squared distance
		return 2 / planetSize;
	}
	
	function update(_) {
		if( fullScreen && root.stage.displayState == flash.display.StageDisplayState.NORMAL )
			toggleFullScreen();
		
		mt.Timer.update();
		time += mt.Timer.deltaT;
		
		if( lock )
			return;
			
		if( process.update(mt.Timer.deltaT) )
			needRedraw = true;

		// basic controls
		var speed = 0.;
		var move = false, strafe = 0., turn = 0.;
		if( Key.isDown(K.RIGHT) || Key.isDown("D".code) || Key.isDown(K.NUMPAD_4) ) {
			if( drag != null && drag.active )
				strafe += 0.15;
			else
				turn += 0.04 * mt.Timer.tmod;
			move = true;
		}
		if( Key.isDown(K.LEFT) || Key.isDown("A".code) || Key.isDown("Q".code) || Key.isDown(K.NUMPAD_6) ) {
			if( drag != null && drag.active )
				strafe -= 0.15;
			else
				turn -= 0.04 * mt.Timer.tmod;
			move = true;
		}
		if( Key.isDown(K.UP) || Key.isDown("W".code) || Key.isDown("Z".code) || Key.isDown(K.NUMPAD_8) ) {
			speed += 0.15;
			move = true;
			hero.recalAngleZ = true;
		} else
			hero.pushPower = 0.0;
		if( Key.isDown(K.DOWN) || Key.isDown("S".code) || Key.isDown(K.NUMPAD_2) ) {
			speed -= 0.15;
			move = true;
			hero.recalAngleZ = true;
		}
		if( Key.isToggled(K.ESCAPE) || Key.isToggled(K.TAB) )
			interf.defaultAction();
		if( Key.isToggled("T".code) )
			startPing();
		if( Key.isToggled("F".code) )
			showFPS.visible = !showFPS.visible;
		if( Key.isToggled("J".code) )
			hero.flying = !hero.flying;
		if( showFPS.visible )
			needRedraw = true;

		// update position
		hero.walking = hero.gravity == 0 && Key.isDown(K.SHIFT);
		if( hero.swimming || hero.walking ) {
			speed *= 0.3;
			strafe *= 0.3;
			turn *= 0.3;
		}
		if( hero.power == 0 && (speed != 0 || strafe != 0) ) {
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
		if( hero.gravity != 0 )
			move = true;
		if( hero.flying && hero.z > 30 ) {
			speed *= hero.z / 30;
			strafe *= hero.z / 30;
		}
		hero.angle += turn;
		var jump = Key.isToggled(K.SPACE) || Key.isToggled(K.CONTROL);
		for( i in 0...k )
			hero.doMove(dt,speed,strafe,jump);
		if( hero.updateAngleView() || hero.gravity != 0 )
			move = true;

		if( DATA != null )
			interf.updateInfos();
		
		if( drag != null ) {
			var dx = Std.int(root.mouseX - drag.x);
			var dy = Std.int(root.mouseY - drag.y);
			if( !drag.active ) {
				drag.active = Math.sqrt(dx*dx+dy*dy) > 10;
				if( drag.active ) {
					mouseLock(true);
					drag.az = hero.angleZ;
				}
			}
			if( drag.active ) {
				hero.recalAngleZ = false;
				drag.x += dx;
				hero.angle += dx / 100.0;
				hero.angleZ = drag.az - dy / 100.0;
				var amax = Math.PI / 2.01;
				if( hero.angleZ < -amax )
					hero.angleZ = -amax;
				else if( hero.angleZ > amax )
					hero.angleZ = amax;
				if( dx != drag.dx || dy != drag.dy ) {
					move = true;
					drag.dx = dx;
					drag.dy = dy;
				}
			}
		}

		// save position
		checkAction();
		hero.savePosition(move);

		// point of view
		var px = (hero.x - Math.cos(hero.angle) * 0.44 + planetSize) % planetSize;
		var py = (hero.y - Math.sin(hero.angle) * 0.44 + planetSize) % planetSize;
		var pz = hero.z + hero.viewZ;
		if( animWater != null ) {
			if( hero.swimming ) {
				var dz = Math.sin(px * animWater.width + time * animWater.speed) * Math.cos(py * animWater.width + time * animWater.speed) * animWater.scale * 0.5;
				pz -= dz;
			}
			needRedraw = true;
		}
		r3d.setPos(px, py, pz, hero.angle, hero.angleZ);
		
		// update selection
		var prev = select;
		if( drag != null && drag.active )
			select = null;
		else {
			var mx = Std.int(root.stage.mouseX);
			var my = Std.int(root.stage.mouseY);
			select = r3d.pick(mx, my, build != null);
		}
		if( fadeFX != null )
			select = null;
		if( select != null ) {
			var dx = hero.x - select.x, dy = hero.y - select.y, dz = hero.z - select.z;
			var ix = Std.int(hero.x), iy = Std.int(hero.y), iz = Std.int(hero.z);
			if( Math.sqrt(dx*dx+dy*dy+dz*dz) > 60 || select.z == 0
				|| (select.x == ix && select.y == iy && (select.z == iz || select.z == iz + 1))
			)
				select = null;
		}
		if( (prev == null) != (select == null) || (select != null && (prev.x != select.x || prev.y != select.y || prev.z != select.z)) ) {
			needRedraw = true;
			selectPower = 0;
		}

		// redraw
		if( move || needRedraw ) {
			needRedraw = false;
			r3d.render();
		}
		
		if( showFPS.visible )  {
			var a = hero.angle % (Math.PI * 2);
			if( a < 0 ) a += Math.PI * 2;
			var bufferCount = 0, bufferFree = 0;
			var b = r3d.builder.bmanager.buffers;
			while( b != null ) {
				bufferCount++;
				var f = b.free;
				while( f != null ) {
					bufferFree += f.count;
					f = f.next;
				}
				b = b.next;
			}
			
			var infos = [
				r3d.drawCalls + " draws",
				r3d.bufCount + " buffers",
				r3d.rebuiltCount+" chunks built (avg "+(Std.int(r3d.rebuiltTime*100/r3d.rebuiltCount)/100)+"ms)",
				"x=" + (Std.int(hero.x * 10) / 10) + " y=" + (Std.int(hero.y * 10) / 10) + " z=" + (Std.int(hero.z * 10) / 10) + " a=" + Std.int(a * 180 / Math.PI) + "°",
				bufferCount+" buffers ("+(Std.int(bufferFree*1000/(bufferCount*Buffers.BufferManager.MAX_SIZE))/10)+"% free)",
			];
			showFPS.text = r3d.driverName()+" "+Std.int(r3d.triCount/1000) + ".KTri @" + (Std.int(mt.Timer.fps()*10)/10) + " fps\n"+infos.join("\n");
		}
	}
	
	public static function log( v : Dynamic ) {
		flash.external.ExternalInterface.call("logString", Std.string(v));
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
		haxe.Log.setColor(0xFF0000);
		var stage = flash.Lib.current.stage;
		if( stage.stageWidth <= 0 ) {
			haxe.Timer.delay(main,1);
			return;
		}
		var k = 0;
		var texts : Hash<String> = null;
		try k = haxe.Unserializer.run(flash.Lib.current.loaderInfo.parameters.k) catch( e : Dynamic ) {};
		if( k != 654 ) {
			//DATA = Codec.getData("data");
			var tstr = flash.Lib.current.loaderInfo.parameters.texts;
			if( tstr != null ) texts = haxe.Unserializer.run(tstr);
		}
		mt.Timer.maxDeltaTime = 10;
		mt.Timer.tmod_factor = 0.9;
		var root = new flash.display.MovieClip();
		flash.Lib.current.addChild(root);
		var mc = new flash.display.Sprite();
		root.addChild(mc);
		new Kube(mc,stage.stageWidth,stage.stageHeight,texts);
		mt.flash.Key.init();
		mt.flash.Key.enableJSKeys("kube");
	}

}
