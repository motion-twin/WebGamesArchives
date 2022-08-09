import Common;
import Anim;

class Cell {

	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var activated : Bool;
	public var mc : flash.MovieClip;
	public var grass : flash.MovieClip;
	public var animal : flash.MovieClip;
	public var mcPoints : flash.MovieClip;

	public var game : Game;
	public var pos : Pos;
	public var dpl: Pos;
	public var colored : Bool;
	public var points : Int;

	var k : Point;	

	public var mine : Bool;
	public var isLowQuality : Bool;
	public var isLocked : Bool;

	public function new( g : Game, x : Int, y : Int, pos : Pos, dpl : Pos){
		
		isLocked = false;
		points = pos.points;
		this.x = x;
		this.y = y;
		colored = false;
		activated = false;
		game = g;
		this.dpl = dpl;
		this.pos = pos;
		isLowQuality = false;

		k = {x:Std.int(Const.CELL_SIZE/2),y:Std.int(Const.CELL_SIZE / 2)};

		mc = game.dm.attach("square",Const.DP_SQUARE);
		mc._xscale = game.scale;
		mc._yscale = game.scale;
		mc._x = getXCoord();
		mc._y = getYCoord();
		if( MMApi.hasControl() )
			mc.onPress = onPress;

		mc.stop();

		grass = game.dm.attach("grass",Const.DP_GRASS);
		grass._xscale = game.scale;
		grass._yscale = game.scale;
		grass._x = getXCoord();
		grass._y = getYCoord();
		grass.smc.gotoAndStop(1);

		addAnimal();

		display;
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
		grass.removeMovieClip();
		grass = null;
		mcPoints.removeMovieClip();
		mcPoints = null;
		animal.removeMovieClip();
		animal = null;
	}

	public function lowQuality() {
	
		if( isLowQuality )
			return;

		if( animal == null )
			return;

		animal.stop();
		var matrix = new flash.geom.Matrix(1,0,0,1,0,0);
		matrix.scale( animal._xscale / 100, animal._yscale / 100);
		matrix.translate(animal._x,animal._y);
		game.bmpData.draw( animal, matrix ) ;
		animal.removeMovieClip();
		animal = null;
		isLowQuality = true;
	}

	function addAnimal() {
		switch( points - 1 ) {
			case 1 : 
				animal = game.dm.attach("bebeh", Const.DP_ANIMALS );				
			case 4 : 
				animal = game.dm.attach("meumeu", Const.DP_ANIMALS );
		}
		if( animal != null ) {
			animal._x = getXCoord() + posXAnimal( animal );
			animal._y = getYCoord()  + posYAnimal( animal );
			var rnd = Std.random(2);			
			animal._xscale = game.scale * (if( rnd == 0 ) 1 else -1);
			animal._yscale = game.scale * (if( rnd == 0 ) 1 else -1);
			animal._rotation = Std.random( 361 );			
			animal.gotoAndPlay( Std.random( animal._totalframes) + 1 );
		}
	}

	public function isClosed() {
		return pos.t && pos.r && pos.b && pos.l;
	}

	public function getXCoord() : Float{
		return this.x * Const.CELL_SIZE * game.scale / 100 + Const.MARGIN;
	}

	public function getYCoord() : Float {
		return this.y * Const.CELL_SIZE * game.scale / 100 + Const.MARGIN;
	}

	public function colorRed() {
		colored = true;
		grass.smc.gotoAndStop(2);
		if( MMApi.isReconnecting() ) {
			grass.smc.smc.gotoAndStop( grass.smc.smc._totalframes );
			return;
		}
		if( animal != null ) {
			addPoints();
		}
	}

	public function colorBlue() {
		colored = true;
		grass.smc.gotoAndStop(3);
		if( MMApi.isReconnecting() ) {
			grass.smc.smc.gotoAndStop( grass.smc.smc._totalframes );			
			return;
		}
		if( animal != null ) {
			addPoints();
		}
	}

	public function addPoints() {
		mcPoints = game.dm.attach("points",Const.DP_SELECT);
		mcPoints._xscale = game.scale;
		mcPoints._yscale = game.scale;
		mcPoints._x = getXCoord() + posXAnimal( mcPoints );
		mcPoints._y = getYCoord() + posYAnimal( mcPoints );	
		var field : flash.TextField = ( cast mcPoints.smc.smc ).field;
		field.text = Std.string( points + 1 );
	}

	public function toString(){
		return "Cell ("+x+","+y+") [t:"+pos.t+" r:"+pos.r+" b:"+pos.b+" l:"+pos.l+"] [t:"+dpl.t+" r:"+dpl.r+" b:"+dpl.b+" l:"+dpl.l+"]";
	}
	
	public function onPress() {

		if( !MMApi.isMyTurn() && !game.lock ) {
			return;
		}
		
		var a : Point = { x:0, y :0 };
		var b : Point = { x:Const.CELL_SIZE, y : 0 };
		var c : Point = { x:Const.CELL_SIZE, y : Const.CELL_SIZE } ;
		var d : Point = { x:0, y : Const.CELL_SIZE };
		var p : Point = { x: Std.int(mc._xmouse), y : Std.int(mc._ymouse) };			

		var addedBorder = {t:false,r:false,b:false,l:false, points : points};
				
		if( isInsideTriangle( a,b,k,p ) && !pos.t) {
			addedBorder.t = true;
		}
			
		if( isInsideTriangle( b,c,k,p ) && !pos.r ){
			addedBorder.r = true;
		}

		if( isInsideTriangle( c,d,k,p ) && !pos.b ){
			addedBorder.b = true;
		}

		if( isInsideTriangle( d,a,k,p ) && !pos.l ){
			addedBorder.l = true;
		}

		if( !addedBorder.t && !addedBorder.r && !addedBorder.b && !addedBorder.l ) {
			return;
		}

		game.onBorderAdded(this.x, this.y,addedBorder);
	}

