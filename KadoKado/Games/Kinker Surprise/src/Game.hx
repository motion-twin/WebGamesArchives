import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;
import mt.bumdum.Plasma;
import mt.bumdum.Bmp;


private enum Step {
	Seek;
	Scroller(flQuit:Bool);
	GameOver;

}

typedef Plan = {>flash.MovieClip, c:Float }

class Game {//}

	public static var FL_DEBUG = false;

	public static var COLOR = [
		0xFF0000,
		0xFFFF00,
		0x00FF00,
		0x00FFFF,
		0x0000FF,
		0xFF00FF,
		0xFFAA00,
		0xAA00FF
	];
	public static var DIR = [[1,0],[0,1],[-1,0],[0,-1]];

	public static var DP_BG = 	0;
	public static var DP_MAP = 	1;
	public static var DP_PLASMA = 	2;
	public static var DP_FRONT = 	3;
	public static var DP_INTER = 	4;


	public static var DP_GROUND = 	1;
	public static var DP_ELEMENT = 	2;
	public static var DP_SELECTOR =	3;
	public static var DP_PARTS =	4;

	static var SCORE_DALLE = 	KKApi.const(125);
	static var SCORE_FREE = 	KKApi.const(-125);
	static var TIME_BONUS =		1200;
	static var TIME_MAX =		2500;

	static var PLASMA_CACHE = 	0;

	public static var EMPTY = 	0;
	public static var PATH = 	1;
	public static var WALL = 	2;
	public static var GENERATOR = 	10;
	public static var PAINT = 	50;

	public static var mcw = 300;
	public static var mch = 300;

	var flAutoSelect:Bool;
	var flForceUpdateTarget:Bool;

	public var xmax:Int;
	public var ymax:Int;
	public var zw:Int;
	public var zh:Int;
	public var size:Int;

	public var colorMax:Int;
	public var level:Int;
	public var ccolorMax:mt.flash.Volatile<Int>;
	public var clevel:mt.flash.Volatile<Int>;

	public var colorId:Int;
	public var tx:Int;
	public var ty:Int;

	var levelTimer:mt.flash.Volatile<Float>;
	var levelTimerMax:mt.flash.Volatile<Float>;
	var freeTimer:mt.flash.Volatile<Float>;
	var scx:Float;
	var scy:Float;

	var coef:Float;

	public var step:Step;

	//BALL
	public var map:flash.MovieClip;
	public var zone:flash.MovieClip;
	public var ground:flash.display.BitmapData;
	public var spectre:flash.display.BitmapData;

	public var grid:Array<Array<Int>>;
	public var archive:Array<Array<Array<Int>>>;
	public var path:Array<Array<Int>>;
	public var free:Array<Array<Array<Int>>>;
	public var action:Array<Int>;
	public var generators:Array<Generator>;
	var plans:Array<Plan>;
	public var plasma:Plasma;

	public var mcInter:{>flash.MovieClip, field:flash.TextField, b0:flash.MovieClip, b1:flash.MovieClip  };
	public var selector:Selector;

	public static var me:Game;
	public var mdm:mt.DepthManager;
	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var stats:{_f:Int,_b:Array<Int>,_s:Int};
	public var run:{x:Int,y:Int};

	var mcTarget:flash.MovieClip;

	public function new( mc : flash.MovieClip ){
		haxe.Log.setColor(0xFFFFFF);
		root = mc;
		me = this;
		mdm = new mt.DepthManager(root);

		level = 0;
		clevel = 0;
		//if(FL_DEBUG)level=5;
		levelTimer = TIME_MAX;

		initBg();
		mcInter = cast mdm.attach("mcInter",DP_INTER);
		mcInter.blendMode = "add";
		Filt.glow(mcInter,6,1,0xFFFFFF);
		//mcInter._alpha = 50;

		//initZone(10,10,40);
		initZone();
		initPlasma();

		initStep(Seek);

	}

	function initStep(n){
		step = n;
		switch(step){
			case Seek:

				map.onPress = select;
				map.onRelease = release;
				map.onReleaseOutside = release;
				KKApi.registerButton(map);
				mcTarget = dm.attach("mcSelector",DP_SELECTOR);
				mcTarget._yscale = mcTarget._xscale = size;
				mcTarget.blendMode = "add";
				mcTarget._visible = false;
				Filt.glow(mcTarget,10,1,0xFFFFFF);

			case Scroller(flQuit):
				coef = 0;
			case GameOver:
		}
	}

