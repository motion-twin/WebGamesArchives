import mb2.Manager;

class mb2.Transition {

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
		mask = Std.createEmptyMC(mc._parent,999);
		mask_size = 350;
		mask._x = 610 / 2;
		mask._y = 410 / 2;
		diag = 0.3+random(300)/100;
		mc.setMask(mask);
		main();
	}

	function main() {
		mask_size -= Std.tmod * 15;
		mask._rotation += Std.tmod * 3;
		mask.clear();
		mask.moveTo(0,-mask_size);
		mask.beginFill(0,100);
		var d = mask_size*diag;
		mask.curveTo(d,-d,mask_size,0);
		mask.curveTo(d,d,0,mask_size);
		mask.curveTo(-d,d,-mask_size,0);
		mask.curveTo(-d,-d,0,-mask_size);
		mask.endFill();
		mode.main();

		if( !reversed && mask_size < 0 ) {
			reversed = true;
			mode.destroy();
			mode = Manager.nextMode();
		}
		if( mask_size < -400 ) {
			var m = mode;
			mode = null;
			Manager.switchMode(m);
		}
	}

	function destroy() {
		mode.destroy();
		mc.setMask(null);
		mask.removeMovieClip();
	}

}