class Game {//}

	var pList:Array<sp.Part>
	
	var particules : Particules;
	var level : Level;
	var dmanager : DepthManager;
	var c1 : Coin;
	var c2 : Coin;
	var rot : int;
	var tr : int;
	var tx : int;
	var rot_activate : bool;
	var fall_key_lock : bool;
	var lock : bool;
	var way : int;
	var bg : MovieClip;
	var points : Array<{> MovieClip, field : TextField, ico : {> MovieClip, sub : MovieClip, sub2 : MovieClip, sub3 : MovieClip } }>;
	var piece : { mc : MovieClip, dmanager : DepthManager };

	var stats : {
		$k : int,
		$b : Array<int>
	};

	function new(mc) {
		dmanager = new DepthManager(mc);
		bg = dmanager.attach("bg",Const.PLAN_BG);
		stats = {
			$k : 0,
			$b : new Array()
		};
		particules = new Particules(dmanager);
		level = new Level(this);
		level.initLevel();
		initPoints();
		updatePoints();
		initCoin();
		nextTurn();
		way = 0;
		Const.game = this;
		pList = new Array();
	}

	function initPoints() {
		var i;
		points = new Array();
		for(i=0;i<Const.POINTS.length;i++) {
			var mc = downcast(dmanager.attach("mcScoreInfo",Const.PLAN_INTERF));
			mc._x = 10;
			mc._y = 3 + i * 24.5;
			mc.field.text = string(KKApi.val(Const.POINTS[i]));
			points.push(mc);
		}
	}

	function updatePoints() {
		var i;
		for(i=0;i<points.length;i++) {
			var mc = points[i];
			mc.ico.gotoAndStop((i < Const.ID_COUNT)?"2":"1");
			mc.ico.sub.gotoAndStop(string(i+1));
			mc.ico.sub2.gotoAndStop(string(i+1));
			mc.ico.sub3.gotoAndStop(string(i+1));
		}
	}

	function initCoin() {
		var mc = dmanager.empty(Const.PLAN_COIN);
		piece = { mc : mc, dmanager : new DepthManager(mc) };
		c1 = new Coin(downcast(piece),0,0);
		c2 = new Coin(downcast(piece),0,0);
		c1.mc._x = Const.COIN_SIZE / 2;
		c2.mc._x = -Const.COIN_SIZE / 2;
		c1.mc._y = 0;
		c2.mc._y = 0;
		mc._x = 150;		
		tr = 0;
		rot = 0;
	}

	function rotate() {
		rot++;
		rot %= 4;
		switch( rot ) {
		case 0:
			tr = 0;
			break;
		case 1:
			tr = 90;
			piece.dmanager.over(c1.mc);
			break;
		case 2:
			tr = 180;
			break;
		case 3:
			tr = -90;
			piece.dmanager.over(c2.mc);
			break;
		}
	}

	function fall() {
		var px = int((piece.mc._x - Const.POS_X + 5) / Const.COIN_SIZE);
		var dy = 0;
		var p1 = null, p2 = null;
		switch( rot ) {
		case 0:
			dy = Const.COIN_SIZE / 2;
			p1 = { x : px + 1, y : 0 };
			p2 = { x : px, y : 0 };
			break;
		case 1:
			p1 = { x : px, y : 1 };
			p2 = { x : px, y : 0 };
			break;
		case 2:
			dy = Const.COIN_SIZE / 2;
			p1 = { x : px, y : 0 };
			p2 = { x : px + 1, y : 0 };
			break;
		case 3:
			p1 = { x : px, y : 0 };
			p2 = { x : px, y : 1 };
			break;
		}

		var cc1,cc2;

		cc1 = new Coin(this,p1.x,p1.y);
		cc1.setId(c1.id);
		level.coins[p1.x][p1.y] = cc1;

		cc2 = new Coin(this,p2.x,p2.y);
		cc2.setId(c2.id);
		level.coins[p2.x][p2.y] = cc2;

		stats.$k++;

		piece.mc._visible = false;
		level.gravity();
		cc1.dy -= dy;
		cc1.mc._y += dy;
		cc2.dy -= dy;
		cc2.mc._y += dy;
		lock = true;
	}

