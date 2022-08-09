package en;

import mt.MLib;
import mt.deepnight.Lib;
import mt.deepnight.slb.BSprite;
import flash.ui.Keyboard;
import flash.display.Sprite;
import flash.display.BlendMode;
#if debug
import mt.flash.Key;
#end

class Hero extends Entity {
	static var ATTACKS = ["atk_a", "atk_b", "atk_c", "atk_d"];
	static var HAIR_ATTACH = mt.deepnight.Color.addAlphaF(0x00bdff);
	static var CHAIN_ATTACH = mt.deepnight.Color.addAlphaF(0x18fff7);
	//static var CHAIN_POINTS : Hash<Array<{x:Int, y:Int}>> = new Hash();

	public var credits			: Int;
	var goingDown				: Bool;
	var hair					: BSprite;
	var ball					: ChainBall;
	var lastAttack				: Null<String>;
	var leftOrRightKey			: Bool;
	public var hasLeft			: Bool;
	var keyHistory				: Array<UInt>;

	public function new() {
		super();
		keyHistory = [0];
		credits = 1;
		speed*=1.2;
		goingDown = false;
		leftOrRightKey = false;
		radius = 20;
		weight = 10;
		dir = 1;
		hasLeft = false;

		// Place
		setPos(Std.int(Const.LWID*0.5), -5);
		sprite.set("idle");

		sprite.a.registerStateAnim("fall", 4, function() return !stable && !cd.has("attackAnim") && dy>=0);
		sprite.a.registerStateAnim("hover", 3, function() return !stable && !cd.has("attackAnim") && dy>=-0.2);
		sprite.a.registerStateAnim("raise", 2, function() return !stable && !cd.has("attackAnim"));
		sprite.a.registerStateAnim("run", 1, function() return stable && leftOrRightKey);
		sprite.a.registerStateAnim("idle", 0, function() return true);

		mode.dm.add(sprite, Const.DP_HERO);

		hair = mode.tiles.getAndPlay("couette");
		mode.dm.add(hair, Const.DP_HERO);
		hair.setCenter(0.8, 0.5);

		ball = new ChainBall(this);
	}

	public function leaveGameArea() {
		hasLeft = true;
		cy = -600;
	}

	public function setCredits(n) {
		credits = n;
		mode.hud.refresh();
	}

	public function loseCredit() {
		credits--;
		mode.skill = 0;
		fx.flashBang(0xFF0F0F, 1);
		mode.hud.loseCreditFx();
		mode.hud.refresh();

		for(e in en.mob.Walker.ALL) {
			e.ignoreFloors(1);
			e.hit(xx,yy, 1);
		}

		if( credits<=0 )
			onDie();
	}

	override function destroy() {
		super.destroy();
		ball.destroy();
	}

	override function onReachBottom() {
		super.onReachBottom();
		leaveGameArea();
		fx.bottomDeathHero(xx);
		mode.onHeroDeath();
	}

	override function onDie() {
		super.onDie();
		fx.heroDeath(this);
		mode.onHeroDeath();
		leaveGameArea();
		endPhase();
	}

	override function onLand() {
		goingDown = false;

		mode.cine.signal("heroLand");

		if( dy>=0.25 )
			fx.spriteFx("fx_land", xx, yy+12);

		super.onLand();
	}

	function attack(e:Mob) {
		// Anim de slash
		var slash = ATTACKS[rseed.random(ATTACKS.length)];
		while( slash==lastAttack )
			slash = ATTACKS[rseed.random(ATTACKS.length)];
		lastAttack = slash;

		var s = mode.tiles.getAndPlay(slash, 1, true);
		mode.dm.add(s, Const.DP_FX);
		s.setCenter(0.5, 0.5);
		s.x = xx + dir*15;
		s.y = yy - 25;
		s.alpha = rnd(0.6, 1);
		s.scaleX = dir;
		s.filters = [ new flash.filters.GlowFilter(0xF07800,0.8, 16,16) ];
		s.blendMode = BlendMode.ADD;

		sprite.a.play("atk");
		cd.set("attackAnim", mode.tiles.getAnimDuration("atk"));
		dir = e.xx<xx ? -1 : 1;

		// Light fx
		var c = getCenter();
		var ce = e.getCenter();
		fx.light(e.xx, e.yy);
		fx.hit( ce.x+0.1*(c.x-ce.x), ce.y+0.1*(c.y-ce.y), 2 );
		fx.backHit(this, e);

		// Super power
		var dmg = hasSuperPower() ? 5 : 1;
		if( dy>=0.30 ) {
			fx.slam(xx, yy);
			if( !e.slamImmune )
				e.ignoreFloors(1);
			dmg+=2;
		}

		// Damage
		e.onHeroAttack();
		e.hit(xx,yy, dmg);
	}

