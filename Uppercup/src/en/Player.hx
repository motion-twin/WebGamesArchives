package en;

import Const;
import mt.MLib;
import mt.deepnight.Lib;
import flash.display.Sprite;
import flash.display.Bitmap;
import mt.deepnight.slb.BSprite;
import TeamInfos;

typedef Point = {
	var x : Float;
	var y : Float;
}

enum ShootMode {
	Full360;
	Restrict(baseAng:Float, range:Float, ?raise:Bool);
}

@:bitmap("assets/star.png") class GfxStar extends flash.display.BitmapData {}

class Player extends Entity {
	public static var ALL : Array<Player> = [];
	public static var ACTIVES : Array<Player> = [null,null];
	static var CLOSE_RANGE = 55;

	var body				: BSprite;
	var shirt				: BSprite;
	var shoes				: BSprite;
	var hair				: BSprite;
	var scale				: Float;

	public var reach		: Float;
	public var origin		: Point;
	public var precision	: Float;
	public var accel		: Float;
	public var speedMul		: Float;
	public var normalFrict	: Float;
	public var strength		: Int;
	var shootMode			: ShootMode;
	public var isGoal		: Bool;
	public var faults		: Int;
	public var faultSpr		: Null<BSprite>;
	public var starIcon		: Null<Bitmap>;

	public var teamInfos: TeamInfos;
	public var id		: Int;
	var anim			: {k:String, frame:Float, loop:Bool};
	var wasOnScreen		: Bool;

	public var dir			: Int;
	public var side			: Int;
	public var arrow		: Null<BSprite>;
	var halo				: Null<Bitmap>;
	var target				: Null<Point>;
	public var ang			: Float;
	public var seekingBall	: Bool;
	public var iaKickDelay	: Int;
	public var isSubstitute	: Bool;
	var isStar				: Bool;

	var battleRadius		: Float;
	var catchRadius			: Float;


	public function new(ti:TeamInfos) {
		super();

		wasOnScreen = false;
		ALL.push(this);
		teamInfos = ti;

		scale = 1;
		isStar = false;
		faults = 0;
		side = teamInfos.side;
		id = getMyTeam().length-1;
		ang = 0;
		dir = 1;
		isSubstitute = false;
		iaKickDelay = 0;
		speedMul = 1;
		catchRadius = 8;
		battleRadius = 12;
		normalFrict = frict = 0.85;
		colBounce = 0.3;
		zbounce = 0.2;
		shootMode = Full360;
		origin = {x:0, y:0}

		getMyTeam().push(this);

		// Halo
		if( side==1 && !game.isMulti() )
			initHalo();

		// Gears
		shirt = new BSprite(side==0 ? game.shirtA : game.shirtB);
		spr.addChild(shirt);
		shirt.setCenter(0.5, 0.5);

		shoes = new BSprite(game.tiles);
		spr.addChild(shoes);
		shoes.setCenter(0.5, 0.5);

		// Skin
		body = new BSprite( id%3==0 ? game.whiteGuys : game.blackGuys );
		//body = new BSprite(game.whiteGuys);
		body.setCenter(0.5, 0.5);
		spr.addChild(body);
		body.a.registerStateAnim("failSkin", 10, function() return isKnocked());
		body.a.registerStateAnim("sauteSkin", 4, function() return z>0);
		body.a.registerStateAnim("sprintSkin", 3, function() return MLib.fabs(dx)>0.2 || MLib.fabs(dy)>0.2);
		body.a.registerStateAnim("walkSkin", 2, function() return dx!=0 || dy!=0);
		body.a.registerStateAnim("moiSkin", 1, function() return !game.lowq && game.ball!=null && !hasBall() && game.ball.hasOwner() && game.ball.owner.side==side );
		body.a.registerStateAnim("idleSkin", 0);

		// Hair
		hair = new BSprite(game.tiles);
		spr.addChild(hair);
		hair.setPivotCoord(48,78);
		setHair(side==0 && !game.isMulti() ? id+1 : teamInfos.hairFrame);


		// Flèche de visée
		if( isPlayable() ) {
			arrow = game.tiles.get("arrow");
			game.sdm.add(arrow, Const.DP_BG2);
			arrow.setCenter(-0.1, 0.5);
			arrow.scaleX = arrow.scaleY = 0.5;
			arrow.visible = false;
		}

		setShadow(20,7);
		updateStats();
	}


	public function setHair(f) {
		hair.set("hairCuts", f);
	}


	public function addFault() {
		if( faults>=2 || cd.has("faultImmune") )
			return;

		cd.set("faultImmune", Const.seconds(1.5));
		faults++;
		if( faults==1 ) {
			faultSpr = game.tiles.get("cartonJaune");
			spr.addChild(faultSpr);
			faultSpr.alpha = 0;
		}

		if( faults==1 )
			game.tutorial.triggerById("yellowCard", this);

		if( faults>=2 )
			game.tutorial.triggerById("redCard", this);

		m.Crowd.ME.onFault(side, faults>=2);
		game.whistleFault(faults>=2);

		fx.fault(this);
		cd.set("forceFaultIndicator", Const.seconds(0.7));

		if( faults>=2 ) {
			if( faultSpr!=null ) {
				faultSpr.dispose();
				faultSpr = null;
			}
			redCard();
		}
	}

