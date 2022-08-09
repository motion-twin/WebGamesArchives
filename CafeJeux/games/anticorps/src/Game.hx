import Common;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;

import flash.Mouse;

typedef Mine = {>flash.MovieClip,x:Int,y:Int,flActive:Bool}
typedef Zone = {>flash.MovieClip,dm:mt.DepthManager}
//typedef MsgInter =  {>flash.MovieClip,flGo:Bool,field:flash.TextField}
typedef MsgInter =  {>flash.MovieClip,fieldName:flash.TextField,fieldDesc:flash.TextField,timer:Int,icon:flash.MovieClip}
typedef Cell = {>Phys,c:Float}

class Game implements MMGame<Msg> {//}

	static public var FL_DEBUG = false;
	static public var FL_PLACE = true;

	static public var DP_BG = 	0;
	static public var DP_MAP = 	1;
	static public var DP_INTER = 	2;

	static public var DP_BACK = 		0;
	static public var DP_ZONE = 		1;
	static public var DP_BACK_PARTS = 	2;
	static public var DP_LEVEL = 		3;
	static public var DP_MINES = 		4;
	static public var DP_COSMO = 		5;
	static public var DP_SHOTS = 		7;
	static public var DP_PARTS = 		9;
	static public var DP_MENU = 		10;
	static public var DP_DEBUG = 		11;

	public var flFreeCam:Bool;
	public var flSpaceView:Bool;
	public var flMain:Bool;
	public var flFirstUpkeep:Bool;
	public var flClick:Bool;
	public var flReady:Bool;
	public var flMouseView:Bool;

	public var mid:Int;
	public var mapWidth:Int;
	public var mapHeight:Int;
	public var mapType:Int;
	public var colorId:Int;
	public var miniMapScaleIndex:Int;
	public var mouseViewCoef:Float;

	public var bot:Float;
	public var wind:Float;
	public var cellDecal:Float;

	public var cosmos:Array<pix.Cosmo>;
	public var myCosmos:Array<pix.Cosmo>;
	public var oppCosmos:Array<pix.Cosmo>;
	public var ejectList:Array<Pix>;
	public var currentCosmo:pix.Cosmo;

	public var anims:Array<{function update():Void;}>;
	public var parts:Array<{function update():Void;}>;
	public var mods:Array<Mode>;
	public var moveStack:Array<Int>;
	public var mines:Array<Mine>;
	public var cells:Array<Cell>;


	public var miniMap:{>flash.MovieClip,dm:mt.DepthManager,sc:Float,ma:Float};
	public var map:flash.MovieClip;
	public var mapBmp:flash.display.BitmapData;
	public var glueBmp:flash.display.BitmapData;
	public var layGlue:{>flash.MovieClip,dm:mt.DepthManager};
	public var rand:mt.OldRandSeed;

	public var mcStartPos:flash.MovieClip;
	public var misCol:{mapBmp:flash.display.BitmapData};
	public var mcCosmoBar :{>flash.MovieClip,list:Array<flash.MovieClip>,group:flash.MovieClip};
	public var mcWeaponTip :MsgInter;
	public var mcMsg : MsgInter;
	public var mcHelpBox : {>flash.MovieClip,field:flash.TextField,cross:flash.MovieClip,last:String};
	var focus:{x:Float,y:Float};
	public var zones:Array<Zone>;

	public var endAnim:Void->Void;

	var so:flash.SharedObject;
	public var params:{flTips:Bool};

	var mcTracer :{>flash.MovieClip,field:flash.TextField};
	var debugLayer :flash.MovieClip;
	var mcDebugCursor :flash.MovieClip;
	var mcDebugAngle :flash.MovieClip;
	public var bg : flash.MovieClip;
	public var root : flash.MovieClip;
	public var dm : mt.DepthManager;
	public var mdm : mt.DepthManager;
	public var ldm : mt.DepthManager;
	public var zdm : mt.DepthManager;
	static public var me:Game;

	function new( base : flash.MovieClip ) {
		root = base;
		me = this;
		dm = new mt.DepthManager(root);
		dm.attach("mcBgBg",DP_BG);
		bg = dm.attach("mcBg",DP_BG);
		bg.cacheAsBitmap = true;

		flFreeCam  = false;

		bot = Cs.mch;

		anims = [];
		parts = [];
		mods = [];
		flReady = true;
		Game.me.flSpaceView = false;

		initCookie();

		// when ready
		MMApi.lockMessages(false);

		//
		initMouseListener();
		initKeyListener();
		// DEBUG
		//initTracer();


	}

	function initCookie(){
		so = flash.SharedObject.getLocal("fwanRace");
		params = cast so.data.params;
		if( params == null ){
			params = {flTips:true};
			so.data.params = params;
			so.flush();
		}


	}

	// UPDATE
	public function main() {

		//if(flash.Key.isDown(flash.Key.ENTER))root._visible = false;

		var max = 1;
		if( MMApi.isReconnecting() )max = 20;
		for(i in 0...max )loop();


	}

