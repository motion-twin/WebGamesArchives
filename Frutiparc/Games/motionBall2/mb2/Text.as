import mb2.Manager;
import mb2.Const;

class mb2.Text {

	var screen;

	function Text( mc : MovieClip, txt ) {
		var me = this;
		screen = Std.attachMC(mc,"panGameOver",0);
		screen._x = Const.LVL_WIDTH / 2;
		screen._y = Const.LVL_HEIGHT / 2;
		screen.gotoAndStop("texte");
		screen.mainField.text = txt;
		screen.mainField._y = 30 - screen.mainField.textHeight / 2;
	}

	function destroy() {
		screen.removeMovieClip();
	}

}