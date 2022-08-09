/*------------------------------------------------------------------------
Entité se déplacant en rotation autour du fruit du menu
------------------------------------------------------------------------*/

import swapou2.Data ;
import swapou2.Sounds ;

class swapou2.Rotator extends MovieClip {

	var menu : swapou2.Menu ;
	var stable ;
	var active, locked ;
	var wait ;
	var phase ;

	var x,y ;
	var cpt ;
	var top ;
	var back ;
	var delay ;
	public var xMove ;
	public var speed ;

	var isOver ;

	var help ;

	public var kill ;


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initRotator( menu:swapou2.Menu, x,y, delay, help ) {
		this.menu = menu ;

		this.x = x ;
		this.y = y ;
		this.help = help ;

		top = getDepth() ;
		back = menu.depthMan.reserve(this,Data.DP_BG) ;
		swapDepths(back) ;

		cpt = Math.PI ;
		phase = Data.BUTTON_SHOW ;
		stable = false ;
		kill = false ;
		isOver = false ;
		enable() ;

		this.delay = delay ;
		wait = 10 + delay * Data.BUTTON_DELAY ;
		_visible = false ;

		xMove = Data.BUTTON_XMOVE ;
		speed = Data.BUTTON_SPEED ;

		onRelease = release ;
		onRollOver = over ;
		onRollOut = out ;
		this.stop() ;
	}


	/*------------------------------------------------------------------------
	FAIT DISPARAÎTRE LE ROTATOR
	------------------------------------------------------------------------*/
	function hide() {
		onRelease = undefined ;
		useHandCursor = false ;
		isOver = false ;
		if ( stable ) {
			wait = delay * 5 ;
			stable = false ;
		}
		phase = Data.BUTTON_HIDE ;
	}


	/*------------------------------------------------------------------------
	EVENT: CLIC
	------------------------------------------------------------------------*/
	function release() {
	  if (!active) return ;
	  Sounds.play(Sounds.MENU_CLICK);
	}


	/*------------------------------------------------------------------------
	EVENT: ROLL OVER
	------------------------------------------------------------------------*/
	function over() {
		isOver = true ;
		if ( stable ) {
			Sounds.play(Sounds.MENU_ACTIVATE);
			menu.help(help) ;
		}
	}


	/*------------------------------------------------------------------------
	EVENT: ROLL OUT
	------------------------------------------------------------------------*/
	function out() {
		isOver = false ;
		menu.hideHelp() ;
	}


  /*------------------------------------------------------------------------
  ACTIVE / DÉSACTIVE LE ROTATOR
  ------------------------------------------------------------------------*/
	function enable() {
	  active = true ;
	  this._alpha = 100 ;
	}
	function disable() {
	  active = false ;
	  this._alpha = 50 ;
	}
	function lock() {
	  locked = true ;
  }
  function unlock() {
    locked = false ;
  }


	/*------------------------------------------------------------------------
	UPDATE GRAPHIQUE
	------------------------------------------------------------------------*/
	function update() {
		_x = x ;
		_y = y ;
		_x = Math.sin(cpt) * xMove + x ;
		_y = Math.cos(cpt) * 20 + y ;
		_xscale = Math.cos(cpt) * 30 + 70 ;
		_yscale = _xscale ;
//		if ( Data.lod>=Data.HIGH )
//			_alpha = Math.cos(cpt) * 50 + 100 ;
	}



	/*------------------------------------------------------------------------
	BOUCLE MAIN
	------------------------------------------------------------------------*/
	function move() {

		if ( wait>0 ) {
			wait -= Std.tmod ;
			if ( wait <= 0 ) {
				wait = 0 ;
				_visible = true ;
			}
		}
		if ( !stable && wait==0 ) {

			switch (phase) {
			case Data.BUTTON_SHOW :
				cpt += speed * Std.tmod ;
				if ( cpt>= Math.PI*2.03 )
					phase = Data.BUTTON_BUMP ;
				break ;
			case Data.BUTTON_BUMP :
				cpt -= speed*0.3 * Std.tmod ;
				if ( cpt<=Math.PI*2 ) {
					cpt = Math.PI*2 ;
					stable = true ;
				}
				break ;
			case Data.BUTTON_HIDE :
				cpt += speed * Std.tmod ;
				if ( cpt>=Math.PI*3 ) {
					stable = true ;
					kill = true ;
				}
				break ;
			}

			// Gestion de la depth
			if ( getDepth()==back )
				if ( cpt>=Math.PI*1.5 )
					swapDepths(top) ;
			if ( getDepth()==top )
				if ( cpt>=Math.PI*2.5 )
					swapDepths(back) ;
		}
	}

}