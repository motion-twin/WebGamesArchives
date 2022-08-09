import Common;

class ChoiceBar {
	
	static var WIDTH = 20;
	static var HEIGHT = 20;
	
	public var displayed : Bool;
	
	var iconeAttack : flash.MovieClip;
	var iconeDefense : flash.MovieClip;
	var iconeSupply : flash.MovieClip;
	var iconeBuild : flash.MovieClip;
	var index : Int;
	var game : Game;
	
	public function new(game : Game){		
		this.game = game;
		displayed = false;
		
		iconeAttack = game.dm.attach("iconeAttack", Const.DP_CHOICEBAR);
		iconeDefense = game.dm.attach("iconeDefense", Const.DP_CHOICEBAR);
		iconeSupply = game.dm.attach("iconeSupply", Const.DP_CHOICEBAR);
		iconeBuild = game.dm.attach("iconeBuild", Const.DP_CHOICEBAR);
		
		iconeAttack._xscale = Const.XSCALE;
		iconeDefense._xscale = Const.XSCALE;
		iconeSupply._xscale = Const.XSCALE;
		iconeBuild._xscale = Const.XSCALE;		
		
		iconeAttack._yscale = Const.YSCALE;
		iconeDefense._yscale = Const.YSCALE;
		iconeSupply._yscale = Const.YSCALE;
		iconeBuild._yscale = Const.YSCALE;		
		
		iconeAttack.gotoAndStop(1);
		iconeDefense.gotoAndStop(1);
		iconeSupply.gotoAndStop(1);
		iconeBuild.gotoAndStop(1);		
		
		iconeAttack.onRollOver = attackLightOn;
		iconeAttack.onRollOut = attackLightOff;
		iconeAttack.onReleaseOutside = attackLightOff;
		iconeAttack.onRelease = attack;

		iconeDefense.onRollOver = defenseLightOn;
		iconeDefense.onRollOut = defenseLightOff;
		iconeDefense.onReleaseOutside = defenseLightOff;
		iconeDefense.onRelease = defense;

		iconeSupply.onRollOver = supplyLightOn;
		iconeSupply.onRollOut = supplyLightOff;
		iconeSupply.onReleaseOutside = supplyLightOff;
		iconeSupply.onRelease = supply;

		iconeBuild.onRollOver = buildLightOn;
		iconeBuild.onRollOut = buildLightOff;
		iconeBuild.onReleaseOutside = buildLightOff;
		iconeBuild.onRelease = build;

		hide();
	}
	
	public function show( x : Float, y : Float, index : Int, tokens : Int ) {
		// XXX pb à régler sur les tokens : afficher
		trace( "show : tokens=" + tokens );
		displayed = true;
		this.index = index;
		
		var h : Float= HEIGHT;
		if( Block.getCost(BBuilder) <= tokens ) {
			iconeBuild._visible = true;
			iconeBuild._x = x + WIDTH;
			iconeBuild._y = y - h;
			h += iconeBuild._height;
		}
		if( Block.getCost(BAttack) <= tokens ) {
			iconeAttack._visible = true;
			iconeAttack._x = x + WIDTH;
			iconeAttack._y = y - h;
			h += iconeAttack._height;
		}
		if( Block.getCost(BDefense) <= tokens ) {
			iconeDefense._visible = true;
			iconeDefense._x = x + WIDTH;
			iconeDefense._y = y - h;
			h += iconeDefense._height;
		}
		if( Block.getCost(BSupply) <= tokens ) {
			iconeSupply._visible = true;
			iconeSupply._x = x + WIDTH;
			iconeSupply._y = y - h;
			h += iconeSupply._height;
		}
		
	}
	
	public function hide() {
		displayed = false;
		iconeAttack._visible = false;
		iconeDefense._visible = false;
		iconeSupply._visible = false;
		iconeBuild._visible = false;
		index = -1;
	}
	
	public function clean() {
		iconeAttack.removeMovieClip();
		iconeDefense.removeMovieClip();
		iconeSupply.removeMovieClip();
		iconeBuild.removeMovieClip();		
	}
	
	function attackLightOn() { iconeAttack.gotoAndStop(2); }
	function attackLightOff() { iconeAttack.gotoAndStop(1); }
	function attack() {
		iconeAttack.gotoAndStop(1);
		game.onBlockChoosed( BAttack, if( index == 0 ) true else false );
		hide();
	}

	function defenseLightOn() { iconeDefense.gotoAndStop(2);}
	function defenseLightOff() { iconeDefense.gotoAndStop(1);}
	function defense() {
		iconeDefense.gotoAndStop(1);
		game.onBlockChoosed( BDefense, if( index == 0 ) true else false );
		hide();
	}
	
	function supplyLightOn() { iconeSupply.gotoAndStop(2);}
	function supplyLightOff() { iconeSupply.gotoAndStop(1);}
	function supply() {
		iconeSupply.gotoAndStop(1);
		game.onBlockChoosed( BSupply, if( index == 0 ) true else false );
		hide();
	}

	function buildLightOn() { iconeBuild.gotoAndStop(2); }
	function buildLightOff() { iconeBuild.gotoAndStop(1); }
	function build() {
		iconeBuild.gotoAndStop(1);
		game.onBlockChoosed( BBuilder, if( index == 0 ) true else false );
		hide();
	}
	
}