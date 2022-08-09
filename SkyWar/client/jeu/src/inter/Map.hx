package inter;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;

enum MapMode {
	VISIT;
	MOVE;
	SETTLER;
}
enum ScrollMode {
	Stare(mc:flash.MovieClip);
	MouseRelative;
	MouseEdge;
	ScrollArrow;
	DragnDrop;
}

typedef McLine = {>flash.MovieClip,mask:flash.MovieClip,top:flash.MovieClip,wp:flash.MovieClip};

typedef McShip = {>flash.MovieClip, pl:McPlanet, fm:Float, by:Float, data:DataShip, car:ShipLogic, color:Int, mcLife:flash.MovieClip };
typedef McPlanet = {>flash.MovieClip, owner:Int, sgr:ShipGroup, pl:Planet, view:Int, flView:Bool,bmp:flash.display.BitmapData, dm:mt.DepthManager, playerField:flash.TextField, nameField:flash.TextField };
typedef Travel = {
	data:DataTravel,
	flView:Bool,
	sx:Float,
	sy:Float,
	ex:Float,
	ey:Float,
	sgr:ShipGroup,
	line:McLine,

};

typedef View = { x:Int, y:Int, ray:Int };
typedef ShipGroup = {>flash.MovieClip, but:flash.MovieClip, list:Array<McShip>, owner:Int, dm:mt.DepthManager };

class Map {//}

	public static var FREE_MOVE = false;

	public static var DP_FRONT= 		12;
	public static var DP_SCREEN = 		10;

	public static var DP_FOG =		8;
	public static var DP_SHIPS =		7;
	public static var DP_SYMBOLS =		6;

	public static var DP_TRAVELS =		4;
	public static var DP_PLANETS = 		2;
	public static var DP_BG = 		0;

	public var flPlay:Bool;
	public var width:Int;
	public var height:Int;
	public var floater:Float;
	public var glow:Float;

	var scrollDir:Int;

	public var xMin:Float;
	public var xMax:Float;
	public var yMin:Float;
	public var yMax:Float;

	var mainScrollMode:ScrollMode;
	public var scrollMode:ScrollMode;
	public var mode:MapMode;

	public var me:inter.Map;
	public var mdm:mt.DepthManager;
	public var dm:mt.DepthManager;

	public var move:{start:McPlanet,list:Array<Int>,range:Int, line:McLine, near:Array<McPlanet>, status:FleetStatus, speed:Int };

	var content:flash.MovieClip;
	var mcRange:flash.MovieClip;
	var mcPlanets:flash.MovieClip;

	public var root:flash.MovieClip;

	public var board:flash.MovieClip;
	public var mcFlat:{>flash.MovieClip,bmp:flash.display.BitmapData};
	public var mcLayer:{>flash.MovieClip,bmp:flash.display.BitmapData};
	public var mcScrollArrow:flash.MovieClip;

	public var planets:Array<McPlanet>;
	public var ships:Array<McShip>;
	public var travels:Array<Travel>;

	// SELECTION MEMORY
	public var selectionTravel:Int;
	public var selectionPlanetFleet:Int;




	//root._url;

