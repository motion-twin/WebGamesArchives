class Hero {//}

	static var WAIT = [1];
	static var WAIT_LOCK = [1];
	static var JUMP = [8,9,10,11,12,13];
	static var END_JUMP = [14,15,16,17,18,19,20,21,22,23,24];
	static var TAKE = [27,28,29,30,31];
	static var END_TAKE = [32,33,34,35,36,37,38,39];
	static var PUT = [42,43,44];
	static var END_PUT = [45,46,47,48,49,50,51,52,53,54,55,56,57,58];

	var game : Game;
	var mc : MovieClip;
	var px : int;
	var frame : float;
	var anim : Array<int>;

	var legumes : Array<Legume>;
	var key_flag : bool;
	var down_flag : bool;

	function new(g) {
		game = g;
		mc = game.dmanager.attach("kanji",Const.PLAN_HERO);
		legumes = new Array();
		px = int((Const.WIDTH - 1)/2);
		anim = WAIT;
		frame = 0;
		mc._y = Const.YLIMIT;
		mc._x = px;
		mc._xscale = 90;
		mc._yscale = 90;
		updateHands();
	}

	function updateHands() {
		var h = downcast(mc).m.m;
		h.gotoAndStop(string(1+(legumes.length > 3)?3:legumes.length));
		var id = 1+legumes[0].id;
		h.it0.gotoAndStop((legumes[0].gold?Const.GOLD:0)+id);
		h.it1.gotoAndStop((legumes[1].gold?Const.GOLD:0)+id);
		h.it2.gotoAndStop((legumes[2].gold?Const.GOLD:0)+id);
		h.it0.sub.gotoAndStop(Const.PIERRE_LIFE+1-legumes[0].life);
		reverse(mc._xscale < 0);
	}

	function setAnim(a) {
		anim = a;
		frame = 0;
	}

	function animDone() {
		switch( anim ) {
		case JUMP:
			setAnim(END_JUMP);
			break;
		case END_JUMP:
			setAnim(WAIT);
			break;
		case PUT:
			setAnim(END_PUT);
			break;
		case END_PUT:
			setAnim(WAIT);
			break;
		case TAKE:
			setAnim(END_TAKE);
			break;
		case END_TAKE:
			setAnim(WAIT);
			break;
		}
	}

	function getLegume(l) {
		if( anim != TAKE )
			setAnim(TAKE);
		l.mc._visible = false;
		legumes.push(l);
		updateHands();
	}

	function reverse(flg) {
		mc._xscale = flg?-90:90;
		var h = downcast(mc).m.m;
		h._xscale = flg?-100:100;
	}

	function main() {
		var lock = game.animator.locked(false);
		if( anim != WAIT && anim != END_JUMP && anim != END_PUT && anim != END_TAKE )
			lock = true;

		if( anim != JUMP && anim != TAKE && game.animator.gets.length == 0 ) {
			if( Key.isDown(Key.LEFT) && px > 0 ) {
				px--;
				reverse(true);
				setAnim(JUMP);
			} else if( Key.isDown(Key.RIGHT) && px < Const.WIDTH-1 ) {
				px++;
				reverse(false);
				setAnim(JUMP);
			}
		}

		if( legumes.length > 0 && Key.isDown(Key.DOWN) )
			down_flag = true;

		if( !lock ) {
			if( Key.isDown(Key.UP) ) {
				if( !key_flag ) {
					key_flag = true;
					var id = legumes[0].id;
					var l;
					var take = false;
					while( (l = game.level.popLegume(px,id)) != null ) {
						id = l.id;
						game.animator.getLegume(l);
						if( l.id != Const.BULLE && l.id != Const.BONUS1 && l.id != Const.BONUS2 )
							take = true;
					}
					if( take )
						setAnim(WAIT_LOCK);
				}
			}
			else
				key_flag = false;
			if( down_flag ) {
				down_flag = false;
				var dy = 0;
				var i;
				for(i=0;i<legumes.length;i++) {
					var l = legumes[i];
					var y = game.level.pushLegume(px,l);
					l.moved = true;
					if( y == -1 ) {
						game.animator.putLegume(l,px,--dy,i);
						game.hscombo.push(l);
					} else
						game.animator.putLegume(l,px,y,i);
					setAnim(PUT);
				}
				legumes = new Array();
				game.combo_phase = 0;
				updateHands();
			}
		}

		frame += Timer.tmod;
		if( frame >= anim.length ) {
			animDone();
			frame = frame % anim.length;
		}
		mc.gotoAndStop(string(anim[int(frame)]));
		mc._x = px * 30 + Const.DX;
	}
//{
}
