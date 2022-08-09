import DungeonData;
import DungeonCodec;
import mt.bumdum.Lib;

private enum PerlinType {
	PNormal;
	PDense;
	PFew;
}

private typedef MC = flash.MovieClip;
private typedef LevelSkin = {
	key		: String,
	w		: String,
	g		: String,
	mask	: Int,
	fog		: Int,
	perlin	: PerlinType,
	over	: Array<String>,
}

private typedef Fx = {
	cpt		: Float,
	mc		: flash.MovieClip,
	update	: Fx->Bool,
}

class View {

	static var DEFAULT_SKIN = "labo";

	static var SKINS : Array<LevelSkin> = [
		{ key:"crypt",		w:"crypt",	g:"crypt",	mask:100,	fog:0x27191c,	perlin:PNormal,		over:[null,"ruinPurple"] },
		{ key:"crypt2",		w:"crypt",	g:"sewer",	mask:100,	fog:0x27191c,	perlin:PDense,		over:["ruinPurple","square"] },
		{ key:"cavern",		w:"cavern",	g:"cavern",	mask:100,	fog:0x392429,	perlin:PNormal,		over:["ruin","grass"] },
		{ key:"cavern2",	w:"cavern",	g:"hell",	mask:70,	fog:0x27191c,	perlin:PNormal,		over:["dirt","grass"] },
		{ key:"cavern3",	w:"cavern",	g:"desert",	mask:70,	fog:0x27191c,	perlin:PDense,		over:["ruinPurple","dirt"] },
		{ key:"desert",		w:"cavern",	g:"desert",	mask:50,	fog:0x3d3325,	perlin:PFew,		over:["dirt","grass"] },
		{ key:"sewer",		w:"sewer",	g:"sewer",	mask:70,	fog:0x37321e,	perlin:PFew,		over:["creep","dirt"] },
		{ key:"sewer2",		w:"sewer",	g:"sewer",	mask:100,	fog:0x37321e,	perlin:PFew,		over:[null,"creep"] },
		{ key:"sewer3",		w:"sewer",	g:"cavern",	mask:100,	fog:0x37321e,	perlin:PFew,		over:[null,"creep"] },
		{ key:"mine",		w:"mine",	g:"desert",	mask:60,	fog:0x352c20,	perlin:PDense,		over:["dirt",null] },
		{ key:"mine2",		w:"mine",	g:"cavern",	mask:100,	fog:0x352c20,	perlin:PNormal,		over:["dirt","grassDark"] },
		{ key:"ruin",		w:"ruin",	g:"cavern",	mask:100,	fog:0x252730,	perlin:PNormal,		over:["square","grass"] },
		{ key:"ruin2",		w:"ruin",	g:"sewer",	mask:100,	fog:0x27191c,	perlin:PNormal,		over:[null,"ruin"] },
		{ key:"ruin3",		w:"ruin",	g:"grass",	mask:60,	fog:0x30371e,	perlin:PNormal,		over:["ruin","grass"] },
		{ key:"ruin4",		w:"ruin",	g:"hell",	mask:100,	fog:0x27191c,	perlin:PDense,		over:["ruinPurple","square"] },
		{ key:"hell",		w:"hell",	g:"hell",	mask:100,	fog:0x330d0d,	perlin:PNormal,		over:["ruin","creep"] },
		{ key:"hell2",		w:"hell",	g:"cavern",	mask:100,	fog:0x330d0d,	perlin:PDense,		over:["creep","ruin"] },
		{ key:"forest",		w:"forest",	g:"grass",	mask:0,		fog:0x30371e,	perlin:PDense,		over:["dirt","grassDark"] },
		{ key:"forest2",	w:"forest",	g:"cavern",	mask:30,	fog:0x30371e,	perlin:PFew,		over:["ruinPurple","grassDark"] },
		{ key:"forest3",	w:"forest",	g:"grass",	mask:60,	fog:0x30371e,	perlin:PNormal,		over:["grassDark","grass"] },
		{ key:"forest4",	w:"forest",	g:"cavern",	mask:100,	fog:0x2E2431,	perlin:PNormal,		over:["ruinPurple","grassDark"] },
		{ key:"oasis",		w:"forest",	g:"desert",	mask:30,	fog:0x433023,	perlin:PNormal,		over:[null,"dirt"] },
		{ key:"oasis2",		w:"forest",	g:"desert",	mask:30,	fog:0x433023,	perlin:PDense,		over:[null,"grass"] },
		{ key:"cave",		w:"cavern",	g:"grass",	mask:100,	fog:0x222615,	perlin:PDense,		over:["grassDark","grass"] },
		{ key:"hell_oasis",	w:"hell",	g:"desert",	mask:0,		fog:0x330d0d,	perlin:PNormal,		over:["dirt","grass"] },
		{ key:"pyramid",	w:"egypt",	g:"desert",	mask:60,	fog:0x433023,	perlin:PNormal,		over:["dirt",null] },
		{ key:"pyramid2",	w:"egypt",	g:"hell",	mask:60,	fog:0x433023,	perlin:PNormal,		over:["ruinPurple",null] },
		{ key:"tomb",		w:"egypt",	g:"crypt",	mask:100,	fog:0x433023,	perlin:PFew,		over:["ruinPurple","square"] },
		{ key:"tomb2",		w:"ruin",	g:"desert",	mask:100,	fog:0x3d3325,	perlin:PDense,		over:[null,"square"] },
		{ key:"tomb3",		w:"ruin",	g:"crypt",	mask:100,	fog:0x330d0d,	perlin:PDense,		over:[null,"ruinPurple"] },
		{ key:"cuzco",		w:"forest", g:"sewer",  mask:20,	fog:0x30371e,	perlin:PDense,		over:["ruin",null] },
		
		{ key:"labo",		w:"labo",	g:"labo",	mask:100,	fog:0x0d1127,	perlin:PDense,		over:[null,"grassLabo"] },
	];

