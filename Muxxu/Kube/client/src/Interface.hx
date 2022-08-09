import Level.Block;
import Common;

class Interface {

	public static inline var WIDTH = 196;
	public static inline var CBITS = 4;
	static inline var YMARGIN = 19;
	static inline var XMARGIN = 14;
	static inline var SPACING = 4;
	static inline var BWIDTH = 40;
	static inline var BHEIGHT = 45;
	static inline var COUNT = 4;
	static inline var PAGE = 16;
	
	var game : Kube;
	var content : Array<{
		mc : flash.display.MovieClip,
		bmp : flash.display.BitmapData,
		count : flash.text.TextField,
		block : Block
	}>;
	public var bg : flash.display.MovieClip;
	var icons : Array<{> flash.display.MovieClip, smc : flash.display.MovieClip }>;
	var scroll : Int;
	var invMC : {> flash.display.MovieClip, bleft : flash.display.MovieClip, bright : flash.display.MovieClip };
	var msgMC : {> flash.display.MovieClip, tf : flash.text.TextField };
	var errorMC : {> flash.display.MovieClip, tf : flash.text.TextField };
	var current : flash.display.MovieClip;
	var inventory : Array<Null<Int>>;
	var defCountColor : Int;
	var minimap : haxe.remoting.AsyncConnection;
	var js : haxe.remoting.Connection;
	var curMap : {
		mx : Int, my : Int,
		zx : Int, zy : Int,
		tag : String,
		pts : Array<{ _x : Int, _y : Int, _c : Int }>,
		redraw : Bool, wait : Bool,
		delay : Float,
	};
	var colors : flash.Vector<Int>;
	var glow : flash.filters.BitmapFilter;
	var lockMC : flash.display.Sprite;
	var north : flash.display.MovieClip;
	var htmlCache : Hash<String>;
	var request : haxe.Http;
	var kubeNames : Array<String>;
	var tipMC : {> flash.display.MovieClip, tf : flash.text.TextField };
	var tipDelay : Float;
	public var power(default,setPower) : mt.flash.Volatile<Int>;
	
	var cnx : flash.net.LocalConnection;
	var cnxListening : Array<String>;
	public var minigfx : Minimap;
	
	public function new(k) {
		game = k;
		invMC = cast attach("inventory");
		game.root.addChild(invMC);
		bg = attach("bg");
		bg.scale9Grid = new flash.geom.Rectangle(10, 10, bg.width - 20, bg.height - 20);
		game.root.addChild(bg);
		content = new Array();
		htmlCache = new Hash();
		icons = new Array();
		glow = new flash.filters.GlowFilter(0,0.5,2,2,5);
		var me = this;
		invMC.bleft.addEventListener(flash.events.MouseEvent.CLICK,function(_) me.doScroll(-1));
		invMC.bright.addEventListener(flash.events.MouseEvent.CLICK,function(_) me.doScroll(1));
		invMC.bleft.stop();
		invMC.bright.stop();
		invMC.bleft.addEventListener(flash.events.MouseEvent.MOUSE_OVER,function(_) me.invMC.bleft.gotoAndStop(2));
		invMC.bleft.addEventListener(flash.events.MouseEvent.MOUSE_OUT,function(_) me.invMC.bleft.gotoAndStop(1));
		invMC.bright.addEventListener(flash.events.MouseEvent.MOUSE_OVER,function(_) me.invMC.bright.gotoAndStop(2));
		invMC.bright.addEventListener(flash.events.MouseEvent.MOUSE_OUT,function(_) me.invMC.bright.gotoAndStop(1));
		invMC.bleft.buttonMode = invMC.bright.buttonMode = true;
		invMC.tabChildren = false;
		select(addIcon("pick",function() me.onBlockSelect(null)));
		if( game.hasFlag(GameConst.FLAG_PHOTO) )
			addIcon("camera", new Photo(game).onClick );
		curMap = {
			mx : 0, my : 0,
			zx : 0xFFFFFF, zy : 0xFFFFFF,
			tag : "",
			pts : [],
			redraw : true, wait : false,
			delay : 0.,
		};
		var ctx = new haxe.remoting.Context();
		ctx.addObject("api",{ _remove : removeKube, _lcAction : onLcAction });
		js = haxe.remoting.ExternalConnection.jsConnect("cnx",ctx).api;
		minimap = haxe.remoting.FlashJsConnection.connect("cnx","minimap").api;
		minimap.setErrorHandler(function(e) me.curMap.redraw = true);
		colors = initMapColors(game.level);
		var texts = game.texts.kube_names;
		tipMC = cast attach("tip");
		tipMC.mouseEnabled = tipMC.mouseChildren = false;
		kubeNames = (texts == null) ? [] : texts.split("\n");
		for( i in 0...kubeNames.length )
			kubeNames[i] = StringTools.trim(kubeNames[i]);
		if( game.demo )
			invMC.visible = false;
		else
			bg.x = WIDTH;
			
		var s = new flash.display.MovieClip();
		var mask = new flash.display.Sprite();
		mask.graphics.beginFill(0);
		mask.graphics.drawRect(0, 0, WIDTH, 188);
		s.visible = false;
		s.mask = mask;
		game.root.addChild(s);
		minigfx = new Minimap(s);

		// LC API
		cnx = new flash.net.LocalConnection();
		cnx.allowDomain("*");
		try cnx.connect("_lc_mx_kube_") catch( e : Dynamic ) { };
		cnxListening = [];
		var me = this;
		cnx.client = {
			_requestUpdates : function(name) {
				if( me.cnxListening.remove(name) )
					return;
				me.cnxListening.push(name);
				me.cnx.send(name,'_updatePos', me.curMap.zx, me.curMap.zy);
			},
			_setText : function(text, action) {
				if( text != null ) {
					text = StringTools.htmlEscape(text);
					if( action != null )
						text += '<a href="#" onclick="kubeCnx.resolve(\'api\').resolve(\'_lcAction\').call([]); return false;">' + StringTools.htmlEscape(action) + '</a>';
				}
				me.setTuto(text);
			},
		};
	}