	function loop(){

		mt.Timer.tmod = 1;

		//if(flash.Key.isDown(flash.Key.SPACE))unify();


		//MMApi.print(Sprite.spriteList.length);

		if( !flReady ){
			if(isReady()){

				if(endAnim!=null){
					//trace("endAnim!");
					endAnim();
					endAnim = null;
				}
				if(currentCosmo.flWaitHand){
					currentCosmo.giveHand();
				}
				setReady(true);
			}
		}

		for( c in cosmos )c.main();





		if(!MMApi.isReconnecting()){
			updateSprites();
			updateMap();
			updateWeaponTip();
			updateCells();

		}
		updateAnims();
		updateMods();


		MMApi.sendQueue();

		//mcTracer.field.text = currentCosmo.x+";"+currentCosmo.y;
	}


	function updateSprites(){
		var list = Sprite.spriteList.copy();
		for( sp in list )sp.update();
		var list = parts.copy();
		for( sp in list )sp.update();
	}
	function updateAnims(){
		var list = anims.copy();
		for( sp in list )sp.update();
	}
	function updateMods(){
		var list = mods.copy();
		for( mod in list )mod.update();
	}

	//
	public function unify(){
		misCol.mapBmp = mapBmp.clone();
		var brush = dm.attach("mcHole",0);

		var sum = 0.0;

		for( c in cosmos ){
			c.cheese();
			var m = new flash.geom.Matrix();
			var sc = (c.ray)*2 / 100 ;
			m.scale(sc,sc);
			m.translate(c.x+c.head.x,c.y+c.head.y);
			misCol.mapBmp.draw(brush,m);
			sum += c.x+c.head.x + c.y+c.head.y;
		}
		brush.removeMovieClip();

		//MMApi.logMessage("unify check size:"+sum);
		//trace("unify check size:"+sum);

		//debugLayer.attachBitmap(misCol.mapBmp,0);


	}

	// MOD
	public function setMod(m:Mod,?cosmo):Mode{

		if(cosmo==null)cosmo = currentCosmo;

		switch(m){
			case PlaceCosmo:	return new mod.Place();
			case PlayStart:		return new mod.Start(cosmo);
			case Watch:		return new mod.Watch(cosmo);
			case Move:		return new mod.ac.Move(cosmo);
			case Bazooka:		return new mod.ac.Missile(cosmo,0);
			case Grenade:		return new mod.ac.Missile(cosmo,3);
			case Obus:		return new mod.ac.Missile(cosmo,4);
			case MedicMissile:	return new mod.ac.Missile(cosmo,7);
			case Gaz:		return new mod.ac.Missile(cosmo,8);
			case Medecine:		return new mod.ac.Brawl(cosmo,9);
			case Gun:		return new mod.ac.Missile(cosmo,2,true);
			case Shotgun:		return new mod.ac.Missile(cosmo, 11, true);
			case Mine:		return new mod.ac.Drop(cosmo,1,true);
			case Sword:		return new mod.ac.Brawl(cosmo, 6);
			case Ram:		return new mod.ac.Missile(cosmo, 10, true);
			case Pass:		cosmo.next(); return null;
			case Cover:		MMApi.queueMessage(TakeCover);cosmo.next();return null;
			default:		return null;
		}
	}