	public function new(){
		me = this;
		root = Inter.me.dm.empty(Inter.DP_MODULE);
		mdm = new mt.DepthManager(root);
		content = mdm.empty(0);
		dm = new mt.DepthManager(content);


		width = Game.me.mapWidth;
		height = Game.me.mapHeight;

		floater = 0;
		glow = 0;

		ships = [];

		initBg();
		initPlanets();

		//mainScrollMode = ScrollArrow;
		//mainScrollMode = MouseRelative;
		mainScrollMode = DragnDrop;
		scrollMode = mainScrollMode;



		updateBorder();
		centerMap();

			active();



	}
	public function initBg(){


		var seed = new mt.Rand(Game.me.data._id);

		// BOARD
		board = dm.empty(DP_BG);
		var bmp = new flash.display.BitmapData(width,height,true,0);
		board.attachBitmap(bmp,0);
		board.blendMode = "overlay";
		Filt.glow(board,6,1,0xafa287);
		// CADRE


		// GRILLE
		var ec = 80;
		var xmax = Std.int(width/ec);
		var ymax = Std.int(height/ec);


		// CENTER
		var cx = width*0.5;
		var cy = height*0.5;

		//*// BOUSSOLE


		var max = 80;
		var line = dm.attach("mcMapLine",0);
		line.gotoAndStop(Game.me.raceId+1);
		for( i in 0...1 ){
			//var cx = seed.random(width);
			//var cy = seed.random(height);

			if(i==1)cx = -50;
			var ray = 100;//seed.random()
			var dist = Math.sqrt(width*width+height*height)-ray;

			for( i in 0...max ){
				var a = i/max * 6.28;
				var x = Math.cos(a);
				var m = new flash.geom.Matrix();
				m.scale(dist*0.01,1);
				m.rotate(a);
				m.translate(cx+Math.cos(a)*ray,cy+Math.sin(a)*ray);
				bmp.draw(line,m);

			}
		}
		line.removeMovieClip();

		var max = 40;
		var mc = dm.attach("mcMapCircle",0);
		mc.gotoAndStop(Game.me.raceId+1);
		for( i in 0...max){
			var c = Math.pow(i/max,8);
			var m = new flash.geom.Matrix();
			var sc = 0.6+(width/75)*c;
			m.scale(sc,sc);
			m.translate(cx,cy);
			var ct = new flash.geom.ColorTransform(1,1,1,c,0,0,0,0);
			bmp.draw(mc,m,ct);
		}
		mc.removeMovieClip();



		/* SCANLINE
		var line = dm.attach("mcScanLine",0);
		var ec = 16;
		var ymax = Std.int(height/ec);
		for( y in 0...ymax ){
			var m = new flash.geom.Matrix();
			m.scale(width*0.01,1);
			m.translate(0,y*ec);
			var ct = new flash.geom.ColorTransform(1,1,1,0,0,0,0,20);
			bmp.draw(line,m,ct,"overlay");

		}
		line.removeMovieClip();
		*/



		#if fast
		return;
		#end

		// SKY
		/*
		bmp.perlinNoise(300,100,5,seed.random(10000),false,true,0,true);
		var c = 0.2;
		var ct = new flash.geom.ColorTransform(c,c,c,1,30,160,236,0);
		bmp.colorTransform(bmp.rectangle,ct);


		// CLOUDS
		var brush =  dm.attach("mcCloud",0);
		var bl = 20;
		Filt.blur(brush.smc,bl,bl);
		var max = 100;
		var mx = -100;
		var hy = height*0.5;

		for( i in 0...max ){
			//var coef = 0.2+Math.pow(i/max,2)*0.8;
			var coef = Math.pow(i/max,2);
			var m = new flash.geom.Matrix();
			var x = mx+seed.random( width-2*mx ) ;
			var y = height - Std.int((1-coef)*500);
			//var y = hy + (seed.rand()*2-1)*coef*hy;
			var sc = 0.1+coef*1.5;
			m.scale(sc,sc);
			m.translate( x, y );

			//var ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,0);
			Col.setPercentColor(brush.smc,(1-coef)*100,COLOR_SKY);

			bmp.draw(brush,m);
		}
		brush.removeMovieClip();

		*/

	}
	public function initPlanets(){

		//var id = 0;
		planets = [];

		//mcPlanets = mdm.empty(DP_PLANETS);
		//var pdm = new mt.DepthManager(mcPlanets);

		for( pl in Game.me.planets ){

			var mc:McPlanet = cast dm.empty(DP_PLANETS);
			mc._x = pl.x;
			mc._y = pl.y;
			mc.pl = pl;
			mc.sgr = newShipGroup();
			planets.push(mc);


			mc.dm = new mt.DepthManager(mc);


			var mmc = mc.dm.attach("mcIsleName",0);
			cast(mmc)._txt = "<b>"+Game.me.getPlanetName(pl.id)+"</b>";
			var field:flash.TextField = cast(mmc)._field;
			field.textColor = Cs.COLOR_TEXT;
			Game.fixTextField(field);
			mc.nameField = field;
			mmc._y = 32;


			var mmc = mc.dm.attach("mcIsleName",0);
			mc.playerField = cast(mmc)._field;
			mc.playerField.htmlText = "";
			Game.fixTextField(mc.playerField);
			//mc.playerField.text =
			mmc._y = 44;


			drawPlanet(mc);






			/* // TITLE
			var mcTitle = dm.attach("mcIslandTitle",DP_PLANETS);
			Reflect.setField(mcTitle,"_name",Game.me.getPlanetName(pl.id)) ;
			mcTitle._x = mc._x;
			mcTitle._y = mc._y + 50;
			mcTitle._alpha = 60;
			*/

		}

	}

	function drawPlanet(mc:McPlanet){


		// DRAW
		if( mc.bmp != null )mc.bmp.dispose();
		var col = Cs.COLOR_SKY;

		var playerName = "";
		if(mc.pl.owner!=null){
			var player = Game.me.getPlayer(mc.pl.owner);
			col =  Cs.COLORS[ player._color ];
			mc.playerField.textColor = col;
			playerName =  "("+player._name+")";
		}
		mc.playerField.text = playerName;
		Game.fixTextField(mc.playerField);
		var bmp = getMiniature(mc.pl, col );
		var mmc = mc.dm.empty(1);
		mmc.attachBitmap(bmp,0);
		mmc._x = -bmp.width*0.5;
		mmc._y = -bmp.height*0.5;
		Filt.glow(mmc,2,4,Cs.COLOR_LINE2);
		mc.bmp = bmp;
		mc.owner = mc.pl.owner;

	}


