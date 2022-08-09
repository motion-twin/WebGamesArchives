class Level {

	var game : Game;
	var bonus_time : float;
	var bonus_inhib : float;
	var bonuses : Array<Bonus>;
	var fruits : Array<Fruit>;
	volatile var fl : int;

	function new(g) {
		game = g;
		bonus_time = 0;
		bonus_inhib = 0;
		fruits = new Array();
		bonuses = new Array();
		fl = 0;
	}

	function generateFruit() {
		var base = int(game.fbarre/3);
		var ampl = Math.round(game.fbarre * (Const.FRUITS_MAX - base + 1) /Const.FBARRE_MAX);
		var id = base + Std.random(ampl);
		var mc = game.dmanager.attach("fruit",Const.PLAN_FRUITS);
		mc._xscale = 75;
		mc._yscale = 75;
		downcast(mc).f.gotoAndStop(string(id+1));
		var f = new Fruit(id,mc,game.dmanager);
		fruits.push(f);
		fl++;
		return f;
	}

	function generateBonus() {
		var id;
		do {
			id = Tools.randomProbas(Const.BONUS_PROBAS);
		} while( game.jackpot.encyclo.length < 5 && id == 7 ); // pas de jackpot
		var mc = game.dmanager.attach("bonus",Const.PLAN_FRUITS);
		mc._xscale = 75;
		mc._yscale = 75;
		downcast(mc).f.gotoAndStop(string(id+1));
		bonuses.push(new Bonus(id,mc));
	}

	function main() {
		var tmod = Timer.tmod;
		if( !game.game_over_flag ) {
			if( Std.random(Math.round(Const.FRUITS_FREQ*fruits.length/tmod)) == 0 )
				generateFruit();
			if( bonus_inhib > 0 ) {
				bonus_inhib -= Timer.deltaT;
				bonus_time = 0;
			} else if( Std.random(Math.round((Const.BONUS_FREQ+KKApi.val(KKApi.getScore())/10000)*(bonuses.length+1)/tmod - bonus_time/6)) == 0 ) {
				bonus_time = 0;
				generateBonus();
			} else
				bonus_time += tmod;
		}

		var i;
		var c = game.snake.collide_mc;
		for(i=0;i<fruits.length;i++) {
			var f = fruits[i];
			if( !f.update() ) {
				bonus_inhib += 6;
				game.fbarre += Const.FBARRE_FRUIT_TIMEOUT;
				if( game.fbarre < 0 )
					game.fbarre = 0;
				fruits.remove(f);
				fl--;
				i--;
			} else if( !game.game_over_flag && Std.hitTest(c,f.mc) && game.eatFruit(f) ) {
				fruits.remove(f);
				fl--;
				i--;
			}
		}

		for(i=0;i<bonuses.length;i++) {
			var b = bonuses[i];
			if( !b.update() ) {
				bonuses.remove(b);
				i--;
			} else if( !game.game_over_flag && Std.hitTest(c,b.mc) ) {
				b.activate(game);
				bonuses.remove(b);
				i--;
			}
		}
	}
}