	public inline function hasSuperPower() {
		return cd.has("superPower");
	}

	function onHitMob(e:Mob) {
		if( cd.has("shield") )
			return;

		cd.set("shield", 10);
		e.cd.set("stun", 15);
		hit(e.xx, e.yy, 1);
	}


	function checkKeyCombo(k:UInt) {
		if( keyHistory[keyHistory.length-1]!=0 )
			return false;

		var i = keyHistory.length-2;
		var gap = 1;
		var press = 0;
		while( i>0 ) {
			if( press>0 && keyHistory[i]!=k )
				break;

			if( keyHistory[i]==0 )
				gap++;
			else if( keyHistory[i]!=k )
				gap = 9999;
			else
				press++;
			i--;
		}
		return press<=5 && gap<=5;
	}


	function phaseOut() {
		if( isPhasing() )
			return;

		sprite.blendMode = ADD;
		sprite.alpha = 0.4;
		fx.phaseOut(this);
		cd.set("phaseLock", Const.PHASE_CD);
		cd.set("phase", Const.PHASE_DURATION);
		mode.tw.terminate(mode.phaseMask);
		mode.phaseMask.visible = true;
		mode.phaseMask.alpha = 0;
		mode.tw.create(mode.phaseMask, "alpha", 1, 300);

		cd.set("phaseMask", cd.get("phase")-Const.seconds(0.3));
		cd.onComplete("phaseMask", endPhase);
	}

	function endPhase() {
		if( !isPhasing() )
			return;

		sprite.alpha = 1;
		sprite.blendMode = NORMAL;
		cd.unset("phase");
		cd.unset("phaseMask");

		mode.tw.terminate(mode.phaseMask);
		mode.tw.create(mode.phaseMask, "alpha", 0, 600).onEnd = function() {
			mode.phaseMask.visible = false;
		};
	}


	public inline function isPhasing() {
		return cd.has("phase");
	}


