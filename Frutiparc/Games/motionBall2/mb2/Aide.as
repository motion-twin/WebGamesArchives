import mb2.Manager;
import mb2.Const;

class mb2.Aide {

	var screen;

	function Aide( mc : MovieClip ) {
		var me = this;
		screen = Std.attachMC(mc,"panGameOver",0);
		screen._x = Const.LVL_WIDTH / 2;
		screen._y = Const.LVL_HEIGHT / 2;
		screen.gotoAndStop("aide");
		screen.onPress = function() { 
			me.click();
			delete(me.screen.onPress);
		};	
	}

	function click() {
		Manager.gotoMenu();
	}

	function destroy() {
		screen.removeMovieClip();
	}

}