	public static inline var GROUND_FRAMES = 30;
	public static inline var WALL_FRAMES = 10;
	public static inline var CX = 9;
	public static inline var CY = 9;
	public static inline var SIZE = 40;

	var dm : mt.DepthManager;
	var dtmp : mt.DepthManager;
	var levelMC : MC;
	var dinozMC : MC;
	var dinoz : Array<Dino>;
	var width : Int;
	var height : Int;
	var d : DungeonStruct;
	var arrows : {>MC, _u : MC, _d : MC, _l : MC, _r : MC, _cu : MC, _cd : MC, _i : MC };
	var scrolling : Bool;
	var scrollDone : Void -> Void;
	var h : haxe.Http;
	var monsters : Array<{> MC, _p0 : {> MC, _p1 : {> MC, _anim : MC }, _box : MC }}>;
	var view : { dx : Float, dy : Float, ix : Int, iy : Int };
	var posX : Int;
	var posY : Int;
	var posL : Int;
	var zonesBitmap : flash.display.BitmapData;
	var groundBitmap : flash.display.BitmapData;
	var overgroundBitmap : flash.display.BitmapData;
	var fogBitmap : flash.display.BitmapData;
	var zonesIds : Array<Int>;
	var roomIds : Array<Array<Array<Int>>>;
	var overMaps : Array<Array<Array<Int>>>;
	var skin : LevelSkin;
	var fl_fog : Bool;
	var mask : flash.MovieClip;
	var commands : Array<DungeonCommand>;
	var fxList : Array<Fx>;
	var simpleFx : Array<MC>;
	var winMsg : MC;
	var posLabel : flash.TextField;


	function new(root) {
		dm = new mt.DepthManager(root);
		var codec = new DungeonCodec();
		if( !codec.decode(DATA._d) )
			throw "Invalid data";
		//trace("on init avec les data décodées");
		this.d = codec.d;
		this.width = d.width;
		this.height = d.height;
		setupLevel();


		setSkin(DATA._skin);
		fl_fog = false;

		initZones();
		commands = new Array();
		// bg
		root.beginFill(skin.fog);
		root.lineTo(400,0);
		root.lineTo(400,400);
		root.lineTo(0,400);
		root.endFill();
		// init
		var count = 0;
		var me = this;
		fxList = new Array();
		simpleFx = new Array();
		monsters = new Array();
		levelMC = dm.empty(0);
		dtmp = new mt.DepthManager(levelMC);
		dinozMC = dtmp.empty(2);
		dinoz = new Array();
		var k = 99;
		for( inf in DATA._group ) {
			var d = new Dino(inf,dinozMC.createEmptyMovieClip("d"+k,k--));
			count++;
			d.flip = DATA._dir;
			d.onLoaded = function() if( --count == 0 ) me.onLoaded();
			dinoz.push(d);
		}


		overMaps = new Array();
		for (i in 0...3) {
			overMaps[i] = new Array();
			for( px in 0...width ) {
				overMaps[i][px] = new Array();
			}
		}

	}

	function setupLevel() {
		// entrance
		d.levels[d.start.l].rooms[0].doors.push({ x : d.start.x, y : d.start.y, up : false, key : null });
		// exit
		d.levels[d.exit.l].rooms[0].doors.push({ x : d.exit.x, y : d.exit.y, up : true, key : null });
		// blocks
		for( l in d.levels )
			for( r in l.rooms ) {
				if( r.item == null ) continue;
				switch( r.item.k ) {
				case IScenario:
					switch( DATA._sicons[r.item.v] ) {
					case DIBlock: l.table[r.item.x][r.item.y] = false;
					default:
					}
				default:
				}
			}
	}

	function setSkin(key:String) {
		for (s in SKINS) {
			if( s.key==key) {
				skin = s;
				return;
			}
		}
	}

