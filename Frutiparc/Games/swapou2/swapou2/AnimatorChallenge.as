import swapou2.Data ;
import swapou2.Sounds ;
import swapou2.TItem ;

class swapou2.AnimatorChallenge extends swapou2.Animator {

	var comboStar ;
	var comboName ;
	var comboId ;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function AnimatorChallenge(pl : swapou2.IPlayer, pos_x, pos_y) {
		super(pl,pos_x,pos_y) ;
	}



	/*------------------------------------------------------------------------
	AFFICHE L'INDICATEUR DE COMBO
	------------------------------------------------------------------------*/
	function attachComboStar() {
		comboStar = Std.cast(depthMan.attach("comboStar",Data.DP_INTERF));
		comboStar._x = Data.COMBOSTAR_X ;
		comboStar._y = Data.COMBOSTAR_Y ;
		comboStar._xscale = Data.COMBOSTAR_SCALE ;
		comboStar._yscale = comboStar._xscale ;
		comboStar.sub.gotoAndStop(2) ;
		comboStar.sub.txtField.text = comboId ;
		comboStar.animCpt=0 ;
	}


	/*------------------------------------------------------------------------
	ÉCHANGE
	------------------------------------------------------------------------*/
	function swap(f1,f2) {
		super.swap(f1,f2) ;

		// Indicateur de combo
		comboId = 0 ;
		if ( comboStar._name != undefined )
			comboStar.removeMovieClip() ;
	}


	/*------------------------------------------------------------------------
	RÉCEPTION D'UNE LISTE DE FRUITS À DÉTRUIRE
	------------------------------------------------------------------------*/
	function explode(mcs,pete_armures,score) {
		super.explode(mcs,pete_armures,score) ;

		comboId ++ ;

		// Indicateur de combo
		if ( comboStar._name == undefined )
			attachComboStar() ;
		else {
			comboStar.gotoAndPlay("flash") ;
			comboStar.sub.txtField.text = comboId ;
		}
	}


	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function main() {
		super.main() ;
		// Anim de la ComboStar
		if ( comboStar.distort ) {
			comboStar.animCpt += Std.tmod * 0.4 ;
			comboStar._xscale = 100 + Math.cos(comboStar.animCpt) * 5 ;
			comboStar._yscale = 100 + Math.sin(comboStar.animCpt) * 5 ;
		}

	}


	/*------------------------------------------------------------------------
	AFFICHAGE DES POINTS D'UNE EXPLOSION
	------------------------------------------------------------------------*/
	function comboScore( score, nbCombos ) {
		super.comboScore(score,nbCombos) ;

		// Score flottant
		var mc ;
		mc = Std.cast(particules.attachFx("scorePop", explosions.x, explosions.y, Data.DP_FXTOP));
		mc.sub.txtField.text = score ;
		if ( score >= 1000 )
			mc.sub.gotoAndStop(2) ;
		else
			mc.sub.gotoAndStop(1) ;
		if ( Data.lod == Data.HIGH )
			mc.managers.push(particules.sinManager) ;

		// Nom de combo
		if ( nbCombos > 0 ) {
			var scale ;
			scale = (nbCombos/Data.COMBOS[Data.COMBOS.length-2]) * (100-Data.COMBOSTAR_SCALE) ;
			comboStar._xscale = Math.min( 100, Data.COMBOSTAR_SCALE + scale ) ;
			comboStar._yscale = comboStar._xscale ;
			comboStar.gotoAndPlay("flash") ;
			comboStar.sub.txtField.text = nbCombos ;
		}
	}



	/*------------------------------------------------------------------------
	AFFICHAGE DES POINTS TOTAUX D'UNE SÉRIE DE COMBOS
	------------------------------------------------------------------------*/
	function finalComboScore(score, nbCombos ) {
		super.finalComboScore(score,nbCombos) ;

		if( score > 0 ) {

			Sounds.play(Sounds.SHOW_SCORE);

			comboStar._xscale = 100 ;
			comboStar._yscale = comboStar._xscale ;
			comboStar.gotoAndPlay("flash") ;
			comboStar.sub.gotoAndStop(1) ;
			comboStar.sub.txtField.text = score ;
			comboStar.distort = true ;
			comboStar.done = true ;
			if ( score < Data.MIN_SUPER_COMBO )
				comboStar.sub.flying._visible = false ;

			var i = 0;

			if( Data.gameMode == Data.CLASSIC ) {
				while( nbCombos >= Data.COMBOS_CLASSIC[i] && i < Data.COMBOS_CLASSIC.length )
					i++;
			} else {
				while( nbCombos >= Data.COMBOS[i] && i < Data.COMBOS.length )
					i++;
				if( i > 0 )
					TItem.addCombo(i-1);
			}
			if( i > 0 ) {
				comboName = Std.cast( depthMan.attach("comboName", Data.DP_LAST) ) ;
				comboName._x = Data.COMBO_X + Data.CHALLENGE_X ;
				comboName._y = Data.COMBO_Y ;
				if( Data.gameMode == Data.CLASSIC )
				  comboName.sub.gotoAndStop(i+30) ;
				else
				  comboName.sub.gotoAndStop(i) ;
			}
		}
	}



	/*------------------------------------------------------------------------
	DESTRUCTEUR
	------------------------------------------------------------------------*/
	function destroy() {
		super.destroy() ;
		comboStar.removeMovieClip() ;
		comboName.removeMovieClip() ;
	}

}