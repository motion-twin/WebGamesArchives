package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Halloween extends en.Client {
	var tang			: Float;

	public function new(cid:Int, ?r) {
		super(cid,r);

		tang = 0;
		hei = 140;
		wid = 80;
		scale*=0.75;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 0.75);

		//spr.a.registerStateAnim("monsterWeekEnderSleep", 1, isSleeping);
		spr.a.registerStateAnim("monsterBulb", 0);
		spr.a.applyStateAnims();
	}

	override function get_handY() return yy - 50;

	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb2, Assets.monsters2, "monsterBulb");
	}

	override function postUpdate() {
		super.postUpdate();

		spr.y-=20;

		if( isWalking() ) {
			tang += 0.01*dir;
			tang*=0.9;
		}
		else
			//if( isWaiting() || isDone() || isSleeping() )
				tang = Math.cos(time*0.1)*0.08;
			//else {
				//tang = Math.cos(time*0.7)*0.28;
			//}

		spr.rotation += (tang-spr.rotation)*0.3;
	}

}

