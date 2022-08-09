package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Vampire extends en.Client {
	var tang			: Float;

	public function new(cid:Int, ?r) {
		super(cid,r);

		tang = 0;
		hei = 150;

		spr.a.registerStateAnim("spectralSwordSleep", 1, isSleeping);
		spr.a.registerStateAnim("spectralSwordIdle", 0);
		spr.a.applyStateAnims();
	}

	override function get_handX() return xx  + dir*25;
	override function get_handY() return yy - hei*0.45;

	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb1, Assets.monsters1, "spectralSwordIdle");
	}


	override function postUpdate() {
		super.postUpdate();

		tang = Math.cos(time*0.1)*0.06;

		if( isWalking() )
			tang -= 0.1*dir;

		spr.scaleX = MLib.fabs(spr.scaleX);
		spr.rotation += (tang-spr.rotation)*0.3;
	}

}

