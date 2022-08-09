import Cell;
import Game;
import Anim;

typedef McSnake = {> flash.MovieClip, head: flash.MovieClip, ec:flash.MovieClip }

class Suite {

	public var list(default,null) : Array<Cell>;
	var tmpList : Array<Cell>;
	var mcList : Array<McCell>;
	var cur : mt.flash.Volatile<Int>;
	var animPos : Float;
	var rot : Float;

	var mcSnake : McSnake;
	var mcSnakeSuite : flash.MovieClip;

	public function new(){
		list = new Array();
		tmpList = new Array();
		cur = 0;
		animPos = 0;
	}

	public function add( cell : Cell ){
		list.push( cell );
	}

	public function check( cell : Cell ){
		if( cell.chained ) return false;
		return list[cur].symbol == cell.symbol;
	}

	public function next( cell : Cell	){
		if( !check(cell) ) return;

		var l = last();
		if( l != null ){
			l.displaySnake( tmpList[tmpList.length-2], cell );
		}

		tmpList.push( cell );
		Game.addAnim( new AnimMove(mcSnakeSuite,{start: {x: mcSnakeSuite._x,y: mcSnakeSuite._y},end: {x: mcSnakeSuite._x+30,y: mcSnakeSuite._y}},5,0,hideSuiteFruit) );
		if( tmpList.length == 1 ){
			initSnake();
			cell.hide();
		}else{
			Game.addAnim( new AnimMove(mcSnake,{start: {x: mcSnake._x, y: mcSnake._y},end: {x: cell.mcSymbol._x, y: cell.mcSymbol._y}},5,0,function(){ cell.hide(); }) );
		}

		if( tmpList.length == list.length ) Game.levelEnded = true;


		cell.chained = true;
		KKApi.addScore( Const.POINTS[cell.symbol] );

		mcList[cur].gotoAndStop(1);
		animPos = 0;
		cur++;

	}

	public function tryNext(){
		var l = last();
		if( l != null ){
			l.tryNeighbour();
		}
	}

	public function clean(){
		for( c in tmpList ) c.chained = false;
		tmpList = new Array();

		for( c in list ) c.chained = false;
	}

	public function started(){
		return cur > 0;
	}

	public function last(){
		return tmpList[tmpList.length-1];
	}

	public function initSnake(){
		mcSnake = cast Game.dm.attach("snakeHead",Game.DP_SNAKE);
		mcSnake._x = last().mcSymbol._x;
		mcSnake._y = last().mcSymbol._y;
	}

	public function display(){
		mcList = new Array();
		for( i in 0...list.length ){
			var mc : McCell = cast Game.dm.attach("cell",Game.DP_CELL);
			mcList[i] = mc;
			mc._x = (i%8) * 30 + (300 - Math.min(8,list.length) * 30)/2 + 15;
			mc._y = 25 + Std.int(i / 8) * 30;
			mc.symbol.gotoAndStop( list[i].symbol + 1 );
			mc.gotoAndStop(Const.ANIM_APPEAR.start);
			mc._rotation = 360 * Math.random();
			var r = 0.8 + 0.3 * Math.random();
			mc.filters = [
				new flash.filters.ColorMatrixFilter([
					r, 0, 0, 0, 0,
					0, r, 0, 0, 0,
					0, 0, r, 0, 0,
					0, 0, 0, 1, 0,
				])
			];
			Game.addAnim( new AnimPlay(mc,Const.ANIM_APPEAR,i*2) );
		}

		mcSnakeSuite = Game.dm.attach("suiteSnake",Game.DP_SNAKE);
		mcSnakeSuite._y = 25;
		mcSnakeSuite._x = (300 - Math.min(8,list.length) * 30)/2 - 15;
	}

	var lastP : {x: Float, y: Float};
	var lastFixRot : Float;
	public function update(){
		var mc = mcList[cur];
		if( mc != null ){
			animPos += mt.Timer.tmod;
			mc.gotoAndStop( Std.int(Const.ANIM_BLINK.start + animPos % (Const.ANIM_BLINK.end - Const.ANIM_BLINK.start)) );
		}

		if( mcSnake != null ){
			/*
			var difX = mcSnake._parent._xmouse - mcSnake._x;
			var difY = mcSnake._parent._ymouse - mcSnake._y;
			rot = Math.atan2(difY,difX)/0.0174;
			*/
			if( lastFixRot != null ){
				var dr = rot - lastFixRot;

				while(dr>180)dr-=360;
				while(dr<-180)dr+=360;

				if( dr > 45 ) rot = lastFixRot + 45;
				if( dr < -45 ) rot = lastFixRot - 45;
			}


			if( lastP != null ){
				var difX = mcSnake._x - lastP.x;
				var difY = mcSnake._y - lastP.y;
				var dif = Math.sqrt( difX*difX + difY*difY );
				if( dif != 0 ){
					rot = Math.atan2(difY,difX)/0.0174;
					lastFixRot = rot;
				}
			}
			lastP = {x: mcSnake._x, y: mcSnake._y};

			mcSnake.ec._rotation = -mcSnake._rotation;

			// BOUGE LA TETE DU SERPENT
			var dr = (mcSnake._rotation-rot);
			while(dr>180)dr-=360;
			while(dr<-180)dr+=360;
			mcSnake._rotation -= dr*0.8;
		}else{
			lastFixRot = null;
			lastP = null;
		}

	}

	public function kill(){
		for( mc in mcList ) mc.removeMovieClip();
		if( mcSnake != null ) mcSnake.removeMovieClip();
		if( mcSnakeSuite != null ) mcSnakeSuite.removeMovieClip();
	}

	public function hideSuiteFruit(){
		Game.inst.destroyAnim(mcList[cur-1],SnakeEatSuite);
	}

	public function reinit(){
		if( mcSnake != null ) mcSnake.removeMovieClip();
		for( c in tmpList ){
			c.chained = false;
			KKApi.addScore( Const.RPOINTS[c.symbol] );
			c.hideSnake();
		}
		tmpList = new Array();
		cur = 0;
		for( mc in mcList ){
			mc._visible = true;
			mc.gotoAndStop( 1 );
		}

		Game.addAnim( new AnimMove(mcSnakeSuite,{start: {x: mcSnakeSuite._x,y: mcSnakeSuite._y},end: {x: (300 - Math.min(8,list.length) * 30)/2 - 15,y: mcSnakeSuite._y}},5) );
	}
}
