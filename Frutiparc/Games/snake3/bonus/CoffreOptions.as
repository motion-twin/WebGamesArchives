
class snake3.bonus.CoffreOptions {

	static function activate( game : snake3.Game, x, y ) {
		var i;
		var nbonus = 3;
		for(i=0;i<nbonus;i++) {
			var b : snake3.Bonus = game.gen_bonus();
			b.set_pos(x,y);
			b.jump_near(random(50)+100,random(20)+35,0.05,game.level.bounds());
		}
	}

}