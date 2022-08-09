package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Spawnling extends en.Client {

	public function new(cid:Int, ?r) {
		super(cid,r);

		wid = 90;
		hei = 80;
		scale = 0.6;
		floating = false;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);
		spr.a.registerStateAnim("monsterSlimeSleep", 2, isSleeping);
		spr.a.registerStateAnim("monsterSlimeWalk", 1, isWalking);
		spr.a.registerStateAnim("monsterSlimeIdle", 0);
		spr.a.applyStateAnims();

		spr.color = new h3d.Vector();
		spr.color.setColor( mt.deepnight.Color.addAlphaF(0xFFD33C), 1 );
	}

	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb1, Assets.monsters1, "monsterSlimeIdle");
	}


	override function get_handY() return yy - hei*0.25;
}

