import Common;

class Block {
	
	var attack : Int;
	var defense : Int;
	var game : Game;	
	
	public var index : Int;
	public var actions : Int;
	public var cost : Int;
	public var type : BlockType;
	public var mc : flash.MovieClip;
	
	public static function getCost ( type : BlockType ) {
			switch( type ) {
				case BAttack :  return 2;
				case BDefense : return 1;
				case BSupply : return 2;
				case BBuilder : return 1;
			}
	}

	public static function getActions( type : BlockType ) {
			switch( type ) {
				case BBuilder : return 1;
				default : return 0;
			}
	}

	public static function createBlock( type : BlockType, game, isLeftTower ) {
			switch( type ) {
				case BAttack :  return createAttackBlock( game, isLeftTower);
				case BDefense : return createDefenseBlock( game, isLeftTower);
				case BSupply : return createSupplyBlock( game, isLeftTower);
				case BBuilder : return createBuilderBlock( game, isLeftTower);
				default : return null;
			}
	}
	
	public static function createAttackBlock( game, isLeftTower) {
		var b = new Block( 2, 1, 0, 0, BAttack, game );
		var invert = if( isLeftTower ) false else true;
		b.buildBlock( "attackBlock", invert );
		return b;
	}
	
	public static function createDefenseBlock( game, isLeftTower) {
		var b = new Block( 1, 0, 1, 0, BDefense, game );
		var invert = if( isLeftTower ) false else true;
		b.buildBlock( "defenseBlock", invert );
		return b;
	}
	
	public static function createSupplyBlock( game, isLeftTower) {
		var b = new Block( 2, 0, 0, 0, BSupply, game );
		var invert = if( isLeftTower ) false else true;
		b.buildBlock( "supplyBlock", invert );
		return b;
	}
	
	public static function createBuilderBlock( game, isLeftTower) {
		var b = new Block( 1, 0, 0, 1, BBuilder, game );
		var invert = if( isLeftTower ) false else true;
		b.buildBlock( "buildBlock", invert );
		return b;
	}
	
	public function new( cost, attack, defense, actions : Int, type : BlockType, game  ) {
		this.game = game;
		this.cost = cost;
		this.type = type;
		this.defense = defense;
		this.type = type;
		this.actions = actions;
	}
		
	function buildBlock( name, invert ) {
		mc = game.dm.attach(name, Const.DP_BLOCK );
		mc._xscale = if( invert ) -Const.XSCALE else Const.XSCALE;
		mc._yscale = Const.YSCALE;		
		cast( mc ).skin.gotoAndStop( if(invert) 2 else 1 );
	}
		
	public function clean() {
		mc.removeMovieClip();
	}
}