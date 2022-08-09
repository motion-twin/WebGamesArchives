class Game {//}

	static var DEBUG = false;

	static var DP_BASE = 	0;
	static var DP_BG = 	4
	static var DP_DECOR = 	5;
	static var DP_ELEMENT = 6;
	static var DP_PIOU = 	7;
	static var DP_PART = 	8;

	static var TOLERANCE = 60


	static var CONTROL_TYPE = 0;

	var flDone:bool;
	var flCenterActive:bool;

	var step:int;
	var genStep:int;
	var generator:Array<int>;
	volatile var timer:float;
	volatile var gameTimer:float;
	volatile var scoreTimer:float;

	var angle:float;
	var va:float;
	var gcos:float;
	var gsin:float;
	var sc:float;

	var dm:DepthManager;
	var gdm:DepthManager;

	var sList:Array<Sprite>;
	var bList:Array<Bille>;
	var eList:Array<Element>;
	var outList:Array<{x:float,y:float,rot:float}>

	var ball:Ball;

	var map:MovieClip;
	var minimap:{ >MovieClip, mask:MovieClip, map:MovieClip };
	var bg:{>MovieClip,sc:MovieClip,x:float,y:float};
	var scroller:MovieClip;
	var mcInter:{>MovieClip, bar:MovieClip,barUp:MovieClip,dec:float}
	var lvl:flash.display.BitmapData;
	var prc:flash.display.BitmapData;

	var pentacle:MovieClip;
	var loader:MovieClip;

	var stats:{}

	var fl:flash.filters.BlurFilter;


	function new(mc) {

		flash.Init.init();
		Cs.init();
		Cs.game = this
		gdm = new DepthManager(mc);
		Cs.dm = gdm;
		scroller = gdm.empty(2)


		map = Std.createEmptyMC(scroller,0)
		dm = new DepthManager(map);
		sList = new Array();
		eList = new Array();

		sc = 1;

		angle = 0;
		va= 0;
		gcos = 0;
		gsin = 0;
		generator = new Array();
		scoreTimer = 0;

		flCenterActive = false;




		initStep(0);
		//initBackground();
	}

	function initBackground(){
		var ts = 128
		var fs  = (Math.ceil(Cs.mcw/ts)+2)*ts
		var bmp = new flash.display.BitmapData(fs,fs,true,0xFF000000)
		var bmp2 = Cs.texturize(bmp,"mcBgText",ts)

		bg  = downcast(gdm.empty(1))
		bg.sc = Std.attachMC(bg,"bg",0)
		bg.sc.attachBitmap(bmp2,0)
		bg.x = 0
		bg.y = 0
		bg._x = Cs.mcw*0.5
		bg._y = Cs.mcw*0.5

	}


	function initStep(s:int){
		step = s;

		switch(step){
			case 0: //
				genStep = 0
				lvl = new flash.display.BitmapData(Cs.LEVEL_SIDE,Cs.LEVEL_SIDE,true,0xFFFFFFFF)
				outList = [{x:Cs.LEVEL_SIDE*0.5,y:Cs.LEVEL_SIDE*0.5,rot:0}]
				//
				loader = gdm.attach("mcLoader",10)
				loader._x = Cs.mcw*0.5
				loader._y = Cs.mch*0.5

				KKApi.processing(true);

				break;
			case 1:	//

				KKApi.processing(false);
				//initKeyListener();
				bList = new Array();
				ball = genBall(Cs.LEVEL_SIDE*0.5,Cs.LEVEL_SIDE*0.5)
				gameTimer = Cs.TIME_MAX

				// INTER
				mcInter = downcast(gdm.attach("mcInter",3))
				mcInter.bar._alpha = 50;
				mcInter._x = Cs.mcw
				mcInter.dec = 0;

				// EXPLO
				var max  = 48
				for( var i=0; i<max; i++ ){
					var p = Cs.game.newPart("mcLightFlip")
					var a = (i/max)*6.28;
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var sp = 1+Math.random()*2
					var ray = 100

					p.x = Cs.LEVEL_SIDE*0.5+ca*ray
					p.y = Cs.LEVEL_SIDE*0.5+sa*ray
					p.vx  = ca*sp
					p.vy  = sa*sp
					p.timer = 10+Math.random()*10
					if(Std.random(3)==0)p.timer+=Math.random()*100
					p.fadeType = 0;
					p.weight = 0.1+Math.random()*0.3
					p.bouncer = new Bouncer(p)
					p.setScale(100+Math.random()*100)
				}


				break;
			case 9: // ENDGAME

				break


		}

	}

	function genBall(x,y){

		var b = new Ball(null);
		b.bouncer.setPos(x,y)
		return b;

	}

	function genBille(x,y){
		var b = new Bille(null);
		b.bouncer.setPos(x,y)
		return b;

	}


	function finalizeLevel(){
		// BACKGROUND
		initBackground();
		// BONUS
		for( var i=0; i<outList.length; i++){
			var p  = outList[i]
			var e = new Element(p.x,p.y,Cs.SPAWN[Std.random(Cs.SPAWN.length)])
		}
		// TEXTURE
		var bmp = Cs.texturize(lvl,"mcText",128);
		lvl = bmp;
		dm.empty(DP_DECOR).attachBitmap(lvl,0)

		initMiniMap();


		//map._xscale = 50;
		//map._yscale = 50;

	}
	//
	function main() {
		timer-=Timer.tmod;
		switch(step){
			case 0: //
				genLevel();
				genStep++
				if(genStep>=Cs.LEVEL_SIZE){
					finalizeLevel();
					loader.removeMovieClip();
					initStep(1)
				}
				downcast(loader).piou._rotation += 15*Timer.tmod;
				downcast(loader).wh._rotation -= Timer.tmod;
				loader.gotoAndStop(string(int(genStep/Cs.LEVEL_SIZE*100) + 1))

				break;
			case 1:
				var ty = (gameTimer/Cs.TIME_MAX)*100
				mcInter.bar._yscale = mcInter.bar._yscale*0.7 + ty*0.3
				mcInter.barUp._y = 295-(mcInter.bar._height)


				scoreTimer -= Timer.tmod;
				while(scoreTimer<0){
					scoreTimer+=Cs.SCORE_LAP
					for(var i=0;i<generator.length;i++)KKApi.addScore(Cs.SCORE_BASE);
				}


				// CENTER CHECK
				var dist = ball.getDist( {x:Cs.LEVEL_SIDE*0.5,y:Cs.LEVEL_SIDE*0.5} )
				var lim = Cs.mcw
				if( ( flCenterActive && dist>=lim ) || ( !flCenterActive && dist<lim ) ){
					switchCenter();
				}

				// SPRITES
				var list = sList.duplicate();
				for( var i=0; i<list.length;i++){
					list[i].update();
				}
				// MOVE MAP
				scrollMap();

				// CHECK END
				gameTimer -= Timer.tmod;
				var m = -20
				if( ball.x<m || ball.x>Cs.LEVEL_SIDE-m || ball.y<m || ball.y>Cs.LEVEL_SIDE-m ){
					gameTimer = Math.min(gameTimer, 20)
				}

				if(gameTimer<0){
					var burst = Cs.game.gdm.attach("mcBurst",10)
					burst._x = Cs.mcw-6
					burst._y = Cs.mch-6
					mcInter.removeMovieClip();
					timer = 8
					initStep(9)
				}

				if(gameTimer<400){
					var fl = new flash.filters.GlowFilter();
					mcInter.dec = (mcInter.dec+23*Timer.tmod)%628
					var inc = Math.abs(Math.cos(mcInter.dec/100)*10)
					fl.blurX = inc
					fl.blurY = inc
					fl.color = 0xFFFFFF
					mcInter.filters = [fl]
					Cs.setPercentColor(mcInter,inc*4,0xFFFFFF)

				}else{
					if(mcInter.filters.length>0){
						mcInter.filters = null;
						Cs.setPercentColor(mcInter,0,0xFFFFFF)
					}

				}




				break;
			case 9:
				if(timer<0){
					KKApi.gameOver(stats);
					va = 0
					initStep(10)
				}
				break;
			case 10:
				va += 0.4*Timer.tmod;
				scroller._rotation+=va*Timer.tmod;
				ball.root._rotation = -scroller._rotation;



				break;

		}



		// PENTACLE TOURNE
		if( flCenterActive ){
			pentacle._rotation += (0.6+generator.length*0.2)*Timer.tmod;
		}



	}
	//
	function scrollMap(){
		//Log.print(int(100/Timer.tmod)+"%")
		switch(CONTROL_TYPE){

			case 0:
				var acc = 0.07
				if(Key.isDown(Key.LEFT)){
					va -= acc*Timer.tmod
				}
				if(Key.isDown(Key.RIGHT)){
					va += acc*Timer.tmod
				}
				va *= Math.pow(0.6,Timer.tmod)
				angle = Cs.hMod( angle+va*Timer.tmod, Math.PI )
				break;
			case 1:
				var dx = Cs.mcw*0.5 - gdm.root_mc._xmouse;
				var dy = Cs.mch*0.5 - gdm.root_mc._ymouse;
				var a = Math.atan2(dy,dx)
				angle = -a

				break;

		}

		var a  = -angle+1.57
		gcos = Math.cos(a)
		gsin = Math.sin(a)


		var dx = -ball.root._x - map._x;
		var dy = -ball.root._y - map._y;

		map._x += dx
		map._y += dy
		scroller._x = Cs.mcw*0.5;
		scroller._y = Cs.mch*0.5;
		scroller._rotation = angle/(Math.PI/180);


		if(DEBUG){
			if(Key.isDown(Key.DOWN)) sc *= 0.97;
			if(Key.isDown(Key.UP)) sc *= 1.025;
			scroller._xscale = sc*100;
			scroller._yscale = sc*100;
		}


		if(minimap!=null){
			updateMinimap();
		}

		// ZOOM
		/*
		var sp = 10
		if( Key.isDown(109) ){
			scroller._xscale = Math.max(10,scroller._xscale-sp*Timer.tmod)
			scroller._yscale = scroller._xscale
		}
		if( Key.isDown(107) ){
			scroller._xscale = Math.min( 1000, scroller._xscale+sp*Timer.tmod )
			scroller._yscale = scroller._xscale
		}
		*/




		// BG

		var c = 0.1
		bg.x = Cs.sMod(bg.x+dx*c,128)
		bg.y = Cs.sMod(bg.y+dy*c,128)
		bg.sc._x = bg.x -(Cs.mcw*0.5+256)
		bg.sc._y = bg.y -(Cs.mch*0.5+256)
		bg._rotation = scroller._rotation
		//var dr = Cs.hMod(scroller._rotation- bg._rotation,180)
		//bg._rotation += dr*0.2


	}

	//
	function newPart(link){
		var p  = new Part(dm.attach(link,DP_PART));
		return p;
	}

	function newDebris(x,y){
		var color = lvl.getPixel32(int(x),int(y))
		if( !isBg(color) ){
			var p = newPart("mcDebris")
			p.x = x;
			p.y = y;
			p.setScale(50+Math.random()*80)
			p.timer = 10+Math.random()*10
			p.fadeType = 0
			p.weight = 0.1+Math.random()*0.1
			p.frict = 0.98
			Cs.setColor(p.root, color ,-255)
			return p;
		}
		return null;
	}

	// CENTER
	function switchCenter(){
		flCenterActive = !flCenterActive
		if(flCenterActive){
			pentacle = dm.attach("mcPentacle",DP_DECOR)
			pentacle._alpha = 50
			pentacle._x = Cs.LEVEL_SIDE*0.5
			pentacle._y = Cs.LEVEL_SIDE*0.5

			for( var i=0; i<generator.length; i++ ){
				var a = Math.random()*6.28
				var ray  = 10+Math.random()*80
				var b = genBille(pentacle._x+Math.cos(a)*ray,pentacle._y+Math.sin(a)*ray);
				b.initGeneratorMode()
				b.bTimer = null
				b.bouncer = null;
				b.setColor(generator[i])
			}

		}else{
			pentacle.removeMovieClip();
			for( var i=0; i<bList.length; i++ ){
				var b  = bList[i];
				if(b.step==2){
					b.kill();
					i--
				}
			}
		}
	}

	// MINIMAP
	function initMiniMap(){
		var m = 4;
		var side = 80;
		var sc = 10;

		minimap = downcast( gdm.empty(5) );
		var dm = new DepthManager(minimap);

		minimap._x = m;
		minimap._y = Cs.mch-(side+m);
		minimap.map = dm.empty(0);
		minimap.map._x = side*0.5;
		minimap.map._y = side*0.5;


		minimap.mask = dm.attach("mcMask",0);
		minimap.mask._xscale = side;
		minimap.mask._yscale = side;
		minimap.map.setMask(minimap.mask);

		minimap.map.smc = new DepthManager(minimap.map).empty(0);
		minimap.map.smc.attachBitmap(lvl,0);
		minimap.map.smc._xscale = sc;
		minimap.map.smc._yscale = sc;
		minimap.map.smc._x = -minimap.map.smc._width*0.5;
		minimap.map.smc._y = -minimap.map.smc._height*0.5;


		var piou = dm.attach("mcMiniPiou",0);
		piou._x = side*0.5;
		piou._y = side*0.5;

		/*
		minimap.attachBitmap(lvl,0);
		minimap._xscale = 8;
		minimap._yscale = 8;
		*/

		Cs.setPercentColor(minimap.map,100,0xFFFFFF);
		minimap.map._alpha = 50;
		//Log.trace("!");



	}
	function updateMinimap(){

		var sc = minimap.map.smc._xscale*0.01

		minimap.map._rotation = scroller._rotation;

		minimap.map.smc._x = map._x*sc;
		minimap.map.smc._y = map._y*sc;


	}


	// LEVEL
	function isFree(x,y){
		var m = Cs.MARGIN
		//if( x<m || x>=Cs.mcw-m || y<m || y>=Cs.mch-m )return false;
		return isBg(lvl.getPixel32(int(x),int(y)))
		//return !lvl.hitTest(new flash.geom.Point(0,0),0,new flash.geom.Point(int(x),int(y)),null,null)
	}

	function isBg(col){
		var pc = Cs.colToObj32(col)
		return pc.a <= TOLERANCE
	}

	function genLevel(){



			var index = Std.random(outList.length)
			var p = outList[index]
			var list = tryBranche(p.x,p.y,p.rot)
			if(list!=null){
				for( var n=0; n<list.length; n++ ){
					outList.push( list[n] );
				}
				outList.splice(index,1)
			}








	}

	function tryBranche(x,y,rot){
		var mc = getRandomBase(x,y,rot)
		var list = new Array();
		for( var i=0; i<mc.list.length; i++){
			var mcp = mc.list[i]
			var p0 = Tools.localToGlobal(mc, mcp._x,mcp._y)
			var p1 = Tools.globalToLocal(map, p0.x, p0.y)
			if( isFree(p1.x,p1.y) ){
				mc.removeMovieClip();
				return null;
			}
			list.push({x:p1.x,y:p1.y,rot:Cs.hMod(mc._rotation+mcp._rotation,180)})
		}

		//
		var b = mc.getBounds(map)
		for( var i=0; i<1500; i++ ){
			var px = int( b.xMin + Math.random()*(b.xMax-b.xMin) )
			var py = int( b.yMin + Math.random()*(b.yMax-b.yMin) )
			if(mc.hitTest(px,py,true) ){
				if(isFree(px,py)){
					if( Cs.getDist({x:px,y:py},{x:x,y:y}) > 40 ){
						mc.removeMovieClip();
						return null
					}
				}
			}
		}

		//
		mc.blendMode = BlendMode.ERASE
		Cs.drawMC(lvl,mc)
		mc.removeMovieClip();
		return list;
	}

	function getRandomBase(x,y,rot){
		var mc = downcast(dm.attach("mcBase",DP_BASE));
		if(flDone!=true){
			mc.removeMovieClip();
			mc = downcast(dm.attach("mcFirst",DP_BASE));
		}

		var frame = string(Std.random(mc._totalframes)+1)
		//frame = "1"
		mc.gotoAndStop(frame)
		mc.list = new Array();
		for( var i=0; i<7; i++ ){

			var d = Std.getVar(mc,"$a"+i)
			if(d==null)break;
			mc.list.push(d)
			d._visible = false;
		}


		var index = Std.random(mc.list.length)
		if(flDone!=true)index = 0;
		var p = mc.list[index]
		var ba = Math.atan2(p._y,p._x)

		rot -= (180+p._rotation)

		var a = Cs.hMod( ba + rot*0.0174, 3.14 )
		var dist = Math.sqrt( p._x*p._x + p._y*p._y )
		mc._x = x - Math.cos(a)*dist;
		mc._y = y - Math.sin(a)*dist;
		mc._rotation = rot

		mc.list.remove(p)
		flDone = true;

		return mc;
	}

	// KEYS
	function initKeyListener(){
		var kl = {
			onKeyDown:callback(this,onKeyPress),
			onKeyUp:callback(this,onKeyRelease)
		}
		Key.addListener(kl)

	}

	function onKeyPress(){

		var n = Key.getCode();

		if(n>=96 && n<107 ){

		}
		if(n>=49 && n<52 ){
		}
		if(n>=52 && n<55 ){

		}

		switch(n){
			case Key.SPACE:
				/*
				var b = genBall(map._xmouse,map._ymouse)
				b.vx = (Math.random()*2-1)*8
				b.vy = (Math.random()*2-1)*8
				*/
				break;
			case Key.ENTER:
				gameTimer-=100
				break;


		}


	}

	function onKeyRelease(){

	}

	//
	function getRandomPos(){
		return {
			x:int(Cs.MARGIN + Math.random()*(Cs.mcw-2*Cs.MARGIN))
			y:int(Cs.MARGIN + Math.random()*(Cs.mch-2*Cs.MARGIN))
		}
	}
	//

	function setMark(x,y,a){
		var mc = gdm.attach("mcMark",DP_PART)
		mc._x = x;
		mc._y = y;
		mc._rotation = a/0.0174
	}


	// TOOLS
	function getShapeList(bmp){
		var list = new Array();
		var px=0
		var py=0

		// SEEK FIRST
		for( var x=0; x<bmp._width; x++ ){
			for( var y=0; y<bmp._height; y++ ){
				if(!isBmpPointFree(bmp,x,y)){
					px = 0
					py = y-1
					break;
				}
			}
		}
		Log.trace("First : "+px+", "+py)
		var first = {x:px,y:py}
		list = [first]

		var dir = {x:0,y:1}

		var tr = 0
		while( true ){
			var f = turn(dir,1)
			var nx = px+f.x;
			var ny = py+f.y;
			if(!isBmpPointFree(bmp,nx,ny)){
				dir = f
			}else{
				if( isBmpPointFree( bmp, nx+dir.x, ny+dir.y ) ){
					px = nx+dir.x;
					py = ny+dir.y;
					dir = turn(dir,-1)
				}else{
					px = nx;
					py = ny;
				}
				if( px!=first.x && py!= first.y){
					list.push({x:px,y:py});
				}else{
					break;
				}
			}
			/*
			if(tr++>100){
				Log.trace(list)
				break;
			}
			*/
		}


		return list;

	}

	function isBmpPointFree(mc,x,y){
		/*
		var p = Tools.localToGlobal(mc,x,y);
		Tools.globalToLocal(map,p.x,p.y);
		*/
		return !mc.hitTest(x,y,true);

	}

	function turn(d,sens){
		return { x:-d.y*sens, y:d.x*sens }
	}


//{
}