	function initZones() {
		zonesBitmap = new flash.display.BitmapData(width,height);
		var seed = if( DATA._url == null ) Std.random(9999) else 0;
//		zonesBitmap.perlinNoise(10,10,5,0,true,true,5);
		switch (skin.perlin) {
			case PDense	: zonesBitmap.perlinNoise(5,5,4,seed,true,true,5);
			case PFew	: zonesBitmap.perlinNoise(7,7,4,seed,true,true,5);
			default		: zonesBitmap.perlinNoise(7,7,1,seed,true,true,5);

		}
		zonesIds = new Array();
		for( i in 0...256 ) {
			var k = switch(skin.perlin) {
				case PFew	: if( i < 60 ) 2 else if( i < 75 ) 1 else 0;
				default		: if( i < 85 ) 2 else if( i < 115 ) 1 else 0;
			}
			zonesIds.push(k);
		}

/***
		var pixels = [0xFF0000FF,0xFF00FF00,0xFFFF0000];
		var debug = new flash.display.BitmapData(width,height);
//		var t = levels[DATA._l].table;
		for( x in 0...width )
			for( y in 0...height )
				if( true )
					debug.setPixel32(x,y,pixels[zonesIds[zonesBitmap.getPixel32(x,y)&0xFF]]);
				else
					debug.setPixel32(x,y,0);
		dm.attachBitmap(debug,10);
/***/

		roomIds = new Array();
		for( l in d.levels ) {
			var z = new Array();
			for( x in 0...d.width )
				z[x] = new Array();
			roomIds.push(z);
			for( r in l.rooms ) {
				for( x in 0...r.w )
					for( y in 0...r.h )
						z[x+r.x][y+r.y] = r.id;
				for( d in r.doors )
					z[d.x][d.y] = r.id;
			}
		}
	}

	function onLoaded() {
		posX = DATA._x;
		posY = DATA._y;
		posL = DATA._l;
		// debug only
		if( posX == null ) {
			posX = d.start.x;
			posY = d.start.y;
			posL = d.start.l;
			DATA._fog = haxe.io.Bytes.alloc((d.levels.length * width * height + 7) >> 3);
			updateFog();
		} else
			fl_fog = DATA._fog != null;
		view = {
			ix : posX - (CX >> 1),
			iy : posY - (CY >> 1),
			dx : 0.,
			dy : 0.,
		};

		var mc : {> flash.MovieClip, field : flash.TextField } = cast dm.attach("msg_field",4);
		mc._x = 250;
		mc._y = 340;
		mc.field.autoSize = "right";
		posLabel = mc.field;
		displayLevel();
		initDinoz();
		arrows = cast dm.attach("arrows",4);
		arrows._x = arrows._y = 5;
		initArrow(arrows._u,	callback(move,0,-1,0));
		initArrow(arrows._d,	callback(move,0,1,0));
		initArrow(arrows._l,	callback(move,-1,0,0));
		initArrow(arrows._r,	callback(move,1,0,0));
		if(  DATA._tower ) {
			initArrow(arrows._cu,	callback(move,0,0,1));
			initArrow(arrows._cd,	callback(move,0,0,-1));
		}
		else {
			initArrow(arrows._cu,	callback(move,0,0,-1));
			initArrow(arrows._cd,	callback(move,0,0,1));
		}
		initArrow(arrows._i,	callback(move,0,0,0));
		arrows.filters = [ new flash.filters.GlowFilter(0x0, 0.5, 10,10, 1, 2) ];
		updateArrows();

		if( DATA._text != null ) {
			message(DATA._text,null);
			DATA._text = null;
		}
	}

	inline function curLevel() {
		return d.levels[posL];
	}


	function initArrow(mc:MC, cb) {
		mc.gotoAndStop(1);
		var me = mc;
		mc.onRollOver = function() { me.gotoAndStop(2); }
		mc.onRollOut = function() { me.gotoAndStop(1); }
		mc.onReleaseOutside = function() { me.gotoAndStop(1); }
		mc.onRelease = cb;
	}

	function initDinoz() {
		for( d in dinoz ) {
			d.mc._visible = true;
			d.px = d.tx = posX;
			d.py = d.ty = posY;
			d.speed = 2 / 40;
		}
	}

	function updateArrows() {
		var fl_wasVisible = arrows._cu._visible || arrows._cd._visible;
		arrows._cu._visible = false;
		arrows._cd._visible = false;
		var v = !DATA._lock;
		arrows._l._visible = v;
		arrows._r._visible = v;
		arrows._u._visible = v;
		arrows._d._visible = v;
		arrows._i._visible = !v;
		if(  !v ) {
			addPop(arrows._x+arrows._i._x+10, arrows._y+arrows._i._y+15);
		}
		for( r in curLevel().rooms )
			for( d in r.doors )
				if( d.x == posX && d.y == posY && d.up != null ) {
					if(  DATA._tower ) {
						arrows._cu._visible = d.up;
						arrows._cd._visible = !d.up;
					}
					else {
						arrows._cu._visible = !d.up;
						arrows._cd._visible = d.up;
					}
					if(  !fl_wasVisible ) addPop(arrows._x+arrows._cu._x+12, arrows._y+arrows._cu._y+12);
					break;
				}
	}

	function openDoor() {
		for( r in curLevel().rooms )
			for( d in r.doors )
				if( d.key != null && d.x == posX && d.y == posY ) {
					if( setFlag(posL,d.x,d.y) ) {
						var fx = addFadeFx("item",d.x*SIZE,d.y*SIZE);
						fx.mc.gotoAndStop(1);
						fx.mc.smc.gotoAndStop( curLevel().table[d.x][d.y-1] ? 1 : 2 );
						return true;
					}
					else {
						return false;
					}
				}
		return false;
	}

