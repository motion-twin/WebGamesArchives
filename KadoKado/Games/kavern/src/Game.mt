class Game {

	var root_mc : MovieClip;
	var dmanager : DepthManager;
	var level : Level;
	var hero : Hero;

	var bg : MovieClip;
	var blocks : MovieClip;
	var terre : MovieClip;
	var terre_mask : MovieClip;
	var mask : MovieClip;
	var update : bool;

	volatile var diff : int;
	var life : KKConst;
	volatile var dlife : float;
	var ilife : int;
	var color : int;

	var tmps : Array<MovieClip>;
	var bonus : Array<Array<{> MovieClip, t : int, b : {} }>>;
	var others : Array<Array<MovieClip>>;
	var casse : Array<Array<{> MovieClip, f : float }>>;
	var parts : Array<{
		mc : MovieClip,
		x : float,
		y : float,
		px : int,
		py : int,
		dx : float,
		dy : float,
		my : float
	}>
	var falls : Array<{> MovieClip,
		t : float,
		py : float,
		x : int,
		y : int
	}>

	var meter : {> MovieClip, field : TextField };
	var jauge : {> MovieClip, sub : MovieClip, anim : MovieClip };

	var stats : {
		$b : Array<int>, // bonuses
		$l : int, // niveaux affichés
		$d : int, // difficulté
		$k : int, // blocks cassés
		$c : int // terre creusée
	};

	function new(mc) {
		root_mc = mc;
		diff = 0;
		life = Const.LIFE[0];
		dlife = 0;
		dmanager = new DepthManager(mc);
		bg = dmanager.attach("bg",Const.PLAN_BG);
		terre = dmanager.attach("terre",Const.PLAN_TERRE);
		terre_mask = dmanager.empty(Const.PLAN_TERRE);
		blocks = dmanager.attach("blocks",Const.PLAN_BLOCKS);
		mask = dmanager.empty(Const.PLAN_BLOCKS);
		blocks.setMask(mask);
		terre.setMask(terre_mask);
		level = new Level(this);
		hero = new Hero(this,1,Const.HEIGHT-2);
		stats = {
			$b : [0,0,0,0,0,0,0,0],
			$d : 0,
			$k : 0,
			$c : 0,
			$l : 0
		};
		meter = downcast(dmanager.attach("meter",Const.PLAN_INTERF));
		jauge = downcast(dmanager.attach("jauge",Const.PLAN_INTERF));
		jauge._x = 100;
		changeLevel(0,0);
	}

	function getBonus(px,py) {
		var b = bonus[px][py];
		if( b == null )
			return;
		stats.$b[b.t]++;
		var max = Const.LIFE[3];
		switch( b.t ) {
		case 0:
			life = KKApi.cadd(life,Const.LIFE[1]);
			if( KKApi.val(life) >= KKApi.val(max) )
				life = max;
			break;
		case 1:
			life = KKApi.cadd(life,Const.LIFE[2]);
			if( KKApi.val(life) >= KKApi.val(max) )
				life = max;
			break;
		default:
			KKApi.addScore( Const.LEGUMES_POINTS[b.t-2] );
			break;
		}
		var fx = dmanager.attach("FXVanish",Const.PLAN_PART);
		fx._x = b._x + 15;
		fx._y = b._y + 15;
		tmps.push(downcast(fx));
		fx.gotoAndStop("4");
		level.bonus.remove(downcast(b.b));
		b.removeMovieClip();
		bonus[px][py] = null;
	}

	function initFirstLevel() {
		var t = new Array();
		var x,y;
		for(x=0;x<Const.WIDTH;x++) {
			t[x] = new Array();
			for(y=0;y<Const.HEIGHT-1;y++)
				t[x][y] = Level.EMPTY;
			t[x][y] = Level.BLOCKSPE;
			t[x][y+1] = Level.EMPTY;
		}
		t[0][8] = Level.BLOCKSPE;
		t[9][8] = Level.BLOCKSPE;
		var i;
		for(i=0;i<3;i++)
			t[Std.random(8)+1][9] = Level.EARTH;
		level.tbl = t;
	}

	function changeLevel(dx,dy) {
		var i,x,y;
		for(x=0;x<Const.WIDTH;x++)
			for(y=0;y<Const.HEIGHT;y++) {
				others[x][y].removeMovieClip();
				casse[x][y].removeMovieClip();
				bonus[x][y].removeMovieClip();
			}
		for(i=0;i<tmps.length;i++)
			tmps[i].removeMovieClip();
		for(i=0;i<parts.length;i++)
			parts[i].mc.removeMovieClip();
		for(i=0;i<falls.length;i++)
			falls[i].removeMovieClip();
		diff += dy;
		if( diff > 40 )
			color = 5;
		else if( diff > 30 )
			color = 4;
		else if( diff > 20 )
			color = 3;
		else if( diff > 10 )
			color = 2;
		else
			color = 1;
		terre.gotoAndStop(string(color));
		stats.$d += dy;
		stats.$l++;
		meter.field.text = ((diff == 0)?"0":("-"+diff))+"$M".substring(1);
		tmps = new Array();
		others = new Array();
		falls = new Array();
		parts = new Array();
		casse = new Array();
		bonus = new Array();
		level.px += dx;
		level.py += dy;
		hero.x -= dx * 290;
		hero.y -= dy * 290;
		if( diff == 0 ) {
			bg.gotoAndStop("1");
			initFirstLevel();
		} else {
			bg.gotoAndStop("2");
			level.init(int(hero.x/Const.BLOCK_SIZE),int(hero.y/Const.BLOCK_SIZE),diff);
		}
		downcast(bg).sub.gotoAndStop(string(color));

		for(i=0;i<level.bonus.length;i++) {
			var b = level.bonus[i];
			var mc = downcast(dmanager.attach("bonus",Const.PLAN_BONUS));
			mc._x = b.x * Const.BLOCK_SIZE;
			mc._y = b.y * Const.BLOCK_SIZE;
			mc.gotoAndStop(string(b.t+1));
			mc.t = b.t;
			mc.b = upcast(b);
			if( bonus[b.x] == null )
				bonus[b.x] = new Array();
			bonus[b.x][b.y] = mc;
		}
		for(x=0;x<Const.WIDTH;x++)
			for(y=0;y<Const.HEIGHT;y++) {
				var l = level.tbl[x][y];
				if( l == Level.BLOCKSPE ) {
					var mc = dmanager.attach("block2",Const.PLAN_BLOCKS);
					mc._x = x * Const.BLOCK_SIZE;
					mc._y = y * Const.BLOCK_SIZE;
					if( others[x] == null )
						others[x] = new Array();
					others[x][y] = mc;
				}
			}
		showLevel();
	}


	function draw(xp,yp,e) {
		var s = Const.BLOCK_SIZE;
		var dx = e * s;
		var cx = (xp % 7 + 1) * 2;
		var cy = (yp % 7 + 1) * 2;
		terre_mask.moveTo(xp - dx,yp);
		terre_mask.beginFill(0,100);
		terre_mask.curveTo(xp - dx / 2, yp - cy, xp, yp);
		terre_mask.curveTo(xp + cx, yp + s/2, xp, yp + s);
		terre_mask.curveTo(xp - dx / 2, yp + s + cy, xp - dx, yp + s);
		terre_mask.curveTo(xp - dx - cx, yp + s/2, xp - dx, yp);
		terre_mask.endFill();
	}

	function showLevel() {
		mask.clear();
		terre_mask.clear();
		var x,y;
		var e = 0;
		var s = Const.BLOCK_SIZE;
		for(y=0;y<Const.HEIGHT;y++) {
			var yp = y * s;
			for(x=0;x<Const.WIDTH;x++) {
				var l = level.tbl[x][y];
				var xp = x * s;
				if( l == Level.EARTH )
					e++;
				else {
					if( e > 0 ) {
						draw(xp,yp,e);
						e = 0;
					}
					if( l == Level.BLOCK ) {
						if( level.tbl[x][y+1] == Level.EMPTY && y != Const.HEIGHT - 1 ) {
							level.tbl[x][y] = Level.FALLING;
							l = Level.FALLING;
							var mc = downcast(dmanager.attach("block",Const.PLAN_BLOCKS));
							var c = casse[x][y];
							if( c != null ) {
								mc.gotoAndStop(string(c._currentframe));
								c.removeMovieClip();
							}
							mc.stop();
							mc.py = yp;
							mc.x = x;
							mc.y = y;
							mc.t = 1;
							mc._x = xp;
							mc._y = yp;
							falls.push(mc);
						} else {
							mask.moveTo(xp,yp);
							mask.beginFill(0,100);
							mask.lineTo(xp + s, yp);
							mask.lineTo(xp + s, yp + s);
							mask.lineTo(xp, yp + s);
							mask.lineTo(xp, yp);
							mask.endFill();
						}
					}
				}

			}
			if( e > 0 ) {
				draw(x*s,yp,e);
				e = 0;
			}
		}
	}

	function genParts(px : int,py : int,dx,dy) {
		var i;
		var n = int(5 / Timer.tmod);

		deltaLife( - (50 + diff) / 200 );

		for(i=0;i<n;i++) {
			var p = dmanager.attach("part",Const.PLAN_BG);
			var x = px * Const.BLOCK_SIZE + Std.random(Const.BLOCK_SIZE);
			var y = py * Const.BLOCK_SIZE + Std.random(Const.BLOCK_SIZE);
			p.gotoAndStop(string(color));
			p._xscale = 50 + Std.random(70);
			p._yscale = p._xscale;
			p._x = x;
			p._y = y;
			parts.push({
				mc : p,
				x : x,
				y : y,
				px : px,
				py : py,
				my : (py + 1) * Const.BLOCK_SIZE,
				dx : dx + Std.random(10) / 20,
				dy : dy - Std.random(10) / 20
			});
		}
	}

	function deltaLife(d) {
		dlife += d;
		var k = int(dlife);
		dlife -= k;
		life = KKApi.cadd(life,KKApi.const(k));
	}

	function doCasse(x,y) {
		if( casse[x] == null )
			casse[x] = new Array();
		var c = casse[x][y];
		if( c == null ) {
			c = downcast(dmanager.attach("block",Const.PLAN_BLOCKS));
			c._x = x * Const.BLOCK_SIZE;
			c._y = y * Const.BLOCK_SIZE;
			c.f = 0;
			c.stop();
			casse[x][y] = c;
		}
		if( c.f > 5 )
			deltaLife(-Timer.tmod/2);
		c.f += Timer.tmod / 2;
		c.gotoAndStop(string(int(c.f)+1));
		if( c.f >= c._totalframes ) {
			c.removeMovieClip();
			stats.$k++;
			level.tbl[x][y] = Level.EMPTY;
			update = true;
		}
	}

	function main() {

		var lf = KKApi.val(life) + dlife;
		var il = int(lf);
		if( ilife != il ) {
			ilife = il;
			jauge.sub._yscale = il;
		}
		jauge.anim._visible = lf < 10;

		if( diff > 0 && jauge._x > 0 ) {
			jauge._x *= Math.pow(0.9,Timer.tmod);
			if( jauge._x < 1 )
				jauge._x = 0;
		}

		if( lf <= 0 ) {
			life = Const.LIFE[4];
			dlife = 0;
			if( hero.state == Hero.NORMAL && hero.anim != Hero.A_DEATH ) {
				hero.state = Hero.DEATH;
				hero.anim = Hero.A_DEATH;
				hero.frame = 0;
			}
		}

		update = false;
		hero.update();

		var i;
		for(i=0;i<falls.length;i++) {
			var f = falls[i];
			f.t -= Timer.deltaT;
			if( f.t < 0 ) {
				f._x = f.x * Const.BLOCK_SIZE;
				f.py += 5 * Timer.tmod;
				f._y = f.py;
				var py = int(f.py / Const.BLOCK_SIZE);
				if( py != f.y ) {
					hero.moving = true;
					level.tbl[f.x][f.y] = Level.EMPTY;
					f.y++;
					hero.kill(f.x,f.y);
					if( level.tbl[f.x][f.y+1] == Level.EMPTY )
						level.tbl[f.x][f.y] = Level.FALLING;
					else {
						level.tbl[f.x][f.y] = Level.BLOCK;
						f.removeMovieClip();
						update = true;
						falls.splice(i--,1);
					}
				}
			} else {
				f._x = f.x * Const.BLOCK_SIZE + (Std.random(5) - 2);
			}
		}
		if( update )
			showLevel();

		for(i=0;i<parts.length;i++) {
			var p = parts[i];
			p.dy += Timer.tmod * 0.5;
			p.x += p.dx * Timer.tmod;
			p.y += p.dy * Timer.tmod;
			if( level.tbl[p.px][p.py+1] == Level.EMPTY ) {
				p.my += Const.BLOCK_SIZE;
				p.py++;
			}
			if( p.y > p.my ) {
				p.y = p.my;
				p.dx = 0;
			}
			p.mc._xscale *= Math.pow(0.9,Timer.tmod);
			p.mc._x = p.x;
			p.mc._y = p.y;
			if( p.mc._xscale <= 10 ) {
				p.mc.removeMovieClip();
				parts.splice(i--,1);
			}
		}
	}

	function destroy() {
	}

}