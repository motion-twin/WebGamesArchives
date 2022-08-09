package b;

import Const;
import mt.deepnight.Lib;
import mt.MLib;
import com.*;
import com.Protocol;
import mt.deepnight.slb.*;
import b.r.*;

import h2d.Bitmap;
import h2d.Sprite;
import h2d.Graphics;
import h2d.SpriteBatch;

enum
HotelChunk {
	CT_Empty;
	CT_Building1;
	CT_Building2;
}


class Hotel extends H2dProcess {
	public static var ME : Hotel;

	var shotel(get,null)		: com.SHotel;

	public var rooms	: Array<Room>;
	public var mainBg	: h2d.Bitmap;
	var mainBgHei		: Int;
	var light			: h2d.Bitmap;
	var lightGlow		: h2d.Bitmap;
	var bgPadding		: Int;

	var elements		: Array<BatchElement>;
	var roofName		: h2d.TextBatchElement;
	var roofStruct		: BatchElement;
	var bgScale			= Assets.SCALE;

	public var top		: Int;
	public var bottom	: Int;
	public var left		: Int;
	public var right	: Int;

	var fxEmitters		: Array<Void->Void>;
	var bgCars			: Array<{ be:Null<BatchElement>, seed:Int, x:Float, spd:Float }>;
	var greenMode		: Bool;

	public function new() {
		super(Game.ME);
		Game.ME.scroller.add(root, Const.DP_HOTEL);
		root.name = "Hotel";
		greenMode = false;

		elements = [];
		mainBgHei = 0;
		top = bottom = left = right = 0;
		name = "HotelRender";
		ME = this;
		rooms = [];
		fxEmitters = [];
		bgCars = [];
		bgPadding = 200;

		mainBg = Assets.tiles.getH2dBitmap("white");
		Game.ME.root.add(mainBg, Const.DP_BG);
		mainBg.hasAlpha = false;
		mainBg.filter = true;
		mainBg.name = "Hotel.mainBg";

		light = Assets.tiles.getH2dBitmap("fxLightHouse",0, 0.5,0.5, true, mainBg);
		light.blendMode = Add;
		light.name = "Hotel.lightHouseLight";

		lightGlow = Assets.tiles.getH2dBitmap("fxGoldGlow",0, 0.5,0.5, true, mainBg);
		lightGlow.blendMode = Add;
		lightGlow.name = "Hotel.lightHouseGlow";


		var n = 8;
		for(i in 0...Std.int(n/2))
			bgCars.push({ be:null, x:500*i + rnd(0,50,true), seed:Std.random(99999), spd:6 });

		for(i in 0...Std.int(n/2))
			bgCars.push({ be:null, x:500*i + rnd(0,50,true), seed:Std.random(99999), spd:-4 });
	};

	inline function get_shotel() return Game.ME.shotel;

	public function getRoomAt(cx,cy) : Null<Room> {
		for(r in rooms)
			if( !r.destroyed && (cx>=r.rx && cx<r.rx+r.rwid) && r.ry==cy )
				return r;
		return null;
	}

	public function getLobby() : b.r.Lobby return cast getRoom(R_Lobby);

	public function getRoom(t:RoomType, ?inclConstructing=true) : Null<b.Room> {
		for(r in rooms)
			if( !r.destroyed && r.sroom.type==t && (inclConstructing || !r.isUnderConstruction()) )
				return r;
		return null;
	}

	public function getRooms(t:RoomType) : Array<b.Room> {
		var a = [];
		for(r in rooms)
			if( !r.destroyed && r.sroom.type==t )
				a.push(r);
		return a;
	}

	public function getNameBase() : Null<Room> {
		var roofY = 0;
		for(r in rooms)
			if( roofY<=0 || !r.destroyed && r.ry>=roofY && !r.sroom.isFiller() )
				roofY = r.ry;

		if( roofY<=0 )
			return null;

		var all = [];
		var x = 0.;
		for(r in rooms)
			if( r.ry==roofY && !r.destroyed && !r.sroom.isFiller()) {
				x+=r.rx;
				all.push(r);
			}
		x/=all.length;
		var base = all[0];
		for(r in all)
			if( !r.destroyed && MLib.fabs(base.rx-x)>MLib.fabs(r.rx-x) )
				base = r;

		return base;
	}

