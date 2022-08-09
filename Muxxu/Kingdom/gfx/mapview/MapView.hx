import data.Delaunay;
import data.MapGenerator.Place;
import data.MapData;

typedef MC = flash.display.MovieClip;
typedef TF = flash.text.TextField;

typedef Panel = {> MC, cityName : TF, cityUser : TF };

class MapView {

	static inline var WIDTH = 500;
	static inline var HEIGHT = 400;

	var g : data.MapGenerator;
	var root : MC;
	var bmpZones : flash.display.BitmapData;
	var bmpDist : flash.display.BitmapData;
	var bmpView : flash.display.BitmapData;
	var view : flash.display.Sprite;
	var mat : flash.geom.Matrix;
	var rnd : mt.Rand;
	var drawX : Int;
	var drawY : Int;
	var triangles : List<DelTriangle>;
	var panel : Panel;
	var interf : MC;
	var bp : BigPanel;
	var movingGeneral : Null<{ _id : Int, _p : Int, _s : GState }>;
	var placeById : IntHash<Place>;
	var placeKindByPos : IntHash<Int>;
	var map : flash.display.BitmapData;
	var mouseLock : flash.display.Sprite;
	var mouseLockClick : { x : Float, y : Float };
	var htmlCache : Hash<String>;
	var panelIndex : Int;
	var strategyMode : Bool;
	var terSprite : flash.display.Sprite;
	var debug : Bool;
	var tmp : flash.display.Sprite;
	var kingdom : Array<Bool>;

	static inline var SCALE = 0.125;
	static inline var OPAQUE = 0xFF000000;
	static inline var COL_CITY = OPAQUE | 0xF00000;
	static inline var COL_CITY_AROUND = OPAQUE | 0x800000;
	static inline var COL_PLACE = OPAQUE | 0xF10000;
	static inline var COL_PLACE_AROUND = OPAQUE | 0xFE00FE;
	static inline var COL_ROAD = OPAQUE | 0xFFFFFF;
	static inline var COL_MOUNTAIN = OPAQUE | 0x776666;
	static inline var COL_MOUNTAIN2 = OPAQUE | 0x775555;
	static inline var COL_VOLCANO = OPAQUE | 0x2237c5;
	static inline var COL_LAKE = OPAQUE | 0x404080;
	static inline var COL_FOREST = OPAQUE | 0x408040;
	static inline var COL_PLAIN = OPAQUE | 0xA0EE0F;
	static inline var COL_PLAIN2 = OPAQUE | 0xDAAF60;
	static inline var COL_DESERT = OPAQUE | 0xECEC00;
	static inline var COL_FIELD = OPAQUE | 0x90FF80;

	public function new( root, g ) {
		this.root = root;
		this.g = g;
		if( !DATA._ter.isEmpty() )
			initTriangles();
		debug = DATA._adm;
		rnd = new mt.Rand(0);
		mat = new flash.geom.Matrix();
		mat.identity();
		initKingdom();
		initZones();
		initInterf();
		initMap();
		var me = this;
		bmpView = new flash.display.BitmapData(WIDTH,HEIGHT,true,OPAQUE);
		view = new flash.display.Sprite();
		view.addChild(new flash.display.Bitmap(bmpView));
		view.addEventListener(flash.events.MouseEvent.CLICK,onClick);
		panel = cast flash.Lib.attach(__unprotect__("panel"));
		panel.visible = false;
		tmp = new flash.display.Sprite();
		tmp.addChild(panel);
		tmp.mouseEnabled = false;
		tmp.mouseChildren = false;
		interf.addChild(tmp);
		htmlCache = new Hash();
		htmlCache.set("","");
		htmlCache.set(DATA._moveto,DATA._moveto);
		panelIndex = 0;
		mouseLock = new flash.display.Sprite();
		mouseLock.graphics.beginFill(0,0);
		mouseLock.graphics.drawRect(0,0,WIDTH,HEIGHT);
		mouseLock.visible = false;
		mouseLock.addEventListener(flash.events.MouseEvent.CLICK,onClick);
		mouseLock.addEventListener(flash.events.MouseEvent.MOUSE_MOVE,onMouseMove);
	}

	function onMouseMove(_) {
		var dx = mouseLock.mouseX - mouseLockClick.x;
		var dy = mouseLock.mouseY - mouseLockClick.y;
		if( Math.sqrt(dx*dx+dy*dy) > 20 )
			mouseLock.visible = false;
	}

	function add() {
		root.addChild(view);
		root.addChild(interf);
		root.addChild(mouseLock);
	}

	function onClick(_) {
		var x = drawX + Std.int(view.mouseX/8);
		var y = drawY + Std.int(view.mouseY/8);
		updatePos(x,y,false);
		mouseLock.visible = true;
		mouseLockClick = { x : mouseLock.mouseX, y : mouseLock.mouseY };
	}