	public function redCard() {
		game.addStat("redCard");
		game.setPhase( RedCard(this, game.time + Const.seconds(3)) );
		game.viewport.focus = this;
		if( hasBall() )
			kickBall(0);

		fx.flashBang(0xFF0000, 0.3, 1000);
		fx.redCross(this);
		game.announce( Lang.Exclusion, 0xFF0000, "siffletCartonRouge" );
	}

	public function setSubstitute() {
		if( isSubstitute )
			return;

		fx.surprise(this);
		fx.say(this, "???");
		m.Global.SBANK.joueur_sac(1);
		isSubstitute = true;
		hair.set("hairCuts", 112);
	}


	public static function getTeam(side) {
		return ALL.filter( function(e) return e.side==side && !e.fl_destroyed );
	}

	public static function getGoal(side) {
		for(e in ALL )
			if( e.isGoal && e.side==side )
				return e;
		return null;
	}


	public static function getClosestFrom(side, cx:Float, cy:Float) {
		cx+=Const.FPADDING;
		cy+=Const.FPADDING;
		var best : Player = null;
		for( e in getTeam(side) )
			if( best==null || Lib.distanceSqr(cx,cy, e.cx,e.cy)<Lib.distanceSqr(cx,cy, best.cx,best.cy) )
				best = e;
		return best;
	}

	public static function getEngager(side) {
		var e = getGoal(side);
		if( e!=null && !e.fl_destroyed )
			return e;

		var team = getTeam(side);
		var best = team[0];
		var g = m.Game.ME.stadium.getGoalRectangle(side);
		var gx = g.x + g.w*0.5;
		var gy = g.y + g.h*0.5;
		for(e in team)
			if( Lib.distanceSqr(e.origin.x, e.origin.y, gx,gy) < Lib.distanceSqr(best.origin.x, best.origin.y, gx,gy) )
				best = e;
		return best;
	}


	public static function hasActive(side:Int) {
		return ACTIVES[side]!=null;
	}

	public static function getActive(side:Int) {
		return ACTIVES[side];
	}

	public static inline function noOneIsActive() {
		return ACTIVES[0]==null && ACTIVES[1]==null;
	}


	public function activate() {
		if( ACTIVES[side]!=null )
			ACTIVES[side].deactivate();

		ACTIVES[side] = this;
		cd.unset("autoKick");

		// Init angle
		switch( shootMode ) {
			case Full360 :
				//ang = rnd(0, 6.28);
				ang = game.ball.lastAng + 3.14;

			case Restrict(b,r, _) :
				ang = b + rnd(-r*0.5, r*0.5);
		}

		if( hasBall() ) {
			game.hud.setPassButton();
			arrow.set("arrow");
		}
		else {
			game.hud.setDefendButton();
			arrow.set("arrowTacle");
		}
		updateArrow();
	}

	public function deactivate() {
		if( ACTIVES[side]==this ) {
			ACTIVES[side] = null;
			arrow.visible = false;
		}
	}

	public static function deactivateCurrent(side) {
		if( ACTIVES[side]!=null )
			ACTIVES[side].deactivate();
	}

	public function isActive() {
		return ACTIVES[side] == this;
	}



	public function updateStats() {
		initSeed();

		isGoal = id==0 && ( side==0 || side==1 && !teamInfos.hasPerk(Perk._PNoGoal) );
		accel = 0.045;
		precision = rnd(0, 0.3);
		strength = 50;
		reach = isPlayable() ? 90 : 90;

		if( teamInfos.hasPerk(Perk._PSuperStrong) )
			strength = 99999;

		if( teamInfos.hasPerk(Perk._PWeak) )
			strength = -99999;

		if( game.stadium.hasWalls )
			reach += 60;

		if( side==0 && getOpponents().length==0 )
			reach += 30;

		if( isGoal ) {
			if( teamInfos.hasPerk(Perk._PBadGoal) )
				accel*=0.5;
			if( teamInfos.hasPerk(Perk._PAverageGoal) )
				accel*=0.6;
		}


		if( teamInfos.hasPerk(Perk._PSlow) )
			accel = 0.030;

		if( teamInfos.hasPerk(Perk._PSuperFast) )
			accel = isGoal ? 0.060 : 0.090;
		else if( teamInfos.hasPerk(Perk._PFast) )
			accel = isGoal ? 0.045 : 0.060;


		if( teamInfos.hasPerk(Perk._PStatic) )
			accel = 0.030;

		if( teamInfos.hasPerk(Perk._PHighRange) )
			reach += 90;
		else if( teamInfos.hasPerk(Perk._PMediumRange) )
			reach += 35;

		if( game.hasSnow() )
			accel*=0.8;


		scale = 1;
		if( teamInfos.hasPerk(_PSuperStrong) )
			scale = 1.35;
		if( teamInfos.hasPerk(_PWeak) )
			scale = rseed.range(0.72, 0.76);
		precision = 0.6;

		// Graphic updates
		if( isGoal && teamInfos.hasPerk(_PBadGoal) )
			setHair(114);

	}

	public static function countStars(side:Int) {
		return getTeam(side).filter( function(e) return e.isStar ).length;
	}

	public static function getPotentialStars(side:Int) {
		return getTeam(side).filter( function(e) return !e.isStar && !e.isGoal );
	}

