import mt.bumdum.Lib;


/*
typedef Info = {
		pop:Int,
		ind:Int,
		env:Int,
		sec:Int,
		com:Int,
		tra:Int
}
*/


typedef Bat = {	x:Float, y:Float, size:Int, type:Int, rand:Float }
typedef StatSlot = {	>flash.MovieClip, fieldName:flash.TextField, fieldPrc:flash.TextField };
typedef BrushHouse = { bmp:flash.display.BitmapData, dx:Int, dy:Int };


enum Step {
	Connect;
	Load;
	Lib;
	Build;
	Draw;
	Show;
}


class Game {//}

	public static var FL_DEBUG = 	false;
	public static var FL_VISION = 	false;
	public static var FL_INTERFACE = false;

	public static var DP_BRUSH = 	0;
	public static var DP_BG = 	1;
	public static var DP_MAP = 	5;
	public static var DP_INTER =	8;
	public static var DP_LAYER = 	9;
	public static var DP_DEBUG = 	10;

	var flPaglop:Bool;
	var flMoveMap:Bool;

	public var buildIndex:Int;
	public var nameSeed:Int;
	public var seed:mt.Random;

	public var name:String;
	public var info:Core;

	var densityMax:Int;
	var roadCoef:Float;
	var chomCoef:Float;
	var polCoef:Float;
	var crimCoef:Float;
	var income:Int;
	var anti:Int;
	var scale:Float;
	var displaySide:Float;
	public var displayMargin:Int;

	var dragPoint:{x:Float,y:Float,sx:Float,sy:Float};

	public var bmpPop:flash.display.BitmapData;
	public var bmpWood:flash.display.BitmapData;
	public var displayGrid:Array<Array<flash.display.BitmapData>>;
	public var bats:Array<Bat>;
	public var sbats:Array<Array<Bat>>;
	public var sgrid:Array<Array<Float>>;
	public var rgrid:Array<Array<Int>>;
	public var wgrid:Array<Array<Int>>;

	public var bmpLib:Array<Array<Array< BrushHouse >>>;

	public var step:Step;

	public var brushDalle:flash.MovieClip;
	public var brushRoad:flash.MovieClip;
	public var brushHouse:flash.MovieClip;
	public var brushObs:flash.MovieClip;
	public var brushTest:flash.MovieClip;

	public var mcStat:{>flash.MovieClip,list:Array<StatSlot>,flOpen:Bool, flMove:Bool, panel:flash.MovieClip };
	public var mcLoading:{>flash.MovieClip,fieldLog:flash.TextField,lb:flash.MovieClip,lb2:flash.MovieClip, build:flash.MovieClip };

	public var map:flash.MovieClip;
	public var mcInter:flash.MovieClip;
	public var mcAnalog:{>flash.MovieClip,panel:flash.MovieClip};
	public var mcAntiPanel:{>flash.MovieClip,field:flash.TextField,dec:Float};

	var lc: flash.LocalConnection;

	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var dm:mt.DepthManager;
	static public var me:Game;

	public function new(mc:flash.MovieClip) {



		root = mc;
		dm = new mt.DepthManager(root);
		me = this;

		scale = 1;


		info = new Core();

		info.pop = Std.parseInt( Reflect.field(flash.Lib._root,"pop") );
		info.ind = Std.parseInt( Reflect.field(flash.Lib._root,"ind") );
		info.env = Std.parseInt( Reflect.field(flash.Lib._root,"env") );
		info.sec = Std.parseInt( Reflect.field(flash.Lib._root,"sec") );
		info.tra = Std.parseInt( Reflect.field(flash.Lib._root,"tra") );
		info.com = Std.parseInt( Reflect.field(flash.Lib._root,"com") );

		info.deb = Std.parseInt( Reflect.field(flash.Lib._root,"deb") );
		var a = Reflect.field(flash.Lib._root,"sta").split(",");
		info.build = [];
		for(str in a )info.build.push( Std.parseInt(str) );

		name = Reflect.field(flash.Lib._root,"name");
		var str = Reflect.field(flash.Lib._root,"anti");
		if(str!=null)anti = Std.parseInt(str);




		// POPULATION
		if( FL_DEBUG ){
			anti = 1200;
			info.pop = 10000;
			info.ind = Std.int(info.pop*0.3);
			info.env = Std.int(info.pop*0.15);
			info.sec = Std.int(info.pop*0.2);
			info.tra = Std.int(info.pop*0.15);
			info.com = Std.int(info.pop*0.25);
			name = "bumdum";
		}else{
			var k = Reflect.field(flash.Lib._root,"k");
			var mk = haxe.Md5.encode(info.pop+";"+info.ind+";"+info.tra+";"+info.sec+";"+info.env+";"+info.com).substr(0,5);
			if(k!=mk){
				Col.setColor(root,0xFFFFFF,-50);
			}
		}
		Cs.init(info.pop);


		//
		initSeed();

		rgrid = [];
		var max = Cs.SIDE;
		for( x in 0...max ){
			rgrid[x] = [];
			for( y in 0...max ){
				rgrid[x][y] = seed.random(100000);
			}
		}


		// initSeed();
		// haxe.Md5.encode(name+";"+pop+";"+ind+";"+tra+";"+sec+";"+env+";"+com).substr(0,5) == k


		init();


		/*
L'embuscade aura lieu en zone rétropéritonéal. La densité organique de la cavité devrait nous permettre d'approcher discretement les cosmos ennemis. A l'assaut !
		*/

	}