	/* Cell representation :
		A-----------B
		|			|
		|			|
		|	  K		|
		|			|
		|			|
		D-----------C

		Where K represents the center of the cell
	*/
	public function getDirection() {
		if( isClosed() )
			return 1;

		var a : Point = { x:0, y :0 };
		var b : Point = { x:Const.CELL_SIZE, y : 0 };
		var c : Point = { x:Const.CELL_SIZE, y : Const.CELL_SIZE } ;
		var d : Point = { x:0, y : Const.CELL_SIZE };
		var p : Point = { x: Std.int(mc._xmouse), y : Std.int(mc._ymouse) };

		if( p.x <= 0 && p.x > Const.CELL_SIZE -1 )
			return 1;

		if( p.y <= 0 && p.y > Const.CELL_SIZE - 1)
			return 1;

		if( isInsideTriangle( a,b,k,p ) && !pos.t ) {
			 return 2;
		}
			
		if( isInsideTriangle( b,c,k,p ) && !pos.r ){
			return 3;
		}

		if( isInsideTriangle( c,d,k,p ) && !pos.b ){
			return 4;
		}

		if( isInsideTriangle( d,a,k,p ) && !pos.l ){
			return 5;
		}
		return 1;
	}

	public function closeBottom() {
		pos.b = true;
		dpl.b = true;
	}

	public function closeTop() {
		pos.t = true;
		dpl.t = true;
	}

	public function closeRight() {
		pos.r = true;
		dpl.r = true;
	}

	public function closeLeft() {
		pos.l = true;
		dpl.l = true;
	}

	public function display() {
		if( isLocked )
			return;

		if( dpl.t && dpl.r && dpl.b && dpl.l ) {
			mc.gotoAndStop( 1 );
			return;
		}
		if( dpl.r && dpl.b && dpl.l ) {
			mc.gotoAndStop( 2 );
			return;
		}
		if( dpl.t && dpl.r && dpl.l ) {
			mc.gotoAndStop( 3 );
			return;
		}
		if( dpl.t && dpl.b && dpl.l ) {
			mc.gotoAndStop( 4 );
			return;
		}
		if( dpl.t && dpl.b && dpl.r ) {
			mc.gotoAndStop( 5 );
			return;
		}
		if( dpl.t && dpl.b ) {
			mc.gotoAndStop( 6 );
			return;
		}
		if( dpl.b && dpl.r ) {
			mc.gotoAndStop( 7 );
			if( isClosed() && x == Const.BOARD_SIZE -1 && y == Const.BOARD_SIZE -1 ) {
				lock();
			}
			return;
		}
		if( dpl.b && dpl.l ) {
			mc.gotoAndStop( 8 );
			if( isClosed() && x == 0 && y == Const.BOARD_SIZE -1 ) {
				lock();
			}
			return;
		}
		if( dpl.t && dpl.r ) {
			mc.gotoAndStop( 9 );
			if( isClosed() && x == Const.BOARD_SIZE - 1 && y == 0 ) {
				lock();
			}
			return;
		}
		if( dpl.t && dpl.l ) {
			mc.gotoAndStop( 10 );
			if( isClosed() && x == 0 && y == 0 ) {
				lock();
			}
			return;
		}
		if( dpl.l && dpl.r ) {
			mc.gotoAndStop( 11 );
			return;
		}
		if( dpl.t ) {
			mc.gotoAndStop( 12 );
			if( isClosed() && y == 0 ) {
				lock();
			}
			return;
		}
		if( dpl.b ) {
			mc.gotoAndStop( 13 );
			if( isClosed() && y == Const.BOARD_SIZE - 1 ) {
				lock();
			}
			return;
		}
		if( dpl.r ) {
			mc.gotoAndStop( 14 );
			if( isClosed() && x == Const.BOARD_SIZE - 1 ) {
				lock();
			}
			return;
		}
		if( dpl.l ) {
			mc.gotoAndStop( 15 );
			if( isClosed() && x == 0 ) {
				lock();
			}
			return;
		}

		mc.gotoAndStop( 16 );
		if( isClosed() ) {
			lock();
			return;
		}

		return;
	}

	public function lock() {
	//	trace("in x=" + x + " y=" + y);
		var matrix = new flash.geom.Matrix(1,0,0,1,0,0);
		matrix.scale( mc._xscale / 100, mc._yscale / 100);
		matrix.translate(mc._x,mc._y);
		game.bmpData.draw( mc, matrix ) ;
		mc.removeMovieClip();
		mc = null;
		isLocked = true;
	}

	function isInsideTriangle(a,b,c,p) {
		if( isLeft(c,a,p) && isLeft(b,c,p) && !isLeft(b,a,p) )
			return true;
		return false;
	}

	function isLeft( p1, p2, p ){
		return ( ( p2.x - p1.x) * (p.y - p1.y) - (p.x - p1.x) * (p2.y - p1.y) ) > 0;
	}

	function posXAnimal( animal : flash.MovieClip ) {
		return ( Const.CELL_SIZE * game.scale / 100 )  / 2;
	}

	function posYAnimal( animal : flash.MovieClip ) {
		return ( Const.CELL_SIZE * game.scale / 100 )  / 2;
	}

	public function getPoints( ) {
		return points +1;
	}

}
