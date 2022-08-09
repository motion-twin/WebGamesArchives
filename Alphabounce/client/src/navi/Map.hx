package navi;
import mt.bumdum.Lib;
import mt.bumdum.Phys;
import Game;


typedef Zone = {
	id:Int,
	list:Array<Array<Int>>,
	prc:Float
}
typedef Bmp = {>flash.MovieClip,bmp:flash.display.BitmapData}
typedef Box = {>flash.MovieClip, but:flash.MovieClip, fieldText:flash.TextField, fieldBut:flash.TextField, fieldTitle:flash.TextField };
typedef Star = {>flash.MovieClip,c:Float,dx:Float,dy:Float,fonce:Float};

typedef Icon = {>flash.MovieClip, flBlink:Bool }
typedef MenuButton = {>flash.MovieClip, id:Int }
typedef Field = {>flash.MovieClip, field:flash.TextField, field2:flash.TextField, flFade:Bool }


enum Step {
	Move;
	Connexion;
	Zoom(x:Int,y:Int,sens:Int);
	Hole(step:Int);
	Land;
	Play;
	Error;

}

class Map{//}


	public static var ZONE_MARGIN = 10;

	public static var XMAX = 20;
	public static var YMAX = 20;
	public static var BW = 20;
	public static var BH = 18;
	static var WW = 0;
	static var HH = 0;
	public static var SX = 0;
	public static var SY = 0;

	public static var DP_GAME = 0;
	public static var DP_MAP = 1;
	public static var DP_LAYER = 2;
	public static var DP_WINDOW = 3;
	public static var DP_COORD = 4;
	public static var DP_INTER = 5;

	public static var DP_BG = 	0;
	public static var DP_FOG = 	1;
	public static var DP_MOVE = 	2;
	public static var DP_ICONS = 	3;

	public var flActive:Bool;
	public var flView:Bool;
	public var flFuel:Bool;

	var playMode:Int;
	var hx:Int;
	var hy:Int;
	var mx:Int;
	var my:Int;
	var zoomCoef:Float;
	var zoomSpeed:Float;
	var iconBlink:Float;
	var menuTimer:Float;
	var timeOut:Float;

	var step:Step;
	public var game:Module;

	var zones:Array<Zone>;
	var fog:Array<Array<Int>>;
	var exp:Array<Array<Bool>>;
	var reach:Array<Array<Bool>>;
	var icons:Array<Icon>;
	var stars:Array<Star>;
	public var spaceColors:Array<Array<Int>>;
	public var zoneTable:Array<Array<Int>>;
	public var seedTable:Array<Array<Random>>;
	public var menus:Array<MenuButton>;
	public var menu:navi.Menu;

	var heroMove : { icon:Icon, c:Float, sx:Int, sy:Int, ex:Int, ey:Int};

	var bmpBg:flash.display.BitmapData;
	var bmpFog:flash.display.BitmapData;
	var layer:{>flash.MovieClip, bmp:flash.display.BitmapData, map:flash.display.BitmapData, mdl:flash.display.BitmapData, dm:mt.DepthManager, mask:flash.MovieClip, pad:flash.MovieClip };

	var map:flash.MovieClip;
	var miniPad:{>flash.MovieClip,vy:Float,vr:Float};
	var mcGame:flash.MovieClip;
	var mcFarWarning:McText;
	var mcScreenshot:Bmp;
	public var box:Box;
	var mcCoord:Field;

	public var mcMoveZone:{>flash.MovieClip,dec:Float};
	//var mcBar:{>flash.MovieClip,field:flash.TextField};

	var root:flash.MovieClip;
	var bg:flash.MovieClip;
	public var dm:mt.DepthManager;
	public var mdm:mt.DepthManager;
	public static var me:Map;

	public var onReceiveLevels:Array<String>->Void;
	var dkl:Dynamic;

	public function new(mc){
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);


		WW = XMAX*BW;
		HH = YMAX*BH;
		hx = Std.int(XMAX*0.5);
		hy = Std.int(YMAX*0.5);

		flView = true;


		// SOUND
		Sound.init();


		//initInter();