	// UPDATE
	public function update(){

		if( !Inter.me.flLoading )scrollMap();
		if( !Inter.me.isReady() || !root._visible )return;

		fxUpdateGlow();

		updateShips();

		if(move!=null)updateMoveMode();



		//haxe.Log.clear();
		//trace( Cs.getTime( Game.me.world.autoUpdateCycle-(Game.me.now()-Game.me.world.lastUpdate) ) );


	}

	// SCROLL
	var dragPoint:{x:Float,y:Float};
	var dragArrow:flash.MovieClip;
	function scrollMap(){

		var trg = null;


		switch(scrollMode){

			case Stare(mc):
				var mx = Inter.me.width*0.5;
				var my = Inter.me.height*0.5;
				var x = Num.mm(mx,mc._x,width-mx);
				var y = Num.mm(my,mc._y,height-my);
				trg = {	x:mx-x,	y:my-y	};

			case MouseRelative:
				trg = getMapPos();

			case MouseEdge:
				if(Inter.me.root._xmouse==0 && Inter.me.root._ymouse==0)return;

				var ma = 80;
				var speed = 50;
				var vx = 0;
				var vy = 0;
				if( Inter.me.root._xmouse < ma ) 			vx += speed;
				if( Inter.me.root._xmouse > Inter.me.width-ma ) 	vx -= speed;
				if( Inter.me.root._ymouse < ma ) 			vy += speed;
				if( Inter.me.root._ymouse > Inter.me.height-ma ) 	vy -= speed;
				trg = {
					x : Num.mm( Inter.me.width-xMax, root._x+vx, -xMin ),
					y : Num.mm( Inter.me.height-yMax, root._y+vy, -yMin ),
				}
				trg.x = Num.mm( Inter.me.width-width, trg.x, 0 );
				trg.y = Num.mm( Inter.me.height-height, trg.y, 0 );

			case ScrollArrow:

				var id = null;
				var ma = 50;
				if( Inter.me.root._ymouse < Inter.me.height ){
					if( Inter.me.root._xmouse < ma && root._x < -xMin ) 					 id = 2;
					else if( Inter.me.root._xmouse > Inter.me.width-ma && root._x > Inter.me.width-xMax ) 	 id = 0
					else if( Inter.me.root._ymouse < ma && root._y < -yMin ) 				 id = 3;
					else if( Inter.me.root._ymouse > Inter.me.height-ma && root._y > Inter.me.height-yMax ) id = 1;
				}

				if( id == null && mcScrollArrow!=null ){
					mcScrollArrow.removeMovieClip();
					mcScrollArrow = null;
				}
				if( id!=null ){

					mcScrollArrow._visible = true;
					if( mcScrollArrow == null ){
						mcScrollArrow = Inter.me.dm.attach( "mcScrollArrow", Inter.DP_MODULE );
						mcScrollArrow.blendMode = "overlay";
					}

					var ww = Cs.mcw*0.5;
					var hh = (Cs.mch-Inter.BH)*0.5;
					var d = Cs.DIR[id];

					mcScrollArrow._x = ww + d[0]*(ww-ma*0.5);
					mcScrollArrow._y = hh + d[1]*(hh-ma*0.5);
					mcScrollArrow._rotation = id*90;

					mcScrollArrow.smc.onPress = callback(startScroll,id);
					mcScrollArrow.smc.onRelease = stopScroll;
					mcScrollArrow.smc.onReleaseOutside = stopScroll;
					mcScrollArrow.smc.onDragOut = stopScroll;

				}


				if(scrollDir != id )scrollDir = null;

				var d = Cs.DIR[scrollDir];
				if(scrollDir==null)d=[0,0];
				var speed=  30;
				trg = {
					x : Num.mm( Inter.me.width-xMax,	root._x-d[0]*speed, -xMin ),
					y : Num.mm( Inter.me.height-yMax,	root._y-d[1]*speed, -yMin ),
				}



			case DragnDrop:
				if(dragPoint!=null){
					root._x = dragPoint.x+Inter.me.root._xmouse;
					root._y = dragPoint.y+Inter.me.root._ymouse;
				}
				recalScroll();


		}


		if( trg!=null ){
			var c = 0.3;
			var lim = 100;
			var dx = trg.x-root._x;
			var dy = trg.y-root._y;
			root._x += Num.mm(-lim,dx,lim)*c;
			root._y += Num.mm(-lim,dy,lim)*c;

			if( Math.abs(dx)<1 ) root._x = trg.x;
			if( Math.abs(dy)<1 ) root._y = trg.y;

		}

	}
	function centerMap(){
		var max = 0;
		var x = 0.0;
		var y = 0.0;

		for( pl in Game.me.planets ){
			if( pl.isMine() ){
				x += pl.x;
				y += pl.y;
				max++;
			}
		}

		if( max == 0 )return;

		x /= max;
		y /= max;

		xMin = Math.max(Inter.me.width-width, xMin);


		var trg = {
			x: Num.mm( Inter.me.width-width, Cs.mcw*0.5-x, 0 ) ,
			y: Num.mm( Inter.me.height-height, Cs.mch*0.5-y, 0 ) ,
		}
		root._x = trg.x;
		root._y = trg.y;
	}
	function updateBorder(){

		// TODO - Gerer les ranges.

		if( FREE_MOVE || !flPlay ){
			xMin = 0;
			yMin = 0;
			xMax = width;
			yMax = height;
			return;
		}

		xMin = 9999;
		yMin = 9999;
		xMax = 0;
		yMax = 0;
		var ww = 500;
		var hh = 500;
		for( pl in Game.me.planets ){
			if( pl.isMine() ){
				xMin = Math.min(pl.x-ww,xMin);
				yMin = Math.min(pl.y-hh,yMin);
				xMax = Math.max(pl.x+ww,xMax);
				yMax = Math.max(pl.y+hh,yMax);
			}
		}

		xMin = Math.max(0,xMin);
		yMin = Math.max(0,yMin);
		xMax = Math.min(width,xMax);
		yMax = Math.min(height,yMax);




	}