	function initTriangles() {
		var points = Lambda.array(g.places.map(function(p) return new DelPoint(p.x,p.y)));
		var dx = Math.ceil(g.width / 32);
		var dy = Math.ceil(g.height / 32);
		for( x in 0...33 ) {
			points.push(new DelPoint(x * dx,0));
			points.push(new DelPoint(x * dx,g.height));
		}
		for( y in 1...32 ) {
			points.push(new DelPoint(0,y * dy));
			points.push(new DelPoint(g.width,y * dy));
		}
		triangles = new data.Delaunay().make(points);
	}

	function initZones() {
		var bmp = new flash.display.BitmapData(g.width,g.height,true,0);
		bmpZones = bmp;
		bmp.lock();
		var tmp = new flash.display.Sprite();
		var gr = tmp.graphics;
		gr.lineStyle(1,COL_ROAD);
		for( p in g.places )
			for( l in p.links ) {
				gr.moveTo(p.x,p.y);
				gr.lineTo(l.x,l.y);
			}
		root.stage.quality = flash.display.StageQuality.LOW;
		bmp.draw(tmp);
		bmpDist = new flash.display.BitmapData(g.width,g.height,true,0);
		bmpDist.applyFilter(bmp,bmp.rect,new flash.geom.Point(0,0),new flash.filters.GlowFilter(0,1,8,8,10,3));
		for( p in g.places )
			bmp.setPixel32(p.x,p.y,COL_ROAD);
		for( x in 0...bmp.width )
			for( y in 0...bmp.height )
				if( bmp.getPixel32(x,y) == 0 ) {
					// fill with red
					bmp.floodFill(x,y,0xFFFF0000);
					// check the size
					var r = bmp.getColorBoundsRect(0xFFFFFFFF,0xFFFF0000);
					var color =
						if( r.width * r.height > g.width * g.height / 25 ) {
							var k = rnd.random(3);
							if( x == 0 && y == 0 )
								k = 0;
							switch(k) {
							case 0: COL_MOUNTAIN;
							case 1: COL_MOUNTAIN2;
							default: COL_VOLCANO;
							}
						} else if( r.width <= 2 && r.height <= 2 )
							COL_ROAD
						else if( r.width * r.height < 200 )
							COL_FIELD
						else if( rnd.random(30) == 0 )
							COL_DESERT
						else if( r.width > 5 && r.height > 5 && r.width / r.height < 1.3 && r.height / r.width < 1.3 && rnd.random(1) == 0 )
							COL_LAKE;
						else switch( rnd.random(3) ) {
						case 0: COL_FOREST;
						case 1: COL_PLAIN;
						case 2: COL_PLAIN2;
						default: throw "assert";
						}
					bmp.floodFill(x,y,color);
				}
		gr.clear();
		for( p in g.places ) {
			gr.beginFill(p.city?(COL_CITY_AROUND + p.id + (INFOS[p.id].kind<<16)):COL_PLACE_AROUND);
			gr.drawCircle(p.x,p.y,4);
		}
		bmp.draw(tmp);
		for( p in g.places )
			bmp.setPixel32(p.x,p.y,p.city?COL_CITY:COL_PLACE);
		root.stage.quality = flash.display.StageQuality.HIGH;
	}

	static inline var MAP_SCALE = 1;

	function initMap() {
		if( map != null ) map.dispose();
		map = new flash.display.BitmapData(g.width >> MAP_SCALE, g.height >> MAP_SCALE,false,0xFBEDBF);
		map.lock();
		var prev = 0;
		var bg = 0xCFAF7C;
		for( x in 0...map.width )
			for( y in 0...map.height ) {
				var col = 0, dist = 0;
				var dx = 0, dy = 0;
				while( dy < (1 << MAP_SCALE) ) {
					col = bmpZones.getPixel32((x<<MAP_SCALE) + dx,(y<<MAP_SCALE) + dy);
					dist = bmpDist.getPixel32((x<<MAP_SCALE) + dx,(y<<MAP_SCALE) + dy) >>> 24;
					col = switch( col ) {
					case COL_MOUNTAIN: if( dist < 100 ) 0xC07302 else bg;
					case COL_MOUNTAIN2: if( dist < 100 ) 0xDDDDDD else bg;
					case COL_VOLCANO: if( dist < 100 ) 0xA66D20 else bg;
					case COL_LAKE: if( dist < 100 ) 0x99C7EC else bg;
					case COL_FOREST: 0x84A443;
					case COL_PLAIN,COL_PLAIN2: 0x9EBA51;
					case COL_DESERT: 0xE6D99B;
					case COL_FIELD: 0xD0AF7A;
					default: 0;
					};
					if( col != 0 )
						break;
					dx++;
					if( dx == (1 << MAP_SCALE) ) {
						dx = 0;
						dy++;
					}
				}
				if( col == 0 )
					col = prev;
				map.setPixel32(x,y,col);
				prev = col;
			}
		map.applyFilter(map,map.rect,new flash.geom.Point(0,0),new flash.filters.BlurFilter(1.1,1.1,3));
		for( c in g.places )
			if( c.city )
				map.setPixel(c.x>>MAP_SCALE,c.y>>MAP_SCALE,0xFFFFFF);
		var mat = new flash.geom.Matrix();
		mat.identity();
		mat.scale(1 / (1 << MAP_SCALE), 1 / (1 << MAP_SCALE));
		if( strategyMode ) {
			mat.scale(1/8,1/8);
			map.draw(terSprite,mat);
		} else {
			var tmp1 = null, tmp2 = null;
			tmp1 = makeTerritory(0x0055CC,0.3,DATA._vas);
			tmp2 = makeTerritory(0x0055CC,0.3,DATA._ter);
			if( tmp1 != null ) map.draw(tmp1,mat,flash.display.BlendMode.MULTIPLY);
			if( tmp2 != null ) map.draw(tmp2,mat,flash.display.BlendMode.MULTIPLY);
		}
		map.unlock();
	}

