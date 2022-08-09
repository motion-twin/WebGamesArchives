import Common;
import Anim;
import flash.Mouse;

class Game implements MMGame<Msg> {

	public var dm : mt.DepthManager;
	public var grid : Array<Array<Cell>>;
	public var anim : List<Anim>;
	public var scale : Float;
	public var bmpContainer : flash.MovieClip;
	public var bmpRect : flash.geom.Rectangle<Int>;
	public var bmpData : flash.display.BitmapData;

	var root : flash.MovieClip;
	var mcSelector:flash.MovieClip;
	var mcHand:flash.MovieClip;
	var mcPabo:flash.MovieClip; 
	var mcTrees:flash.MovieClip;
	var mcGlow:flash.MovieClip;
	var mcAnim:flash.MovieClip;
	var mcBg : flash.MovieClip;

	var myCount : Int;
	var oppCount : Int;
	var team : Bool;
	var currentCell : Cell;
	var gridPoints : Int;
	var currentDir : Int;

	var modifiedCell : Cell;
	var isMine : Bool;
	var addedBorder : Pos;
	var notDisplayed : Bool;
	var currentOption : Int;

	public var lock : Bool;

	function new( base : flash.MovieClip ) {	
		currentOption = 2;
		isMine = false;
		root = base;
		myCount = 0;
		oppCount = 0;
		gridPoints = 0;
		notDisplayed = true;
		lock = false;

		anim = new List();
		dm = new mt.DepthManager(base);

		mcBg = dm.attach("bground",Const.DP_BG);
		mcBg.cacheAsBitmap = true;
		mcBg.gotoAndStop(currentOption);

		mcSelector = dm.attach("select",Const.DP_SELECT);
		mcSelector.stop();		

		mcTrees = dm.attach("trees",Const.DP_TREE);		
		mcTrees.cacheAsBitmap = true;
		mcTrees.gotoAndStop(currentOption);

		bmpData = new flash.display.BitmapData( Const.WIDTH, Const.WIDTH, true, 0x000FFF);
		bmpContainer = dm.empty( Const.DP_ANIMALS );
		bmpContainer.attachBitmap( bmpData, Const.DP_ANIMALS );

		mcAnim = dm.attach("fall", Const.DP_SELECT );
		mcAnim._visible = false;

		mcGlow = dm.attach( "glow", Const.DP_ANIMALS );
		mcGlow._visible = false;

		mcHand = dm.attach("hand",Const.DP_SELECT);
		mcHand._visible = false;

		mcPabo = dm.attach("invisible", Const.DP_INVISIBLE );
		mcPabo._visible = false;

		MMApi.lockMessages(false);
	}

	// Grid Generation
	public function initialize() {
		return Init( Grid.generate() );
	}

	public function main() {

		//XXX animList de barrières qui tombent

		if( anim.length > 0 ){
			for( a in anim ){
				if( a.play() ){
					a.onEnd();
					anim.remove( a );
				}
			}
			return;
		}

		if( !MMApi.isMyTurn() || !MMApi.hasControl()) {
			return;
		}


		if( lock )
			return;

		// On background, we do nothing
		if( mcBg._xmouse < Const.MARGIN || mcBg._xmouse > Const.WIDTH - Const.MARGIN ) {				
			mcHand._visible = false;
			mcSelector._visible = false;
			return;
		}

		if( mcBg._ymouse < Const.MARGIN || mcBg._ymouse > Const.WIDTH - Const.MARGIN ) {
			mcHand._visible = false;
			mcSelector._visible = false;
			return;
		}

		mcHand._x = mcBg._xmouse;
		mcHand._y = mcBg._ymouse;		
		mcHand._visible = true;

		var i = Std.int( ( mcBg._xmouse - Const.MARGIN ) / ( Const.CELL_SIZE * scale / 100 ) ); 
		var j = Std.int( ( mcBg._ymouse - Const.MARGIN ) / ( Const.CELL_SIZE * scale / 100 ) );

		var currentCell = grid[i][j];
		if( currentCell == null ){
			mcHand._visible = false;
			return;
		}

		if( currentCell.isClosed() ) {
			return;
		}

	}


