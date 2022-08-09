import Common;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import flash.Key;

class Piece extends Sprite{//}

	public static var RAY = 2;

	public var flNext:Bool;
	public var flLeft:Bool;
	public var flRight:Bool;
	public var flDeath:Bool;

	public var color:Int;
	public var px:Int;
	public var py:Int;
	public var ty:Float;
	var ox:Float;
	var oy:Float;
	var tr:Float;


	public var cx:Float;
	public var cy:Float;

	var flTurnReady:Bool;
	var flOptReady:Bool;

	var step:Int;
	var playTimer:Float;
	var transTimer:Float;


	var grid:Array<Array<Square>>;
	var dm:mt.DepthManager;

	public function new(mc,infos,?flNext:Bool){
		super(mc);
		dm = new mt.DepthManager(root);
		ox = 0;
		oy = 0;
		transTimer = 0;
		tr = 0;
		this.flNext = flNext;
		genGrid(infos);
	}

	function genGrid(infos){

		color = infos[2][0];

		var matrix = infos[0];
		cx = infos[1][0]*0.5;
		cy = infos[1][1]*0.5;






		// GRID
		grid = [];
		for( x in 0...RAY*2 ){
			grid[x] = [];
			for( y in 0...RAY*2 ){
				var type = matrix[x*4+y];
				if( type > 0 ){
					var sq = new Square( dm.attach("mcSquare",0), type-1, color );
					grid[x][y] = sq;
				}
			}
		}


		updateGridPos();




	}

	function updateGridPos(){

		/*
		var center = getCenter(grid);
		cx = center.x;
		cy = center.y;
		*/


		if(flNext)setCenter(grid);




		for( x in 0...RAY*2 ){
			for( y in 0...RAY*2 ){
				var dx = x-cx;
				var dy = y-cy;
				if(flNext!=true){
					dx = Math.floor(dx);
					dy = Math.floor(dy);
				}

				var sq = grid[x][y];
				sq.root._x = Cs.SIZE*dx;
				sq.root._y = Cs.SIZE*dy;
			}
		}
	}



	public function update(){

		if(flNext){
			/*
			var dy = ty-y;
			y += dy*0.5*mt.Timer.tmod;
			super.update();
			if(Math.abs(dy)<5 && ty!=0 ){
				Game.me.bg.nextList.remove();
			}
			*/

			super.update();
			return;
		}
		if(Game.me.step!=Play)return;



		if(transTimer>0)transTimer-=mt.Timer.tmod;

		var flDown = Key.isDown(Key.DOWN);
		flLeft = Key.isDown(Key.LEFT);
		flRight = Key.isDown(Key.RIGHT);

		if( Game.me.flInverse ){
			var fl = flRight;
			flRight = flLeft;
			flLeft = fl;
		}


		control();

		if(flDeath)return;

		switch(step){
			case 0:
				var fall = Game.me.speed;
				if(flDown)fall = 1;
				oy+= fall*mt.Timer.tmod;
				while(oy>1){
					oy--;
					setPos(px,py+1);

					if(flLeft)translate(-1,true);
					if(flRight)translate(1,true);

					if(step!=0)break;
				}
			case 1:
				playTimer-=mt.Timer.tmod;
				if( playTimer<0 || flDown )validate();
			case 2:
		}


		// TURN
		var dr = Num.hMod(tr-root._rotation,180);
		root._rotation += dr*0.5*mt.Timer.tmod;

		//
		ox *= Math.pow(0.5,mt.Timer.tmod);
		x = Cs.MX + (px+ox )*Cs.SIZE;
		y = Cs.MY + (py+oy )*Cs.SIZE;

		super.update();



		Game.me.drawRainbowShade(root);

	}

	// MOVE
	function control(){
		if(flLeft)translate(-1);
		if(flRight)translate(1);
		/*
		if(Key.isDown(Key.SPACE)){
			if(flTurnReady)turn(-1);
			flTurnReady = false;
		}else{
			flTurnReady = true;
		}
		*/

		if(flTurnReady){
			if(Key.isDown(66) || Key.isDown(Key.SPACE) ){
				turn(-1);
				flTurnReady = false;
			}
			if(Key.isDown(86)){
				turn(1);
				flTurnReady = false;
			}
		}else{
			flTurnReady = !Key.isDown(86) && !Key.isDown(66) && !Key.isDown(Key.SPACE);
		}





		if( Key.isDown(Key.UP) ){
			if(flOptReady)Game.me.useOpt();
			//Game.me.useOpt();
			flOptReady = false;
		}else{
			flOptReady = true;
		}

	}
	function translate(sens:Int,?flInter:Bool){
		if(transTimer<=0 && (flInter || isFree(px+sens,Math.ceil(py+oy))) && isFree(px+sens,py) && Math.abs(ox)<0.2){
			setPos(px+sens,py);
			ox -= sens;
		}
	}
	public function turn(sens){

		var a = null;
		var flOk = false;

		/*
		for( k in 0...2 ){
			if(k==1)sens*=-1;

			a = getTurnedGrid(sens);
			var center = getCenter(a);
			if( isFree(px,py,a,center.x,center.y )){
				flOk = true;
			}else{

				for( n in 0...2 ){
					var sens = n*2-1;
					if( isFree(px+sens,py,a,center.x,center.y) ){
						flOk = true;
						px+=sens;
						break;
					}
				}

			}
			if(flOk)break;
		}
		*/

		var o = getTurnedGrid(sens);
		//var center = getCenter(a);

		flOk = isFree(px,py,o.grid,o.cx,o.cy );
		if(flOk){
			grid = o.grid;
			cx = o.cx;
			cy = o.cy;
			updateGridPos();
			checkState();
		}

		//traceGrid();
	}

