
class snake3.bonus.Coffre {

	static function activate( game : snake3.Game, x, y ) {
		var i;
		var nfruits = 10 + random(10);
		for(i=0;i<nfruits;i++) {
			var f : snake3.Fruit = game.gen_fruit();
			f.set_pos(x,y);
			f.on_eat = undefined;
			f.jump_near(random(50)+50,random(10)+20,0.05,game.level.bounds());
		}

	}

}