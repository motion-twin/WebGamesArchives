package inter;
import Datas;
import Inter;
import mt.bumdum.Lib;
import mt.bumdum.Trick;

typedef IsleLink = { >flash.MovieClip, pl:Planet };
typedef SkyPart = { >flash.MovieClip, c:Float, type:Int };

typedef Dalle = {
	>flash.MovieClip,
	link:Dalle,
	flEther:Bool,
	ground:{>flash.MovieClip,but:flash.MovieClip},
	dirt:flash.MovieClip,
	bat:flash.MovieClip,
	bt:_Bld,
	life:Int,
	lifeBar:flash.MovieClip,
	counter:Counter,
	dm:mt.DepthManager,
	x:Int,
	z:Int,
	y:Int
};

class Isle {//}

	static var FL_ARROW = true;

	public static var DX = 30;
	public static var DY = 16;
	public static var HH = 8;

	public var flBlob:Bool;
	public var flOwn:Bool;
	public var flConstruct:Bool;
	var flView:Bool;

	// ISLE
	public static var DP_SHIPS_INTER =	10;
	public static var DP_PROJECTILES =	8;
	public static var DP_PLASMA =		6;
	public static var DP_SHIPS = 		4;
	public static var DP_LINKS = 		5;
	public static var DP_GLASS = 		4;
	public static var DP_SELECTION = 	3;
	public static var DP_BAT = 		2;
	public static var DP_GROUND = 		1;
	public static var DP_BG = 		0;

	public var fight:Fight;

	public var grid:Array<Array<Dalle>>;
	public var dalles:Array<Dalle>;

	public var autoUpdate:Float;

	public var mcGlass:flash.MovieClip;
	public var mcIsle:flash.MovieClip;
	public var pl:Planet;
	public var dm:mt.DepthManager;
	public var idm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;

	public function new(p:Planet){
		root = Inter.me.dm.empty(Inter.DP_MODULE);
		dm = new mt.DepthManager(root);
		bg = Inter.me.dm.attach("bgIsle",Inter.DP_BG);
		bg._x = Cs.mcw*0.5;
		bg._y = Cs.mch*0.5;
		setPlanet(p);
	}

	function setPlanet(p:Planet){
		pl = p;
		checkOwn();
		initLand();
		flView = false;
		maj();
	}

	public function initLand(){
		var pgr = pl.getGrid();
		var seed = pl.getSeed();

		mcIsle = dm.empty(DP_GROUND);
		idm = new mt.DepthManager(mcIsle);

		// BORDER
		var a = [];
		for( x in 0...Cns.GRID_MAX ){
			for( y in 0...Cns.GRID_MAX ){
				//var h = pgr[x][y];
				if(pgr[x][y]!=null)a.push([x,y]);
			}
		}
		var list = [];
		for( p in a ){
			for( d in Cns.DIR ){
				var x = p[0]+d[0];
				var y = p[1]+d[1];
				if( pgr[x][y]==null ){
					pgr[x][y]=-1;
				}
			}
		}

		// ATTACH
		dalles = [];
		grid = [];
		for( x in 0...Cns.GRID_MAX ){
			grid[x] = [];
			for( y in 0...Cns.GRID_MAX ){
				var h = pgr[x][y];
				if( h != null ){
					var mc:Dalle = cast idm.attach("mcDalle",DP_GROUND);
					mc._x = getX(x,y);
					//if( flOwn )mc._x -= inter.Board.WIDTH*0.5;
					mc._y = getY(x,y);
					mc.ground.gotoAndStop(h+1);
					if(h==1)mc.flEther = true;
					mc.x = x;
					mc.y = y;
					dalles.push(mc);
					if( h>=0 ){

						var k = 0;
						for( d in Cs.FDIR ){
							var nx = x+d[0];
							var ny = y+d[1];
							var nb = pgr[nx][ny];
							if( nb!=null && nb>=0 )k++;
						}
						if (mc.dirt._totalframes == null)
							throw "mc.dirt._totalframes == null";
						mc.dirt.gotoAndStop(seed.random(mc.dirt._totalframes)+1);
						mc.dirt._y = Math.pow(k-1,2.2)*2 + seed.random(60)-30;
						mc.dm = new mt.DepthManager(mc);
						mc.ground.stop();
						if (mc.ground.smc._totalframes == null)
							throw "mc.ground.smc._totalframes == null";
						mc.ground.smc.gotoAndStop(seed.random(mc.ground.smc._totalframes)+1);

						grid[x][y] = mc;

						//var prc = 80-(mc.x+mc.y)*2;
						//Col.setPercentColor(mc.dirt,prc,0x8AA190);

					}else{
						mc.gotoAndStop(2);
						var fr = 1;
						var inc = 1;
						for( d in Cs.DIR ){
							var nb = pgr[x-d[0]][y-d[1]];
							if(nb!=null && nb>=0 ){
								fr+= inc;
							}
							inc *= 2;
						}
						mc.smc.gotoAndStop(fr);
						var frames = if (mc.smc.smc._totalframes != null) mc.smc.smc._totalframes else 0;
						mc.smc.smc.gotoAndStop(seed.random(frames)+1);
					}

					//var prc = 90-(mc.x+mc.y)*2.5;
					var prc = 98-(mc.x+mc.y)*3;
					if( prc < 0 ) prc = 0;
					Col.setPercentColor(mc,prc,0x8AA190);
				}
			}
		}
	}