	public function setStar() {
		if( isStar )
			return;
		isStar = true;
		starIcon = new Bitmap( new GfxStar(0,0) );
		spr.addChild(starIcon);
	}

	function isDefense() {
		return
			if( side==0 )
				origin.x < Const.GRID*(Const.FPADDING+Const.FWID*0.5);
			else
				origin.x > Const.GRID*(Const.FPADDING+Const.FWID*0.5);
	}


	function initHalo() {
		var col = side==0 ? 0x79FF00 : 0xFF0000;
		var r = side==0 ? 20 : 30;
		var a = side==0 ? 0.5 : 1;
		var b = 16;

		var s = new Sprite();
		var m = new flash.geom.Matrix();
		m.createGradientBox(r*2, r*2, 0);
		s.graphics.beginFill(col, a);
		s.graphics.drawEllipse(0,0,r*2,r*2*0.6);
		s.graphics.endFill();
		s.scaleY = 0.6;
		s.filters = [ new flash.filters.BlurFilter(b,b,2) ];

		halo = Lib.flatten(s, b, true);
		game.sdm.add(halo, Const.DP_BG2);
		halo.blendMode = ADD;
	}

	public override function toString() {
		return
			"Team"+side+" #"+id +
			" @"+Lib.prettyFloat(cx+xr)+","+Lib.prettyFloat(cy+yr) +
			" Orig="+Lib.prettyFloat(origin.x/Const.GRID)+","+Lib.prettyFloat(origin.y/Const.GRID);
	}

	override function unregister() {
		super.unregister();

		deactivate();
		ALL.remove(this);

		body.dispose();
		shirt.dispose();
		shoes.dispose();
		hair.dispose();

		if( starIcon!=null ) {
			starIcon.bitmapData.dispose();
			starIcon.bitmapData = null;
			starIcon.parent.removeChild(starIcon);
			starIcon = null;
		}

		if( faultSpr!=null )
			faultSpr.dispose();

		teamInfos = null;

		if( halo!=null ) {
			halo.bitmapData.dispose();
			halo.bitmapData = null;
			halo.parent.removeChild(halo);
		}

		if( arrow!=null )
			arrow.dispose();
	}


	inline function debug() {
		return id==0 && side==0;
	}

	public inline function getMyTeam() {
		return getTeam(side);
	}

	public inline function getOpponents() {
		return getTeam(side==0 ? 1 : 0);
	}

	public inline function isPlayable() {
		return game.isMulti() ? true : side==0;
	}

	public inline function isKnocked() {
		return cd.has("knock");
	}

	public function knock(fromX:Float, fromY:Float, ?pow=1.0) {
		var a = Math.atan2(yy-fromY, xx-fromX);
		if( teamInfos.hasPerk(_PKamikaze) && !cd.has("slipKnock") ) {
			cd.set("kamikaze", rnd(18, 25));
			cd.onComplete("kamikaze", function() explode(68));
		}

		if( isActive() && !hasBall() && game.ball.hasOwner() )
			game.ball.owner.cd.unset("waitKick");
		deactivate();

		clearTarget();
		if( arrow!=null )
			arrow.visible = false;
		cd.unset("animLock");

		var s = 0.4*pow;
		dx = Math.cos(a)*s;
		dy = Math.sin(a)*s;
		dir = dx<0 ? -1 : 1;
		cd.set("knock", Const.seconds(2));

		if( hasBall() )
			kickBall(a, rnd(0.5, 0.8), rnd(0.4, 0.8));
	}



	public function battle(e:Player) {
		if( isKnocked() || e.isKnocked() )
			return;

		if( side==e.side )
			return;

		fx.clash(this, e);

		if( isSubstitute && e.isSubstitute ) {
			knock(e.xx, e.yy);
			e.knock(xx, yy);
			return;
		}

		var winner;
		var loser;
		if( e.strength-strength>1000 || isSubstitute ) {
			winner = e;
			loser = this;
		}
		else if( strength-e.strength>1000 || e.isSubstitute ) {
			winner = this;
			loser = e;
		}
		else {
			var rlist = new mt.RandList();
			rlist.add(this, strength);
			rlist.add(e, e.strength);
			winner = rlist.draw(rseed.random);
			loser = winner!=this ? this : e;
		}

		m.Crowd.ME.onBattle(winner.side);

		if( winner.teamInfos.hasPerk(Perk._PSuperStrong) )
			fx.flashBang(0xFF0000, 0.5, 500);

		loser.knock(winner.xx, winner.yy);
		mt.flash.Sfx.playOne([
			m.Global.SBANK.joueur_contact1,
			m.Global.SBANK.joueur_contact2,
			m.Global.SBANK.joueur_contact3,
			m.Global.SBANK.joueur_contact4,
			m.Global.SBANK.joueur_contact5,
			m.Global.SBANK.joueur_contact6,
		], rnd(0.4, 0.6));
		if( winner.side==0 && winner.cd.has("faultEnabled") && !loser.teamInfos.hasPerk(_PNoFaults) )
			switch( game.getVariant() ) {
				case Normal :
					if( rseed.random(100)<50 )
						winner.addFault();

				case Hard, Epic :
					winner.addFault();
			}
	}





