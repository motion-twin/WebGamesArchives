import Common;
import Kube.Texts;
typedef K = flash.ui.Keyboard;
typedef BUT = flash.display.SimpleButton;

typedef MapLoad = {
	var x : Int;
	var y : Int;
	var k : haxe.io.Bytes;
	var h : haxe.io.Bytes;
	var colors : flash.utils.ByteArray;
	var loading : Null<Bool>;
	var visible : Bool;
	var lastSeen : Float;
}

class Map {

	static inline var MAX_ZMEM = 80;
	static inline var HALFX = 768 >> 1;
	static inline var HALFY = 512 >> 1;
	static var SCALES = [0.5,1.0,2.0,3.0];

	var root : flash.display.MovieClip;
	var bmp : Array<Array<{ b : flash.display.Bitmap, col : flash.utils.ByteArray }>>;
	var all : Hash<MapLoad>;
	var colors : flash.Vector<Int>;
	var level : Level;
	var ui : {> flash.display.MovieClip,
		tf : flash.text.TextField,
		ico : flash.display.MovieClip,
		zoom_plus : BUT,
		zoom_minus : BUT,
		ar_top : BUT,
		ar_bottom : BUT,
		ar_left : BUT,
		ar_right : BUT,
	};
	var ux : Int;
	var uy : Int;
	var zones : Hash<ZoneInfos>;
	var scaleLevel : Int;
	var sx : Int;
	var sy : Int;
	var displayX : Int;
	var displayY : Int;
	var lastWheel : Int;
	var inf : MapData;
	var bits : InfBitSet;
	var admin : Bool;
	var texts : Texts;
	var bitmaps : flash.display.Sprite;
	var r : { xMin : Int, yMin : Int, xMax : Int, yMax : Int };
	var loading : flash.display.BitmapData;
	var hidden : flash.display.BitmapData;
	var loadingMaps : Int;
	var cursor : flash.display.MovieClip;
	var drag : { x : Int, y : Int, active : Bool };
	var highMode : Bool;
	var mapUsers : Hash<String>;

