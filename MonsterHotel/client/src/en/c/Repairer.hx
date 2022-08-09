package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Repairer extends en.Client {
	var tang			: Float;

	public function new(cid:Int, ?r) {
		super(cid,r);

		tang = 0;
		hei = 130;
		wid = 80;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 0.25);

		spr.a.registerStateAnim("monsterCarefullSleep", 1, function() return isSleeping());
		spr.a.registerStateAnim("monsterCarefullIdle", 0);
		spr.a.applyStateAnims();
	}

	override function get_handY() return yy + 120;

	override function postUpdate() {
		super.postUpdate();

		spr.y-=150;

		if( isWalking() ) {
			tang += 0.01*dir;
			tang*=0.9;
		}
		else
			if( isWaiting() || isDone() || isSleeping() )
				tang = Math.cos(time*0.1)*0.08;
			else {
				if( time%3==0 )
					game.fx.repairerSmoke(this);
				tang = Math.cos(time*0.7)*0.28;
			}

		//spr.scaleX = MLib.fabs(spr.scaleX);
		spr.rotation += (tang-spr.rotation)*0.3;
	}

}