	public function recalScroll(){
		root._x = Num.mm( Inter.me.width-xMax, root._x, -xMin);
		root._y = Num.mm( Inter.me.height-yMax, root._y, -yMin);
	}

	function startScroll(id){
		scrollDir = id;
	}
	function stopScroll(){
		scrollDir = null;
	}

	function initDragMap(){
		stopDragMap();
		Inter.me.background.onPress = startDragMap;
		Inter.me.background.onRelease = stopDragMap;
		Inter.me.background.onReleaseOutside = stopDragMap;
		Inter.me.background.useHandCursor = false;
	}
	function removeDragMap(){
		Inter.me.background.onPress = null;
		Inter.me.background.onRelease = null;
		Inter.me.background.useHandCursor = false;
	}
	function startDragMap(){
		Inter.me.flDrag = true;
		dragArrow.removeMovieClip();
		dragArrow = dm.attach("mcDragArrow",DP_FRONT);
		dragArrow._x = root._xmouse;
		dragArrow._y = root._ymouse;
		dragArrow.blendMode = "overlay";
		dragPoint = {
			x : root._x - Inter.me.root._xmouse,
			y : root._y - Inter.me.root._ymouse,
		}
	}
	function stopDragMap(){
		Inter.me.flDrag = false;
		dragArrow.removeMovieClip();
		dragPoint = null;
	}

	public function getMapPos(){
		var m = 80;
		var cx = Num.mm(0,Inter.me.root._xmouse-m,Inter.me.width-2*m) / (Inter.me.width-2*m);
		var cy = Num.mm(0,Inter.me.root._ymouse-m,Inter.me.height-2*m) / (Inter.me.height-2*m);
		return {
			x : (Inter.me.width-width)*cx,
			y : (Inter.me.height-height)*cy,
		};
	}
	public function backToMouseScroll(){
		scrollMode = mainScrollMode;
	}

	// MAJ
	public function maj( ){


		var data = Game.me.world.data;
		if(Inter.me.isle!=null)return;


		// CLEAN BOARD / LAYER
		Inter.me.panel.remove();
		if(mode==MOVE)cleanMoveMode();

		// CLEAN TRAVELS
		while( travels.length>0 ){
			var tr = travels.pop();
			tr.sgr.removeMovieClip();
		}

		// CLEAN SHIP GROUPS PLANET
		for( mc in planets ){
			mc.sgr.removeMovieClip();
			mc.sgr = newShipGroup();
		}

		// PLANETS
		for( d in data._planets ){
			var mc = getPlanet(d._id);
			mc.pl.attributes = d._attributes;
			if( mc.owner != d._owner ){
				mc.pl.owner = d._owner;
				drawPlanet(mc);
			}

			var fieldVisible = Param.is(PAR_DISPLAY_ISLAND_INFO);
			mc.playerField._visible = fieldVisible;
			mc.nameField._visible = fieldVisible;

		}


		flPlay = false;

		if( Game.me.world.data._mode != MODE_INSTALL ){

			flPlay = true;
			//Game.me.date = Date.now();
			//Game.me.setTimeDif( data._time );


			// TRAVELS
			dm.clear(DP_TRAVELS);
			travels = [];
			for( data in data._travels ){

				var pl =  getPlanet(data._start);

				var pl2 = getPlanet(data._dest);
				var travel = {
					data:data,
					sx:pl._x,
					sy:pl._y,
					ex:pl2._x,
					ey:pl2._y,
					line:cast dm.attach("mcTravelLine",DP_TRAVELS),
					flView:true,
					sgr:newShipGroup()
				};
				travels.push(travel);
			}


			// SHIPS
			while(ships.length>0)ships.pop().removeMovieClip();
			for(d in data._ships){
				if(d._pid==null){
					var tr = getTravel(d._tid);
					var mc = newShip(d,tr.sgr);
					mc.car = Tools.getShipCaracs(d._type,Game.me.getPlayer(d._owner)._tec,tr.data._attributes,null);
				}else{
					var pl = getPlanet(d._pid);
					var mc = newShip(d,pl.sgr);
					mc.car = Tools.getShipCaracs(d._type,Game.me.getPlayer(d._owner)._tec,null,pl.pl.attributes);
					mc.pl = pl;
				}
			};


			// GROUPS UPDATE
			for( pl in planets ){
				pl.sgr._x = pl._x;
				pl.sgr._y = pl._y-30;
				updateShipGroup(pl.sgr);
			}
			for( tr in travels ){
				updateShipGroup(tr.sgr);
			}


			// COLOR TRAVELS
			var id = 0;
			for( tr in travels ){
				var color = Cs.COLORS[ tr.sgr.list[0].color ];
				Col.setColor(tr.line,color);
				dm.over(tr.sgr);

				id++;
			}


		}else{

			for( mc in planets ){
				if( mc.pl.owner == Game.me.playerId ){
					flPlay = true;
					Inter.me.initPlayerWait();
					break;
				}
			}

		}

		if( flPlay ){
			initVisitMode();
		}else{
			initSettlerMode();
		}



		if( selectionTravel!=null ){
			var tr = getTravel(selectionTravel);
			if( tr!=null )selectTravelFleet(tr);
		}


		if( selectionPlanetFleet!=null ){
			var mcp = this.getPlanet(selectionPlanetFleet);
			if( mcp !=null && mcp.sgr.list.length>0 )selectPlanetFleet(mcp);
		}

	}
	function getTravel(id):Travel{
		for( tr in travels )if(tr.data._id==id)return tr;
		return null;
	}

