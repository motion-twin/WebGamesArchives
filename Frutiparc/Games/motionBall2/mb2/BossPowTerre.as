import mb2.Const;

class mb2.BossPowTerre {

	var game : mb2.Game;
	var boss : mb2.BossSerpent;

	var time;
	var px,py;
	var mc;
	var tied;
	var casse;
	var moveList;

	function BossPowTerre( g : mb2.Game, b ) {
		game = g;
		boss = b;
		init();
		update();
	}

	function init() {
		tied = false;

		mc = game.dmanager.attach("FXbourgeon",Const.BONUS_PLAN);

		px = (boss.x / Const.DELTA) - Const.BORDER_CSIZE;
		py = (boss.y / Const.DELTA) - Const.BORDER_CSIZE;
		px -= px % 10;
		py -= py % 10;
		
		mc._x = px * Const.DELTA + Const.BORDER_SIZE + 20;
		mc._y = py * Const.DELTA + Const.BORDER_SIZE + 20;

		time = 10 + random(10);

		moveList = new Array(); 
	}

	function initLiane() {
		var i;		
		var maxElement = 10;
		var prev = null;
		this.mc.gotoAndPlay("explode");
		for(i=0; i<maxElement; i++) { 			
			var mc = game.dmanager.attach("FXLiane",Const.BONUS_PLAN);
			mc.x = this.mc._x; 
			mc.y = this.mc._y; 
			mc.sx = 0; 
			mc.sy = 0; 
			mc.link = prev;
			if( i == 0 )
				mc.flFixe = true;
			prev = mc;
			moveList.push(mc);
		}
		Std.cast(game.ball).link = prev;
		moveList.push(game.ball);
	}

	function updateLiane() {

		if( casse ) {
			var i;
			for(i=0;i<moveList.length-1;i++) {
				var mc = moveList[i];
				mc._alpha -= 10 * Std.tmod;
				if( mc._alpha <= 0 ) {
					moveList.remove(mc);
					mc.removeMovieClip();
					i--;
				}
			}
			if( moveList.length == 1 ) {				
				casse = false;
				tied = false;
				time = 0;
			}
			return;
		}

		var i;
		var ropeBasicLength = 5;		

		for(i=0;i<moveList.length;i++) {
			var mc = moveList[i];
			if( mc.link != null ) {
				var dx = mc.link.x - mc.x; 
				var dy = mc.link.y - mc.y;
				var d = Math.sqrt( dx*dx + dy*dy );
				if( d > ropeBasicLength ){ 
					var c = (d/ropeBasicLength)-1; 
					dx *= c * 0.01; 
					dy *= c * 0.01;
			        
					mc.sx += dx;
					mc.sy += dy;
			      
					mc.link.sx -= dx;
					mc.link.sy -= dy;
				} 
			}

			mc.sx *= Math.pow(0.95,Std.tmod); 
			mc.sy *= Math.pow(0.95,Std.tmod);
			if( !mc.flFixe ) {
				mc.x += mc.sx * Std.tmod;
				mc.y += mc.sy * Std.tmod;
			}
			mc._x = mc.x;
			mc._y = mc.y;
		}
		for(i=0;i<moveList.length-1;i++) {
			var mc1 = moveList[i];
			var mc2 = moveList[i+1];
			var dy = mc2.y - mc1.y;
			var dx = mc2.x - mc1.x;
			var d = Math.sqrt(dx*dx+dy*dy);
			mc1._rotation = Math.atan2(dy,dx) * 180 / Math.PI;
			mc1.liane._xscale = d;
		}

		var dx = this.mc._x - game.ball.x;
		var dy = this.mc._y - game.ball.y;
		var d = Math.sqrt(dx*dx+dy*dy);		
		if( d > 225 || game.ball.hole_death )
			casse = true;
	}

	function update() {
		time -= Std.deltaT;
		if( tied ) {
			updateLiane();
		} else {			
			if( time < 0 ) {
				mc.gotoAndPlay("death");
				boss.powers.remove(this);
				return;
			}
			var d = Math.sqrt(mb2.Tools.dist2(mc,game.ball.mc));
			if( d < 30 ) {
				casse = false;
				tied = true;
				initLiane();
				updateLiane();
			}
		}
	}

	function destroy() {
		time = 0;
		casse = true;
	}

}