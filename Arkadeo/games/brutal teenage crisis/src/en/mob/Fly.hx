package en.mob;

import mt.MLib;
import mt.deepnight.Lib;
import mt.deepnight.slb.BSprite;

enum DashPhase {
	Wander;
	Charge;
	ChargeEnd;
	Dash;
}

class Fly extends Mob {
	var target		: {x:Float, y:Float};
	var fxDash		: BSprite;
	var phase		: DashPhase;
	var dashTarget	: {x:Float, y:Float};

	public function new() {
		super(0, 100);
		setPos( rseed.irange(0, Const.LWID), Const.LHEI+2 );

		type = MT_Fly;
		phase = Wander;
		gravity = 0;
		target = {x:0, y:0}
		dashTarget = {x:0, y:0}
		sprite.a.play("mob_e_fly").loop();
		speed *= 0.25;
		radius = 12;
		initLife(2);
		collides = false;
		sprite.setCenter(0.5, 0.7);

		fxDash = mode.tiles.get("focusFx");
		sprite.addChild(fxDash);
		fxDash.setCenter(0.5, 0.5);
		fxDash.y = -10;
		fxDash.blendMode = ADD;

		initDash();
		initTarget();
	}

	override function destroy() {
		super.destroy();
		fxDash.destroy();
	}

	override function loot() {
		dropGold(5);
	}

	override function onReachBottom() {
	}

	function initTarget() {
		var tcx = rseed.irange(1, Const.LWID-1);
		var tcy = rseed.irange(1, Const.LHEI-1);
		var d2 = Lib.distanceSqr(cx,cy, tcx,tcy);
		while ( d2<5*5 || d2>10*10 ) {
			tcx = rseed.irange(1, Const.LWID-1);
			tcy = rseed.irange(1, Const.LHEI-1);
			d2 = Lib.distanceSqr(cx,cy, tcx,tcy);
		}

		target.x = (tcx+0.5) * Const.GRID;
		target.y = (tcy+0.5) * Const.GRID;
	}

	override function onHeroAttack() {
		if( isDead() || killed )
			return;

		super.onHeroAttack();

		var h = mode.hero;
		if( !h.hasSuperPower() ){
			pushHero();

			var a = Math.atan2(h.yy-yy, h.xx-xx);
			dx = -Math.cos(a) * 0.5;
			dy = -Math.sin(a) * 0.5;
			if( phase==Charge || phase==ChargeEnd )
				initDash();

			initTarget();
		}
	}

	function pushHero() {
		var h = mode.hero;

		if( h.hasSuperPower() || h.isPhasing() )
			return;

		if( phase==ChargeEnd ) {
			// Charge hit
			var a = Math.atan2(dy,dx);
			var s = rseed.range(0.9, 1);
			h.dx = Math.cos(a)*s;
			h.dy = Math.sin(a)*s*2;
			fx.flashBang(0x0ACCF5, 0.4);
			h.cd.set("stun", Const.seconds( rseed.range(0.35, 0.45)));
		}
		else {
			// Normal hit
			var a = Math.atan2(h.yy-yy, h.xx-xx);
			var p = rseed.range(0.2, 0.3);
			h.dx = Math.cos(a)*p;
			//h.dy = (h.yy>yy+10 ? 1 : -1) * rseed.range(0.2, 0.3);
			h.dy = Math.sin(a)*p;
			if( h.dy>0 )
				h.dy = 0;
			h.cd.set("stun", Const.seconds( rseed.range(0.15, 0.25)));
		}

		h.frictX = h.frictY = 0.98;
		h.stopFall();
	}

	function initDash() {
		phase = Wander;
		fxDash.visible = false;
		cd.unset("charge");
		cd.set("dash", Const.seconds(rnd(4,7)));
		cd.onComplete("dash", onCharge);
	}

	function onCharge() {
		phase = Charge;
		fxDash.a.play("focusFx").loop();
		cd.set("charge", 30);
	}

	override function update() {
		if( isDead() || killed )
			return;

		if( mode.hero.hasLeft )
			initDash();

		switch( phase ) {
			case Wander :
				// Go to target
				if( !cd.has("stationary") ) {
					var a = Math.atan2(target.y-yy, target.x-xx);
					dx += Math.cos(a)*speed;
					dy += Math.sin(a)*speed;
				}

				// Reach target
				if( Lib.distanceSqr(xx,yy, target.x, target.y) < 30*30 ) {
					cd.set("stationary", Const.seconds( rseed.range(0.5, 1.5)) );
					initTarget();
				}

			case Charge :
				if( !cd.has("charge") ) {
					dashTarget = { x:mode.hero.xx, y:mode.hero.yy }
					cd.set("jit", 5);
					phase = ChargeEnd;
				}

			case ChargeEnd :
				if( !cd.has("jit") ) {
					fx.dashTrail(this, dashTarget.x, dashTarget.y);
					var a = Math.atan2(dashTarget.y-yy, dashTarget.x-xx);
					var s = 0.3;
					dx = Math.cos(a) * s;
					dy = Math.sin(a) * s;
					setPosPixel(dashTarget.x, dashTarget.y);
					fxDash.a.stop();
					cd.set("brake", 15);
					canBeHit = false;
					if( atDistance(mode.hero, 50) )
						pushHero();
					phase = Dash;
				}

			case Dash :
				if( !cd.has("brake") ) {
					canBeHit = true;
					initDash();
				}
		}

		fxDash.visible = phase==Charge || phase==ChargeEnd || phase==Dash;
		if( fxDash.visible )
			fxDash.scaleX = fxDash.scaleY = 2 + Math.cos(mode.time*0.3)*0.3;

		super.update();

		sprite.y+=Math.cos(mode.time*0.3)*4;
	}
}