	/*---------------------------HEART-------------------------------*/


//	public function onBorderAdded( cell : Cell, addedBorder : Pos ){	
	public function onBorderAdded( x: Int, y :Int, addedBorder : Pos ){	
		if( lock )
			return;

		mcSelector._visible = false;
		lock = true;

		var cell = grid[x][y];
		if( !wouldCloseCell( cell, addedBorder ) && !wouldCloseAdjacentCell( x, y, addedBorder ) ) {
			MMApi.endTurn( UpdateCell( x, y, addedBorder ) );
			return;
		}

		MMApi.sendMessage( UpdateCell( x, y, addedBorder ) );
	}

	public function onMessage( mine : Bool, msg : Msg ) {
		switch( msg ) {

		case Init(g):
			team = !mine;

			if( team )
				MMApi.setColors(Const.COLOR1,Const.COLOR2);
			else
				MMApi.setColors(Const.COLOR2,Const.COLOR1);			

			var totalWidth = Const.WIDTH - Const.MARGIN * 2;
			var actualWidth = Const.BOARD_SIZE * Const.CELL_SIZE;
			this.scale = totalWidth / actualWidth * 100;
			mcHand._xscale = scale;
			mcHand._yscale = scale;		
			mcAnim._xscale = scale;
			mcAnim._yscale = scale;
			
			grid = new Array();
			for( i in 0...Const.BOARD_SIZE ){
				grid[i] = new Array();
				for( j in 0...Const.BOARD_SIZE ){			
					var cc = g[i][j];
					var nc = {t:cc.t,r:cc.r,b:cc.b,l:cc.l,points:cc.points};
					var c = new Cell(this,i,j,cc,nc);
					grid[i][j] = c;
					gridPoints += c.getPoints();
					c.display();
				}
			}

		case UpdateCell( x, y, addedBorder ) :

			MMApi.lockMessages(true);
			notDisplayed = true;
			modifiedCell = grid[x][y];
			isMine = mine;
			this.addedBorder = addedBorder;
			updateScoreByCell();
			if( MMApi.isReconnecting() )
				checkVictory();
			doFall(x,y,addedBorder);
		}
	}


	/*---------------------------UPDATE-------------------------------*/


	function doFall( x,y, addedBorder ) {
		mcHand._visible = false;

		var ACTUAL_CELL_SIZE = Const.CELL_SIZE * scale / 100;

		var frame = 1;
		if( addedBorder.t )
			frame = 2;
		else if( addedBorder.r )
			frame = 3;
		else if( addedBorder.b )
			frame = 4;
		else if( addedBorder.l )
			frame = 5;

		/*
		mcGlow.removeMovieClip();
		*/
		mcGlow._visible = false;
		mcGlow._x = x * Const.CELL_SIZE * scale / 100 + Const.MARGIN;
		mcGlow._y = y * Const.CELL_SIZE * scale / 100 + Const.MARGIN;
		mcGlow._xscale = scale;
		mcGlow._yscale = scale;
		mcGlow.gotoAndStop( frame );

		mcAnim._x = x * Const.CELL_SIZE * scale / 100 + Const.MARGIN;
		mcAnim._y = y * Const.CELL_SIZE * scale / 100 + Const.MARGIN;
		var fa = new FallAnim( mcAnim, frame );
		fa.onEnd = onEndFall;
		fa.onUpdate = onUpdateFall;
		anim.add( fa );
	}

	function onEndFall() {
		mcGlow._visible = true;
		if( MMApi.isMyTurn() )
			mcHand._visible = true;

		updateScore();
		lock = false;
		MMApi.lockMessages( false );
	}

	function onUpdateFall( mc, f : Float){
		//XXX frame 13 -> virer lock et lancer anims grow / tester mcSelector and mcHand

		if( f >= 18 ) {
			if( notDisplayed ) {
				updateCell();
				checkVictory();
				displayGrid();
				notDisplayed = false;
			}
		}
	}

	function borderAdded( b ) : Bool {
		return b.t || b.b || b.r || b.l;
	}

