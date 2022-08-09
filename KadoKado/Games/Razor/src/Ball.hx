import mt.bumdum.Lib;
class Ball {//}


	public var col:Int;
	public var x:Int;
	public var y:Int;

	public var tx:Int;
	public var ty:Int;

	public var fall:Float;

	public var root:flash.MovieClip;

	public function new(px,py){

		x = px;
		y = py;
		insertInGrid();
		Game.me.balls.push(this);

		root = Game.me.bdm.attach("mcBall",Game.DP_BALL);

		//root._xscale = root._yscale = 94;

		col = Std.random(Cs.COL_MAX);
		if(Std.random(Game.me.probaSpecial)==0)col = Cs.COL_MAX;
		root.gotoAndStop(col+1);

		updatePos();
	}

	public function updatePos(){

		root._x = Cs.getX(x);
		root._y = Cs.getY(y);
	}

	public function updateRot(){
		root._rotation = -Game.me.board._rotation;
	}

	public function sliced(){


		var coord = Geom.getParentCoord(root,Game.me.root);

		// SPLASH
		for( i in 0...4 ){
			var mcSplash = Game.me.dm.attach("mcSplash",Game.DP_FX);
			mcSplash._x = coord.x + (Math.random()*2-1)*3;
			mcSplash._y = coord.y + (Math.random()*2-1)*3;
			mcSplash._xscale = mcSplash._yscale = 50+Math.random()*50;
			//Col.setColor(mcSplash,[0x00FF00,0xFF0000,0xFFFFFF][col]);
			Col.setColor(mcSplash,0xFF0000);
			mcSplash._rotation = Math.random()*360;
		}

		// 3 PARTS
		var max = 3;
		for( i in 0...max ){
			var dp = Game.DP_UNDER_FX;
			if(i>0) dp = Game.DP_FX;
			var p = new mt.bumdum.Phys( Game.me.dm.attach("partSlice",dp));



			//trace(coord.x+","+coord.y);

			p.x = coord.x;
			p.y = coord.y;
			p.weight = 0.5+Math.random()*0.2;
			p.vx = (Math.random()*2-1)*1.5;
			p.vy = -(2+Math.random()*4)*1.5;
			p.vr = (Math.random()*2-1)*4;
			p.fr = 0.95;
			p.timer = 60;
			//p.fadeType = 0;
			p.root.gotoAndStop((col+1)*max-i);

			if( i==1 ){
				//Col.setPercentColor(p.root,40,0xA83E3E);
			}

			p.updatePos();
		}

		// SCORE
		var sc = KKApi.cadd( Cs.SCORE_FRUIT_BASE , KKApi.cmult( Cs.SCORE_FRUIT_INC, KKApi.const(Game.me.bonus)));
		if( col == Cs.COL_MAX )sc = Cs.SCORE_PIOUPIOU;

		KKApi.addScore(sc);
		Game.me.comboScore += KKApi.val(sc);

		if( Game.FL_VISEW_SCORE ){
			for( i in 0...3 ){
				var p = new Shaker(Game.me.dm.attach("mcScore",Game.DP_FX));
				cast(p.root)._val = KKApi.val(sc);
				p.x = coord.x;
				p.y = coord.y;
				p.fadeType = 0;
				p.timer = 20;
				p.updatePos();
				p.root.blendMode = "add";
				Col.setColor(p.root,[0xFF0000,0x00FF00,0x0000FF][i]);
			}
		}






		kill();



	}

	public function kill(){
		Game.me.grid[x][y] = null;
		Game.me.balls.remove(this);
		root.removeMovieClip();
	}


	public function insertInGrid(){
		Game.me.grid[x][y] = this;
	}
	public function removeFromGrid(){
		Game.me.grid[x][y] = null;
	}

//{
}