	function buildGeneralPath( target : Place ) {
		var g = movingGeneral;
		var from = placeById.get(g._p);
		var oldK = kingdom[from.id];
		var pids = switch( g._s ) {
			case GMove(to,k):
				var to = placeById.get(to);
				var dist = Math.sqrt(from.dist(to));
				[{ p : from, d : dist * k / 100.0 },{ p : to, d : dist * (1 - k / 100.0) }];
			default:
				kingdom[from.id] = true;
				[{ p : from, d : 0. }];
		};
		for( p in this.g.places )
			p.tag = -1;
		updateDistMap(target,1);
		kingdom[from.id] = oldK;
		var p0 = null, min = 1e10;
		for( p in pids ) {
			var d = p.p.tag + p.d;
			if( p.p.tag > 0 && d < min ) {
				p0 = p.p;
				min = d;
			}
		}
		if( p0 == null )
			return null;
		var path = switch( g._s ) { case GMove(_,_): [p0]; default: []; };
		while( p0 != target ) {
			var min = 1e10, pnext = null;
			for( p in p0.links )
				if( p.tag > 0 && p.tag < min ) {
					min = p.tag;
					pnext = p;
				}
			path.push(pnext);
			p0 = pnext;
		}
		return path;
	}

	function updateDistMap( from : Place, dist : Float ) {
		var infos = DATA._infos;
		from.tag = dist;
		for( p in from.links ) {
			if( !kingdom[p.id] && infos[p.id]._u != null )
				continue;
			var d = dist + Math.sqrt(p.dist(from));
			if( p.tag > 0 && p.tag < d )
				continue;
			updateDistMap(p,d);
		}
	}

	function showPath( path : Array<Place> ) {
		var g = movingGeneral;
		var from = placeById.get(g._p);
		var px, py;
		switch( g._s ) {
		case GMove(to,k):
			var to = placeById.get(to);
			px = from.x + Std.int((to.x - from.x) * k / 100.0);
			py = from.y + Std.int((to.y - from.y) * k / 100.0);
		default:
			px = from.x;
			py = from.y;
		}
		tmp.graphics.moveTo(px*8,py*8);
		tmp.graphics.lineStyle(3,0xFFFFFF,0.5);
		for( p in path )
			tmp.graphics.lineTo(p.x*8,p.y*8);
	}

	function clearPath() {
		tmp.graphics.clear();
	}

	function onPlaceOver( p : Place, r : RollShape, flag ) {
		if( !flag ) {
			clearPath();
			hidePanel();
			return;
		}
		var inf = INFOS[p.id];
		r.buttonMode = true;
		if( movingGeneral != null ) {
			var path = buildGeneralPath(p);
			if( path == null ) {
				r.buttonMode = false;
				return;
			}
			showPath(path);
			showPanel( p.x * 8, p.y * 8, inf.name, DATA._moveto );
			return;
		}
		showPanel( p.x * 8, p.y * 8, inf.name, DATA._infUrl+"c="+inf.id );
	}

	function onPlaceClick( p : Place ) {
		var url;
		var force = false;
		if( movingGeneral != null ) {
			var path = buildGeneralPath(p);
			if( path == null )
				return;
			p = path.shift();
			url = DATA._moveUrl.split("::gid::").join(Std.string(movingGeneral._id));
			url += "p="+Lambda.map(path,function(p) return INFOS[p.id].id).join(":")+";";
			force = true;
		} else {
			url = DATA._selectUrl;
			updatePos(p.x,p.y,true);
		}
		var inf = INFOS[p.id];
		htmlCache.remove(DATA._infUrl+"c="+inf.id);
		reload(url+"c="+inf.id,force);
	}

	function reload( url, ?force ) {
		if( force ) {
			flash.Lib.getURL(new flash.net.URLRequest(url),"_self");
			return;
		}
		flash.external.ExternalInterface.call("js.App.reload","content",url,"reload");
	}