	function getItem() {
		for( r in curLevel().rooms ) {
			var i = r.item;
			if( i == null || i.x != posX || i.y != posY ) continue;
			var change = false;
			switch( i.k ) {
			case IKey:
				DATA._keys[i.v] = true;
				change = setFlag(posL,i.x,i.y);
			case IGold, IScenario:
				change = setFlag(posL,i.x,i.y);
			case IHeal:
			}
			return change;
		}
		return false;
	}

	function onPos(p) {
		return posL == p.l && posX == p.x && posY == p.y;
	}

	function move(dx,dy,dl) {
		var t = curLevel().table;
		if( scrolling || winMsg != null )
			return;

		if( !t[posX+dx][posY+dy] )
			return;
		var send = false;
		var move = true;
		for( r in curLevel().rooms ) {
			for( d in r.doors )
				if( d.x == posX+dx && d.y == posY+dy ) {
					send = true; // maybe monster
					if( d.key != null )
						move = DATA._keys[d.key];
					break;
				}
			if( r.item != null && r.item.x == posX+dx && r.item.y == posY+dy )
				send = true;
		}
		if( DATA._lock && ( dx != 0 || dy != 0 || dl != 0 ) )
			return;
		// send data
		var cmd : DungeonCommand = {
			_x : posX,
			_y : posY,
			_l : posL,
			_dx : dx,
			_dy : dy,
			_dl : dl,
		};
		commands.push(cmd);

		// update
		if( move ) {
			posX += dx;
			posY += dy;
			if( dl != 0 && !onPos(d.start) && !onPos(d.exit) )
				posL += dl;
		} else {
			dx = 0;
			dy = 0;
			dl = 0;
		}

		var w = 0;
		for( d in dinoz ) {
			if( dx != 0 )
				d.flip = dx > 0;
			if( move && d.delay <= 0 && !d.moving )
				d.delay = w * 10;
			w++;
			d.tx += dx;
			d.ty += dy;
		}
		updateFog();
		if( openDoor() )
			send = true;
		// wait until data or no url if debug
		if( commands.length >= 10 )
			send = true;
		if( DATA._url == null )
			send = false;
		if( send ) {
			h = new haxe.Http(DATA._url);
			h.onData = onData;
			h.onError = function(msg) haxe.Log.trace(msg,null);
			h.setParameter("data",haxe.Serializer.run(commands));
			h.request(true);
			commands = new Array();
		}
		var me = this;
		scrolling = true;
		scrollDone = function() if( !send ) me.scrollEnd();
		displayLevel();
		updateScroll();
	}

	function onData(data) {
		var r : _DResponse;
		try {
			r = haxe.Unserializer.run(data);
		} catch( e : Dynamic ) {
			haxe.Log.trace("INVALID DATA "+data,null);
			//if( haxe.Firebug.detect() )
			//	haxe.Firebug.trace("INVALID DATA "+data,null);
			return;
		}
		var me = this;
		scrollDone = function() {
			DATA._lock = false;
			switch( r ) {
			case DOk:
				me.scrollEnd();
			case DUrl(url):
				flash.Lib.getURL(url,"_self");
				me.scrollDone = function() { };
			case DMessage(msg,icon,url):
				me.message(msg,icon,url);
				me.scrollEnd();
			}
		}
	}

	function scrollEnd() {
		scrolling = false;
		if( getItem() )
			displayLevel();
		updateArrows();
	}

	function updateFog() {
		if(  !fl_fog ) return false;
		var t = curLevel().table;
		var x = posX;
		var y = posY;
		var redraw = false;
		for( px in x-1...x+2 )
			for( py in y-1...y+2 ) {
				var pos = posL * width * height + px * height + py;
				var ipos = (pos + 7) >> 3;
				var b = DATA._fog.get(ipos);
				if( b & (1 << (pos & 7)) == 0 ) {
					b |= 1 << (pos & 7);
					DATA._fog.set(ipos,b);
					var fx = addFadeFx("fx_reveal",px*SIZE+SIZE*0.5,py*SIZE+SIZE*0.5, 4);
					Col.setPercentColor(fx.mc, 100, skin.fog);
					fx.mc._rotation = Math.atan2(posY-py,posX-px)*180/Math.PI;
					fx.mc.filters = [ new flash.filters.BlurFilter(32,32,1) ];
					redraw = true;
				}
			}
		return redraw;
	}

	function hasFlag(l,x,y) {
		var f = l * width * height + x * height + y;
		for( f2 in DATA._flags )
			if( f == f2 )
				return true;
		return false;
	}

	function setFlag(l,x,y) {
		if( hasFlag(l,x,y) )
			return false;
		var f = l * width * height + x * height + y;
		DATA._flags.push(f);
		return true;
	}

