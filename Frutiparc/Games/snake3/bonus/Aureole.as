
class snake3.bonus.Aureole {

	static function activate( game : snake3.Game, x, y ) {
		var i;
		var ray = 100;
		var b = game.level.bounds();
		var nfruits = 12;
		var id;
		do {
			id = game.gen_fruit_id();
		} while( id % 10 != 0 ); 
		for(i=0;i<nfruits;i++) {
			var ang = i / nfruits * Math.PI * 2;
			var fx = x + ray * Math.cos(ang);
			var fy = y + ray * Math.sin(ang);
			if( fx >= b.left + 10 && fy >= b.top + 10 && fx <= b.right - 10 && fy <= b.bottom - 10 ) {
				var f = game.gen_fruit();
				f.set_id(id);
				f.set_pos(fx,fy);
				f.on_eat = undefined;
			}
		}
	}

}