	public inline function hasRoom(cx,cy) {
		return shotel.hasRoom(cx,cy) && !getRoomAt(cx,cy).destroyed;
	}

	public inline function hasRoomWithWalls(cx,cy) {
		var r = getRoomAt(cx,cy);
		return r!=null && !r.destroyed && !r.is(R_FillerStructs);
	}

	override function onResize() {
		super.onResize();
		updateMainBg();
	}

	override function onDispose() {
		super.onDispose();

		if( roofName!=null ) {
			roofName.dispose();
			roofName = null;
		}

		for(r in rooms)
			r.destroy();
		rooms = null;

		bgCars = null;

		mainBg.dispose();
		mainBg = null;

		light.dispose();
		light = null;

		lightGlow.dispose();
		lightGlow = null;

		fxEmitters = null;

		if( ME==this )
			ME = null;

	}

	public static function gridToPixels(rx:Float, ry:Float) {
		return {
			x	: Std.int( rx * Const.ROOM_WID ),
			y	: Std.int( -ry * Const.ROOM_HEI ),
		}
	}

	public function attachRoom(sr:com.SRoom, ?redrawSurroundings=true) : b.Room {
		var r = getRoomAt(sr.cx, sr.cy);
		var wasSelected = r!=null && r.isSelected();
		if( wasSelected )
			Game.ME.unselect();

		// Save existing clients
		var clients = r!=null ? r.getAllClientsInside() : [];

		if( r!=null )
			r.destroy();

		var x = sr.cx;
		var y = sr.cy;
		var r = switch( sr.type ) {
			case R_Bedroom : new b.r.Bedroom(x,y);
			case R_Lobby : new b.r.Lobby(x,y);
			case R_Laundry : new b.r.Laundry(x,y);
			case R_ClientRecycler : new b.r.ClientRecycler(x,y);
			//case R_SouvenirShop : new b.r.SouvenirShop(x,y);
			case R_Bar : new b.r.Bar(x,y);
			case R_Trash : new b.r.Trash(x,y);
			//case R_AffectCold : new b.r.AffectRoom(x,y, Cold);
			//case R_AffectHeat : new b.r.AffectRoom(x,y, Heat);
			//case R_AffectNoise : new b.r.AffectRoom(x,y, Noise);
			//case R_AffectOdor : new b.r.AffectRoom(x,y, Odor);
			//case R_Psy : new b.r.Psy(x,y);
			//case R_Restaurant : new b.r.Restaurant(x,y);
			case R_StockPaper, R_StockSoap, R_StockBeer : new b.r.Stock(x,y);
			case R_StockBoost: new b.r.Generator(x,y);
			case R_Library : new b.r.Library(x,y);
			case R_LevelUp : new b.r.LevelUp(x,y);
			case R_FillerStructs : new b.r.FillerStructs(x,y);
			case R_CustoRecycler : new b.r.CustoRecycler(x,y);
			case R_Bank : new b.r.Bank(x,y);
			case R_VipCall : new b.r.VipCall(x,y);
		}

		r.init();

		// Reinstall previous clients
		for(c in clients) {
			c.room = r;
			r.updateHud();
		}

		if( wasSelected )
			Game.ME.select(r);

		if( redrawSurroundings )
			renderSurroundings();

		return r;
	}

	public function detach() {
		for(e in elements)
			e.remove();
		elements = [];

		if( roofName!=null ) {
			roofName.dispose();
			roofName = null;
		}

		fxEmitters = [];

		for(c in bgCars)
			c.be = null;

		for(r in rooms)
			r.destroy();
		rooms = [];
	}

	public function attach() {
		detach();

		for(sr in shotel.rooms)
			attachRoom(sr, false);

		renderSurroundings();
	}

