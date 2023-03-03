import snake3.Const;

class snake3.bonus.Slot {

	var game;
	var mc;

	function Slot( game : snake3.Game, id ) {
		this.game = game;
		mc = game.dmanager.attach("slot",Const.PLAN_SLOTS);
		mc.gotoAndStop(string(id));
	}

	function update_pos(i) {
		mc._x = i * 50 + 30;
		mc._y = 30;
	}

	function close() {
		mc.removeMovieClip();
	}

	function activate(flag : Boolean) {
	}

	function update() {
	}

	function use() {
		return false;
	}

	function activable() {
		return false;
	}

}