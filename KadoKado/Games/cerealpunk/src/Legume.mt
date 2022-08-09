class Legume {//}

	var game : Game;
	var id : int;
	var moved : bool;
	var blast : bool;
	var mc : {> MovieClip, sub : MovieClip };
	var pop : MovieClip;
	var frame : float;
	var timer:float;
	var life : int;
	var gold : bool;

	function new( g, id, x, y ) {
		game = g;
		this.id = id;
		mc = downcast(game.dmanager.attach("legume",Const.PLAN_LEGUME));
		mc._x = x * 30 + Const.DX;
		mc._y = y * 30 + Const.DY;
		mc.gotoAndStop(string(id+1));
		mc.sub.stop();
		life = Const.PIERRE_LIFE;
		gold = (id >= Const.GOLD && id < Const.GOLD + 6);
		if( gold )
			this.id -= Const.GOLD;
	}

	function initExplode() {
		switch(id){
			case Const.BULLE:
				timer = 0
				for( var i=0; i<8; i++ ){
					var p = game.animator.newPart("partBubble")
					//Log.trace(p)
					var a = Math.random()*6.28
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var ray = 16
					var sp = 0.5+Math.random()*0.5
					p._x = mc._x + ca*ray
					p._y = mc._y + sa*ray
					p.vx = ca*sp
					p.vy = sa*sp
					p.frict = 0.96
					p.timer = 10+Math.random()*10
				}
				mc.removeMovieClip();
				break;

			case Const.BONUS1:
			case Const.BONUS2:
				var link = "partBonus2"
				if(id==Const.BONUS1)link="partBonus"
				for(var i=0; i<24; i++ ){
					var p = game.animator.newPart(link)
					var a = Math.random()*6.28
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var ray = Math.random()*20
					var sp = 1+Math.random()*5
					p._x = mc._x + ca*ray
					p._y = mc._y + sa*ray
					p.vx = ca*sp
					p.vy = -Math.abs(sa*sp)
					p.vr = (Math.random()*2-1)*20
					p.fvr = 0.98
					p.frict = 0.97
					p.weight = 0.05+Math.random()*0.2
					p.timer = 10+Math.random()*35
					p.scale = 50+Math.random()*60
					p._xscale = p.scale
					p._yscale = p.scale
					p.gotoAndPlay(string(Std.random(p._totalframes)+1))
				}
				mc.removeMovieClip();

				break;
			default:
				for( var i=0; i<8; i++ ){
					var p = game.animator.newPart("partRay")
					p._x = mc._x
					p._y = mc._y
					p._rotation = Math.random()*360
					p._xscale = 30 + Math.random()*60
					p.scale = 150 + Math.random()*350
					p._yscale = p.scale
					p.vr = 0.5+Math.random()*4
					p.fvr = 0.9+Math.random()*0.1
					p.timer = 10+Math.random()*10
					p.ft = 0
					p.gotoAndStop(string(Std.random(p._totalframes)+1))
				}
				timer = 0
				var pc = game.animator.newPart("partCircle")
				pc._x = mc._x
				pc._y = mc._y
				break;
		}

	}

	function initDestroy(){
		switch(id){

			case Const.BONUS1:
			case Const.BONUS2:

				for( var i=0; i<8; i++ ){
					var p = game.animator.newPart("partBonusDie")
					var a = Math.random()*6.28
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var ray = 8
					var sp = 1+Math.random()*3
					p._x = mc._x + ca*ray
					p._y = mc._y + sa*ray
					p.vx = ca*sp
					p.vy = sa*sp
					p.frict = 0.96
					p.timer = 10+Math.random()*10
					p.scale = 50+Math.random()*80
					p._xscale = p.scale;
					p._yscale = p.scale;
					var frame = 1
					if(Math.random()<0.5){
						frame = 2;
						if(id==Const.BONUS1)frame=3;
					}
					p.gotoAndStop(string(frame))
				}

				var pc = game.animator.newPart("partCircle2")
				pc._x = mc._x
				pc._y = mc._y
				var sc = 150
				pc._xscale = sc
				pc._yscale = sc

				mc.removeMovieClip();
				break;
			default:
				for( var i=0; i<8; i++ ){
					var p = game.animator.newPart("partPiece")
					var a = Math.random()*6.28
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var ray = 6+Math.random()*10
					var sp = 0.5+Math.random()*3
					p._x = mc._x + ca*ray
					p._y = mc._y + sa*ray
					//p._rotation = a/0.0174
					p.vx = ca*sp
					p.vy = sa*sp
					p.frict = 0.96
					p.timer = 10+Math.random()*10
					//p.ft = 1
				}

				var pc = game.animator.newPart("partCircle2")
				pc._x = mc._x
				pc._y = mc._y
				mc.removeMovieClip();
				break;
		}
	}

	function explodeMain() {
		switch(id){
		case Const.BULLE:
			return false;
		default:
			timer += Timer.tmod;
			Const.setPercentColor(mc,Math.min(timer*25,100),0xFFFFFF)
			var lim = 10
			if(timer>lim){
				mc._xscale -= (timer-lim)*Timer.tmod;
				mc._yscale = mc._xscale
				timer += 2*Timer.tmod;
			}

			if(mc._xscale <= 0 ){
				mc.removeMovieClip();
				return false;
			}
			break;
		}
		return true;
	}

	function stoneParts() {
		life--;

		for( var i=0; i<8; i++ ){
			var p = game.animator.newPart("partStone")
			var a = Math.random()*6.28;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var ray = 10 + Math.random()*5;
			//var sp = 1+Math.random()*0.5;
			p._x = mc._x + ca*ray;
			p._y = mc._y + sa*ray;
			p.vx = 0
			p.vy = 0
			p.frict = 0.96;
			p.weight = 0.2+Math.random()*0.5
			p.timer = 10+Math.random()*10;
		}

		mc.sub.gotoAndStop(string(Const.PIERRE_LIFE+1-life));
		if( life == 0 ) {
			if( Std.random(2) == 0 ) {
				mc.removeMovieClip();
				return false;
			}
			id = Const.BONUS1+(Std.random(20) == 0)?1:0;
			mc.gotoAndStop(string(id+1));
		}
		return true;
	}

//{
}