	public function takeBall() {
		if( !game.ball.loseElectricCounter() )
			return;

		setRestrictMode(false);
		cd.unset("autoKick");

		if( side==0 )
			game.tutorial.trigger(_PTuto3, 4);

		if( game.isPlaying() && isPlayable() )
			fx.surprise(this);

		if( game.ball.z>=9 )
			dz = 1;

		if( game.isShootOut() )
			game.endShootOut();

		// Free knock enemies around
		//for( e in getOpponents() )
			//if( distanceSqr(e)<=35*35 )
				//e.knock(xx,yy);

		m.Global.SBANK.joueur_reception(1);

		var pr = getPositionRatio();
		m.Crowd.ME.onBallTaken(side, pr.x, pr.y);

		game.resetCharge();
		game.onBallTaken(this);
		game.ball.takenBy(this);
		clearTarget();

		if( side==0 )
			flash.system.System.pauseForGCIfCollectionImminent(0.15);
		else
			flash.system.System.pauseForGCIfCollectionImminent(0.50);

		if( isStar )
			game.tutorial.triggerById("star", this);

		if( game.isPlaying() ) {
			if( game.isMulti() ) {
				activate();
				activateDefender(side==0 ? 1 : 0);
				cd.set("autoKick", Const.seconds(5));
				cd.onComplete("autoKick", function() {
					game.endCharge(side, true);
				});
			}
			else if( side==0 )
				activate();
			else if( side==1 && !isGoal )
				activateDefender(0);
		}


		switch(game.getVariant() ) {
			case Normal, Hard :

			case Epic :
				// Tacler
				//if( isPlayable() && game.isPlaying() )
					//chooseTacler();
		}


		if( !isPlayable() ) {
			if( isGoal || isStar )
				cd.set("waitKick", rnd(5,8));
			else
				prepareIaKick();
		}

		//if( game.isShootOut() )
			//game.nextShootOut();
	}

	public function prepareIaKick() {
		game.enemyBar.visible = true;
		if( teamInfos.hasPerk(_PSlowIaKick) )
			iaKickDelay = Const.seconds(99);
		else
			iaKickDelay = Const.seconds(5 - teamInfos.getSkillLevel()*2);

		game.iaKickPreview.alpha = 0;
		cd.set("waitKick", iaKickDelay);
	}


	public function activateDefender(dside) {
		var mates = getTeam(dside).map( function(p) return { p:p, score:0. } );
		var pr = getPositionRatio();

		for(m in mates) {
			m.score = -Lib.distance(cx,cy, m.p.cx, m.p.cy)*1.5;
			if( m.p.isGoal ) {
				if( pr.x<=0.25 && pr.y>=0.3 && pr.y<=0.6 )
					m.score+=10;
				else
					m.score+=2;
			}

			if( m.p.isKnocked() )
				m.score-=4;

			if( m.p.isSubstitute )
				m.score-=2;

			if( m.p.cx<cx && dside==0 )
				m.score+=2;

			if( m.p.cx>cx && dside==1 )
				m.score+=2;
		}

		if( mates.length==0 )
			iaKick();
		else {
			mates.sort( function(a,b) return -Reflect.compare(a.score, b.score) );
			var best = mates[0].p;
			best.activate();
			fx.pop(best.xx, best.yy, Lang.RetrieveBall, 0xFF0000);
		}
	}


	public function setRestrictMode(b:Bool) {
		var base = side==0 ? 0 : 3.14;
		var range = 3.14;
		shootMode = b ? Restrict(base, range) : Full360;
	}

	inline function getPositionQuality() {
		var r = getPositionRatio();
		return (1-Math.min(1, r.x/0.5)) * Math.min(1, 1-Math.abs(0.5-r.y)/0.5);
	}


	function getBestPassTarget() {
		var maxDist = Std.int(170 + teamInfos.getSkillLevel()*250);
		var targets = Lambda.array( Lambda.filter(getMyTeam(), function(p) {
			var d = distance(p);
			return p.cx<cx && d>=CLOSE_RANGE && d<maxDist;
		}) );

		if( targets.length>0 ) {
			targets.sort(function(p1,p2) return -Reflect.compare(p1.getPositionQuality(), p2.getPositionQuality()));
			return targets[0];
		}
		else
			return null;
	}



