
import flash.Key;

typedef MC = flash.MovieClip

typedef Part = {
	mc:MC,
	dx:Float,
	dy:Float
}

enum State {
	Wait;
	Start( inc : Bool );
	WaitSpace( s : State );
	WaitFrames( n : Int );
	Angle;
	Run;
}

enum FxState {
	Grass;
}

class Game {//}

	static var BOTTOM = 280.0;
	static var SCROLL_SPEEDS = [
		1,		// grass
		0.6,
		0.3,	// trees
		0.2,	// forest
		0.1,
		0,
	];

	var state : State;
	var dmanager : mt.DepthManager;
	var bgs : Array<MC>;
	var scroll : Float;
	var speed : mt.flash.Volatile<Float>;
	var angle : mt.flash.Volatile<Float>;
	var pos : { x : Float, y : Float, dx : Float, dy : Float };
	var nextObject : mt.flash.Volatile<Int>;
	var lastTree : Int;
	var objects : Array<MC>;
	var items : Array<{ mc : {> MC, sub : MC }, k : Int, active : Bool }>;
	var hframe : Int;
	var stats : { _d : Int };
	var gameover : Bool;
	var itemDist : mt.flash.Volatile<Float>;
	var vangle : Float;
	var qpos : Float;
	var aim : MC;
	var arrow : {> MC, txt : flash.TextField, sub : MC };
	var plate : {> MC, sub : MC };
	var hero : {> MC, sub : {> MC, q : MC } };
	var nexts : Array<MC>;
	var nextItems : Array<Int>;
	var nextPos : Int;
	var dispPos : Int;
	var bonus : Bool;

	var plist : Array<Part>;
	var genFxTimer : Float;

	public function new(mc) {
		dmanager = new mt.DepthManager(mc);
		bgs = new Array();
		for (i in 0...6) {
			bgs[i] = dmanager.attach("bg_plan"+i, (if (i==0) Const.PLAN_FRONT else Const.PLAN_BG) );
			dmanager.under(bgs[i]);
		}
		bgs[0]._y = 300 - bgs[0]._height;
		bgs[1]._y = 300 - bgs[1]._height;
		bgs[2]._y = 300 - bgs[2]._height;
		bgs[3]._y = 290 - bgs[3]._height;
		bgs[4]._y = 170 - bgs[4]._height;
		plist = new Array();
		nexts = new Array();
		for( i in 0...3 ) {
			var n = dmanager.attach("next",Const.PLAN_ARROW);
			nexts.push(n);
			n._x = 210 + i * 35;
			n._y = 20;
		}
		stats = { _d : 0 };
		init();
	}

	function init() {
		scroll = 150.0;
		pos = { x : 200.0, y : BOTTOM - 10, dx : 0.0, dy : 0.0 };
		angle = 0;
		qpos = 0;
		speed = 10;
		nextObject = 100 + Std.random(400);
		itemDist = 0;
		state = Wait;
		nextPos = 0;
		dispPos = 0;
		bonus = false;
		nextItems = [randomProbas(Const.PROBAS),randomProbas(Const.PROBAS),randomProbas(Const.PROBAS)];
		objects = new Array();
		items = new Array();
		plate = cast dmanager.attach("startPlat",Const.PLAN_BG);
		objects.push(plate);
		update();
		updateObjects();
	}

	function randomProbas(tbl:Array<Int>) {
		var t = 0;
		for( i in 0...tbl.length )
			t += tbl[i];
		t = Std.random(t);
		var i = 0;
		while( true ) {
			t -= tbl[i];
			if( t < 0 )
				return i;
			i += 1;
		}
		return null;
	}

	function setAngle(a) {
		var amax = Math.PI * 7 / 16 ;
		if( a > amax )
			a = amax;
		angle = a;
		pos.dx = Math.cos(a) * speed;
		pos.dy = -Math.sin(a) * speed;
	}

	public function update() {
		var count = 5;
		for( i in 0...count )
			doUpdate(mt.Timer.tmod / count,i==0);
	}

