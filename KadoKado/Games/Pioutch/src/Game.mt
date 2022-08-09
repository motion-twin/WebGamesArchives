class Game {

	static var PLAN_BG1 = 0;
	static var PLAN_PARTBIRD = 1;	
	static var PLAN_BG2 = 2;
	static var PLAN_CAISSE = 3;
	static var PLAN_HERO = 4;
	static var PLAN_PIOU = 5;
	static var PLAN_PART = 6;
	static var PLAN_BG3 = 7;
	static var PLAN_INTERF = 8;

	// game play
	static var SIMULTANOUS = [0,4,30,100,200];
	static var INIT_LIFE = KKApi.const(5);
	static var INIT_SPECIAL = KKApi.const(3);
	static var POINTS = KKApi.aconst([200,500,3000]);
	static var TYPE_PROBAS = [50,10,1,1];

	// game feeling
	static var ACC = 1.3;
	static var FRIC = 0.65;
	static var GRAVITY = 0.95;
	static var MINSPEED = 2;
	static var MAXSPEED = 7;
	static var PIOUSPEED = 0.9;

	// gfx
	static var REPEAT = 10;
	static var MINX = 10;
	static var MAXX = 228;
	static var MIDDLEX = (MINX + MAXX) / 2;
	static var INIT_FRAMES = 4;
	static var MAXY = 295;
	static var HIGHY = 70;
	static var SAVEX = 275;
	static var SAVEY = 200;
	static var BASEGATE = 145;

	var dmanager : DepthManager;
	var hero : {> MovieClip, sub : {> MovieClip, hit :MovieClip, r : MovieClip, h : MovieClip, sub : {> MovieClip, c : MovieClip }} };
	var magicGate : {> MovieClip, sub : MovieClip, manager : DepthManager };
	var shadowGate : MovieClip;
	var infos : MovieClip;
	var caisse : MovieClip;
	var bug : {> MovieClip, sub : {> MovieClip} };
	var hanim : float;
	var hspeed : float;
	var hx : float;
	var dir : int;
	var shakeY : float;
	var shakeFact : float;
	var gateY : float;
	var piouY : float;
	var cooldown : int;
	var bugProb : int;
	volatile var timer : float;
	volatile var speed : float;
	var furie : bool;
	var head_pos : float;
	var parts : Array<{> MovieClip, size : float, dx : float, dy : float }>;
	var partsP : Array<{> MovieClip, size : float, dx : float, dy : float }>;
	var partsBird : Array<{> MovieClip, size : float, dx : float, dy : float }>;
	var partsBug : Array<{> MovieClip, size : float, dx : float, dy : float }>;
	var partsBlob : Array<{> MovieClip, size : float, dx : float, dy : float }>;
	var pious : Array<{> MovieClip, sub : MovieClip, dx : float, dy : float, k : float, type : int }>;
	var stats : {
		$c : int,
		$s : int,
		$l : int,
	};

	var lifeIcons : Array<MovieClip>;
	var specialIcons : Array<MovieClip>;
	var lifeCount : KKConst;
	var specialCount : KKConst;
	var pressSpace : bool;
	var bg : MovieClip;
	var bg2 : MovieClip;
	var bg3 : MovieClip;
	var cl1 : MovieClip;
	var cl2 : MovieClip;

	function new(mc) {
		dmanager = new DepthManager(mc);
		bg = dmanager.attach("background",PLAN_BG1);
		bg.cacheAsBitmap = true;
		cl1 = dmanager.attach("clouds",PLAN_BG1);
		cl1.cacheAsBitmap = true;
		bugProb = Std.random(500);
		if( bugProb == 0 )
			bug = downcast(dmanager.attach("bug",PLAN_BG1));
		cl2 = dmanager.attach("clouds2",PLAN_BG2);
		cl2.cacheAsBitmap = true;
		bg2 = dmanager.attach("background2",PLAN_BG2);
		bg2.cacheAsBitmap = true;
		caisse = dmanager.attach("caisse",PLAN_CAISSE);
		caisse.cacheAsBitmap = true;
		caisse._x = 300;
		caisse._y = 300;
		bg3 = dmanager.attach("background3",PLAN_BG3);
		bg3.cacheAsBitmap = true;
	
		hero = downcast(dmanager.attach("hero",PLAN_HERO));
		magicGate = downcast(dmanager.attach("magicGate",PLAN_BG2));
		magicGate.manager = new DepthManager(magicGate.sub);
		magicGate.cacheAsBitmap = true;
		shadowGate = dmanager.attach("shadowGate",PLAN_BG2);
//		infos = dmanager.empty(PLAN_INTERF);
		shadowGate.cacheAsBitmap = true;
		magicGate._x = -9;
		magicGate._y = BASEGATE - 5;
		shadowGate._x = 25;
		shadowGate._y = 294;
		hero.gotoAndStop("1");
		bug.sub.gotoAndStop(string(Std.random(4)+1));
		bug._x = 500;
		bug._y = 260;
		cooldown = 80;
		hx = MIDDLEX;
		hero._y = MAXY;
		hspeed = 0;
		hanim = 0;
		head_pos = 0;
		speed = PIOUSPEED;
		dir = 1;
		timer = 3;
		stats = {
			$c : 0,
			$s : 0,
			$l : 0,
		}
		pious = new Array();
		parts = new Array();
		partsP = new Array();
		partsBird = new Array();
		partsBug = new Array();
		partsBlob = new Array();

		lifeIcons = new Array();
		specialIcons = new Array();
		lifeCount = INIT_LIFE;
		specialCount = INIT_SPECIAL;

		var i;
		for(i=0;i<KKApi.val(lifeCount);i++)
			addLife();
		for(i=0;i<KKApi.val(specialCount);i++)
			addSpecial();

		initShake(0,0);
		gateY = 0;
		main();
	}

	function addLife() {
		var ico = dmanager.attach("lifeIcon",PLAN_INTERF);
		ico._x = 280 - lifeIcons.length * 23;
		ico._y = 20;
		ico.stop();
		lifeIcons.push(ico);
	}

	function addSpecial() {
		var ico = dmanager.attach("specialIcon",PLAN_INTERF);
		ico._x = 20 + specialIcons.length * 25;
		ico._y = 20;
		ico.stop();
		specialIcons.push(ico);
	}

	function genPiou() {
		var i;
		if( stats.$c < SIMULTANOUS[pious.length] )
			return false;
		var xlimit = (MAXX + MINX) / 2 + stats.$c * 3;
		var ylimit = HIGHY - stats.$c / 3;
		var xmin = MINX + 50;
		infos.clear();
		infos.lineStyle(1,0,20);
		infos.moveTo(xlimit,0);
		infos.lineTo(xlimit,300);
		infos.moveTo(0,ylimit);
		infos.lineTo(300,ylimit);

		for(i=0;i<pious.length;i++) {
			var p = pious[i];
			if( p._x > xlimit || (p._x > xmin && p._y < ylimit) ) {
				return false;
			}
		}
		stats.$c++;
		var p = downcast(dmanager.attach("piou",PLAN_PIOU));
		var n = Std.random(3);
		p._x = 35;
		p._y = 120 + n * 50;
		p.dx = 4 - Math.random();
		genPartBlob(p._x,p._y);
		p.dy = -12;
		p.k = 2 * (Math.random()*2-1)
		p.gotoAndStop("" + int(Std.random(2)+1));
		p.dx *= speed;
		p.dy *= speed;
		p.type = Tools.randomProbas(TYPE_PROBAS);
		switch( p.type ) {
		case 0:
			break;
		case 1:
			var c = new Color(p);
			c.setTransform({ ra : 42, rb : 71, ga : 100, gb : 25, ba : 52, bb : 0, aa : 100, ab : 0 });
			break;
		case 2:
			var c = new Color(p);
			c.setTransform({ ra : 98, rb : -26, ga : 74, gb : 5, ba : 100, bb : 86, aa : 100, ab : 0 });
			break;
		case 3:
			var c = new Color(p);
			c.setTransform({ ra : 100, rb : 61, ga : 86, gb : 25, ba : -16, bb : 0, aa : 100, ab : 0 });
			break;
		}
		pious.push(p);
		return true;
	}

	function genPart() {
		var part = downcast(dmanager.attach("smokePart",PLAN_PART));
		part._x = hx + (Std.random(8)+8);
		part._y = hero._y - (Std.random(10) + 2);
		part.gotoAndStop(""+(Std.random(3)+1));
		parts.push(part);

 	}

	function genPartCoussin() {
		var part = downcast(dmanager.attach("smokePart",PLAN_PART));
		part._x = hx + (Std.random(30)+20);
		part._y = hero._y - (Std.random(10) - 5);
		part._xscale = Std.random(20) + 60;
		part._yscale = part._yscale;
		part._alpha = 70;
		part.gotoAndStop(""+(Std.random(3)+1));
		parts.push(part);

 	}

	function genPartPlume(mc) {
		var part = downcast(dmanager.attach("plumePart",PLAN_PART));
		if( mc == hero )  {
			part._x = mc._x + (Std.random(10)+30);
			part._y = mc._y - (Std.random(10) + 25);
		} else {
			part._x = mc._x + (Std.random(10)-20);
			part._y = mc._y + (Std.random(10));
		}
		part.gotoAndPlay(string(Std.random(part._totalframes)+1));
		part._xscale = 100;
		part._yscale = part._yscale;
		part._alpha = 100;
		part.dx = -(Std.random(3)+3);
		part.dy = Std.random(4)+4;
		partsP.push(part);
 	}

	function genPartPlumeCaisse() {
		var part = downcast(dmanager.attach("plumePart",PLAN_PART));
		part._x = 230 + (Std.random(10)+30);
		part._y = 310 - (Std.random(25) + 10);
		part.gotoAndPlay(string(Std.random(part._totalframes)+1));
		part._xscale = 100;
		part._yscale = part._yscale;
		part._alpha = 100;
		part.dx = -(Std.random(3)+3);
		part.dy = Std.random(4)+4;
		partsP.push(part);
 	}
	
	function genPartBird() {
		var part = downcast(dmanager.attach("partBird",PLAN_PARTBIRD));
		part._x = Std.random(30) + 160;
		part._y = Std.random(20) + 200;
		part._xscale = Std.random(50) + 50;
		part._yscale = part._xscale;
		part.gotoAndPlay(""+(Std.random(5)+1));
		partsBird.push(part);
 	}

	function genSmokeBug() {
		var part = downcast(dmanager.attach("smokePart",PLAN_BG1));

		// smoke normale

		part._x = bug._x + (Std.random(150)-150);
		part._y = bug._y - (Std.random(20) +20);
		part._xscale = (Std.random(200)+200);
		part._yscale = part._xscale;
		part.dx = 3 * (Std.random(2)*2-1);
		part.gotoAndStop(""+(Std.random(3)+1));
		partsBug.push(part);
	}

	function genPartBlob(x,y) {
		var part = downcast(magicGate.manager.attach("partBlob",0));
		part._x = x;
		part._y = y - 20 - magicGate._y - magicGate.sub._y;
		partsBlob.push(part);

 	}

	function initShake(sy,sf){
		shakeY = sy;
		shakeFact = sf;
	}


	function shake(){
		var root = dmanager.getMC();
		shakeFact *= 0.8;
		shakeY = (shakeFact - root._y) * 1.5 + 0.5 * shakeY;
		root._y += shakeY;
	}

	function moveGate(){
		gateY = (BASEGATE - magicGate._y) * 0.002 + 1 * gateY;
		magicGate._y += gateY;
	}

	function moveBug(){
		cooldown--;
		if( cooldown <= 0 ) {
			bug._x -= 40;
			bug.gotoAndPlay("1");
			cooldown = 80;
		}
		if( bug._currentframe == 37 ) {
			var compt = Std.random(5)+5;
			for(var j = 0 ; j <= compt ; j ++){
				genSmokeBug();
			}
			initShake(0,1);
			if( bug._x <=330 && bug._x >=300 ) {
				var len = Std.random(10)+5;
				for(var i = 0 ; i <= len ; i++)
					genPartBird();
			}
		}
	}

	function main() {
		timer -= Timer.deltaT;
		if( timer <= 0 ) {
			if( !genPiou() )
				timer += Std.random(1000) / 2000;
			else {
				timer = Std.random(1500) + 500;
				timer *= Math.max((50 - (stats.$c + stats.$s))/50,0.1);
				timer /= 1000;
			}
		}

		var press = false;
		if( Key.isDown(Key.LEFT) ) {
			dir = -1;
			press = true;
		}
		if( Key.isDown(Key.RIGHT) ) {
			dir = 1;
			press = true;
		}

		if( Key.isDown(Key.SPACE) && KKApi.val(specialCount) > 0 ) {
			if( !pressSpace && !furie ) {
				specialCount = KKApi.const(KKApi.val(specialCount)-1);
				specialIcons.pop().play();
				var sh = dmanager.attach("shock",PLAN_PART);
				bg.gotoAndPlay("2");
				bg2.gotoAndPlay("2");
				bg3.gotoAndPlay("2");
				cl1.gotoAndPlay("2");
				cl2.gotoAndPlay("2");
				hero.gotoAndStop("3");
				furie = true;
				sh._x = hx;
				sh._y = hero._y;
				var i;
				for(i=0;i<pious.length;i++) {
					var p = pious[i];
					p.dy = -Math.abs(p.dy*1.5);
					p.dx += 1;
				}
				pressSpace = true;
			}
		} else
			pressSpace = false;
// 		if (hero.sub._currentframe >= 39){
// 			
// 			blackFade = false;
// 		}

		if( press && hspeed < MINSPEED )
			hspeed = MINSPEED;

		var special = hero._currentframe == 3;

		if( special ) {
			
			hspeed = 0;
			hanim += Timer.tmod;
			press = false;
		} else if( furie ) {
			furie = false;
			bg.gotoAndPlay("5");
			bg2.gotoAndPlay("5");
			bg3.gotoAndPlay("5");
			cl1.gotoAndPlay("5");
			cl2.gotoAndPlay("5");
			///
		}

		hspeed *= Math.pow(press?ACC:FRIC,Timer.tmod);
		if( !special && hspeed < 0.5 ) {
			hspeed = 0;
			hanim = 0;
			head_pos = 0;
		} else {
			hanim += hspeed / 8 * Timer.tmod;
			while( hanim >= hero.sub._totalframes ) {
				if( special ) {
					hero.gotoAndStop("2");
					break;
				}
				hanim -= (hero.sub._totalframes - INIT_FRAMES);
			}
			if( hspeed > MAXSPEED )
				hspeed = MAXSPEED;
		}


		shake();
		moveGate();
		if( bugProb == 0 ) {
			if( bug._x >= -20 )
				moveBug();
			else
				bug.removeMovieClip();
		}

		if( (hspeed > 4 && hero.sub._currentframe >=7 && hero.sub._currentframe <=9)  || (hspeed > 4 && hero.sub._currentframe >= 13 && hero.sub._currentframe <=15) )
			genPart();

		if( hero.sub.sub._currentframe == 4 ) {
			var i;
			for(i=0;i<=5;i++)
				genPartCoussin();
		}
		hx += dir * hspeed * Timer.tmod;
		if( hx < MINX )
			hx = MINX;
		else if( hx > MAXX )
			hx = MAXX;
		hero._x = hx;
		if( !special ) {
			hero.gotoAndStop((dir == 1)?"1":"2");
			var ang = Math.PI;
			var dist = 9999999;
			var i;
			for(i=0;i<pious.length;i++) {
				var p = pious[i];
				var dy = (hero._y - 45) - p._y;
				var dx = (hero._x - p._x);
				var d = dx*dx+dy*dy;
				if( d < dist ) {
					ang = Math.atan2(dy,dx);
					dist = d;
				}
			}
			var hframe = 60 * (Math.PI - ang) / Math.PI;
			if( hframe < 0 )
				hframe = 0;
			else if( hframe > 59 )
				hframe = 59;
			head_pos = head_pos * 0.95 + hframe * 0.05;			
			hero.sub.h.gotoAndStop(string(int(head_pos+1)));
		}
		hero.sub.hit._alpha = 0;
		hero.sub.gotoAndStop(string(int(hanim+1)));
		var i;
		var n = 0;
		var f = speed / REPEAT * Timer.tmod;
		var k = REPEAT;
		if( special && hero.sub._currentframe < 26 )			
			k = 0;
		for(n=0;n<k;n++) {
			for(i=0;i<pious.length;i++) {
				var p = pious[i];
				p._rotation += p.k;
				p._x += p.dx * f;
				p._y += p.dy * f;
				p.dy += GRAVITY * f;
				if( hero.sub.hit.hitTest(p._x,p._y,false) ) {
					hero.sub.sub.c.gotoAndPlay("2");
					p.dy *= -1;
					p.k = 2 * (Math.random()*2-1);
					p.gotoAndStop(string(Std.random(3)+1));
					var count = Std.random(2) + 1;
					for(var j=0; j <= count; j++ ) {
						genPartCoussin();
						genPartPlume(hero);
					}
					p.dx += (p._x - (hx + hero.sub._x + hero.sub.hit._x)) * 1.5 / hero.sub.hit._width;
					if( p.dx < 0 )
						p.dx = 0;
					p._y = hero._y + hero.sub._y + hero.sub.hit._y - 1;
				}
			}
		}
		if(caisse._currentframe == 18) {
			var countC = Std.random(3)+1;
			for(var j=0; j <= countC; j++ )
				genPartPlumeCaisse();			
		}
		for(i=0;i<pious.length;i++) {
			var p = pious[i];
			if( p._x > 285 )
				p._x = 285;
			if( p._x > SAVEX && p._y > SAVEY - 50 && p.dy > 0 ) {
				if( p._y > SAVEY ) {
					stats.$s++;
					if( p.type == 3 ) {
						specialCount = KKApi.const(KKApi.val(specialCount)+1);
						addSpecial();
					} else
						KKApi.addScore(POINTS[p.type]);
					var s = downcast(dmanager.attach("score",PLAN_INTERF));
					s.sub.gotoAndStop(string(p.type+1));
					caisse.gotoAndPlay("2");
					p.removeMovieClip();
					pious.splice(i--,1);
				} else
					dmanager.swap(p,PLAN_BG2);
			} else if( p._y >= 280 ) {
				stats.$l++;
				var sp = downcast(dmanager.attach("splatch",PLAN_PART));
				sp._x = p._x;
				sp._y = 295;
				var rf = downcast(dmanager.attach("redFade",PLAN_BG3));
				rf._x = 0;
				rf._y = 0;
				p.removeMovieClip();
				pious.splice(i--,1);
				var count = Std.random(10)+5;
				for(var j = 0; j <= count; j++)
					genPartPlume(sp);
				lifeCount = KKApi.const(KKApi.val(lifeCount)-1);
				lifeIcons.pop().play();
				if( KKApi.val(lifeCount) == 0 ) {
					timer = 1000;
					var j;
					for(j=0;j<pious.length;j++)
						pious[j].removeMovieClip();
					pious = null;
					KKApi.gameOver(stats);
				}
			}
		}

		//fumée hero run
		for(i=0;i<parts.length;i++) {
			var p = parts[i];
			p._y-= 0.5 + (Std.random(10) / 10);
			p._rotation -= Std.random(20);
			p._xscale -=5 + Std.random(90) / 10;
			p._yscale = p._xscale;
			p._alpha -= 5;
			if( p._xscale <=1 ) {
				p.removeMovieClip();
				parts.splice(i--,1);
			}
		}

		//plumes splatch
		for(i=0;i<partsP.length;i++) {
			var p = partsP[i];
			p.dx += 0.3;
			p.dy -= 0.45;
			if(p.dx >= 5)
				p.dx = 5;
			p._y -= p.dy;
			p._x -= p.dx;
			p._alpha -= int((Std.random(3)+1)/2);
			if( p._alpha <=1 ) {
				p.removeMovieClip();
				partsP.splice(i--,1);
			}
		}

		// oiseaux
		for(i=0;i<partsBird.length;i++) {
			var pb = partsBird[i];
			pb._x -= Std.random(3)+1;
			pb._y -= Std.random(3)+1;
			if(pb._x <= 0 || pb._y <= 0) {
				pb.removeMovieClip();
				partsBird.splice(i--,1);
			}
		}

		// fumée bestiole
		for(i=0;i<partsBug.length;i++) {
			var pb = partsBug[i];
			pb._xscale += 5;
			pb._yscale = pb._xscale;
			pb._alpha -= (Std.random(4)+2);
			pb._rotation += pb.dx;
			pb._y -= Std.random(1)+0.5;
			if(pb._alpha <= 0) {
				pb.removeMovieClip();
				pb.removeMovieClip();
				partsBug.splice(i--,1);
			}
		}
	}

}