	//
	public function update(){
		if( FL_DEBUG && flash.Key.isDown(84)){
			haxe.Log.clear();
			haxe.Log.setColor(0xFFFFFF);
			var str = "";
			for( a in archive ){
				var n = Std.string(a.length);
				if(a==null)n="+";
				str = str+"-"+n;
			}
			trace("");
			trace(str);
		}


		// STEP
		switch(step){
			case GameOver:
			case Seek:	updateSeek();
			case Scroller(flQuit):
				coef = Math.min(coef+0.05*mt.Timer.tmod,1);
				var c = coef;
				if(!flQuit)c = 1-coef;
				selector.vx = c*100;
				selector.vy = c*0.5*100;

				if(coef==1){
					if(flQuit){
						map.removeMovieClip();
						initZone();
						initStep(Scroller(false));
					}else{
						initStep(Seek);
					}
				}

				var lim = 0.5;
				if( c > lim ){
					var ca = (c-lim)/lim;
					//Col.setPercentColor(root,ca*100,0xFFFFFF);
				}



		}

		// SPRITE
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();

		//
		updateFree();
		updateScroll();
		Plasma.updateAll();

		//plasma.drawMc(map,PLASMA_CACHE,PLASMA_CACHE);
		if( ccolorMax != colorMax || level!=clevel ){
			KKApi.flagCheater();
		}

	}

	// SEEK
	function updateSeek(){

		if(FL_DEBUG && flash.Key.isDown(flash.Key.SPACE) )initStep(Scroller(true));

		moveSelector();
		updateTarget();

		if(level>1)levelTimer = Math.max( levelTimer-mt.Timer.tmod, 0 );
		var c = levelTimer/TIME_MAX;
		mcInter.b0._xscale = c*100;
		mcInter.b1._xscale = c*100;
		if(levelTimer==0){
			initStep(GameOver);
			KKApi.gameOver(stats);
		}
	}
	function moveSelector(){
		var dx = root._xmouse-mcw*0.5;
		var dy = root._ymouse-mch*0.5;

		var lim = 50;
		var adx = Math.abs(dx);
		var ady = Math.abs(dy);
		var sx = dx/adx;
		var sy = dy/ady;

		if(adx>lim){
			dx = dx-lim*sx;
		}else{
			dx = 0;
		}
		if(ady>lim){
			dy = dy-lim*sy;
		}else{
			dy = 0;
		}

		var c = 0.1;
		selector.vx = dx*c;
		selector.vy = dy*c;
	}