	function updatePos(tmod : Float) {
		pos.x += pos.dx / 2 * tmod;
		pos.y -= pos.dy / 2 * tmod;
		pos.dy -= 0.1 * tmod;
		if( pos.y > BOTTOM ) {
			pos.y = BOTTOM;
			pos.dx *= 0.7;
			pos.dy *= -0.65;
			if( speed > 10 ) {
				hero.gotoAndStop(2);
				genFxTimer = 70;
				state = WaitFrames(4);
			} else if( speed < 3 )
				pos.dy = 1;
		}
		speed = Math.sqrt(pos.dx*pos.dx+pos.dy*pos.dy);
		if( speed > 20 ) {
			var p = Math.pow(0.999,tmod);
			speed *= p;
			pos.dx *= p;
			pos.dy *= p;
		}
		angle = Math.atan2(-pos.dy,pos.dx);
		vangle = angle;
		hframe = 1;
		if( pos.y > BOTTOM-20 && speed < 10 ) {
			hframe = 6;
			pos.dx = speed * Math.pow(0.95,tmod);
			pos.dy = 0;
			pos.y = BOTTOM;
		} else if( Key.isDown(Key.LEFT) || Key.isDown(Key.UP) ) {
			var mina = 0.05 + (BOTTOM - pos.y) / 10000;
			if( angle > mina ) {
				angle -= 0.03 * Math.sqrt(speed) / 4 * tmod;
				if( angle < mina )
					angle = mina;
				setAngle(angle);
			}
			vangle = -Math.PI / 4;
			hframe = 3;
		} else if( Key.isDown(Key.RIGHT) || Key.isDown(Key.DOWN) ) {
			pos.dy -= 0.1 * tmod;
			vangle = Math.PI / 4;
			hframe = 4;
		}
	}

	function updateScroll(tmod) {
		var p = Math.pow(0.825,tmod);
		var old = Std.int(scroll);
		scroll = scroll * p + (pos.x - 50) * (1 - p);
		var i = 0;
		for (bg in bgs) {
			var bgpos = Std.int((scroll*SCROLL_SPEEDS[i]) % 500);
			bg._x = -bgpos;
			i++;
		}
		return Std.int(scroll) - old;
	}


	function particle(id:Int,x:Float,y:Float, ds:Float) {
		var mc = dmanager.attach("part", Const.PLAN_FX);
		var dx : Float = null;
		var dy : Float = null;
		mc._xscale = Std.random(70)+30;
		mc._yscale = mc._xscale;
		mc._alpha = Std.random(40)+60;
		mc._rotation = Std.random(360);
		mc.gotoAndStop(""+id);

		if ( id==1 ) {
			// fumée
			mc._x = x + 25 + Std.random(10)*(Std.random(2)*2-1);
			mc._y = y + Std.random(7)*(Std.random(2)*2-1);
			if ( ds<=1 ) {
				mc._xscale*=0.5;
				mc._yscale*=0.5;
			}
		}
		else {
			mc._x = x + Std.random(15)*(Std.random(2)*2-1);
			mc._y = y + Std.random(15)*(Std.random(2)*2-1);
			dx = ds * (Std.random(10)/10);
			if ( id>=6 ) {
				// terre
				dy = -Std.random(20)/10;
			}
			else {
				// feuilles
				dy = -Std.random(10)/10;
				if ( id==5 ) {
					dx *= 0.5 * (Std.random(2)*2-1);
				}
			}
			if ( ds<=1 ) {
				dy *=0.5;
			}
		}
		plist.push( {mc:mc, dx:dx, dy:dy} );
	}


	function updateObjects() {
		while( itemDist > 500 ) {
			itemDist -= 500;

			while( nextItems.length <= nextPos + 3 )
				nextItems.push(randomProbas(Const.PROBAS));

			var id = nextItems[nextPos++];
			var mc = cast dmanager.attach("item",if( id == 1 ) Const.PLAN_ITEM_FRONT else Const.PLAN_ITEM );
			items.push({ mc : mc, k : id, active : false });
			mc.gotoAndStop(1+id);
			if( id == 4 )
				mc.sub.gotoAndStop(if( bonus ) 2 else 1);
			mc._x = 400 + itemDist;
			mc._y = BOTTOM;
		}

		if( scroll >= nextObject ) {
			nextObject += 140 + Std.random(500);
			var obj = dmanager.attach("bgItem",Const.PLAN_BG);
			var f;
			do {
				f=1+Std.random(obj._totalframes);
			} while (f==lastTree);
			obj.gotoAndStop(f);
			lastTree = obj._currentframe;
			obj._x = 300 + obj._width;
			obj._y = BOTTOM+30;
			objects.push(obj);
		}
		for( i in 0...3 )
			nexts[i].gotoAndStop(nextItems[dispPos+i]+1);
	}