    function updateCell() {
        var cell = modifiedCell;

		if( addedBorder.t ) cell.closeTop();
		if( addedBorder.r ) cell.closeRight();
		if( addedBorder.b ) cell.closeBottom();
		if( addedBorder.l ) cell.closeLeft();

		if( cell.isClosed() ) {
			if( !isMine ) {
				cell.mine = false;
				if( team )
					cell.colorRed();
				else
					cell.colorBlue();
			} else {
				cell.mine = true;
				if( team )
					cell.colorBlue();
				else
					cell.colorRed();
			}
		}
		closeAdjacentBorder(cell, addedBorder, if( isMine ) true else false );
    }

	function updateScoreByCell() {
		var cell = modifiedCell;
		var tc : Pos = { t : cell.pos.t, r: cell.pos.r, b: cell.pos.b, l: cell.pos.l, points : cell.getPoints() };
		if( addedBorder.t ) tc.t = true;
		if( addedBorder.r ) tc.r = true;
		if( addedBorder.b ) tc.b = true;
		if( addedBorder.l ) tc.l = true;

		if( tc.t && tc.r && tc.l && tc.b ) {
			if( !isMine ) {
				oppCount += tc.points;
			} else {
				myCount += tc.points;
			}
		}
	}

	public function onEndCloseCellAnim() {
		displayGrid();
		notDisplayed = false;
	}


	/*---------------------------UTILITY FUNCTIONS-------------------------------*/