	// MAP
	function initMap(type){




		// CELLULE

		var max = 20;
		var mapLevel = 18;

		if(FL_DEBUG){
			max = 2;
			mapLevel = 1;
		}

		cells = [];
		for( i in 0...max ){
			var c = i/mapLevel;
			if( i == mapLevel ){
				map = dm.empty(DP_MAP);
			}else{
				var p = initCell(c);
				if(i>mapLevel)p.setScale(p.scale*1.5);
			}

		}



		// MAP
		mid = type;
		mdm = new mt.DepthManager(map);

		debugLayer = mdm.empty(DP_DEBUG);	// DEBUG

		var mapInfo = Cs.MAP_INFOS[type];
		mapWidth = mapInfo.width;
		mapHeight = mapInfo.height;
		mapType = mapInfo.type;

		mapBmp = new flash.display.BitmapData(mapWidth,mapHeight,true,0);
		var mc = dm.attach("mcLevel",0);
		mc.gotoAndStop(type+1);
		mapBmp.draw(mc,new flash.geom.Matrix());
		mc.removeMovieClip();
		var lvl = mdm.empty(DP_LEVEL);
		ldm = new mt.DepthManager(lvl);
		ldm.empty(1).attachBitmap(mapBmp,0);

		Filt.glow(lvl,2,2,0);
		misCol = {mapBmp:mapBmp.clone()};

		// GLUE
		glueBmp = new flash.display.BitmapData(mapWidth,mapHeight,true,0);
		var mc = dm.attach("mcGlue",0);
		mc.gotoAndStop(type+1);
		glueBmp.draw(mc,new flash.geom.Matrix());
		mc.removeMovieClip();

		layGlue = cast mdm.empty(DP_PARTS);
		layGlue.dm = new mt.DepthManager(layGlue);
		Filt.glow( layGlue,5,2,0xFFFF66,true);
		//Filt.glow( layGlue,2,2,0xAA6600);

		//map._xscale = map._yscale = 40;
	}
	public function isFree(x,y){
		var pix = mapBmp.getPixel32(x,y);
		var col = Col.colToObj32(pix);
		return col.a < 50 || y>mapHeight;
	}
	public function isGlue(x,y){
		var pix = glueBmp.getPixel32(x,y);
		var col = Col.colToObj32(pix);
		return col.a > 0;
	}
	public function updateMap(){


		// CAMERA CONTROLE
		if(flSpaceView){
			var c = 0.1;
			var dx = (root._xmouse-Cs.mcw*0.5)*c;
			var dy = (root._ymouse-Cs.mcw*0.5)*c;

			moveMap(-dx,-dy);

			//map._x -= dx;
			//map._y -= dy;
			//var m = 0;
			//if(mapType==0)m=150;
			//recalMap(m);
			return;
		}


		if(focus==null)return;

		var tx =  Cs.mcw*0.5 - focus.x;
		var ty =  Cs.mch*0.5 - focus.y;
		var cc = 0.3;

		if( mouseViewCoef!=null ){

			tx -= (root._xmouse-Cs.mcw*0.5)*mouseViewCoef;
			ty -= (root._ymouse-Cs.mch*0.5)*mouseViewCoef;
			if( !flMouseView ){
				mouseViewCoef*=0.8;
				if(mouseViewCoef<0.1)mouseViewCoef=null;
			}
		}


		moveMap( (tx-map._x)*cc, (ty-map._y)*cc );
		//if(mapType==1)recalMap(0);

		/*
		map._x += (tx-map._x)*cc;
		map._y += (ty-map._y)*cc;
		if(mapType==1)recalMap(0);
		*/


	}
	function moveMap(dx,dy){
		//if( flFree == null )flFree = false;

		var nx = map._x+dx;
		var ny = map._y+dy;

		var m = 150;
		if(mapType==1)m = 0;


		if( !flFreeCam || mapType == 1 ){
			nx = Num.mm( Cs.mcw-(mapWidth+m), nx, m );
			ny = Num.mm( Cs.mch-(mapHeight+m), ny, m );
			dx = nx-map._x;
			dy = ny-map._y;
		}



		var cm = 0.2;
		map._x += dx;
		map._y += dy;
		for( c in cells ){
			var coef = cm+c.c*(1-cm);
			c.x += coef*dx;
			c.y += coef*dy;
		}

		bg._x += dx*cm;
		bg._y += dy*cm;


	}

	public function setFocus(trg){
		focus = trg;
	}
	public function makeHole(x,y,ray:Float,?flFx){
		if(flFx==null)flFx=true;
		var list = [];
		var max = Std.int(Math.pow(ray,2)*0.02);
		if( MMApi.isReconnecting() ) max = 0;
		for( i in 0...max ){

			var a = Math.random()*6.28;
			var dist = Math.random()*ray;
			var dx = Math.cos(a)*dist;
			var dy = Math.sin(a)*dist;
			var cs = (1-dist/ray)*0.2;

			var px = Std.int(x+dx);
			var py = Std.int(y+dy);

			if(!isFree(px,py)){


				var p = getDirt(px,py);
				p.vx = dx*cs;
				p.vy = dy*cs - (2+Math.random()*2);


				/*
				if(i%3==0){

					var p = new pix.Part(mdm.attach("partDirt",DP_PARTS));
					p.x = px;
					p.y = py;
					p.vx = dx*cs;
					p.vy = dy*cs;
					p.timer = 50+Math.random()*20;
					p.weight = 0.1+Math.random()*0.3;
					p.setScale(50+p.weight*100);
					p.colFrict = 0.6;
					Col.setColor(p.root, mapBmp.getPixel32(px,py) );
					p.updatePos();

				}else{
					var p = new Phys(mdm.attach("partDirt",DP_PARTS));
					p.x = px;
					p.y = py;
					p.vx = dx*cs;
					p.vy = dy*cs;
					p.timer = 10+Math.random()*10;
					p.weight = 0.1+Math.random()*0.3;
					p.setScale(50+p.weight*100);
					p.fadeType = 0;
					Col.setColor(p.root, mapBmp.getPixel32(px,py) );
					p.updatePos();

				}
				*/
			}
		}


		// MINES
		for( mc in mines ){
			var dx = mc._x-x;
			var dy = mc._y-y;
			var dist = Math.sqrt(dx*dx+dy*dy);
			if( dist < Cs.MINE_RAY+ray )explodeMine(mc);
		}

		// HOLE
		var brush = Game.me.dm.attach("mcHole",0);
		var m = new flash.geom.Matrix();
		var sc = ray*2/100;
		m.scale(sc,sc);
		m.translate(x,y);
		Game.me.mapBmp.draw(brush,m,null,"erase");
		brush.removeMovieClip();

		// FX
		if(flFx)fxSphere(x,y,sc*100*0.9);

	}

	public function mouseSideScroll(){
		var speed = 20;
		var xm = root._xmouse;
		var ym = root._ymouse;
		var m = 40;
		var cx = 0.0;
		var cy = 0.0;
		if( xm<m )cx = (1-xm/m);
		if( ym<m )cy = (1-ym/m);
		if( xm>Cs.mcw-m )cx = -(1-(Cs.mcw-xm)/m);
		if( ym>Cs.mch-m )cy = -(1-(Cs.mch-ym)/m);

		var sm = 80;

		moveMap(cx*speed,cy*speed);
		//if(mapType==1)recalMap(sm);

		/*
		map._x = Num.mm( -((mapWidth+sm)-Cs.mcw), map._x+cx*speed, sm );
		map._y = Num.mm( -((mapHeight+sm)-Cs.mcw), map._y+cy*speed, sm );
		*/
	}