	function onGeneralOver( g : { _id : Int, _u : String, _n : String }, r : MC, flag ) {
		if( !flag ) {
			hidePanel();
			return;
		}
		if( g._n == null ) g._n = "G#"+g._id;
		showPanel( r.x, r.y, g._n, DATA._infUrl+"g="+g._id );
	}

	function onGeneralClick( g : { _id : Int }, x : Int, y : Int ) {
		htmlCache.remove(DATA._infUrl+"g="+g._id);
		reload(DATA._selectUrl+"g="+g._id);
		updatePos(x,y,true);
	}

	function updatePos( x, y, set ) {
		if( set ) {
			DATA._x = x;
			DATA._y = y;
		}
		this.display(x,y);
		minimap.api._updatePos.call([x >> MAP_SCALE,y >> MAP_SCALE,set]);
	}

	function initKingdom() {
		kingdom = new Array();
		var cross = DATA._cross;
		for( i in 0...INFOS.length ) {
			var u = INFOS[i].user;
			if( u == null ) {
				kingdom[i] = true;
				continue;
			}
			for( user in cross )
				if( user == u ) {
					kingdom[i] = true;
					break;
				}
		}
	}

	function initInterf() {
		interf = new MC();
		var dmanager = new mt.DepthManager(interf);
		placeById = new IntHash();
		placeKindByPos = new IntHash();
		for( p in g.places ) {
			var r = new RollShape();
			r.x = p.x * 8;
			r.y = p.y * 8;
			r.buttonMode = true;
			r.alpha = 0;
			dmanager.add(r,0);
			var inf = INFOS[p.id];
			//r.gotoAndStop((inf.kind == null) ? 1 : 2);
			r.stop();
			placeById.set(inf.id,p);
			placeKindByPos.set((p.x << 16) | p.y,inf.kind);
			mt.flash.Event.over.bind(r,callback(onPlaceOver,p,r,true));
			mt.flash.Event.out.bind(r,callback(onPlaceOver,p,r,false));
			mt.flash.Event.click.bind(r,callback(onPlaceClick,p));
		}
		var gcount = new Array();
		var tot = new Array();
		for( g in DATA._gen ) {
			var n : Int = tot[g._p];
			tot[g._p] = n + 1;
		}
		for( g in DATA._gen ) {
			var c = placeById.get(g._p);
			var px = -1., py = -1., flip = false;
			switch(g._s) {
			case GMove(t,k):
				var ct = placeById.get(t);
				var dx : Float = ct.x - c.x;
				var dy : Float = ct.y - c.y;
				var d = Math.sqrt(dx*dx+dy*dy);
				var walk = (4 + (d - 8) * k / 100.0) / d;
				px = c.x + dx * walk;
				py = c.y + dy * walk;
				flip = ct.x < c.x;
			default:
				var n : Int = gcount[c.id];
				var a;
				if( tot[g._p] <= 9 ) {
					a = ((n + 1) >> 1) * 0.7;
					if( n & 1 == 0 ) a *= -1;
					a += Math.PI / 2;
				} else
					a = Math.PI / 2 + Math.PI * 2 * n / tot[g._p];
				px = c.x + Math.cos(a) * 4;
				py = c.y + Math.sin(a) * 4;
				gcount[c.id] = n + 1;
			}
			var r : {> MC, but : MC } = cast dmanager.attach(__unprotect__("general"),0);
			switch(g._s) {
			case GMove(t,k):
				var mc : flash.display.MovieClip = cast r.sub;
				mc.gotoAndPlay(1+Std.random(mc.totalFrames));
				r.stop();
			case GWait:
				r.stop();
				var mc : flash.display.MovieClip = cast r.sub;
				mc.stop();
			case GBattle(att):
				if( !att ) flip = true;
				r.gotoAndStop(2);
			case GFortify:
				r.gotoAndStop(3);
			}
			r.x = Std.int(px * 8);
			r.y = Std.int(py * 8);
			r.scaleX = flip ? -1 : 1;
			r.but.x += r.x;
			r.but.y += r.y;
			dmanager.add(r.but,0);
			r.but.buttonMode = true;
			r.mouseEnabled = false;
			r.mouseChildren = false;
			var m = new mt.flash.ColorMatrix();
			m.adjustHue(g._c);
			r.filters = [new flash.filters.ColorMatrixFilter(m.matrix)];
			mt.flash.Event.over.bind(r.but,callback(onGeneralOver,g,r,true));
			mt.flash.Event.out.bind(r.but,callback(onGeneralOver,g,r,false));
			mt.flash.Event.click.bind(r.but,callback(onGeneralClick,g,Std.int(px),Std.int(py)));
		}
		dmanager.ysort(0);
	}

	function hidePanel() {
		panel.visible = false;
		panelIndex++;
		flash.external.ExternalInterface.call("js.King.hidePanel");
	}

