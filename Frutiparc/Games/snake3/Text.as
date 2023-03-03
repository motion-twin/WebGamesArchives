import snake3.Const;

class snake3.Text {

	var screen;
	var fx;

	function Text( mc, title, txt ) {
		screen = Std.attachMC(mc,"screens",1);
		screen._x = Const.WIDTH / 2;
		screen._y = Const.HEIGHT / 2;
		setScreen(title);
		setBgColor(1);
		setText(txt);
		fx = new asml.PopupFX(screen,0,100,10,3,1.2,0.6,0.5,1);
		fx.main();
	}

	function setBgColor(id) {
		Std.getVar(screen,"pan").gotoAndStop(string(id));
	}

	function setText( txt ) {
		var t : TextField = Std.getVar(screen,"fieldText");
		t.text = txt;
		t._y = - t.textHeight / 2;
	}

	function setFruit( id ) {
		Std.getVar(screen,"mcFruit").gotoAndStop(string(id));
	}

	function setScreen( scr ) {
		screen.gotoAndStop(scr);		
	}

	function setPress( f ) {
		var s = screen;
		function f_on_press() {
			f();
			delete(s.onPress);
		};
		screen.onPress = f_on_press;
	}

	function setTitleText( txt ) {
		Std.setVar(screen,"title",txt);
	}

	function main() {
		fx.main();
	}

	function destroy() {
		screen.removeMovieClip();
	}

	function close() {
		screen.removeMovieClip();
	}
}