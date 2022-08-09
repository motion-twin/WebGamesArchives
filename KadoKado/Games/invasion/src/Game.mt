class Game {

	static var PLACE = 0;
	static var ATTACK = 1;
	static var END = 2;
	static var EXIT = 3;
	static var ANIM = 4;

	var dmanager : DepthManager;
	var level : Array<Array<Perso>>;
	var cases : Array<Array<MovieClip>>;
	var state : int;
	var cursor : MovieClip;
	var root_mc : MovieClip;
	var anims : Array<Perso>;
	var monster_turn : bool;
	var wait : Array<Perso>;

	var stats : {
		$l : int,
		$s : int,
		$k : Array<int>,
		$m : Array<int>,
		$g : Array<int>,
	};

	function new( root ) {
		root_mc = root;
		dmanager = new DepthManager(root);
		var bg = dmanager.attach("background",Const.PLAN_BG);
		bg._x = 150;
		bg._y = 150;
		bg.cacheAsBitmap = true;
		level = new Array();
		cases = new Array();
		anims = new Array();
		wait = new Array();
		state = PLACE;
		cursor = dmanager.attach("cursor",Const.PLAN_CURSOR);
		cursor._visible = false;
		var x,y;
		for(x=0;x<Const.WIDTH;x++) {
			level[x] = new Array();
			cases[x] = new Array();
			for(y=0;y<Const.HEIGHT;y++) {
				var mc = dmanager.attach("case",Const.PLAN_CASES);
				if( Std.random(4) == 0 )
					mc.gotoAndStop(string(1+Std.random(mc._totalframes)));
				else
					mc.stop();
				mc.cacheAsBitmap = true;
				Const.pos(mc,x,y);
				mc.useHandCursor = false;
				cases[x][y] = mc;
			}
		}
		var bg2 = dmanager.attach("background_dirt-element",Const.PLAN_CASES);
		bg2._x = 150;
		bg2._y = 150;
		bg2.cacheAsBitmap = true;
		stats = {
			$l : 0,
			$s : 0,
			$k : [0,0,0],
			$m : [0,0,0],
			$g : [],
		};
		root.onRelease = callback(this,action,callback(this,press),null);
		root.onMouseMove = callback(this,action,callback(this,preview),callback(this,clearPreview));
		root.useHandCursor = false;
		KKApi.registerButton(root);
	}

	function monsterPlace() {
		var x,y,x2,y2;
		var l = new Array();
		for(x=0;x<Const.WIDTH;x++)
			for(y=0;y<Const.HEIGHT;y++)
				if( level[x][y] == null ) {
					var k1 = 0, k2 = 0;
					for(x2=0;x2<Const.WIDTH;x2++)
						for(y2=0;y2<Const.HEIGHT;y2++) {
							var p = level[x2][y2];
							if( p != null ) {
								var d = Math.pow(Math.abs(x - x2) * Math.abs(y - y2),0.7);
								if( p.hero )
									k1 += - d * 0.3;
								else
									k2 += d;
							}
						}
					l.push({ x : x, y : y, k1 : k1, k2 : k2 });
				}
		l.sort(fun(p1,p2) { return (p2.k1 + p2.k2) - (p1.k1 + p1.k2) });
		if( l.length == 0 )
			return false;
		var choice = l[Std.random(int(l.length/4))];		
		var p = new Perso(this,false,choice.x,choice.y);
		level[p.x][p.y] = p;
		return true;
	}

	function monsterCheckAttack(x,y,dx,dy,l) {
		var att = sameCount(false,x+dx,y+dy,dx,dy);
		if( att == 0 )
			return;
		var def = sameCount(true,x,y,-dx,-dy);
		if( att > def )
			l.push({ x : x, y : y, dx : dx, dy : dy, att : att, def : def, can : true });
	}

	function playerCheckAttack(x,y,dx,dy) {
		var att = sameCount(true,x+dx,y+dy,dx,dy);
		if( att == 0 )
			return false;
		var def = sameCount(false,x,y,-dx,-dy);
		return att > def;
	}

	function attackRec(f : bool,x : int,y : int,l : Array<Perso>) : bool {
		if( x < 0 || y < 0 || x == Const.WIDTH || y == Const.HEIGHT )
			return false;
		var p = level[x][y];
		if( p.hero == f ) {
			var i;
			for(i=0;i<l.length;i++)
				if( l[i].x == x && l[i].y == y )
					return true;
			l.push(p);
			if( !attackRec(f,x-1,y,l) )
				return false;
			if( !attackRec(f,x+1,y,l) )
				return false;
			if( !attackRec(f,x,y-1,l) )
				return false;
			if( !attackRec(f,x,y+1,l) )
				return false;
		}
		return true;
	}

	function doAttack(a) {
		var x = a.x;
		var y = a.y;
		var l = new Array();
		var p = level[x][y];
		if( !attackRec(p.hero,x,y,l) )
			l = [p];
		var i;
		for(i=0;i<l.length;i++) {
			p = l[i];
			if( p.hero ) {
				stats.$l++;
				KKApi.addScore(Const.HERO_DEATH_POINTS);
			} else {
				stats.$k[p.kind]++;
				KKApi.addScore(Const.MONSTER_POINTS[p.kind]);
			}
			p.destroy();
			level[p.x][p.y] = null;
		}
		if( l.length > 1 ) {
			stats.$g.push(l.length-1);
			KKApi.addScore(KKApi.cmult(Const.GROUP_BONUS,KKApi.const(l.length-1)));
		}
		x += a.dx;
		y += a.dy;
		var first = true;
		while( a.att > 0 ) {
			p = level[x][y];
			p.move(-a.dx,-a.dy,first);
			first = false;
			level[x][y] = null;
			level[p.x][p.y] = p;
			x += a.dx;
			y += a.dy;
			a.att--;
			anims.push(p);
		}
		state = ANIM;
		if( a.dy != 0 )
			dmanager.ysort(Const.PLAN_PERSO);
	}

	function playerCanAttack() {
		var x, y;
		for(x=0;x<Const.WIDTH;x++)
			for(y=0;y<Const.HEIGHT;y++) {
				var p = level[x][y];
				if( p.hero == false && (
					playerCheckAttack(x,y,1,0) ||
					playerCheckAttack(x,y,-1,0) ||
					playerCheckAttack(x,y,0,1) ||
					playerCheckAttack(x,y,0,-1)
				))
					return true;
			}
		return false;
	}

	function monsterAttack() {
		var l = new Array();
		var p, x, y;
		for(x=0;x<Const.WIDTH;x++)
			for(y=0;y<Const.HEIGHT;y++) {
				p = level[x][y];
				if( p.hero ) {
					monsterCheckAttack(x,y,1,0,l);
					monsterCheckAttack(x,y,-1,0,l);
					monsterCheckAttack(x,y,0,1,l);
					monsterCheckAttack(x,y,0,-1,l);
				}
			}
		if( l.length == 0 )
			return false;
		doAttack(l[Std.random(l.length)]);
		return true;
	}

	function sameCount(h,x,y,dx,dy) {
		var n = 0;
		while( level[x][y].hero == h ) {
			x += dx;
			y += dy;
			n++;
		}
		return n;
	}

	function checkAttack(x,y) {
		var mc = cases[x][y];
		var p = level[x][y];
		var mx = mc._xmouse > mc._ymouse;
		var my = mc._xmouse + mc._ymouse < Const.SIZE;
		var dx = 0;
		var dy = 0;
		if( mx && my )
			dy = -1;
		else if( mx )
			dx = 1;
		else if( my )
			dx = -1;
		else
			dy = 1;
		var att = sameCount(!p.hero,x+dx,y+dy,dx,dy);
		var def = sameCount(p.hero,x,y,-dx,-dy);
		return {
			x : x,
			y : y,
			dx : dx,
			dy : dy,
			att : att,
			def : def,
			can : att > def,
		}
	}

	function action(prev,out) {
		var x = int((root_mc._xmouse - Const.DX) / Const.SIZE);
		var y = int((root_mc._ymouse - Const.DY) / Const.SIZE);	
		if( x < 0 || y < 0 || x >= Const.WIDTH || y >= Const.HEIGHT ) {
			out();
			return;
		}
		prev(x,y);
	}

	function clearPreview() {
		var x,y;
		cursor._visible = false;
		for(x=0;x<Const.WIDTH;x++)
			for(y=0;y<Const.HEIGHT;y++)
				level[x][y].signal(null);

	}

	function dir(dx,dy) {
		if( dx < 0 )
			return 1;
		if( dx > 0 )
			return 0;
		if( dy > 0 )
			return 2;
		return 3;
	}

	function preview(x,y) {
		var p = level[x][y];
		clearPreview();
		if( p == null && state == PLACE ) {
			cursor._visible = true;
			cursor.gotoAndStop("1");
			Const.pos(cursor,x,y);
			return;
		}
		if( state != ATTACK || p.hero != false )
			return;

		var a = checkAttack(x,y);
		if( a.att == 0 )
			return;

		var n = a.def;
		var first = true;
		while( n-- > 0 ) {
			p = level[x][y];
			p.dir = dir(a.dx,a.dy);
			p.update();
			p.signal(a.can?(first ? Const.SDEF_FIRST : Const.SDEF):Const.SNODEF);
			first = false;
			x -= a.dx;
			y -= a.dy;
		}
		x = a.x + a.dx;
		y = a.y + a.dy;
		n = a.att;
		while( n-- > 0 ) {
			p = level[x][y];
			p.dir = dir(-a.dx,-a.dy);
			p.update();
			p.signal(a.can?Const.SATT:Const.SNOATT);
			x += a.dx;
			y += a.dy;
		}
		cursor._visible = true;
		var frame;
		if( a.dx < 0 )
			frame = 2;
		else if( a.dx > 0 )
			frame = 4;
		else if( a.dy < 0 )
			frame = 3;
		else
			frame = 5;
		cursor.gotoAndStop(string(frame));
		Const.pos(cursor,a.x,a.y);
	}

	function press(x,y) {
		switch( state ) {
		case PLACE :
			var p = level[x][y];
			if( p != null )
				return;
			clearPreview();			
			level[x][y] = new Perso(this,true,x,y);
			if( !monsterPlace() )
				nextTurn();
			break;
		case ATTACK:
			var p = level[x][y];
			if( p.hero != false )
				return;
			var a = checkAttack(x,y);
			if( !a.can )
				return;
			clearPreview();
			doAttack(a);
			break;
		}
	}

	function nextTurn() {
		var p = playerCanAttack();
		if( !p ) {
			if( !monsterAttack() )
				state = END;
		} else
			state = ATTACK;
	}

	function main() {
		var i;
		for(i=0;i<wait.length;i++) {
			var p = wait[i];
			if( p.fx.remove ) {
				if( p.mc == null )
					p.attach();
				else
					p.mc.removeMovieClip();
				wait.splice(i--,1);
			}
		}
		if( wait.length != 0 )
			return;

		switch( state ) {
		case PLACE:
			break;
		case ANIM:
			for(i=0;i<anims.length;i++)
				if( !anims[i].anim() )
					anims.splice(i--,1);
			if( anims.length == 0 ) {
				if( monster_turn ) {
					monster_turn = false;
					nextTurn();
				} else {
					monster_turn = true;
					if( !monsterAttack() )
						nextTurn();
				}
			}
			break;
		case END:
			root_mc.onMouseMove = null;
			root_mc.onRelease = null;
			var x,y;
			for(x=0;x<Const.WIDTH;x++)
				for(y=0;y<Const.HEIGHT;y++) {
					var p = level[x][y];
					if( p != null && p.cursig != Const.SMARK ) {
						p.signal(Const.SMARK);
						if( p.hero ) {
							stats.$s++;
							KKApi.addScore(Const.HERO_KEEP_POINTS);
						} else {
							stats.$m[p.kind]++;
							KKApi.addScore(Const.MONSTER_KEEP_POINTS[p.kind]);
						}
						return;
					}
				}
			KKApi.gameOver(stats);
			state = EXIT;
			break;
		}
	}

}