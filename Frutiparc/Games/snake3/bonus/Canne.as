
class snake3.bonus.Canne {

	static function activate( game : snake3.Game, x, y ) {	
		var f : snake3.Fruit = game.gen_fruit();
		var pts = f.points() * 10;
		function f_pts() {
			return pts;
		};
		f.gotoAndStop("standard");
		f.z = 100;
		f.scale = 3;
		f.fall(0.08);
		f.points = f_pts;
	}

}