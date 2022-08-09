package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Custom extends en.Client {

	public function new(cid:Int, ?r) {
		super(cid,r);


		hei = 120;
		floating = false;

		spr.a.unsync();

		spr.a.registerStateAnim("monsterSlimeSleep", 2, isSleeping);
		spr.a.registerStateAnim("monsterSlimeWalk", 1, isWalking);
		spr.a.registerStateAnim("monsterSlimeIdle", 0);
		spr.a.applyStateAnims();
	}

	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb1, Assets.monsters1, "monsterSlimeIdle");
	}

}