	function onLcAction() {
		for( name in cnxListening )
			cnx.send(name, '_action');
	}
	
	function doScroll(ds) {
		scroll += ds * PAGE;
		redraw();
	}

	function removeKube( x : Int, y : Int, z : Int ) {
		x -= game.cx;
		y -= game.cy;
		var b = game.level.get(x,y,z);
		if( b == null )
			return;
		switch( b ) {
		case BMessage:
		default: return;
		}
		var old = game.select, oldb = game.build;
		game.build = null;
		game.select = { x : x, y : y, z : z, b : game.level.getBlock(b) };
		game.click(true,null);
		game.select = old;
		game.build = oldb;
	}

	public function lockButtons(flag) {
		if( flag ) {
			if( lockMC != null ) return;
			lockMC = new flash.display.Sprite();
			lockMC.graphics.beginFill(0,0);
			lockMC.graphics.drawRect(0,0,game.root.stage.stageWidth,game.root.stage.stageHeight);
			game.root.addChild(lockMC);
		} else {
			if( lockMC == null ) return;
			game.root.removeChild(lockMC);
			lockMC = null;
		}
	}

	public function defaultAction() {
		select(icons[0]);
		onBlockSelect(null);
	}

	public static function initMapColors( level : Level ) {
		var colors = new flash.Vector(256 << GameConst.ZBITS);
		var tmp = new flash.display.BitmapData(16,16);
		var pos = 0;
		for( b in level.blocks ) {
			if( b == null ) {
				for( i in 0...1<<CBITS )
					colors[pos++] = 0;
				continue;
			}
			var t = if( b.tu.isEmpty ) b.tlr else b.tu;
			tmp.applyFilter(t.bmp,tmp.rect,new flash.geom.Point(0,0),new flash.filters.BlurFilter(16,16,2));
			var c = tmp.getPixel32(8,8);
			if( !level.isSoil(b.k) ) {
				for( i in 0...1<<CBITS )
					colors[pos++] = c;
				continue;
			}
			var r = (c >> 16) & 0xFF;
			var g = (c >> 8) & 0xFF;
			var b = c & 0xFF;
			for( i in 0...1<<CBITS ) {
				var k = 0.9 + 0.6 * i / (1<<CBITS);
				var r = Std.int(r * k), g = Std.int(g * k), b = Std.int(b * k);
				if( r >= 255 ) r = 255;
				if( g >= 255 ) g = 255;
				if( b >= 255 ) b = 255;
				colors[pos++] = 0xFF000000 | (r << 16) | (g << 8) | b;
			}
		}
		tmp.dispose();
		return colors;
	}

	inline function attach(name) {
		return flash.Lib.attach(untyped __unprotect__(name));
	}

	public function clean() {
		for( c in content ) {
			if( c.bmp != null ) c.bmp.dispose();
			invMC.removeChild(c.mc);
			if( current == c.mc ) current = null;
		}
		content = new Array();
	}