	public function update(){
		if(fight!=null){
			fight.update();
			return;
		}
		if( move!=null ){
			updateLink();
			return;
		}
		if( Inter.me.isReady() && pl.isOld() ){
			Api.getDataPlanet(pl.id, maj);
		}
		var flv = flash.Key.isDown(flash.Key.CONTROL);
		if( !flView && flv   )showView();
		if( flView && !flv   )hideView();
		if( flBlob )fxBlob();
	}

	// MAJ
	public function superMaj(){
		Inter.me.board.remove();
		active();
		maj();
	}
	
	public function maj(){
		var oldOwn = flOwn;
		var oldCon = flConstruct;
		checkOwn();
		if (!flOwn && (oldOwn != flOwn || oldCon != flConstruct)){
			// not a neutral (or own) isle anymore, get out isle mode so we won't see what the new owner will do on this isle.
			Inter.me.launchModule(0,null);
			return;
		}
		Inter.me.board.updateFields();
		displayBuildings(pl.bld,flConstruct);
		if( flConstruct )				initDalleBuildActions();
		if( Game.me.world.data._mode==MODE_INSTALL )	initBuildPalaceActions();
		// ICONS
		displayIcons();
		// PANEL
		Inter.me.board.display();
		// AUTO UPDATE
		autoUpdate = pl.yard[0]._counter._end;
		if( pl.breed._end < autoUpdate  )autoUpdate = pl.breed._end;
		//
		flBlob = Param.is(PAR_BLOB);
		//
		updateDepths();
	}
	
	public function displayBuildings(a:Array<DataBuilding>,flPlan:Bool){
		for( d in dalles )cleanDalle(d);
		for( b in a ){
			if(b._progress>0 || flPlan )build(b);
		}
	}

	public function getBat(x,y){
		var dalle = getDalle(x,y);
		if( dalle.bat == null  ){
			dalle.bat = dalle.dm.attach("mcBuilding",DP_BAT);
			//dalle.bat._x = dalle._x;
			//dalle.bat._y = dalle._y;
			//bats.push(dalle);
		}
		return dalle.bat;
	}

	public function build(b:DataBuilding){
		var bat = getBat(b._x,b._y);
		displayBld(bat,b);
		installBld(b);
		bat.filters = [];
	}
	
