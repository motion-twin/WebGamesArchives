package exp;

import mt.flash.Key;
import flash.ui.Keyboard;
import mt.deepnight.Buffer;
import mt.deepnight.SpriteLib;
import mt.deepnight.Color;
import mt.deepnight.Particle;
import mt.deepnight.Tweenie;
import mt.deepnight.Lib;

import ExploreProtocol;

@:bitmap("tiles.png") class GfxTiles extends flash.display.BitmapData {}

class Manager implements haxe.Public {//}
	static var STAR_COLORS = [0xE1BD7B, 0xF1B49E, 0xFFFFBB, 0xFFB0B0];
	static var BG_COLORS = [0x368189, 0x3D86A9, 0x3D4285, 0x8A6BAF, 0x8B3F3F];
	static var COMMON_LOW_ALPHA = 0.5;
	static var COMMON_HIGH_ALPHA = 0.85;
	static var REACTOR_COLOR = 0xA482FF;
	inline static var SHIP_FRAMES = 32;
	inline static var SHIP_SIZE = 96;
	static var ANIM_SECTOR_ZOOM = 60;
	static var ANIM_COMMON_ZOOM = 100;
	static var ANIM_SOLARSTAR_ZOOM = 10;
	static var QUALITY = flash.display.StageQuality.MEDIUM;

	static var pt0 = new flash.geom.Point(0,0);
	static var autoInc = 0;
	public static var DP_BG = autoInc++;
	public static var DP_ZLAYERS = autoInc++;
	public static var DP_FRONTLAYER = autoInc++;
	public static var DP_PLANET = autoInc++;
	public static var DP_SHIP = autoInc++;
	public static var DP_INTERF = autoInc++;
	public static var DP_FX = autoInc++;
	public static var DP_TOP = autoInc++;
	
	public static var WID = Std.int(flash.Lib.current.stage.stageWidth);
	public static var HEI = Std.int(flash.Lib.current.stage.stageHeight);
	public static var ME : Manager;
	public static var UPSCALE = 1;
	public static var USE_SCALE2X = false;
	public static var USE_SPHERIZE = false;
	public static var SPHERIZE_X = if(UPSCALE<=2) -8 else -4;
	public static var SPHERIZE_Y = if(UPSCALE==1) -32 else if(UPSCALE<=2) -24 else -12;
	
	var tw				: Tweenie;
	var root			: flash.display.MovieClip;
	var buffer			: Buffer;
	var rdm				: mt.DepthManager; // root
	var fdm				: mt.DepthManager; // Front
	var scroller		: flash.display.Sprite; // TODO supprimer
	//var seed			: Int;
	var lib				: SpriteLib;
	var libShip			: Null<SpriteLib>;
	
	var gps				: Array<{arrow:flash.display.Sprite, target:Entity}>;
	
	//var viewPort		: flash.geom.Rectangle;
	
	var shipSpr			: Null<DSprite>;
	var ship			: Entity;
	var reactors		: List<flash.display.Sprite>;
	var reactorPoints	: Null< Array<Array<{x:Float,y:Float,b:Block,visible:Bool}>> >;
	var cursor			: Entity;
	var targetObject	: Null<Entity>;
	
	var buttons			: Array<Button>;
	var tip				: { spr : flash.display.Sprite, field : flash.text.TextField };
	var curWindow		: Null<{top:flash.display.Sprite, bottom:flash.display.Sprite, bd:flash.display.BitmapData}>;
	var windowTarget	: Null<Entity>;
	var initMask		: flash.display.Sprite;
	
	var fl_serverLock		: Bool;
	var fl_lockControls	: Bool;
	var fl_lockCamera	: Bool;
	var spherize		: flash.display.BitmapData;
	var overdriveBurn	: flash.display.Sprite;
	var burn			: flash.display.Sprite;
	var zoomCache		: flash.display.Bitmap;
	var sector			: Room;
	var common			: Room;
	var solar			: Null<Room>;
	var solarStars		: Null<Room>;
	var current			: Room;
	var bgColor			: Int;
	var bg				: flash.display.Sprite;
	var oldBg			: flash.display.Sprite;
	var loadingAnim		: flash.display.Sprite;
	var bar				: flash.display.Sprite;
	
	var externalSprites	: flash.display.Sprite;
	
	var infos			: ExploreInfos;
	var curSector		: SectorInfos;
	var curSystem		: Null<SystemInfos>;
	var shipSpeed		: mt.flash.Volatile<Float>;
	var lastShipAng		: Float;
	
	//#if debug
	var test			: flash.display.Sprite;
	var cd				: Int;
	//#end
	
	var lowFrames		: Int;
	
	var server 			: ServerCall;
	var cnx				: haxe.remoting.Connection;
	var debugStats		: Bool;
	
	public function new(r, infos, debugStats) {
		ME = this;
		this.debugStats = debugStats;
		root = r;
		root.stage.frameRate = 30;
		haxe.Log.setColor(0xFF6600);
		root.addEventListener( flash.events.Event.ENTER_FRAME, main );
		Key.init();
		Lang.init(infos);
		tw = new Tweenie();
		setQuality(QUALITY);
		mt.Timer.pause();
		
		this.infos = infos;
		curSector = infos.sector;
		server = new ServerCall(infos);
		
		cd = 32;
		buttons = new Array();
		fl_lockControls = false;
		fl_lockCamera = false;
		fl_serverLock = false;
		lastShipAng = 0;
		lowFrames = 0;
		shipSpeed = 0;
		reactors = new List();
		gps = new Array();
		
		lib = new SpriteLib( new GfxTiles(0,0) );
		lib.setCenter(0,0);
		lib.setUnit(32,32);
		lib.sliceUnit("asteroid", 0,2);
		lib.slice("planet", 0,5*32, 64,64, 3);
		lib.sliceUnit("system", 0,1, 3);
		lib.slice("hex", 0,32*3, 38,20);
		lib.slice("brush", 0,368, 208,64, 1,1);
		
		lib.setUnit(16);
		lib.sliceUnit("lock", 0,0);
		lib.sliceUnit("deleted", 1,0);
		lib.sliceUnit("unknown", 2,0);
		lib.sliceUnit("flag", 3,0);
		lib.sliceUnit("counter", 4,0);

		//#if debug
		test = new flash.display.Sprite();
		//#end
		
		rdm = new mt.DepthManager(root);
		
		buffer = new Buffer(Std.int(WID/UPSCALE),Std.int(HEI/UPSCALE), UPSCALE, false, 0x0, USE_SCALE2X);
		rdm.add(buffer.render, DP_PLANET);
		if( UPSCALE==1 ) {
			//buffer.setTexture( Buffer.makeMosaic(3), 0.14, flash.display.BlendMode.OVERLAY, true );
			buffer.setTexture( Buffer.makeScanline(0x0, 3), 0.22, flash.display.BlendMode.OVERLAY, true );
		}
		else {
			//buffer.setTexture( Buffer.makeMosaic(UPSCALE), 0.14, flash.display.BlendMode.OVERLAY, true );
			buffer.setTexture( Buffer.makeScanline(0x0, UPSCALE*2), 0.15, flash.display.BlendMode.OVERLAY, true );
		}

		bg = new flash.display.Sprite();
		buffer.dm.add(bg, DP_BG);
		oldBg = new flash.display.Sprite();
		buffer.dm.add(oldBg, DP_BG);
		
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);
		
		scroller = new flash.display.Sprite();
		buffer.dm.add(scroller, DP_TOP);
		
		var front = new flash.display.Sprite();
		buffer.dm.add(front, DP_FRONTLAYER);
		fdm = new mt.DepthManager(front);
		
		externalSprites = new flash.display.Sprite();
		rdm.add(externalSprites, DP_PLANET);

		/*** HACK **/
		//infos.systems = [];
		//infos.sector.seed = Std.random(999999);

		common = new Room(infos.sector.seed);
		common.generateCommon();
		common.finalize();
		for(l in common.layers)
			l.cont.alpha = COMMON_LOW_ALPHA;
			
		sector = new Room(infos.sector.seed);
		sector.generateSector(infos.sector);
		sector.finalize();

		current = sector ;
		
		initShip();
		
		current.viewPort.x = ship.x;
		current.viewPort.y = ship.y;
		common.viewPort = current.viewPort.clone();
		//setBg( Color.darken(current.bgColor, 0.8) );
		setBg(current.bgColor);
		
		burn = new flash.display.Sprite();
		burn.graphics.beginFill(0xffffff, 1);
		burn.graphics.drawRect(0,0, buffer.width, buffer.height);
		burn.blendMode = flash.display.BlendMode.ADD;
		burn.visible = false;
		buffer.dm.add(burn, DP_TOP);
		