	function showPanel( x : Float, y : Float, title, url ) {
		var data = htmlCache.get(url);
		var me = this;
		var show = function(data:String) flash.external.ExternalInterface.call("js.King.showPanel",(x-me.drawX)*8,(y-me.drawY)*8,StringTools.htmlEscape(title),data);
		if( data == null ) {
			data = '<div class="reload"></div>';
			haxe.Timer.delay(callback(loadPanelData,panelIndex,url,show),500);
		}
		show(data);
	}

	function loadPanelData( index : Int, url : String, show : String -> Void ) {
		if( index != panelIndex )
			return;
		htmlCache.set(url,"");
		var me = this;
		var h = new haxe.Http(url);
		h.onError = function(e) h.onData(e);
		h.onData = function(data) {
			if( data.substr(0,9) == "<!DOCTYPE" )
				data = "&nbsp;";
			me.htmlCache.set(url,data);
			if( me.panelIndex == index )
				show(data);
		};
		h.request(false);
	}

	function recall( mc : MC ) {
		var b = mc.getBounds(root);
		if( b.left < 0 ) mc.x -= b.left;
		if( b.top < 0 ) mc.y -= b.top;
		if( b.right > WIDTH ) mc.x += WIDTH - b.right;
		if( b.bottom > HEIGHT ) mc.y += HEIGHT - b.bottom;
	}

	function draw( mcs : Array<flash.display.MovieClip>, px : Int, py : Int ) {
		mat.tx = (px - drawX) << 3;
		mat.ty = (py - drawY) << 3;
		bmpView.draw(mcs[rnd.random(mcs.length)],mat);
	}

	function drawRoads() {
		var tmp = new flash.display.Sprite();
		var gr = tmp.graphics;
		gr.lineStyle(1,0x813C0A);
		for( p in g.places )
			for( l in p.links ) {
				if( p.id < l.id ) continue;
				var dx : Float = l.x - p.x;
				var dy : Float = l.y - p.y;
				var d = Math.sqrt(dx*dx+dy*dy);
				var u = 0.1;
				dx /= d;
				dy /= d;
				var x = p.x * 10. + dx * 3 * 8;
				var y = p.y * 10. + dy * 3 * 8;
				for( k in 0...(Std.int(d/u) >> 3) - 6 ) {
					gr.moveTo(x,y);
					x += dx * 2;
					y += dy * 2;
					gr.lineTo(x,y);
					x += dx * 6;
					y += dy * 6;
				}
			}
		mat.tx = -drawX*8;
		mat.ty = -drawY*8;
		mat.a = .8;
		mat.d = .8;
		bmpView.draw(tmp,mat);
		mat.identity();
	}

	function makeTerritory( color, alpha, ter : List<Int>, ?edges = false ) {
		if( ter.length == 0 )
			return null;
		rnd.initSeed(0);
		var tmp = new flash.display.Sprite();
		var gr = tmp.graphics;
		var selected = [];
		for( id in ter ) {
			for( p in g.places )
				if( INFOS[p.id].id == id ) {
					selected[p.id] = true;
					break;
				}
		}
		for( t in triangles ) {
			var gx = (t.p1.x + t.p2.x + t.p3.x) / 3;
			var gy = (t.p1.y + t.p2.y + t.p3.y) / 3;
			if( selected[t.p1.id] ) {
				gr.beginFill(color,alpha);
				gr.moveTo(t.p1.x,t.p1.y);
				gr.lineTo((t.p1.x + t.p2.x) / 2, (t.p1.y + t.p2.y) / 2);
				if( edges || selected[t.p2.id] || selected[t.p3.id] ) {
					gr.lineTo(gx,gy);
					gr.lineTo((t.p1.x + t.p3.x) / 2, (t.p1.y + t.p3.y) / 2);
				} else
					gr.curveTo(gx,gy,(t.p1.x + t.p3.x) / 2, (t.p1.y + t.p3.y) / 2);
				gr.endFill();
			}
			if( selected[t.p2.id] ) {
				gr.beginFill(color,alpha);
				gr.moveTo(t.p2.x,t.p2.y);
				gr.lineTo((t.p2.x + t.p1.x) / 2, (t.p2.y + t.p1.y) / 2);
				if( edges || selected[t.p1.id] || selected[t.p3.id] ) {
					gr.lineTo(gx,gy);
					gr.lineTo((t.p2.x + t.p3.x) / 2, (t.p2.y + t.p3.y) / 2);
				} else
					gr.curveTo(gx,gy,(t.p2.x + t.p3.x) / 2, (t.p2.y + t.p3.y) / 2);
				gr.endFill();
			}
			if( selected[t.p3.id] ) {
				gr.beginFill(color,alpha);
				gr.moveTo(t.p3.x,t.p3.y);
				gr.lineTo((t.p3.x + t.p2.x) / 2, (t.p3.y + t.p2.y) / 2);
				if( edges || selected[t.p1.id] || selected[t.p2.id] ) {
					gr.lineTo(gx,gy);
					gr.lineTo((t.p3.x + t.p1.x) / 2, (t.p3.y + t.p1.y) / 2);
				} else
					gr.curveTo(gx,gy,(t.p3.x + t.p1.x) / 2, (t.p3.y + t.p1.y) / 2);
				gr.endFill();
			}
		}
		return tmp;
	}