	public function displayBld(mc:flash.MovieClip,b:DataBuilding){
		if( b._progress ==1 ){
			mc.gotoAndStop(Type.enumIndex(b._type)+2);
		}else{
			var fr = Cs.isBig(b._type)?2:1;
			if(b._progress==0)fr+=2;
			mc.gotoAndStop(1);
			mc.smc.gotoAndStop(fr);
		}
	}
	/*
	public function buildConstruct(b:_Bld,x,y,counter){

		if( !Game.flViewFuturBuild ){

			var d = getDalle(x,y);
			d.counter = counter;
			var bat = getBat(x,y);
			bat.gotoAndStop(1);

			bat.smc.gotoAndStop(fr);
			installBld({_x:x,_y:y,_type:b,_life:null});

		}else{
			build({_id:0, _type:b, _x:x, _y:y, _life:100, _progress:1.0 });
		}

	}
	*/

	function cleanDalle(d:Dalle){
		d.bat.removeMovieClip();
		d.link = null;
		d.bat = null;
		d.bt = null;
		if(d.flEther){
			d.ground.gotoAndStop(2);
			d.ground.smc.stop();
		}
	}

	function installBld(b){
		var mainDalle:Dalle = null;
		var a = Cs.getBatZone(b._type,b._x,b._y);
		for( p in a ){
			var dalle = getDalle(p[0],p[1]);
			if(mainDalle==null){
				mainDalle = dalle;
				dalle.bt = b._type;
				dalle.life = b._life;
			}else{
				dalle.link = mainDalle;
			}
			dalle.ground.gotoAndStop(1);
			dalle.ground.smc.gotoAndStop(1);
		}
	}

	function updateDepths(){
		var me = this;
		var f = function(a:Dalle,b:Dalle){
			if( me.getDepth(a) < me.getDepth(b) ) return -1;
			return 1;
		}
		dalles.sort(f);
		for( d in dalles )idm.over(d);
	}
	
	function getDepth(d:Dalle){
		var dsc = (d.x+d.y)*2;
		if( Cs.isBig(d.bt) )dsc--;
		return dsc;
	}

	public function displayIcons(){
		/*
		var a = [displayYard,displayConstructShip,displaySearch,displayWar];
		if( pl.yard.length == 0 )		a[0] = null;
		if( pl.availableShp.length == 0 )	a[1] = null;
		if( pl.research.length == 0 )		a[2] = null;
		if( pl.attacks.length == 0 )		a[3] = null;

		var id = 0;
		var n = 0;
		for( i in 0...4 ){
			if(a[i]!=null){
				Inter.me.activeIcon(i,a[i]);
				n++;
			}
		}
		*/
	}

	// PANEL
	public function displayInfo(){
	}
	
	public function displayYard(){
		new inter.pan.Yard(pl);
	}
	
	public function displaySearch(){
		var counter = Game.me.research[0]._counter;
		new inter.pan.Research();
	}

	// INTERRACT
	var cursor:flash.MovieClip;
	
	public function initDalleBuildActions(){
		removeDalleActions();
		for( d in dalles ){
			if( d.bt != null )	Trick.butAction( d.ground.but, callback(clickBat,d), callback(rOverBat,d), callback(rOutBat,d) );
			else if( d.link!=null )	Trick.butAction( d.ground.but, callback(clickBat,d.link), callback(rOverBat,d.link), callback(rOutBat,d.link) );
			else			Trick.butAction( d.ground.but, callback(clickDalle,d), callback(rOverDalle,d), callback(rOutDalle,d) );
		}
	}
	
	public function removeDalleActions(){
		for( d in dalles )Trick.butKill(d.ground.but);
	}
	
	function clickDalle(d:Dalle){
		removeDalleActions();
		new inter.pan.ConstructBuilding(pl,d.x,d.y,d.flEther);
	}
	
	function rOverDalle(d:Dalle){
		cursor = d.dm.attach("mcDalleSelection",DP_SELECTION);
		cursor.blendMode = "add";
		//d.blendMode = "overlay";
	}
	