	function init(){

		bg = dm.attach("mcBg",DP_BG);
		bg.stop();
		mcLoading = cast dm.attach("mcLoading",DP_INTER);
		mcLoading.build.stop();

		genSubInfo();
		genMapPop();

		initConnect();

		// ANTI
		if(anti!=null){
			var mc = dm.attach("mcAntiLayer",DP_LAYER);
			mc.gotoAndStop(2);
			mc._alpha = 20;

			var mc = dm.attach("mcAntiLayer",DP_LAYER);
			mc.stop();
			mc._alpha = 50;
			mc.blendMode = "overlay";
		}


	}

	function initConnect(){
		step = Connect;
		mcLoading.fieldLog.text = "connexion en cours...";
		lc = new flash.LocalConnection();
	}
	function updateConnect(){
		if( lc.connect("miniville") ){
			initLib();
		}
	}

	function initSeed(){
		if(nameSeed==null){
			var n = 0;
			var a = name.split("");
			for( chr in a )n += Std.ord(chr);
			nameSeed = n;
		}
		seed = new mt.Random(nameSeed);

	}
	public function update() {

		control();

		switch(step){
			case Connect: updateConnect();
			case Lib: updateLib();
			case Build: updateBuild();
			case Draw: updateDraw();
			case Show: updateShow();
			default:
		}

		if( mcStat.flMove )updateStats();

		if(mcAntiPanel!=null){
			mcAntiPanel.dec = (mcAntiPanel.dec+13)%628;
			mcAntiPanel.filters = [];
			var c = Math.cos(mcAntiPanel.dec*0.01);
			Filt.glow(mcAntiPanel,10+c*5,2+c,0xFFFFFF);
		}

	}

	//
	function genMapPop(){
		bmpPop = new flash.display.BitmapData( Cs.SIDE, Cs.SIDE, false, 0 );


		initSeed();

		//SGRID
		sgrid = [];
		for( x in 0...Cs.SIDE){
			sgrid[x] = [];
			for( y in 0...Cs.SIDE) sgrid[x][y] = null;
		}

		// OBSTACLES
		var max = seed.random(10);
		for( i in 0...max ){
			var x = seed.random(Cs.SIDE);
			var y = seed.random(Cs.SIDE);
			if( Math.abs(x-Cs.SIDE*0.5)+Math.abs(y-Cs.SIDE*0.5) > 3 ){
				sgrid[x][y] = seed.rand();
			}
		}

		// MERVEILLES
		/*
		wgrid = [];
		var ss = new mt.Random(nameSeed);
		var id = 0;
		for( n in info.build ){
			if(n!=null){
				//wgrid.push( n, [ss.random(Cs.SIDE), ss.random(Cs.SIDE)] );
			}
			id++;
		}
		*/

		// WOOD
		bmpWood = new flash.display.BitmapData(Cs.SIDE,Cs.SIDE,false,0);
		var max = 35;//5+seed.random(30);
		var brush = dm.attach("brushWood",0);
		for( n in 0...max ){
			var m = new flash.geom.Matrix();
			m.translate(seed.random(Cs.SIDE),seed.random(Cs.SIDE));
			bmpWood.draw(brush,m);
		}
		brush.removeMovieClip();



		// REPARTITION
		var n = 0;
		densityMax = 0;
		while( n < info.pop ){

			/*
			var lim = 1.0;
			if(n>50)lim = Math.pow(n,0.3);
			var maxInc = Math.min(Math.max(1, lim ),1);
			var inc = seed.random(Std.int(maxInc))+1;
			*/

			var inc = 1;
			if(n>50)inc = 5;
			//if(n>500)inc = 10;


			var rayMax = getRayMax(n);

			var ray = seed.rand()*rayMax;
			var a = seed.rand()*6.28;
			var x = Std.int( Cs.SIDE*0.5+ Math.cos(a)*ray);
			var y = Std.int( Cs.SIDE*0.5+ Math.sin(a)*ray);

			var color = Math.min( bmpPop.getPixel(x,y)+inc, 255);
			densityMax = Std.int( Math.max(densityMax, color) );
			bmpPop.setPixel( x, y, Std.int(color) );
			n+=inc;
		}


		// SOFT
		var fl = new flash.filters.BlurFilter();
		fl.blurX = 2;
		fl.blurY = 2;



		// VISION
		if(FL_VISION){
			var mc = dm.empty(DP_DEBUG);
			mc._xscale = mc._yscale = 600;
			mc.attachBitmap(bmpPop,0);
		}




	}
	function genSubInfo(){

		roadCoef = info.getRoadCoef();//Math.min( (info.tra*5+30) / info.pop , 1 );
		chomCoef = info.getChomCoef();
		polCoef =  info.getPolCoef();
		crimCoef = info.getCrimCoef();
		income =  info.getIncomes();
	}