		if( Cs.pi.flAdmin || Api.FL_DEBUG)initDebugListener();

	}
	public function init(){


		flFuel = Cs.pi.chs+Cs.pi.chl > 0;

		SX = Cs.pi.x - hx;
		SY = Cs.pi.y - hy;
		//dst = Math.sqrt(Cs.pi.x*Cs.pi.x + Cs.pi.y*Cs.pi.y );

		// SEED TABLE
		seedTable = [];
		for( x in 0...XMAX+ZONE_MARGIN*2 ){
			seedTable[x] = [];
			for( y in 0...YMAX+ZONE_MARGIN*2 ){
				var px = x+SX-ZONE_MARGIN;
				var py = y+SY-ZONE_MARGIN;
				var n = Std.int( px*(1000+py) + py ) ;
				seedTable[x][y] = new Random(n);
			}
		}


		// STUFF
		initZones();
		initMap();


		//step = Move;

		if( layer == null ){
			zoomCoef = 1;
			step = Zoom(hx,hy,-1);

		}else{

			step = Hole(0);
		}

		//
		//mcBar.field.text = "";

		//launchMenu({id:6});

	}

	// UPDATE
	dynamic public function update(){

				//

		//
		Sound.update();

		switch(step){
			case Move:		updateMove();
			case Connexion:		updateConnexion();
			case Zoom(x,y,sens): 	updateZoom(x,y,sens);
			case Hole(sens):	updateHole(sens);
			case Land:		updateLand();
			default:
		}

		updateIcons();
		updateMenu();

		if(game!=null)game.update();

		if(timeOut!=null){
			timeOut -= mt.Timer.tmod;
			if(timeOut<0){
				timeOut= null;
				displayError(Text.get.WARNING_CNX);
			}
		}


		// DEBUG
		if(Api.FL_DEBUG)updateDebug();

	}




	// MOVE
	function initMove(){

		menus = [];

		initIcons();
		//initMoveZone();
		initMenu();


		flActive = true;

		switchView(true);



		//
		// STARS

		//updateStars(0);

	}
	function updateMove(){
		if(Cs.PREF_BOOLS[1]){
			mcMoveZone.dec = (mcMoveZone.dec+23*mt.Timer.tmod)%628;
			mcMoveZone._alpha = 30 + Math.cos( mcMoveZone.dec*0.01 )*45;
		}
		updateCoord();
		if( heroMove!=null )updateHero();
	}
	function updateCoord(){
		var p = getMouseSector();

		var tx = ((p.x+0.5)-SX)*BW;
		var ty = ((p.y+0.5)-SY)*BH;


		if(mcCoord==null){
			mcCoord = cast dm.attach("mcCoord",DP_COORD);
			mcCoord._x = tx;
			mcCoord._y = ty;
			mcCoord.cacheAsBitmap = true;

			//mcCoord._alpha = 50;
		}


		//
		mcCoord.filters = [];

		var flFarWarning = false;

		if( reach[p.x-SX][p.y-SY] ){
			if(mcCoord._currentframe==2)mcCoord.gotoAndStop(1);
			if( !Cs.pi.gotItem(MissionInfo.BALL_DRILL) && Math.max(Math.abs(p.x),Math.abs(p.y)) >=3  ){
				flFarWarning = true;
				if(mcFarWarning == null )mcFarWarning = cast dm.attach("mcFarZone",DP_INTER);
				mcFarWarning.gotoAndStop(2);
				mcFarWarning.field.text = Text.get.WARNING_CARDS;
			}

		}else{
			if(mcCoord._currentframe==1){
				mcCoord.gotoAndStop(2);
			}
			if( Math.abs(Cs.pi.x)+Math.abs(Cs.pi.y) <= 3  ){
				flFarWarning = true;
				if(mcFarWarning == null && Cs.pi.missions[0]!=0 )mcFarWarning = cast dm.attach("mcFarZone",DP_INTER);
				mcFarWarning.gotoAndStop(1);
				mcFarWarning.field.text = Text.get.WARNING_FAR;
			}

		}
		if(!flFarWarning && mcFarWarning!=null){
			mcFarWarning.removeMovieClip();
			mcFarWarning = null;
		}


		// TEXT
		mcCoord.field.text = "["+p.x+"]["+p.y+"]";
		mcCoord.field2.text = getSquareName(p.x-SX,p.y-SY);


		var c = 0.5;
		mcCoord._x += (tx-mcCoord._x)*c;
		mcCoord._y += (ty-mcCoord._y)*c;

		//
		/*
		var sens = 1;
		if( mcCoord.flFade )sens = -1;
		mcCoord._alpha = Num.mm(0,mcCoord._alpha+sens*20,100);
		*/
	}

	function getSquareName(x,y){
		var name = ZoneInfo.list[ zoneTable[x][y] ].name.toUpperCase();
		if( name == null ) name = "";

		return name;


	}

	// ZOOM
	function startZoom(x,y,flMinerai,?lvl:String){

		flActive = false;

		zoomCoef = 0;
		step = Zoom(x,y,1);


		var wx = x+SX;
		var wy = y+SY;

		// GAME
		/*
		game = null;
		mcGame = dm.empty( DP_GAME );
		switch(playMode){
			case 0:	game = new Game( mcGame, spaceColors[x][y] );
			case 1:	game = new lander.Game( mcGame, spaceColors[x][y] );

		}
		*/

		game.initLevel( wx, wy, zoneTable[x][y],flMinerai,lvl);

		// SCREEN
		mcScreenshot = cast mdm.empty(DP_ICONS);
		var bmp = new flash.display.BitmapData( Cs.mcw,Cs.mch,false,0);
		var m = new flash.geom.Matrix();
		m.scale(1.001,1.001);
		bmp.draw(mcGame,m);

		//
		mcScreenshot.attachBitmap(bmp,0);
		mcScreenshot._x = x*BW;
		mcScreenshot._y = y*BH;
		mcScreenshot._xscale = 100/20;
		mcScreenshot._yscale = 100/20;
		mcScreenshot._alpha = 0;
		mcScreenshot.bmp = bmp;


		// CLEAN
		//mcBar.removeMovieClip();
		initStars();


	}
	function updateZoom(x,y,sens){
		if(sens==1){
			zoomCoef = Num.mm( 0, (zoomCoef+0.00005*mt.Timer.tmod)*1.5, 1 );
		}else{
			zoomCoef = Num.mm( 0,  (zoomCoef-0.05*mt.Timer.tmod)*0.8, 1 );
		}
		map._xscale = 100*(1-zoomCoef)+zoomCoef*2000;
		map._yscale = 100*(1-zoomCoef)+zoomCoef*2000;
		mcScreenshot._alpha = zoomCoef*100;


		var tx = Cs.mcw*0.5 - (x+0.5)*BW*20;
		var ty = Cs.mch*0.5 - (y+0.5)*BH*20;

		map._x = tx*zoomCoef;
		map._y = ty*zoomCoef;

		if( zoomCoef == 1 ){
			initPlay();
		}else if( zoomCoef == 0 ){
			initMove();
		}



		var cc = 1-zoomCoef;
		var cx = Cs.mcw*0.5 + (x+0.5-10)*BW*cc;
		var cy = Cs.mch*0.5 + (y+0.5-10)*BH*cc;




		if(sens==1){
			updateStars(zoomCoef,cx,cy);
		}else{
			var dist = 50+Math.random()*20/zoomCoef;
			if( dist < 300 ){
				for( i in 0...8){
						if(zoomCoef == 0 )dist = 50;
						var a = Math.random()*6.28;
						var mc = dm.attach("mcZoomRay",DP_INTER);
						mc._x = cx + Math.cos(a)*dist;
						mc._y = cy + Math.sin(a)*dist;
						mc._rotation = a/0.0174;
						mc._xscale = 100+Math.random()*200;
						mc.blendMode = "add";
				}
			}
		}

	}

	function initStars(){
		stars = [];
		var ma = 20;
		for( i in 0...200 ){
			var mc:Star = cast dm.attach("partStar",DP_LAYER);
			mc.c = 0.2+Math.pow(Math.random(),2)*0.8;
			var a = i/200 * 6.28;
			var dist = (20+Math.random()*250);
			mc.dx = Math.cos(a)*dist;
			mc.dy = Math.sin(a)*dist;
			mc.fonce = 25+Math.pow(Math.random(),2)*250;
			//mc.blendMode = "add";
			//mc._xscale = mc._yscale = 300;
			stars.push(mc);
		}
	}
	function updateStars(zc:Float,cx,cy){
			var list = stars.copy();
			for( mc in list ){

				var c = mc.c+zc*mc.fonce ;

				mc._x = cx+ mc.dx*c;
				mc._y = cy + mc.dy*c;

				if( c > 0.9 ){
					mc._alpha = ((1-c)/0.1)*100;
				}else{
					mc._alpha = (1-zc)*100;
				}
				if(zc<0.0005)mc._alpha = (zc/0.0005)*100;

				if( c > 1 ){

					stars.remove(mc);
					mc.removeMovieClip();
				};
			}
	}

	// HOLE
	function initHole(){
		zoomCoef = 0;
		zoomSpeed = 0;


		// PREPARE LAYER
		layer = cast dm.empty(DP_LAYER);
		layer.bmp = bmpBg.clone();
		layer.map = new flash.display.BitmapData( Cs.mcw, Cs.mch, false, 0xFFFFFF );
		layer.mdl = bmpBg.clone();
		layer.onPress =function(){};

		var mc = dm.attach("mapBlackHole",0);
		layer.map.draw(mc,new flash.geom.Matrix());
		mc.removeMovieClip();
		layer.attachBitmap(layer.bmp,0);

		layer.dm = new mt.DepthManager(layer);
		layer.pad = layer.dm.attach("mcMiniPad",1);
		layer.pad._x = (hx+0.5)*BW;
		layer.pad._y = (hy+0.5)*BH;

		layer.mask = layer.dm.attach("holeMask",1);
		layer.mask._x = layer.pad._x;
		layer.mask._y = layer.pad._y;

		layer.pad.setMask(layer.mask);





		//SEND INFO
		initConnexion();
		Api.warp();
		cleanAll();




	}
	function updateHole(step){

		switch(step){
			case 0:
				zoomCoef = Num.mm( 0, zoomCoef+((1-zoomCoef)*0.1+0.01), 1 );
				if(zoomCoef==1)this.step = Hole(1);

				layer.pad._y =  Cs.mch*0.5+zoomCoef*70;
				layer.mask._y = Cs.mch*0.5+zoomCoef*40;

			case 1:
				zoomSpeed += -zoomCoef*0.25;
				zoomSpeed *= 0.9;
				zoomCoef += zoomSpeed;
				if( Math.abs(zoomSpeed)+Math.abs(zoomCoef) < 0.1 ){
					layer._alpha -= 10;
					if( layer._alpha <= 0 ){
						layer.bmp.dispose();
						layer.mdl.dispose();
						layer.map.dispose();
						layer.removeMovieClip();
						layer = null;
						this.step = Land;

					}
				}

				layer.pad._y -= 20;
				layer.pad._rotation += 20;

		}


		var fl = new flash.filters.DisplacementMapFilter();
		fl.mapBitmap = layer.map;
		fl.componentX = 0;
		fl.componentY = 1;
		fl.scaleX = zoomCoef*100;
		fl.scaleY = -zoomCoef*300;
		layer.bmp.applyFilter( layer.mdl, layer.mdl.rectangle, new flash.geom.Point(0,0), fl );




	}

	// LAND
	function updateLand(){

		if( miniPad == null ){
			miniPad = cast dm.attach("mcMiniPad",DP_INTER);
			miniPad._x = (hx+0.5)*BW;
			miniPad._y = -(20+Cs.mch*0.5);
			miniPad.vy = 15;
			miniPad.vr = 20;
			miniPad._rotation = 0;

		}

		miniPad.vy += 1;
		miniPad._y += miniPad.vy;
		miniPad._rotation += miniPad.vr;

		var gy = (hy+0.5)*BH;

		if( miniPad._y > gy ){
			miniPad.vy *= -0.5;
			miniPad._y = gy;
			miniPad.vr *= -0.45;
			//miniPad._rotation *= 0.5;
			miniPad._rotation = 0;
			if(miniPad.vy >-1){
				initMove();
				miniPad.removeMovieClip();
				miniPad = null;
			}

		}




	}

	// PLAY
	function initPlay(){

		cleanAll();

		step = Play;
		game.initPlay();

		// CLEAN


		//

	}
	function updatePlay(){
		game.update();
	}
	function cleanAll(){
		bmpBg.dispose();
		bmpFog.dispose();
		mcScreenshot.removeMovieClip();
		mcScreenshot.bmp.dispose();
		map.removeMovieClip();
		while(menus.length>0)menus.pop().removeMovieClip();
	}

	// ZONES
	function initZones(){
		var id = 0;
		zones = [];
		zoneTable = [];
		for( x in 0...XMAX )zoneTable[x] = [];

		for( zone in ZoneInfo.list ){
			if( isZoneIn(zone.pos) ){
				var zone:Zone = cast {
					id:id,
					list:ZoneInfo.getSquares(id)
				}
				zones.push(zone);
				for( p in zone.list ){
					var x = p[0]-SX;
					var y = p[1]-SY;
					zoneTable[x][y] = id;
				}
			};
			id++;
		}
	}

	// MENU
	function initMenu(){

		menuTimer = 0;

		// PREFERENCES
		newMenu(4);

		// EDITOR
		if( ( Cs.pi.gotItem(MissionInfo.EDITOR) && Cs.pi.pendingLevels>=0 && Cs.pi.pendingLevels<32 ) || Cs.pi.flEditor ){
			newMenu(2);
		}

		// LANDER
		if( Cs.pi.gotItem(MissionInfo.LANDER_REACTOR) && zoneTable[Cs.pi.x-SX][Cs.pi.y-SY]!=null   ) newMenu(6);

		// RETOUR
		if( Cs.pi.gotItem(MissionInfo.RETROFUSER) ) newMenu(8,initHole);

		if( Cs.pi.flAdmin ){

			// WORLD MAP
			newMenu(3);

			//
			//newMenu(8,initHole);

			// FORCE EDIT
			newMenu(6);

			// FORCE LANDER
			//newMenu(2);



		}
	}
	function updateMenu(){
		for( mc in menus ){
			var ty = Cs.mch-37;
			mc._y += (ty-mc._y)*0.5;
		}
		menu.updateMenu();
	}
	public function newMenu(?id:Int,?f:Void->Void,?seed:mt.OldRandom){

		var n = menus.length;
		var mc:MenuButton = cast dm.attach("mcMenu",DP_INTER);
		mc._x = 5+n*38;
		mc._y = Cs.mch;
		mc.id = id;
		mc.gotoAndStop(id+1);

		menus.push(mc);

		var me = this;

		mc.onRollOver = function(){
			Filt.glow(mc,2,4,0xFFFFFF);
			Filt.glow(mc,10,1,0xFFFFFF);
			mc.blendMode = "add";
			me.mcCoord._alpha = 0;
		};
		mc.onRollOut = function(){
			mc.filters  = [];
			mc.blendMode = "normal";
			me.mcCoord._alpha = 100;
		};
		mc.onDragOver = mc.onRollOver;
		mc.onDragOut = mc.onRollOver;


		if(id!=null)mc.onPress = callback(me.launchMenu,mc);
		if(f!=null)mc.onPress = f;


		switch(id){
			case 0:	navi.menu.Shop.initAlien(mc.smc,seed);
		}

 	}

	public function removeMenu(id){
		var i = 0;
		while( i < menus.length ){
			var mc = menus[i];
			mc._x = 5+i*38;
			mc._y = Cs.mch;
			if(mc.id==id){
				menus.splice(i--,1);
				mc.removeMovieClip();
			}
			i++;
		}
	}
	public function launchMenu(mc){
		switch(mc.id){
			case 0:	menu = new navi.menu.Shop(mc._x,mc._y);
			case 2:	menu = new navi.menu.Editor(mc._x,mc._y);
			case 3:	menu = new navi.menu.World(mc._x,mc._y);
			case 4:	menu = new navi.menu.Pref(mc._x,mc._y);
			case 5:	menu = new navi.menu.Asteroid(mc._x,mc._y);
			case 6:
				setTimeOut(200);
				Api.playLander(Cs.pi.x,Cs.pi.y);
				playMode = 1;
				initConnexion();
		}
	}

	public function switchView(vis){

		for(mc in menus){
			mc.onRollOut();
			mc._visible = vis;
		}

		if(!flActive)return;

		flView = vis;
		for(mc in icons )mc._visible = vis;
		if(vis){
			active();
		}else{
			unactive();
		}
	}

	public function active(){
		step = Move;
		initMoveZone();
		bg.onPress = 		clickMap;
		bg.onRollOver = 	rOverMap;
		bg.onRollOut =		rOutMap;
		bg.onRollOut =		rOutMap;



	}
	public function unactive(){
		step = null;
		mcCoord.removeMovieClip();
		mcCoord = null;
		mcMoveZone.removeMovieClip();
		bg.onPress = null;
		bg.onRollOver = null;
		bg.onRollOut = null;
		mcFarWarning.removeMovieClip();
		mcFarWarning = null;

		//
		//while(menus.length>0)menus.pop().removeMovieClip();

	}

	// MAP
	function initMap(){

		map = dm.empty(DP_MAP);
		mdm = new mt.DepthManager(map);

		var col = Cs.COL_SPACE;
		if( Cs.pi.gotItem(MissionInfo.MODE_DIF) )col = 0x500048;

		bmpBg = new flash.display.BitmapData(WW,HH,false,col);
		bmpFog = new flash.display.BitmapData(WW,HH,true,0);
		bg = mdm.empty(DP_BG);
		bg.attachBitmap(bmpBg,0);
		bg.useHandCursor = false;
		var mc = mdm.empty(DP_FOG);
		mc.attachBitmap(bmpFog,0);
		mc._alpha = 50;
		drawBg();
		drawFog();

	}
	function drawBg(){


		var ma = ZONE_MARGIN;

		var stars = [];
		var t = flash.Lib.getTimer();
		var brushLight = dm.attach("mcLuz",0);


		// CLOUDS
		for( px in 0...XMAX+2*ma ){

			for( py in 0...YMAX+2*ma ){

				var x = px-ma;
				var y = py-ma;

				x -= 5;

				// CLOUD
				var sc = 5;
				var n = (x+SX)*1000 + (y+SY)*(x+SX) ;
				//var seed = new mt.Random(n,7);
				//var seed = new Random(n);
				var seed = seedTable[x+ZONE_MARGIN][y+ZONE_MARGIN];
				if( seed.random(70) == 0 ){
					var m = new flash.geom.Matrix();
					m.scale((0.5+seed.rand())*sc,(0.5+seed.rand())*sc);
					m.translate(x*BW,y*BH);
					var bi = 5;
					var ri = 50;
					var o = {
						r:bi+seed.random(ri),
						g:bi+seed.random(ri),
						b:bi+seed.random(ri)
					}
					Col.setPercentColor( brushLight.smc,100,Col.objToCol(o));
					bmpBg.draw(brushLight,m,null,"add");
				}


				// STARS
				if( x>=0 && x<XMAX && y>=0 && y<YMAX ){
					var max = seed.random(3);
					for( i in 0...max ){
						stars.push( [ (x+seed.rand())*BW, (y+seed.rand())*BH, 0.2+seed.rand()*0.3 ] );
					}

				}

			}
		}


		//GET COLORS
		spaceColors = [];
		for( x in 0...XMAX ){
			spaceColors[x] = [];
			for( y in 0...YMAX ){
				spaceColors[x][y] = bmpBg.getPixel(Std.int(x+0.5)*BW,Std.int(y+0.5)*BH);
			}
		}

		// STARS
		var link = "mcStar";
		if(Cs.pi.gotItem(MissionInfo.MODE_DIF))link="mcDifStar";
		var brushStar =  dm.attach(link,0);
		for( p in stars ){
			var m = new flash.geom.Matrix();
			var sc  = p[2];
			m.scale(sc,sc);
			m.translate(p[0],p[1]);
			bmpBg.draw(brushStar,m,null,"add");
		}
		brushStar.removeMovieClip();
		brushLight.removeMovieClip();



		// ASTEROIDES
		var brush = dm.attach("mcMapAsteroide",0);
		var strength = 10;
		var noise = 0.3;
		var freq = 0.3;
		for( x in 0...XMAX ){
			for( y in 0...YMAX ){
				var seed = seedTable[x+ZONE_MARGIN][y+ZONE_MARGIN];
				var dx = SX+x - ZoneInfo.ASTEROBELT_CX;
				var dy = SY+y - ZoneInfo.ASTEROBELT_CY;
				var a = Math.atan2(dy,dx);
				var dist = Math.abs( Math.sqrt(dx*dx+dy*dy) - ZoneInfo.ASTEROBELT_RAY );
				if( dist<strength ){
					var coef = dist/strength;
					if( seed.rand() > (1-freq)+coef*freq ){
						var m = new flash.geom.Matrix();
						var px = x+(seed.rand()*2-1)*noise;
						var py = y+(seed.rand()*2-1)*noise;
						m.translate( px*BW, py*BH );
						brush.smc._rotation = seed.rand()*360;
						brush.smc._xscale = brush.smc._yscale = 30+50*(1-coef)+seed.rand()*40;
						brush.smc.gotoAndStop( seed.random(brush.smc._totalframes)+1 );
						Col.setPercentColor( brush.smc, 10+seed.random(50),spaceColors[x][y] );

						bmpBg.draw(brush,m);
						zoneTable[x][y] = ZoneInfo.ASTEROBELT;
					}

				}
			}
		}
		brush.removeMovieClip();

		// ZONES //
		var brush =  Manager.mcPlanet;
		for( zone in zones ){
			var zi = ZoneInfo.list[zone.id];
			brush.smc.gotoAndStop(zone.id+1);
			var scx = zi.pos[2]*2*BW *0.01;
			var scy = zi.pos[2]*2*BH *0.01;
			var m = new flash.geom.Matrix();
			m.scale(scx,scy);
			m.translate( (zi.pos[0]-SX)*BW, (zi.pos[1]-SY)*BH );
			bmpBg.draw(brush,m);
		}

		// LINES GRID //
		var bmp = new flash.display.BitmapData(WW,HH,true,0);
		var col = 0x30FFFFFF;
		for( x in 0...XMAX ) bmp.fillRect( new flash.geom.Rectangle( x*BW, 0, 1, HH ), col );
		for( y in 0...YMAX ) bmp.fillRect( new flash.geom.Rectangle( 0, y*BH, WW, 1 ), col );
		bmpBg.copyPixels(bmp, bmp.rectangle, new flash.geom.Point(0,0));

	}
	public function drawFog(){

		bmpFog.fillRect(new flash.geom.Rectangle(0,0,WW,HH), 0x00000000);

		// GEN FOG
		var i = 0;
		fog = [];
		for( x in 0...XMAX ){
			fog[x] = [];
			for( y in 0...YMAX ){
				var n = Cs.pi.fog[i];
				if( n == null ) n = -1;
				n++;
				fog[x][y] = n;



				/*
				switch(Cs.pi.fog[i]){
					case 0:		fog[x][y] = 0;
					case 1:		fog[x][y] = 2;
					case null:	fog[x][y] = null;
				}


				fog[x][y] = if (Cs.pi.fog[i] == 1) 2 else 0;
				*/

				i++;
			}

		}

		// EXPAND FOG
		exp = [];
		for( x in 0...XMAX )exp[x] = [];
		var ray = Cs.pi.radar;
		for( x in 0...XMAX ){

			for( y in 0...YMAX ){
				if( fog[x][y] == 2 ){
					var max = ray*2+1;
					for( dx in 0...max ){
						for( dy in 0...max ){
							var nx = x+dx-ray;
							var ny = y+dy-ray;
							exp[nx][ny] = true;
						}
					}
				}
			}
		}

		// DRAW
		/*
		var mc = dm.attach("mcSkull",0);
		for( x in 0...XMAX ){
			for( y in 0...YMAX ){
				var n = fog[x][y];
				var a = [ 0xFF000000, 0xFF330000 ];
				if( exp[x][y] ) a = [ 0x88000000, 0x88330000 ];
				if( n<2 )bmpFog.fillRect( new flash.geom.Rectangle( x*BW, y*BH, BW, BH ), a[n] );
				if( n == 1 ){
					var m = new flash.geom.Matrix();
					m.translate(x*BW,y*BH);
					bmpFog.draw(mc,m);
				}
			}
		}
		mc.removeMovieClip();
		*/

		for( x in 0...XMAX ){
			for( y in 0...YMAX ){
				var n = fog[x][y];
				var a = [ 0xFF000000, 0xFF330000 ];
				if( n<2 )bmpFog.fillRect( new flash.geom.Rectangle( x*BW, y*BH, BW, BH ), a[n] );
			}
		}
		//if( Cs.PREF_BOOLS[] )
		var fl = new flash.filters.GlowFilter();
		fl.blurX = 2;
		fl.blurY = 2;
		fl.strength = 8;
		fl.color = 0xAA00FF;
		bmpFog.applyFilter( bmpFog, bmpFog.rectangle, new flash.geom.Point(0,0), fl );


		var mc = dm.attach("mcSkull",0);
		for( x in 0...XMAX ){
			for( y in 0...YMAX ){
				var n = fog[x][y];
				var a = [ 0x88000000, 0x88330000 ];
				if( exp[x][y] )if( n<2 )bmpFog.fillRect( new flash.geom.Rectangle( x*BW, y*BH, BW, BH ), a[n] );
				if( n == 1 ){
					var m = new flash.geom.Matrix();
					m.translate(x*BW,y*BH);
					bmpFog.draw(mc,m);
				}
			}
		}
		mc.removeMovieClip();


		///*

		//*/
	}

	// INTER
	/*
	public function initInter(){
		//mcBar = cast dm.attach("mcMapBar",DP_INTER);
		//setCoord(Cs.pi.x,Cs.pi.y);
	}
	public function setCoord(x:Int,y:Int){
		//var name = ZoneInfo.list[ zoneTable[x-SX][y-SY] ].name.toUpperCase();
		//if( name == null ) name = "SECTEUR";
		//mcBar.field.text = name+" "+x+":"+y;
	}

	function displayZone(x,y){
		mx = x;
		my = y;
		setCoord(mx,my);
	}
	*/

	// ACTIONS
	function clickMap(){
		var p = getMouseSector();

		if( !flFuel ){
			initBoxFuel();
			return;
		}


		if( reach[p.x-SX][p.y-SY] || (Cs.pi.flAdmin && p.x-SX>0) ){
			callPlay(p.x,p.y);
		}
	}
	public function callPlay(x,y){

		setTimeOut(200);
		Api.play(x,y);
		playMode = 0;
		initConnexion();
	}

	function rOverMap(){

	}
	function rOutMap(){

	}

	// HERO
	function updateHero(){
		mcMoveZone._visible = false;
		heroMove.c = Math.min(heroMove.c+0.04*mt.Timer.tmod,1);
		var mc = heroMove.icon;
		var x = heroMove.sx*(1-heroMove.c) + heroMove.ex*heroMove.c;
		var y = heroMove.sy*(1-heroMove.c) + heroMove.ey*heroMove.c;
		mc._x = x*BW;
		mc._y = y*BH;

		if(heroMove.c==1){
			mcMoveZone._visible = true;
			heroMove = null;
		}

	}

	// ICONS
	function initIcons(){
		icons = [];
		iconBlink = 0;


		// TROU NOIRS
		for( a in ZoneInfo.holes ){
			for( p in a ){
				var rx = p[0]-SX;
				var ry = p[1]-SY;
				if( rx>=0 && rx<XMAX && ry>=0 && ry<YMAX ){
					if( Cs.pi.flAdmin )displayIcon(2,rx,ry,false);
					if( rx==hx && ry==hy ){
						newMenu(1,initHole);
					}
				}
			}
		}


		// BOUTIQUE
		for( x in 0...XMAX ){
			for( y in 0...YMAX ){
				var wx = SX+x;
				var wy = SY+y;
				if( Cs.pi.gotItem(MissionInfo.MAP_SHOP) || (wx==-2 && wy==3) ){
					var dst = Math.sqrt(wx*wx+wy*wy);
					var seed = seedTable[x+ZONE_MARGIN][y+ZONE_MARGIN];
					if( seed.random( Std.int(40+Math.pow(dst,1.4)) ) == 0 ){
						displayIcon(1,x,y,false);
						if( x==hx && y==hy ){
							newMenu(0);
						}
					}
				}
			}
		}

		// ITEMS
		var id = 0;
		for( o in MissionInfo.ITEMS ){
			if( o.x > SX && o.x < SX+XMAX && o.y > SY && o.y < SY+YMAX ){
				var o = MissionInfo.ITEMS[id];
				if(Cs.pi.items[id] == 1 || (o.fam==1 && Cs.pi.shopItems[ShopInfo.MISSILE_MAP]==1 && !Cs.pi.gotItem(id) ) ){
					displayIcon( id+10, o.x-SX, o.y-SY, true );
				}
			}
			id++;
		}

		// HERO
		var h = displayIcon( 0, hx, hy );
		if( Cs.pi.ox != null ){
			var dx = Cs.pi.ox-Cs.pi.x;
			var dy = Cs.pi.oy-Cs.pi.y;
			var sum = Math.abs(dx)+Math.abs(dy);
			if( sum > 0 && sum < 10 ){
				heroMove = {
					ex:hx,
					ey:hy,
					sx:hx + dx,
					sy:hy + dy,
					icon:h,
					c:0.0
				}
				updateHero();
			}
		}


		// START CLICK
		if( Cs.pi.missions[0] == 0 ){
			var mc:Icon = cast mdm.attach("mcStartClick",DP_ICONS);
			mc._x = 10.5*BW;
			mc._y = 10.5*BH;
			var field:flash.TextField = (cast mc).field;
			field.text = Text.get.START_CLIC_GREEN;
			icons.push(mc);
		}

		// MINE ZONE
		if( Cs.pi.square!=null ){
			var mc:Icon  = cast mdm.attach("mcMineZone",DP_ICONS);
			var x = Cs.pi.square[0]-SX;
			var y = Cs.pi.square[1]-SY;
			mc._x = x*BW;
			mc._y = y*BH;
			mc.smc._xscale = Cs.pi.square[2]*BW;
			mc.smc._yscale = Cs.pi.square[2]*BH;
			mc.flBlink = true;
			icons.push(mc);

			// ESCORP / FURI
			var frame = 1;
			if(Cs.pi.gotItem(MissionInfo.EVASION))frame = 2;
			mc.gotoAndStop(frame);
			mc.smc.gotoAndStop(frame);
			Filt.glow(mc,10,1,[0x00FF00,0xFF0000][frame-1]);

		}


	}
	function displayIcon(id,x,y,?flBlink){

		var mc:Icon = cast mdm.attach("mcMapIcon",DP_ICONS);
		mc._x = x*BW;
		mc._y = y*BH;
		mc.flBlink = flBlink;
		//mc.blendMode = "add";
		if(id>=10){
			mc.gotoAndStop(11);
			mc.smc.gotoAndStop((id-10)+1);
		}else{
			mc.gotoAndStop(id+1);
		}

		icons.push(mc);
		return mc;


	}
	function updateIcons(){
		if(!flView)return;
		iconBlink += mt.Timer.tmod;
		if( iconBlink > 25 ){
			iconBlink = 0;
			for( mc in icons ){
				if( mc.flBlink ){
					//mc._visible = !mc._visible;
					//if( !mc._visible && iconBlink == 0) iconBlink = 20;
					if( mc._alpha == 0 ){
						mc._alpha = 100;

					}else{
						mc._alpha = 0;
						iconBlink = 20;
					}

				}
			}
		}
	}
	function removeIcons(){
		while(icons.length>0)icons.pop().removeMovieClip();
	}

	// MOVES
	public function initMoveZone(){

		if(mcMoveZone != null)mcMoveZone.removeMovieClip();

		mcMoveZone = cast mdm.empty(DP_MOVE);
		mcMoveZone.useHandCursor = true;
		mcMoveZone._x = hx*BW;
		mcMoveZone._y = hx*BH;
		mcMoveZone._alpha = 15;
		mcMoveZone.blendMode = "overlay";
		mcMoveZone.blendMode = "add";
		mcMoveZone.dec = 0;
		Filt.glow(mcMoveZone,2,100,0xFFFFFF);
		mcMoveZone._alpha = 0;

		mcMoveZone.onPress = clickMap;


		reach = [];
		for( x in 0...XMAX )reach[x] = [];
		reach[hx][hy] = true;
		var zone = [[hx,hy]];
		var list = [[hx,hy]];

		var max = Cs.pi.engine;

		for( i in 0...max ){
			zone = extendZone( zone );
			for( p in zone )list.push(p);
		}

		if( Cs.pi.missions[0]!=0 ){
			list.shift();
			reach[hx][hy] = false;
		}


		var fr = 1;
		if(!flFuel)fr = 2;
		var dm = new mt.DepthManager(mcMoveZone);
		for( p in list ){
			var mc = dm.attach("mcMove",0);
			mc._x = (p[0]-hx)*BW;
			mc._y = (p[1]-hy)*BH;
			mc.gotoAndStop(fr);

		}

		/*
		count = 0;
		var done = [];
		for( x in 0...XMAX )done[x] = [];
		setMoveZone(hx,hy,7,new mt.DepthManager(mcMoveZone),done);
		*/


	}
	function extendZone(zone:Array<Array<Int>>){
		var list = [];
		for( p in zone ){
			if( fog[p[0]][p[1]]==2 || exp[p[0]][p[1]] ){

				for( d in Cs.DIR ){
					var nx = p[0]+d[0];
					var ny = p[1]+d[1];

					if( reach[nx][ny] == null ){
						reach[nx][ny] = true;
						list.push( [nx,ny] );
					}
				}
			}
		}
		return list;
	}

	// TOOLS
	function getGX(x:Float){
		return Std.int(x/BW);
	}
	function getGY(y:Float){
		return Std.int(y/BH);
	}
	function getMouseSector(){
		var x =  Std.int( Num.mm(0,getGX(map._xmouse),XMAX-1) + Cs.pi.x - Std.int(XMAX*0.5) );
		var y =  Std.int( Num.mm(0,getGY(map._ymouse),YMAX-1) + Cs.pi.y - Std.int(YMAX*0.5) );
		return {x:x,y:y};
	}

	function isZoneIn(pos:Array<Int>){
		if(pos[2]==0)return false;

		var xMin = SX;
		var yMin = SY;
		var xMax = SX+XMAX;
		var yMax = SY+YMAX;


		if(pos.length==3){
			xMin -= pos[2];
			yMin -= pos[2];
			xMax += pos[2];
			yMax += pos[2];

		}else{
			xMin -= pos[2];
			yMin -= pos[3];
		}

		var x = pos[0];
		var y = pos[1];

		return x >= xMin && x< xMax && y >= yMin && y< yMax;

	}

	// BOX
	function initBoxFuel(){
		box = cast dm.attach("boxFuel",DP_INTER);
		box.smc.onPress = function(){};
		//box.field
		box.fieldTitle.text = Text.get.FUEL_TITLE;
		box.fieldText.htmlText = Text.get.FUEL_TEXT;
		box.fieldBut.text = Text.get.FUEL_BANK;

		var mc = box.but;
		var me = this;
		mc.stop();
		box.but.onPress = function(){ mc.gotoAndStop(3); me.redirectBank(); };
		box.but.onRollOver = function(){mc.gotoAndStop(2);};
		box.but.onRollOut = function(){mc.gotoAndStop(1);};
		box.but.onDragOver = box.but.onRollOver;
		box.but.onDragOut = box.but.onRollOut;
		box.but.onRelease = box.but.onRollOver;
		box.but.onReleaseOutside = box.but.onRollOut;




	}
	function redirectBank(){
		flash.external.ExternalInterface.call("game_load_bank");
		//var lv = new flash.LoadVars();
		//lv.send( Reflect.field(flash.Lib._root,"bankUrl"), "_self" );
	}

	// PROTOCOLE
	public function initConnexion(){
		step = Connexion;
		//mcBar.field.text = "CONNEXION";

		// CLEAN
		switchView(false);
		while(menus.length>0)menus.pop().removeMovieClip();
		//mcMoveZone.removeMovieClip();
		removeIcons();

		map.onPress = null;
		map.onRollOver = null;
		map.onRollOut = null;
		map.useHandCursor = false;

	}
	function updateConnexion(){
		//mcBar.field.text = mcBar.field.text+".";
		//if(mcBar.field.text.length>12)mcBar.field.text = "CONNEXION";
	}

	public function confirmMove(x,y,flMinerai,?lvl){

		mcGame = dm.empty( DP_GAME );
		game = new Game( mcGame, spaceColors[x-SX][y-SY] );

		setTimeOut(null);
		startZoom(x-SX,y-SY,flMinerai,lvl);
	}

	public function confirmLander(flMinerai,capsType,flHouseVisited){

		mcGame = dm.empty( DP_GAME );
		game = new lander.Game( mcGame, spaceColors[hx][hy],flHouseVisited );

		setTimeOut(null);
		startZoom(hx,hy,flMinerai,null);

	}

	public function error(str:String){
		displayError(str);
	}

	public function setTimeOut(n){
		timeOut = n ;
		if( n==null )Manager.dm.clear(17);
	}
	public function displayError(str:String){
		var head = str.substr(0,3);
		if( head.indexOf("CRC")==1 || head.indexOf("crc")==1 ){
			str = Text.get.ERROR_CRC;
		}

		mcFarWarning = cast Manager.dm.attach("mcFarZone",17);
		mcFarWarning.gotoAndStop(3);
		mcFarWarning.field.text = str;
		game.kill();
		step = Error;
	}

	// SET INFOS
	public function setInfos( ?str ){
		setTimeOut(null);

		Cs.pi = new PlayerInfo();

		#if prod
			Cs.pi.parseInfo( str );
		#else
			Cs.pi.loadCache();
		#end

		Cs.log("PlayerInfo:");
		Cs.log(" - minerai:"+Cs.pi.minerai);
		Cs.log(" - missile:"+Cs.pi.missile+"/"+Cs.pi.missileMax);
		Cs.log(" - missions:");
		for( n in Cs.pi.missions ){
			var mi = MissionInfo.LIST[n];
			Cs.log("["+n+"]"+mi.desc);
		}




		// PLACE EARTH
		var earth = null;
		for( pl in ZoneInfo.list )if(pl.name=="Terre")earth = pl;
		var seed = new mt.Rand(Cs.pi.pid);
		if( Cs.pi.gotItem(MissionInfo.MODE_DIF) )seed.random(100);
		var ray = 1500+seed.random(500);
		earth.pos[0] = seed.random(ray)*(seed.random(2)*2-1);
		earth.pos[1] = Std.int( (ray-Math.abs(earth.pos[0]))*(seed.random(2)*2-1) );

		//trace(earth.pos);
			//Cs.pi.x = earth.pos[0];
			//Cs.pi.y = earth.pos[1];


		if(game!=null){
			game.kill();
			mcGame = null;
			game = null;
		}
		init();
	}

	// DEBUG KEY
	function initDebugListener(){
		dkl = {};
		Reflect.setField(dkl,"onKeyDown",pressKey);
		Reflect.setField(dkl,"onKeyUp",releaseKey);
		flash.Key.addListener(cast dkl);
	}
	function pressKey(){
		var n = flash.Key.getCode();
		var al = 65;

		/*
		//if( n >= al  && n<al+26 )
		var speed = 5;

		if( flash.Key.isDown(flash.Key.SHIFT) )speed*=4;
		if( flash.Key.isDown(flash.Key.CONTROL) )speed=1;

		if( n == flash.Key.LEFT )	warp(-speed,0);
		if( n == flash.Key.RIGHT )	warp(speed,0);
		if( n == flash.Key.UP )		warp(0,-speed);
		if( n == flash.Key.DOWN )	warp(0,speed);


		if( n == flash.Key.ENTER )	_Js._updateCapsules(0);
		*/

	}
	function releaseKey(){

	}

	// DEBUG
	function markMinerai(){
		//return;
		var mc:{>flash.MovieClip,field:flash.TextField} = cast dm.attach("mcTextField",0);
		mc.field._alpha = 50;
		var total = 0;

		for( x in 0...XMAX ){
			for( y in 0...YMAX ){
				var wx = SX+x;
				var wy = SY+y;
				var level = new Level(wx,wy,zoneTable[x][y],true);
				level.genModel();
				var n = level.getMineraiTotal();
				total += n;

				var m = new flash.geom.Matrix();
				m.translate(x*BW,y*BH);
				mc.field.text = Std.string(n);

				bmpBg.draw(mc,m);


			}
		}
		mc.removeMovieClip();

		Cs.log("minerai moyen par case :"+Std.int(total/(XMAX*YMAX)));

	}
	function warp( dx, dy){
		Cs.pi.x += dx;
		Cs.pi.y += dy;
		Cs.pi.saveCache();
		cleanAll();
		setInfos();
		zoomCoef = 0;
	}
	function updateDebug(){

		if( flash.Key.isDown(flash.Key.SHIFT) && flash.Key.isDown(82) ){	// R ESET
			trace("");
			trace("RESET ! VEUILLEZ RELANCER LE CLIENT !");
			Cs.pi.setToDefault();
			Cs.pi.saveCache();
			update = null;
		}
		if( flash.Key.isDown(flash.Key.SHIFT) && flash.Key.isDown(83) ){	// S AVE
			trace("");
			trace("SAVE ! VEUILLEZ RELANCER LE CLIENT !");
			Cs.pi.saveCache(flash.SharedObject.getLocal("info2"));
			update = null;
		}
		if( flash.Key.isDown(flash.Key.SHIFT) && flash.Key.isDown(76) ){	// L OAD
			trace("");
			trace("LOAD ! VEUILLEZ RELANCER LE CLIENT !");
			Cs.pi.loadCache(flash.SharedObject.getLocal("info2"));
			Cs.pi.saveCache();
			update = null;
		}
		if( flash.Key.isDown(flash.Key.SHIFT) && flash.Key.isDown(73) ){	// I TEM
			trace("");
			trace("EMPTY SHOP ITEM ! VEUILLEZ RELANCER LE CLIENT !");
			Cs.pi.shopItems = [];
			Cs.pi.saveCache();
			update = null;
		}
		if( flash.Key.isDown(flash.Key.SHIFT) && flash.Key.isDown(77) ){	// M ONEY
			trace("");
			trace("+10000 Minerai ! VEUILLEZ RELANCER LE CLIENT !");
			Cs.pi.minerai += 10000;
			Cs.pi.saveCache();
			update = null;
		}
		if( flash.Key.isDown(flash.Key.SHIFT) && flash.Key.isDown(67) ){	// C APS
			trace("");
			trace("FULL CAPS ! VEUILLEZ RELANCER LE CLIENT !");
			Cs.pi.shopItems[ShopInfo.FIRE] = 1 ;
			Cs.pi.shopItems[ShopInfo.ICE] = 1 ;
			Cs.pi.shopItems[ShopInfo.BLACKHOLE] = 1 ;
			Cs.pi.shopItems[ShopInfo.STORM] = 1 ;
			Cs.pi.saveCache();
			update = null;
		}

	}

	//
	public function kill(){
		flash.Key.removeListener(dkl);
		bmpBg.dispose();
		bmpFog.dispose();
		root.removeMovieClip();
	}


//{
}














