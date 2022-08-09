import Common;
import Anim;
import flash.Mouse;

class Game implements MMGame<Msg> {

	public var dm : mt.DepthManager;
	public var anim : List<Anim>;
	
	var team : Bool;
	var root : flash.MovieClip;
	var sky : flash.MovieClip;
	var ground : flash.MovieClip;
	var hill : flash.MovieClip;
	var myTower : Tower;
	var oppTower : Tower;
	var leftBase : flash.MovieClip;
	var rightBase : flash.MovieClip;
	var choiceBar : ChoiceBar;
	var maxTurns : Int;
	var currentTurn : Int;
	
	function new( base : flash.MovieClip ) {
		
		anim = new List();
		dm = new mt.DepthManager(base);
		maxTurns = Const.MAXTURNS;
		currentTurn = 1;
		
		sky = dm.attach("UIGame",Const.DP_BG);		
		sky._xscale = Const.WIDTH / sky._width * 100;
		sky._yscale = Const.WIDTH / sky._height * 100;
		Const.XSCALE = sky._xscale;
		Const.YSCALE = sky._yscale;
		
		var refY = 262/480*100;
		hill = dm.attach("colline",Const.DP_BG);
		hill._xscale = Const.XSCALE;
		hill._yscale = Const.YSCALE;
		hill._y = Const.WIDTH - hill._height;
				
		ground = dm.attach("ground",Const.DP_BG);		
		ground._xscale = Const.XSCALE;
		ground._yscale =  Const.YSCALE;
		ground._y = 94;
		
		choiceBar = new ChoiceBar( this );
		
		MMApi.lockMessages(false);
	}

	public function initialize() {
		return Init(true);
	}

	public function main() {

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
		
		myTower.unLock();
	}

	public function onBlockChoosed( type : BlockType, bottom : Bool ) {  
		trace("onBlockChoosed");
		myTower.expectedCost += Block.getCost( type );
		myTower.availableActions -= 1;
		if( myTower.getBudget() == 0 || myTower.getRemainingActions() == 0 ) {
			MMApi.endTurn(EndBlock( type, bottom));
			return;
		}
		MMApi.sendMessage(AddBlock( type, bottom));
	}
	
	public function onMessage( mine : Bool, msg : Msg ) {
		switch( msg ) {
			case Init(true) : 
				team = !mine;	
				if( team ) {
					MMApi.setColors(Const.COLOR1,Const.COLOR2);
				} else {
					MMApi.setColors(Const.COLOR2,Const.COLOR1);		
				}									
				if( MMApi.isMyTurn() ) {
					myTower = new Tower( this, 104, 240, true );
					oppTower = new Tower( this, 200, 240, false );				
				} else {
					myTower = new Tower( this, 200, 240, false );				
					oppTower = new Tower( this, 104, 240, true );
				}
				updateScore();
			
			case AddBlock( type, bottom ) :
				MMApi.lockMessages(true);			
				if( MMApi.isMyTurn() ) {
					myTower.tokens -= myTower.expectedCost;
					trace( myTower.tokens );
					myTower.addBlock( type, bottom, onBlockAdded );
					myTower.lock();
				} else {
					oppTower.addBlock( type, bottom, onBlockAdded );
				}
				
			case EndBlock( type, bottom ) :
				
				MMApi.lockMessages(true);
				if( mine ) {
					myTower.tokens -= myTower.expectedCost;				
					myTower.updateAvailableTokens();
					myTower.updateActionsCount();
					myTower.addBlock( type, bottom, resolveConflict );
					myTower.lock();
				} else {
					oppTower.addBlock( type, bottom, resolveConflict );
				}
		}
	}
	
	public function onTurnDone() {
		updateScore();
		
		if( !MMApi.hasControl() || MMApi.isReconnecting() )
			return;
		
		if( !MMApi.isMyTurn() ) {
			// on cache les composants
		}else {
		}	
	}

	public function updateScore(){
		var s = "";
				
		s += "<div class=\"score0\">"+myTower.getCount()+" </div>";
		s += "<div class=\"score1\">"+oppTower.getCount()+"</div>";
		
		s += "<p>";
		if( MMApi.hasControl() && !MMApi.isReconnecting() ){
			s += if( !MMApi.isMyTurn() ) "Tour de votre adversaire : $other" else "A vous de jouer , $me !";
		}
		s += "</p>";
		
		MMApi.setInfos(s);
	}

	function checkVictory(){
	}

	function victory( mine : Bool ){
		MMApi.victory( mine );
	}

	public function onVictory( mine : Bool ){
		haxe.Timer.delayed( onGameOver, 2000 )();
	}

	public function onGameOver() {
		MMApi.gameOver();
		clean();
	}

	public function onReconnectDone(){
	}

	public function clean() {
		sky.removeMovieClip();
		ground.removeMovieClip();
		hill.removeMovieClip();
		choiceBar.clean();
	}


	/* ----------------------------------------------------------*/
	/*--------------------------- ANIMS -------------------------*/
	/* ----------------------------------------------------------*/
	public function resolveConflict() {
		trace("resolveConflict");
		if( MMApi.isMyTurn() ) 
			myTower.unLock();
			
		MMApi.lockMessages( false );
	}
	
	public function onBlockAdded() {
		trace("onBlockAdded");
		if( MMApi.isMyTurn() ) 
			myTower.unLock();
			
		MMApi.lockMessages( false );
	}

	/* ----------------------------------------------------------*/
	/*------------------------ CALLBACKS ------------------------*/
	/* ----------------------------------------------------------*/
	
	
	public function displayChoiceBar( x, y, index ) {
		choiceBar.show( x, y, index, myTower.getBudget() );
	}
	
	public function hideChoiceBar() {
		choiceBar.hide();
	}
	
}