	function getKickDecision() {
		var skill = teamInfos.getSkillLevel();
		var pr = getPositionRatio();
		var kickRand = new mt.Rand(0);

		// Tir générique
		var a = 3.14 + kickRand.range(0, 0.4, true);
		var pow = kickRand.range(0.5, 0.7);
		var aerial = kickRand.range(0, 0.7);

		if( skill>=0.7 ) {
			a = Math.atan2(Const.FPADDING+Const.FHEI*0.5 - cy, -1-cx) + kickRand.range(0.10, 0.30, true);
			pow = kickRand.range(0.7, 0.9);
		}

		if( game.hasSnow() )
			aerial = kickRand.range(0.3, 0.7);

		// Moitié supérieure
		if( pr.y<0.4 )
			a-=0.7;

		// Moitié inférieure
		if( pr.y>0.6 )
			a+=0.7;

		if( isGoal ) {
			// Dégagement du gardien
			a = 3.14 + kickRand.range(0.2, 0.4, true);
			if( skill<=0.5 )
				pow = kickRand.range(0.7, 1.1);
			else if( skill<=0.75 )
				pow = kickRand.range(0.9, 1.3)
			else
				pow = kickRand.range(1.2, 1.5);
			aerial = kickRand.range(0.7, 1) + skill*0.2;
		}
		else {
			if( pr.x<=0.2 && pr.y<=0.3 ) {
				// Corner haut
				a = kickRand.range(0.7, 1.57);
			}
			else if( pr.x<=0.2 && pr.y>=0.7 ) {
				// Corner bas
				a = -kickRand.range(0.7, 1.57);
			}
			else if( game.isShootOut() || pr.x<=0.35 && pr.y>=0.30 && pr.y<=0.70 ) {
				// Tir au but !
				var r = game.stadium.getGoalRectangle(0);
				var pt = { x:(r.x+r.w)*Const.GRID, y:(r.y+r.h*0.5)*Const.GRID }
				a = Math.atan2(pt.y-yy, pt.x-xx);
				if( skill<=0.25 ) {
					pow = kickRand.range(0.4, 0.6);
					aerial = kickRand.range(0, 0.5);
					a += kickRand.range(0.2, 0.4, true);
				}
				else if( skill<=0.5 ) {
					pow = kickRand.range(0.6, 0.8);
					aerial = kickRand.range(0.1, 0.7);
					a += kickRand.range(0.1, 0.3, true);
				}
				else if( skill<=0.75 ) {
					pow = kickRand.range(0.6, 0.9);
					aerial = kickRand.random(100)<40 ? kickRand.range(0.2, 0.4) : kickRand.range(0.8, 1);
					a += kickRand.range(0.05, 0.25, true);
				}
				else {
					a += kickRand.range(0, 0.15, true);
					pow = 1;
					aerial = kickRand.range(0.6, 0.8);
				}

				// Lower aerial strength when close to the goal (avoid misses)
				if( MLib.iabs(cx-pt.x)<=150 )
					if( kickRand.random(100)<skill*95 )
						aerial*=0.5;
			}
			else {
				// Vise un allié
				var maxDist = Std.int(170 + skill*250);
				fx.radius(xx, yy, maxDist);
				var targets = Lambda.array( Lambda.filter(getMyTeam(), function(p) {
					var d = distance(p);
					return p.cx<cx && d>=CLOSE_RANGE && d<maxDist;
				}) );
				#if debug
				for(t in targets)
					fx.marker(t.xx, t.yy, 0x00BFFF);
				#end
				targets.sort(function(p1,p2) return -Reflect.compare(p1.getPositionQuality(), p2.getPositionQuality()));

				if( targets.length>0 ) {
					var p = targets[0];
					var pdist = distance(p);
					#if debug
					fx.marker(p.xx, p.yy);
					#end
					a = Math.atan2(p.yy-yy, p.xx-xx);
					pow = Math.min(1, pdist/300);
					// Lobe
					if( skill<=0.33 )
						aerial = kickRand.range(0, 1);
					else if( skill<=0.66 )
						aerial = kickRand.range(0.3, 1);
					else {
						if( game.hasSnow() )
							aerial = pdist<=160 ? kickRand.range(0.2, 0.3) : kickRand.range(0.5, 1);
						else
							aerial = pdist<=160 ? kickRand.range(0, 0.3) : kickRand.range(0.75, 1);
					}

					// Erreur de visée
					if( skill<=0.33 )
						a+=kickRand.range(0.25, 0.45, true);
					else if( skill<=0.66 )
						a+=kickRand.range(0.10, 0.30, true);
					else
						a+=0;
				}
			}
		}

		if( game.stadium.hasWalls )
			aerial = MLib.fmax(0.7, aerial);

		return {
			ang		: a,
			pow		: pow,
			aerial	: aerial,
		}
	}


	public function iaKick() {
		if( !game.isPlaying() )
			return;

		if( game.isCharging(0) )
			game.endCharge(0);

		deactivateCurrent(0);
		fx.radius(xx,yy, CLOSE_RANGE, 0xFF0000);

		// On empêche les voisins de bus de prendre le ballon...
		for(p in ALL)
			if( p!=this && p.side==1 && distance(p)<=CLOSE_RANGE )
				p.cd.set("catchLock",40);


		var decision = getKickDecision();
		kickBall(decision.ang, decision.pow, decision.aerial);

		// Dribble
		if( rseed.random(100)<80 ) {
			game.ball.makeUncatchable(0, Const.seconds(0.5));
			dz = 2.8;
		}
	}



	public function kickBall(a:Float, ?power=1.0, ?aerialPower=0.0) {
		if( !hasBall() )
			return;

		for(p in ALL)
			p.cd.unset("repositionLock");

		setRestrictMode(false);

		var b = game.ball;
		var s = 0.68; // 0.65
		b.dx = Math.cos(a)*s*power;
		b.dy = Math.sin(a)*s*power;
		//b.dz = 0.25 + aerialPower * 6.5;
		b.dz = 0.5 + aerialPower * 6.5;
		b.z = aerialPower*5;
		b.onKick();
		if( power>=0.6 )
			m.Global.SBANK.joueur_tir(power);
		else
			m.Global.SBANK.joueur_passe(power*power);

		game.fx.grassKick(xx,yy, a, 15);
		game.fx.hit(b.xx, b.yy);
		game.fx.kickLight(b.xx, b.yy, a, power);

		dir = b.dx<0 ? -1 : 1;
		dz = 1.8;
		dx = 0;

		body.a.play("shootSkin");

		deactivate();
		cd.set("stop", 20);
		game.tutorial.trigger(_PTuto1, 1);

		for( p in ALL )
			p.clearTarget();
	}