	function initMonster( gfx, flip, id ) {
		var m = monsters[id];
		if( m != null ) {
			m._visible = true;
			m._p0._x = 0;
			m._p0._y = 0;
			m._p0.gotoAndStop(gfx);
			m._p0._p1._anim.gotoAndStop("stand");
			m._p0._box._visible = false;
			var b = m._p0._box.getBounds(m);
			var size = Math.max(Math.max(Math.abs(b.xMin),Math.abs(b.xMax)),Math.max(Math.abs(b.yMin * 0.8),Math.abs(b.yMax)));
			var scale = (SIZE / 2) * 100 / size;
			if( scale > 100 )
				scale = 100;
			m._xscale = m._yscale = scale;
			if( flip )
				m._xscale *= -1;
			return m;
		}
		m = cast dtmp.empty(2);
		m._visible = false;
		id = monsters.length;
		monsters.push(m);
		var l = new flash.MovieClipLoader();
		var k = 0;
		var me = this;
		l.onLoadComplete = l.onLoadInit = function(_) {
			k++;
			if( k == 2 ) me.initMonster(gfx,flip,id);
		};
		l.loadClip(DATA._smonster,m);
		return m;
	}

	inline function set( mc : flash.MovieClip, x : Int, y : Int ) {
		mc._x = x * SIZE;
		mc._y = y * SIZE;
	}


	inline function getNoiseId(x,y) {
		return zonesIds[zonesBitmap.getPixel32(x,y)&0xFF];
	}

	function getOverMap(mid:Int, px:Int,py:Int) {
		if(  skin.over[mid-1]==null ) return 0;
		var val = overMaps[mid][px][py];
		if(  val!=null ) return val;

		if(  getNoiseId(px,py)<mid ) {
			val |= if( getNoiseId(px-1,py-1)>=mid )		8	else 0;
			val |= if( getNoiseId(px,py-1)>=mid )		12	else 0;
			val |= if( getNoiseId(px+1,py-1)>=mid )	4	else 0;
			val |= if( getNoiseId(px-1,py)>=mid )		10	else 0;
			val |= if( getNoiseId(px+1,py)>=mid )		5	else 0;
			val |= if( getNoiseId(px-1,py+1)>=mid )	2	else 0;
			val |= if( getNoiseId(px,py+1)>=mid )		3	else 0;
			val |= if( getNoiseId(px+1,py+1)>=mid )		1	else 0;
		}
		else {
			val = 15;
		}
		overMaps[mid][px][py] = val;

		return val;
	}


	function initWall(rseed:mt.Rand, baseMc:flash.MovieClip, wallMc:flash.MovieClip, xoff=0, yoff=0) {
		wallMc._x = baseMc._x+xoff;
		wallMc._y = baseMc._y+yoff;
		wallMc.gotoAndStop( skin.w );
		wallMc.smc.gotoAndStop( rseed.random(wallMc.smc._totalframes)+1 );
//		wallMc.gotoAndStop( LEVEL_SKIN.w*10 + rseed.random(9)+1 );
//		w.smc.gotoAndStop(rseed.random(w.smc._totalframes)+1);
	}

	function windowPart(dmw:mt.DepthManager, frame, x,y,w,h, xw, yw) {
		var mc = dmw.attach("msg_box",0);
		mc.gotoAndStop(frame);
		mc._x = x + xw*w*0.5 - (if( xw==0) 0 else mc._width);
		mc._y = y + yw*h*0.5 - (if( yw==0) 0 else mc._height);
		return mc;
	}