	// LIB
	function initLib(){


		bmpLib = [];
		for( i in 0...10 )bmpLib.push([]);
		buildIndex = 0;
		mcLoading.fieldLog.text = "construction lib";
		mcLoading.lb._xscale = 0;
		mcLoading.lb2._xscale = 0;

		brushHouse = dm.attach("mcHouse",DP_BRUSH);
		var mc = brushHouse;

		step = Lib;

		/*
		//var t = flash.Lib.getTimer();

		for( n in 0...mc._totalframes ){
			mc.gotoAndStop(n+1);
			bmpLib.push([]);

			for( n2 in 0...mc.smc._totalframes ){
				mc.smc.gotoAndStop(n2+1);
				bmpLib[n].push([]);
				var max = mc.smc.smc._totalframes;
				var mmc = mc.smc.smc;
				if( mmc==null ){
					max=1;
					mmc = mc.smc;
				}
				for( n3 in 0...max ){
					mc.smc.smc.gotoAndStop(n3+1);
					var b = mmc.getBounds(mmc);
					var ww = Math.ceil(mc._width);
					var hh = Math.ceil(mc._height);
					var bmp = new flash.display.BitmapData(ww,hh,true,0);
					var dx = Math.floor(b.xMin);
					var dy = Math.floor(b.yMin);
					var m = new flash.geom.Matrix();
					m.translate(-dx,-dy);
					bmp.draw(mc,m);
					bmpLib[n][n2].push({bmp:bmp,dx:dx,dy:dy});
					//trace(ww+";"+hh);
					//trace(dx+";"+dy);


				}
			}

		}

		//trace( flash.Lib.getTimer()-t );
		//displayLib(1);
		*/

	}
	function updateLib(){
		var mc = brushHouse;
		mc.gotoAndStop(buildIndex+1);

		for( n2 in 0...mc.smc._totalframes ){
			mc.smc.gotoAndStop(n2+1);
			bmpLib[buildIndex].push([]);
			var max = mc.smc.smc._totalframes;
			var mmc = mc.smc.smc;
			if( mmc==null ){
				max=1;
				mmc = mc.smc;
			}
			for( n3 in 0...max ){
				mc.smc.smc.gotoAndStop(n3+1);
				var b = mmc.getBounds(mmc);
				var ww = Math.ceil(mc._width);
				var hh = Math.ceil(mc._height);
				var bmp = new flash.display.BitmapData(ww,hh,true,0x00FFFFFF );
				var dx = Math.floor(untyped b["xMin"]);
				var dy = Math.floor(untyped b["yMin"]);
				var m = new flash.geom.Matrix();
				m.translate(-dx,-dy);
				bmp.draw(mc,m);
				bmpLib[buildIndex][n2].push({bmp:bmp,dx:dx,dy:dy});
			}
		}

		var lim = mc._totalframes;

		mcLoading.lb._xscale = (buildIndex/lim)*100;
		mcLoading.lb2._xscale = (buildIndex/lim)*100;

		if( buildIndex==lim ){
			initBuild();
			return;
		};

		buildIndex++;
		if( buildIndex==1 && densityMax<Cs.POP_BIG )buildIndex++;
		if( buildIndex==2 && densityMax<Cs.POP_HUGE )buildIndex++;

		//displayLib(0);

	}
	function displayLib(n){
		var bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0x444444);
		dm.attachBitmap(bmp,DP_DEBUG);
		var x = 0;
		var y = 0;
		var yMax = 0;