	function drawTerritory( color, alpha, ter ) {
		var tmp = makeTerritory(color,alpha,ter);
		if( tmp == null ) return;
		mat.tx = -drawX*8;
		mat.ty = -drawY*8;
		mat.a = 8;
		mat.d = 8;
		var bmpTmp = new flash.display.BitmapData(bmpView.width+16,bmpView.height+16,true,0);
		bmpTmp.draw(tmp,mat);
		bmpTmp.applyFilter(bmpTmp,bmpTmp.rect,new flash.geom.Point(0,0),new flash.filters.GlowFilter(color,0.5,8,8,3,3));
		mat.identity();
		mat.tx = -8;
		mat.ty = -8;
		bmpView.draw(bmpTmp,mat,flash.display.BlendMode.MULTIPLY);
		bmpTmp.dispose();
	}

	function drawTerritories() {
		var uter = new Hash();
		var inf = DATA._infos;
		if( inf == null )
			return;
		if( terSprite != null ) {
			interf.addChildAt(terSprite,0);
			return;
		}
		terSprite = new flash.display.Sprite();
		interf.addChildAt(terSprite,0);
		for( i in 0...inf.length ) {
			var u = inf[i]._u;
			if( u == null )
				u = "";
			var l = uter.get(u);
			if( l == null ) {
				l = new List();
				uter.set(u,l);
			}
			l.add(INFOS[i].id);
		}
		var comp = [0x00,0x80,0xFF];
		var colors = new Array();
		for( r in comp )
			for( g in comp )
				for( b in comp )
					colors.push((r<<16)|(g<<8)|b);
		colors.shift(); // black
		mat.tx = -drawX*8;
		mat.ty = -drawY*8;
		mat.a = 8;
		mat.d = 8;
		var me = this;
		for( u in uter.keys() ) {
			var cid = 0;
			for( i in 0...u.length )
				cid = cid * 11 + u.charCodeAt(i);
			var nobody = (u == "");
			cid &= 0xFFFFFF;
			var tmp = makeTerritory(nobody ? 0 : colors[cid%colors.length],1.0,uter.get(u),true);
			tmp.scaleX = tmp.scaleY = 8;
			tmp.mouseEnabled = true;
			tmp.alpha = 0.5;
			if( !nobody ) tmp.filters = [new flash.filters.GlowFilter(0,1,1.3,1.3,500,2)];
			tmp.addEventListener(flash.events.MouseEvent.MOUSE_OVER,function(_) me.showPanel(me.root.mouseX,me.root.mouseY,nobody?DATA._nob:u,""));
			tmp.addEventListener(flash.events.MouseEvent.MOUSE_OUT,function(_) me.hidePanel());
			terSprite.addChild(tmp);
		}
		terSprite.addEventListener(flash.events.MouseEvent.CLICK,function(_) me.onClick(null));
		mat.identity();
	}

	function redraw() {
		var width = Math.ceil(bmpView.width * SCALE);
		var height = Math.ceil(bmpView.height * SCALE);
		display(drawX + (width>>1), drawY + (height>>1));
	}