	// DAMAGE
	public function rayDamage( x:Float, y:Float, damage:Float, radiusDamage:Float, radiusDamageBase:Float, eject:Float, ?flHeal ){
		var list = [];

		var rseed = new mt.OldRandSeed(Std.int(x+y));

		//MMApi.logMessage("rayDamage("+x+";"+y+")");

		// COSMOS
		var clist = Game.me.cosmos.copy();
		var ejected = [];
		for( c in clist ){
			var dec = 2;
			var dx = (c.x+Math.cos(c.ga)*dec-x);
			var dy = (c.y+Math.sin(c.ga)*dec-y);

			var ray = radiusDamage+c.ray;

			if( Math.abs(dx)< ray && Math.abs(dy)< ray ){
				var dist = Math.sqrt(dx*dx+dy*dy);
				if( dist < radiusDamage ){
					var a = Math.atan2(dy,dx);
					a += (rseed.rand()*2-1)*0.2;
					var coef = Num.mm( 0, 1-(dist-radiusDamageBase)/ray, 1 );
					if(eject>0){
						c.setState(Fly);
						c.vx = Math.cos(a)*coef*eject;
						c.vy = Math.sin(a)*coef*eject;
						ejected.push( cast c);
					}
					var n  = Std.int(coef*damage);

					if(flHeal){
						c.heal(n);
					}else{
						c.incHp(-n);
					}

				}
				list.push(c);
			}
		}

		if(ejected!=null)ejectList = ejected;
		return list;
	}

	// MINI MAP
	function initMiniMap(){
		if(miniMapScaleIndex==null)miniMapScaleIndex=0;


		var sc = Cs.MINIMAP_SCALES[miniMapScaleIndex];
		var ma = 3;

		miniMap = cast dm.empty(DP_INTER);
		var dm = new mt.DepthManager(miniMap);

		// BASE
		var mc = dm.empty(0);
		var ddm = new mt.DepthManager(mc);
		mc._xscale = 100*sc;
		mc._yscale = 100*sc;

		// MASK
		var mask = dm.attach("mcWhiteSquare",1);
		mask._xscale = mapWidth*sc;
		mask._yscale = mapHeight*sc;
		mc.setMask(mask);


		// BG
		var mc = ddm.attach("mcWhiteSquare",0);
		mc._xscale = mapWidth;
		mc._yscale = mapHeight;
		mc._alpha = 30;

		// MAP
		var mc = ddm.empty(0);
		mc.attachBitmap(mapBmp,0);
		Col.setPercentColor(mc,100,0xFFFFFF);
		mc._alpha = 70;

		// CADRE
		var mc = dm.attach("mcCadre",1);
		mc._xscale = mapWidth*sc;
		mc._yscale = mapHeight*sc;
		mc._alpha = 100;

		miniMap.dm = ddm;
		miniMap.sc = sc;
		miniMap.ma = ma;
		updateMiniMap();



	}
	function updateMiniMap(){
		miniMap._x = miniMap.ma;
		miniMap._y = bot - (miniMap.ma+mapHeight*miniMap.sc);
		miniMap.onPress = callback(cycleMiniMap);
	}
	function cycleMiniMap(){
		flClick = false;
		miniMapScaleIndex = (miniMapScaleIndex+1)%Cs.MINIMAP_SCALES.length;
		miniMap.removeMovieClip();
		initMiniMap();
		for(c in cosmos)c.initMapPos(c.colorId+1);
	}


	// START
		// DIRECT
	function initCosmos(a:Array<Array<Int>>){


		//var types = [CosmoScout,CosmoSoldat,CosmoNinja];
		//var types = [CosmoSoldat,CosmoSoldat,CosmoSoldat];
		var types = [CosmoSoldat,CosmoTank,CosmoScout];

		var pos = [ [47,257],[79,235],[130,242], [463,360],[425,354],[388,362]];
		var max = pos.length;
		for( i in 0...max ){
			var p = pos[i];
			var flMine = i<max*0.5;
			if( !flMain )flMine = !flMine;
			spawnCosmo( p[0], p[1], types[i%3], flMine );
		}
	}
	function spawnCosmo(?x,?y,?type,?flMine){
		if( x == null) x = Std.int(map._xmouse);
		if( y == null) y = Std.int(map._ymouse);
		if( type == null ) type = CosmoSoldat;
		if( flMine == null ) flMine = true;

		var cosmo = new pix.Cosmo(mdm.empty(DP_COSMO),type,flMine);
		cosmo.x = x;
		cosmo.y = y;
		cosmo.grip();

		if(cosmo.gid==null ){
			if( !isFree(cosmo.x,cosmo.y) ){
				cosmo.kill();
			}else{
				cosmo.setState(Fly);
			}
		}else{
			cosmo.setState(Ground);
		}

	}