	function new(root,inf:MapData,h:Hash<String>) {
		this.root = root;
		this.ux = inf._x;
		this.uy = inf._y;
		this.inf = inf;
		this.texts = new Texts(h.get);
		mapUsers = new Hash();
		admin = (inf._flags & GameConst.FLAG_ADMIN) != 0;
		initBits(inf);
		root.stage.addEventListener(flash.events.KeyboardEvent.KEY_UP,onKeyUp);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE,onMouseMove);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL,onMouseWheel);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN,onMouseDown);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP,onMouseUp);
		root.graphics.beginFill(0x0090FF);
		root.graphics.drawRect(0,0,768,768);
		level = new Level();
		all = new Hash();
		bmp = new Array();
		zones = new Hash();
		sx = ux;
		sy = uy;
		bmp = new Array();
		bitmaps = new flash.display.Sprite();
		root.addChild(bitmaps);
		colors = Interface.initMapColors(level);
		for( i in 0...1<<Interface.CBITS ) {
			colors[(0xFF<<Interface.CBITS)+i] = 0xFF800000;
			colors[i] = 0xFF808080;
		}
		ui = cast flash.Lib.attach(__unprotect__("map_ui"));
		root.buttonMode = true;
		ui.tf.mouseEnabled = false;
		initButton(ui.zoom_minus,callback(scale,-1));
		initButton(ui.zoom_plus,callback(scale,1));
		initButton(ui.ar_bottom,callback(move,0,1));
		initButton(ui.ar_top,callback(move,0,-1));
		initButton(ui.ar_left,callback(move,-1,0));
		initButton(ui.ar_right,callback(move,1,0));
		cursor = new flash.display.MovieClip();
		cursor.graphics.lineStyle(1,0,0.3);
		cursor.graphics.drawRect(0.5,0.5,31.5,31.5);
		root.addChild(ui);
		scaleLevel = SCALES.length - 1;
		loading = getBitmap("map_loading");
		hidden = getBitmap("map_hidden");
		redraw();
	}

	function initButton(b:BUT,f) {
		var me = this;
		b.addEventListener(flash.events.MouseEvent.CLICK,function(e:flash.events.MouseEvent) {
			f();
		});
		b.addEventListener(flash.events.MouseEvent.MOUSE_DOWN,function(e:flash.events.MouseEvent) {
			e.stopPropagation();
		});
		b.addEventListener(flash.events.MouseEvent.MOUSE_UP,function(e:flash.events.MouseEvent) {
			e.stopPropagation();
		});
		b.addEventListener(flash.events.MouseEvent.MOUSE_OVER,function(_) {
			me.cursor.visible = false;
		});
		b.addEventListener(flash.events.MouseEvent.MOUSE_OUT,function(_) {
			me.cursor.visible = true;
		});
	}


	function move( dx, dy ) {
		var scale = SCALES[scaleLevel];
		sx += Std.int(dx * 32 / scale);
		sy += Std.int(dy * 32 / scale);
		redraw();
	}

	inline function getBitmap(name) : flash.display.BitmapData {
		var c = flash.system.ApplicationDomain.currentDomain.getDefinition(untyped __unprotect__(name));
		return Type.createInstance(c,[null,null]);
	}

	static inline var D	= 1 << GameConst.DOLBITS;

	function initBits( inf : MapData ) {
		bits = new InfBitSet(GameConst.DOLBITS);
		var zx = ux>>GameConst.ZONEBITS, zy = uy>>GameConst.ZONEBITS;
		var xMin, yMin, xMax, yMax;
		xMin = xMax = zx;
		yMin = yMax = zy;
		var ux = zx >> GameConst.DOLBITS, uy = zy >> GameConst.DOLBITS;
		var kxMin, kyMin, kxMax, kyMax;
		kxMin = kxMax = ux;
		kyMin = kyMax = uy;
		for( z in inf._dol ) {
			var kx = z._x, ky = z._y;
			bits.add(kx,ky,z._b);
			if( kx <= kxMin ) {
				kxMin = kx;
				var zx = kx<<GameConst.DOLBITS;
				var zy = ky<<GameConst.DOLBITS;
				while( zx < xMin ) {
					for( zy in zy...zy+D )
						if( bits.get(zx,zy) ) {
							xMin = zx;
							break;
						}
					zx++;
				}
			}
			if( ky <= kyMin ) {
				kyMin = ky;
				var zx = kx<<GameConst.DOLBITS;
				var zy = ky<<GameConst.DOLBITS;
				while( zy < yMin ) {
					for( zx in zx...zx+D )
						if( bits.get(zx,zy) ) {
							yMin = zy;
							break;
						}
					zy++;
				}
			}
			if( kx >= kxMax ) {
				kxMax = kx;
				var zx = (kx<<GameConst.DOLBITS) + (D - 1);
				var zy = ky<<GameConst.DOLBITS;
				while( zx > xMax ) {
					for( zy in zy...zy+D )
						if( bits.get(zx,zy) ) {
							xMax = zx;
							break;
						}
					zx--;
				}
			}
			if( ky >= kyMax ) {
				kyMax = ky;
				var zx = kx<<GameConst.DOLBITS;
				var zy = (ky<<GameConst.DOLBITS) + (D - 1);
				while( zy > yMax ) {
					for( zx in zx...zx+D )
						if( bits.get(zx,zy) ) {
							yMax = zy;
							break;
						}
					zy--;
				}
			}
		}
		bits.set(zx,zy,true);
		if( admin ) {
			var big = 1<<25;
			this.r = { xMin : -big, yMin : -big, xMax : big, yMax : big };
		} else
			this.r = { xMin : xMin, yMin : yMin, xMax : xMax, yMax : yMax };
	}

	function onKeyUp( e : flash.events.KeyboardEvent ) {
		var me = this;
		switch( e.keyCode ) {
		case K.PAGE_UP, K.NUMPAD_ADD:
			if( scaleLevel < SCALES.length - 1 ) {
				scaleLevel++;
				redraw();
			}
		case K.PAGE_DOWN, K.NUMPAD_SUBTRACT:
			if( scaleLevel > 0 ) {
				scaleLevel--;
				redraw();
			}
		case K.LEFT: sx -= 32; redraw();
		case K.RIGHT: sx += 32; redraw();
		case K.UP: sy -= 32; redraw();
		case K.DOWN: sy += 32; redraw();
		}
		if( !admin )
			return;
		var p = getPos();
		if( highMode ) {
			p.x <<= 5;
			p.y <<= 5;
		}
		switch( e.keyCode ) {
		case "T".code:
			command(CSavePos(p.x * GameConst.PREC,p.y * GameConst.PREC,0,null),function(_) {
				flash.Lib.getURL(new flash.net.URLRequest("/"),"_self");
			});
		case K.DELETE:
			var x = p.x >> GameConst.XYBITS;
			var y = p.y >> GameConst.XYBITS;
			command(CAdminDelete(x,y),function(_) {
				me.all.remove(key(x,y));
				me.redraw();
			});
		case "A".code:
			admin = false;
			redraw();
		case "G".code:
			var mx = p.x >> GameConst.XYBITS;
			var my = p.y >> GameConst.XYBITS;
			var g = new Generator(0);
			var t = g.generate(mx * Level.XYSIZE,my * Level.XYSIZE);
			var l = new Level();
			level.init(t);
			var bytes = new flash.utils.ByteArray();
			bytes.writeBytes(level.t);
			bytes.compress();
			var bytes = haxe.io.Bytes.ofData(bytes);
			command(CGenLevel(mx,my,bytes),onMapLoad);
		case "F".code:
			zones = new Hash();
			highMode = true;
			ux >>= 3;
			uy >>= 3;
			all = new Hash();
			for( b in bmp ) {
				for( b in b ) {
					if( b == null ) continue;
					b.col = null;
				}
			}
			redraw();
		}
	}

	function getPos( ?noscale ) {
		var scale = SCALES[scaleLevel];
		var width = Math.ceil(HALFX/scale);
		var height = Math.ceil(HALFY/scale);
		var x = Std.int(root.mouseX/scale) + sx - width;
		var y = Std.int(root.mouseY/scale) + sy - height;
		return { x : x, y : y };
	}

	function onMouseDown(_) {
		var p = getPos();
		drag = {
			x : p.x - sx,
			y : p.y - sy,
			active : false,
		}
	}

	function onMouseUp(_) {
		if( drag != null && !drag.active ) {
			var p = getPos();
			sx = p.x;
			sy = p.y;
			redraw();
		}
		drag = null;
	}

	function onMouseWheel(e:flash.events.MouseEvent) {
		var t = flash.Lib.getTimer();
		if( t - lastWheel < 100 )
			return;
		lastWheel = t;
		scale((e.delta > 0)?1:-1);
	}

	function scale( d : Int ) {
		scaleLevel += d;
		if( scaleLevel < 0 )
			scaleLevel = 0;
		else if( scaleLevel >= SCALES.length )
			scaleLevel = SCALES.length - 1;
		redraw();
	}

	function onMouseMove(event) {
		var p = getPos();

		if( drag != null && event != null ) {
			var dx = (p.x - sx) - drag.x;
			var dy = (p.y - sy) - drag.y;
			if( dx != 0 || dy != 0 ) {
				sx -= dx;
				sy -= dy;
				drag.x += dx;
				drag.y += dy;
				drag.active = true;
				redraw();
				return;
			}
		}

		if( highMode ) {
			p.x <<= 3;
			p.y <<= 3;
		}

		var zx = p.x >> GameConst.ZONEBITS;
		var zy = p.y >> GameConst.ZONEBITS;
		var text = [];
		var z = zones.get(key(zx,zy));
		if( !admin && !bits.get(zx,zy) )
			z = null;
		text.push("["+zx+"]["+zy+"]" + (( z != null && z._n != null ) ? " <b>"+StringTools.htmlEscape(z._n)+"</b>" : ""));
		if( z == null ) {
			ui.ico.gotoAndStop(1);
			text.push(texts.zone_empty);
		} else {
			if( z._u == null ) {
				ui.ico.gotoAndStop(1);
				text.push(texts.zone_admin);
			} else {
				ui.ico.gotoAndStop(2);
				text.push(texts.zone_user.split("::u::").join(z._u));
			}
		}
		if( admin ) {
			text.push("");
			text.push("X : "+p.x+" Y : "+p.y);
			var mx = p.x >> 8;
			var my = p.y >> 8;
			text.push("MX : "+mx+" MY : "+my);
			var u = mapUsers.get(mx+"_"+my);
			if( u != null )
				text.push("User : "+u);
		}
		ui.tf.htmlText = text.join("<br>");
		bitmaps.addChild(cursor);

		if( highMode ) {
			p.x >>= 3;
			p.y >>= 3;
			zx = p.x >> GameConst.ZONEBITS;
			zy = p.y >> GameConst.ZONEBITS;
		}

		cursor.x = zx << GameConst.ZONEBITS;
		cursor.y = zy << GameConst.ZONEBITS;
	}

	function setData(x:Int,y:Int,fdata:haxe.io.Bytes) {
		var data = all.get(key(x,y));
		if( data == null )
			return;
		var kmap = data.k, hmap = data.h;
		data.colors = null;
		data.loading = false;
		var pos = 0;
		var invisible = admin ? -1 : (Type.enumIndex(BInvisible) + 1);
		for( y in 0...256 )
			for( x in 0...256 ) {
				var k = 0, z = (1 << GameConst.ZBITS) - 1;
				if( fdata != null ) {
					var a = level.addr(x,y,z);
					while( k == 0 || k == invisible ) {
						k = fdata.get(a);
						a -= 1 << Level.Z;
						z--;
					}
				} else
					z = 0;
				kmap.set(pos,k);
				hmap.set(pos,z+1);
				pos++;
			}
	}

	static inline function key(x:Int,y:Int) {
		return x+"/"+y;
	}

	function initData(x,y) {
		var data = {
			x : x,
			y : y,
			k : haxe.io.Bytes.alloc(256*256),
			h : haxe.io.Bytes.alloc(256*256),
			loading : null,
			visible : false,
			colors : null,
			lastSeen : 0.,
		};
		all.set(key(x,y),data);
		for( i in 0...256*256 )
			data.k.set(i,255);

		var zmax = 1<<(GameConst.XYBITS - GameConst.ZBITS);
		var visible = admin;
		for( zx in 0...zmax )
			for( zy in 0...zmax )
				if( bits.get(x*zmax+zx,y*zmax+zy) ) {
					visible = true;
					break;
				}
		if( !visible )
			setData(x,y,null);
		return data;
	}

	function command( c : _Cmd, callb : _Answer -> Void ) {
		Codec.call(inf._s,c,callb);
	}

	function initLoading( m : MapLoad ) {
		if( m.loading != null ) return;
		if( loadingMaps > 3 ) return;
		m.loading = true;
		loadingMaps++;
		if( highMode ) {
			var maps = [];
			for( x in 0...8 )
				for( y in 0...8 ) {
					maps.push(m.x*8+x);
					maps.push(m.y*8+y);
				}
			Codec.load("/mapBits",maps,callback(onMapBits,m));
		} else
			command(CLoad(m.x,m.y),onMapLoad);
	}

	function onMapLoad(a) {
		loadingMaps--;
		switch(a) {
		case AMap(x,y,data,patches,zones):
			var bytes = data.getData();
			bytes.uncompress();
			var bytes = haxe.io.Bytes.ofData(bytes);
			if( patches != null ) {
				var p = 0;
				while( p < patches.length ) {
					var x = patches.get(p++);
					var y = patches.get(p++);
					var z = patches.get(p++);
					var b = patches.get(p++);
					if( z == 0 ) break;
					bytes.set(level.addr(x,y,z),b);
				}
			}
			var zmax = 1 << (GameConst.XYBITS - GameConst.ZONEBITS);
			for( dx in 0...zmax )
				for( dy in 0...zmax ) {
					var zx = x * zmax + dx;
					var zy = y * zmax + dy;
					var z = zones.shift();
					if( z != null )
						this.zones.set(key(zx,zy),z);
				}
			setData(x,y,bytes);
		case AGenerate(x,y):
			setData(x,y,null);
		default:
			throw Std.string(a);
		}
		redraw();
	}

	function onMapBits( m : MapLoad, a : { _f : Array<String>, _b : haxe.io.Bytes } ) {
		loadingMaps--;
		var b = new flash.display.BitmapData(256,256,false,0xFF0000);
		b.lock();
		var pos = 0;
		var bits = a._b;
		for( x in 0...8 )
			for( y in 0...8 ) {
				var mx = m.x * 8 + x;
				var my = m.y * 8 + y;
				var user = a._f[pos];
				mapUsers.set(mx+"_"+my,user);
				if( user == null ) {
					for( dx in 0...32 )
						for( dy in 0...32 )
							b.setPixel32((x<<5)+dx,(y<<5)+dy,0x808080);
				} else {
					var a = pos * 128 * 8;
					for( dy in 0...32 )
						for( dx in 0...32 ) {
							var k = bits.get(a>>3) >> (a&7);
							b.setPixel32((x<<5)+dx,(y<<5)+dy,((k&1) > 0)?0xC5752C:0x4CA5CD);
							a++;
						}
				}
				pos++;
			}
		b.unlock();
		m.loading = false;
		m.colors = b.getPixels(b.rect);
		b.dispose();
		redraw();
	}

	function redraw() {
		var scale = SCALES[scaleLevel];
		var width = Math.ceil(HALFX/scale);
		var height = Math.ceil(HALFY/scale);

		// recall
		var rec = false;
		var vmin, vmax;
		vmin = ((r.xMin-1)<<GameConst.ZONEBITS) + width;
		vmax = ((r.xMax+2)<<GameConst.ZONEBITS) - width;
		if( vmin > vmax )
			sx = (vmin + vmax) >> 1;
		else if( sx < vmin ) {
			sx = vmin;
			rec = true;
		} else if( sx > vmax ) {
			sx = vmax;
			rec = true;
		}
		vmin = ((r.yMin-1)<<GameConst.ZONEBITS) + height;
		vmax = ((r.yMax+2)<<GameConst.ZONEBITS) - height;
		if( vmin > vmax )
			sy = (vmin + vmax) >> 1;
		else if( sy < vmin ) {
			sy = vmin;
			rec = true;
		} else if( sy > vmax ) {
			sy = vmax;
			rec = true;
		}
		if( rec ) {
			redraw();
			return;
		}

		var dx = (sx - width) >> 8;
		var dy = (sy - height) >> 8;
		var sizex = ((sx + width)>>8) - dx + 1;
		var sizey = ((sy + height)>>8) - dy + 1;
		var mx = (sx - width) - (dx<<8);
		var my = (sy - height) - (dy<<8);
		for( bx in bmp )
			for( b in bx )
				b.b.visible = false;
		var count = 0;
		for( a in all ) {
			count++;
			a.visible = false;
		}
		if( count > MAX_ZMEM ) {
			var all = Lambda.array(all);
			all.sort(function(m1,m2) return (m1.lastSeen == m2.lastSeen) ? 0 : ((m1.lastSeen > m2.lastSeen) ? 1 : -1));
			while( all.length > MAX_ZMEM ) {
				var m = all.shift();
				this.all.remove(key(m.x,m.y));
			}
		}

		bitmaps.x = (-dx * 256 - mx) * scale;
		bitmaps.y = (-dy * 256 - my) * scale;
		bitmaps.scaleX = bitmaps.scaleY = scale;

		for( x in 0...sizex )
			for( y in 0...sizey ) {
				var xx = x + dx, yy = y + dy;
				var tag = xx+","+yy;
				var data = all.get(key(xx,yy));
				if( data == null )
					data = initData(xx,yy);
				data.visible = true;
				data.lastSeen = haxe.Timer.stamp();
				var pos = 0;
				var bx = bmp[x];
				if( bx == null ) {
					bx = new Array();
					bmp[x] = bx;
				}
				var bmp = bmp[x][y];
				if( bmp == null ) {
					var b = new flash.display.BitmapData(256,256,true,0);
					bmp = { b : new flash.display.Bitmap(b), col : null };
					bitmaps.addChildAt(bmp.b,0);
					this.bmp[x][y] = bmp;
				}
				bmp.b.x = xx * 256;
				bmp.b.y = yy * 256;
				bmp.b.visible = true;
				var b = bmp.b.bitmapData;
				var hmap = data.h, kmap = data.k;
				if( data.colors == null && data.loading != false ) {
					b.copyPixels(loading,loading.rect,new flash.geom.Point(0,0));
					initLoading(data);
				} else if( data.colors == null ) {
					b.lock();
					for( y in 0...256 )
						for( x in 0...256 ) {
							b.setPixel32(x,y,colors[(kmap.get(pos)<<Interface.CBITS) | (hmap.get(pos)>>(GameConst.ZBITS-Interface.CBITS))]);
							pos++;
						}
					var zmc = new flash.display.Shape();
					var zmax = 1 << (GameConst.XYBITS - GameConst.ZONEBITS);
					var Z = 1 << GameConst.ZONEBITS;
					var g = zmc.graphics;
					for( x in 0...zmax )
						for( y in 0...zmax ) {
							var zx = xx*zmax+x;
							var zy = yy*zmax+y;
							if( admin ) {
								if( !zones.exists(key(zx,zy)) )
									continue;
								g.beginFill(0xFFFFFF,0.1);
								g.drawRect(x*Z,y*Z,Z,Z);
								continue;
							}
							if( !bits.get(zx,zy) )
								b.copyPixels(hidden,hidden.rect,new flash.geom.Point(x*Z,y*Z));
							else if( !zones.exists(key(zx,zy)) ) {
								g.beginFill(colors[0],0.3);
								g.drawRect(x*Z,y*Z,Z,Z);
							}
						}
					b.draw(zmc);
					b.unlock();
					data.colors = b.getPixels(b.rect);
				} else if( data.colors != bmp.col ) {
					data.colors.position = 0;
					b.setPixels(b.rect,data.colors);
					bmp.col = data.colors;
				}
				if( (ux>>8) == xx && (uy>>8) == yy ) {
					var x = ux&0xFF;
					var y = uy&0xFF;
					b.fillRect(new flash.geom.Rectangle(x-1,y-1,3,3),0xFFFFFFFF);
					b.setPixel32(x,y,0xFFFF0000);
				}
			}
		onMouseMove(null);
	}


	static var inst : Map;

	static function main() {
		var root = flash.Lib.current;
		Codec.VERSION = GameConst.VERSION;
		var inf : MapData = Codec.getData("infos");
		var h : Hash<String> = haxe.Unserializer.run(root.loaderInfo.parameters.texts);
		haxe.Log.setColor(0xFF0000);
		inst = new Map(root,inf,h);
	}

}