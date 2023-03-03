import snake3.Manager;

class snake3.Transition {

	var mc;
	var mask;
	var mask_size;
	var diag;
	public var mode;
	public var reversed;

	function Transition( mc , mode ) {
		this.mc = mc;
		this.mode = mode;
		reversed = false;
		mask = Std.attachMC(mc._parent,"snakeMask",999);
		mask_size = 400;
		mask._x = 700 / 2;
		mask._y = 480 / 2;
		mc.setMask(mask);
		main();
	}

	function main() {
		mask_size -= Std.tmod * 15;
		mask._xscale = Math.abs(mask_size);
		mask._yscale = Math.abs(mask_size);
		mode.main();

		if( !reversed && mask_size < 0 ) {
			reversed = true;
		
			mode.close();
			mode = Manager.nextMode();
		}
		if( mask_size < -400 ) {
			var m = mode;
			mode = null;
			Manager.switchMode(m);
		}
	}

	function close() {
		mode.close();
		mc.setMask(null);
		mask.removeMovieClip();
	}

}