	public function init(c,p) {
		power = p;
		inventory = c;
		for( i in 0...c.length ) {
			var count = c[i];
			if( count == null ) continue;
			addInventory(game.level.blocks[i],count);
		}
		redraw();
	}

	public function inventoryCount( distinct ) {
		var n = 0;
		for( i in 0...inventory.length )
			if( inventory[i] != null )
				n += distinct ? 1 : inventory[i];
		return n;
	}

	function addInventory( block : Block, count : Int ) {
		var me = this;
		var h = Level.TSIZE;
		var tmp = new flash.display.Shape();

		var point = function(x:Float,y:Float,u:Float,v:Float,w:Float) return [x,y,u,v,w];
		var h = Math.sqrt(1 + 0.5 * 0.5);
		var a = point(-1,0,0,1,-0.139);
		var b = point(1,0,1,0,-0.139);
		var b2 = point(1,0,0,1,-0.139);
		var c = point(0,0.5,1,1,-0.170);
		var d = point(0,-0.5,0,0,-0.119);
		var e = point(-1,h,0,0,-0.124);
		var f = point(0,h+0.5,1,0,-0.148);
		var g = point(1,h,0,0,-0.124);

		var coords = new Array();
		var uvs = new Array();
		var add = function(p) { coords.push(p[0]); coords.push(p[1]); uvs.push(p[2]); uvs.push(p[3]); uvs.push(p[4]); };
		var shade = function(s) return ( s == 255 ) ? null : new flash.geom.ColorTransform(s/255,s/255,s/255);

		var smooth = switch( block.k ) {
			case BInvisible, BTeleport: true;
			default: false;
		}

		var bmp = new flash.display.BitmapData(BWIDTH,BHEIGHT,true,0);
		var mat = new flash.geom.Matrix();
		mat.translate(1.025,0.525);
		mat.scale(20,20);

		var E = 0.5;

		var mat2 = mat.clone();
		tmp.graphics.beginFill(0x4C536F);
		add(a); add(b); add(f); add(a); add(f); add(e); add(a); add(d); add(b); add(b); add(f); add(g);
		tmp.graphics.drawTriangles(flash.Vector.ofArray(coords));
		mat2.scale(0.95,0.95);
		mat2.tx += E * 2;
		mat2.ty += E * 2;
		bmp.draw(tmp,mat2);

		coords = new Array();
		uvs = new Array();
		tmp.graphics.clear();
		tmp.graphics.beginBitmapFill(block.tu.bmp,null,false,smooth);
		add(a); add(b); add(c); add(a); add(d); add(b);
		tmp.graphics.drawTriangles(flash.Vector.ofArray(coords),null,flash.Vector.ofArray(uvs));
		mat.ty += E;
		bmp.draw(tmp,mat,shade(block.shadeUp));
		mat.ty -= E;


		coords = new Array();
		uvs = new Array();
		tmp.graphics.clear();
		tmp.graphics.beginBitmapFill(block.tlr.bmp,null,false,smooth);
		add(a); add(c); add(f); add(a); add(f); add(e);
		tmp.graphics.drawTriangles(flash.Vector.ofArray(coords),null,flash.Vector.ofArray(uvs));
		mat.tx += E;
		bmp.draw(tmp,mat,shade(block.shadeX));
		mat.tx -= E;

		coords = new Array();
		uvs = new Array();
		tmp.graphics.clear();
		tmp.graphics.beginBitmapFill(block.tlr.bmp,null,false,smooth);
		add(c); add(b2); add(g); add(c); add(g); add(f);
		tmp.graphics.drawTriangles(flash.Vector.ofArray(coords),null,flash.Vector.ofArray(uvs));
		mat.tx -= E;
		bmp.draw(tmp,mat,shade(block.shadeY));
		mat.tx += E;

		var s = new flash.display.MovieClip();
		s.addEventListener(flash.events.MouseEvent.CLICK,function(_) { me.select(s); me.onBlockSelect(block); });
		s.addEventListener(flash.events.MouseEvent.ROLL_OVER,function(_) me.showTip(me.kubeNames[block.index]));
		s.addEventListener(flash.events.MouseEvent.ROLL_OUT,function(_) me.showTip(null));
		s.buttonMode = true;
		invMC.addChild(s);
		var cc : Dynamic = attach("count");
		s.addChild(new flash.display.Bitmap(bmp));
		s.addChild(cc);
		s.filters = [glow];
		var tf : flash.text.TextField = cc.tf;
		tf.x += 4;
		tf.y += 18;
		defCountColor = tf.textColor;
		tf.text = Std.string(count);
		tf.mouseEnabled = false;
		content.push({ mc : s, bmp : bmp, block : block, count : tf });
		updateInventory(block,0);
	}

