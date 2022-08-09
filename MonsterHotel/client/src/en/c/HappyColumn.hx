package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class HappyColumn extends en.Client {
	public function new(cid:Int, ?r) {
		super(cid,r);

		hei = 150;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 0.9);

		spr.a.registerStateAnim("monsterEmpathySleep", 1, function() return isSleeping());
		spr.a.registerStateAnim("monsterEmpathyIdle", 0);
		spr.a.applyStateAnims();
	}


	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb1, Assets.monsters1, "monsterEmpathyIdle");
	}

	override function postUpdate() {
		super.postUpdate();
		spr.rotation = Math.cos(time*0.1)*0.05;
	}


	override function update() {
		super.update();
	}

}