		// CHOICE
	function initCosmoBar(){
		mcCosmoBar = cast dm.attach( "mcCosmoBar", DP_INTER );
		mcCosmoBar.smc.gotoAndStop(colorId+1);
		mcCosmoBar._y = -31;
		var dm = new mt.DepthManager(mcCosmoBar);

		mcCosmoBar.group = dm.empty(1);
		var gdm = new mt.DepthManager(mcCosmoBar.group);

		// LIST
		mcCosmoBar.list = [];
		for( i in 0...Cs.COSMO_MAX ){

			//var id = Std.int(Math.min(i-2,0));

			var slot = dm.attach("mcCosmoSlot",0);
			slot._x = (i+0.5)*(Cs.mcw/Cs.COSMO_MAX);
			slot._y = 14;
			slot.gotoAndStop(colorId+1);

			var mc = gdm.empty(0);
			mc._x = slot._x;
			mc._y = slot._y;
			mc._xscale= mc._yscale = 140;
			mcCosmoBar.list.push(mc);
			Filt.glow(mc,2,4,0);

			var ddm  = new mt.DepthManager(mc);
			var head = ddm.attach("mcHead",0);
			head.gotoAndStop(i+1);
			for( i in 0...2 ){
				var foot = ddm.attach("mcPod",0);
				foot.gotoAndStop(colorId*2+i+1);
				foot._rotation = -90;
				foot._y = 8;
				foot._x = 3.5*(i*2-1);
				if(i==0)ddm.over(head);
			}
		}

		// ZONES


	}
	function initZones(){
		zones =[];
		for( i in 0...2 ){
			var mc:Zone = cast mdm.empty(DP_ZONE);
			mc.blendMode = "layer";
			mc._alpha = 50;
			//Col.setColor( mc, [0xFF0000,0x0000FF][i] );
			mc.dm = new mt.DepthManager(mc);
			zones.push(mc);
			Filt.glow( mc, 4, 4, 0xFFFFFF );
		}
	}
	function addZone(cosmo:pix.Cosmo){
		var mc = zones[cosmo.colorId];
		var round = mc.dm.attach("mcZoneRound",0);
		round._x = cosmo.x;
		round._y = cosmo.y;
		round._xscale = cosmo.startZone*2;
		round._yscale = round._xscale;
		round.gotoAndStop(cosmo.colorId+1);
	}


	// UPKEEP
	function upkeep(){

		setWind();

		if(flFirstUpkeep){
			mcCosmoBar.removeMovieClip();
			while(zones.length>0)zones.pop().removeMovieClip();
			flFirstUpkeep = false;
		}
		activeMines();

		// POISON
		for( c in cosmos )if(c.flPoison)c.incHp(-5);

		// VICTORY
		checkVictory();

	}

	// MINE
	public function addMine(x,y,ga:Float,flMine){
		if(mines==null)mines = [];
		var mc:Mine = cast ldm.attach("mcMine",DP_MINES);
		mc._x = x;
		mc._y = y;
		mc._rotation = ga/0.0174;
		mc._visible = flMine;
		mc.flActive = false;
		mines.push(mc);

	}
	public function getNearMines(x,y){
		var list = [];
		for( mc in mines ){
			//var mc = mines[i];
			if(mc.flActive){
				var dx = x-mc._x;
				var dy = y-mc._y;
				var dist = Math.sqrt(dx*dx+dy*dy);
				if(dist<Cs.MINE_RAY)list.push(mc);
			}
		}
		return list;
	}
	public function checkMines(x:Int,y:Int){
		//trace("checkMines("+x+","+y+")");
		var list = getNearMines(x,y);


		if(list.length>0){
			for( mc in list )explodeMine(mc);
		}
		return list.length>0;
	}
	public function explodeMine(mc){

		mines.remove(mc);

		var list = rayDamage( mc._x, mc._y, 40, Cs.MINE_EXPLODE_RAY, Cs.MINE_EXPLODE_RAY*0.5, 10 );
		makeHole( mc._x, mc._y, Cs.MINE_EXPLODE_RAY);


		/*
		for( cosmo in list ){
			if( cosmo.flWaitHand ){
				cosmo.flWaitHand = false;
				endAnim = callback(cosmo.pass);
			}
		}
		*/

		setReady(false);

		mc.removeMovieClip();


	}
	public function activeMines(){
		for( mc in mines )mc.flActive = true;
	}

