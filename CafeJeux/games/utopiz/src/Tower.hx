import Common;
import Anim;

class Tower {
	
	var game : Game;
	var socle : flash.MovieClip;
	var firstBlock : flash.MovieClip;
	var baseX : Int;
	var baseY : Int;
	var blocks : List<Block>;
	var _lock : Bool;
	
	public var isLeftTower : Bool;
	public var tokens : Int;
	public var availableActions : Int;
	public var expectedCost : Int;
	
	public function new( game, x, y, isLeftTower ) {
		availableActions = Const.TURN_ACTIONS;
		tokens = Const.TURN_TOKENS;
		expectedCost = 0;
		baseX = x;
		baseY = y;
		this.game = game;
		this.isLeftTower= isLeftTower;
		blocks = new List();
		_lock = true;
		
		firstBlock = game.dm.attach("emptyBlock", Const.DP_BG );
		firstBlock._xscale = if( isLeftTower ) Const.XSCALE else -Const.XSCALE;
		firstBlock._yscale = Const.YSCALE;		
		firstBlock._x = baseX;
		firstBlock._y = baseY ;
		firstBlock.stop();
		
		socle = game.dm.attach("socle", Const.DP_BG);
		socle._xscale = if( isLeftTower) Const.XSCALE else -Const.XSCALE;
		socle._yscale = Const.YSCALE;
		socle._x = baseX;
		socle._y = baseY;
				
        cast( firstBlock).remove.onRelease = displayChoiceBarFromFirstBlock; 
        cast( firstBlock).remove.onReleaseOutside = hideChoiceBar;
		
	}

	public function addBlock( type, bottom, cbk ) {

		cast( firstBlock).remove.onRelease = displayChoiceBarFromFirstBlock;
		cast( blocks.last().mc ).remove.onRelease = displayChoiceBarFromBlock;
		
		var block = Block.createBlock( type, game, isLeftTower );
		if( bottom ) {
			block.mc._x = baseX;
			block.mc._y = baseY;
			var anim = new ElevationAnim( block.mc, baseY - Const.BLOCK_HEIGHT, true );
			anim.onEnd = cbk;
			game.anim.push( anim );
			for( block in blocks ){
				var anim = new ElevationAnim( block.mc, block.mc._y - Const.BLOCK_HEIGHT, false );
				game.anim.push( anim );	
			}
			blocks.push( block );			
			block.index = 0;
			var i = 1;
			for( b in blocks ) {
				b.index = i++;
			}
			giveControlToBlock( blocks.last() );
			swapDepths();
			return;
		}
		var lastBlock = blocks.last();
		block.mc._x = baseX;
		block.mc._y = lastBlock.mc._y;
		var anim = new ElevationAnim( block.mc, lastBlock.mc._y - Const.BLOCK_HEIGHT, true );
		anim.onEnd = cbk;
		game.anim.push( anim );
		blocks.add( block );
		block.index = blocks.length;
		giveControlToBlock( block );
		swapDepths();
		return;		
	}
	
	public function updateAvailableTokens() {
		expectedCost = 0;
		for( block in blocks ) {
			tokens += block.cost;
		}
		tokens += Const.TURN_TOKENS; 
	}

	public function updateActionsCount() {
		availableActions = 0;
		for( block in blocks ) {
			availableActions += block.actions;
		}
		availableActions += Const.TURN_ACTIONS; 
	}

	public function getBudget() {
		return tokens - expectedCost;
	}

	public function getRemainingActions() {
		return availableActions;
	}

    function displayChoiceBarFromFirstBlock()  { 
		if( _lock ) return;		
		trace("infirst" + firstBlock._height);
		displayChoiceBar( baseX, baseY, 0 );
	}
		
	function displayChoiceBarFromBlock() {
		if( _lock ) return;		
		var last = blocks.last();
		trace("into" + last.mc._height);
		displayChoiceBar( last.mc._x, last.mc._y, last.index );
	}
	
	function giveControlToBlock( b: Block ) {
		for( block in blocks ) {
			removeControlFromBlock( block );
		}
        cast( b.mc).remove.onRelease = displayChoiceBarFromBlock; 
        cast( b.mc).remove.onReleaseOutside = hideChoiceBar;		
	}
	
	function removeControlFromBlock( b: Block ) {
        cast( b.mc).remove.onRelease = function() {}; 
        cast( b.mc).remove.onReleaseOutside = function() {};
	}
	
	public function lock() {
		_lock = true;
	}
	
	public function unLock() {
		_lock = false;
	}
	
	function swapDepths() {
		for( block in blocks ) {
			game.dm.over( block.mc );
		}
		game.dm.over( firstBlock );
		game.dm.over( socle );
	}
	
	function displayChoiceBar( x, y, index ) {
		if( _lock ) 
			return;
		
		game.displayChoiceBar( x , y, index );
		cast( firstBlock).remove.onRelease = hideChoiceBar;
		cast( blocks.last().mc ).remove.onRelease = hideChoiceBar;
	}
	
	function hideChoiceBar() {
		if( _lock ) 
			return;
			
		game.hideChoiceBar();
		cast( firstBlock).remove.onRelease = displayChoiceBarFromFirstBlock;
		cast( blocks.last().mc ).remove.onRelease = displayChoiceBarFromBlock;
	}
	
	public function getCount() {
		return blocks.length;
	}
}