	// SHIP / SHIPGROUP
	function newShip(data:DataShip,sgr:ShipGroup){
		//var mc:McShip = cast sgr.dm.attach("mcMapShip",3);
		var mc:McShip = cast sgr.dm.empty(3);

		var sdm = new mt.DepthManager(mc);

		mc.smc = sdm.attach("mcMapShip",0);

		mc.data = data;
		mc.car = Tools.getShipCaracs(data._type,Game.me.getPlayer(data._owner)._tec,null,null);
		mc.fm = Math.random()*628;
		ships.push(mc);
		sgr.list.push(mc);
		mc.smc.gotoAndStop(Type.enumIndex(data._type)+1);
		mc.cacheAsBitmap = true;
		mc.color = Game.me.getPlayer(mc.data._owner)._color;
		sgr.owner = mc.data._owner;

		if( Param.is(_ParamFlag.PAR_DISPLAY_UNIT_LIFE ) ){

			mc.mcLife = sdm.attach("mcShipLifeBar",0);
			var coef = data._life / mc.car.life;
			mc.mcLife.smc._xscale = coef*100;
			mc.mcLife._x = 0;
			mc.mcLife._y = -14;
			var bar = mc.mcLife.smc;
			if( bar._xscale < 75 )Col.setPercentColor(bar,100,0xFFFF00);
			if( bar._xscale < 50 )Col.setPercentColor(bar,100,0xFF8800);
			if( bar._xscale < 25 )Col.setPercentColor(bar,100,0xFF0000);
		}



		Col.setColor(mc.smc,Cs.COLORS[ mc.color ]);
		//Filt.glow(mc,4,0.5,Cs.COLORS[data._owner]);

		Filt.glow(mc,2,10,Cs.COLOR_SKY);

		//Filt.glow(mc,2,10,0xFFFFFF);


		return mc;

	}
	public function newShipGroup(){
		var mc:ShipGroup = cast dm.empty(DP_SHIPS);
		mc.dm = new mt.DepthManager(mc);
		mc.list = [];
		mc.but = mc.dm.attach("mcSquare",0);
		mc.but._alpha = 0;
		mc.but._visible = false;
		mc.owner = null;
		return mc;
	}

	function updateShipGroup(sgr:ShipGroup){

		var a = sgr.list;

		var mod = Math.ceil(Math.min(Math.pow(a.length,0.5),5));

		var ec = 18;
		var xmax = Math.min(a.length,mod);
		var ymax = Math.ceil(a.length/mod);

		var ecx = ec;
		var ecy = Math.min( 60/ymax, 18);

		var x = -(xmax-1)*ecx*0.5;
		var y = -(ymax-1)*ecy*0.5;

		var id = 0;
		for( mc in a ){
			mc._x = x + id%mod * ecx;
			mc._y = y + Std.int(id/mod) * ecy;
			mc.by = mc._y;

			id++;
		}

		// BUT
		var m = 2;
		if(a.length==0)m=0;
		sgr.but._xscale = (xmax*ecx)+m;
		sgr.but._yscale = (ymax*ecy)+m;
		sgr.but._x = -(sgr.but._xscale)*0.5;
		sgr.but._y = -(sgr.but._yscale)*0.5;



	}
	function setGroupAction(sgr:ShipGroup,f){
		sgr.but.onPress = f;
		sgr.but._visible = f!=null;
	}