	function showTip( t : String ) {
		if( t == null ) {
			if( tipMC.parent != null ) tipMC.parent.removeChild(tipMC);
			return;
		}
		tipMC.tf.text = t;
		tipMC.x = game.root.mouseX;
		tipMC.y = game.root.mouseY;
		tipMC.visible = false;
		tipDelay = 1.0;
		game.root.addChild(tipMC);
	}

	public function updateInventory( b : Block, count : Int ) {
		var max = (Kube.DATA == null) ? 30 : Kube.DATA._imax;
		var index = Type.enumIndex(b.k) + 1;
		var k = inventory[index];
		if( k == null ) {
			inventory[index] = k = 0;
			addInventory(b,0);
			redraw();
		}
		if( count < 0 && k <= 0 )
			return false;
		if( count > 0 && k >= max )
			return false;
		k += count;
		inventory[index] = k;
		for( c in content )
			if( c.block == b ) {
				c.count.text = Std.string(k);
				c.count.textColor = (k == 0) ? 0x808080 : ((k >= max) ? 0xFF0000 : defCountColor);
				break;
			}
		return true;
	}

	public function updateZone( zx, zy ) {
		if( curMap.zx == zx && curMap.zy == zy )
			curMap.zx = 0xFFFFFF;
	}

	public function warning( text  ) {
		if( text == null ) return;
		setInfos('<div class="warning">'+text+'</div>');
		curMap.zx = 0xFFFFFF;
		curMap.delay = 5;
	}

	public function notice( text  ) {
		if( text == null ) return;
		setInfos('<div class="notice">'+text+'</div>');
		curMap.zx = 0xFFFFFF;
		curMap.delay = 5;
	}

	public function setTuto( text : String ) {
		js._setTuto.call([text]);
	}

	function addIcon( name : String, callb ) {
		var me = this;
		var i = cast attach("icons");
		icons.push(i);
		i.gotoAndStop(name);
		i.buttonMode = true;
		i.addEventListener(flash.events.MouseEvent.CLICK,function(_) { me.select(i); callb(); });
		i.addEventListener(flash.events.MouseEvent.MOUSE_OVER,function(_) {
			if( i.smc != null ) i.smc.gotoAndStop(2);
		});
		i.addEventListener(flash.events.MouseEvent.MOUSE_OUT,function(_) {
			if( i.smc != null ) i.smc.gotoAndStop(1);
		});
		var s = new mt.flash.Skin();
		s.add(__unprotect__("smc"),1);
		s.apply(i,false);
		invMC.addChild(i);
		i.y = 6;
		i.x = 6 + (icons.length - 1) * 50;
		return i;
	}

	function select( cur : flash.display.MovieClip ) {
		if( current != null )
			current.filters = [glow];
		current = cur;
		cur.filters = [glow,new flash.filters.GlowFilter(0xFFFFFF,1,4,4,5)];
	}

	function setPower( p : Int ) {
		if( p < 0 ) p = 0;
		power = p;
		return p;
	}

	function setInfos( html : String ) {
		try {
			js._setInfos.call([html]);
		} catch( e : Dynamic ) {
		}
		if( game.drag != null && game.drag.active ) {
			var g = game;
			flash.ui.Mouse.hide();
			haxe.Timer.delay(function() {
				if( g.drag != null && g.drag.active ) flash.ui.Mouse.hide();
			},100);
		}
	}

	public function initMiniMap() {
		if( game.hasFlag(GameConst.FLAG_DIRECTION) ) {
			minimap._showDir.call([]);
			minigfx._showDir();
		}
	}
	
	public function forceUpdateMap() {
		curMap.redraw = true;
		curMap.tag = "";
	}

	public function updateMinimap(x,y) {
		var cur = game.getCurrentWatch(null,x,y);
		curMap.pts.push({ _x : x - curMap.mx + 128, _y : y - curMap.my + 128, _c : colors[cur.getColorIndex(x,y)] });
	}