	// FX
	public function fxSphere(x,y,sc,?link){
		if(MMApi.isReconnecting())return;
		if(link==null)link = "mcSphereBlink";
		var mc = Game.me.mdm.attach(link,DP_PARTS);
		mc._x = x;
		mc._y = y;
		mc._xscale = mc._yscale = sc;
		Filt.glow(mc,8,2,0xFFFF);
	}
	public function fxSpawn(cosmo){
		if(MMApi.isReconnecting())return;
		var max = 32;
		var ray  = 10;
		for( i in 0...max ){
			var p = new Phys(mdm.attach("partHeal",DP_PARTS));
			p.x = cosmo.x+(Math.random()*2-1)*ray;
			p.y = cosmo.y+(Math.random()*2-1)*ray;
			p.weight = -(0.1+Math.random()*0.1);
			p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
			p.timer = 10+Math.random()*10;
		}

	}
	public function getDirt(px,py,?freq):Dynamic{
		if(freq==null)freq=3;

		var p = null;

		if(Std.random(3)%freq==0){
			p = cast new pix.Part(mdm.attach("partDirt",DP_PARTS));
			p.x = px;
			p.y = py;
			//p.vx = dx*cs;
			//p.vy = dy*cs;
			p.timer = 50+Math.random()*20;
			p.weight = 0.2+Math.random()*0.2;
			p.setScale(50+p.weight*100);
			p.colFrict = 0.6;
			Col.setColor(p.root, mapBmp.getPixel32(px,py) );
			p.updatePos();

		}else{
			p = cast new Phys(mdm.attach("partDirt",DP_PARTS));
			p.x = px;
			p.y = py;
			//p.vx = dx*cs;
			//p.vy = dy*cs;
			p.timer = 10+Math.random()*10;
			p.weight = 0.2+Math.random()*0.2;
			p.setScale(50+p.weight*100);
			p.fadeType = 0;
			Col.setColor(p.root, mapBmp.getPixel32(px,py) );
			p.updatePos();

		}
		return p;

	}
	public function setWind(){
		wind = (rand.rand()*2-1)*0.2;
	}

	// CELLS
	public function initCell(c:Float){
		var p:Cell = cast new Phys(dm.attach("partCellule",DP_MAP));
		p.x = Math.random()*Cs.mcw;
		p.y = Math.random()*Cs.mch;
		p.vy = -c*1;
		p.c = c;
		p.setScale(40+c*120);
		p.root._rotation = Math.random()*360;
		cells.push(p);
		cellDecal = 0;
		return p;
	}
	public function updateCells(){
		cellDecal = (cellDecal+3)%628;
		for( c in cells ){
			c.x += c.c*wind*20;
			c.y += Math.cos(cellDecal*0.01)*c.c*1.5;

			var m = 20;
			if( c.x<-m ) 		c.x += Cs.mcw+2*m;
			if( c.x>Cs.mcw+m ) 	c.x -= Cs.mcw+2*m;
			if( c.y<-m ) 		c.y += Cs.mch+2*m;
			if( c.y>Cs.mch+m ) 	c.y -= Cs.mch+2*m;
		}

	}


	// HELP_BOX
	public function setMsg(?str:String){

		if(str==null)str= "";

		mcHelpBox.field.text = str;
		mcHelpBox.last = str;

		//trace("!"+str);

		/*
		if(str==null){
			mcMsg.timer = 2;
			return;
		}
		if( mcMsg == null ){
			mcMsg = cast dm.attach("mcMessage",DP_INTER);
			mcMsg._y = Cs.mch+30;
			//mcMsg.smc.gotoAndStop(colorId+1);

		}
		mcMsg.timer = null;
		mcMsg.fieldDesc.text = str.toUpperCase();
		*/


	}
	public function initHelpBox(){

		mcHelpBox = cast dm.attach("mcHelpBox",DP_INTER);
		mcHelpBox._y = Cs.mch;
		mcHelpBox.last = "";

		if( params.flTips && MMApi.hasControl() ) showHelpBox(); else hideHelpBox();


	}
	public function showHelpBox(){
		flClick = false;
		mcHelpBox.gotoAndStop(1);
		mcHelpBox.smc.gotoAndStop(colorId+1);
		mcHelpBox.cross.onPress = callback(hideHelpBox);

		Filt.glow( cast mcHelpBox.field, 3, 4, [0x220000,0x000044][colorId] );

		params.flTips = true;
		so.data.params = params;
		so.flush();

		bot = Cs.mch-21;
		updateMiniMap();

		setMsg(mcHelpBox.last);

	}
	public function hideHelpBox(){
		flClick = false;
		mcHelpBox.gotoAndStop(2);
		mcHelpBox.cross.onPress = callback(showHelpBox);

		//mcHelpBox.removeMovieClip();
		//mcHelpBox = null;

		params.flTips = false;
		so.data.params = params;
		so.flush();

		bot = Cs.mch;
		updateMiniMap();
	}

	// WEAPON TIP
	public function setWeaponTip(aid,ammo){
		if(!params.flTips)return;


		var name = Lang.ACTION_NAME[aid].toUpperCase();
		if(ammo>0) name+= " ["+ammo+"]";
		var desc = Lang.ACTION_DESC[aid];

		if( mcWeaponTip == null ){
			mcWeaponTip = cast dm.attach("mcWeaponTip",DP_INTER);
			mcWeaponTip._y = -60;
			Filt.glow( cast mcWeaponTip.fieldName, 2, 4, [0xFF0000,0x0000FF][colorId] );
			var fl = new flash.filters.DropShadowFilter();
			fl.blurX = 0;
			fl.blurY = 0;
			fl.strength = 0.3;
			fl.distance = 3;
			var a = mcWeaponTip.fieldName.filters;
			a.push(fl);
			mcWeaponTip.fieldName.filters = a;
			mcWeaponTip.smc.gotoAndStop(colorId+1);

		}
		mcWeaponTip.timer = null;
		mcWeaponTip.fieldName.text = name;
		mcWeaponTip.fieldDesc.text = desc;
		mcWeaponTip.icon.gotoAndStop(aid+1);
		mcWeaponTip.fieldDesc._y = 38 - Std.int(mcWeaponTip.fieldDesc.textHeight*0.5);


	}
	public function removeWeaponTip(){
		mcWeaponTip.timer = 5;
	}
	function updateWeaponTip(){
		if( mcWeaponTip != null ){

			if(mcWeaponTip.timer!=null){
				if(mcWeaponTip.timer--<0){
					mcWeaponTip._y += (mcWeaponTip._y-1);
					if(mcWeaponTip._y<-60){
						mcWeaponTip.removeMovieClip();
						mcWeaponTip = null;
					}
				}
			}else{
				mcWeaponTip._y *= 0.5;
			}
			mcWeaponTip._y = Std.int(mcWeaponTip._y);

		}


	}

