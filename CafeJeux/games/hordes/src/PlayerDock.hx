import Common;
import Cell;

class PlayerDock {

	public var mc : T_CellMc;
	public var mcPoints : { >flash.MovieClip, field:flash.TextField };
	public var mcNext : { >flash.MovieClip, field:flash.TextField };
	public var game : Game;
	public var team1 : Bool;
	public var points : Int;

	public function new( game : Game, team1 : Bool ) {
		points = 0;
		this.team1 = team1;
		this.game = game;

		mc = cast game.dm.attach("playerPad",Const.DP_OPTIONS);
		mc._x = Math.floor( Const.WIDTH*0.5 - mc._width*0.5 );
		mc._y = Const.WIDTH - 35;
		mc.gotoAndStop( if(team1) 1 else 2 );
		mc._visible = false;
		mc.switchAnim._visible = false;
		var me = this;
		mc.smc.onRollOver = function() { me.game.displayHelp( 103 ); };
		mc.smc.onRollOut = function() { me.game.hideHelp(); };
		mc.smc.useHandCursor = false;
		mc.smc.stop();

		mcPoints = cast game.dm.attach("mcPoints",Const.DP_OPTIONS);
		mcPoints.gotoAndStop(1);
		mcPoints._x = mc._x + mc._width*0.5 - 6;
		mcPoints._y = mc._y - 10;
		mcPoints._visible = false;

		mcNext = cast game.dm.attach("mcPoints",Const.DP_OPTIONS);
		mcNext.gotoAndStop( if(team1) 2 else 3 );
		mcNext._x = mc._x + mc._width*0.5;
		mcNext._y = mc._y + 11;
		mcNext._visible = false;
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
		mcPoints.removeMovieClip();
		mcPoints = null;
		mcNext.removeMovieClip();
		mcNext = null;
	}

	public function display() {
		mcNext._visible = true;
		mcPoints._visible = true;
		mc._visible = true;
	}

	public function setPoints(points:Int,next:Int) {
		mcPoints.field.text = "+ " + points;
		mcNext.field.text = "+ " + next;
	}

	public function hide() {
		mcNext._visible = false;
		mcPoints._visible = false;
		mc._visible = false;
	}

	public function show() {
		display();
	}

}