		var a = bmpLib[n];
		for( a2 in a){
			for( o in a2){
				if( x+o.bmp.width>Cs.mcw ){
					x = 0;
					y = yMax;
				}

				var m = new flash.geom.Matrix();
				m.translate(x,y);
				bmp.draw(o.bmp,m);

				yMax = Std.int(Math.max(yMax,y+o.bmp.height));
				x += o.bmp.width;
			}
		}

	}

	// BUILD
	function initBuild(){
		step = Build;
		buildIndex = 0;
		mcLoading.fieldLog.text = "génération";
		mcLoading.lb._xscale = 0;
		mcLoading.lb2._xscale = 0;
		bats = [];
		sbats = [[],[],[]];


		//
		var ray = getRayMax(info.pop)+1;
		var dif = Cs.SIDE-ray*2;
		displayMargin = Std.int(Math.max(0,dif*0.5));
		if(anti!=null)displayMargin = 12;

		var side = Cs.SIDE-2*displayMargin;
		displaySide = side;


		//


		var ww = Cs.SQUARE_SIDE*Cs.WW*Cs.SIDE;
		var hh = Cs.SQUARE_SIDE*Cs.HH*Cs.SIDE;

		displayGrid = [];
		var base = Cs.BMP_SIZE_MAX;
		var xMax = Std.int(ww/base)+1;
		var yMax = Std.int(hh/base)+1;
		for( x in 0...xMax ){
			displayGrid[x] = [];
			for( y in 0...yMax ){
				displayGrid[x][y] = new flash.display.BitmapData(base,base,true,0x00000000 );
			}
		}


		//bmpDisplay = new flash.display.BitmapData(ww,hh,true,0xFFFF0000 );
		//brushDalle = dm.attach("mcDalle",DP_BRUSH);
		//brushRoad = dm.attach("mcRoad",DP_BRUSH);
		//brushObs= dm.attach("mcObs",DP_BRUSH);



	}
	function updateBuild(){


		var st = flash.Lib.getTimer();
		var lim = Math.pow(displaySide,2);
		while( flash.Lib.getTimer()-st < 80 ){
			var x = displayMargin+Std.int(buildIndex/displaySide);
			var y = displayMargin+Std.int(buildIndex%displaySide);
			genSquare(x,y);
			buildIndex++;
			if( buildIndex >= lim ){
				initDraw();
				return;
			}
		}

		var coef = buildIndex/lim;
		mcLoading.lb._xscale = coef*100;
		mcLoading.lb2._xscale = coef*100;
		setLoadingBuild(coef*0.5);

	}
	function setLoadingBuild(c:Float){
		mcLoading.build.gotoAndStop(Std.int(c*mcLoading.build._totalframes)+1);
	}

	function genSquare(bx,by){




		var x = bx*Cs.SQUARE_SIDE;
		var y = by*Cs.SQUARE_SIDE;
		var pop = bmpPop.getPixel(bx,by);


		// GROUND
		//var m = new flash.geom.Matrix();
		//m.translate( Cs.getX(x,y), Cs.getY(x,y) );
		//draw( brushDalle, m );
		addBat(x,y,5,0);

		// BIG ROADS
		var flRoad = false;
		var sd = new mt.Random( rgrid[bx][by] );
		brushRoad.gotoAndStop(1);
		for( n in 0...2 ){
			var d = Cs.DIR[n];
			var c = 0.0;
			var bis = 0;
			for( i in 0...2 ){
				var sens = (i*2)-1;
				var nx = bx+d[0]*sens;
				var ny = by+d[1]*sens;
				var pp = bmpPop.getPixel(nx,ny)*0.25;
				if(pp>0)bis++;
				c+=pp;

			}
			if(pop>1)c+=pop*0.5;
			if( pop==0 && bis<2 ){
				c = 0;
			}

			if( c*roadCoef>=1 ){
				/*
				brushRoad.smc._xscale = (n*2-1)*100;
				var frame = 1;
				if(c*roadCoef>=1.5)frame++;
				if(c*roadCoef>=5)frame++;
				brushRoad.smc.gotoAndStop(frame);
				draw( brushRoad, m );
				//*/

				var fr = 3*n;
				if(c*roadCoef>=1.5)fr++;
				if(c*roadCoef>=5)fr++;
				addBat( x, y, 3, fr  );
				//*/
				//trace(fr);

				flRoad = true;
			}
		}


		// BATIMENT
		var obs = sgrid[bx][by];


		if( obs!=null ){
			addBat(x,y,0,16,obs);
		}else if( pop>0   ){



			if( pop < Cs.POP_HUGE ){


				/// CROSS ROADS
				var scoreRoad =pop*(0.1+roadCoef*0.9);
				if( scoreRoad >6 ){
					/*
					brushRoad.gotoAndStop(2);
					var frame = 1;
					if(scoreRoad>9)frame++;
					brushRoad.smc.gotoAndStop(frame);
					var m = new flash.geom.Matrix();
					m.translate( Cs.getX(x,y), Cs.getY(x,y) );
					draw( brushRoad, m );
					*/
					var fr = 0;
					if(scoreRoad>9)fr++;
					addBat( x, y, 4, fr  );
				}



				// REPARTITION
				var rep = [0,0,0,0,0];
				var sd = new mt.Random( rgrid[bx][by] );
				for( i in 0...pop ){
					var id = sd.random(4);
					rep[id]++;
				}

				// DRAW MINISQUARE
				for( i in 0...4 ){
					var px = (i%2)*4;
					var py = Std.int( i/2 )*4;
					if(px>1)px+=1;
					if(py>1)py+=1;
					genMiniSquare(x+px,y+py,rep[i],false,bx,by,i);
				}


			}else{
				addBat(x,y,2,0,sd.rand());
			}
		}else{
			var sd = new mt.Random( rgrid[bx][by] );
			var sidePop = 0;
			for( d in Cs.DIR )sidePop += bmpPop.getPixel(bx+d[0],by+d[1]);

			//trace(sidePop < 50 );
			//trace(sidePop);
			if(sidePop >= 2 && sidePop < 50 && !flRoad ){
				addBat( x, y, 0, 15, sd.rand() );

			}else{
				// FOREST


				var wcol = Col.colToObj(bmpWood.getPixel(bx,by));
				var max = Std.int(24*wcol.b/255);



				var list:Array<Array<Float>> = [];
				for( i in 0...max )list.push([sd.rand(),sd.rand()]);

				var f = function (a:Array<Float>,b:Array<Float>){
					var ay = Cs.getY(a[0],a[1]);
					var by = Cs.getY(b[0],b[1]);

					if(ay>by)return 1;
					return -1;
				}
				list.sort(f);
				for( p in list ){
					var margin = 0.5;
					if(flRoad)margin += 1;
					var tx = x+p[0]*(Cs.SQUARE_SIDE-margin);
					var ty = y+p[1]*(Cs.SQUARE_SIDE-margin);
					addBat(tx,ty,0,14,sd.rand());
				}

			}



		}


	}
	function genMiniSquare(bx:Int,by:Int,pop,flSpecial,rx,ry,n){

		var rval = rgrid[rx][ry]*(n+1);
		//var rval = Std.random(10000);



		if(pop==0){
			var sd  = new mt.Random( rval+2 );
			addBat( bx, by, 1, 2, sd.rand() );

		}else if( pop<Cs.POP_BIG ){

			// REPARTITION
			var rep = [0,0,0,0];
			var sd = new mt.Random( rval );
			for( i in 0...pop ){
				var id = sd.random(4);
				rep[id]++;
			}


			var sd =new mt.Random( rval );
			for( i in 0...4 ){
				var rand = sd.rand();
				var rand2 = sd.random(Cs.PROBA_SPECIAL);
				if(rep[i]>0){
					var nx = bx + (i%2)*2;
					var ny = by + Std.int( i/2 )*2;
					var m = new flash.geom.Matrix();
					m.translate( Cs.getX(nx,ny), Cs.getY(nx,ny) );

					var id = 0;
					if( pop<Cs.POP_PEON ){
						id = 12;
					}else if(rep[i]>Cs.POP_NORMAL){
						var type = getBatType(bx,by,sd);
						id += 2*(1+type);
					}

					if(rand2==0)	id+=1;
					addBat( nx, ny, 0, id, rand );
				}
			}

		}else{
			var sd  = new mt.Random( rval+1 );
			var id = 0;
			if( sd.random( Std.int(Cs.PROBA_SPECIAL*0.1) ) == 0 )id++;
			addBat( bx, by, 1, id, sd.rand() );
		}


	}

	function addBat(x:Float,y:Float,size,type, ?rand:Float  ){			// PB TYPAGE
		var bat:Bat = { x:x, y:y, size:size, type:type, rand:rand };
		bats.push(bat);
		sbats[size].push(bat);
	}
	function getBatType(x,y,sd:mt.Random){

		var dx = x-(Cs.SIDE*Cs.SQUARE_SIDE)*0.5;
		var dy = y-(Cs.SIDE*Cs.SQUARE_SIDE)*0.5;
		var dist = Math.sqrt(dx*dx+dy*dy);

		var a = [];
		a.push( info.pop );

		var coef = dist/ (getRayMax(info.pop)*Cs.SQUARE_SIDE);

		a.push( Std.int(info.ind*(coef*5) ) );
		a.push( info.env*2 );
		a.push( Std.int(info.sec*0.2) );
		a.push( Std.int(info.com*0.75) );


		var sum = 0;
		for( n in a )sum+=n;

		var rnd = Std.int(sd.rand()*sum);

		sum = 0;
		var type = 0;
		for( n in a ){
			sum += n;
			if( sum >= rnd)break;
			type++;
		}
		return type;
	}

	// DRAW
	function initDraw(){
		step = Draw;
		mcLoading.fieldLog.text = "affichage";
		buildIndex = 0;
		//brushHouse = dm.attach("mcHouse",DP_BRUSH);


	}
	function updateDraw(){

		var st = flash.Lib.getTimer();
		while( flash.Lib.getTimer()-st < 80 ){
			var bat = bats[buildIndex];
			/*
			var m = new flash.geom.Matrix();
			m.translate( Cs.getX(bat.x,bat.y), Cs.getY(bat.x,bat.y) );
			brushHouse.gotoAndStop(bat.size+1);
			brushHouse.smc.gotoAndStop(bat.type+1);
			var frame = Std.int(bat.rand*brushHouse.smc.smc._totalframes)+1;
			brushHouse.smc.smc.gotoAndStop(frame);
			draw(brushHouse,m);
			*/
			var a = bmpLib[bat.size][bat.type];
			var n = Std.int(bat.rand*a.length);
			if(bat.rand==null)n=0;
			var o = a[n];
			var m = new flash.geom.Matrix();
			m.translate( Cs.getX(bat.x,bat.y)+o.dx, Cs.getY(bat.x,bat.y)+o.dy );

			drawBmp(o.bmp,m);

			//*/


			buildIndex++;
			if( buildIndex == bats.length ){
				showMap();
				break;
			}
		}


		var coef = buildIndex/bats.length;
		mcLoading.lb._xscale = coef*100;
		mcLoading.lb2._xscale = coef*100;

		setLoadingBuild(0.5+coef*0.5);

	}
	function draw(mc:flash.MovieClip,m:flash.geom.Matrix){
		//var bmp = displayGrid[0][0];
		var b = mc.getBounds(mc);
		var cs = Cs.BMP_SIZE_MAX;

		var xMin = Std.int( (m.tx+b.xMin)/cs );
		var xMax = Std.int( (m.tx+b.xMax)/cs );
		var yMin = Std.int( (m.ty+b.yMin)/cs );
		var yMax = Std.int( (m.ty+b.yMax)/cs );

		for( x in xMin...xMax+1 ){
			for( y in yMin...yMax+1 ){
				var bmp = displayGrid[x][y];
				var mm = m.clone();
				mm.translate( -x*cs, -y*cs );
				bmp.draw(mc,mm);
			}
		}
	}

	function drawBmp(bmp:flash.display.BitmapData,m:flash.geom.Matrix){



		var cs = Cs.BMP_SIZE_MAX;
		var xMin = Std.int( (m.tx)/cs );
		var xMax = Std.int( (m.tx+bmp.width)/cs );
		var yMin = Std.int( (m.ty)/cs );
		var yMax = Std.int( (m.ty+bmp.height)/cs );


		for( x in xMin...xMax+1 ){
			for( y in yMin...yMax+1 ){
				var bmp2 = displayGrid[x][y];
				var mm = m.clone();
				mm.translate( -x*cs, -y*cs );
				//bmp2.draw(bmp,mm);
				var p =  new flash.geom.Point(Std.int(mm.tx),Std.int(mm.ty));
				bmp2.copyPixels(bmp, bmp.rectangle, p, bmp, new flash.geom.Point(0,0), true );

			}
		}


	}

	// INTER
	function initInterface(){
		if(anti!=null){
			mcAntiPanel = cast dm.attach("mcAntiPanel",DP_LAYER);
			mcAntiPanel._x = Cs.mcw*0.5;
			mcAntiPanel._y = Cs.mch*0.5;
			mcAntiPanel.field.text = Std.string(anti);
			mcAntiPanel.dec = 0;
			return;
		}

		if(FL_INTERFACE){

			mcInter = dm.empty(DP_INTER);
			mcInter._y = Cs.mch;
			var idm = new mt.DepthManager(mcInter);

			// COMPTEUR :
			var slot:{>flash.MovieClip, field:flash.TextField, mid:flash.MovieClip, b1:flash.MovieClip } = cast idm.attach("mcCompt",0);
			slot._x = 22;
			slot._y = -22;
			slot.field.text = Std.string(info.pop);
			var ww = slot.field.textWidth+12;
			slot.b1._x  = ww;
			slot.mid._xscale  = ww;

			// STATISTIQUES :
			initStats();
		}


		// ANALOG
		initAnalog();

		//
		map.onPress = pressMap;
		map.onRelease = releaseMap;
		map.onReleaseOutside = releaseMap;

	}
	function initStats(){
		mcStat = cast dm.attach("mcStats",DP_INTER);
		mcStat._x = Cs.mcw-180;
		mcStat._y = 8;
		mcStat.onPress = clickStats;
		mcStat.onRelease = releaseStats;
		mcStat.flOpen = false;
		mcStat.flMove = false;

		mcStat.panel = new mt.DepthManager(mcStat).empty(0);
		mcStat.panel._visible = false;

		var dm = new mt.DepthManager(mcStat.panel);
		var a = [ "chomage", "transport", "pollution", "criminalite" ];
		var pList = [Std.int(chomCoef*100),Std.int(roadCoef*100),Std.int(polCoef*100),Std.int(crimCoef*100)];
		for( i in 0...4 ){
			var mc:StatSlot = cast dm.attach("mcStatSlot",0);
			var prc = pList[i];

			mc._x = 10;
			mc._y = 26+i*23;
			mc.fieldName.text = a[i];
			mc.fieldPrc.text = prc+"%";

			var textColor = 0x338103;

			var cprc = prc;
			if( i == 1 ) cprc = 100-prc;

			if( cprc > 50 ) textColor = 0xFF9900;
			if( cprc > 80 ) textColor = 0xEE0000;
			if( cprc == 100) textColor = 0x880000;

			mc.fieldPrc.textColor = textColor;

		}
	}

	function clickStats(){
		mcStat.flOpen = !mcStat.flOpen;
		mcStat.flMove = true;
	}
	function releaseStats(){

	}
	function updateStats(){
		if( mcStat.flOpen ){
			mcStat.nextFrame();
			if(mcStat._currentframe == mcStat._totalframes ){
				mcStat.flMove = false;
				mcStat.panel._visible = true;
			}
		}else{
			mcStat.prevFrame();
			if(mcStat._currentframe == 1 ) mcStat.flMove = false;
			mcStat.panel._visible = false;
		}


	}

	function initAnalog(){


		var m = 26;
		mcAnalog = cast dm.attach("mcAnalog",DP_INTER);
		mcAnalog._x = Cs.mcw-m;
		mcAnalog._y = Cs.mch-m;
		mcAnalog.smc.stop();
		Filt.glow(mcAnalog,2,4,0xFFFFFF);
		mcAnalog.panel._visible = false;

		mcAnalog.onPress = startAnalog;
		mcAnalog.onRelease = stopAnalog;
		mcAnalog.onReleaseOutside = stopAnalog;

		mcAnalog.onRollOver = showAnalogInfo;
		mcAnalog.onRollOut = hideAnalogInfo;
		mcAnalog.onDragOut = hideAnalogInfo;

	}
	function startAnalog(){
		flMoveMap = true;
		hideAnalogInfo();
	}
	function stopAnalog(){
		flMoveMap = false;
	}
	function showAnalogInfo(){
		mcAnalog.panel._visible = true;
	}
	function hideAnalogInfo(){
		mcAnalog.panel._visible = false;
	}

	function updateAnalog(){

		var xm = -mcAnalog._xmouse;
		var ym = -mcAnalog._ymouse;
		var dist = Math.sqrt( xm*xm + ym*ym );
		var c = Math.min( dist/60, 1);

		if( flMoveMap ){
			var a = Math.atan2(ym,xm);
			mcAnalog.smc._rotation = a/0.0174 - 90;
			mcAnalog.smc.gotoAndStop( Std.int(c*mcAnalog.smc._totalframes)+1 );
			var sp = 30;
			moveMap( Math.cos(a)*sp*c, Math.sin(a)*sp*c );

		}else{
			var fr = Std.int((mcAnalog.smc._currentframe-1)*0.5)+1;
			mcAnalog.smc.gotoAndStop(fr);
		}

	}
	function moveMap(dx,dy){

		var www =  Cs.SQUARE_SIDE*Cs.WW*scale;
		var hhh =  Cs.SQUARE_SIDE*Cs.HH*scale;

		var ww = www*(Cs.SIDE-2*displayMargin);
		var hh = hhh*(Cs.SIDE-2*displayMargin);

		var mx = www*displayMargin;
		var my = hhh*displayMargin;


		var nx = map._x+dx;
		var ny = map._y+dy;

		map._x = Num.mm( Cs.mcw-(ww+mx), nx, -mx);
		map._y = Num.mm( Cs.mch-(hh+my), ny, -my);

		//haxe.Log.clear();
		//trace(mx+"---"+my+"----"+displayMargin);
		//trace(Std.int(map._x)+";"+Std.int(map._y));

	}

	// SHOW
	function showMap(){
		lc.close();
		step = Show;
		bg.nextFrame();

		map = dm.empty(DP_MAP);
		var mdm = new mt.DepthManager(map);
		for( x in 0...displayGrid.length ){
			var a = displayGrid[x];
			for( y in 0...a.length ){
				var bmp = displayGrid[x][y];
				var mc = mdm.empty(0);
				mc.attachBitmap(bmp,0);
				mc._x = x*Cs.BMP_SIZE_MAX;
				mc._y = y*Cs.BMP_SIZE_MAX;
			}
		}




		var mid = Cs.SIDE*Cs.SQUARE_SIDE*0.5;

		map._x = Cs.mcw*0.5-Cs.getX(mid,mid);
		map._y = Cs.mch*0.5-Cs.getY(mid,mid);
		//map.attachBitmap(bmpDisplay,0);

		//
		mcLoading.removeMovieClip();
		mcLoading = null;
		initInterface();

		//



	}
	function updateShow(){
		updateAnalog();



		if(dragPoint!=null){
			var dx = root._xmouse - dragPoint.x;
			var dy = root._ymouse - dragPoint.y;
			moveMap(  (dragPoint.sx+dx)-map._x, (dragPoint.sy+dy)-map._y );
			return;
		}

		// SCALE
		var ds = scale - map._xscale*0.01;
		map._xscale = map._yscale = scale*100;
		var ww = Cs.SQUARE_SIDE*Cs.WW*Cs.SIDE;
		var hh = Cs.SQUARE_SIDE*Cs.HH*Cs.SIDE;
		map._x -= ww*ds*0.5;
		map._y -= hh*ds*0.5;


		// RECAL
		moveMap(0,0);





	}
	function mouseScroll(){

		/* // RELATIVE
		var cx = root._xmouse/Cs.mcw;
		var cy = root._ymouse/Cs.mch;

		var ww = Cs.SQUARE_SIDE*Cs.WW*Cs.SIDE;
		var hh = Cs.SQUARE_SIDE*Cs.HH*Cs.SIDE;

		var tx = -cx*(ww-Cs.mcw);
		var ty = -cy*(hh-Cs.mch);

		var c = 0.4;
		map._x += (tx-map._x)*c;
		map._y += (ty-map._y)*c;
		/*/




		//*/

	}

	function pressMap(){
		dragPoint = { x:root._xmouse, y:root._ymouse, sx:map._x, sy:map._y };
	}
	function releaseMap(){
		dragPoint = null;
	}
	//
	function control(){
		if(FL_DEBUG){
			if(flash.Key.isDown(107)){
				incPop(1);
				tracePop();
			}
			if(flash.Key.isDown(109)){
				incPop(-1);
				tracePop();
			}
			if( flash.Key.isDown(flash.Key.SPACE)){
				if(flPaglop!=true){
					reset(1);
					flPaglop = true;
				}
			}else{
				flPaglop = false;
			}
		}
		if(flash.Key.isDown(222))zoom(1.1);
		if(flash.Key.isDown(49))zoom(0.9);

		var inc = 10;
		if( flash.Key.isDown( flash.Key.LEFT  ) ) moveMap(-inc,0);
		if( flash.Key.isDown( flash.Key.RIGHT ) ) moveMap(inc,0);
		if( flash.Key.isDown( flash.Key.UP    ) ) moveMap(0,-inc);
		if( flash.Key.isDown( flash.Key.DOWN  ) ) moveMap(0,inc);
	}
	function zoom(c:Float){			// >_<

		scale = Num.mm(0.2,scale*c,1);
	}

	//
	function getRayMax(n){
		return 1+Math.pow(n,0.6)*0.15;
	}


	//DEBUG
	function incPop(n){
		if(flash.Key.isDown(flash.Key.CONTROL))n*=10;

		info.pop = Std.int(Math.max(info.pop+n,0));
	}
	function tracePop(){
		haxe.Log.clear();
		trace(info.pop);
	}
	function reset(?n){
		haxe.Log.clear();
		//

		for( a in displayGrid ){
			for( bmp in a ){
				bmp.dispose();
			}
		}

		//
		if(n!=null)incPop(n);
		//map.removeMovieClip();
		//mcInter.removeMovieClip();
		dm.destroy();

		init();
	}


//{
}