	public function renderSurroundings() {
		for(e in elements)
			e.remove();
		elements = [];
		fxEmitters = [];
		if( roofName!=null ) {
			roofName.dispose();
			roofName = null;
		}

		if( greenMode ) {
			mainBg.tile = Assets.tiles.getTile("white");
			mainBg.color = h3d.Vector.fromColor(alpha(0x00FF00),1);
			mainBgHei = mainBg.tile.height;
			updateMainBg();
			light.visible = false;
			lightGlow.visible = false;
		}
		else {
			mainBg.tile = Assets.getDirectTexture("paris");
			mainBgHei = 1152;
			mainBg.color = null;
		}

		for(c in bgCars)
			c.be = null;

		// Get bounds
		var xMin = 0;
		var xMax = 0;
		var yMin = 0;
		var yMax = 0;
		for(sr in shotel.rooms) {
			xMin = MLib.min(xMin, sr.cx);
			xMax = MLib.max(xMax, sr.cx+sr.wid-1);
			yMin = MLib.min(yMin, sr.cy);
			yMax = MLib.max(yMax, sr.cy);
		}
		xMin-=4;
		xMax+=4;
		yMin-=2;
		yMax+=3;
		left = xMin*Const.ROOM_WID;
		right = (xMax+1) * Const.ROOM_WID;
		bottom = (-yMin+1)*Const.ROOM_HEI;
		top = -(yMax+1)*Const.ROOM_HEI;

		var rseed = new mt.Rand(0);
		rseed.initSeed(shotel.seed);

		if( !greenMode ) {
			// Far bg
			var cx = xMax;
			while( cx>=xMin ) {
				cx--;
				if( cx%3==0 )
					continue;
				var e = addBuildingElement("bgBackBuilding", 0.5,1, rseed.random);
				e.x = (cx+rseed.range(0.3, 0.6))*Const.ROOM_WID;
				e.setScale(bgScale);
				e.scaleY *= rseed.range(0.8, 1.3);
			}


			// Trees
			var n = (xMax-xMin+1)*3;
			for(i in 0...n) {
				var x = left + (right-left)*(i/n) + rseed.irange(0,60,true);
				var e = addBackElement("bgTree", rseed.random);
				e.x = x;
				e.scaleX *= rseed.range(0.7, 1.5);
				e.scaleY *= rseed.range(0.7, 1.5);
			}
		}

		// Compute max roof height for each CX
		var roofYs = new Map();
		for(cx in xMin...xMax+1) {
			var cy = yMax;
			while( cy>0 && !hasRoom(cx,cy) )
				cy--;
			roofYs[cx] = cy;
		}


		if( !greenMode ) {
			// Bg cars
			rseed.initSeed(shotel.seed);
			for(c in bgCars) {
				c.be = addBackElement("car", rseed.random);
				c.be.x = 200;
				c.be.y = rseed.irange(10,20);
				c.be.setScale(bgScale*rseed.range(0.75, 1));
			}

			// Fog
			var e = addBuildingElement("fxGradient", 0,1, rseed.random);
			e.x = left;
			e.width = bgScale * (right-left);
			e.height = bgScale * 300;
			e.alpha = 0.9;


			// Chunks
			for(cx in xMin...xMax+1) {
				var t = CT_Empty;
				if( cx==xMin || cx==xMax )
					t = CT_Building1;
				//if( cx==xMin )
					//t = CT_Building2;

				renderChunk(cx, t);
			}
		}

		// Building details
		var lobby = getRoom(R_Lobby);
		for( cy in yMin...yMax+1 ) {
			var cx = xMax+1;
			while( cx>xMin ) {
				cx--;
				if( hasRoomWithWalls(cx,cy) )
					continue;

				var flags = 0 |
					(hasRoomWithWalls(cx+1,cy)?2:0) |
					(hasRoomWithWalls(cx-1,cy)?8:0) |
					(hasRoomWithWalls(cx,cy-1)?4:0) |
					(hasRoomWithWalls(cx,cy+1)?1:0);

				if( flags==0 )
					continue;

				rseed.initSeed(shotel.seed + cx+cy*1000);
				var pt = gridToPixels(cx,cy);

				var left = pt.x;
				var right = pt.x + Const.ROOM_WID;
				var top = pt.y - Const.ROOM_HEI;
				var bottom = pt.y;
				var centerX = (left+right)*0.5;
				var centerY = (top+bottom)*0.5;

				if( cy<0 ) {
					// Underground
					for(i in 0...rseed.irange(2,4)) {
						var e = Assets.tiles.addBatchElementRandom(Game.ME.tilesSb, "rock", 0.5,0.5, rseed.random);
						elements.push(e);
						e.x = pt.x + Const.ROOM_WID*rseed.range(0.2,0.8);
						e.y = pt.y - Const.ROOM_HEI*rseed.range(0.2,0.8);
						e.rotation = 0.5 + rseed.range(0,0.4,true);
						e.setScale( rseed.range(1,2) );
						//e.alpha = rseed.range(0.3, 0.6);
					}

					if( flags&8!=0 ) {
						var e = Assets.tiles.addBatchElementRandom(Game.ME.tilesSb, "rockSide", 0,0.5, rseed.random);
						elements.push(e);
						e.x = left;
						e.y = centerY;
						e.setScale( (Const.ROOM_HEI+20) / e.height );
					}
					if( flags&2!=0 ) {
						var e = Assets.tiles.addBatchElementRandom(Game.ME.tilesSb, "rockSide", 0,0.5, rseed.random);
						elements.push(e);
						e.x = right;
						e.y = centerY;
						e.setScale( (Const.ROOM_HEI+20) / e.height );
						e.rotation = MLib.PI;
					}
					if( flags&1!=0 ) {
						var e = Assets.tiles.addBatchElementRandom(Game.ME.tilesSb, "rockSide", 0,0.5, rseed.random);
						elements.push(e);
						e.x = centerX;
						e.y = top;
						e.setScale( (Const.ROOM_WID+40) / e.height );
						e.rotation = MLib.PIHALF;
					}
					if( flags&4!=0 ) {
						var e = Assets.tiles.addBatchElementRandom(Game.ME.tilesSb, "rockSide", 0,0.5, rseed.random);
						elements.push(e);
						e.x = centerX;
						e.y = bottom;
						e.setScale( (Const.ROOM_WID+40) / e.height );
						e.rotation = -MLib.PIHALF;
					}
					continue;
				}


				// Left
				if( flags&2!=0 ) {
					var e = addBuildingElement("parisTest", 1,1, rseed.random);
					e.changePriority(-1);
					e.x = right;
					e.y = bottom;
					e.setScale(bgScale);
				}

				// Right
				if( flags&8!=0 && (cy>0 || cx<lobby.rx) ) {
					var e = addBuildingElement("parisWall", 1,1, rseed.random);
					e.changePriority(-3);
					e.x = left;
					e.y = bottom;
					e.setScale(bgScale);
					e.scaleX *= -1;
				}

				// Bottom
				if( flags&1!=0 ) {
					var e = addBuildingElement("parisCeiling", 0,0, rseed.random);
					e.changePriority(-3);
					e.x = left-197-50; // 197
					e.y = top;
					e.setScale(bgScale);

					var e = addBuildingElement("parisPipe", 0.5,0, rseed.random);
					e.changePriority(-3);
					e.x = rseed.irange(left+100, right-200);
					e.y = top+30;
					e.setScale(bgScale);
					e.scaleX = e.scaleY = rseed.range(0.6, 1.2);
				}

				// Roof
				if( flags&4!=0 && cy>0 ) {
					if( cy>=roofYs[cx] && !shotel.hasRoom(cx,cy) ) {
						var e = addBuildingElement("parisRoof", 0,1, rseed.random);
						e.changePriority(-3);
						e.x = left-197;
						e.y = bottom;
						e.setScale(bgScale);
						e.scaleY*=0.65;

						var e = addBuildingElement("parisChimney", 0.5,1, rseed.random);
						e.changePriority(-3);
						e.x = rseed.irange(left+100, right-200);
						e.y = bottom-rseed.irange(100,120);
						e.y = bottom-120;
						e.setScale(bgScale * rseed.range(0.7, 1.5));
					}
					else {
						var e = addBuildingElement("parisBalcony", 0,1, rseed.random);
						e.changePriority(-3);
						e.x = left-270; //178
						e.y = bottom;
						e.setScale(bgScale);
					}
				}
			}
		}

		// Hotel name & Roof sign
		var base = getNameBase();
		if( base!=null ) {
			var l = shotel.level;
			//var l = 32;
			var y = base.globalTop - 95;
			// Struct
			//var e = Assets.bg.addBatchElement(bgSb, "roofSign",0, 0.5, 1);
			var e = addBuildingElement("roofSign", 0.5,1, rseed.random);
			e.x = base.globalCenterX;
			e.y = y;
			// Name
			var col = 0x0;
			var dark = 0x0;
			if( l<=5 ) { // bronze
				col = 0xf89450;
				dark = 0x8c3c08;
			}
			else if( l<=10 ) { // silver
				col = 0xB3DCE8;
				dark = 0x5C4196;
			}
			else if( l<=15 ) { // gold
				col = 0xFFBF00;
				dark = 0x821C42;
			}
			else if( l<=20 ) { // diamond
				col = 0x80EAD2;
				dark = 0x257D85;
			}
			else { // black
				col = 0xF4C2FC;
				dark = 0x642CC0;
			}

			var row1 = addBuildingElement("squareBlue", 0.5,0.5, rseed.random);
			var row2 = addBuildingElement("squareBlue", 0.5,0.5, rseed.random);

			var nameScale = shotel.name.length<10 ? 1.6 : 1.3;
			roofName = Assets.createBatchText(Game.ME.textSbRoof, Assets.fontRoof, Std.int(72*nameScale), shotel.name);
			roofName.textColor = col;
			roofName.x = base.globalCenterX - roofName.textWidth*roofName.scaleX*0.5;
			roofName.y = y-200;
			roofName.dropShadow = { dx:-3, dy:0, alpha:1, color:dark}

			var th = roofName.textHeight*roofName.scaleY;
			row1.setPos(base.globalCenterX, roofName.y + th*0.4);
			row1.width = roofName.textWidth*roofName.scaleX*0.9;
			row2.setPos(base.globalCenterX, roofName.y + th*0.7);
			row2.width = roofName.textWidth*roofName.scaleX*0.9;

			// Stars & glow
			if( l>0 ) {
				var star = Const.getStarFromLevel(l);

				var x = base.globalCenterX - (25 + MLib.min(5,l)*80)*0.5;
				var y = roofName.y + 70;

				// Bg
				if( star.frame>0 )
					for(i in 0...5) {
						var s = Assets.tiles.addBatchElement(Game.ME.tilesSb, "star",star.frame-1, 0.5,0.5);
						elements.push(s);
						s.x = x + 50 + i*80;
						s.y = y + 50;
						s.setScale(0.85);
					}

				// Stars
				for( i in 0...star.n ) {
					var s = Assets.tiles.addBatchElement(Game.ME.tilesSb, "star",star.frame, 0.5,0.5);
					elements.push(s);
					s.x = x + 50 + i*80;
					s.y = y + 50;
					s.setScale(0.85);
				}

				// Name glow
				if( l>0 ) {
					var e = Assets.tiles.addBatchElement(Game.ME.addSb, "nameGlow",star.frame, 0.5, 0.5);
					elements.push(e);
					e.alpha = 0.45;
					e.x = roofName.x + roofName.textWidth*roofName.scaleX*0.5;
					e.y = roofName.y + roofName.textHeight*roofName.scaleY*0.5;
					e.width = roofName.textWidth*roofName.scaleX*0.8 * nameScale;
					e.height = roofName.textHeight*roofName.scaleY*1.1 * nameScale;
				}
			}
		}


		// Ground dirt
		var e = addBuildingElement("squareBlue", 0,0, rseed.random);
		e.x = left;
		e.width = bgScale * (right-left);
		e.height = bgScale * bottom;

		// Ground road
		var e = addBuildingElement("bgSidewalk", 0,0, rseed.random);
		e.x = left;
		e.width = bgScale * (right-left);
	}


