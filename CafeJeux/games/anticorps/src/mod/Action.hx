package mod;
import Common;



class Action extends Mode{//}

	var flMenu:Bool;
	public var flCancel:Bool;

	public function new(?cosmo) {
		super(cosmo);
		flCancel = true;
	}

	// UPDATE
	override function update(){

		var xm = cosmo.root._xmouse;
		var ym = cosmo.root._ymouse;
		var dist = Math.sqrt(xm*xm+ym*ym);
		if( !flMenu && dist < 20 && flCancel){
			flMenu = true;
			remove();
			cosmo.initMenu();


		}
		if( flMenu && dist > 60 ){
			cosmo.flAutoTurnHead = true;
			flMenu = false;
			cosmo.removeMenu();
			init();
		}

		if( flMenu ){
			var mp = getMousePos();
			cosmo.aimAt( Math.atan2(mp.y,mp.x) );

		}

		super.update();
	}




//{
}











