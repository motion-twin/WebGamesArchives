package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class GemSpawner extends en.Client {
	public function new(cid:Int, ?r) {
		super(cid,r);

		wid = 130;
		hei = 170;
		floating = false;
		baseSpeed*=1.2;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);

		spr.a.registerStateAnim("monsterRoosterSleep", 3, function() return isSleeping() );
		spr.a.registerStateAnim("monsterRoosterWalk", 2, function() return isWalking() );
		spr.a.registerStateAnim("monsterRoosterPond", 1, function() return cd.has("dropping") );
		spr.a.registerStateAnim("monsterRoosterIdle", 0);
		spr.a.applyStateAnims();
	}

	override function get_handX() return xx+dir*20;
	override function get_handY() return yy-hei*0.25;

	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb2, Assets.monsters2, "monsterRoosterIdle");
	}

	override function onSpecialAction() {
		cd.set("dropping", Const.seconds(2));
		cd.set("wait", cd.get("dropping"));

		var gem = Assets.tiles.getH2dBitmap("moneyGem", 0.5,0.5, true);
		game.scroller.add(gem, Const.DP_ROOM_BATCH);
		gem.x = xx;
		gem.y = yy-60;
		gem.scale(1.9);

		var d = 0;
		game.createChildProcess(
			function(p) {
				if( destroyAsked ) {
					p.destroy();
					return;
				}

				dir = xx>room.wid*0.2 ? 1 : -1;
				//iaGoto(room.wid*0.6, 1, true);

				gem.x = xx - (10 + d*1.10)*dir;
				gem.y = yy-60+rnd(0,2,true);
				gem.rotation = -(1.7+0.007*d)*dir;

				d++;

				if( !cd.has("dropping") ) {
					dx = dir*20;
					Assets.SBANK.chicken(1);
					p.destroy();
				}
			},
			function(p) {
				gem.dispose();
			}
		);
	}

	override function canBeDragged() {
		return super.canBeDragged() && !cd.has("dropping");
	}

	override function postUpdate() {
		super.postUpdate();
		spr.scaleX += Math.cos(time*0.17)*0.02;
		spr.scaleY += Math.sin(time*0.20)*0.02;

		if( cd.has("dropping") ) {
			spr.rotation = rnd(0, 0.03, true);
			spr.x+=rnd(0,2,true);
		}
	}


	override function update() {
		super.update();

		if( cd.has("dropping") )
			game.fx.droppingGem(this);

		//if( cd.has("dropping") && !cd.has("feather") ) {
			//cd.set("feather", rnd(4, 10));
			//game.fx.droppingGem(this);
		//}

		if( !cd.has("dropping") && cd.has("wait") && !cd.has("pick") && !isSleeping() ) {
			cd.set("pick", Const.seconds(rnd(0.7, 2.5)));
			spr.a.play("monsterRoosterPicore");
		}
	}

}

