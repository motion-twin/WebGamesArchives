import snake3.Const;
import snake3.Manager;

class snake3.bonus.TimedSlot extends snake3.bonus.Slot {

	var time;

	function TimedSlot( game : snake3.Game, slotnb, max_time ) {
		super(game,slotnb);
		time = max_time;
	}

	function permanent() {
		time -= Std.deltaT;
		if( time < 0 ) {
			Manager.smanager.play(Const.SOUND_EFFECT_END);
			game.remove_slot(this);
			return;
		}
		effect();
	}

	function effect() {
	}


}