	function rOutDalle(d:Dalle){
		d.dm.clear(DP_SELECTION);
		cursor = null;
	}

	function clickBat(d:Dalle){
		new inter.pan.Building(d.bt,d.x,d.y,d.counter);
		/*
		showGlass(callback(hideBatIcons,d));
		var a = [ callback(displayBatInfo,d), callback(removeBat,d) ];
		var id = 0;
		var ww = (a.length-1)*26;
		for( f in a ){
			var c = ( id/(a.length-1) )*2-1;
			var mc = dm.attach("mcBatBut",DP_ICONS2);
			mc._x = d._x + c*ww*0.5;
			mc._y = d._y + d.lifeBar._y + 25;
			mc.gotoAndStop(id+1);
			var appear = function(){ mc.filters = [];Filt.glow(mc,4,4,0xFFFFFF); Col.setColor(mc,0,50); };
			var vanish = function(){ mc.filters = []; Col.setColor(mc,0,0); };
			Trick.butAction( mc, f, appear , vanish );
			id++;
		}
		*/
		rOutBat(d);
	}
	
	function rOverBat(d:Dalle){
		d.bat.filters = [];
		Filt.glow(d.bat,3,4,0xFFFFFF);
		Filt.glow(d.bat,12,1,0xFFFFFF);
		showLifeBar(d);
	}
	
	function rOutBat(d:Dalle){
		d.bat.filters = [];
		if(!flView)d.lifeBar.removeMovieClip();
	}
	
	public function removeCursor(){
		for(d in dalles )d.dm.clear(DP_SELECTION);
	}

	function showLifeBar(d:Dalle){
		d.lifeBar.removeMovieClip();
		var b = BuildingLogic.get(d.bt);
		var c = d.life / b.life;
		//if(Game.flDebug)c= Math.min(Math.random()*1.5,1);
		d.lifeBar = d.dm.attach("mcBatLifeBar",5);
		d.lifeBar.smc._xscale = c*100;
		d.lifeBar._x = 0;
		d.lifeBar._y = -46;
		if( Cs.isBig(d.bt) ) d.lifeBar._y -= 24;
		var col = 0x00FF00;
		if( c<1 )	col = 0xFFFF00;
		if( c<0.5 )	col = 0xFF8800;
		if( c<0.2 )	col = 0xFF0000;
		Col.setColor(d.lifeBar.smc,col);
		var field:flash.TextField = Reflect.field(d.lifeBar,"_field");
		field.text = Lang.BUILDING[Type.enumIndex(d.bt)];
	}

	// FIRST PLACE
	var ghost:Dalle;
	
	public function initBuildPalaceActions(){
		for( d in dalles ){
			if(!d.flEther){
				Trick.butAction( d.ground.but, callback(placePalace,d), callback(displayPalace,d),hideGhost );
			}
		}
	}
	
	function placePalace(d:Dalle){
		if(ghost==null)return;
		Api.settleDown(pl.id,ghost.x,ghost.y);
		removeDalleActions();
	}
	
	function displayPalace(d:Dalle){
		showGhost([TOWNHALL,TEMPLE][Game.me.raceId],d);
		/*
		var p = Cs.getBigPoint(this,d.x,d.y);
		var bat = getBat(p.x,p.y);
		bat.gotoAndStop(Type.enumIndex([TOWNHALL,TEMPLE][Game.me.raceId])+2 );
		ghost = getDalle(p.x,p.y);
		ghost.bat._alpha = 30;
		*/
	}

	// GHOST
	public function showGhost(bt:_Bld,d:Dalle){
		var p = {x:d.x,y:d.y};
		if( Cs.isBig (bt) ) p = Cs.getBigPoint(this,d.x,d.y);
		var bat = getBat(p.x,p.y);
		bat.gotoAndStop(Type.enumIndex(bt)+2 );
		ghost = getDalle(p.x,p.y);
		ghost.bat._alpha = 60;
		cursor._visible = false;
	}
	