	// SELECT
	function updateTarget(){

		var x = Math.floor( (root._xmouse - map._x)/size );
		var y = Math.floor( (root._ymouse - map._y)/size );



		if( mcTarget._x != x*size || mcTarget._y != y*size || flForceUpdateTarget || true ){
			flForceUpdateTarget = false;
			mcTarget._x = x*size;
			mcTarget._y = y*size;

			x = tx = gx(x);
			y = ty = gy(y);

			var type = grid[x][y];
			action = [0];

			if( colorId == null ){
				if( type == EMPTY ){
					var dirIndex = 0;
					for( d in DIR ){
						var nx = gx(x+d[0]);
						var ny = gy(y+d[1]);
						var t = grid[nx][ny];
						if( t>=10 && t<20 ){
							var col = t-10;
							if( archive[col] == null ){
								var td = getTargetDir();
								action = [1,col,dirIndex,1];
								if((td+2)%4==dirIndex)break;
							}
						}
						dirIndex++;
					}
				}
				if( type >= GENERATOR && archive[type-GENERATOR]!=null ){
					action = [2,type-GENERATOR];
				}
			}else{
				var first = path[0];
				if( first[0]==x  && first[1]==y ){
					action = [3];
				}else{
					var last = path[path.length-1];
					var dx = gdx(x-last[0]);
					var dy = gdy(y-last[1]);

					if( Math.abs(dx)+Math.abs(dy)==1 ){
						if( type == EMPTY ){
							var dirIndex =0;
							for( d in DIR ){
								if( d[0]==-dx && d[1]==-dy )break;
								dirIndex++;
							}
							action = [1,colorId,dirIndex];
						}
						if( type>=PAINT && type!=PAINT+colorId && free.length == 0 ){
							action = [4,type-PAINT];
						}
					}
				}
			}
			if(action[0]==1){
				mcTarget.gotoAndStop(2+action[2]);
				Col.setPercentColor(mcTarget,100,COLOR[action[1]]);
			}else{
				mcTarget.gotoAndStop(1);
				Col.setPercentColor(mcTarget,0,0);
			}

			if(flAutoSelect)select();
		}


		mcTarget._visible = action[0]>0;
		map.useHandCursor = mcTarget._visible;
		KKApi.registerButton(map);

	}
	function select(){
		flAutoSelect=true;
		var a = action;
		switch(a[0]){
			case 1:
				colorId = a[1];
				if( a[3]==1 ){
					var d = DIR[a[2]];
					path = [ [  gx(tx+d[0]), gy(ty+d[1]) ] ];
				}
				paint(tx,ty);
			case 2:
				free.push(getArchive(a[1]));
			case 3:
				giveUpRun();
			case 4:
				var p = getArchive(a[1]);
				var index = 0;
				for( pos in p){
					if(pos[0] == tx && pos[1] == ty)break;
					index++;
				}
				free.push(p.slice(0,index));
				var arr = p.slice(index+1,p.length);
				arr.reverse();
				free.push(arr);

				//
				paint(tx,ty);

		}
		action = [0];

		/*
		var type = grid[x][y];

		if( colorId == null ){
			if( type == EMPTY ){
				for( d in DIR ){
					var nx = gx(x+d[0]);
					var ny = gy(y+d[1]);
					var t = grid[nx][ny];
					if( t>=10 && t<20 ){
						var col = t-10;
						if( archive[col] == null ){
							colorId  = col;
							path = [[nx,ny]];
							paint(x,y);
							break;
						}
					}
				}
			}
			if( type >= GENERATOR ){
				var p = getArchive(type-GENERATOR);
				free.push(p);
			}


		}else{
			var first = path[0];
			if( first[0]==x  && first[1]==y ){
				giveUpRun();
			}else{
				var last = path[path.length-1];
				var dx = gdx(x-last[0]);
				var dy = gdy(y-last[1]);

				if( Math.abs(dx)+Math.abs(dy)==1 ){
					if( type == EMPTY ){
						paint(x,y);
					}
					if( type>=PAINT && type!=PAINT+colorId ){
						var p = getArchive(type-PAINT);

						var index = 0;
						for( pos in p){
							if(pos[0] == x && pos[1] == y)break;
							index++;
						}
						free.push(p.slice(0,index));
						free.push(p.slice(index,p.length).reverse());

					}
				}
			}
		}
		*/


	}
	function release(){
		flAutoSelect=false;
	}

	//
	public function getArchive(col){
		var p = archive[col];
		archive[col] = null;
		var a = getColGenerator(col);
		for( g in a )g.unlight();
		return p;
	}
	public function paint(x,y){
		path.push([x,y]);
		grid[x][y] = PAINT+colorId;
		KKApi.addScore(SCORE_DALLE);

		// PLASMA
		var r = new flash.geom.Rectangle(Std.int(x*size),Std.int(y*size),size,size);
		var o = Col.colToObj(COLOR[colorId]);
		var o2 = { r:o.r, g:o.g, b:o.b, a:120 };
		spectre.fillRect( r, Col.objToCol32( o2 ) );

		//SPARK
		var max = 4;
		for( i in 0...max ){
			var a = 6.28*i/max + (Math.random()*2-1)*0.3;
			var sp = new Rel(dm.attach("mcSpark",DP_PARTS));
			sp.x = (x+Math.random())*size;
			sp.y = (y+Math.random())*size;
			//var a = Math.atan2( sp.y-(y+0.5)*size, sp.x-(x+0.5)*size);
			//var ca = Math.cos(a);
			//var sa = Math.sin(a);
			//var speed = Math.random()*1;
			//sp.vx = ca*speed;
			//sp.vy = sa*speed;
			sp.timer = 10+Math.random()*10;
			sp.setScale(20+Math.random()*30);
			sp.frict = 0.98;
			sp.root.blendMode = "add";
			sp.relPoint = selector;
			sp.updatePos();
			sp.fadeType = 0;
			sp.root.gotoAndPlay(Std.random(sp.root._totalframes)+1);
		}


		//CHECK END
		for( d in DIR ){
			var nx = gx(x+d[0]);
			var ny = gy(y+d[1]);
			var t = grid[nx][ny];
			if( t == GENERATOR+colorId && ( path[0][0]!=nx || path[0][1]!=ny ) ){
				linkOk();
			}
		}

		//
		var rx = Math.floor(grx(x*size));
		var ry = Math.floor(gry(y*size));
		var inc = 1250;
		o2.r = 255;
		o2.g = 255;
		o2.b = 255;
		o2.a = 1000;

		plasma.fillRect( new flash.geom.Rectangle(rx,ry,size,size), Col.objToCol32(o2) );


	}
	function linkOk(){

		flAutoSelect = false;
		var a = getColGenerator(colorId);
		for(g in a )g.light();
		path.shift();
		archive[colorId] = path;

		path = null;
		colorId = null;
		//
		// CHECK END
		for( gen in generators ){
			if(gen.root._currentframe==1)return;
		}

		/*
		for( i in 0...colorMax )if(archive[i]==null){
			//trace("echec>"+i+"<");
			return;
		}
		*/
		//if(FL_DEBUG)trace("endOk!");
		initStep(Scroller(true));

	}
	function giveUpRun(){
		path.shift();
		free.push(path);
		freeTimer = 0;
		path = null;
		colorId=  null;

	}