	function display( x : Int, y : Int ) {

		bmpView.lock();
		bmpView.fillRect(bmpView.rect,OPAQUE);

		var width = Math.ceil(bmpView.width * SCALE);
		var height = Math.ceil(bmpView.height * SCALE);

		if( x < 0 ) x = 0;
		if( y < 0 ) y = 0;
		if( x > g.width ) x = g.width;
		if( y > g.height ) y = g.height;

		x -= width >> 1;
		y -= height >> 1;

		// init clips
		var clips = {
			bg : null,
			mountainGround : null,
			volcanoGround : null,
			forestGround : null,
			desertGround : null,
			plainGround : null,
			plain2Ground : null,
			lakeGround : null,
			mountain : null,
			mountain2 : null,
			volcano : null,
			city : null,
			house : null,
			tree : null,
			plainelements : null,
			desert : null,
			field : null,
		};
		for( name in Reflect.fields(clips) ) {
			var mc = flash.Lib.attach(name);
			var frames = [mc];
			for( i in 2...mc.totalFrames + 1 ) {
				var mc = flash.Lib.attach(name);
				mc.gotoAndStop(i);
				frames.push(mc);
			}
			Reflect.setField(clips,name,frames);
		}

		// base
		this.drawX = x;
		this.drawY = y;
		var xmin = x;
		var xmax = x + width;
		var ymin = y;
		var ymax = y + height;
		var bmpLake = new flash.display.BitmapData(bmpView.width+16,bmpView.height+16,true,0);
		draw(clips.bg,x,y);

		// draw grounds
		for( py in ymin - 1...ymax + 4 )
			for( px in xmin - 2...xmax + 2 ) {
				rnd.initSeed(px + py * g.width);
				var c : Int = bmpZones.getPixel32(px,py);
				var dist : Int = bmpDist.getPixel32(px,py) >>> 24;
				switch( c ) {
				case 0, COL_MOUNTAIN: if( rnd.random(15) == 0 ) draw(clips.mountainGround,px,py);
				case COL_MOUNTAIN2: if( rnd.random(20) == 0 ) draw(clips.plainGround,px,py); // gray & snow mountains
				case COL_VOLCANO: if( rnd.random(1) == 0 ) draw(clips.volcanoGround,px,py);
				case COL_FOREST: if( rnd.random(20) == 0 ) draw(clips.forestGround,px,py);
				case COL_DESERT:
					if( rnd.random(10) == 0 ) draw(clips.desertGround,px,py);
					if( dist < 150 && rnd.random(3) == 0 ) draw(clips.desert,px,py);
				case COL_PLAIN: if( rnd.random(20) == 0 ) draw(clips.plainGround,px,py);	// green plains
				case COL_PLAIN2: if( rnd.random(50) == 0 ) draw(clips.plain2Ground,px,py); // cracks
				case COL_LAKE:
					if( dist < 100 ) {
						var old = bmpView;
						bmpView = bmpLake;
						draw(clips.lakeGround,px+1,py+1);
						bmpView = old;
					}
				}
			}
		var mc = flash.Lib.attach(__unprotect__("lakeGlow"));
		for( f in mc.getChildAt(0).filters )
			bmpLake.applyFilter(bmpLake,bmpLake.rect,new flash.geom.Point(0,0),f);
		mat.tx = -8;
		mat.ty = -8;
		bmpView.draw(bmpLake,mat);
		bmpLake.dispose();

		drawRoads();
		if( terSprite != null && terSprite.parent != null )
			interf.removeChild(terSprite);
		if( strategyMode ) {
			if( triangles == null )
				initTriangles();
			drawTerritories();
		} else {
			drawTerritory(0x0055CC,0.07,DATA._vas);
			drawTerritory(0x0055CC,0.08,DATA._ter);
		}

		// draw elements
		var pos = 0;
		var mc = flash.Lib.attach(__unprotect__("city"));
		mc.gotoAndStop("place");
		var placeIndex = mc.currentFrame - 1;
		var houses = new Array();
		for( x in [2,4,4] ) {
			var tmp = new Array();
			for( k in 0...x ) {
				var h = clips.house[pos++];
				if( h == null ) throw "assert "+(--pos);
				tmp.push(h);
			}
			houses.push(tmp);
		}
		houses.push(houses[houses.length-1]);
		var infos = DATA._infos;
		for( py in ymin - 1...ymax + 4 )
			for( px in xmin - 2...xmax + 2 ) {
				rnd.initSeed(px + py * g.width);
				var c : Int = bmpZones.getPixel32(px,py);
				var dist : Int = bmpDist.getPixel32(px,py) >>> 24;
				switch( c ) {
				case 0, COL_MOUNTAIN:
					if( dist < 100 && rnd.random(3) == 0  ) draw(clips.mountain,px,py);
				case COL_MOUNTAIN2:
					if( dist < 100 && rnd.random(3) == 0  ) draw(clips.mountain2,px,py);
				case COL_VOLCANO:
					if( dist < 100 && rnd.random(5) == 0  ) draw(clips.volcano,px,py);
				case COL_CITY:
					var kind = placeKindByPos.get((px << 16) | py);
					draw([clips.city[kind]],px,py);
				case COL_PLACE:
					var kind : Int = placeKindByPos.get((px << 16) | py);
					draw([clips.city[kind + placeIndex]],px,py);
				case COL_PLACE_AROUND:
				case COL_FOREST:
					if( rnd.random(100-dist) <= 50 ) draw(clips.tree,px,py);
				case COL_PLAIN:
					if( rnd.random(100-dist) <= 1 ) draw(clips.plainelements,px,py);
				case COL_FIELD:
					if( rnd.random(100) == 0 ) draw(clips.field,px,py);
				default:
					if( c & 0xFFF00000 == COL_CITY_AROUND ) {
						var pid = c&0xFFFF;
						if( rnd.random(200) < ((infos == null)?20:infos[pid]._s) )
							draw(houses[(c>>16)&15],px,py);
					}
				}
			}

		bmpView.unlock();

		interf.x = -drawX * 8;
		interf.y = -drawY * 8;
	}

	function _toggleStrategy() {
		strategyMode = !strategyMode;
		redraw();
		initMap();
		minimap.api._refresh.call([]);
	}