	public function hideGhost(){
		cleanDalle(ghost);
		ghost = null;
		cursor._visible = true;
	}

	// GET
	public function getDalle(x,y){
		for (d in dalles )if(d.x==x && d.y==y)return d;
		trace("ERROR DALLE NOT FOUND ["+x+":"+y+"]");
		return null;
	}
	
	public function getLarge(x,y){
		var a = [[0,0],[0,1],[1,0],[1,1]];
		for( dec in a ){
			var flOk = true;
			for( dc in a ){
				var px = x+dec[0]-dc[0];
				var py = y+dec[1]-dc[1];
				var d = getDalle(px,py);
				if( d==null || d.bt != null ){
					flOk = false;
					break;
				}
			}
			if( flOk ) return { x:x+dec[0], y:y+dec[1] };
		}
		return null;
	}

	// ACTIVE
	public function active(){
		checkOwn();
		root._visible = true;
		Inter.me.step = Planet;
		if(flConstruct){
			var b = new inter.Board(0);
			loadDefaultPanel();
		}else{
			var p = new inter.pan.War(pl);
			Inter.me.board.setSkin(3);
		}
		attachLinks();
	}
	
	function checkOwn(){
		flOwn = pl.owner == Game.me.playerId;
		flConstruct = flOwn || pl.owner == null;
	}

	//
	function showGlass(f){
		mcGlass = dm.attach("mcSquare",DP_GLASS);
		mcGlass._xscale = Cs.mcw;
		mcGlass._yscale = Cs.mch;
		mcGlass._alpha = 10;
		mcGlass.useHandCursor = false;
		mcGlass.onPress = f;
	}
	
	function hideGlass(){
		mcGlass.removeMovieClip();
	}

	// VIEW
	
	function showView(){
		flView = true;
		for( d in dalles ){
			if( d.bt != null ){
				showLifeBar(d);
			}
		}
	}
	
	function hideView(){
		flView = false;
		for( d in dalles ){
			if( d.bt != null ){
				d.lifeBar.removeMovieClip();
			}
		}
	}

	// BOARD
	public function loadDefaultPanel(){
		new inter.pan.War(pl);

	}

	// FIGHT
	public function askFight(id){
		if(Inter.me.isReady())
			Api.getFight(id);
	}
	
	public function loadFight(data:DataFight){
		Inter.me.board.root._visible = false;
		fight = new Fight(this,data);
		Inter.me.board.root._visible = true;
		Inter.me.board.vanish();

	}
	
	public function endFight(){
		fight.remove();
		fight = null;
		maj();
		active();
	}

	// LINKS
	var links:Array<IsleLink>;
	var move:{old:flash.MovieClip,bmp:flash.display.BitmapData,c:Float,x:Float,y:Float,parts:Array<SkyPart>};