		overdriveBurn = new flash.display.Sprite();
		overdriveBurn.graphics.beginFill(0xFFBE28, 1);
		overdriveBurn.graphics.drawRect(0,0, buffer.width, buffer.height);
		overdriveBurn.blendMode = flash.display.BlendMode.ADD;
		overdriveBurn.visible = false;
		buffer.dm.add(overdriveBurn, DP_TOP);
		
		zoomCache = new flash.display.Bitmap(null, flash.display.PixelSnapping.NEVER, false );
		zoomCache.blendMode = flash.display.BlendMode.ADD;
		buffer.dm.add(zoomCache, DP_TOP);
		
		initSpherize();
		
		cursor = new Entity( current, new flash.display.Sprite() );
		fdm.add( cursor.spr, DP_TOP );
		//cursor.spr.blendMode = flash.display.BlendMode.ADD;
		//cursor.spr.filters = [ new flash.filters.GlowFilter(0xB3FF00,1, 8,8, 1) ];
		cursor.spr.filters = [
			new flash.filters.DropShadowFilter(1,90, 0x2F3642,1, 1,1, 1),
			//new flash.filters.DropShadowFilter(1,-90, 0xFFFFFF,0.5, 2,2, 5, true),
			new flash.filters.GlowFilter(0x343F4E,1, 2,2, 1)
		];
		var g = cursor.spr.graphics;
		var w = 8;
		g.lineStyle(3, 0xC8D9F2, 1, flash.display.LineScaleMode.NONE);
		g.moveTo(-w,0);
		g.curveTo(-(w-1),-(w-1), 0,-w);
		g.moveTo(w,0);
		g.curveTo(w-1,w-1, 0,w);
		
		// Rebords flous
		if( !debugStats )
			initBorders();
			
		//viewPort = new flash.geom.Rectangle(ship.x,ship.y, buffer.width,buffer.height);
		
		initTip();
		
		// écran de chargement
		initMask = new flash.display.Sprite();
		rdm.add(initMask, DP_INTERF);
		initMask.graphics.beginFill(0x0, 1);
		initMask.graphics.drawRect(0,0,WID,HEI);
		//var tf = makeField(0xFFFFFF);
		//initMask.addChild(tf);
		//tf.text = Lang.get("loading");
		//tf.x = Std.int( WID*0.5 - tf.textWidth*0.5 );
		//tf.y = Std.int( HEI*0.35 );
		
		// DEBUG
		if( debugStats ) {
			infos.freeLicense = false;
			var debug = new mt.kiroukou.debug.Stats(WID-70, 0, 0.7);
			rdm.add(debug, DP_TOP);
			rdm.add(test, DP_TOP);
		}

		// Barre de progression
		bar = new flash.display.Sprite();
		rdm.add(bar, DP_INTERF);
		
		// Anim de chargement
		loadingAnim = new flash.display.Sprite();
		rdm.add(loadingAnim, DP_TOP);
		loadingAnim.x = WID-20;
		loadingAnim.y = 20;
		loadingAnim.visible = false;
		loadingAnim.filters = [
			new flash.filters.DropShadowFilter(2,90, 0x0,0.4, 0,0),
		];
		var g = loadingAnim.graphics;
		g.lineStyle(5, 0x282E44, 0.7);
		g.drawCircle(0,0,10);
		g.endFill();
		g.lineStyle(0,0,0);
		for(i in 0...5) {
			var a = i*0.45;
			g.beginFill(0xCCD8EC, 0.8*i/5 + 0.2);
			g.drawCircle(Math.cos(a)*10, Math.sin(a)*10, 2);
		}
		loading(true);
		