	function renderChunk(cx:Int, t:HotelChunk) {
		var rseed = new mt.Rand(cx*1000);
		var xMin = cx*Const.ROOM_WID;
		var xMax = (cx+1)*Const.ROOM_WID - 1;
		var wid = Const.ROOM_WID;

		switch( t ) {
			case CT_Empty :

			case CT_Building1 :
				var e = addBackElement("bgBuilding", rseed.random);
				e.x = xMin + wid * rseed.range(0.4, 0.6);
				e.setScale( bgScale * rseed.range(1.4, 1.6) );

			case CT_Building2 :
				var e = addBackElement("bgBuilding", rseed.random);
				e.x = xMin + wid * rseed.range(0.4, 0.6);
				e.y = 100;
				e.setScale( bgScale * 1.5 );
		}


		if( !hasRoomWithWalls(cx,0) ) {
			// Pilars
			if( cx%2==0 ) {
				var n = rseed.irange(3, 5);
				for(i in 0...n) {
					var e = addBackElement("bgPilars", rseed.random);
					e.x = xMin + (i/n)*wid;
					e.scaleY *= rseed.range(0.9, 1);
				}
			}

			// Street lights
			if( !hasRoom(cx,1) && !greenMode ) {
				var el = addBackElement("bgStreetLight", rseed.random);
				el.x = xMin + wid * rseed.range(0.3, 0.7);
				el.y = rseed.irange(0, 15);
				el.setScale( bgScale * rseed.range(0.9, 1) );
				fxEmitters.push( Game.ME.fx.streetLight.bind(el.x, el.y-el.height*0.8) );

				var ef = Assets.tiles.addBatchElement(Game.ME.addSb, "fxStreetLight", 0, 0.5, 0.5);
				elements.push(ef);
				ef.x = el.x;
				ef.y = el.y-el.height*0.8;
				ef.setScale( bgScale * rseed.range(1.5, 2) );
				ef.alpha = rseed.range(0.4, 0.6);
			}
		}
	}

