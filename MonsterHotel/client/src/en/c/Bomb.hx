package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Bomb extends en.Client {
	var tang			: Float;
	var exploding		: Bool;

	public function new(cid:Int, ?r) {
		super(cid,r);

		tang = 0;
		hei = 90;
		floating = false;
		exploding = false;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);

		spr.a.registerStateAnim("monsterBombExplode", 3, function() return exploding);
		spr.a.registerStateAnim("monsterBombSleep", 2, function() return isSleeping());
		spr.a.registerStateAnim("monsterBombWalk", 1, function() return isWalking());
		spr.a.registerStateAnim("monsterBombIdle", 0);
		spr.a.onEachLoop = function() {
			cd.unset("persistWalk");
		}
		spr.a.applyStateAnims();
	}

	override function postUpdate() {
		super.postUpdate();

		tang = Math.cos(time*0.1)*0.06;
		if( isWalking() )
			tang += 0.1*dir;
		spr.rotation += (tang-spr.rotation)*0.3;

		if( exploding ) {
			spr.x+=rnd(0,5,true);
			spr.y-=rnd(0,5);
			spr.rotation += rnd(0,0.1,true);
		}
	}


	override function update() {
		exploding = shotel.hasTask( InternalClientSpecialAction(id) );

		super.update();

		if( exploding ) {
			cd.set("wait", Const.seconds(3));

			if( !cd.hasSet("explodeWarn", 30 + Const.FPS*com.GameData.EXPLOSION_WARNING/1000) ) {
				clearBubbles();
				say( Lang.t._("I'm gonna EXPLODE!!!") );
			}

			if( time%10==0 )
				game.fx.bombWarning(this);
		}

		if( isWalking() )
			cd.set("persistWalk", 10);
	}

}

