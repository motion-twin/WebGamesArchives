class snake3.Popup extends asml.NumberMC {

	var game : snake3.Game;
	var max_size, xspeed, yspeed, xphase, yphase, xtime, ytime, ptime, pphase;

	function update() {
		if( pphase ) {
			ptime -= Std.deltaT;
			if( ptime < 0 ) {
				xphase = true;
				yphase = true;
				pphase = false;
			} else
				return;
		}
	
		if( xphase )
			xtime += Std.deltaT * xspeed;
		if( yphase )
			ytime += Std.deltaT * yspeed;
			
		_xscale = xtime * max_size;
		_yscale = ytime * max_size;

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
			game.updates.remove(this,update);
			this.removeMovieClip();
		}
	}

	function initPopup(g,x,y,n) {
		game = g;
		super.init((n<0)?"policePointYellow":"policePointRed");

		alignCenter();
		alignVerticalCenter();
		setVal(Math.abs(n));

		if( n < 0 ) {
			var beurk = Std.attachMC(this,"beurk",100);
			beurk._x = mcs[0]._x + mcs[0]._width + 5;
			beurk._y = mcs[0]._y;

			beurk = Std.attachMC(this,"beurk",101);
			beurk._x = mcs[mcs.length-1]._x - 38;
			beurk._y = mcs[0]._y;
		}

		_x = x;
		_y = y;
		_xscale = 0;
		_yscale = 0;

		xtime = 0;
		ytime = 0;
		ptime = 1;
		max_size = 50 + Math.abs(n) / 100;
		if( max_size > 200 )
			max_size = 200;
		xspeed = (1 + random(10)/10) / 0.4;
		yspeed = (1 + random(10)/10) / 0.4;
		xphase = true;
		yphase = true;
		pphase = false;
		game.updates.push(this,update);
	}

}