	function addBackElement(k:String, rnd:Int->Int) {
		var e = Assets.bg.addBatchElementRandom(Game.ME.bgSb, k, rnd);
		elements.push(e);
		e.tile.setCenterRatio(0.5, 1);
		e.setScale(bgScale);
		e.visible = !greenMode;
		return e;
	}

	function addBuildingElement(k:String, xr:Float, yr:Float, rnd:Int->Int) {
		var e = Assets.bg.addBatchElementRandom(Game.ME.bgSb, k, rnd);
		elements.push(e);
		e.tile.setCenterRatio(xr,yr);
		e.setScale(bgScale);
		return e;
	}


	#if trailer
	public function toggleGreen() {
		greenMode = !greenMode;
		renderSurroundings();
	}
	#end


	function updateMainBg() {
		var g = Game.ME;
		var vp = g.viewport;

		var s = MLib.fmax(
			( ( w()+bgPadding*2 ) / g.totalScale ) / mainBg.tile.width,
			( ( h()+bgPadding*2 ) / g.totalScale ) / mainBgHei
		);
		mainBg.setScale(s);

		var rx = ( (vp.x-left) / (right-left) - 0.5 ) / 0.5; // [-1,1]
		var ry = ( (vp.y-top) / (bottom-top) - 0.5 ) / 0.5; // [-1,1]
		mainBg.x = ( (w()-rx*bgPadding*2)/g.totalScale )*0.5 - mainBg.tile.width*s*0.5;
		mainBg.y = ( (h()-ry*bgPadding*2)/g.totalScale )*0.5 - mainBgHei*s*0.5;

		// Eiffel light
		var f = 0.03;
		var s = 0.6;
		var x = 1364;
		var y = 267;
		light.x = x + Math.cos(1.57 + ftime*f)*12;
		light.y = y - Math.cos(ftime*f)*1;
		light.scaleX = s * (0.05 + 0.95*Math.cos(ftime*f));
		light.scaleY = s;
		light.alpha = MLib.fclamp( Math.cos(ftime*f), 0, 1);

		lightGlow.x = x + Math.cos(1.57 + ftime*f)*8;
		lightGlow.y = y;
		var gf = Math.cos(ftime*f);
		lightGlow.scaleX = 3.5 + MLib.fabs(gf)*0.8;
		lightGlow.scaleY = lightGlow.scaleX * 0.6;
		lightGlow.alpha = 0.1 + (gf>0 ? gf : -gf*0.25)*0.2;
	}



	override function update() {
		super.update();

		#if !trailer
		for( cb in fxEmitters )
			cb();
		#end

		// Cars AI
		var i = 0;
		var wid = right-left;
		for(c in bgCars) {
			c.x += c.spd;
			if( c.spd>0 && c.x>=right+200 )
				c.x -= wid+400;

			if( c.spd<0 && c.x<=left-200 )
				c.x += wid+400;

			if( c.be!=null ) {
				c.be.scaleX = MLib.fabs(c.be.scaleX) * (c.spd>0 ? 1 : -1);
				c.be.x = c.x + Math.cos((c.seed+ftime)*0.03)*50;
				c.be.y = 10 - rnd(0,2);
			}
			i++;
		}

		if( Main.ME.avgFps>=23 && !cd.hasSet("weatherPart", 4) ) {
			if( shotel.hasEvent(Data.EventKind.Autumn) )
				Game.ME.fx.autumnLeaves();
			else if( shotel.hasEvent(Data.EventKind.ChristmasPeriod) )
				Game.ME.fx.snow();
		}

		updateMainBg();
	}
}
