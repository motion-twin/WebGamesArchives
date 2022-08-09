import swapou2.Data ;

class swapou2.InterfChallenge extends swapou2.Interf {

	// Movies
	var defenseIcon : swapou2.SimpleButton ;
	var leaves ;

	// Données
	var score, viewScore ;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function InterfChallenge( game:swapou2.Challenge, depth_m : asml.DepthManager ) {
		super(game,depth_m,1) ;


    // Hack mode classic
		if ( Data.gameMode==Data.CLASSIC ) {
		  bg.gotoAndStop("2");
		  leftPanel.sub.gotoAndStop("3");
		  rightPanel.sub.gotoAndStop("3");
		}
		else {
  		leaves = depthMan.attach("leaves",Data.DP_INTERFTOP) ;
  		glue( Std.cast(leftPanel.sub), Std.cast(leaves), Data.LEAVES_X, Data.LEAVES_Y) ;
  	}

		pl[0] = new swapou2.InterfPlayerData ;
		pl[0].powerX = Data.POWER_X ;
		pl[0].powerY = Data.POWER_Y ;

		attachFace(0, Data.FACE_X, Data.FACE_Y, 1.0, leftPanel.sub) ;

		defenseIcon = Std.cast( depthMan.attach("swapou2_simpleButton",Data.DP_INTERFTOP) ) ;
		defenseIcon.attach( Std.cast(this), "powerIcon", 0,0, Std.cast(defend) ) ;
		defenseIcon.skin.sub.gotoAndStop(2) ;
		glue( Std.cast(leftPanel.sub), Std.cast(defenseIcon), Data.ATTDEF_ICON_X, Data.POWER_Y-(Data.DEFENSE_STARS[Data.players[0]]-1)*Data.POWER_HEIGHT) ;

		starScale = 0 ;
		powerFx = new Array() ;
		updatePower(0) ;
		score = 0 ;
		viewScore = 0 ;

		updateScore(score) ;
	}



	/*------------------------------------------------------------------------
	BOUCLE MAIN
	------------------------------------------------------------------------*/
	function main() {
		super.main() ;

		defenseIcon.update() ;


		// Anim du score
		if ( viewScore < score ) {
			if ( score-viewScore >= 1000 )
				viewScore += Math.round( Data.SCORE_SPEED * 2 * Std.tmod ) ;
			else
				viewScore += Math.round( Data.SCORE_SPEED * Std.tmod ) ;
			if ( viewScore >= score )
				viewScore = score ;
			leftPanel.sub.scoreTxt.text = string(viewScore) ;
		}

		particules.main() ;
	}


	/*------------------------------------------------------------------------
	ACTUALISE LE SCORE
	------------------------------------------------------------------------*/
	function updateScore(score) {
		this.score = score ;
		leftPanel.sub.scoreTxt.text = string(viewScore) ;
	}


	/*------------------------------------------------------------------------
	PLAY GAME OVER SEQUENCE
	------------------------------------------------------------------------*/
	function gameOver(is_player) {
		super.gameOver(is_player) ;
	}


	/*------------------------------------------------------------------------
	DÉFINI L'ÉTAT DU LOCK
	------------------------------------------------------------------------*/
	function setLock(flag) {
		super.setLock(flag) ;

		if ( lock ) {
			defenseIcon.disable() ;
		}
		else {
			defenseIcon.enable() ;
		}
	}

	function classicMode() {
		leftPanel.sub.gotoAndStop(3);
		defenseIcon._visible = false;
		pl[0].face._visible = false;
	}
}