	// READY
	public function setReady(fl){
		//if(fl && moveStack.length>0)return;
		flReady = fl;
		MMApi.lockMessages(!flReady);
		//trace("setReady("+fl+")");

	}
	function isReady(){
		if(moveStack.length>0 || anims.length>0 )return false;
		return true;
	}
	function playStack(a:Array<Int>){
		//trace("playStack...("+a.length+")");
		if(a==null)trace("playStack null!");
		if(!isReady())trace("PlayStack error");

		/*
		if(MMApi.isReconnecting() ){
			while(a.length>12)a.shift();
		}else{
			//for(i in 0...4 )a.pop();
		}
		*/


		moveStack = a;
		setReady(false);
	}

	// PROTOCOLE
	public function initialize():Msg{
		//bg.onPress = spawnCosmo;
		//


		/*
		var kc = flash.Key.getCode()-49;
		if( kc>=0 && kc<7 && FL_DEBUG ){
			type = kc;
		}
		*/


		var a = [ MMApi.getOptions(true), MMApi.getOptions(false) ];
		var mapList = [];
		for( i in 0...10 ){
			if( a[0][i] && a[1][i] )mapList.push(i+1);
		}
		if( mapList.length == 0 ) mapList = [0];
		var type = mapList[Std.random(mapList.length)];
		var mapInfo = Cs.MAP_INFOS[type];




		/*
		for( n in 0...2 ){
			for( i in 0...3 ){
				spawnCosmo(Std.random(mapWidth),Std.random(mapHeight),n==0);
			}
		}
		*/

		return Init(type,Std.random(1000));
	}
	public function onMessage(flMine:Bool,msg){

		switch(msg){

			case Init(levelType,seed):
				flMain = flMine;
				flFirstUpkeep = true;
				colorId=0;
				if(!flMain)colorId=1;
				rand = new mt.OldRandSeed(seed);

				initMap(levelType);
				initMiniMap();
				initHelpBox();

				setWind();

				cosmos = [];
				myCosmos = [];
				oppCosmos = [];

				initZones();
				initCosmoBar();

				if(!FL_PLACE  ){
					//initCosmos(levelInfo.cosmos);
					if(!flMain)MMApi.sendMessage(PlayNext());
					return;
				}

				if(flMain){
					setMod(PlaceCosmo);
				}else{
					setMod(Watch,null);
				}


				/*
				initCosmos(levelInfo.cosmos);
				if(!flMain){
					MMApi.sendMessage(PlayNext);
				}
				*/


			case Place(cid,x,y):



				var cosmo = new pix.Cosmo( mdm.empty(Game.DP_COSMO), Cs.getCosmoType(cid), flMine );
				cosmo.x = x;
				cosmo.y = y;
				cosmo.setState(Ground);
				cosmo.startDrop();
				focus = cast cosmo;
				fxSpawn(cosmo);
				mcStartPos.removeMovieClip();
				mcStartPos = null;

				if( myCosmos.length == Cs.COSMO_TEAM_MAX && oppCosmos.length == Cs.COSMO_TEAM_MAX )return;
				//trace("msgPlace("+myCosmos.length+","+oppCosmos.length+")");


				// ZONE
				addZone(cosmo);

				// AGAIN
				if(flMine){
					if(cid>1)mcCosmoBar.list[cid]._visible = false;
					setMod(Watch,null);
				}else{
					setMod(PlaceCosmo);
				}



			case PlayNext(flAgain): // IMPLEMENTE FLAGAIN

				//MMApi.logMessage("playnext!");

				upkeep();

				//trace("playNext("+flAgain+") flMine("+flMine+")");
				//trace("PlayNext("+flMine+")");

				var flMyTurn = !flMine;
				if(flAgain)flMyTurn = !flMyTurn;

				var list = if( flMyTurn ) myCosmos; else oppCosmos;

				currentCosmo.unselect();
				currentCosmo = list.shift();

				list.push(currentCosmo);
				setFocus( cast currentCosmo );
				currentCosmo.select();

				currentCosmo.initTurn();

				if( flMyTurn && MMApi.hasControl() && !MMApi.isReconnecting() ){
					setMod(PlayStart,currentCosmo);
				}else{
					setMod(Watch,currentCosmo);
				}




			case PlayStack(sta): if(!flMine || MMApi.isReconnecting() || !MMApi.hasControl() )playStack(sta);


			case ExplodeMine(n):


			case PlayJump(da,power):
				//trace("msg JUMP");
				currentCosmo.jump(da,power);
				setReady(false);

			case PlayShot(type,mid,angle,power):
				//trace("--- PLAY SHOT ---");
				//trace("-UNIFY-");
				unify();
				//trace("-SHOT-");
				currentCosmo.shot(type,angle,power);
				currentCosmo.decAmmo(mid);
				setReady(false);

			case ShowWeapon(type,flSecret):
				if(flSecret && !currentCosmo.flMine)return;
				currentCosmo.initWeapon(type);
			case HideWeapon:
				//trace("hideWeapon");
				currentCosmo.removeWeapon();
			case TakeCover:
				currentCosmo.cover();
				//trace("hideWeapon");
				//currentCosmo.removeWeapon();

		}
	}
	public function onReconnectDone(){

		for( c in cosmos )c.cheese();

		if( isReady() && currentCosmo.flMine ){
			//root._visible = true;


			if(currentCosmo.escapeTimer==null){
				setMod(PlayStart,currentCosmo);
			}else{
				currentCosmo.timeUp();
			}
		}
	}
	public function onTurnDone(){


	}
	public function onVictory(fl){
		Game.me.setMsg();
		MMApi.gameOver();
	}

