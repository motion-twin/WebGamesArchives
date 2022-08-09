package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Plant extends en.Client {
	public function new(cid:Int, ?r) {
		super(cid,r);

		hei = 150;
		floating = false;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);

		spr.a.registerStateAnim("monsterPlantSleep", 2, function() return isSleeping() );
		spr.a.registerStateAnim("monsterPlantWalk", 1, function() return isWalking() || cd.has("persistWalk") );
		spr.a.registerStateAnim("monsterPlantIdle", 0);
		spr.a.onEachLoop = function() {
			cd.unset("persistWalk");
		}
		spr.a.applyStateAnims();
	}


	override function postUpdate() {
		super.postUpdate();
		spr.rotation = isWalking() ? 0 : Math.cos(offset + time*0.1)*0.1;
	}

	override function update() {
		super.update();

		if( isWalking() )
			cd.set("persistWalk", 30);

		spr.rotation = Math.cos(offset + time*0.1)*0.1;
	}

}