	function displayGrid() {
		var lowQuality = false;

		if( mt.Timer.fps() < 15 )
			lowQuality = true;

		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){

				var c = grid[i][j];

				// case déjà cachée en bitmap
				if( c.isLocked )
					continue;

				var b = grid[i][j+1];
				var r = grid[i+1][j];
				if( c.isClosed() && b.isClosed() ) {
					if( c.mine == b.mine ) {
						c.dpl.b = false;
						b.dpl.t = false;
					}
				}

				if( c.isClosed() && r.isClosed() ) {
					if( c.mine == r.mine ) {
						c.dpl.r = false;
						r.dpl.l = false;
					}
				}

				if( lowQuality && ! c.isLowQuality )
					c.lowQuality();

				c.display();
			}
		}			
	}
	
	function wouldCloseCell( cell: Cell, addedBorder : Pos ) {
		if( !cell.pos.t && !addedBorder.t )
			return false;
		if( !cell.pos.b && !addedBorder.b )
			return false;
		if( !cell.pos.r && !addedBorder.r )
			return false;
		if( !cell.pos.l && !addedBorder.l )
			return false;
		return true;
	}

	function wouldCloseAdjacentCell( i, j , addedBorder : Pos ) {	
		if( addedBorder.t ) {		
			var topCell = grid[i][j-1];
			if( !topCell.pos.b) {	
				if( topCell.pos.t && topCell.pos.l && topCell.pos.r )
					return true;
			}
			return false;
		}

		if( addedBorder.l ) {
			var leftCell = grid[i-1][j];
			if( !leftCell.pos.r ) {
				if( leftCell.pos.t && leftCell.pos.b && leftCell.pos.l ) 
					return true;
			}
			return false;
		}

		if( addedBorder.r ) {
			var rightCell = grid[i+1][j];
			if( !rightCell.pos.l) {
				if( rightCell.pos.r && rightCell.pos.b && rightCell.pos.t ) {
					return true;
				}
			}
			return false;
		}

		if( addedBorder.b ) {
			var bottomCell = grid[i][j+1];
			if( !bottomCell.pos.t ) {
				if( bottomCell.pos.r && bottomCell.pos.b && bottomCell.pos.l )
					return true;
			}
			return false;
		}

		return false;	
	}

	function closeAdjacentBorder( cell : Cell, pos : Pos, mine : Bool ){	
		var i = cell.x;
		var j = cell.y;

		if( pos.t ) {		
			var topCell = grid[i][j-1];
			if( topCell != null && !topCell.pos.b && cell.pos.t) {
				topCell.closeBottom();
				if( topCell.isClosed() ) {
                   closeCell( topCell, mine );
				}
				return;
			}
		}

		if( pos.l ) {
			var leftCell = grid[i-1][j];
			if( leftCell != null && !leftCell.pos.r && cell.pos.l ) {
				leftCell.closeRight();
				if( leftCell.isClosed() ) {
                   closeCell( leftCell, mine );								
				}
				return;
			}
		}

		if( pos.r ) {
			var rightCell = grid[i+1][j];
			if( rightCell != null && !rightCell.pos.l  && cell.pos.r) {
				rightCell.closeLeft();
				if( rightCell.isClosed() ) {
                   closeCell( rightCell, mine );								
				}
				return;
			}
		}

		if( pos.b ) {
			var bottomCell = grid[i][j+1];
			if( bottomCell != null && !bottomCell.pos.t && cell.pos.b ) {
				bottomCell.closeTop();
				if( bottomCell.isClosed() ) {
	                closeCell( bottomCell, mine );								
				}
				return;
			}
		}		
	}

	function closeCell( cell : Cell, mine : Bool) {
		cell.mine = mine;
		if( !mine ) {
			if( team )
				cell.colorRed();
			else
				cell.colorBlue();
			oppCount += cell.getPoints();
		} else {
			if( team )
				cell.colorBlue();
			else
				cell.colorRed();
			myCount += cell.getPoints();
		}
	}

	public function emptyGrid() {
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				grid[i][j].clean();
			}
		}	
	}

	public function clean() {
		bmpData.dispose();
		mcBg.removeMovieClip();
		mcTrees.removeMovieClip();
		emptyGrid();
	}

	/*---------------------------SCORE && VICTORY-------------------------------*/


	public function onTurnDone() {
		updateScore();
		if( !MMApi.hasControl() || MMApi.isReconnecting() )
			return;
		
		if( !MMApi.isMyTurn() ) {
			mcHand._visible = false;
			mcPabo.gotoAndStop(1);
			mcPabo._visible = true;
			mcPabo.onRelease = function() {};
			mcPabo.useHandCursor = false;
		}else {
			mcHand._visible = false;
			mcHand._xscale = scale;
			mcHand._yscale = scale;
			mcPabo._visible = false;
		}	
	}

	public function updateScore(){
		var s = "";

		if( myCount != null && oppCount != null ){
			s += "<div class=\"score0\">"+myCount+" </div>";
			s += "<div class=\"score1\">"+oppCount+"</div>";
		}

		s += "<p>";
		if( MMApi.hasControl() && !MMApi.isReconnecting() ){
			s += if( !MMApi.isMyTurn() ) "Tour de votre adversaire : $other" else "A vous de jouer , $me !";
		}
		s += "</p>";

		MMApi.setInfos(s);
	}

	function checkVictory(){

		// si toutes les cellules sont activées 
		if( !Const.WITHPOINTS ) {
			if( (myCount + oppCount) < Const.BOARD_SIZE * Const.BOARD_SIZE )
				return;
		}
		else{
			if( (myCount + oppCount) < gridPoints )
				return;			
		}
	
		if( myCount == oppCount ) 
			victory(null);
		else
			victory( myCount > oppCount );
	}

	function victory( mine : Bool ){
		mcGlow.removeMovieClip();
		mcHand.removeMovieClip();
		mcPabo.removeMovieClip();	
		mcAnim.removeMovieClip();
		mcSelector.removeMovieClip();
		MMApi.victory( mine );
	}

	public function onVictory( mine : Bool ){
		haxe.Timer.delay( onGameOver, 2000 );
	}

	public function onGameOver() {
		MMApi.gameOver();
		clean();
	}

	public function onReconnectDone(){
		updateScore();

		if( !MMApi.hasControl() )
			return;

		if( !MMApi.isMyTurn() ) {
			mcHand._visible = false;
			mcPabo._visible = true;
			mcPabo.gotoAndStop(1);
			mcPabo.onRelease = function() {};
			mcPabo.useHandCursor = false;
		}else {
			mcHand._visible = true;
			mcHand._xscale = scale;
			mcHand._yscale = scale;
			mcPabo._visible = false;
		}
	}

}