	function message(txt:String, ?icon:String, ?url:String) {
		var w = 320;
		var h = 300;
		var padding = 8;
		winMsg.removeMovieClip();
		winMsg = dm.empty(5);
		var dmw = new mt.DepthManager(winMsg);
		var field : flash.TextField = (cast dmw.attach("msg_field",1)).field;
		txt = StringTools.replace(txt," !","#!");
		txt = StringTools.replace(txt," ?","#?");
		txt = StringTools.replace(txt," :","#:");
		field.text = txt;

		var tf = new flash.TextFormat();
		tf.size = if(txt.length<=100) 20 else 13;

		// cesure manuelle
		var tries = 0;
		var maxTries = 50;
		var fl_ok = false;
		while (!fl_ok && tries<maxTries) {
			var maxWidth = w-padding*2;
			field._width = w-padding*2;
			field._height = h-padding*2;
			var words = txt.split(" ");
			field.text = "";
			var lineStart = 0;
			var prevLength = 0;
			var fl_first=true;
			for (w in words) {
				field.text += (fl_first?"":"_") + w;
				field.setTextFormat(tf);
				fl_first = false;
				if(  field.textWidth>maxWidth ) {
					var newStart = field.text.indexOf("_")+1;
					prevLength = newStart-lineStart;
					lineStart = newStart;
					field.text = StringTools.replace(field.text,"_","\n");
				}
				else {
					field.text = StringTools.replace(field.text,"_"," ");
				}
			}
			var lastLength = field.text.length-lineStart;
			fl_ok = ( lastLength/prevLength > 0.4 );
			if(  !fl_ok ) {
				w-=5;
			}
			tries++;
		}
		if(  !fl_ok && tries>=maxTries ) {
			// fails !
			field.wordWrap = true;
			field.text = txt;
			w = 320;
		}
		field.text = StringTools.replace(field.text,"#"," ");
		field.setTextFormat(tf);
		h = Std.int( Math.max(50, field.textHeight + padding*2.5) );

		var x = 360*0.5-w*0.5;
		var y = 360*0.5-h*0.5;
		field._x = x+padding;
		field._y = y+padding;


		// bg
		winMsg.beginFill(0x4d1e10);
		winMsg.lineTo(x,y);
		winMsg.lineTo(x+w,y);
		winMsg.lineTo(x+w,y+h);
		winMsg.lineTo(x,y+h);
		winMsg.lineTo(x,y);
		winMsg.endFill();

		// horizontal sides
		var hPart = 23;
		for (i in 1...Math.floor(w/hPart)) {
			var t = windowPart(dmw, 2, x,y,w,h, 0,0);
			t._x = x+i*hPart;
			var b = windowPart(dmw, 8, x,y,w,h, 0,2);
			b._x = x+i*hPart;
		}
		// vertical sides
		var vPart = 41;
		for (i in 1...Math.floor(h/vPart)) {
			var l = windowPart(dmw, 4, x,y,w,h, 0,0);
			l._y = y+i*vPart;
			var r = windowPart(dmw, 6, x,y,w,h, 2,0);
			r._y = y+i*vPart;
		}
		// corners
		windowPart(dmw, 1, x,y,w,h, 0,0);
		windowPart(dmw, 3, x,y,w,h, 2,0);
		windowPart(dmw, 7, x,y,w,h, 0,2);
		windowPart(dmw, 9, x,y,w,h, 2,2);

		// icon
		if(  icon!=null ) {
			var iconMc = dmw.attach("msg_icon",2);
			iconMc.gotoAndStop(icon);
			iconMc._x = x+w*0.5;
			iconMc._y = y-5;
		}

		winMsg.filters = [ new flash.filters.GlowFilter( 0x0, 0.7, 32,32, 2, 2) ];
		var me = this;
		winMsg.onPress = function() {
			me.winMsg.removeMovieClip();
			me.winMsg = null;
			if( url != null ) flash.Lib.getURL(url,"_self");
		};
	}