	function _enableMove( gid : Int, b : Bool ) {
		if( bp != null ) {
			root.removeChild(bp);
			bp = null;
			movingGeneral = null;
			return;
		}
		if( !b )
			return;
		var g = null;
		for( g2 in DATA._gen )
			if( g2._id == gid ) {
				g = g2;
				break;
			}
		if( g == null )
			return;
		bp = new BigPanel();
		bp.title.text = DATA._move.split("::name::").join(g._n);
		bp.message.text = "";
		root.addChild(bp);
		movingGeneral = g;
	}

	function _getMap() : MiniMapData {
		return {
			width : map.width,
			height : map.height,
			bytes : haxe.io.Bytes.ofData(map.getPixels(map.rect)),
			x : drawX >> MAP_SCALE,
			y : drawY >> MAP_SCALE,
			viewX : Std.int(WIDTH * SCALE) >> MAP_SCALE,
			viewY : Std.int(HEIGHT * SCALE) >> MAP_SCALE,
			selX : DATA._x >> MAP_SCALE,
			selY : DATA._y >> MAP_SCALE,
		};
	}

	function _setMapPos( mx : Int, my : Int ) {
		display(mx << MAP_SCALE,my << MAP_SCALE);
	}

	static var DATA : data.MapData;
	static var INFOS : Array<{ id : Int, name : String, user : Null<String>, kind : Null<Int> }>;
	static var inst : MapView;
	static var minimap : haxe.remoting.AsyncConnection;

	static function initInfos( gen : data.MapGenerator, cities : String ) {
		var arr = new Array();
		var infos = DATA._infos;
		var i = 0;
		var cities = cities.split(":");
		var count = [0,15,25,50,150];
		for( p in gen.places ) {
			var inf = infos[i];
			var str = cities[i].split("#");
			var k = inf._s;
			if( p.city ) {
				var p = 1;
				while( k >= count[p] )
					p++;
				p--;
				var ratio = Std.int((inf._s - count[p]) * 100 / (count[p+1] - count[p]));
				inf._s = ratio;
				k = p;
			}
			arr[i] = { id : Std.parseInt(str[0]), name : str[1], user : inf._u, kind : k };
			i++;
		}
		return arr;
	}

	static function init(_) {
		var root = flash.Lib.current;
		root.removeEventListener(flash.events.Event.ENTER_FRAME,init);
		var parameters : {} = cast root.loaderInfo.parameters;
		var gen = new data.MapGenerator();
		gen.unserialize(Reflect.field(parameters,"data"));
		if( Reflect.field(parameters,"infos") != null ) {
			Codec.addObfuType("data.GState",GState);
			DATA = Codec.getData("infos");
			INFOS = initInfos(gen,Reflect.field(parameters,"cities"));
		} else {
			var gid = 0;
			var general = function(p,?t) {
				var s = if( t != null ) GMove(t,Std.random(50)) else [GWait,GFortify,GBattle(true),GBattle(false)][Std.random(4)];
				return { _id : ++gid, _n : "G#"+gid, _u : null, _p : p, _s : s, _c : 220 };
			};
			DATA = {
				_x : 50,
				_y : 50,
				_selectUrl : "#",
				_moveUrl : "#",
				_infUrl : "#",
				_infos : null,
				_ter : Lambda.list([43,280,157]),
				_vas : Lambda.list([84,391,241,216,300,400]),
				_move : "Déplacer ::name::",
				_moveto : "Déplacer le général ici.",
				_nob : "",
				_gen : [
					general(43),
					general(43),
					general(43),
					general(43,280),
					general(43,280),
					general(43,280),
				],
				_adm : true,
				_cross : [],
			};
			INFOS = Lambda.array(gen.places.map(function(p) {
				return {
					id : p.id,
					name : "#"+p.id,
					user : null,
					kind : Std.random(3),
				}
			}));
		}
		for( x in DATA._ter )
			DATA._vas.add(x);
		var ctx = new MC();
		root.addChild(ctx);
		inst = new MapView(ctx,gen);
		if( Reflect.field(parameters,"viewZones") != null ) {
			root.addChild(new flash.display.Bitmap(inst.bmpZones));
			var bmp = new flash.display.Bitmap(inst.bmpDist);
			bmp.alpha = 0.5;
			root.addChild(bmp);
			return;
		}
		// display
		inst.add();
		inst.display(DATA._x,DATA._y);
		// init connection
		var ctx = new haxe.remoting.Context();
		ctx.addObject("api",inst);
		var cnx = haxe.remoting.ExternalConnection.jsConnect("cnx",ctx);
		minimap = haxe.remoting.FlashJsConnection.connect("cnx","minimap",ctx);
		minimap.setErrorHandler(function(_) {});
	}

	static function main() {
		flash.system.Security.allowDomain("*");
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME,init);
	}

}