	public function updateShips(){


		// TRAVELS
		for( tr in travels ){
			var o = Game.me.getCounterInfo(tr.data._move);
			var x = tr.sx*(1-o.c) + tr.ex*o.c;
			var y = tr.sy*(1-o.c) + tr.ey*o.c;



			tr.sgr._x = x;
			tr.sgr._y = y;


			var dx = tr.ex-x;
			var dy = tr.ey-y;

			//var bray = 10;

			tr.line._x = x;
			tr.line._y = y;
			tr.line._rotation = Math.atan2(dy,dx)/0.0174;
			tr.line.mask._xscale = Math.sqrt(dx*dx+dy*dy);

			tr.line.smc._x += 0.5;
			if( tr.line.smc._x > -8 )tr.line.smc._x -= 8;

			tr.line.smc._yscale = 50;
			tr.line.top._x = tr.line.mask._xscale;

		}

		// FLOAT
		floater = (floater+6)%628;
		for( mc in ships ){
			if(mc.pl!=null){
				var decal = (floater+mc.fm)%628;
				mc._y =  mc.by+Math.cos(decal*0.01)*2;
			}

		}
	}

	// CLEAN MODE
	function cleanMode(){
		for( mc in planets ){
			Trick.butKill(mc);
			setGroupAction( mc.sgr, null );
		}
		for( tr in travels ){
			setGroupAction( tr.sgr, null );
		}


		Inter.me.background.onPress = null;
		Inter.me.background.useHandCursor = false;
		active();

		//Trick.butKill(board);
		//board.onPress = null;
		//board.useHandCursor = false;
		//board.enabled = false;
	}

	// VISIT MODE
	function initVisitMode(){
		cleanMode();
		mode = VISIT;
		for( mc in planets ){
			mc.onPress = callback( selectPlanet, mc.pl.id );
			mc.useHandCursor = true;
		}

		for( tr in travels ){
			setGroupAction( tr.sgr, callback( selectTravelFleet, tr  ) );
		}
		for( pl in planets ){
			setGroupAction( pl.sgr, callback( selectPlanetFleet, pl  ) );
		}


	}
	function selectTravelFleet(tr:Travel){
		selectionTravel = tr.data._id;
		new inter.pan.Fleet(tr.sgr,tr,null);
		scrollMode = Stare(tr.sgr);
	}
	function selectPlanetFleet(pl:McPlanet){
		selectionPlanetFleet = pl.pl.id;
		new inter.pan.Fleet(pl.sgr,null,pl);
		scrollMode = Stare(pl.sgr);
	}
	public function selectNextFleet(fleet:ShipGroup,inc:Int){
		var a = [];
		for( mc in planets )if(mc.sgr.list.length>0)a.push({sgr:mc.sgr,pl:mc,tr:null});
		for( tr in travels )a.push({sgr:tr.sgr,pl:null,tr:tr});

		var f = function(a:Dynamic,b:Dynamic){if(a.sgr._x<b.sgr._x)return -1;return 1;};
		a.sort(f);
		var id = 0;
		for( o in a ){
			if( o.sgr == fleet )break;
			id++;
		}

		id = Std.int( Num.sMod(id+inc,a.length) );
		var o = a[id];

		Inter.me.panel.remove();
		Inter.me.board.remove();
		new inter.pan.Fleet(o.sgr,o.tr,o.pl);
		Inter.me.board.animCoef = 1;
		Inter.me.board.update();

		selectionTravel = o.tr.data._id;
		selectionPlanetFleet = o.pl.pl.id;

		scrollMode = Stare(o.sgr);
	}

	// MOVE MODE
	public function initMoveMode(){
		cleanMode();
		mode = MOVE;



		move.near = getNeighbours(move.start,move.range);
		move.near.push(move.start);
		//var a = planets;
		for( mc in move.near ){
			Trick.butAction( mc, callback(selectMove,mc), callback(rollOverMove,mc), callback(rollOutMove,mc) );
		}

		//Inter.me.background.onPress = cancelMoveMode;
		//Inter.me.background.useHandCursor = true;

		traceNearLayer();

		//traceDistanceLayer();


	}
	public function updateMoveMode(){
		move.line.smc._x += 0.5;
		if( move.line.smc._x > -8 )move.line.smc._x -= 8;

		for( mc in move.near  ){
			var c = 0.5+Math.cos(glow*0.01)*0.5;
			mc.filters = [];
			Filt.glow(mc,4+c*4,2+c*3,0xFFFF00);
		}

	}