	function checkObjects(ds) {
		var i = 0;
		while( i < objects.length ) {
			var o = objects[i];
			o._x -= ds*0.7;
			if( o._x < -o._width ) {
				o.removeMovieClip();
				objects.splice(i,1);
			} else
				i++;
		}

		var i = 0;
		while( i < items.length ) {
			var o = items[i];
			o.mc._x -= ds;
			if( o.mc._x < -30 ) {
				o.mc.removeMovieClip();
				items.splice(i,1);
				dispPos++;
				Const.PROBAS[3]++;
			} else {
				if( !o.active && o.mc.hitTest(pos.x - scroll,pos.y) && !gameover ) {
					// start anim
					o.active = true;
					if( bonus && (o.k == 3 || o.k == 4)  ) {
						bonus = false;
						hero.sub.smc._visible = false;
						arrow.sub.smc._visible = false;
						if( o.k == 4 )
							o.mc.sub.gotoAndStop(1);
					} else {
						o.mc.sub.play();
						KKApi.addScore(Const.POINTS[o.k]);
						switch( o.k ) {

						case 0:	// MOULIN
							if( Math.abs(angle) < 0.3 )
								setAngle(-0.3);
							pos.dx += 20;
							if( pos.dx > 30 )
								pos.dx = 30;
							hero._visible = false;
							state = WaitFrames(21);

						case 1: // BUISSON
							angle += Math.PI / 5;
							setAngle(angle);
							for (n in 0...10) {
								particle(5, o.mc._x, o.mc._y, ds);
							}
							genFxTimer = 60;
							if( pos.dy <= 4 )
								pos.dy = 4;

						case 2:  // TREMPLIN
							pos.dy = Math.abs(pos.dy) + 10;
							if( pos.dy > 30 )
								pos.dy = 30;

						case 3: // SOUCHE
							speed = 0;
							pos.dx = 0.01;
							pos.dy = 0;
							hero.removeMovieClip();

						case 4: // SHIELD
							bonus = true;
							hero.sub.smc._visible = true;
							pos.dx += 10;

						case 5: // GLAND
							pos.dx += 15;
						}
					}
				}
				i++;
			}
		}
	}

	function updateHero(tmod : Float) {
		hero._x = Std.int(pos.x - scroll);
		hero._y = pos.y;


		if( hero._y < -30 ) {
			if( arrow._name == null )
				arrow = cast dmanager.attach("arrow",Const.PLAN_ARROW);
			arrow._x = hero._x;
			arrow.txt.text = Std.int(-hero._y/10)+"m";
			arrow._xscale = arrow._yscale = 100 - Math.sqrt(-hero._y);
		} else
			arrow.removeMovieClip();

		var ca = hero._rotation * Math.PI / 180;
		ca += Math.sin(vangle-ca) * Math.max(speed / 30,0.03) * tmod;
		hero._rotation = ca * 180 / Math.PI;
		if( state == Run && hframe != hero._currentframe && hero._currentframe != 2 )
			hero.gotoAndStop(hframe);

		qpos += speed / 20;
		hero.sub.q.gotoAndStop(Std.int(qpos%hero.sub.q._totalframes)+1);
		hero.sub.q._rotation = -hero._rotation + angle * 180 / Math.PI;
		arrow.sub.gotoAndStop(hero._currentframe);
		arrow.sub._rotation = hero._rotation;

		if( speed < 1 && pos.y > BOTTOM-20 && pos.dy <= 0 && !gameover ) {
			stats._d = Std.int(pos.x);
			KKApi.gameOver(stats);
			gameover = true;
			hero.sub.gotoAndPlay("end");
		}

		hero.sub.smc._visible = bonus;
		arrow.sub.smc._visible = bonus;
	}


