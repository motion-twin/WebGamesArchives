class PopScore {

	var halign : bool;
	var valign : bool;

	var max_size : float;
	var xspeed : float;
	var yspeed : float;
	var xphase : bool;
	var yphase : bool;
	var pphase : bool;
	var xtime : float;
	var ytime : float;
	var ptime : float;

	var mc : MovieClip;
	var digits : Array<MovieClip>;
	var fupdate : void -> void;

	function new(x,y,n,mc) {

		mc._x = x;
		mc._y = y;
		mc._xscale = 0;
		mc._yscale = 0;

		xtime = 0;
		ytime = 0;
		ptime = 1;
		max_size = 25 + Math.abs(n) / 100;
		max_size = Math.min(Math.max( 40, max_size ), 70 )
		//if( max_size > 50 )
		//	max_size = 50;

		xspeed = 4//(1 + Std.random(10)/10) / 0.4;
		yspeed = 4//(1 + Std.random(10)/10) / 0.4;
		xphase = true;
		yphase = true;
		pphase = false;

		var me = this;
		fupdate = fun() { me.update() };
		Manager.updates.push(fupdate);

		this.mc = mc;
		halign = true;
		valign = true;
		init(n);
	}

	function init(v) {
		clear();
		var n = 0;
		var x = 0;
		var link = "scoreDigit";
		if( v == 0 ) {
			var d = Std.attachMC(mc,link,n);
			d.gotoAndStop(string(1));
			x -= -d._width;
			d._x = -x;
			digits.push(d);			
		} else {
			while( v > 0 ) {
				var d = Std.attachMC(mc,link,n++);
				d.gotoAndStop(string(1+(v%10)));
				x -= d._width;
				d._x = x;
				digits.push(d);
				v = int(v/10);
			}
		}
		if( halign ) {
			x = Math.abs(x/2);
			for(n=0;n<digits.length;n++)
				digits[n]._x += x;
			x *= max_size / 100;
			if( mc._x - x < 10 )
				mc._x = 10 + x;
			if( mc._x + x > 290 )
				mc._x = 290 - x;
		}
		if( valign ) {
			var y = digits[0]._height / 2;
			for(n=0;n<digits.length;n++)
				digits[n]._y -= y;
		}

	}

	function clear() {
		var i;
		for(i=0;i<digits.length;i++)
			digits[i].removeMovieClip();
		digits = new Array();
	}

	function update() {
		if( pphase ) {
			ptime -= Timer.deltaT;
			if( ptime < 0 ) {
				xphase = true;
				yphase = true;
				pphase = false;
			} else
				return;
		}
	
		if( xphase )
			xtime += Timer.deltaT * xspeed;
		if( yphase )
			ytime += Timer.deltaT * yspeed;
			
		mc._xscale = xtime * max_size;
		mc._yscale = ytime * max_size;

		if( ptime > 0 ) {
			if( xphase && xtime > 1 ) {
				xphase = false;
				if( !yphase )
					pphase = true;
				xspeed *= -1;
			}
			if( yphase && ytime > 1 ) {
				yphase = false;
				if( !xphase )
					pphase = true;
				yspeed *= -1;
			}
		}
		
		if( (xspeed < 0 && xtime <= 0.3) || (yspeed < 0 && ytime <= 0.3) ) {
			Manager.updates.remove(fupdate);
			mc.removeMovieClip();
		}
	}

}