	public function selectMove(mc:McPlanet){
		if(mc==move.start){
			cancelMoveMode();
			return;
		}
		if( move.start.owner == Game.me.playerId ) sendFleet(mc);
		else Inter.me.msgBox(Lang.SEND_FLEET_CONFIRM,Lang.ARE_YOU_SURE_BACK_UNAVAILABLE,[{name:Lang.YES,f:callback(sendFleet,mc)},{name:Lang.NO,f:cancelMoveMode}]);
	}
	public function rollOverMove(mc:McPlanet){


		if(move.line==null){
			move.line = cast dm.attach("mcTravelLine",DP_SYMBOLS);
			move.line.blendMode = "add";
			move.line.top._visible = false;
			Filt.glow(move.line,8,1,0xFFFF00);
		}

		var dx = mc._x-move.start._x;
		var dy = mc._y-move.start._y;
		var dist = Math.sqrt(dx*dx+dy*dy);
		move.line._x = move.start._x;
		move.line._y = move.start._y;
		move.line._rotation = Math.atan2(dy,dx)/0.0174;
		move.line.mask._xscale = dist;

		var prc = (dist>move.range)?100:0;


		Col.setPercentColor(move.line,prc,0xFF0000);
		mcLayerField._visible = true;
		var speed = move.speed;

		for( att in mc.pl.attributes){
			switch(att){
				case PA_WATCH_TOWER :
					if( mc.pl.owner == Game.me.playerId ){
						speed = Std.int(speed*GamePlay.WATCH_TOWER_COEF);
					}
				default :
			}
		}


		mcLayerField.field.text = Cs.getTime(  Tools.getTravelTime(speed,dist) );
		mcLayerField._x = mc._x;
		mcLayerField._y = mc._y-10;

		if( mc==move.start )mcLayerField.field.text = Lang.CANCEL;


	}
	public function rollOutMove(mc){
		move.line.removeMovieClip();
		move.line = null;
		mcLayerField._visible = false;
	}

	public function cancelMoveMode(){
		initVisitMode();
		cleanMoveMode();
	}
	function cleanMoveMode(){
		for( mc in move.near )	mc.filters = [];
		move.line.removeMovieClip();
		move = null;
		selectionPlanetFleet = null;
		cleanLayer();
	}

	public function sendFleet(mc:McPlanet){
		Api.sendFleet(move.start.pl.id, mc.pl.id, move.list, move.status );
		cleanMoveMode();
	}

	// LAYER
	var mcLayerField:{>flash.MovieClip,field:flash.TextField};
	function newLayer(){
		mcLayer = cast dm.empty(DP_BG);
		mcLayer.bmp = new flash.display.BitmapData(width,height,true,0);
		mcLayer.attachBitmap(mcLayer.bmp,0);
	}

	function traceDistanceLayer(){
		if(mcLayer!=null)cleanLayer();
		newLayer();


		var mc = dm.attach("mcDistance",0);

		var a= Game.me.planets;
		for( n in 0...a.length ){
			var pl = a[n];
			for( k in n+1...a.length ){
				var pl2 = a[k];
				var dx = pl.x - pl2.x;
				var dy = pl.y - pl2.y;
				var dist = Math.sqrt(dx*dx+dy*dy);

				var fr = 1;
				if( dist >= 300 )	fr = 2;
				if( dist >= 400 )	fr = 3;
				if( dist < 600 ){
					var m = new flash.geom.Matrix();
					m.scale( dist/100, 1 );
					m.rotate( Math.atan2(dy,dx) );
					m.translate(pl2.x,pl2.y);
					mc.gotoAndStop(fr);
					mcLayer.bmp.draw(mc,m);
				}
			}
		}

		mc.removeMovieClip();


	}
	function cleanLayer(){
		mcLayer.bmp.dispose();
		mcLayer.removeMovieClip();
		mcLayer = null;
		mcLayerField.removeMovieClip();
	}

	function traceNearLayer(){
		newLayer();
		mcLayer.blendMode = "overlay";
		var mc = move.start;
		var brush = dm.attach("mcNearLine",0);
		for( mc2 in move.near ){
			var dx = mc._x - mc2._x;
			var dy = mc._y - mc2._y;
			var dist = Math.sqrt(dx*dx+dy*dy);
			var m = new flash.geom.Matrix();
			m.scale( dist/100, 1 );
			m.rotate( Math.atan2(dy,dx) );
			m.translate(mc2._x,mc2._y);
			mcLayer.bmp.draw(brush,m);
		}
		brush.removeMovieClip();

		//
		mcLayerField = cast dm.attach("mcTimeTravel",DP_SHIPS);
		mcLayerField.field.text = "bonjour";
		mcLayerField._x = mc._x;
		mcLayerField._y = mc._y-40;
		//Col.setColor(mcLayerField,Cs.COLOR_MARONASSE);
		Col.setColor(mcLayerField,Cs.COLOR_LINE);
		//mcLayerField.blendMode = "overlay";
		mcLayerField._visible = false;



	}