	function updateParticles(ds) {
		if ( genFxTimer>0 ) {
			genFxTimer-=1;
			if ( Std.random(5)==0 ) {
				particle(2+Std.random(3), hero._x, hero._y, ds);
			}
			if ( hero._y>=BOTTOM-15 && Std.random(8)==0 ) { // terre
				particle(6+Std.random(3), hero._x, hero._y, ds);
			}
		}

		if ( hero._y>=BOTTOM-5 ) {
			if ( ds>=1 ) {
				particle(1, hero._x, BOTTOM-2, ds);
			}
		}

		var i=0;
		while (i<plist.length) {
			var p = plist[i];
			var fl_kill = false;

			if ( p.mc._currentframe==1 ) { // fumée
				p.mc._x -= ds;
				p.mc._y -= 0.25;
				p.mc._xscale-= 1 + Std.random(2);
				p.mc._yscale = p.mc._xscale;
				if ( p.mc._xscale<=5 ) {
					fl_kill = true;
				}
			}
			else {
				p.mc._x -= ds*0.6;
				p.mc._rotation -= Std.random(5);
//				p.mc._alpha -= 0.5;
				if ( p.mc._alpha<=0 || p.mc._x<=-10 || p.mc._y>=310 ) {
					fl_kill = true;
				}
			}
			if ( p.dx!=null && p.dy!=null ) {
				p.mc._x += p.dx;
				p.mc._y += p.dy;
				if ( p.mc._currentframe>=6 ) {
					// terre
					p.dx -= ds*0.006;
					p.dy += 0.01;
				}
				else {
					p.dx -= ds*0.01;
					p.dy += 0.006;
				}
			}
			if ( fl_kill ) {
				p.mc.removeMovieClip();
				plist.splice(i,1);
				i--;
			}
			i++;
		}
	}



	public function doUpdate(tmod : Float,first) {
		//trace(speed);
		switch( state ) {
		case WaitSpace(s):
			if( !Key.isDown(Key.SPACE) )
				state = s;
		case Wait:
			updateScroll(tmod);
			if( Key.isDown(Key.SPACE) ) {
				plate.sub.gotoAndStop("back");
				state = WaitSpace(Start(false));
				speed = 10;
			}
		case Start(press):
			speed += tmod / 2;
			if( speed > 30 )
				speed = 30;
			plate.sub.gotoAndStop(Std.int(43 + (speed - 10) * 80 / 20));
			pos.x = 200 - speed * 3;
			var ds = updateScroll(tmod);
			updateObjects();
			checkObjects(ds);
			if( press && !Key.isDown(Key.SPACE) ) {
				aim = dmanager.attach("aim",Const.PLAN_ARROW);
				aim._x = pos.x - 100 + speed * 2;
				aim._y = 250;
				state = Angle;
			} else if( !press && (Key.isDown(Key.SPACE) || speed == 30) )
				state = Start(true);
		case Angle:
			angle += speed * tmod / 50;
			var a = angle % Math.PI;
			if( a > Math.PI / 2 )
				a = Math.PI - a;
			var a = ((a / (Math.PI / 2)) * 0.4 + 0.05) * Math.PI / 2;
			aim._rotation = -a * 180 / Math.PI;
			if( Key.isDown(Key.SPACE) ) {
				plate.sub.gotoAndPlay("launch");
				plate._x += 100;
				hero = cast dmanager.attach("hero",Const.PLAN_HERO);
				hero.sub.smc._visible = false;
				arrow.sub.smc._visible = false;
				flash.Lib._global.hero = hero;
				aim.removeMovieClip();
				var s = Math.pow(speed-10,0.7) + 30;
				pos.dx = Math.cos(a) * s;
				pos.dy = Math.sin(a) * s;
				pos.x += pos.dx;
				pos.y -= pos.dy;
				state = Run;
			}
		case Run:
			updatePos(tmod);
			var ds = updateScroll(tmod);
			itemDist += ds;
			if( !gameover )
				KKApi.addScore(KKApi.const(ds));
			updateObjects();
			checkObjects(ds);
			updateHero(tmod);
			updateParticles(ds);
			if( first && plate._name != null ) {
				var apos = if( plate._x < 0 ) 0 else plate._x;
				var nframes = 20;
				var f = Std.int(200 - apos * nframes / 250);
				if( f < 200 - nframes )
					f = 200 - nframes;
				plate.sub.gotoAndStop(f);
			}
		case WaitFrames(n):
			updateParticles(0);
			if( !first )
				return;
			if( n == 0 )
				hero._visible = true;
			state = if( n == 0 ) Run else WaitFrames(n-1);
		}
	}

//{
}