	public function checkVictory(){


		if( oppCosmos.length==0 && myCosmos.length>0 )  MMApi.victory(true);
		if( oppCosmos.length>0 && myCosmos.length==0 )  MMApi.victory(false);
		if( oppCosmos.length==0 && myCosmos.length==0 ) MMApi.victory(null);

	}
	public function pass(){
		//MMApi.logMessage("pass!");
		MMApi.queueMessage(PlayNext());
		MMApi.endTurn();
	}


	// LISTENERS
	function initMouseListener(){
		var ml = {};
		var me = this;
		Reflect.setField( ml, "onMouseDown", function(){ me.flClick = true; });
		Reflect.setField( ml, "onMouseUp", function(){ me.flClick = false; });
		Mouse.addListener(cast ml);
	}
	function initKeyListener(){
		var kl = {};
		var me = this;
		Reflect.setField( kl, "onKeyDown", keyPress);
		Reflect.setField( kl, "onKeyUp", keyRelease);
		flash.Key.addListener(cast kl);
	}
	function keyPress(){
		var n = flash.Key.getCode();
		switch(n){
			case flash.Key.SPACE:
				flSpaceView = true;

		}
	}
	function keyRelease(){
		flSpaceView = false;
	}


	// DEBUG
	function testMove(){
		var sens = null;
		if( flash.Key.isDown(flash.Key.LEFT) )sens = 1;
		if( flash.Key.isDown(flash.Key.RIGHT) )sens = -1;

		if(sens!=null){
			for( c in cosmos ){
				c.walk(sens);

			}
		}

	}
	function initTracer(){
		mcTracer = cast dm.attach("mcTracer",DP_INTER);
		mcTracer._x = Cs.mcw;
		Filt.glow(mcTracer,2,4,0);
	}
	public function setDebugCursor(x,y){
		if(mcDebugCursor==null){
			mcDebugCursor = mdm.attach("mcDebugCursor",DP_DEBUG);
		}
		mcDebugCursor._x = x;
		mcDebugCursor._y = y;
	}

	public function showAngle(x:Float,y:Float,a:Float,?flErase){
		if(flErase)mcDebugAngle.removeMovieClip();
		mcDebugAngle = mdm.attach("mcDebugLine",DP_DEBUG);
		mcDebugAngle._x = x;
		mcDebugAngle._y = y;

		mcDebugAngle._rotation = a/0.0174;
		/*
		trace("!"+mc._x);
		trace("!"+mc._y);
		trace("!"+mc._rotation);
		*/
	}

//{
}




// IDEE POUR LA VERSION SITE
// AURAS
// BAR DE TOURS A JOUER
// sniper couverture
// enterrer des tresor ou des objectifs.

// BUGS :
// X passage de tour.
// X endturn sur les poses de cosmos au depart
// X enlever barre de retraite sur grenade
// X cam suis pas grenade.
// X je joue je meurs (tombe), je rejoue
// X gerer vent
// X marche pied vers le haut.

// X BLINDER Menu ( apparait au tour adverse )
// X faire monter les anges moins vites.
// X temps de recovery interrompu -- flWaitHand bug
// X grossir cellule premier plan
// finir a l'avance

/*
X grenade qui gonfle juste avant l'explosion.

gonfler le bazooka pendant le chargement du tir

X corriger l'orientation du bazooka

X affichage du projectile sur la map

X attacher gunShot2 à l'extremité de gunShot

X toggle minimap ON/OFF (les différentes tailles sont pas très utiles)

x ptite fumée au sol lors d'un saut ou un atterissage

x skiner la mort d'un cosmo (plus de particules ? tombe ? fantome ?)

x eviter la superposision parfaite de plusieurs cosmo

x mettre un ptit rollover sur les icones du choix de l'arme (petit scale elastique par exemple)

x pendant le choix de l'arme, orienter la tete du cosmo vers le bouton allumé

x particule depart de saut

*/