	// INSTALL MODE
	public function initSettlerMode(){

		mode = SETTLER;

		for( mc in planets ){
			if(mc.pl.owner == null ){
				Trick.butAction( mc, callback(selectSettler,mc), callback(rollOverSettler,mc), callback(rollOutSettler,mc) );
			}else{
				/*
				var flag = dm.attach("mcFlag",DP_TRAVELS);
				flag._x = mc._x;
				flag._y = mc._y;
				Col.setColor( flag.smc, Cs.COLORS[mc.pl.owner] );
				*/
			}
		}
		Inter.me.initScrollText(Lang.CHOOSE_ISLAND);

	}
	public function selectSettler(mc:McPlanet){
		mc.filters = [];
		//trace(mc.pl.id);
		//Inter.me.selectPlanet(mc.pl,true);
		Inter.me.launchModule(1,mc.pl.id);
		//Api.settleDown(mc.pl.id);
		//Api.onConfirm = maj;
		Inter.me.removeScrollText();
	}
	public function rollOverSettler(mc:McPlanet){
		mc.filters = [];
		Filt.glow(mc,6,3,0xFFFFFF);
	}
	public function rollOutSettler(mc:McPlanet){
		mc.filters = [];

	}

	// PLANETS
	function getMiniature(pl:Planet,?col:Int){

		var sc =  Inter.MAP_ZOOM;

		var grid = pl.getGrid();

		var mc = dm.empty(0);
		var ddm = new mt.DepthManager(mc);


		for( x in 0...Cns.GRID_MAX ){
			for( y in 0...Cns.GRID_MAX ){
				var h = grid[x][y];
				if( h != null ){
					var mc = ddm.attach(Cs.gil("mcMapDalle"),0);
					mc._x = Isle.getX(x,y);
					mc._y = Isle.getY(x,y);
					if(col!=null)Col.setColor(mc.smc,col);
					var ether:flash.MovieClip = cast(mc).ether;
					ether._visible = h>0;

				}
			}
		}


		var width = Std.int( (Cs.mcw-inter.Board.WIDTH)*sc );
		var height = Std.int( Cs.mch*sc );
		var bmp = new flash.display.BitmapData( width, height, true, 0 );
		var m = new flash.geom.Matrix();
		m.scale(sc,sc);
		m.translate(0,0);
		bmp.draw(mc,m);

		mc.removeMovieClip();


		return bmp;

	}
	function selectPlanet(id){
		//Inter.me.selectPlanet(id);
		Inter.me.launchModule(1,id);
	}

	// RANGE
	public function traceRange(x,y,ray){
		if(mcRange==null){

			mcRange = Inter.me.map.dm.attach("mcRange",Map.DP_SYMBOLS);
			mcRange.blendMode = "add";
			mcRange._alpha = 10;
			Filt.blur(mcRange,16,16);
		}
		mcRange._x = x;
		mcRange._y = y;
		mcRange._xscale = mcRange._yscale = ray*2;
	}
	public function removeRange(){
		mcRange.removeMovieClip();
		mcRange = null;
	}

	// ACTIVE
	public function active(){
		root._visible = true;
		if(mainScrollMode == DragnDrop)initDragMap();

	}
	public function unactive(){
		root._visible = false;
		if(mainScrollMode == DragnDrop)removeDragMap();
	}

	// FLAT
	public function flat(){


		mcFlat = cast mdm.empty(1);
		mcFlat.bmp = new flash.display.BitmapData(width,height,true,0);
		mcFlat.attachBitmap(mcFlat.bmp,0);

		Col.setPercentColor(board,100,Cs.COLOR_LINE);
		board._alpha = 10;
		mcFlat.bmp.draw(root);
		board._alpha = 100;
		Col.setPercentColor(board,0,0);

		content._visible = false;
		for( mc in ships )mc._visible = false;
		for( tr in travels ){
			tr.line._visible = false;
			tr.sgr._visible = false;
		}

		board._visible = false;



	}
	public function unFlat(){
		board._visible = true;
		//trace("UNFLAT!!!");
		mcFlat.bmp.dispose();
		mcFlat.removeMovieClip();
		content._visible = true;
		for( mc in ships )mc._visible = true;
		for( tr in travels ){
			tr.line._visible = true;
			tr.sgr._visible = true;
		}

	}

	// FX
	function fxUpdateGlow(){
		glow = (glow+17)%628;
	}

	//
	public function getNeighbours(mc:McPlanet,dist){
		var a = [];

		for( pl in planets ){
			var dx = pl._x - mc._x;
			var dy = pl._y - mc._y;
			var pdist = Math.sqrt(dx*dx+dy*dy);
			if( pl!=mc && pdist<dist ){
				// trace( Game.me.getPlanetName(mc.pl.id)+ "<---->" +  Game.me.getPlanetName(pl.pl.id)+" = "+pdist );
				a.push(pl);
			}
		}

		return a;
	}

	//
	public function getPlanet(id){
		for( mc in planets )if(mc.pl.id==id)return mc;
		return null;
	}


//{
}