	// FREE
	function updateFree(){
		if(freeTimer<=0){
			freeTimer = 0.5;
			for( a in free ){
				if(a.length>0){

					KKApi.addScore(SCORE_FREE);

					//
					var p = a.pop();
					var col = grid[p[0]][p[1]]-PAINT;
					grid[p[0]][p[1]]= EMPTY;
					var r = new flash.geom.Rectangle(Std.int(p[0]*size),Std.int(p[1]*size),size,size);
					spectre.fillRect(r,0x00000000);

					/// PLASMA
					var max = 5;
					var mc = dm.attach("mcExplo",0);
					for( i in 0...max ){
						var m = new flash.geom.Matrix();
						var sc = 0.5+Math.random()*4;
						m.scale(sc,sc);
						/*
						var x = (p[0]+Math.random())*size ;
						var y = (p[1]+Math.random())*size ;
						var dx = Num.hMod(selector.x-x,zw*0.5);
						var dy = Num.hMod(selector.y-y,zh*0.5);
						x = (selector.x-dx) + map._x ;
						y = (selector.y-dy) + map._y ;
						*/
						var x = grx( (p[0]+Math.random())*size );
						var y = gry( (p[1]+Math.random())*size );


						m.translate(x,y);
						var inc = 120;
						var co = Col.colToObj(COLOR[col]);
						var r = 40+co.r+Std.random(inc);
						var g = 40+co.g+Std.random(inc);
						var b = 40+co.b+Std.random(inc);

						var ct = new flash.geom.ColorTransform(0,0,0,1,r,g,b,0);
						plasma.draw(mc,m,ct,"add");

						/*
						mc._x = (p[0]+Math.random())*size;
						mc._y = (p[1]+Math.random())*size;
						mc._xscale = mc._yscale = 50+Math.random()*100;
						*/
						//plasma.drawMc(mc);



						/*

						*/
					}

					//SPARK
					var max = 3;
					for( i in 0...max ){
						var a = 6.28*i/max + (Math.random()*2-1)*0.3;
						var sp = new Rel(dm.attach("mcSpark",DP_PARTS));
						sp.x = (p[0]+Math.random())*size;// + ca*speed*cr;
						sp.y = (p[1]+Math.random())*size;// + sa*speed*cr;
						var a = Math.atan2( sp.y-(p[1]+0.5)*size, sp.x-(p[0]+0.5)*size);
						var ca = Math.cos(a);
						var sa = Math.sin(a);
						var speed = Math.random()*1;
						sp.vx = ca*speed;
						sp.vy = sa*speed;
						sp.timer = 10+Math.random()*10;
						sp.setScale(20+Math.random()*30);
						sp.frict = 0.98;
						sp.root.blendMode = "add";
						sp.relPoint = selector;
						sp.updatePos();
						sp.fadeType = 0;
						sp.root.gotoAndPlay(Std.random(sp.root._totalframes)+1);
					}

					//
					mc.removeMovieClip();

				}
				if(a.length==0){
					free.remove(a);
				}

			}
			flForceUpdateTarget = true;
		}else{
			if(free.length>0)freeTimer -= mt.Timer.tmod;
		}

	}

