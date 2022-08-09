import mb2.Const;

class mb2.Options {

	var game : mb2.Game;

	var	cur_ball;
	var ball_types;
	var ball_flags;
	var ball_types_chk;

	var icons, grelots;
	var has_map, has_radar;
	var grelot_count;

	function Options( game : mb2.Game, nballs ) {
		this.game = game;

		ball_types = new Array();
		ball_flags = new Array();
		var i;
		for(i=0;i<7;i++)
			ball_types[i] = 0;
		ball_types[0] = nballs;
		ball_types_chk = nballs;
		cur_ball = 0;

		icons = new Array();
		grelots = new Array();

		has_map = false;
		has_radar = false;

		grelot_count = 0;
	}

	function update_icons() {

		if( mb2.Manager.play_mode == Const.MODE_CLASSIC )
			return;

		var i,n;
		var x = 585;
		var bsum = 0;
		clean_icons();
		for(i=6;i>=0;i--) {
			bsum += ball_types[i];
			for(n=0;n<ball_types[i];n++) {
				var ico = game.dmanager.attach("ball icon",Const.ICON_PLAN);
				icons.push(ico);
				ico._x = x;
				ico._y = 390;
				ico.ball.gotoAndStop(i+1);
				if( game.ball.btype == i && n == ball_types[i]-1 )
					ico.gotoAndStop("on");
				else
					ico.gotoAndStop("select");
				x -= 25;
			}
		}

		if( bsum != ball_types_chk )
			mb2.Manager.error();
		
		if( grelots.length < grelot_count ) {
			var xx = 575 - 25*grelots.length;
			while( grelots.length < grelot_count ) {
				var ico = game.dmanager.attach("icon grelot",Const.ICON_PLAN);
				grelots.push(ico);
				ico._x = xx;
				ico._y = 355;
				xx -= 25;
			}
		} else while( grelots.length > grelot_count ) {
			var g = grelots[grelots.length-1];
			g.gotoAndPlay("hit");
			grelots.remove(g);
		}
	}

	function clean_icons() {
		var i;
		for(i=0;i<icons.length;i++)
			icons[i].removeMovieClip();
		// DOES NOT CLEAN GRELOTS
	}

}