	public function attachLinks(){
		while(links.length>0)links.pop().removeMovieClip();
		links = [];
		var a = [];
		var data = Game.me.world.data;
		for( d in data._planets ){
			//if(d._owner == Game.me.playerId && d._id != pl.id)a.push(d._id);
			var mpl = Game.me.getPlanet(d._id);
			var dx = mpl.x - pl.x;
			var dy = mpl.y - pl.y;
			var dist = Math.sqrt(dx*dx+dy*dy);

			if( d._id != pl.id && dist < 400 && Param.is(_ParamFlag.PAR_FAST_LINK)){
				if( d._owner == Game.me.playerId || !Param.is(_ParamFlag.PAR_FAST_LINK_SELF) ){
					a.push({pl:mpl,dist:dist});
				}
			}
		}

		for( o in a ){
			var mc:IsleLink = cast dm.attach("mcLinkArrow",DP_LINKS);
			mc.pl = Game.me.getPlanet(o.pl.id);
			//var str = Game.me.getPlanetName(o.pl.id);
			//if(o.dist>300)str = "+ "+str+" +";
			mc.smc.gotoAndStop( (o.dist<300)?1:2 );
			var color = 0xFFFFFF;
			if( mc.pl.owner!=null )color = Cs.COLORS[Game.me.getPlayer(mc.pl.owner)._color];
			Inter.me.makeHint(mc,Game.me.getPlanetName(o.pl.id));
			var dx = mc.pl.x - pl.x;
			var dy = mc.pl.y - pl.y;
			var an = Math.atan2(dy,dx);
			//var ww = Inter.me.width*0.5;
			var ww = (Cs.mcw -inter.Board.WIDTH)*0.5;
			var hh = Inter.me.height*0.5;
			mc._rotation = an/0.0174;
			Filt.glow(mc,2,4,0);
			Col.setColor(mc.smc,color);
			mc._x = ww;
			mc._y = hh;
			var ma = 24;
			var p = Trick.squarize(an,ww-ma,hh-ma);
			mc._x += p.x;
			mc._y += p.y;
			// ACTION
			mc.onPress = callback( linkTo, mc.pl );
			// RECAL
			recalLink(mc);
			// ADD ( BEFORE RECAL ! )
			links.push(mc);
		}
		/*
		// RECAL
		var to = 0;
		while(to++<100){
			for( i in 0...links.length){
				var mc = links[i];
				for( n in i+1...links.length ){

				}
			}
		}
		*/

		/*
		for( i in 0...100 ){
			var p = Trick.squarize(i*6.28/100,100,100);
			var mc = dm.attach("mcProjectile",DP_LINKS);
			mc._x = Inter.me.width*0.5+p.x;
			mc._y = Inter.me.height*0.5+p.y;
		}
		*/
	}
	
	function linkTo(p:Planet){
		var dx = p.x - pl.x;
		var dy = p.y - pl.y;
		var bmp = new flash.display.BitmapData( Std.int(Inter.me.width), Std.int(Inter.me.height+160),true,0x00FF0000 );
		bmp.draw(mcIsle);
		var mc = dm.empty(DP_GROUND);
		mc.attachBitmap(bmp,0);
		var dist = 12.0;
		move = {old:mc,bmp:bmp,c:0.0,x:dx*dist,y:dy*dist,parts:[]};
		//
		cleanAll();
		setPlanet(p);
		//
		mcIsle._x = move.x;
		mcIsle._y = move.y;
		// PARTS
		var max = 60;
		for( i in 0...max ){
			var c = 0.05+Math.pow(i/max,4)*1.25;
			//var c = 0.05+Math.pow(i/max,1)*0.5;
			var type = 0;
			if( (c>0.3 && i%2==0 ) || c>0.8 )type = 1;

			var mc:SkyPart = cast dm.attach(type==0?"mcNearLine":"fxCloud",(c<1)?DP_BG:DP_GROUND);
			mc._visible = false;
			mc.c = c;
			mc.type = type;
			mc._xscale = mc._yscale = mc.c*150;
			move.parts.push(mc);
			switch(type){
				case 0:
					mc._x = Math.random()*Cs.mcw;
					mc._y = Math.random()*Cs.mch;
				case 1:
					mc._alpha = 0;
					Col.setPercentColor(mc,5,Col.objToCol(Col.getRainbow(Math.random())));
					mc._rotation = Math.random()*360;
					var rx = mc._width*0.5;
					var ry = mc._height*0.5;
					mc._x = rx + Math.random()*(Cs.mcw+rx*2);
					mc._y = ry + Math.random()*(Cs.mch+ry*2);
			}
		}
	}
	