		//init JS
		var ctx = new haxe.remoting.Context();
		ctx.addObject('api', { _delete : function(pid) {
			server.sendAction(ADiscardPlanet(pid), function() {
				for( s in infos.systems )
					for( p in s.planets )
						if( p.id==pid )
							p.status = PAbandonned;
				infos.freeLicense = true;
				refreshSolar();
			});
			return true;
		}} );
		cnx = haxe.remoting.ExternalConnection.jsConnect('cnx', ctx).api;
	}
	
	
	function setQuality(q) {
		QUALITY = q;
		root.stage.quality = q;
	}
	
	
	function clearGps() {
		for( g in gps )
			g.arrow.parent.removeChild(g.arrow);
		gps = new Array();
	}
	
	inline function gpsArrow() {
		var c = 0x80FF00;
		var spr = new flash.display.Sprite();
		var g = spr.graphics;
		g.lineStyle(1, c, 1, flash.display.LineScaleMode.NONE);
		g.moveTo(0,-8);
		g.lineTo(5,0);
		g.lineTo(0,8);
		rdm.add(spr, DP_INTERF);
		spr.filters = [ new flash.filters.GlowFilter(c,0.8, 8,8,2) ];
		return spr;
	}
	
	function addGpsPlanet(inf:SystemPlanetInfos) {
		gps.push({
			arrow	: gpsArrow(),
			target	: current.getPlanetEntity(inf),
		});
		//clearGps(); // HACK
	}
	
	function addGpsSystem(inf:SystemInfos) {
		gps.push({
			arrow	: gpsArrow(),
			target	: current.getSystemEntity(inf),
		});
		//clearGps(); // HACK
	}
	
	
	function start() {
		mt.Timer.restore();
		fl_lockCamera = false;
		fl_lockControls = false;
		
		// Position de départ
		if( debugStats )
			infos.ship.pos = PInSystem(5);
		if( infos.ship.pos!=null ) {
			switch( infos.ship.pos ) {
				case PPlanet(id) :
					var sinf = getPlanetSystem(id);
					popString(sinf.name);
					gotoSolar(sinf, false);
					var p = getPlanet(id);
					var pt = solar.getOrbitCoord(p.distance);
					ship.x = pt.x+32;
					ship.y = pt.y;
					
				case PInSector(x,y) :
					gotoSector(null, false);
					popString(infos.sector.name);
					var pt = sector.gridToMap({x:x,y:y});
					ship.x = pt.x;
					ship.y = pt.y;
					
				case PInSystem(id) :
					var sinf = getSystem(id);
					popString(sinf.name);
					gotoSolar(sinf, false);
			}
		}
		centerView();
		
		// message d'accueil
		var n = 0;
		for( s in infos.systems )
			for( p in s.planets )
				if( p.status==PActive || p.status==PAbandonned )
					n++;
		if( n==0 ) {
			var s = Lang.get("welcome");
			var tf = popString( s, 0xFFC600, 35 );
			tf.y+=35;
		}
		
		tw.create(initMask, "alpha", 0, TEaseIn, 1000).onEnd = function() {
			initMask.visible = false;
		}
		loading(false);
	}
	
	
	function clearButtons() {
		for(b in buttons) {
			b.active = false;
			tw.create(b.spr, "alpha", 0, TEaseOut, 500).onEnd = function() {
				b.spr.parent.removeChild(b.spr);
			}
		}
		buttons = new Array();
	}
	
	function addButton(label:String, cb:Void->Void) {
		var w = Math.max(128, label.length*14);
		var col = 0x18E7DC;
		var s = new flash.display.Sprite();
		s.graphics.lineStyle(1, col, 1, true);
		s.graphics.beginFill(col, 0.3);
		s.graphics.drawRect(0,0, w,24);
		s.x = Std.int( WID*0.5 - s.width*0.5);
		s.y = Std.int( HEI-70 - s.height*0.5);
		
		var tf = makeField(0xFFFFFF);
		tf.text = label;
		tf.width = tf.textWidth+5;
		tf.scaleX = tf.scaleY = 2;
		tf.filters = [];
		tf.x = Std.int(w*0.5 - tf.textWidth*tf.scaleX*0.5);
		s.addChild(tf);
		
		s.alpha = 0;
		s.y += 15;
		tw.create(s,"alpha", 1, TEaseOut, 500);
		tw.create(s,"y", s.y-15, TEaseOut, 500);
		
		var b = new Button(s);
		rdm.add(b.spr, DP_INTERF);
		b.onOver = function() {
			b.spr.filters = [ new flash.filters.GlowFilter(col, 1, 8,8,1) ];
		}
		b.onOut = function() {
			b.spr.filters = [];
		}
		b.onClick = function() {
			clearButtons();
			b.spr.filters = [ new flash.filters.GlowFilter(0xFFFFFF,1, 2,2, 10) ];
			cb();
		}
		buttons.push(b);
	}
	
	
	function popString(str:String, ?col=0xffffff, ?size=50, ?fadeOut=true) {
		var tf = makeField(col, size);
		rdm.add(tf, DP_INTERF);
		tf.width = WID-100;
		tf.height = 100;
		tf.multiline = tf.wordWrap = true;
		tf.text = str;
		tf.x = Std.int(WID*0.5-tf.textWidth*0.5);
		tf.y = Std.int(HEI*0.25);
		if( col==0xFFFFFF )
			tf.filters = [ new flash.filters.GlowFilter(tf.textColor, 0.6, 16,16, 1) ];
		else
			tf.filters = [
				new flash.filters.DropShadowFilter(2,90,Color.brightnessInt(col, -0.5),1, 2,2,2),
				new flash.filters.GlowFilter(Color.brightnessInt(col,-0.5), 0.6, 16,16, 1)
			];
		tf.alpha = 0;
		tw.create(tf, "alpha", 1, 500);
		if( fadeOut )
			haxe.Timer.delay( function() {
				tw.create(tf, "alpha", 0, TEaseIn, 2500).onEnd = function() tf.parent.removeChild(tf);
			}, 1000 + str.length*20);
		return tf;
	}

	function setBg(col:Int, ?fadeDuration=0) {
		var cap = 0.3;
		var dfactor = -0.2;
		col = Color.capBrightnessInt(col, cap);
		var dark = Color.brightnessInt(col, dfactor);
		var old = bgColor;
		bgColor = col;
		
		tw.terminate(oldBg);
		oldBg.graphics.clear();

		var g = bg.graphics;
		var m = new flash.geom.Matrix();
		m.createGradientBox(buffer.width, buffer.height, Math.PI*0.5);
		g.clear();
		g.beginGradientFill(flash.display.GradientType.LINEAR, [col,dark], [1,1], [0,255], m);
		g.drawRect(0,0, buffer.width,buffer.height);
		g.endFill();
		
		if( fadeDuration>0 ) {
			var col = Color.capBrightnessInt(old, cap);
			var dark = Color.brightnessInt(old, dfactor);
			var g = oldBg.graphics;
			g.beginGradientFill(flash.display.GradientType.LINEAR, [col,dark], [1,1], [0,255], m);
			g.drawRect(0,0, buffer.width,buffer.height);
			g.endFill();
			oldBg.visible = true;
			oldBg.alpha = 1;
			tw.create(oldBg,"alpha", 0, TEaseIn, fadeDuration).onEnd = function() oldBg.visible = false;
		}
	}
	
	function showBar(f:Float) {
		if( f<0 ) f = 0;
		if( f>1 ) f = 1;
		
		bar.visible = true;
		if( f<1 )
			tw.create(bar, "alpha", 1, TEaseOut, 500);
		else
			tw.create(bar, "alpha", 0, TEaseIn, 500).onEnd = function() bar.visible = false;
		
		var col = 0xB6AEC6;
		var g = bar.graphics;
		g.clear();
		g.beginFill(Color.brightnessInt(col, -0.7), 1);
		g.drawRect(0,0, 300,3);
		g.beginFill(col, 1);
		g.drawRect(0,0, 300*f,3);
		
		bar.filters = [
			new flash.filters.GlowFilter(Color.brightnessInt(col, -0.7), 1, 2,2,10),
			new flash.filters.GlowFilter(Color.brightnessInt(col, -0.4), 1, 2,2,10),
			new flash.filters.DropShadowFilter(8,90, Color.brightnessInt(col,0.3),0.2, 0,0, 1,1, true),
			new flash.filters.GlowFilter(0x0, 1, 2,2,10),
			//new flash.filters.DropShadowFilter(4,90, 0x0,0.7, 8,8),
		];
		
		bar.x = Std.int(WID*0.5 - bar.width*0.5);
		bar.y = Std.int(HEI*0.5 - bar.height*0.5)+50;
	}
	
	function loading(b:Bool) {
		tw.terminate(loadingAnim);
		if( b ) {
			loadingAnim.visible = true;
			loadingAnim.alpha = 1;
		}
		else
			tw.create(loadingAnim, "alpha", 0, TLinear, 500).onEnd = function() loadingAnim.visible = false;
	}
	
	function initShip() {
		ship = new Entity(current, new flash.display.Sprite());
		fdm.add(ship.spr, DP_SHIP);
		var g = ship.spr.graphics;
		g.lineStyle(1,0x495776, 0.8);
		g.beginFill(0xACB6CC,1);
		g.moveTo(-8,-5);
		g.lineTo(8,0);
		g.lineTo(-8,5);
		g.endFill();
		
		//g.lineStyle(1,0xFFFF00, 1);
		//g.moveTo(-32,0);
		//g.lineTo(32,0);
		//g.lineStyle(1,0xFF0000, 1);
		//g.moveTo(0,-32);
		//g.lineTo(0,32);
		
		ship.x = current.entrance.x;
		ship.y = current.entrance.y;
		
		var data = infos.ship.data==null ? Common.Const.DEFAULT_SHIP : infos.ship.data;
		//var data = Common.Const.DEFAULT_SHIP; // HACK
		var c = new r3d.Capture(data, SHIP_SIZE, SHIP_FRAMES);
		c.trackBlock(Block.get(BShipEngine));
		c.onReady = function(bd,rtrack) {
			ship.spr.graphics.clear();
			bd.applyFilter(bd, bd.rect, pt0, Color.getContrastFilter(0.7));
			
			libShip = new SpriteLib( bd );
			libShip.setCenter(0,0);
			libShip.slice("ship", 0,0, SHIP_SIZE,SHIP_SIZE, SHIP_FRAMES);
			
			shipSpr = libShip.getSprite("ship");
			shipSpr.setCenter(0.5, 0.5);
			shipSpr.blendMode = flash.display.BlendMode.NORMAL;
			shipSpr.filters = [ new flash.filters.GlowFilter(0x0,1, 2,2, 3) ];
			shipSpr.scaleX = shipSpr.scaleY = (if(UPSCALE==1) 1 else 1/UPSCALE) * (128/SHIP_SIZE);
			fdm.add(shipSpr, DP_SHIP);
			
			shipSpeed = Common.Const.shipSpeed(rtrack[0].length, c.weight);
			if( debugStats )
				shipSpeed = 1;
			ship.speed = shipSpeed;
			reactorPoints = rtrack;
			
			start();
		};
		
		
		// réacteurs
		var r = new flash.display.Sprite();
		reactors.add(r);
		ship.spr.addChild(r);
		r.x = -20;
		r.y = -4;
		var r = new flash.display.Sprite();
		ship.spr.addChild(r);
		reactors.add(r);
		r.x = -20;
		r.y = 4;
	}
	
	
	function initBorders() {
		var col = 0x0;
		var bs = 0.25;
		var borders = new flash.display.Bitmap( new flash.display.BitmapData(WID,HEI, true, 0x0) );
		var w = if( USE_SPHERIZE ) 30 else 20;
		var tmp = new flash.display.Sprite();
		var m = new flash.geom.Matrix();
		m.createGradientBox(Math.max(WID,HEI),w, Math.PI/2);
		tmp.graphics.beginGradientFill(flash.display.GradientType.LINEAR, [col,col], [1,0], [120,255],m);
		tmp.graphics.drawRect(0,0,Math.max(WID,HEI),w);

		// haut
		borders.bitmapData.draw(tmp);
		// bas
		var m = new flash.geom.Matrix();
		m.rotate(Math.PI);
		m.translate(WID,HEI);
		borders.bitmapData.draw(tmp, m);
		// gauche
		var m = new flash.geom.Matrix();
		m.rotate(-Math.PI/2);
		m.translate(0,HEI);
		borders.bitmapData.draw(tmp, m);
		// droite
		var m = new flash.geom.Matrix();
		m.rotate(Math.PI/2);
		m.translate(WID,0);
		borders.bitmapData.draw(tmp, m);
		var b = if( USE_SPHERIZE ) 16 else 32;
		borders.bitmapData.applyFilter(borders.bitmapData, borders.bitmapData.rect, pt0, new flash.filters.BlurFilter(b,b));
		
		rdm.add(borders, DP_TOP);
	}
	
	function hideWindow() {
		clearButtons();
		if( curWindow!=null ) {
			var d = 500;
			var w = curWindow;
			tw.create(w.top,"y", w.top.y-w.top.height, d);
			tw.create(w.top,"alpha", 0, d);
			tw.create(w.bottom,"y", w.bottom.y+w.bottom.height, d);
			tw.create(w.bottom, "alpha", 0, TEaseIn, d).onEnd = function() {
				w.bottom.parent.removeChild(w.bottom);
				w.top.parent.removeChild(w.top);
				if( w.bd!=null )
					w.bd.dispose();
			}
			windowTarget = null;
			curWindow = null;
		}
	}
	
	function setWindow(e:Entity, title:String, ?subTitle:String, ?desc:String) {
		var d = 500;
		hideWindow();
		var alpha = 0.6;
		var col = 0x726DBC;
		var dark = Color.capBrightnessInt(col, 0.2);
			
		// Barre haut
		var top = new flash.display.Sprite();
		top.cacheAsBitmap = true;
		top.mouseChildren = top.mouseEnabled = false;
		top.y = -70;
		tw.create(top, "y", 0, TEaseOut, d);
		top.graphics.beginFill(dark, alpha);
		top.graphics.drawRect(0,0, WID, 70);
		externalSprites.addChild(top);
		
		// Titre
		var tf = makeField(0xffffff);
		top.addChild(tf);
		tf.width = 300;
		tf.text = title;
		tf.scaleX = tf.scaleY = 6;
		tf.filters = [];
		tf.x = Std.int( WID*0.5 - tf.textWidth*0.5*tf.scaleX );
		tf.y = 20;
		tf.filters = [
			new flash.filters.GlowFilter(dark,0.6, 2,2, 3),
			new flash.filters.DropShadowFilter(1,90, 0x0, 0.8, 0,0,1)
		];
		
		// Sous-titre
		if( subTitle!=null ) {
			var tf = makeField(0xffffff);
			top.addChild(tf);
			tf.width = 300;
			tf.text = subTitle;
			tf.scaleX = tf.scaleY = 2;
			tf.filters = [];
			tf.x = Std.int( WID*0.5 - tf.textWidth*0.5*tf.scaleX );
			tf.y = 75;
			tf.filters = [
				new flash.filters.GlowFilter(dark,0.6, 2,2, 3),
				new flash.filters.DropShadowFilter(1,90, 0x0, 0.8, 0,0,1)
			];
		}
		
		// Barre bas
		var bottom = new flash.display.Sprite();
		bottom.cacheAsBitmap = true;
		bottom.mouseChildren = bottom.mouseEnabled = false;
		externalSprites.addChild(bottom);

		var bg = new flash.display.Sprite();
		bottom.addChild(bg);
		var g = bg.graphics;
		g.beginFill(dark, alpha);
		g.drawRect(0,-70, WID, 70);
		g.endFill();
		
		// Description
		if( desc!=null ) {
			//g.beginFill(Color.brightnessInt(col, -0.1), 0.7);
			//g.drawRect(WID*0.5-200,-80, 400,100);
			//g.endFill();
			
			var tf = makeField(Color.brightnessInt(col, 0.55));
			bottom.addChild(tf);
			tf.width = 240;
			tf.height = 40;
			tf.multiline = tf.wordWrap = true;
			tf.text = desc;
			tf.scaleX = tf.scaleY = 2;
			tf.x = Std.int(WID*0.5-tf.textWidth*0.5*tf.scaleX);
			tf.y = -82;
		}
		bottom.y = Std.int(HEI+100);
		tw.create(bottom,"y", HEI, TEaseOut, d).fl_pixel = true;
		
		curWindow = {
			top:top,
			bottom:bottom,
			bd:null,
		};
		windowTarget = e;
	}
	
	function setZoom(?z=0.0) {
		var d = if(z==0) 500 else 800;
		for( l in current.layers ) {
			tw.terminate(l, "zoom");
			tw.create(l, "zoom", z, TEaseOut, d);
		}
		for( e in current.entities ) {
			tw.terminate(e, "zoom");
			tw.create(e, "zoom", z, TEaseOut, d);
		}
		tw.create(cursor, "zoom", z, TEaseOut, d);
	}
	
	
	function makeField(col, ?size=10) {
		var f = new flash.text.TextFormat("vis1", size, col);
		//if( center )
			//f.align = flash.text.TextFormatAlign.CENTER;
		var tf = new flash.text.TextField();
		tf.defaultTextFormat = f;
		tf.embedFonts = true;
		tf.antiAliasType = flash.text.AntiAliasType.NORMAL;
		tf.sharpness = 400;
		tf.mouseEnabled = tf.selectable = tf.multiline = tf.wordWrap = false;
		tf.filters = [ new flash.filters.GlowFilter(Color.brightnessInt(col,-0.6),1, 2,2,10) ];
		tf.width = 100;
		tf.height = 20;
		return tf;
	}
	
	function initTip() {
		var c = 0xB0FA05;
		var s = new flash.display.Sprite();
		buffer.addChild(s);
		s.x = s.y = 100;
		s.mouseChildren = s.mouseEnabled = false;
		var tf = makeField(c);
		s.addChild(tf);
		tf.width = 200;
		tf.height = 25;
		//tf.scaleX = tf.scaleY = 2;
		tip = {spr:s, field:tf}
	}
	
	function setTip(?str:Null<String>) {
		tip.spr.alpha = 1;
		if( str==null ) {
			tip.spr.visible = false;
			tip.field.text = "";
		}
		else {
			tip.spr.visible = true;
			tip.field.text = str;
			tip.spr.scaleX = 0;
			tw.create(tip.spr, "scaleX", 1, TLinear, 200);
		}
	}
	
	
	function getReactorsPt() {
		var frame = reactorPoints[shipSpr.getFrame()];
		var r = new Array();
		for(fr in frame) {
			var pt = shipSpr.localToGlobal( new flash.geom.Point(fr.x-SHIP_SIZE*0.5, fr.y-SHIP_SIZE*0.5) );
			pt = scroller.globalToLocal(pt);
			r.push({
				x	: Std.int(pt.x),
				y	: Std.int(pt.y),
				vis	: fr.visible,
			});
		}
		return r;
	}
	
	
	function hyperjumpArrivalFx(speed:Float, ?cb:Void->Void) {
		if( cb!=null )
			haxe.Timer.delay(cb, 600);
		ship.update();
		var a = ship.getAngleRad();
		ship.dx = Math.cos(a)*speed;
		ship.dy = Math.sin(a)*speed;
		var pt = bufferToGlobal({x:ship.spr.x, y:ship.spr.y});
		var f : Array<flash.filters.BitmapFilter>= [ new flash.filters.GlowFilter(REACTOR_COLOR,1, 8,8, 4)];
		ship.spr.visible = true;
		ship.spr.alpha = 0;
		tw.create(ship.spr, "alpha", 1, TEaseIn, 500);
		
		// lignes droites
		for(i in 0...15) {
			var a = ship.rotation*Math.PI/180;
			var s = Math.random()*5+4;
			var p = new Particle(pt.x+Math.random()*7*(Std.random(2)*2-1)-Math.cos(a)*40, pt.y+Math.random()*7*(Std.random(2)*2-1)-Math.sin(a)*40);
			p.drawBox(Std.random(5)+2, Std.random(2)+1, 0xFFFFFF);
			p.gx = p.gy = 0;
			p.life = 10 + Std.random(10);
			p.blendMode = flash.display.BlendMode.ADD;
			p.rotation = a*180/Math.PI;
			p.frictX = p.frictY = 0.80 + Math.random()*0.10;
			p.alpha = Math.random()*0.9+0.1;
			p.filters = [ new flash.filters.GlowFilter(REACTOR_COLOR,1, 8,8, 4) ];
			var scale = 7 * (0.7 + Math.random()*0.3);
			p.onUpdate = function() {
				p.scaleX = (p.getSpeed()/s)*scale;
			}
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			externalSprites.addChild(p);
		}
		
		//for(i in 0...15) {
			//var a = (i/15) * Math.PI*2;
			//var s = Math.random()*7+1;
			//var p = new Particle(pt.x + Math.cos(a)*10, pt.y + Math.sin(a)*10);
			//p.drawBox(Std.random(5)+2, Std.random(2)+1, 0xFFFFFF);
			//p.gx = p.gy = 0;
			//p.life = 10 + Std.random(10);
			//p.blendMode = flash.display.BlendMode.ADD;
			//p.rotation = a*180/Math.PI;
			//p.frictX = p.frictY = 0.80 + Math.random()*0.10;
			//p.alpha = Math.random()*0.9+0.1;
			//p.filters = f;
			//var scale = 6 * (0.7 + Math.random()*0.3);
			//p.onUpdate = function() {
				//p.scaleX = (p.getSpeed()/s)*scale;
			//}
			//p.dx = -Math.cos(a)*s;
			//p.dy = -Math.sin(a)*s;
			//externalSprites.addChild(p);
		//}
		
		novaFx(pt.x-Math.cos(a)*40, pt.y-Math.sin(a)*40, 30, true);
	}
	
	function novaFx(x,y, radius:Float, absorb:Bool) {
		var nova = new flash.display.Sprite();
		nova.graphics.beginFill(0xFFFFFF,1);
		nova.graphics.drawCircle(0,0,radius);
		nova.x = x;
		nova.y = y;
		nova.filters = [
			new flash.filters.GlowFilter(REACTOR_COLOR, 1, 16,16,2, 1, true,true),
			new flash.filters.BlurFilter(4,4),
		];
		nova.scaleX = nova.scaleY = if( absorb ) 1 else 0.3 ;
		nova.blendMode = flash.display.BlendMode.ADD;
		var a = tw.create(nova, "scaleX", if(absorb) 0.3 else 1, TBurnIn, 500);
		a.onUpdateT = function(t) {
			nova.scaleY = nova.scaleX;
			nova.alpha = 0.5*(1-t);
		}
		a.onEnd = function() {
			nova.parent.removeChild(nova);
		}
		externalSprites.addChild(nova);
		return nova;
	}
	
	function hyperjumpFx3D(?cb:Void->Void) {
		if( cb!=null )
			haxe.Timer.delay(cb, 50);
			//cb();
		ship.spr.visible = false;
		var pt = bufferToGlobal({x:ship.spr.x, y:ship.spr.y});
		
		// lignes 3d
		for(i in 0...10) {
			var a = (i/15) * Math.PI*8 + Math.random()*0.05;
			var d = Math.random()*5 + 15;
			var x = pt.x + Math.cos(a)*d;
			var y = pt.y + Math.sin(a)*d;
			var a = Math.atan2(pt.y-y, pt.x-x);
			var s = 2 + Math.random()*0.5;
			var p = new Particle(x,y);
			p.drawBox(15, 2, 0xFFFFFF);
			p.gx = p.gy = 0;
			var maxLife =  15 + Std.random(5);
			p.life = maxLife;
			p.blendMode = flash.display.BlendMode.ADD;
			p.rotation = a*180/Math.PI;
			p.frictX = p.frictY = 0.95;
			p.alpha = Math.random()*0.9+0.1;
			p.filters = [ new flash.filters.GlowFilter(REACTOR_COLOR,1, 8,8, 4) ];
			p.onUpdate = function() {
				p.scaleX = p.scaleY = 1-p.time();
			}
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			externalSprites.addChild(p);
		}
		
		novaFx(pt.x, pt.y, 40, true);
	}
	
	function hyperjumpFxHorizontal(?cb:Void->Void) {
		if( cb!=null )
			haxe.Timer.delay(cb, 300);
		ship.spr.visible = false;
		var pt = bufferToGlobal({x:ship.spr.x, y:ship.spr.y});
		
		// lignes droites
		for(i in 0...15) {
			var fl_back = i<=5;
			var a = (ship.rotation + (fl_back?180:0))*Math.PI/180;
			var s = if( fl_back ) Math.random()*4+1 else Math.random()*5+5;
			var p = new Particle(pt.x+Math.random()*7*(Std.random(2)*2-1), pt.y+Math.random()*7*(Std.random(2)*2-1));
			p.drawBox(Std.random(5)+2, Std.random(2)+1, 0xFFFFFF);
			p.gx = p.gy = 0;
			p.life = 10 + Std.random(10);
			p.blendMode = flash.display.BlendMode.ADD;
			p.rotation = a*180/Math.PI;
			p.frictX = p.frictY = 0.80 + Math.random()*0.10;
			p.alpha = Math.random()*0.9+0.1;
			p.filters = [ new flash.filters.GlowFilter(REACTOR_COLOR,1, 8,8, 4) ];
			var scale = (if(fl_back) 3 else 7) * (0.7 + Math.random()*0.3);
			p.onUpdate = function() {
				p.scaleX = (p.getSpeed()/s)*scale;
			}
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			externalSprites.addChild(p);
		}
		
		novaFx(pt.x, pt.y, 25, false);
	}
	
	function makeHyperspacePart(size:Float) {
		var col = Color.brightnessInt(current.starColor, 0.4);
		var a = Math.random()*Math.PI*2;
		var s = Math.random()*3+3;
		var p = new Particle(buffer.width*0.5, buffer.height*0.5);
		p.dx = Math.cos(a)*s;
		p.dy = Math.sin(a)*s;
		var n = 2 + Math.random()*40;
		p.setPos(p.x+p.dx*n, p.y+p.dy*n);
		p.graphics.lineStyle(1, col,1, flash.display.LineScaleMode.NONE);
		p.graphics.moveTo(0,0);
		p.graphics.lineTo(1.5,0);
		p.life = 20;
		p.rotation = a*180/Math.PI;
		p.onUpdate = function() {
			p.scaleX = size * p.getSpeed()*0.8;
		}
		p.alpha = Math.random()*0.8+0.2;
		p.gx = p.gy = 0;
		p.frictX = p.frictY = 1.15;
		p.filters = [ new flash.filters.GlowFilter(current.starColor,1,8,8, 4) ];
		fdm.add(p, DP_FX);
	}
	
	function stopShip(?brake=false) {
		if( brake )
			ship.dx = ship.dy = 0;
		if( targetObject!=null ) {
			targetObject.spr.filters = [];
			targetObject = null;
			setTip();
		}
		ship.target = null;
	}
	
	function moveShip(?e:Entity, ?pt:{x:Int,y:Int}) {
		stopShip();
		if( curWindow!=null && (e==null || e!=windowTarget) ) {
			hideWindow();
			setZoom();
		}
			
		// Entité
		if( e!=null ) {
			targetObject = e;
			targetObject.spr.filters =  [
				//new flash.filters.GlowFilter(0xF2FFC6,1, 3,3, 2),
				//new flash.filters.GlowFilter(0xACFF00,0.5, 8,8, 1, 1),
			];
			ship.target = {x:e.x, y:e.y}
			cursor.spr.alpha = 1;
			cursor.scale = 4;
			tw.create(cursor, "scale", 3, TEaseOut, 250);
			if( current==sector ) {
				// Système solaire
				var s = getSystem(e.dataId);
				switch( s.status ) {
					case SystemStatus.SOpen :
						ship.onArriveDist = 0;
						ship.onArrive = function() {
							onReachSystem(e);
						}
					
					case SystemStatus.SLocked(cost) :
						ship.onArriveDist = 30;
						ship.onArrive = function() {
							if( windowTarget!=targetObject ) {
								setWindow(targetObject, s.name, s.x+","+s.y);
								addButton(Lang.get("unlockSystem"), function() {
									sendAction( AUnlockSystem(s.id) );
								});
								setZoom(0.6);
							}
						}
				}
			}
			if( current==solar ) {
				// Planète
				var p = getPlanet(e.dataId);
				ship.onArriveDist = 30;
				ship.onArrive = function() {
					if( windowTarget!=targetObject ) {
						setWindow(targetObject, p.name, p.bname );
						switch( p.status ) {
							case PUnexplored :
								addButton(Lang.get("scan"), function() {
									if( !infos.freeLicense ) {
										popString(Lang.get("noLicense"), 0xFFC600);
										return;
									}
									loading(true);
									fl_serverLock = true;
									fl_lockControls = true;
									initMask.visible = true;
									clearGps();
									tw.create(initMask, "alpha", 1, TEaseIn, 1000).onEnd = function() {
										showBar(0);
										popString(p.name,false);
										haxe.Timer.delay(function() {
											mt.Timer.pause();
											server.startGeneratePlanet(
												p,
												function(p) showBar(p),
												function() {
													mt.Timer.restore();
													showBar(1);
													sendAction(ALandPlanet(p.id));
												}
											);
										}, 500);
									}
								});
							case PActive, PInvited :
								addButton(Lang.get("land"), function() {
									sendAction(ALandPlanet(p.id));
								});
							case PAbandonned, PForbidden :
						}
						setZoom(0.6);
					}
				}
			}
		}
		
		// Point libre
		if( pt!=null ) {
			if( current.wallRadiusX!=0 && current.wallRadiusY!=0 ) {
				var dx = (pt.x-current.center.x)/current.center.x;
				var dy = (pt.y-current.center.y)/current.center.y;
				var d = Math.sqrt( Math.pow(dx, 2) + Math.pow(dy, 2) );
				if( d>1 ) {
					var a = Math.atan2(dy,dx);
					pt.x = Std.int( current.center.x + Math.cos(a)*(current.center.x-1) );
					pt.y = Std.int( current.center.y + Math.sin(a)*(current.center.y-1) );
				}
			}
			
			if( pt.x<0 ) pt.x = 0;
			if( pt.x>=current.width ) pt.x = current.width-1;
			if( pt.y<0 ) pt.y = 0;
			if( pt.y>=current.height ) pt.y = current.height-1;
			
			ship.onArrive = null;
			targetObject = null;
			ship.target = { x:pt.x, y:pt.y }
			cursor.x = ship.target.x;
			cursor.y = ship.target.y;
			cursor.scale = 1.5;
			tw.create(cursor, "scale", 1, TEaseOut, 250);
		}
	}
	
	
	function initSpherize() {
		spherize = new flash.display.BitmapData(buffer.width, buffer.height, true, 0x0);
		var s = new flash.display.Sprite();
		var w = buffer.width;
		var h = buffer.height;
		var gsteps = 15;

		var alpha = [];
		var steps = [];
		for( x in 0...gsteps+1 ) {
			steps.push( Std.int(255*x/gsteps) );
			alpha.push(1.0);
		}
		
		// distorsion Y (red channel)
		var m = new flash.geom.Matrix();
		m.createGradientBox(w*0.5, h);
		var colors = [];
		for( x in 0...gsteps+1 ) {
			var c = Std.int( 0xff * Math.pow(x/gsteps,2) );
			colors.push( Color.rgbToInt({r:c, g:0, b:0}) );
		}
		colors.reverse();
		s.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alpha, steps, m, flash.display.SpreadMethod.REFLECT);
		s.graphics.drawRect(0,0,w,h);
		spherize.draw(s);
		
		// distorsion X (green channel)
		var m = new flash.geom.Matrix();
		m.createGradientBox(w, h*0.5, Math.PI/2);
		var colors = [];
		for( x in 0...gsteps+1 ) {
			var c = Std.int( 0xff * (1-Math.cos(x/gsteps)) );
			colors.push( Color.rgbToInt({r:0, g:c, b:0}) );
		}
		colors.reverse();
		s.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alpha, steps, m, flash.display.SpreadMethod.REFLECT);
		s.graphics.drawRect(0,0,w,h);
		spherize.draw(s, flash.display.BlendMode.SCREEN);
		
		setSpherize(USE_SPHERIZE);
	}
	
	function onMouseUp(_) {
		if( fl_lockControls || fl_serverLock )
			return;
			
		var fl_clickBg = true;
		for( b in buttons ) {
			b.registerStageClick(false);
			if( b.over )
				fl_clickBg = false;
		}
		if( fl_clickBg )
			for( b in current.buttons ) {
				b.registerStageClick(false);
				if( b.over )
					fl_clickBg = false;
			}
		if( fl_clickBg )
			moveShip( getMouseInMap() );
	}
	
	function onMouseDown(_) {
		if( fl_lockControls || fl_serverLock )
			return;
			
		for( b in buttons )
			b.registerStageClick(true);
		for( b in current.buttons )
			b.registerStageClick(true);
	}
	
	function setSpherize(b) {
		USE_SPHERIZE = b;
		if( USE_SPHERIZE )
			buffer.postFilters = [
				new flash.filters.DisplacementMapFilter(spherize, new flash.geom.Point(0,0), 2,1, SPHERIZE_X,SPHERIZE_Y, flash.filters.DisplacementMapFilterMode.COLOR),
			];
		else
			buffer.postFilters = [];
	}
	
	function bufferToGlobal( pt:{x:Float,y:Float} ) {
		if( USE_SPHERIZE ) {
			var x = pt.x;
			var y = pt.y;
			if( x>=buffer.width ) x = buffer.width-1;
			if( y>=buffer.height ) y = buffer.height-1;
			if( x<0 ) x = 0;
			if( y<0 ) y = 0;
			var col = Color.intToRgb( spherize.getPixel(Std.int(x), Std.int(y)) );
			var f = col.g/(0.5*0xff)-1;
			pt.x -= Std.int( f*SPHERIZE_X*0.5 );
			var f = col.r/(0.5*0xff)-1;
			pt.y -= Std.int( f*SPHERIZE_Y*0.5 );
		}
		return buffer.localToGlobalFloat( pt.x, pt.y );
	}
	
	function globalToMap( pt:{x:Float,y:Float} ) {
		if( USE_SPHERIZE ) {
			var col = Color.intToRgb( spherize.getPixel(Std.int(pt.x/UPSCALE), Std.int(pt.y/UPSCALE)) );
			var f = col.g/(0.5*0xff)-1;
			pt.x += Std.int( UPSCALE * f*SPHERIZE_X*0.5 );
			var f = col.r/(0.5*0xff)-1;
			pt.y += Std.int( UPSCALE * f*SPHERIZE_Y*0.5 );
		}
		var pt = buffer.globalToLocal( pt.x, pt.y );
		if( pt.x>=buffer.width ) pt.x = buffer.width-1;
		if( pt.y>=buffer.height ) pt.y = buffer.height-1;
		if( pt.x<0 ) pt.x = 0;
		if( pt.y<0 ) pt.y = 0;
		return pt;
	}
	
	function mapToGlobal( pt:{x:Float,y:Float} ) {
		pt.x+=scroller.x;
		pt.y+=scroller.y;
		var pt = buffer.localToGlobal( pt.x, pt.y );
		if( USE_SPHERIZE ) {
			var col = Color.intToRgb( spherize.getPixel(Std.int(pt.x/UPSCALE), Std.int(pt.y/UPSCALE)) );
			var f = col.g/(0.5*0xff)-1;
			pt.x -= Std.int( UPSCALE * f*SPHERIZE_X*0.5 );
			var f = col.r/(0.5*0xff)-1;
			pt.y -= Std.int( UPSCALE * f*SPHERIZE_Y*0.5 );
		}
		return {x:Math.round(pt.x), y:Math.round(pt.y)}
	}
	
	function getMouse() {
		return globalToMap( {x:root.stage.mouseX, y:root.stage.mouseY} );
	}
	
	function getMouseInMap() {
		var pt = getMouse();
		pt.x -= Std.int(scroller.x);
		pt.y -= Std.int(scroller.y);
		return pt;
	}
	
	function centerView(?duration=0, ?cb:Void->Void) {
		if( duration>0 && (current.viewPort.x!=ship.x || current.viewPort.y!=ship.y) ) {
			var n = 2;
			var onEnd = function() {
				if( --n==0 ) {
					fl_lockCamera = false;
					if( cb!=null ) cb();
				}
			}
			fl_lockCamera = true;
			tw.create(current.viewPort, "x", ship.x, TEase, duration).onEnd = onEnd;
			tw.create(current.viewPort, "y", ship.y, TEase, duration).onEnd = onEnd;
		}
		else {
			current.viewPort.x = ship.x;
			current.viewPort.y = ship.y;
			fl_lockCamera = false;
			if( cb!=null ) cb();
		}
	}
	
	function refreshSolar() {
		if( current!=solar )
			return;
			
		hideWindow();
		setZoom();
		stopShip();
		var pt = {x:ship.x, y:ship.y};
		gotoSolar(curSystem, false);
		ship.x = pt.x;
		ship.y = pt.y;
		centerView();
	}
	
	function generateSolar(infos:SystemInfos) {
		curSystem = infos;
		
		// génération système d'arrivée
		if( solar!=null )
			solar.destroy();
		solar = new Room(infos.seed);
		solar.generateSolarSystem(infos);
		solar.finalize();

		// génératon bg du système d'arrivée
		if( solarStars!=null )
			solarStars.destroy();
		solarStars = new Room(infos.seed);
		solarStars.bgColor = solar.bgColor;
		solarStars.generateSolarStars();
		solarStars.finalize();
		solarStars.viewPort = solar.viewPort.clone();
	}
	
	
	
	function gotoSolar(inf:SystemInfos, anim:Bool) {
		clearGps();
		function processEnd() {
			sector.hide();
			solarStars.show();
			common.show();
			solar.show();

			setBg(solar.bgColor);

			current = solar;
			ship.x = solar.entrance.x;
			ship.y = solar.entrance.y;
			fl_lockControls = false;
			if( zoomCache.bitmapData!=null ) {
				zoomCache.visible = false;
				zoomCache.bitmapData.dispose();
				zoomCache.bitmapData = null;
			}

			for(l in solarStars.layers)
				l.zoom = ANIM_SOLARSTAR_ZOOM;
			
			for(l in common.layers) {
				l.zoom = ANIM_COMMON_ZOOM;
				l.cont.alpha = COMMON_HIGH_ALPHA;
			}
			
			for(p in inf.planets)
				if( p.status==PActive || p.status == PInvited )
					addGpsPlanet(p);

			ship.room = cursor.room = current;
		}
		
		function zoomAnim() {
			var total = 1300;
			var solarSeed = inf.seed;
			stopShip(true);
			fl_lockControls = true;
			fl_lockCamera = true;
			ship.spr.visible = false;
			ship.spr.alpha = 1;
			var arrivalAng = (180+ship.rotation)*Math.PI/180;
			
			tw.create(cursor.spr, "alpha", 0, TEaseIn, 300);
			
			// sauvegarde du pt
			sector.entrance.x = ship.x;
			sector.entrance.y = ship.y;

			// Progression générale
			var zoomProgress = {t:0.0}
			var a = tw.create(zoomProgress, "t", 1, TLinear, total);
			a.onUpdateT = function(t) {
				if( t>=0.10 && t<=0.60 ) {
					var ratio = 1-(t-0.10)/0.50;
					for(i in 0...Std.int(ratio*10+Std.random(10)))
						makeHyperspacePart(ratio);
				}
			}
			a.onEnd = function() {
				popString(inf.name);
				processEnd();
				ship.rotation = 180 + arrivalAng*180/Math.PI;
				centerView( Std.int(total*0.8) );
				hyperjumpArrivalFx(10);
			}
			
			// init système solaire
			var newBgCol = solar.bgColor;
			//setBg( Color.capBrightnessInt(newBgCol, 0.25), total );
			setBg(newBgCol, total);
			solar.entrance.x = solar.center.x + Math.cos(arrivalAng) * Math.min(250, solar.exitDist-10);
			solar.entrance.y = solar.center.y + Math.sin(arrivalAng) * Math.min(250, solar.exitDist-10);
			solar.viewPort.x = solar.entrance.x;
			solar.viewPort.y = solar.entrance.y;
			solar.hide();
			solarStars.viewPort = solar.viewPort.clone();
			
			// préparation bitmap zoom
			if( zoomCache.bitmapData!=null )
				zoomCache.bitmapData.dispose();
			zoomCache.bitmapData = solar.snapshot();
			zoomCache.visible = false;

			// Mise à jour couleur burn
			burn.graphics.clear();
			burn.graphics.beginFill(Color.interpolateInt(solar.sunColor, 0xF46800, 0.3), 1);
			burn.graphics.drawRect(0,0, buffer.width, buffer.height);

			// burn au départ
			//burn.visible = true;
			//burn.alpha = 0.5;
			//tw.create(burn, "alpha", 0, TEaseOut, 600).onEnd = function() burn.visible = false;
			
			// burn à l'arrivée
			var oc = Color.brightnessInt(newBgCol,0.6);
			oc = Color.rgbToInt( Color.saturation(Color.intToRgb(oc), -0.3) );
			overdriveBurn.graphics.clear();
			overdriveBurn.graphics.beginFill( oc, 1 );
			overdriveBurn.graphics.drawRect(0,0, buffer.width, buffer.height);
			overdriveBurn.visible = false;
			haxe.Timer.delay( function() {
				overdriveBurn.visible = true;
				overdriveBurn.alpha = 0;
				tw.create(overdriveBurn, "alpha", 0.7, TEaseIn, total*0.6).onEnd = function() {
					tw.create(overdriveBurn, "alpha", 0, TEaseOut, total*0.4).onEnd = function() overdriveBurn.visible = false;
				}
				//tw.create( buffer.render, "x", 4, TShakeBoth, d*0.8 );
				//tw.create( buffer.render, "y", 4, TShakeBoth, d*0.8 );
			}, Std.int(total*0.4));
			
			// zoom du bg du système d'arrivée
			solarStars.show();
			for(l in solarStars.layers) {
				l.zoom = 0;
				l.cont.alpha = 0;
				tw.create(l, "zoom", ANIM_SOLARSTAR_ZOOM, TEaseOut, total);
				tw.create(l.cont, "alpha", 1, TEaseOut, total);
			}
			
			// zoom layers du fond commun
			for(l in common.layers) {
				tw.create(l, "zoom", ANIM_COMMON_ZOOM, TEase, total);
				tw.create(l.cont, "alpha", COMMON_HIGH_ALPHA, TEase, total);
			}

			// zoom sur système solaire d'arrivée
			var d = total*0.9;
			var e = TEase;
			zoomCache.scaleX = zoomCache.scaleY = 1;
			var cacheX = buffer.width*0.5-zoomCache.width*0.5;
			var cacheY = buffer.height*0.5-zoomCache.height*0.5;
			zoomCache.visible = true;
			zoomCache.scaleX = zoomCache.scaleY = 0.01;
			zoomCache.alpha = 0.5;
			zoomCache.x = buffer.width*0.5 - zoomCache.width*0.5;
			zoomCache.y = buffer.height*0.5 - zoomCache.height*0.5;
			haxe.Timer.delay( function() {
				tw.create(zoomCache, "scaleX", 1, e, d).onUpdateT = function(t) {
					zoomCache.scaleY = zoomCache.scaleX;
				}
				tw.create(zoomCache, "x", cacheX, e, d);
				tw.create(zoomCache, "y", cacheY, e, d);
				tw.create(zoomCache, "alpha", 1, TEaseOut, 500);
			}, Std.int(total*0.1));
			
			
			// zoom du secteur actuel
			var d = total * 0.8;
			for(l in sector.layers) {
				l.zoom = 0;
				tw.create(l, "zoom", ANIM_SECTOR_ZOOM, TEaseIn, d).onUpdateT = function(t) {
					l.cont.alpha = 1-t;
				}
			}
			
			// entités
			for(e in sector.entities) {
				e.zoom = 0;
				tw.create(e, "zoom", ANIM_SECTOR_ZOOM*0.2, TEaseIn, d*0.4).onUpdateT = function(t) {
					e.spr.alpha = 1-t;
				}
			}
			
			mt.Timer.restore();
		}
		
		if( anim ) {
			mt.Timer.pause();
			generateSolar(inf);
			solar.hide();
			solarStars.hide();
			hyperjumpFx3D( zoomAnim );
		}
		else {
			generateSolar(inf);
			processEnd();
			centerView();
		}
	}
	
	
	function gotoSector(from:Null<SystemInfos>, anim:Bool) {
		clearGps();
		curSystem = null;
		if( from!=null ) {
			var pt = sector.gridToMap({x:from.x, y:from.y});
			sector.entrance.x = pt.x;
			sector.entrance.y = pt.y;
		}
		
		function processEnd() {
			fl_lockControls = false;
			ship.room = cursor.room = current;
			
			for( s in infos.systems )
				if( s.status==SOpen )
					if( Lambda.filter(s.planets, function(p) return p.status==PActive || p.status == PInvited).length>0 )
						addGpsSystem(s);
		}
		
		function zoomAnim() {
			stopShip();
			fl_lockControls = true;
			var total = 800; //1100;
			ship.spr.visible = false;
			ship.spr.alpha = 1;
			var arrivalAng = ship.rotation;

			// Progression générale
			var zoomProgress = {t:0.0}
			var a = tw.create(zoomProgress, "t", 1, TLinear, total);
			a.onEnd = function() {
				processEnd();
				zoomCache.bitmapData.dispose();
				zoomCache.bitmapData = null;
				zoomCache.visible = false;
				ship.rotation = arrivalAng;
				hyperjumpArrivalFx(6);
			}
			
			if( zoomCache.bitmapData!=null )
				zoomCache.bitmapData.dispose();
			zoomCache.bitmapData = solar.snapshot();
			zoomCache.visible = true;
			zoomCache.scaleX = zoomCache.scaleY = 1;
			zoomCache.alpha = 1;
			zoomCache.x = buffer.width*0.5-zoomCache.width*0.5;
			zoomCache.y = buffer.height*0.5-zoomCache.height*0.5;
			
			ship.x = sector.entrance.x + Math.cos(arrivalAng*Math.PI/180)*20;
			ship.y = sector.entrance.y + Math.sin(arrivalAng*Math.PI/180)*20;
			
			// Zoom système solaire
			var d = total*1;
			var e = TBurnIn;
			var s = 0.01;
			solar.destroy();
			solar = null;
			tw.create(zoomCache, "x", buffer.width*0.5 - zoomCache.width*0.5*s, e, d);
			tw.create(zoomCache, "y", buffer.height*0.5 - zoomCache.height*0.5*s, e, d);
			tw.create(zoomCache, "scaleX", s, e, d);
			tw.create(zoomCache, "scaleY", s, e, d);
			haxe.Timer.delay( function() {
				tw.create(zoomCache, "alpha", 0, TEaseIn, d*0.5);
			}, Std.int(d*0.5) );
			
			tw.create(burn, "alpha", 0, TEaseIn, d);
			
			// burn au départ
			overdriveBurn.visible = true;
			overdriveBurn.alpha = 0.6;
			tw.create(overdriveBurn, "alpha", 0, TEaseOut, 800).onEnd = function() overdriveBurn.visible = false;
			
			// zoom layers du bg de système
			for(l in solarStars.layers) {
				tw.create(l, "zoom", 0, e, d);
				tw.create(l.cont, "alpha", 0, e, d);
			}

			// zoom layers du fond commun
			for(l in common.layers) {
				tw.create(l, "zoom", 0, TEaseOut, total);
				tw.create(l.cont, "alpha", COMMON_LOW_ALPHA, e, d);
			}

			
			// zoom layers du sector
			var d = total;
			current = sector;
			current.show();
			centerView();
			for(l in sector.layers) {
				l.cont.alpha = 0;
				l.zoom = ANIM_SECTOR_ZOOM;
				tw.create(l, "zoom", 0, TEaseOut, d);
				tw.create(l.cont, "alpha", 1, TEaseIn, d);
			}
			for(e in sector.entities) {
				e.spr.alpha = 0;
				e.zoom = ANIM_SECTOR_ZOOM*0.2;
				haxe.Timer.delay(function() {
					tw.create(e, "zoom", 0, TEaseOut, d*0.5).onUpdateT = function(t) {
						e.spr.alpha = t;
					}
				}, Std.int(d*0.5));
			}
			
			//setBg( Color.darken(sector.bgColor, 0.8), d );
			setBg(sector.bgColor, d);
		}
		
		if( anim ) {
			fl_lockControls = true;
			hyperjumpFxHorizontal( zoomAnim );
		}
		else
			processEnd();
	}
	
	
	function getPlanetSystem(planetId:Int) : SystemInfos{
		for( s in infos.systems )
			for( p in s.planets )
				if( p.id==planetId )
					return s;
		throw "Unknown planet "+planetId;
	}
	
	function getPlanet(id:Int) : SystemPlanetInfos {
		for(p in curSystem.planets)
			if( p.id==id )
				return p;
		throw "Unknown planet "+id;
	}
	
	function getSystem(id:Int) : SystemInfos {
		for(s in infos.systems)
			if( s.id==id )
				return s;
		throw "Unknown system "+id;
	}
	
	
	function onReachSystem(e:Entity) {
		fl_lockControls = true;
		centerView(200, function() {
			var s = getSystem(e.dataId);
			sendAction( ASetShipPos(PInSystem(s.id)), function() {
				gotoSolar(s, true);
			});
		});
	}
	
	function sendAction(a:ExploreAction, ?onOk:Void->Void) {
		loading(true);
		fl_serverLock = true;
		server.sendAction(a, function() {
			loading(false);
			fl_serverLock = false;
			if( onOk != null ) onOk();
		});
	}
	
	
	function main(_) {
		mt.Timer.update();
		tw.update(mt.Timer.tmod);
		if( QUALITY!=flash.display.StageQuality.LOW )
			if( mt.Timer.fps()<20 && lowFrames++>90 )
				setQuality( flash.display.StageQuality.LOW );
			else
				lowFrames = 0;
		
		if( loadingAnim.visible && loadingAnim.alpha>0 ) {
			loadingAnim.rotation+=25;
			while( loadingAnim.rotation>=360 )
				loadingAnim.rotation-=360;
		}
		
		if( !fl_serverLock ) {
			var mouse = getMouse();
			for( b in buttons )
				b.update(mouse);
			for( b in current.buttons )
				b.update(mouse);
				
			//var pt = mapToScreen( {x:cursor.x, y:cursor.y} );
			//var g = test.graphics;
			//g.clear();
			//g.lineStyle(1,0xFF0000,1);
			//g.drawRect(pt.x-10, pt.y-10, 20,20);
			//g.endFill();
			
			if( debugStats && Key.isToggled("S".code) )
				trace("seed="+infos.sector.seed);
				
			if( !fl_lockControls ) {
				if( debugStats && Key.isToggled(Keyboard.ENTER) ) {
					//if( Key.isDown(Keyboard.SHIFT) )
						//hyperjumpArrivalFx(0);
					//else
						//hyperjumpFx3D();
					//var bmp = new flash.display.Bitmap( current.snapshot() );
					//bmp.scaleX = bmp.scaleY = 0.5;
					//test.addChild( bmp );
					//for( i in 0...10)
						//makeHyperspacePart(1);
				}
				
				// sortie du système solaire par les bords
				if( current==solar ) {
					var d = Math.sqrt( Math.pow(ship.x-current.center.x, 2) + Math.pow(ship.y-current.center.y, 2) );
					if( ship.target!=null && !fl_serverLock && !fl_lockControls ) {
						var td = Math.sqrt( Math.pow(ship.target.x-current.center.x, 2) + Math.pow(ship.target.y-current.center.y, 2) );
						if( d>=current.exitDist-30 && td>=current.exitDist ) {
							sendAction( ASetShipPos(PInSector(curSystem.x, curSystem.y)), function() {
								gotoSector(curSystem, true);
							});
						}
					}
					if( d>=current.exitDist )
						stopShip();
				}
			}
			
			if( Key.isToggled("D".code) )
				setSpherize(!USE_SPHERIZE);
				
		}
			
		// Curseur cible
		if( ship.target!=null ) {
			cursor.x = ship.target.x;
			cursor.y = ship.target.y;
		}
		var d = ship.getTargetDist();
		if( targetObject==null && d<25 && cursor.spr.alpha>0 )
			cursor.spr.alpha-=0.1;
		if( d>=25 && cursor.spr.alpha<1 )
			cursor.spr.alpha+=0.1;
		cursor.rotation+=7;
		while( cursor.rotation>=360 )
			cursor.rotation-=360;

		if( targetObject!=null ) {
			tip.spr.x = current.viewPort.width*0.5 + targetObject.x-current.viewPort.x + 20;
			tip.spr.y = current.viewPort.height*0.5 + targetObject.y-current.viewPort.y - 10;
		}

		if( ship.getScreenSpeed()>0.3 )
			ship.rotation = ship.getAngleDeg();
			
		
		// scrolling
		var spd = if(UPSCALE==2) 0.2 else 0.1;
		#if debug spd = 0.4; #end
		var deadZone = 0;
		if( !fl_lockCamera ) {
			var pt = { xr : (ship.x+scroller.x)/buffer.width, yr : (ship.y+scroller.y)/buffer.height }
			if( pt.xr<0.5-deadZone || pt.xr>0.5+deadZone )
				current.viewPort.x += (ship.x-current.viewPort.x) * spd;
			if( pt.yr<0.5-deadZone || pt.yr>0.5+deadZone )
				current.viewPort.y += (ship.y-current.viewPort.y) * spd;
		}
		scroller.x = Std.int( -current.viewPort.x + current.viewPort.width*0.5 );
		scroller.y = Std.int( -current.viewPort.y + current.viewPort.height*0.5 );
		
		
		// Chaleur soleil
		if( current.sun!=null ) {
			var r = 1-Math.sqrt( Math.pow(ship.x-current.center.x,2) + Math.pow(ship.y-current.center.y,2) ) / 140;
			if( r>0 )
				burn.alpha = Math.min(r,0.9) + Math.random()*r*0.1;
			burn.visible = r>0;
		}
		
		common.viewPort = sector.viewPort.clone();
		common.update();
		sector.update();
		if( solar!=null )
			solar.update();
		if( solarStars!=null ) {
			if( current==solar )
				solarStars.viewPort = current.viewPort.clone();
			solarStars.update();
		}
		
		cursor.update();
		ship.update(mt.Timer.tmod);
		
		// rotation du modèle de vaisseau
		if( shipSpr!=null ) {
			shipSpr.x = ship.spr.x;
			shipSpr.y = ship.spr.y;
			shipSpr.visible = ship.spr.visible;
			shipSpr.alpha = ship.spr.alpha;
			var r = 1 - ((360 + 90 + ship.rotation)%360)/360;
			var f = Math.floor((SHIP_FRAMES-1)*r);
			shipSpr.setFrame( f );
			var delta = SHIP_FRAMES*r - f;
			shipSpr.rotation = -delta*(360/SHIP_FRAMES);
		}
		
		// Particules réacteurs
		var spd = ship.getScreenSpeed();
		if( reactorPoints!=null && spd>1 ) {
			var a = ship.getAngleRad();
			var s = Math.min(1, spd*0.8);
			var col = REACTOR_COLOR;
			for(pt in getReactorsPt() ) {
				for(i in 0...2) {
					var p = new Particle(pt.x - Math.cos(a)*7, pt.y - Math.sin(a)*7);
					var a = a + Math.random()*0.08*(Std.random(2)*2-1);
					var w = spd<1.5 ? 4 : (spd>3 ? 20 : 10);
					var h = spd<1.5 ? 6 : 2;
					p.drawBox(w,h, col, Math.random()*0.7+0.3);
					p.rotation = a*180/Math.PI;
					p.gx = p.gy = 0;
					p.life = Std.random(6)+2;
					p.dx = Math.cos( a )*s;
					p.dy = Math.sin( a )*s;
					p.onUpdate = function() {
						p.scaleX = 1-p.time();
					}
					
					p.filters = [ new flash.filters.GlowFilter(col,1,8,8, 2) ];
					p.blendMode = flash.display.BlendMode.ADD;
					scroller.addChild(p);
				}
			}
			lastShipAng = a;
		}
		
		// GPS
		for( g in gps ) {
			var a = Math.atan2(g.target.y-ship.y, g.target.x-ship.x);
			var d = Lib.distance( g.target.x, g.target.y, ship.x, ship.y );
			g.arrow.alpha = Math.min(1, Math.max(0, (d-50)/50));
			var ad = 64*Math.min(1, Math.max(0, (d-50)/50));
			g.arrow.x = shipSpr.x + Math.cos(a)*ad;
			g.arrow.y = shipSpr.y + Math.sin(a)*ad;
			g.arrow.rotation = a*180/3.14;
		}

		DSprite.updateAll();
		Particle.update();
		buffer.update();
	}
}