	public function updateInfos() {
		if( tipMC.parent != null ) {
			if( tipDelay > 0 ) {
				tipDelay -= mt.Timer.deltaT;
				if( tipDelay <= 0 ) tipMC.visible = true;
			}
			tipMC.x = game.root.mouseX;
			tipMC.y = game.root.mouseY;
		}
		// update minimap graphics
		var cx = Math.floor(game.cx + game.px);
		var cy = Math.floor(game.cy + game.py);
		var dx = cx - curMap.mx;
		var dy = cy - curMap.my;
		var dist = dx * dx + dy * dy;
		if( dist > 256 || curMap.redraw ) {
			curMap.mx = cx;
			curMap.my = cy;
			curMap.pts = [];
			curMap.redraw = false;
			var px = cx - 128;
			var py = cy - 128;
			var b = new flash.utils.ByteArray();
			var cur = null;
			for( y in 0...256 )
				for( x in 0...256 ) {
					var px = x + px;
					var py = y + py;
					cur = game.getCurrentWatch(cur,px,py);
					if( cur == null ) {
						b.writeInt(0);
						continue;
					}
					b.writeInt(colors[cur.getColorIndex(px,py)]);
				}
			b.compress();
			minimap._draw.call([haxe.io.Bytes.ofData(b), px, py]);
			if( minigfx.root.visible )
				minigfx._draw(haxe.io.Bytes.ofData(b), px, py);
			return;
		}
		// update minimap infos
		curMap.delay -= mt.Timer.deltaT;
		if( !curMap.wait ) {
			var me = this;
			var infos = [
				dx,
				dy,
				Std.int(game.angle * 1000) / 1000,
				Std.int((game.swimming ? (1.0 - game.swimDistance/game.maxSwimDistance()) : (power/GameConst.POWER)) * 1000) / 1000,
				game.swimming
			];
			var tag = Std.string(infos);
			if( tag != curMap.tag || curMap.pts.length > 0 ) {
				curMap.wait = true;
				curMap.tag = tag;
				infos.push(curMap.pts);
				curMap.pts = [];
				minimap._set.call(infos, function(_) me.curMap.wait = false);
				if( minigfx.root.visible )
					Reflect.callMethod(minigfx,minigfx._set,infos);
			}
			var zx = cx >> GameConst.ZONEBITS;
			var zy = cy >> GameConst.ZONEBITS;
			if( curMap.delay <= 0 && (zx != curMap.zx || zy != curMap.zy) ) {
				curMap.zx = zx;
				curMap.zy = zy;
				displayZoneInfos();
				for( name in cnxListening )
					cnx.send(name, '_updatePos', zx, zy);
			}
		}
	}

	function displayZoneInfos() {
		var url = game.texts.infos.split("::zx::").join(""+curMap.zx).split("::zy::").join(""+curMap.zy);
		if( htmlCache.exists(url) ) {
			setInfos(htmlCache.get(url));
			return;
		}
		var me = this;
		var tmp = '<div class="reload"></div>';
		htmlCache.set(url,tmp);
		request = new haxe.Http(url);
		request.onData = function(data) {
			me.htmlCache.set(url,data);
			me.curMap.zx = 0xFFFFFF;
		};
		request.request(false);
	}

	public function redraw() {
		for( i in 0...content.length ) {
			var s = content[i].mc;
			if( i < scroll || i >= scroll + PAGE ) {
				s.visible = false;
				continue;
			}
			s.visible = true;
			s.x = XMARGIN + ((i - scroll) % COUNT) * (BWIDTH + SPACING);
			s.y = YMARGIN + (Std.int((i - scroll)/COUNT) + 1) * (BHEIGHT + SPACING);
		}
		invMC.bleft.visible = scroll > 0;
		invMC.bright.visible = (content.length - scroll) > PAGE;
	}

	public function message( ?msg : String ) {
		if( msg == null ) {
			if( msgMC != null )
				game.root.removeChild(msgMC);
			msgMC = null;
			return;
		}
		if( msgMC == null ) {
			msgMC = cast attach("message");
			msgMC.x = game.root.stage.stageWidth;
			msgMC.y = game.root.stage.stageHeight;
			game.root.addChild(msgMC);
		}
		msgMC.tf.text = msg;
	}

	public function logError( e : Dynamic ) {
		var str;
		try str = Std.string(e) catch( e : Dynamic ) str = "???";
		game.lock = true;
		if( errorMC == null ) {
			errorMC = cast attach("error");
			errorMC.buttonMode = true;
			errorMC.tf.text = "";
			errorMC.tf.mouseEnabled = false;
			errorMC.addEventListener(flash.events.MouseEvent.CLICK,function(_) {
				flash.Lib.getURL(new flash.net.URLRequest("/"),"_self");
			});
			game.root.addChild(errorMC);
		}
		errorMC.tf.appendText("["+Date.now().toString()+"] "+str+"\n");
	}

	public dynamic function onBlockSelect( b : Block ) {
	}

}