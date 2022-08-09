class Bille {//}

	var game : Game;
	var mc : MovieClip;
	var t : int;
	var x : int;
	var y : int;
	var px : float;
	var py : float;
	var dy : float;
	var group : Array<Bille>;

	function new(g,t) {
		game = g;
		mc = game.dmanager.attach("bille",Const.PLAN_BLOCKS);
		setSkin(t);
	}

	function select(b) {
		var c = new Color(mc);
		if( b )
			c.setTransform({
				ra : 100,
				rb : -50,
				ga : 100,
				gb : -50,
				ba : 100,
				bb : -50,
				aa : 100,
				ab : 0
			});
		else
			c.reset();
	}

	function setPos(x,y) {
		this.x = x;
		this.y = y;
		mc._x = x * Const.BSIZE + Const.PX;
		mc._y = y * Const.BSIZE + Const.PY;
		px = mc._x;
		py = mc._y;
		mc.onPress = callback(game,onSelect,this);
		KKApi.registerButton(mc);
		game.level.tbl[x][y] = this;
	}

	function score() {
		//mc.removeMovieClip();
		//mc = null;
		switch( t ) {
			case 0:
			case 1:
			case 2:
			case 3:
				//downc ast(mc).sub.nextFrame();
				mc.removeMovieClip();
				mc = null;
				KKApi.addScore(Const.C150);
				game.stats.$k++;
				//
				var p = centerPart("partScore");
				p.skin._rotation = Math.random()*360
				centerPart("partRound");

				break;
			case Const.ID_WALL:
				mc.removeMovieClip();
				mc = null;
				centerPart("partStoneBlast")
				KKApi.addScore(Const.C50);
				game.stats.$w++;
				break;
			case Const.ID_MONSTER:
				mc.removeMovieClip();
				mc = null;
				game.stats.$m++;

				var ray = 12
				for( var i=0; i<6; i++ ){
					var p = game.newPart("partMonster")
					var a = Math.random()*6.28
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var sp = 0.6+Math.random()*0.5
					p.x = px+ca*ray
					p.y = py+sa*ray
					p.vitx = ca*sp;
					p.vity = sa*sp;
					p.timer = 10+Math.random()*10
					p.init();
				}
				centerPart("partDeath")

				break;
			case Const.ID_BONUS:
				mc.removeMovieClip();
				mc = null;
				KKApi.addScore(Const.C1000);
				game.stats.$b++;
				//
				for( var i=0; i<1; i++){
					var p = game.newPart("partAureole")
					p.x = px;
					p.y = py;
					p.scale = 50
					p.vits = 20
					p.timer = 20
					p.fadeTypeList=[1]
					p.init();
				}

				var p = centerPart("partBonusValue")
				downcast(p.skin).sub.gotoAndStop(2)

				break;
		}
		if(t!=Const.ID_MONSTER)game.flash(mc);

	}

	function centerPart(link){
		var p = game.newPart(link)
		p.x = px;
		p.y = py
		p.init();
		return p;
	}

	function setSkin(t) {
		this.t = t;
		mc.gotoAndStop(string(t+1));
	}

	function moveTo(x,y) {
		var tx = x * Const.BSIZE + Const.PX;
		var ty = y * Const.BSIZE + Const.PY;
		var p = Math.pow(0.8,Timer.tmod);
		mc._x = mc._x * p + tx * (1 - p);
		py = py * p + ty * (1 - p);
		if( tx != px )
			mc._y = py + Math.sin((mc._x - px) * 3.14 / (tx - px)) * (tx < px)?10:-10;
		else
			mc._y = py;

		var dx = mc._x - tx;
		var dy = mc._y - ty;
		var d = Math.sqrt(dx*dx+dy*dy);

		return (d > 1);
	}
//{
}