	function displayLevel() {
		if(  skin.mask>0 ) {
			if(  mask==null ) {
				mask = dm.attach("mask",2);
				Col.setPercentColor(mask, 70, skin.fog);
				mask._alpha = skin.mask;
				mask.cacheAsBitmap = true;
			}
		}
		else {
			if(  mask!=null ) {
				mask.removeMovieClip();
				mask = null;
			}
		}

		var rseed = new mt.Rand(0);
		// clean not-monsters plans
		dtmp.clear(0);
		dtmp.clear(1);
		dtmp.clear(3);
		var lvl = curLevel();
		var t = lvl.table;
		var dx = view.ix - 2;
		var dy = view.iy - 1;
		var mx = view.ix + CX + 1;
		var my = view.iy + CY + 2;
		var vsize = (CX + 3) * SIZE;
		var mat = new flash.geom.Matrix();
		mat.identity();

		// init ground and walls
		var b = dtmp.attach("block",0);
		var over1 = dtmp.attach("overground",0);
		var over2 = dtmp.attach("overground",0);
		groundBitmap.dispose();
		groundBitmap = new flash.display.BitmapData(vsize,vsize,true,0);
		overgroundBitmap.dispose();
		overgroundBitmap = new flash.display.BitmapData(vsize,vsize,true,0);
		var groundMC = dtmp.empty(0);
		groundMC._x = dx * SIZE;
		groundMC._y = dy * SIZE;
		groundMC.attachBitmap(groundBitmap,0);
		groundMC.attachBitmap(overgroundBitmap,1);
		var rooms = roomIds[posL];
		for( py in dy...my ) {
			for( px in dx...mx ) {
				rseed.initSeed(py*height+px);
				if( t[px][py] ) {
					var gid = getNoiseId(px,py);
					b.gotoAndStop(skin.g);
					b.smc.gotoAndStop( rseed.random(b.smc._totalframes)+1 );
					mat.tx = (px - dx) * SIZE;
					mat.ty = (py - dy) * SIZE;
					groundBitmap.draw(b,mat);
					var val = getOverMap(1,px,py);
					if(  val>0 ) {
						over1.gotoAndStop(skin.over[0]);
						over1.smc.gotoAndStop(val);
						overgroundBitmap.draw(over1,mat);
					}
					var val = getOverMap(2,px,py);
					if(  val>0 ) {
						over2.gotoAndStop(skin.over[1]);
						over2.smc.gotoAndStop(val);
						overgroundBitmap.draw(over2,mat);
					}
					set(b,px,py);
					if( !t[px][py-1] ) {
						var w = dtmp.attach("wall_front",0);
						initWall(rseed,b,w);
					}
					if( !t[px-1][py] ) {
						var w = dtmp.attach("wall_side_left",3);
						initWall(rseed,b,w);
					}
					if( !t[px][py-1] && !t[px-1][py] ) {
						var w = dtmp.attach("wall_corner",0);
						initWall(rseed,b,w);
					}
					if( !t[px+1][py] ) {
						var w = dtmp.attach("wall_side_right",3);
						initWall(rseed,b,w);
					}
					if( !t[px][py+1] ) {
						var w = dtmp.attach("wall_back",3);
						initWall(rseed,b,w);
					}
					if( !t[px][py-1] && !t[px+1][py] ) {
						var w = dtmp.attach("wall_corner",0);
						initWall(rseed,b,w,SIZE+8);
					}
					if( !t[px][py+1] && !t[px-1][py] ) {
						var w = dtmp.attach("wall_corner",3);
						initWall(rseed,b,w,0,SIZE+8);
					}
					if( !t[px][py+1] && !t[px+1][py] ) {
						var w = dtmp.attach("wall_corner",3);
						initWall(rseed,b,w,SIZE+8,SIZE+8);
					}
				}
			}
		}

		// hide all monsters
		for( m in monsters )
			m._visible = false;
		var mid = monsters.length;

		// add items
		for( r in lvl.rooms ) {
			var i = r.item;
			if( i == null ) continue;
			if( i.x >= dx && i.x < mx && i.y >= dy && i.y < my ) {
				var b = dtmp.attach("item",1);
				var active = !hasFlag(posL,i.x,i.y);
				switch( i.k ) {
				case IKey:
					if( !active ) b.removeMovieClip();
					b.gotoAndStop(4);
					b.smc.gotoAndStop( 1 + (i.v%b.smc._totalframes) );
				case IGold:
					if( !active ) b.removeMovieClip();
					b.gotoAndStop(3);
				case IHeal:
					b.gotoAndStop(active?7:8);
				case IScenario:
					switch( DATA._sicons[i.v] ) {
					case DINothing:
						b.removeMovieClip();
						continue;
					case DIIcon(ico):
						if( !active ) b.removeMovieClip();
						b.gotoAndStop(9);
						b.smc.stop();
						b.smc.gotoAndStop(ico);
					case DIMonster(m):
						b.removeMovieClip();
						if( !active ) continue;
						var flip = (i.x == posX) ? !dinoz[0].flip : (i.x < posX);
						var m = initMonster(m,flip, --mid);
						set(m,i.x,i.y);
						m._x += 0.5 * SIZE;
						m._y += 0.6 * SIZE;
					case DIBlock:
						b.removeMovieClip();
					}
				}
				set(b,i.x,i.y);
			}
		}

		// add doors and monsters
		for( r in lvl.rooms )
			for( d in r.doors )
				if( d.x >= dx && d.x < mx && d.y >= dy && d.y < my ) {
					var flag = hasFlag(posL,d.x,d.y);
					if( d.up != null ) {
						// stair
						var b = dtmp.attach("item",1);
						b.gotoAndStop(DATA._tower ? (d.up ? 6 : 5) : (d.up ? 5 : 6));
						b.smc.gotoAndStop( t[d.x+1][d.y] ? 1 : 2 );
						set(b,d.x,d.y);
					} else if( d.key != null ) {
						// door
						var b = dtmp.attach("item",1);
						b.gotoAndStop(flag ? 2 : 1);
						b.smc.gotoAndStop( t[d.x][d.y-1] ? 1 : 2 );
						set(b,d.x,d.y);
					} else if( !flag ) {
						// monster
						var r = new mt.Rand(0);
						r.initSeed(d.x * height + d.y);
						var gfx = DATA._monsters[r.random(DATA._monsters.length)];
						var flip = (d.x == posX) ? !dinoz[0].flip : (d.x < posX);
						var m = initMonster(gfx,flip, --mid);
						set(m,d.x,d.y);
						m._x += 0.5 * SIZE;
						m._y += 0.6 * SIZE;
					}
				}

		// add fog
		fogBitmap.dispose();
		if(  fl_fog ) {
			fogBitmap = new flash.display.BitmapData(vsize,vsize,true,0);
			var fogMC = dtmp.empty(4);
			fogMC._x = dx * SIZE;
			fogMC._y = dy * SIZE;
			fogMC.attachBitmap(fogBitmap,0);
			var fog = dtmp.attach("fog",0);
			for( px in dx...mx ) {
				var pos = posL * width * height + px * height + dy;
				for( py in dy...my ) {
					if( DATA._fog.get((pos + 7) >> 3) & (1 << (pos & 7)) == 0 ) {
						fog.gotoAndStop(1+(pos % b._totalframes));
						mat.tx = (px - dx) * SIZE;
						mat.ty = (py - dy) * SIZE;
						fogBitmap.draw(fog,mat);
					}
					pos++;
				}
			}
			Col.setPercentColor(fogMC, 100, skin.fog);
			fog.removeMovieClip();
		}

		filter(overgroundBitmap,new flash.filters.GlowFilter(0x0, 0.7, 2,2, 2, 1));
		groundBitmap.draw(overgroundBitmap);
		overgroundBitmap.dispose();
		filter(groundBitmap,new flash.filters.DropShadowFilter(15,0,0,0.3,3,3,1,2,true));
		filter(groundBitmap,new flash.filters.GlowFilter(0x0, 0.35, 64,64, 2, 1, true));
		filter(groundBitmap,new flash.filters.GlowFilter(0x72525B, 0.6, 64,64, 2, 1));
		filter(fogBitmap,new flash.filters.BlurFilter(32,32,1));
		b.removeMovieClip();
		over1.removeMovieClip();
		over2.removeMovieClip();

		posLabel.text = DATA._tlvl.split("::n::").join(Std.string((posL+1+DATA._ldelta)*(DATA._tower?1:-1)));
	}