	function nextTurn() {
		var i;
		for(i=0;i<Const.WIDTH;i++)
			if( level.coins[i][1] != null ) {
				KKApi.gameOver(stats);
				lock = true;
				return;
			}

		c1.setId( Std.random(Const.ID_COUNT-1) );
		c2.setId( Std.random(Const.ID_COUNT-1) );
		piece.mc._y = -Const.COIN_SIZE;
		piece.mc._visible = true;
	}

	function calcPoints() {
		var x,y;
		var s = 0;
		var i;
		for(i=0;i<stats.$b.length;i++)
			stats.$b[i] = 0;
		for(x=0;x<Const.WIDTH;x++)
			for(y=0;y<Const.HEIGHT;y++) {
				var c = level.coins[x][y];
				if( c != null ) {
					if( stats.$b[c.id] == null )
						stats.$b[c.id] = 0;
					stats.$b[c.id]++;
					s += KKApi.val(Const.POINTS[c.id]);
				}
			}
		KKApi.setScore(KKApi.const(s));
	}

	function main() {

		//dmanager.attach("partLightFlip",5);

		sp.Part.fr = Math.pow(0.95,Timer.tmod)
		for( var i=0; i<pList.length; i++ ){
			pList[i].update();
		}
			
		//particules.main();

		if( lock ) {
			if( !level.update() ) {
				lock = level.gravity();
				if( !lock ) {
					lock = level.explode();
					calcPoints();
					updatePoints();
					if( !lock )
						nextTurn();
				}
			}
			return;
		}

		piece.mc._y = (piece.mc._y + Const.COIN_SIZE) / 2;

		var moving = false;
		if( piece.mc._rotation != tr * 1.0 ) {
			
			/*  // LINEAIRE
			var s = Math.min(10 * Timer.tmod,30);
			if( Math.abs(piece.mc._rotation - tr) < s )
				piece.mc._rotation = tr;
			else {
				moving = true;
				piece.mc._rotation += s;
			}
			/*/ // ACCELERATION
			var dr = tr - piece.mc._rotation
			while(dr>180)dr-=360;
			while(dr<=-180)dr+=360;
			piece.mc._rotation += dr*0.4*Timer.tmod;
			moving = Math.abs(dr) > 5
			//*/
			
			c1.mc._rotation = -piece.mc._rotation;
			c2.mc._rotation = -piece.mc._rotation;
		}

		var calcx = int((piece.mc._x - Const.POS_X) / Const.COIN_SIZE);
		var bigx = Math.round((piece.mc._x - Const.POS_X) / Const.COIN_SIZE);
		var maxx = Const.WIDTH - (rot==0 || rot==2)?2:1;

		if( tx == null )
			tx = calcx;

		if( calcx < 0 )
			calcx = 0;
		else if( calcx > maxx )
			calcx = maxx;
		if( tx > maxx )
			tx = maxx;
		else if( tx < 0 )
			tx = 0;

		var s = Math.min(5 * Timer.tmod,20);
		var ds = 0;
		if( Key.isDown(Key.LEFT) && bigx > 0 ) {
			tx = bigx - 1;
			ds = -s;
			moving = true;
		} else if( Key.isDown(Key.RIGHT) && calcx < maxx ) {
			tx = calcx + 1;
			ds = s;
			moving = true;
		} else {
			var px = (tx + ((rot & 1) == 0)?0.5:0) * Const.COIN_SIZE + Const.POS_X;
			var p = Math.pow(0.7,Timer.tmod);
			moving = (Math.abs(piece.mc._x - px) > 4);
			piece.mc._x = piece.mc._x * p + px * (1 - p);
		}
		piece.mc._x += ds;

		if( Key.isDown(Key.DOWN) ) {
			if( !fall_key_lock && !moving ) {
				fall_key_lock = true;
				fall();
			}
		} else
			fall_key_lock = false;
		if( (rot_activate || Key.isDown(Key.SPACE) || Key.isDown(Key.UP)) && !moving ) {
			rot_activate = false;
			rotate();
		}
	}

	function destroy() {
	}

	//
	function newPart(link){
		var sp = new sp.Part();
		var mc = dmanager.attach( link, Const.PLAN_PART )
		sp.setSkin( mc )
		pList.push(sp)
		return sp;
	}
	
	
//{
}