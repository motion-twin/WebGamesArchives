class Animator {//}

	var game : Game;
	var ups : Array<{ l : Legume, dy : float }>;
	var gets : Array<Legume>;
	var puts : Array<{ l : Legume, dy : float, delta : float }>;
	var pList : Array<{ >MovieClip, vx:float, vy:float, vr:float, weight:float, frict:float, timer:float, scale:float, ft:int, fvr:float }>;
	var explodes : Array<Legume>;
	var amort : Array<{ l : Legume, y : float }>;
	var amort_max : float;
	var amort_y : float;
	var amort_x : int;

	function new(g) {
		game = g;
		ups = new Array();
		gets = new Array();
		puts = new Array();
		pList = new Array();
		amort = new Array();
		explodes = new Array();
	}

	function moveUp(l) {
		if( l == null )
			return;
		var i;
		for(i=0;i<ups.length;i++)
			if( ups[i].l == l ) {
				ups[i].dy += 30;
				return;
			}
		ups.push({
			l : l,
			dy : 30
		})
	}

	function getLegume(l) {
		gets.push(l);
	}

	function putLegume(l,x,y,i) {
		l.mc._x = x * 30 + Const.DX;
		l.mc._y = Const.YLIMIT - i * 30;
		l.mc._visible = true;
		var ty = y * 30 + Const.DY;
		amort_x = x;
		puts.push({ l : l, dy : ty - l.mc._y, delta : 30 });
	}
	
	function gravity(l) {
		puts.push({ l : l, dy : 30, delta : 15 }); 
	}
	
	function explodeLegume(l) {
		l.initExplode();
		explodes.push(l);
	}
	
	function destroyLegume(l) {
		if( l == null )
			return;
		l.initDestroy();
		explodes.push(l);
	}
	
	function locked(expl) {
		return ups.length != 0 || gets.length != 0 || puts.length != 0 || amort.length != 0 || (expl && explodes.length != 0);
	}

	function newPart(link){
		var mc = downcast(game.dmanager.attach(link,Const.PLAN_POP));
		mc.vx = 0
		mc.vy = 0
		pList.push(mc)
		return mc;
	}
	
	function main() {
		var i;
		var flag = puts.length != 0 || amort.length != 0 || explodes.length != 0;

		for(i=0;i<explodes.length;i++) {
			var l = explodes[i];
			if( !l.explodeMain() )
				explodes.splice(i--,1);
		}

		var udelta = 10 * Timer.tmod;
		for(i=0;i<ups.length;i++) {
			var m = ups[i];
			m.dy -= udelta;
			m.l.mc._y -= udelta;
			if( m.dy < 0 ) {
				m.l.mc._y -= m.dy;
				ups.splice(i--,1);
			}
		}

		var doput = puts.length != 0;
		for(i=0;i<puts.length;i++) {
			var m = puts[i];
			var pdelta = m.delta * Timer.tmod;
			var k = (m.dy > 0)?1:-1;
			m.dy -= pdelta * k;
			m.l.mc._y += pdelta * k;
			if( m.dy * k < 0 ) {
				m.l.mc._y += m.dy;
				puts.splice(i--,1);
			}
		}
		if( puts.length == 0 ) {

			if( doput ) {
				for(i=0;i<Const.HEIGHT;i++) {
					var l = game.level.legumes[amort_x][i];
					if( l != null )
						amort.push({ l : l, y : l.mc._y });
				}
				amort_max = 5;
				amort_y = 0;
				amort_x = -1;
			}

			var amort_end = false;
			amort_y += Timer.tmod * amort_max;
			if( amort_y * amort_max > 0 && Math.abs(amort_y) >= Math.abs(amort_max) ) {
				amort_y = amort_max;
				amort_max *= -0.5;
				if( Math.abs(amort_max) < 1 ) {
					amort_y = 0;
					amort_end = true;
				}
			}
			for(i=0;i<amort.length;i++) {
				var m = amort[i];
				m.l.mc._y = m.y + amort_y;
			}
			if( amort_end )
				amort = new Array();
		}

		if( flag && amort.length == 0 && puts.length == 0 && explodes.length == 0 )
			game.explode();

		var gdelta = 30 * Timer.tmod;
		for(i=0;i<gets.length;i++) {
			var l = gets[i];
			l.mc._y -= gdelta;
			if( l.mc._y < Const.YLIMIT - 30 ) {
				switch( l.id ) {
				case Const.BULLE:
					explodeLegume(l);
					break;
				case Const.BONUS1:
					game.stats.$b1++;
					KKApi.addScore(Const.C1000);
					explodeLegume(l);
					break;
				case Const.BONUS2:
					game.stats.$b2++;
					KKApi.addScore(Const.C5000);
					explodeLegume(l);
					break;
				default:
					game.hero.getLegume(l);
					break;
				}
				gets.splice(i--,1);
			}
		}
		
		for(i=0;i<pList.length;i++) {
			var mc = pList[i]
			if(mc.weight!=null){
				mc.vy += mc.weight;
			}
			if(mc.frict!=null){
				mc.vx *= mc.frict;
				mc.vy *= mc.frict;
			}
			mc._x += mc.vx*Timer.tmod;
			mc._y += mc.vy*Timer.tmod;
			
			
			if(mc.vr!=null){
				if(mc.fvr!=null)mc.vr *= mc.fvr
				mc._rotation += mc.vr*Timer.tmod;
				mc._rotation += mc.vr*Timer.tmod;
			}
			
			
			if(mc.timer!=null){
				mc.timer -= Timer.tmod;
				if(mc.timer<=0){
					mc.removeMovieClip();
					pList.splice(i--,1)
				}else if(mc.timer<=10){
					var sc = mc.scale;
					if(sc==null)sc =100 
					
					switch(mc.ft){
						case 0:
							mc._yscale = sc * mc.timer/10
							break;
						case 1:
							mc._alpha = mc.timer*10
							break;						
						default:
							
							mc._xscale = sc * mc.timer/10
							mc._yscale = mc._xscale
							break;

					}
				}
			}
		}
		
		
	}
//{
}