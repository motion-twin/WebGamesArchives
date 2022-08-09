package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Rich extends en.Client {
	public function new(cid:Int, ?r) {
		super(cid,r);

		hei = 130;
		floating = false;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);

		spr.a.registerStateAnim("monsterRichSleep", 2, function() return isSleeping() );
		spr.a.registerStateAnim("monsterRichWalk", 1, function() return isWalking() );
		spr.a.registerStateAnim("monsterRichIdle", 0);
		spr.a.applyStateAnims();
	}

	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb1, Assets.monsters1, "monsterRichIdle");
	}


	override function postUpdate() {
		super.postUpdate();
		spr.scaleY += Math.cos(time*0.07)*0.02;
	}

	override function update() {
		super.update();
	}

}