	// VALIDATE
	function validate(){
		for( x in 0...4 ){
			for( y in 0...4 ){
				var sq = grid[x][y];
				if( sq != null ){
					Game.me.addSquare( sq, Math.floor(px+x-cx), Math.floor(py+y-cy) );

				}

			}
		}
		kill();
		Game.me.checkLines();


	}

	// LOGIC
	public function setPos(x,y){
		px = x;
		py = y;
		checkState();
	}
	public function checkState(){
		if(isFree(px,py+1)){
			step=0;
		}else{
			if(step!=1){
				step=1;
				playTimer = Game.me.playTimerMax;
				oy = 0;
			}
		}
	}
	public function isFree(x,y,?gr,?ccx,?ccy){
		if(gr==null)gr=grid;
		if(ccx==null)ccx=cx;
		if(ccy==null)ccy=cy;
		for( dx in 0...4 ){
			for( dy in 0...4 ){
				var flOk = gr[dx][dy] != null;
				if( flOk && !Game.me.isFree(Math.floor(x+dx-ccx),Math.floor(y+dy-ccy)) )return false;
			}
		}
		return true;
	}
	public function getTurnedGrid(sens){

		var a = [];
		var ccx = 1.5;
		var ccy = 1.5;
		for( x in 0...4 ){
			a[x] = [];
			for( y in 0...4 ){
				var nx = Math.floor( ccx - (y-ccx)*sens );
				var ny = Math.floor( ccy + (x-ccy)*sens );
				a[x][y] = grid[nx][ny];
			}
		}

		var ncx = ccx + (cy-ccx)*sens ;
		var ncy = ccy - (cx-ccy)*sens ;

		return {grid:a,cx:ncx,cy:ncy};
	}

	public function setCenter(grid){

		var xMin = 9.0;
		var xMax = 0.0;
		var yMin = 9.0;
		var yMax = 0.0;
		for( x in 0...RAY*2 ){
			for( y in 0...RAY*2 ){
				if( grid[x][y]!=null){
					xMin = Math.min(x,xMin);
					xMax = Math.max(x,xMax);
					yMin = Math.min(y,yMin);
					yMax = Math.max(y,yMax);
				}
			}
		}

		cx = (xMin+xMax)*0.5 +0.5;
		cy = (yMin+yMax)*0.5 +0.5;



	}



	// FX
	public function explode(){

		/*
		for( x in 0...RAY*2 ){
			for( y in 0...RAY*2 ){
				var sq = grid[x][y];
				if( sq!=null ){
					for( n in 0...12 ){
						var p = new Particule(Game.me.dm.attach("partSquare",Game.DP_PARTS));
						var dx  = Cs.SIZE*(x-cx) + Math.random()*Cs.SIZE;
						var dy  = Cs.SIZE*(y-cy) + Math.random()*Cs.SIZE;
						var a = Math.atan2(dy,dx);
						var sp = (2+Math.random()*5)*1;
						p.x = this.x + dx;
						p.y = this.y + dy;
						p.vx = Math.cos(a)*sp;
						p.vy = Math.sin(a)*sp;
						p.frict = 0.95;
						p.timer = 10+Math.random()*30;
						p.weight = 0.05+Math.random()*0.05;
						p.setScale(100+Math.random()*50);
						p.fadeType = 0;
						p.updatePos();
						//Filt.glow(p.root,10,2,0xFFFFFF);
						p.bhl = [1];
					}
				}
			}
		}
		*/


		kill();
	}

	//
	public function kill(){
		flDeath = true;
		Game.me.piece = null;
		super.kill();
	}





	// DEBUG
	function traceGrid(){
		haxe.Log.clear();

		for( y in 0...4 ){
			var str = "";
			for( x in 0...4 ){
				str += if(grid[x][y]!=null)"1-"; else "0-";
			}
			trace(str);
		}
	}



//{
}

// COL
// REVOIR LES LUCIOLES