	public inline function hasBall() {
		return game.ball.owner==this;
	}

	public function clearTarget() {
		target = null;
	}

	public function setTarget(x:Float,y:Float, ?spd=1.0) {
		if( game.matchEnded() )
			return;
		if( game.hasSnow() && spd<0.5 )
			spd = 0.5;

		if( game.isPlaying() && isSubstitute )
			spd = 0.5;

		speedMul = spd;
		target = {x:x, y:y}
	}


	public inline function nearOrigin() {
		return mt.deepnight.Lib.distanceSqr(xx,yy, origin.x, origin.y)<=30*30;
	}

	public function setOrigin(x:Float, y:Float) {
		var ocx = Std.int(x/Const.GRID);
		var ocy = Std.int(y/Const.GRID);
		var oxr = (x-ocx*Const.GRID) / Const.GRID;
		var oyr = (y-ocy*Const.GRID) / Const.GRID;

		if( collides(ocx,ocy) )
			if( ocx<Const.FPADDING+Const.FWID*0.5 )
				ocx-=2;
			else
				ocx+=2;

		// Close right
		if( collides(ocx+1, ocx) || collides(ocx+1,ocx-1) || collides(ocx+1,ocx+1) )
			ocx-=2;
		// Far right
		if( collides(ocx+2, ocx) || collides(ocx+2,ocx-1) || collides(ocx+2,ocx+1) )
			ocx-=1;

		// Close left
		if( collides(ocx-1, ocx) || collides(ocx-1,ocx-1) || collides(ocx-1,ocx+1) )
			ocx+=2;
		// Far left
		if( collides(ocx-2, ocx) || collides(ocx-2,ocx-1) || collides(ocx-2,ocx+1) )
			ocx+=1;

		// Upper collision ?
		if( collides(ocx, ocx-1) || collides(ocx-1,ocx-1) || collides(ocx+1,ocx-1) )
			ocx++;

		// Bottom collision ?
		if( collides(ocx, ocx+1) || collides(ocx-1,ocx+1) || collides(ocx+1,ocx+1) )
			ocx--;

		x = (ocx+oxr) * Const.GRID;
		y = (ocy+oyr) * Const.GRID;

		//var d = 50;
		//var d2 = d*d;
		//for(o in Obstacle.ALL)
			//if( Lib.distanceSqr(x,y, o.xx,o.yy)<d2 ) {
				//var a = Math.atan2(y-o.yy, x-o.xx);
				//x = o.xx + Math.cos(a)*d;
				//y = o.yy + Math.sin(a)*d;
			//}

		origin.x = x;
		origin.y = y;
	}


	public function postRender() {
		if( !onScreen() )
			return;

		var g = body.groupName.substr(0, body.groupName.indexOf("Skin"));
		var fdata = body.lib.getFrameData(body.groupName, body.frame);
		var ac = body.a.getAnimCursor();

		// Shirt
		var k = g+"Shirt";
		var gearAnim = shirt.lib.getAnim(k);
		if( !shirt.is(k, gearAnim[ac]) )
			shirt.set( k, gearAnim[ac] );

		// Shoes
		gearAnim = game.tiles.getAnim(g+"Shoes");
		if( !shoes.is(k, gearAnim[ac]) )
			shoes.set( g+"Shoes", gearAnim[ac] );

		// Hair
		var fdata = game.tiles.getFrameData( g+"Hair", game.tiles.getAnim(g+"Hair")[ac] );
		hair.x = -fdata.realFrame.x;
		hair.y = -fdata.realFrame.y;
	}



	public function updateArrow() {
		if( arrow!=null ) {
			arrow.visible = isActive() && game.isPlaying();
			if( arrow.visible ) {
				arrow.rotation = mt.MLib.toDeg(ang);
				var d = hasBall() ? 15 : 10;
				arrow.x = spr.x + Math.cos(ang)*d;
				arrow.y = spr.y + Math.sin(ang)*d;
			}
		}
	}


	public function rotate() {
		#if fullControl
		return;
		#end

		#if debug
		ang = Math.atan2( game.root.mouseY-Const.HEI*0.5, game.root.mouseX-Const.WID*0.5 );
		#else

		var diff = switch( game.getVariant() ) {
			case Normal : game.oppTeam.getSkillLevel();
			case Hard, Epic : game.oppTeam.getSkillLevel();
		}
		diff = MLib.fclamp( diff, 0, 1 );
		var as = 0.11 + 0.07*diff  +  0.04*(1-precision);

		if( game.isMulti() )
			as = hasBall() ? 0.13 : 0.20;

		if( isSubstitute )
			as*=2;

		switch( shootMode ) {
			case Full360 :
				ang += as;

			case Restrict(base, range, raise) :
				if( raise==true ) {
					ang+=as;
					var d = base-ang;
					if( d>=Math.PI ) d-=Math.PI*2;
					if( Math.abs(d)>=range*0.5 ) {
						ang = base+range*0.5;
						shootMode = Restrict(base, range, !raise);
					}
				}
				else {
					ang-=as;
					var d = base-ang;
					if( d>=Math.PI ) d-=Math.PI*2;
					if( Math.abs(d)>=range*0.5 ) {
						ang = base-range*0.5;
						shootMode = Restrict(base, range, !raise);
					}
				}
		}
		#end
		var pi = Math.PI;
		while(ang>pi) ang-=pi*2;
		while(ang<-pi) ang+=pi*2;

		updateArrow();
	}



