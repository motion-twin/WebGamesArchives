import KKApi;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;

enum Step {
	Move;
	Play;
	Slice;
	Fall;
	Spawn;
	GameOver;
}



class Game {//}




	#if prod
		public static var FL_TEST = 	false;
	#else
		public static var FL_TEST = 	true;
	#end


	public static var FL_VISEW_SCORE = false;


	var step:Step;

	//public static var DP_RAZOR =		2;
	public static var DP_BALL =		1;


	public static var DP_FRONT = 		10;
	public static var DP_FX = 		8;
	public static var DP_RAZOR = 		6;
	public static var DP_SHADE =		5;
	public static var DP_UNDER_FX = 	4;
	public static var DP_BOARD = 		2;
	public static var DP_BG = 		0;

	var flGameOver:Bool;

	var rtx:Int;
	var rty:Int;
	var rx:Int;
	var ry:Int;
	var move:Int;
	public var probaSpecial:Int;

	var trot:Float;
	var sc:Float;
	var vrot:Float;
	var bdir:Int;
	var vibe:Int;
	var sliceIndex:Int;
	var sliceDirection:Int;
	public var comboScore:Int;
	public var bonus:mt.flash.Volatile<Int>;
	public var board:flash.MovieClip;

	public var grid:Array<Array<Ball>>;
	public var balls:Array<Ball>;
	public var work:Array<Ball>;
	public var pool:Array<Array<flash.MovieClip>>;
	public var limits:Array<Int>;
	public var mcWarning:flash.MovieClip;


	public var razor:flash.MovieClip;
	public var razorReal:flash.MovieClip;

	public static var me:Game;
	public var bdm:mt.DepthManager;
	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;

	// DEBUG
	public var markers:Array<flash.MovieClip>;




	public function new( mc : flash.MovieClip ){
		//haxe.Log.setColor(0xFFFFFF);


		//Cs.init();
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);


		bg = dm.attach("mcBg",Game.DP_BG);
		balls = [];

		move = 0;
		vibe = 1;
		probaSpecial = 100000;


		initInter();
		initBoard();

		// RAZOR
		razor = bdm.empty(0);//bdm.attach("mcRazor",DP_RAZOR);
		razorReal = dm.attach("mcRazor",DP_RAZOR);
		moveRazorTo(3,6);