	// GRID GENERATION
	function genGrid(){
		grid = [];
		for( x in 0...xmax ){
			grid[x] = [];
			for( y in 0...ymax ){
				grid[x][y] = EMPTY;
			}
		}

		// placeGeneratorBasic();
		placeGeneratorAdvanced();

		for( x in 0...xmax ){
			for( y in 0...ymax ){
				if( grid[x][y] == EMPTY ) grid[x][y] = WALL;
				if( grid[x][y] == PATH ) grid[x][y] = EMPTY;
			}
		}

		// FALSE PATH
		var max = Std.int(Math.max(5, 60-level*6));
		var x = Std.random(xmax);
		var y = Std.random(ymax);
		var dIndex = Std.random(4);
		for( i in 0...max){
			if(Std.random(5)==0){
				dIndex = Std.int( Num.sMod( dIndex + Std.random(2)*2-1, 4 ) );
			}
			var d = DIR[dIndex];
			x=gx(x+d[0]);
			y=gy(y+d[1]);

			if( grid[x][y] == WALL ) grid[x][y] = EMPTY;

		}




	}
	function placeGeneratorBasic(){
		for( i in 0...colorMax ){
			for( n in 0...2 ){
				var p = getEmptyPos();
				grid[p.x][p.y] = 10+i;
			}
		}
	}
	function placeGeneratorAdvanced(){
		var rayMin = 3;
		var distMin = 6;



		for( i in 0...colorMax ){
			var to=0;
			while(true){

				var start = getEmptyPos();
				var p = {x:start.x,y:start.y};
				var path = [[p.x,p.y]];
				grid[p.x][p.y] = PATH;
				var parc = 0;
				var flValidate = false;
				while(true){
					var dir = shuffle( DIR );
					var flBlock = true;
					for ( d in dir ){
						var x = p.x + d[0];
						var y = p.y + d[1];
						var flOk = grid[x][y]==EMPTY;

						var nb = 0;
						for( p2 in path ){
							var dx = gdx(x-p2[0]);
							var dy = gdy(y-p2[1]);
							if( Math.abs(dx)+Math.abs(dy)==1 ){
								nb++;
								if(nb==2){
									flOk = false;
									break;
								}
							}
						}

						if( flOk ){
							path.push([x,y]);
							grid[x][y] = PATH;
							p.x = x;
							p.y = y;
							flBlock = false;
							break;
						}
					}

					parc++;
					var max = Math.min(level*3,14);
					if( flBlock || ( parc>max && Std.random(3)==0 ) ){
						flValidate = parc>3;
						break;
					}
				}
				if(flValidate){
					grid[start.x][start.y] = 10+i;
					grid[p.x][p.y] = 10+i;
					break;
				}else{
					for( p in path )grid[p[0]][p[1]] = EMPTY;
				}
				if( to++>100 ){
					break;
				}
			}
		}
	}
	function getEmptyPos(){
		var to = 0;
		while(true){
			var x = Std.random(xmax);
			var y = Std.random(ymax);
			if(grid[x][y]==EMPTY)return{x:x,y:y};
			if( to++ > 100 )break;
		}
		trace("can't find pos");
		return null;
	}