	override function update() {
		#if debug
		Key.update();
		//if( Key.isToggled(Key.D) ) {
			//for( e in en.mob.Lock.ALL )
				//e.hit(0,0,9999);
		//}
		#end

		var canControl = !hasLeft && !cd.has("stun");
		if( canControl )
			frictX = frictY = Const.FRICTION;

		var left = canControl && api.AKApi.isDown(Keyboard.LEFT);
		var right = canControl && api.AKApi.isDown(Keyboard.RIGHT);
		var up = canControl && api.AKApi.isDown(Keyboard.UP);
		var down = canControl && api.AKApi.isDown(Keyboard.DOWN);
		var special = canControl && api.AKApi.isDown(Keyboard.SPACE);

		// Phasing
		if( special ) {
			if( !cd.has("phaseKey") ) {
				cd.set("phaseKey", 9999);
				if( isPhasing() )
					endPhase();
				else if( !cd.has("phaseLock") )
					phaseOut();
			}
		}
		else
			cd.unset("phaseKey");

		// Detect key combos
		var dash = false;
		if( !cd.has("dashRun") ) {
			if( left )
				dash = checkKeyCombo(Keyboard.LEFT);

			if( right )
				dash = checkKeyCombo(Keyboard.RIGHT);

			if( dash )
				cd.set("dashRun", Const.seconds(0.5));
		}
		if( left )
			keyHistory.push(Keyboard.LEFT);
		else if( right )
			keyHistory.push(Keyboard.RIGHT);
		else
			keyHistory.push(0);

		if( keyHistory.length>60 )
			keyHistory.splice(0,30);


		// Course gauche
		var s = speed * (stable ? 1 : 0.7);
		if( left ) {
			if( stable && !cd.has("dashFx") && MLib.fabs(dx)<=0.1 ) {
				var s = fx.spriteFx("fx_dash", xx + 40, yy+8);
				s.scaleX *= -1;
			}
			cd.set("dashFx", 10);

			if( dash ) {
				dx = -0.75;
				dy*=0.2;
				sprite.a.stop();
				fx.heroDash(this);
			}
			else
				dx -= s;
		}

		// Course droite
		if( !left && right ) {
			if( stable && !cd.has("dashFx") && MLib.fabs(dx)<=0.1 )
				fx.spriteFx("fx_dash", xx - 40, yy+8);
			cd.set("dashFx", 10);

			if( dash ) {
				dx = 0.75;
				dy*=0.2;
				sprite.a.stop();
				fx.heroDash(this);
			}
			else
				dx += s;
		}

		// Direction
		if( !cd.has("attackAnim") ) {
			var old = dir;
			if( dx>0 )	dir = 1;
			if( dx<0 )	dir = -1;
			// Dash fx
			if( dir!=old && sprite.a.isPlayingAnim("skid") ) {
				var s = fx.spriteFx("fx_dash", xx - dir*40, yy+8);
				s.scaleX = dir;
				sprite.a.stop();
			}
		}

		leftOrRightKey = left || right;

		// Freinage
		if( !left && !right && stable && !cd.has("stun") ) {
			if( sprite.a.isPlayingAnim("run") )
				sprite.a.play("skid");
			dx*=0.6;
		}

		// Anim dérapage
		if( sprite.a.isPlayingAnim("run") ) {
			if( dir==1 && left && !right )
				sprite.a.play("skid");
			if( dir==-1 && !left && right )
				sprite.a.play("skid");
		}


		// Descend
		if( down && getFloor()>0 && stable ) {
			stable = false;
			dx *= 0.2;
			dy = -0.4;
			ignoreFloors(1);
			goingDown = true;
		}

		// Anim de saut
		//if( !stable && !cd.has("attackAnim") ) {
			//if( dy>=0 )
				//sprite.playAnim("fall");
			//else if( dy>=-0.2 )
				//sprite.setGroup("hover");
			//else
				//sprite.setGroup("raise");
		//}


		// Saut
		if( up && !stable && cd.has("jumpExtend") ) {
			// Extension
			dy -= 0.30;
			stable = false;
		}
		if( up && stable ) {
			// Base
			dy -= 0.55;
			stable = false;
			cd.set("jumpExtend", 3);

			var s = mode.tiles.getAndPlay("fx_jump", 1, true);
			mode.dm.add(s, Const.DP_FX);
			s.setCenter(0.5, 1);
			s.alpha = 0.5;
			s.x = xx;
			s.y = yy + 8;
			s.blendMode = BlendMode.ADD;
		}


		// Collisions mobs (repel)
		if( !cd.has("stun") && !isPhasing() ) {
			var center = getCenter();
			for( e in Mob.ALL )
				if( e.canBeHit && Math.abs(cx-e.cx)<=2 && Math.abs(cy-e.cy)<=2 ) {
					var ec = e.getCenter();
					var dist = Math.sqrt( (ec.x-center.x)*(ec.x-center.x) + (ec.y-center.y)*(ec.y-center.y) );
					if( dist <= radius+e.radius ) {
						if( !e.cd.hasSet("attacked", rnd(3,5)) )
							attack(e);

						var ang = Math.atan2(ec.y-center.y, ec.x-center.x);
						var force = 0.05; // 0.25
						if( !hasSuperPower() ) {
							if( !cd.has("stun") ) {
								dx = 0;
								if( !stable )
									dy = -0.1;
							}
							var wratio = e.weight / (e.weight+weight);
							if( wratio>=0.9 ) wratio = 1;
							dx -= Math.cos(ang) * wratio * force;
							dy -= Math.sin(ang) * wratio * force;
						}
						var wratio = weight / (e.weight+weight);
						if( wratio<=0.1 ) wratio = 0;
						e.dx += Math.cos(ang) * wratio * force;
						e.dy += Math.sin(ang) * wratio * force;
					}
				}
		}

		super.update();

		// Anim super power
		if( hasSuperPower() && !cd.hasSet("powerFx", 2) )
			fx.superPower(this);

		var bd = sprite.getBitmapData();

		// Point attache cheveux
		var r = bd.getColorBoundsRect(0xffFFFFFF, HAIR_ATTACH, true);
		if( r.width>0 ) {
			hair.visible = true;
			hair.x = xx + dir * ( r.x - sprite.width*0.5 );
			hair.y = yy + r.y - sprite.height;
			hair.scaleX = sprite.scaleX;
		}
		else
			hair.visible = false;

		// Point attache morgenstern
		var r = bd.getColorBoundsRect(0xffFFFFFF, CHAIN_ATTACH, true);
		ball.setAttach(r.x, r.y);

		//if( cd.has("attackAnim") || r.x==0 && r.y==0 )
			//ball.hide();
		//else
			//ball.show();
		if( r.x==0 && r.y==0 )
			ball.hide();
		else
			ball.show();

		if( isPhasing() )
			fx.phaseSpark();
	}
}