	function filter( bmp : flash.display.BitmapData, f : flash.filters.BitmapFilter ) {
		bmp.applyFilter(bmp,bmp.rectangle,new flash.geom.Point(0,0),f);
	}


	function addFx(link,x,y, ?plan=2, fn:Fx->Bool) : Fx {
		var mc = dtmp.attach(link, plan);
		mc._x = x;
		mc._y = y;
		mc.stop();
		var fx : Fx = {
			update	: fn,
			cpt		: 0.0,
			mc		: mc,
		}
		fxList.push(fx);
		return fx;
	}

	function addFadeFx(link,x,y,?plan) : Fx {
		var fx = addFx( link,x,y, plan, function(fx) { fx.mc._alpha=Math.cos(fx.cpt)*100; return fx.cpt>=Math.PI; } );
		return fx;
	}

	function addPop(x,y) {
		var mc = dm.attach("fx_pop",10);
		mc._x = x;
		mc._y = y;
		mc.filters = [ new flash.filters.GlowFilter(0xFFD735, 1, 16,16, 3, 2) ];
		mc.blendMode="screen";
		simpleFx.push(mc);
	}


	function update() {
		// fx
		var i=0;
		while(i<fxList.length) {
			var fx = fxList[i];
			fx.cpt+=0.07;
			if(  fx.update(fx) ) {
				fx.mc.removeMovieClip();
				fxList.splice(i,1);
				i--;
			}
			i++;
		}
		var i=0;
		while(i<simpleFx.length) {
			var mc = simpleFx[i];
			mc.nextFrame();
			if(  mc._currentframe>=mc._totalframes ) {
				mc.removeMovieClip();
				simpleFx.splice(i,1);
				i--;
			}
			i++;
		}

		// wait until initialized
		if( arrows == null )
			return;
		// keyboard controls
		if( flash.Key.isDown(flash.Key.DOWN) )
			move(0,1,0);
		else if( flash.Key.isDown(flash.Key.UP) )
			move(0,-1,0);
		else if( flash.Key.isDown(flash.Key.LEFT) )
			move(-1,0,0);
		else if( flash.Key.isDown(flash.Key.RIGHT) )
			move(1,0,0);
		// dinoz
		for( d in dinoz )
			d.update();
		if( scrolling && !dinoz[0].moving )
			scrollDone();
		updateScroll();
	}

	function updateScroll() {
		// update scroll
		var d0 = dinoz[dinoz.length - 1];
		var dx = (d0.px - (CX-1)/2) - (view.ix + view.dx);
		var dy = (d0.py - (CY-1)/2) - (view.iy + view.dy);
		view.dx += dx * 0.1;
		view.dy += dy * 0.1;
		var idx = Std.int(view.dx);
		var idy = Std.int(view.dy);
		if( idx != 0 ) {
			view.ix += idx;
			view.dx -= idx;
		}
		if( idy != 0 ) {
			view.iy += idy;
			view.dy -= idy;
		}
		if( idx != 0 || idy != 0 )
			displayLevel();
		levelMC._x = -Math.round((view.ix + view.dx) * SIZE);
		levelMC._y = -Math.round((view.iy + view.dy) * SIZE);
	}

	public static var DATA : DungeonData;
	public static var inst : View;

	static function start() {
		inst = new View(flash.Lib.current);
		flash.Lib.current.onEnterFrame = inst.update;
	}

	static function main() {
		haxe.Log.setColor(0xFF0000);
		var data = Reflect.field(flash.Lib._root,"data");
		if( data == null ) {
			var l = new haxe.Http("dungeon_test.xml");
			//trace("main");
			l.onData = function(data) {
				//trace("main onData");
				DATA = {
					_d : data,
					_x : null,
					_y : null,
					_dir : true,
					_l : 0,
					_ldelta : 0,
					_sdino : "../../dev/swf/sdino.swf",
					_smonster : "../../dev/swf/smonster.swf",
					_group : [
						{ _n : "RedRed", _g : "86v70XPBxnd8ctaS" } //,{ _n : "Nunuche", _g : "7918bK5h1ENzewxU" },
						],
					_monsters : ["goupi","coq","grdien","borg"],
					_flags : [],
					_keys : [],
					_fog : null,
					_url : null,
					_lock : false,
					_tower : false,
					_skin : DEFAULT_SKIN,
					_sicons : [DIIcon("skel")],
					_text : null,
					_tlvl : "Niveau ::n::",
				};
				try {
					start();
				} catch ( e : Dynamic ) {
					trace("error : " + e);
					haxe.Log.trace(Std.string(e),null);
				}
			};
			l.onError = function(msg) {
				trace("msg:" + msg);
				haxe.Log.trace(msg,null);
			}
			l.request(false);
		} else {
			DATA = haxe.Unserializer.run(data);
			start();
		}
	}

}