	// MAP - BG - SCROLL
	function initMap(){

		initGround();
		spectre = new flash.display.BitmapData(zw,zh,true,0x00000000);

		// MAP
		map = cast mdm.empty(DP_MAP);
		dm = new mt.DepthManager(map);
		for( x in 0...3 ){
			for( y in 0...3 ){
				var mc = dm.empty(DP_GROUND);
				mc.attachBitmap(ground,0);
				mc.attachBitmap(spectre,1);
				mc._x = (x-1)*zw;
				mc._y = (y-1)*zh;
			}
		}

		// SELECTOR
		selector = new Selector(dm.attach("mcRunner",DP_SELECTOR));
		selector.setScale(size);


		// ELEMENTS
		for( x in 0...xmax ){
			for( y in 0...ymax ){
				var type = grid[x][y];
				if(type>=10){
					var gen = new Generator(dm.attach("mcGenerator",DP_ELEMENT),type-10);
					gen.setPos(x,y);
				}

			}
		}




	}
	function initGround(){
		ground = new Bmp(dm.empty(DP_GROUND),zw,zh,true,0x0000FF00);
		var mc = mdm.attach("mcSquare",0);
		var sc = size/100;
		for( x in 0...xmax ){
			for( y in 0...ymax ){
				if( grid[x][y] != WALL ){
					var m = new flash.geom.Matrix();
					m.scale(sc,sc);
					m.translate(x*size,y*size);
					/*
					var inc = 20;
					var base = 140;
					var r = -(base+Std.random(inc));
					var g = -(base+Std.random(0));
					var b = -(base+Std.random(inc));
					var ct = new flash.geom.ColorTransform(1,1,1,1,r,g,b,0);
					/*/
					var ct = null;
					var inc = 20;
					Col.setColor( mc.smc, Col.objToCol({r:Std.random(inc),g:Std.random(inc),b:Std.random(inc)}), -20 );
					mc.gotoAndStop(Std.random(mc._totalframes)+1);

					//*/
					ground.draw(mc,m,ct);



				}
			}
		}
		mc.removeMovieClip();
	}
	function initBg(){

		scx = 0;
		scy = 0;

		plans = [];

		var infos = [
			{ d:DP_BG,	c:0.2,	lb:800,	col:0xFF002200	},
			{ d:DP_BG,	c:0.4,	lb:150,	col:0		},
			{ d:DP_BG,	c:0.7,	lb:40,	col:0		}
		];


		for( o in infos ){


			var bg:Plan = cast mdm.empty(o.d);
			bg.c = o.c;

			var dm = new mt.DepthManager(bg);
			var bmp = new flash.display.BitmapData(mcw,mch,true,o.col);
			for( x in 0...2 ){
				for( y in 0...2 ){
					var mc = dm.empty(0);
					mc.attachBitmap(bmp,0);
					mc._x = x*mcw;
					mc._y = y*mch;
				}
			}

			// LIGHT
			var mc = dm.attach("mcLight",0);
			for( i in 0...o.lb ){
				var ma = 3;
				var x = ma + (Math.random()*mcw-2*ma);
				var y = ma + (Math.random()*mch-2*ma);
				var m = new flash.geom.Matrix();
				var sc = (0.1+Math.random()*0.2)*o.c;
				m.scale(sc,sc);
				m.translate(x,y);
				bmp.draw(mc,m,null,"add");
			}
			mc.removeMovieClip();

			//
			plans.push(bg);

		}


		//bg._xscale =bg._yscale = 50;
	}
	function updateScroll(){
		// SCROLL
		var dx = (mcw*0.5-selector.x)-map._x;
		var dy = (mch*0.5-selector.y)-map._y;

		if(Math.abs(dx)+Math.abs(dy)<1)return;

		map._x += dx;
		map._y += dy;

		dx = Num.hMod(dx,Std.int(zw*0.5));
		dy = Num.hMod(dy,Std.int(zh*0.5));

		//haxe.Log.clear();
		//haxe.Log.setColor(0xFFFFFF);
		//trace(dx);
		//trace(dy);

		for( mc in plans ){
			mc._x = Num.sMod(mc._x+dx*mc.c,mcw)-mcw;
			mc._y = Num.sMod(mc._y+dy*mc.c,mch)-mch;
		};

		scx += dx;
		scy += dy;
		var ddx = Math.floor(Math.abs(scx)) * (scx/Math.abs(scx));
		var ddy = Math.floor(Math.abs(scy)) * (scy/Math.abs(scy));
		if(dx==0)ddx=0;
		if(dy==0)ddy=0;

		scx -= ddx;
		scy -= ddy;
		plasma.scroll(Math.floor(ddx),Math.floor(ddy));



		/*
		var c = 0.3;
		bg._x = Num.sMod(bg._x+dx*c,mcw)-mcw;
		bg._y = Num.sMod(bg._y+dy*c,mch)-mch;
		*/

	}

	// PLASMA
	function initPlasma(){
		var m = PLASMA_CACHE;
		plasma = new Plasma(mdm.empty(DP_PLASMA), mcw+2*m, mch+2*m, 1 );
		plasma.setPos(-m,-m);
		var fl = new flash.filters.BlurFilter();
		fl.blurX = 2;
		fl.blurY = 2;
		plasma.filters.push(fl);

		var inc = -10;
		var mult = 1.1;
		plasma.ct = new flash.geom.ColorTransform(mult,mult,mult,1,inc,inc,inc, -16 );

	}

