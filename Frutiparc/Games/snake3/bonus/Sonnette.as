import snake3.Const;
import snake3.Manager;

class snake3.bonus.Sonnette extends snake3.bonus.Slot {

	public static var activated = false;

	var s_mc;

	function Sonnette( game ) {
		super(game,45);
		s_mc = game.dmanager.attach("sonnette",Const.PLAN_DUMMIES);
		update();
		activated = true;
	}

	function close() {
		s_mc.removeMovieClip();
		super.close();
	}

	function permanent() {

		if( game.snake.len <= 1 ) {
			game.remove_unique_slot(this);
			return;
		}

		if( !activated )
			return;

		var delta = 2;
		var p1 = Std.cast(game.snake.end_queue_pos(0));
		var p2;
		
		do {
			p2 = Std.cast(game.snake.end_queue_pos(delta++))
		} while( p1 == p2 && delta < 100 );

		var ang = Math.atan2(p1.y - p2.y,p1.x - p2.x);
				
		s_mc._x = p1.x;
		s_mc._y = p1.y;
		s_mc._rotation = ang * 180 / Math.PI;

		if( s_mc._currentframe == 1 && Key.isDown(Key.SPACE) ) {
			Std.setVar(s_mc,"angle",25);
			s_mc.play();
			Manager.smanager.play(Const.SOUND_SONNETTE);
		}

		var f = game.level.get_fruit(s_mc);
		if( f != null ) { 
			game.eat_fruit(f);
			Manager.smanager.stopSound(Const.SOUND_FRUIT_EAT_1,Const.CHANNEL_SOUNDS);
			Manager.smanager.stopSound(Const.SOUND_FRUIT_EAT_2,Const.CHANNEL_SOUNDS);
			game.snake.eat = -1;
		}
	}

}
