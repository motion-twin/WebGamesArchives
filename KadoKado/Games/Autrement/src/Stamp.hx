import mt.bumdum.Phys;
import mt.bumdum.Lib;

enum Step {
	Play;
	Burst;
	Shaker;
	GameOver;
}

class Stamp {//}

	static var START_SIZE = 3;


	public var flRotate:Bool;
	public var rotDec:{x:Int,y:Int};

	public var x:Int;
	public var y:Int;


	var ct:Float;
	var flh:Float;
	public var step:Step;

	var dir:Array<Int>;
	var cols:Array<Bloc>;
	var burstList:Array<Bloc>;
	var optWait:Array<Array<Int>>;

	public var root:flash.MovieClip;
	var dm:mt.DepthManager;

	public var bm:BlocManager;
	var pentacle:flash.MovieClip;
	var mcDisplay:flash.MovieClip;

	public function new(){

		x = Std.int(Game.MAX*0.5);
		y = Std.int(Game.MAX*0.5);

		root = Game.me.dm.empty(Game.DP_STAMP);
		dm = new mt.DepthManager(root);



		bm = new  BlocManager(dm.empty(0),Game.MAX*2);
		bm.dx = bm.dy = Std.int(bm.max*0.5);

		bm.root._x -= Game.SIZE*0.5;
		bm.root._y -= Game.SIZE*0.5;

		pentacle = dm.attach("mcStamp",Game.DP_BLOCS);
		mcDisplay = dm.attach("mcDisplay",Game.DP_BLOCS);
		pentacle._xscale = pentacle._yscale = Game.SIZE/20 * 100;
		mcDisplay._xscale = mcDisplay._yscale = Game.SIZE/20 * 100;


		for( x in 0...START_SIZE ){
			for( y in 0...START_SIZE ){
				var b = new Bloc(x-1,y-1,10,bm);
			}
		}


		// MOUSE
		var o:Dynamic = Reflect.empty();
		Reflect.setField(o,"onMouseDown",action);
		flash.Mouse.addListener(o);

		// STEP
		step = Play;

		//
		//
		//Col.setColor(bm.root,0xFF000000,80);
		//Col.setPercentColor(bm.root,30,0);

	}


	public function update(){

		//
		var odir = dir;
		var ocols = cols;
		cols = [];
		dir = [0,0];
		//

		switch(step){
			case Play: updatePlay();
			case Burst: updateBurst();
			case Shaker: updateShaker();
			case GameOver:
		}

		// FLASH
		if(flh!=null){
			flh*=Math.pow(0.9,mt.Timer.tmod);
			var prc = flh;
			if(flh<5){
				prc = 0;
				flh = null;
			}
			Col.setPercentColor(root,prc,0xFFFFFF);
		}


		// REMET LES PIONS EN PLACE
		if( dir[0]!=odir[0] || dir[1]!=odir[1] ){
			for( b in ocols )b.setPos(b.x,b.y,true);
		}
		//

		// UPDATE DISPLAY
		if( cols.length == 0 ){
			mcDisplay._rotation = 0;
			if(flRotate){
				mcDisplay.gotoAndStop("2");
			}else{
				mcDisplay.gotoAndStop("3");
			}
		}else{
			if( dir[0]==0 ) mcDisplay._rotation = dir[1]*90;
			if( dir[1]==0 ) mcDisplay._rotation = dir[0]*90 - 90;
			mcDisplay.gotoAndStop("1");
		}

		move();


	}

	function move(){

		var tx = Game.getX(x);
		var ty = Game.getY(y);

		if( cols.length>0 ){
			var  dec = Game.SIZE*0.3;
			for( b in cols ){
				Game.me.bm.dm.over(b.root);
				var tx = Game.getX(b.x) + dir[0]*dec;
				var ty = Game.getY(b.y) + dir[1]*dec;

				Bloc.goto(b,tx,ty);
			}
			tx += dir[0]*dec;
			ty += dir[1]*dec;
		}


		var dx = tx - root._x;
		var dy = ty - root._y;
		var cc = 0.6;
		root._x += dx*cc*mt.Timer.tmod;
		root._y += dy*cc*mt.Timer.tmod;
	}

	function updatePlay(){

		root._rotation*=0.5;

		var dx:Int = Game.getGX(Game.me.root._xmouse) - x;
		var dy:Int = Game.getGY(Game.me.root._ymouse) - y;

		var adx = Math.abs(dx);
		var ady = Math.abs(dy);

		if( adx==0 && ady==0 )return;

		if(adx>=ady){
			dir = [ Std.int(adx/dx), 0 ];
		}else{
			dir = [ 0,Std.int(ady/dy) ];

		}

		var list = getObstacle(dir);
		if(list!=null){
			if(list.length>0){
				for( b in list )cols.push(b);
			}else{
				x += dir[0];
				y += dir[1];
				checkRotate();
			}
		}

	}
	function getObstacle(dir){

		var list= [];
		var flOk = true;
		for( b in bm.list ){
			var nx = x + b.x + dir[0];
			var ny = y + b.y + dir[1];

			var b2 =  Game.me.bm.grid[nx][ny];
			if(b2!=null)list.push(b2);

			if( Game.me.bm.isOut(nx,ny) ){
				list = null;
				flOk = false;
				break;
			}

		}
		return list;
	}

