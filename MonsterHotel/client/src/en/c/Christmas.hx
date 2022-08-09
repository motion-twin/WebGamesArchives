package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Christmas extends en.Client {
	var tang			: Float;

	public function new(cid:Int, ?r) {
		super(cid,r);

		tang = 0;
		hei = 160;
		wid = 100;
		floating = false;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);

		spr.a.registerStateAnim("monsterSantaWalk", 2, isWalking);
		spr.a.registerStateAnim("monsterSantaSleep", 1, isSleeping);
		spr.a.registerStateAnim("monsterSantaIdle", 0);
		spr.a.applyStateAnims();
	}

	override function get_handX() return xx + dir*25;
	override function get_handY() return yy - 75;

	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb2, Assets.monsters2, "monsterSantaIdle");
	}

	override function postUpdate() {
		super.postUpdate();


		if( isWalking() ) {
			tang -= 0.01*dir;
			tang*=0.9;
		}
		else
			//if( isWaiting() || isDone() || isSleeping() )
				tang = Math.cos(time*0.05)*0.04;
			//else {
				//tang = Math.cos(time*0.7)*0.28;
			//}

		spr.scaleX = Assets.SCALE * dir * (scale + Math.sin(time*0.07)*0.01);
		spr.scaleY = Assets.SCALE * scale + Math.sin(time*0.08)*0.01;
		spr.rotation += (tang-spr.rotation)*0.3;
	}

}