	// LEVEL
	public static var LEVEL = [
		{ size:60, cmax:2 },
		{ size:50, cmax:3 },
		{ size:50, cmax:4 },
		{ size:40, cmax:5 },
		{ size:40, cmax:6 },
		{ size:40, cmax:7 },
		{ size:40, cmax:7 },
		{ size:40, cmax:8 }
	];

	function initZone(){

		var o = LEVEL[Std.int(Math.min(level,LEVEL.length-1))];

		level++;
		clevel++;

		path = [];
		free = [];
		generators = [];
		archive = [];


		//
		var sz =  o.size;
		var side = Math.ceil(mcw/sz*0.5)*2 + 2;

		xmax = side;
		ymax = side;
		size = sz;
		zw = Std.int(xmax*size);
		zh = Std.int(ymax*size);
		Rel.ZW = zw;
		Rel.ZH = zh;

		colorMax =  o.cmax;
		ccolorMax = o.cmax;
		//for( i in 0...colorMax) archive[i] = [];

		levelTimer = Math.min( (levelTimer+TIME_BONUS)-level*20 ,TIME_MAX );
		var str = Std.string(level);
		if(str.length==1)str = "0"+str;
		mcInter.field.text = "LEVEL'"+str;

		genGrid();
		initMap();


	}


	// TOOLS
	function getTargetDir(){
		var dx = (mcTarget._x+size*0.5+map._x) - root._xmouse;
		var dy = (mcTarget._y+size*0.5+map._y) - root._ymouse ;

		if(dx==0)dx=0.1;
		if(dy==0)dy=0.1;

		var sx = dx/Math.abs(dx);
		var sy = dy/Math.abs(dy);
		if(Math.abs(dx)>Math.abs(dy)) sy = 0; else sx=0;

		var dirIndex = 0;
		for( d in DIR ){
			if( sx == d[0] && sy == d[1] )break;
			dirIndex++;
		}
		if(dirIndex==4){
			trace("-- ("+sx+","+sy+") --");
			return 0;
		}
		return dirIndex;


		/*
		haxe.Log.clear();
		haxe.Log.setColor(0xFFFFFF);
		trace("");
		trace(dx+","+dy);
		*/
	}

	function shuffle(list:Array<Array<Int>>):Array<Array<Int>>{
		var pos = [];
		for( n in 0...list.length )pos.push(n);
		var a = [];
		while(pos.length>0){
			var index = Std.random(pos.length);
			var n = pos[index];
			pos.splice(index,1);
			a.push(list[n]);
		}
		return a;
	}

	static public function getGenerator(x,y){
		for( g in Game.me.generators ){
			if(g.px == x && g.py ==y )return g;
		}
		trace("generator not found at "+x+","+y+"!");
		return null;
	}
	static public function getColGenerator(type){
		var a = [];
		for( g in Game.me.generators ){
			if(g.type == type )a.push(g);
		}
		return a;
	}

	static public function gx(x){
		return Std.int(Num.sMod(x,Game.me.xmax));
	}
	static public function gy(y){
		return Std.int(Num.sMod(y,Game.me.ymax));
	}
	static public function gdx(x){
		return Std.int(Num.hMod(x,Std.int(Game.me.xmax*0.5)));
	}
	static public function gdy(y){
		return Std.int(Num.hMod(y,Std.int(Game.me.ymax*0.5)));
	}
	static public function grx(x:Float){
		var dx = Num.hMod(Game.me.selector.x-x,Game.me.zw*0.5);
		return (Game.me.selector.x-dx) + Game.me.map._x ;
	}
	static public function gry(y:Float){
		var dy = Num.hMod(Game.me.selector.y-y,Game.me.zh*0.5);
		return (Game.me.selector.y-dy) + Game.me.map._y ;
	}
	//
	public function mouseScroll(){
		var c = 0.1;
		var vx = -(root._xmouse-mcw*0.5)*c;
		var vy = -(root._ymouse-mch*0.5)*c;
		map._x = Num.sMod( map._x+vx*mt.Timer.tmod, zw);
		map._y = Num.sMod( map._y+vy*mt.Timer.tmod, zh);

	}


	// X BUG SELECT DIGONALE
	// X SYSTEME DE TEMPS
	// X SYSTEME DE POINT
	// X AFFICHAGE DU LEVEL
	// X PARTICULES
	// X MONTRER LES CASES JOUABLES
	// X DESACTIVER PATH SUR CLICK GENERATOR


//{
}