	function updateLink(){
		var ox = mcIsle._x;
		var oy = mcIsle._y;
		if(mcIsle._visible!=true){
			ox = 0;
			oy = 0;
		}
		var speed = 0.025;
		if( flash.Key.isDown(flash.Key.SPACE) && Game.flDebug ) speed = 0.002;
		move.c = Math.min(move.c+speed,1);
		var c = move.c;
		var c = 0.5-Math.cos(c*3.14)*0.5;
		mcIsle._x = move.x*(1-c);
		mcIsle._y = move.y*(1-c);
		move.old._x = -move.x*c;
		move.old._y = -move.y*c;
		var vx = mcIsle._x - ox;
		var vy = mcIsle._y - oy;
		var a = Math.atan2(vy,vx);
		var dist = Math.sqrt(vx*vx+vy*vy);
		// PARTS
		var ma = 10;
		for( mc in move.parts ){
			mc._x += vx*mc.c;
			mc._y += vy*mc.c;
			mc._visible = true;
			//mc._x = ((mc._x-ma)%(Cs.mcw+2*ma))+ma;
			//mc._y = ((mc._y-ma)%(Cs.mch+2*ma))+ma;
			//mc._x = Num.sMod(mc._x,Cs.mcw);
			//mc._y = Num.sMod(mc._y,Cs.mch);
			switch(mc.type){
				case 0:
					mc._xscale = dist*mc.c;
					mc._rotation = a/0.0174;
					mc._x = Num.sMod(mc._x,Cs.mcw);
					mc._y = Num.sMod(mc._y,Cs.mch);

				case 1:
					var ma = mc._width;
					mc._alpha = dist*1.2;
					if(mc._x<ma)	mc._x += Cs.mcw+ma*2;
					if(mc._y<ma)	mc._y += Cs.mch+ma*2;
					if(mc._x>Cs.mcw+ma)	mc._x -= Cs.mcw+ma*2;
					if(mc._y>Cs.mch+ma)	mc._y -= Cs.mch+ma*2;
			}
		}

		// BG
		var bsp = 0.02;
		bg._x += vx*bsp;
		bg._y += vy*bsp;
		if( move.c == 1 ){
			while(move.parts.length>0)move.parts.pop().removeMovieClip();
			move.old.removeMovieClip();
			move.bmp.dispose();
			active();
			move = null;
		}
	}

	function recalLink(mc:IsleLink){
		// COIN
		var lx = 70+mc.smc._width*0.5;
		var ly = 48;
		if( mc._x<lx && mc._y<ly ){
			if( mc._y < 24 )	mc._x = lx;
			else			mc._y = ly;
		}
		// OTHERS
		var sens = mc._y<Inter.me.height*0.5?1:-1;
		var to = 0;
		while(to++<100){
			var flHit = false;
			for( omc in links ){
				var dx = mc._x - omc._x;
				var dy = mc._y - omc._y;
				if( Math.abs(dx) < 18 && Math.abs(dy) < 18 ){
					flHit = true;
					break;
				}
			}
			if( !flHit )return;
			mc._y += 2*sens;

		}
	}

	// CLEAN
	function cleanAll(){
		while(links.length>0)links.pop().removeMovieClip();
		Inter.me.board.vanish();
		mcIsle.removeMovieClip();
	}

	// TOOLS
	inline public static function getX(px,py){
		return (Cs.mcw-inter.Board.WIDTH)*0.5 + (px-py)*DX;
	}
	
	inline public static function getY(px,py){
		return -160+(px+py)*DY;
	}

	// LEAVE
	public function instantRemove(){
		remove();
		bg.removeMovieClip();
		Inter.me.isle = null;
	}
	
	public function remove(){
		fight.remove();
		Inter.me.board.vanish();
		bg.onPress = null;
		bg.useHandCursor = null;
		root.removeMovieClip();
	}
	
	public function leave(){
		remove();
		Inter.me.initZoom(-1);
	}

	// FX
	var blobDecal:Float;
	function fxBlob(){
		if(blobDecal==null)blobDecal =0;
		blobDecal = (blobDecal+11)%628;
		for( mc in dalles ){
			mc._x = getX(mc.x,mc.y);
			mc._y = getY(mc.x,mc.y);
			var a = (blobDecal+(mc.x+mc.y)*20)*0.01;
			mc._y += Math.sin(a)*5;
		}
	}
//{
}