	// ACTION
	function action(){
		if(step!=Play)return;
		if(cols.length>0){



			// ATTACH
			for( b in cols ){
				if(Game.me.bm.isOut(b.x,b.y,1))Game.me.holes.push({x:b.x,y:b.y});
				b.discard();
				b.setManager(bm);
				b.display(b.x-x,b.y-y);
			}

			// BURST
			var gr = bm.getGroups(function(a,b){return a.id == b.id;});
			burstList = [];
			optWait = [];
			for( a in gr ){
				if(a.length>3 && a[0].id<10 ){
					for( b in a ){
						burstList.push(b);
						if(b.option!=null)optWait.push([b.option,b.id]);
					}
				}
			}

			if(burstList.length>0){
				step = Burst;
				ct = 0;

			}else{
				Game.me.nextTurn();
			}

			// RECULE
			var cc = 1;
			root._x += dir[0]*Game.SIZE*cc;
			root._y += dir[1]*Game.SIZE*cc;

			// FLASH
			flh = 100;
			Col.setPercentColor(root,100,0xFFFFFF);

			//
			//Game.me.nextTurn();

		}else{
			/*
			var ofl = flRotate;
			checkRotate();
			if(flRotate!=ofl)trace("ERRRRRROOOOOOOOOOOOOOOR!");
			*/
			if(flRotate){
				if(rotDec!=null){
					x+=rotDec.x;
					y+=rotDec.y;
					rotDec = null;
				}

				bm.rotate();
				root._rotation -= 90 ;
				pentacle._rotation += 90;

				checkRotate();
			}

		}
	}
	public function checkRotate(){
		rotDec = null;
		flRotate =  bm.checkRotate(Game.me.bm,x,y);
		if(!flRotate){
			for( dx in 0...3 ){
				for( dy in 0...3 ){

					flRotate = bm.checkRotate( Game.me.bm, x+dx-1, y+dy-1 );
					if( flRotate ){
						rotDec = {x:dx-1,y:dy-1};
						return;
					}
				}
			}
		}

	}

	// BURST
	function updateBurst(){
		ct = Math.min(ct+0.1*mt.Timer.tmod,1);

		for( b in burstList ){
			Col.setPercentColor(b.root,ct*100,0xFFFFFF);
			if(ct==1)b.explode();
		}

		if(ct==1){
			// FALL
			var list = bm.getFalls();
			for( b in list )b.fall();
			//
			Game.me.nextTurn();
			step = Play;
			cols = [];
			dir = [0,0];
			//
			for( a in optWait){
				switch(a[0]){
					case 0:	Game.me.activeStar(a[1]);
					case 1:	Game.me.activeShaker();
				}
			}


		}
	}

	// SHAKER
	public function initShaker(){
		step = Shaker;
	}
	function updateShaker(){

		if(bm.list.length==9){
			step = Play;
			return;
		}

		// FALL BALL

		var b = null;
		do{
			b = bm.list[Std.random(bm.list.length)];
		}while(b.id==10);

		var a = Geom.getAng(cast b,cast {x:0,y:0});
		var sp = 2+Math.random()*4;
		var p = b.fall();
		p.vx = Math.cos(a)*sp;
		p.vy = Math.sin(a)*sp;


		// ROTATION
		root._rotation = (Math.random()*2-1)*9;
		var size = 300;
		var bmp = new flash.display.BitmapData(size,size,true,0x00000000);
		var m = new flash.geom.Matrix();
		m.translate(size*0.5,size*0.5);
		bmp.draw(root,m);
		var mc = Game.me.dm.empty(Game.DP_PARTS);
		var mcc = new mt.DepthManager(mc).empty(0);
		mcc._x = - size*0.5;
		mcc._y = - size*0.5;
		mcc.attachBitmap(bmp,0);
		mcc._alpha = 50;
		mc._rotation = -root._rotation;

		var p = new Phys(mc);
		p.x = Game.getX(x);
		p.y = Game.getY(y);
		p.timer = 3;
		p.fadeLimit = 1;
		p.updatePos();
		p.setAlpha(50);


	}



	public function die(){
		step = GameOver;
	}
	public function shake(n:Float){
		root._x = Game.getX(x) + (Math.random()*2-1)*n;
		root._y = Game.getY(y) + (Math.random()*2-1)*n;
	}


	// CHECK
	public function isDead(){
		for( d in Game.DIR ){
			var list = getObstacle(d);
			if( list.length == 0 )return false;
		}
		return true;
	}
	public function isGridFree(gx,gy){
		return bm.isFree(gx-x,gy-y);
	}



//{
}

/*
27
254	- 1
2542	- 10
15766	- 100
310952	- 1000
*/