	public function canAct() {
		return isPlayable() && game.isPlaying() && isActive();
	}



	override public function update() {
		fl_collide = !game.isRepositionning();

		var isOnScreen = onScreen();
		var suspend = game.isSuspended();
		var b = game.ball;


		if( !suspend && !isKnocked() ) {
			// Tir de l'IA
			if( hasBall() && !isPlayable() && !cd.has("waitKick") && z==0 )
				iaKick();

			if( game.isPlaying() && b.free() && !cd.has("stop") ) { // TODO bug possible: isPlaying vs isRepositionning
				var d = mt.deepnight.Lib.distance(xx,yy, b.xx, b.yy);

				// Course après le ballon
				if( !teamInfos.hasPerk(_PStatic) ) {
					var r = reach * b.getLostReachFactor();
					if( d<=r ) {
						var anticip = if( d<=30 ) 20 else 120;

						var spd = d<=r && !cd.has("catchLock") ? 1 : 0.6;
						if( cd.has("defend") )
							spd = 1;

						setTarget(b.xx + b.dx*anticip, b.yy + b.dy*anticip, spd);
						seekingBall = d<=r;
					}
					else {
						seekingBall = false;
						dx*=0.8;
						dy*=0.8;
					}
				}

				// Attrape le ballon
				if( d<=catchRadius*3 && game.isPlaying() && !cd.has("catchLock") && (isGoal || !b.cd.has("uncatchable"+side)) )
					if( Math.abs(z-b.z)<=15 ) {
						if( b.tryToCatch(this) ) {
							// Fail test
							var fail = 0;
							var bs = b.getActualSpeed();
							if( bs>=0.35 ) {
								if( dz!=0 )
									fail = isGoal ? 13 : 40;
								if( isGoal && teamInfos.hasPerk(_PBadGoal) )
									fail = 70;
								if( isGoal && teamInfos.hasPerk(_PAverageGoal) )
									fail = 35;
							}
							if( rseed.random(100)<fail ) {
								// Failed!
								fx.surprise(this);
								dz = rnd(2.5, 4);
								cd.set("catchLock", Const.seconds(1));
							}
							else {
								// Success
								if( z>0 ) {
									if( isGoal )
										fx.flashBang(side==0 ? 0x0080FF : 0xFF0000, 0.3, 1000);
									fx.airGrab(this);
									m.Global.SBANK.balle_rebond(1);
								}
								if( isGoal )
									m.Crowd.ME.onGoalInterception(side);
								takeBall();
								cd.set("catchLock", Const.seconds(1.2));
							}
						}
					}

				// Saut pour rattraper la balle
				var jd = b.getActualSpeed()>=0.45 ? catchRadius*4 : catchRadius*2;
				if( !hasBall() && d<=jd && game.isPlaying() && MLib.fabs(z-b.z)>15 && z==0 ) {
					var chances = isGoal ? 100 : 15;

					if( isGoal && teamInfos.hasPerk(_PBadGoal) )
						chances = 0;

					if( isGoal && teamInfos.hasPerk(_PAverageGoal) )
						chances = 40;

					if( !cd.has("jumpDecision") && rseed.random(100)<chances ) {
						cd.set("jumpDecision", Const.seconds(1));
						if( isPlayable() )
							dz = isGoal ? (rseed.random(100)<20 ? 6 : 3.5) : 3.5;
						else {
							dz = isGoal ? 5 : 3;
							if( isGoal && teamInfos.hasPerk(_PBadGoal) )
								dz = 2;
							if( isGoal && teamInfos.hasPerk(_PAverageGoal) )
								dz = rseed.random(100)<40 ? 2 : 4;
						}
						dx*=0.7;
						dy*=0.7;
					}
				}
			}


			// Retour à la position normale
			if( game.isRepositionning() || b.hasOwner() && !hasBall() && !isActive() && !cd.has("defend") && !cd.has("repositionLock") )
				setTarget(origin.x, origin.y, game.isPlaying() ? 0.6 : 1.6);

			if( isActive() && !game.isRepositionning() )
				clearTarget();

			// Mouvement vers la cible
			if( target!=null && z<=0 ) {
				var d = mt.deepnight.Lib.distance(xx,yy, target.x,target.y);
				if( d<=5 ) {
					clearTarget();
					dx*=0.7;
					dy*=0.7;
				}
				else {
					var a = Math.atan2(target.y-yy, target.x-xx);
					dx += Math.cos(a)*accel*speedMul;
					dy += Math.sin(a)*accel*speedMul;
					// Water slipping
					if( game.isPlaying() && !cd.has("slip") && rseed.random(100)<20 && getActualSpeed()>=0.22 && game.stadium.checkWaterPerlin(xx,yy) ) {
						cd.set("slip", Const.seconds(10));
						fx.slip(this);
						var d = Const.seconds(1);
						cd.set("slipKnock", d);
						knock(xx-dx, yy-dy, rnd(0.8, 1));
						cd.set("knock", d);
					}
				}
			}

			// Repoussement
			if( game.isPlaying() ) {
				var r = battleRadius;
				for( p in ALL ) {
					if( p==this )
						continue;

					var d = mt.deepnight.Lib.distanceSqr(xx, yy, p.xx, p.yy);
					var maxDist = battleRadius + p.battleRadius;
					if( d<=maxDist*maxDist ) {
						var pow = isKnocked() || p.isKnocked() || p.side==side ? 0.16 : 0.4;
						var a = Math.atan2(p.yy-yy, p.xx-xx);
						var midX = xx + (p.xx-xx)*0.5;
						var midY = yy + (p.yy-yy)*0.5;
						dx+= -Math.cos(a)*pow;
						dy+= -Math.sin(a)*pow;
						p.dx+= Math.cos(a)*pow;
						p.dy+= Math.sin(a)*pow;
						battle(p);
					}
				}
			}

		}

		// Direction
		if( isOnScreen && z==0 && !cd.has("stop") ) {
			if( !cd.has("dirLock") )
				if( dx>0 )
					dir = 1;
				if( dx<0 )
					dir = -1;
			if( isSubstitute )
				cd.set("dirLock", 20);
			if( dx==0 && dy==0 && !isKnocked() ) {
				if( hasBall() )
					dir = side==0 ? 1 : -1; // le porteur regarde le but
				else
					if( game.ball.xx<xx )
						dir = -1;
					if( game.ball.xx>xx )
						dir = 1;
			}
			if( isGoal ) {
				var prx = getPositionRatio().x;
				if( side==0 && prx>=-0.03 && prx<=0.15 )
					dir = 1;
				if( side==1 && prx>=0.85 && prx<=1.03 )
					dir = -1;
			}
		}
		spr.scaleX = dir*scale;
		spr.scaleY = scale;


		if( game.isPlaying() && hasBall() )
			frict = isGoal ? 0.7 : 0.8;
		else
			frict = isKnocked() ? (game.hasSnow() ? 0.8 : 0.94) : normalFrict;

		if( side==0 && game.stadium.checkGluePerlin(xx,yy) ) {
			if( game.isPlaying() ) {
				var s = getActualSpeed();
				frict = s>=0.10 ? 0.2 : 0.6;
			}
			else
				frict = 0.8;
		}


		if( isActive() && !b.hasOwner() )
			deactivate();


		super.update();

		var isOnScreen = onScreen();


		// Gestion du radius
		//if( radiusBmp!=null ) {
			//radiusBmp.x = spr.x - radiusBmp.width*0.5;
			//radiusBmp.y = spr.y - radiusBmp.height*0.5;
			//radiusBmp.visible = game.canDoAction() && !hasBall();
		//}

		// Snow holes
		if( isOnScreen && ( dx!=0 || dy!=0 ) && z<=4 && game.hasSnow() /*&& (game.time+uid)%3==0*/ )
			game.stadium.snowHole(xx,yy);

		updateArrow();

		// Fault indicator
		if( faultSpr!=null ) {
			if( isActive() && faults>0 || cd.has("forceFaultIndicator") ) {
				faultSpr.visible = true;
				if( faultSpr.alpha<1 )
					faultSpr.alpha+=0.1;
				faultSpr.x = -faultSpr.width*0.5;
				faultSpr.y = -faultSpr.height - 35;
			}
			if( !isActive() ) {
				if( faultSpr.visible )
					faultSpr.alpha-=0.05;
				if( faultSpr.alpha<=0 ) {
					faultSpr.alpha = 0;
					faultSpr.visible = false;
				}
			}
		}

		// Star indicator
		if( starIcon!=null ) {
			starIcon.x = -starIcon.width*0.5;
			starIcon.y = -starIcon.height - 35;
		}

		if( cd.has("electric") )
			fx.electricityRemains(xx, yy);

		var vis = !isKnocked() || cd.has("slipKnock") ? true : game.time%3!=0;
		shadow.visible = spr.visible = vis && isOnScreen;
		if( !spr.visible )
			spr.a.pause();
		else
			spr.a.resume();

		// IA Kick arrow
		if( side==1 && hasBall() ) {
			if( game.iaKickPreview.alpha<1 )
				game.iaKickPreview.alpha+=0.1;
			game.iaKickPreview.x = xx;
			game.iaKickPreview.y = yy;
			if( game.time%2==0 ) {
				var decision = getKickDecision();
				game.iaKickPreview.rotation = MLib.toDeg(decision.ang);
			}
		}

		// Animation optimisations
		if( game.lowq && body.a.isPlayingAnim("idleSkin") )
			body.a.setGeneralSpeed(0.0000001);
		else {
			body.a.setGeneralSpeed(1);
			if( wasOnScreen && !isOnScreen )
				body.a.stopWithoutStateAnims();

			if( !wasOnScreen && isOnScreen )
				body.a.stop();
		}


		// Halo
		if( halo!=null ) {
			halo.x = xx - halo.width*0.5;
			halo.y = yy - halo.height*0.5;

			var ta = 1.0;
			if( !b.hasOwner() || !game.isPlaying() )
				ta = 0;
			else
				if( b.owner.side==0 )
					ta = 1;
				else
					ta = isActive() || hasBall() ? 1 : 0;

			if( halo.alpha<ta )
				halo.alpha+=0.1;
			if( halo.alpha>ta )
				halo.alpha-=0.1;
			halo.visible = spr.visible && halo.alpha>0;
		}

		wasOnScreen = isOnScreen;
	}

}
