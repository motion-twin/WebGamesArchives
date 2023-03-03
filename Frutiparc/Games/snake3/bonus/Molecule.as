class snake3.bonus.Molecule {

	public static function activate( game : snake3.Game, big ) {
		if( big )
			game.fbarre += 20;
		else
			game.fbarre += 5;
	}

}
