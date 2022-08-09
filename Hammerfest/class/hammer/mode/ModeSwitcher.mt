class mode.ModeSwitcher extends Mode
{
	var prev : Mode;
	var next : Mode;

	var prevMask : MovieClip;
	var nextMask : MovieClip;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m) {
		super(m);
		_name = "$switcher";
	}


	/*------------------------------------------------------------------------
	ATTACH: MASQUE DE TRANSITION
	------------------------------------------------------------------------*/
	function attachMask(link,mode:Mode) {
		var mask = mode.depthMan.attach(link,Data.DP_INTERF);
		mask._x -= mode.xOffset;
		mode.mc.setMask(mask);
		return mask;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initSwitcher(p:Mode,n:Mode) {
		prev = p;
		next = n;
		next.fl_switch = true;
		prev.fl_switch = true;
		prevMask = attachMask("modeMaskOut",prev);
		nextMask = attachMask("modeMaskIn",next);
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		prev.mc.setMask(null);
		prevMask.removeMovieClip();
		next.mc.setMask(null);
		nextMask.removeMovieClip();

		prev.destroy();
		next.fl_switch = false;
		manager.current = next;

		super.destroy();
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function main() {
		super.main();

		prev.main();
		next.main();

		// Fin
		if ( prevMask._currentframe==prevMask._totalframes ) {
			destroy();
		}
	}
}