		step  = Play;


	}

	//
	public function update(){
		//haxe.Log.clear();
		//for( i in 0... 99999){	var a = 120*456;}

		#if prod
		#else
		cleanMarkers();
		viewGrid(bgrid);
		#end


		switch(step){
			case Move:		updateMove();
			case Play : 		updatePlay();
			case Slice : 		updateSlice();
			case Fall:		updateFall();
			case Spawn :		updateSpawn();
			case GameOver : 	updateGameOver();
		}




		updateBoard();
		//razor._rotation += 30;
		//razor.smc._rotation = -(board._rotation+razor._rotation);

		var p = Geom.getParentCoord(razor,root);
		razorReal._x = p.x + Std.random(3)-1;
		razorReal._y = p.y + Std.random(3)-1;
		//razorReal._x = p.x + vibe;
		//razorReal._y = p.y;
		//vibe = - vibe;

		razorReal.smc._rotation += 11;
		//razorReal._rotation += 11;
		//razorReal.smc._rotation = -(board._rotation+razorReal._rotation);

		updateSprites();




	}
	public function updateSprites(){

		var a = Sprite.spriteList.copy();
		for( sp in a )sp.update();
	}

	// PLAY
	function initPlay(){
		step = Play;

		var ball = getSliceTarget();

		if( limits[ball.col] >= Cs.POOL_MAX )attachWarning(ball);


	}
	function updatePlay(){

		if( flash.Key.isDown(flash.Key.LEFT) )			slip(-1);
		else if( flash.Key.isDown(flash.Key.RIGHT) )		slip(1);
		else if( flash.Key.isDown(flash.Key.UP) )		initSlice();


		if( Math.random()/mt.Timer.tmod<0.1 ){
			balls[Std.random(balls.length)].root.smc.play();
		}

	}
	function slip(sens){

		var di = ( bdir+1-sens)%4;
		var dx = Cs.DIR[di][0];
		var dy = Cs.DIR[di][1];
		rtx = rx+dx;
		rty = ry+dy;

		if(
			dx!=0 && ( rtx==-1 || rtx==Cs.SIDE ) ||
			dy!=0 && ( rty==-1 || rty==Cs.SIDE )

		){

			di =   Std.int(Num.sMod(di-sens,4));
			bdir = Std.int(Num.sMod(bdir-sens,4));
			//turn = sens;
			rtx += Cs.DIR[di][0];
			rty += Cs.DIR[di][1];
		}

		initMove();
		removeWarning();
	}

	// SLICE
	function initSlice(){

		if( move++ == 2 )	probaSpecial = 16;
		if( move++ == 10 )	probaSpecial = 10;

		var ball = getSliceTarget();
		incPool(ball.col);


		work = getPath(ball.col,ball,[]);
		step = Slice;
		sliceIndex = 0;
		sliceDirection = 1;
		comboScore = 0;
		sc = 0;
		var trg = work[sliceIndex];
		rtx = trg.x;
		rty = trg.y;

		bonus = 0;
		removeWarning();


	}
	function updateSlice(){

		var speed = 0.1;
		speed *= 1+(work.length-sliceIndex);
		if(sliceIndex==-1)speed = 0.15;
		if( speed > 0.5 )speed = 0.5;
		sc += speed*mt.Timer.tmod;

		while(sc>1){
			sc--;
			rx = rtx;
			ry = rty;

			sliceIndex += sliceDirection;

			if( sliceDirection == 1 ){
				var b = grid[rx][ry];
				b.sliced();
				bonus++;

			}


			if( sliceIndex == work.length ){
				sc = 0;
				sliceIndex -= 2;
				sliceDirection = -1;
				fxComment(work.length);
			}
			if(sliceIndex>=0){
				var trg = work[sliceIndex];
				rtx = trg.x;
				rty = trg.y;
			}
			if( sliceIndex == -1 ){
				//step = null;
				var di = Std.int(Num.sMod(bdir+1,4));
				rtx = rx + Cs.DIR[di][0];
				rty = ry + Cs.DIR[di][1];
			}
			if( sliceIndex == -2 ){
				initFall();
				//if(flGameOver)	initGameOver();
				//else		initFall();
			}

		}
		moveRazor(sc);

		fxShade();
	}
	function getPath(col:Int,ball:Ball,list:Array<Ball>):Array<Ball>{

		list.push(ball);
		var a = [];

		for( d in Cs.DIR ){
			var x = ball.x + d[0];
			var y = ball.y + d[1];
			var b = grid[x][y];
			if( b.col == col || b.col == Cs.COL_MAX ){
				var flOk = true;
				for( b2 in list )if(b2==b){ flOk = false; break; };
				if(flOk){
					var work = getPath(col,b,list.copy());
					if( work.length> a.length ){
						a = work;
					}else if( work.length == a.length){
						var sp0 = 0;
						var sp1 = 0;
						for( b in work )if(b.col==Cs.COL_MAX)sp0++;
						for( b in a )if(b.col==Cs.COL_MAX)sp1++;
						if( sp0<sp1 ) a = work;

					}



				}
			}
		}

		a.unshift(ball);

		return a;


	}
	function getSliceTarget(){
		var di = Std.int(Num.sMod(bdir-1,4));
		var bx = rx+Cs.DIR[di][0];
		var by = ry+Cs.DIR[di][1];
		return grid[bx][by];
	}

	// FALL
	function initFall(){
		step = Fall;
		var d = Cs.DIR[(bdir+1)%4];

		sc = 0;

		var fx=null;
		var fy=null;

		if( d[1] == 1  ){
			fx = function(col,et){ return col; };
			fy = function(col,et){ return Cs.SIDE-(1+et); };

		}
		if( d[1] == -1  ){
			fx = function(col,et){ return col; };
			fy = function(col,et){ return et; };
		}

		if( d[0] == 1  ){
			fx = function(col,et){ return Cs.SIDE-(1+et); };
			fy = function(col,et){ return col; };
		}
		if( d[0] == -1  ){
			fx = function(col,et){ return et; };
			fy = function(col,et){ return col; };
		}

		for( col in 0...Cs.SIDE ){
			var fall = 0;
			for( et in 0...Cs.SIDE ){
				var x = fx(col,et);
				var y = fy(col,et);
				var b =  grid[x][y];
				if( b == null ){
					fall++;
				}else{
					b.fall = fall;
					if(fall>0)b.removeFromGrid();
				}


			}
		}


	}
	function updateFall(){
		sc = sc+0.34*mt.Timer.tmod;
		var d = Cs.DIR[(bdir+1)%4];

		var flEndFall = true;

		for( b in balls ){
			if( b.fall > 0){
				flEndFall = false;
				b.root._x = Cs.getX( b.x+d[0]*sc );
				b.root._y = Cs.getY( b.y+d[1]*sc );
				if( sc>=1 ){
					b.x += d[0];
					b.y += d[1];
					b.fall--;
					if(b.fall==0){
						b.insertInGrid();
						b.updatePos();
					}
				}
			}
		}

		if(sc>1)sc--;
		if(flEndFall)initSpawn();



	}

	// SPAWN
	function initSpawn(){
		step = Spawn;
		work = [];
		sc = 0;
		for( x in 0...Cs.SIDE ){
			for( y in 0...Cs.SIDE ){
				var b = Game.me.grid[x][y];
				if( b == null ){
					b = new Ball(x,y);
					work.push(b);
					b.root._xscale = b.root._yscale = 0;
					work.push(b);
				}

			}
		}
	}
	function updateSpawn(){
		sc = Math.min(sc+0.1,1);
		for( b in work ){
			b.root._xscale = b.root._yscale = sc*100;
		}
		if(sc==1){
			if(flGameOver)	initGameOver();
			else		initPlay();
		}

	}

	// MOVE
	public function initMove(){
		sc = 0;
		step = Move;
		updateMove();
	}
	public function updateMove(){
		var speed = Cs.RAZOR_SPEED;
		//if(turn!=null)speed *= 0.5;
		sc = sc+speed;
		var c = sc;
		if(sc>1){
			sc = 1;
			moveRazorTo(rtx,rty);
			initPlay();
			updatePlay();
		}else{
			moveRazor(c);

		}

		//fxShade();

		/*
		if(turn!=null){
			board._rotation = -Num.sMod( bdir+turn*(1-sc), 4)*90;
			board._y = Cs.mch *0.5 - Math.sin(sc*3.14)*30;
			if(sc==1){
				turn = null;
				board._rotation = -bdir*90;
			}
		}
		*/

	}
	public function moveRazor(c:Float){
		razor._x = Cs.getX(  rx*(1-c) + rtx*c  );
		razor._y = Cs.getY(  ry*(1-c) + rty*c  );
		//fxShade();
	}

	// BOARD
	public function initBoard(){
		board = dm.empty(DP_BOARD);
		board._x = Cs.mcw*0.5;
		board._y = Cs.mch*0.5;
		bdm = new mt.DepthManager(board);
		bdir = 0;
		vrot = 0;

		grid = [];
		for( x in 0...Cs.SIDE ){
			grid[x] = [];
			for( y in 0...Cs.SIDE ){
				new Ball(x,y);
			}
		}


		var fl = new flash.filters.DropShadowFilter();
		fl.alpha = 0.2;
		fl.distance = 15;
		board.filters = [fl];


	}
	public function updateBoard(){

		//var trot = null;
		var factor = 5;

		if( rx==-1 ) 		trot = -90   	+ (ry-2.5)*factor  ;
		if( ry==-1 ) 		trot = 180   	- (rx-2.5)*factor  ;
		if( rx==Cs.SIDE ) 	trot = 90   	- (ry-2.5)*factor  ;
		if( ry==Cs.SIDE ) 	trot = 0   	+ (rx-2.5)*factor  ;




		if(trot==null)return;
		var dr = Num.hMod(   trot-board._rotation  , 180);


		vrot += dr*0.1;
		vrot *= 0.6;
		board._rotation += vrot;


		for( b in balls )b.updateRot();

		var speed = Math.abs(dr);
		if( speed < 0.1 )trot = null;


		/* // PART TURN
		var max = Std.int(speed*0.1);
		for( i in 0...max ){
			var p = new mt.bumdum.Phys(dm.attach("partWind",DP_FX));
			p.x = board._x;
			p.y = board._y;
			p.vr = vrot * 0.8+Math.random()*0.4;
			p.root._rotation  = Math.random()*360;
			p.updatePos();
			p.timer = 10+Math.random()*10;
			p.root.smc._x = 20+Math.random()*150;
			p.vx = Math.random()*2-1;
			p.vy = Math.random()*2-1;
		}
		//*/




	}

	// INTER
	function initInter(){
		limits = [];
		pool = [];
		for( i in 0...Cs.COL_MAX ){
			limits[i] = 0;
			pool[i] = [];
			for( n in 0...Cs.POOL_MAX ){
				var mc = dm.attach("mcIcon",DP_BG);
				mc._x = getPoolX(i,n);
				mc._y = 19 ;
				mc.smc._visible = false;
				mc.smc.gotoAndStop(i+1);
				pool[i].push(mc);
					Filt.glow(mc,2,2,0x7D421C);
			}
		}
	}
	function attachWarning(ball){
		return;
		mcWarning = dm.empty(DP_BG);
		var wdm = new mt.DepthManager(mcWarning);
		for( i in 0...Cs.COL_MAX+1 ){
			var mc = wdm.attach("mcWarning",0);
			mc._x = getPoolX(ball.col,i);
			mc._y = 19;

		}
	}
	function removeWarning(){
		mcWarning.removeMovieClip();
	}
	function getPoolX(col,n){
		return 22 + n*20.5 + col*97 ;
	}
	function incPool(col){

		var id = limits[col];

		var mc = pool[col][id];
		mc.smc._visible = true;
		limits[col]++;
		if( id == Cs.POOL_MAX )flGameOver = true;


	}

	function updateInter(){

	}

	// RZAOR
	public function moveRazorTo(x,y){
		rx = x;
		ry = y;
		razor._x = Cs.getX(x);
		razor._y = Cs.getY(y);
	}

	// GAMEOVER
	public function initGameOver(){
		step = GameOver;
		KKApi.gameOver({});

	}
	function updateGameOver(){




	}

	// FX
	function fxShade(){
		var mc = bdm.attach("mcShade",0);
		mc._x = razor._x;
		mc._y = razor._y;
		mc._rotation = Math.random()*360;
		//mc.blendMode = "overlay";

	}
	function fxComment(n){

		//n = 12+Std.random(10);

		//n = 9+Std.random(12);

		if( n< 8 )return;

		var str = "COMBO!";
		if( n >= 10 )	str = "SUPER COMBO!";
		if( n >= 12 )	str = "MONSTRUEUX!";
		if( n >= 16 )	str = "ARCHI-GORE!";
		if( n >= 20 )	str = "ORGIE DANS LE SANG!";


		var mc = dm.attach("mcCommentAnim",DP_FRONT);
		cast(mc)._txt = str;
		cast(mc)._compt = n*2;
		cast(mc)._score = "+"+comboScore;
		cast(mc).fxBam = fxBam;


		var width = Reflect.field(cast(mc.smc.smc.smc).field,"textWidth");
		var ratio = (Cs.mcw-50)/width;

		mc.smc.smc._xscale = 100*ratio;
		mc.smc.smc._yscale = 100*ratio;
	}

	function fxBam(){
		//root._rotation += 1;


		for( i in 0...100 ){

			var dx = (Math.random()*2-1)*Cs.mcw*0.5;
			var dy = (Math.random()*2-1)*50;
			var a = Math.atan2(dy,dx);
			var dist = Math.sqrt(dx*dx*0.1+dy*dy);
			var vit = (100/dist)*2;


			var p = new mt.bumdum.Phys(dm.attach("mcPix",DP_FRONT));
			p.x = Cs.mcw*0.5 + dx;
			p.y = Cs.mch*0.5 + dy;
			p.vx = Math.cos(a)*vit;
			p.vy = Math.sin(a)*vit;
			p.timer = 10+Math.random()*15;
			p.fadeType = 0;
			p.updatePos();
			p.frict = 0.95;


		}

	}


	// DEBUG

	#if prod
	#else

	var bmpGrid:flash.display.BitmapData;
	function viewGrid(grid:Array<Array<Array<Ball>>>){
		if( !flash.Key.isDown(71) ){
			bmpGrid.dispose();
			bmpGrid = null;
			return;
		}

		if(bmpGrid==null){
			bmpGrid = new flash.display.BitmapData( Cs.GXMAX, Cs.GYMAX, false, 0 );
			var mc = dm.empty(DP_BG);
			mc.attachBitmap(bmpGrid,10);
			mc.blendMode = "add";

			mc._xscale = (Cs.mcw/Cs.GXMAX)*100;
			mc._yscale = (Cs.mch/Cs.GYMAX)*100;

		}

		for( x in 0...Cs.GXMAX ){
			for( y in 0...Cs.GYMAX ){

				var n = grid[x][y].length * 20;
				if( n >255 ) n = 255;
				var col = Col.objToCol({r:n,g:n,b:n});


				bmpGrid.setPixel(x,y,col);
			}
		}


	}
	function cleanMarkers(){
		while(markers.length>0)markers.pop().removeMovieClip();
	}
	public function mark(x,y){
		var mc = dm.attach("mcMark",20);
		mc._x = x;
		mc._y = y;
		markers.push(mc);

	}

	#end





	// EXPLOSION
	// ? CASSAGE DES BILLES A RETARDEMENT
	// TABLEAU VIDE -> SPAWN


//{
}




































