class Teddy {

	var mc : MovieClip;
	var mc2 : MovieClip;
	var timer : float;

	function new(dman) {
		mc = dman.attach("teddy",1);
		mc2 = dman.attach("teddy",1);
		mc.gotoAndStop("1");
		mc2.gotoAndStop("2");
		mc._x = 20;
		mc._y = 230;
		mc2._x = mc._x;
		mc2._y = mc._y;
		mc2._visible = false;
		timer = 0;
	}

	function main() {
		if( timer > 0 ) {
			timer -= Timer.deltaT;
			if( timer <= 0 ) {
				mc._visible = true;
				mc2._visible = false;
			}
		}
	}

	function hit(x,y,g) {
		timer = 0.3;
		mc._visible = false;
		mc2._visible = true;
	}

}