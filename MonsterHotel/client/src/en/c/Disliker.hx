package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Disliker extends en.Client {
	public function new(cid:Int, ?r) {
		super(cid,r);

		hei = 110;
		floating = false;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);

		//spr.a.registerStateAnim("monsterPearSleep", 2, function() return isSleeping() );
		spr.a.registerStateAnim("monsterPearWalk", 1, function() return isWalking() );
		spr.a.registerStateAnim("monsterPearIdle", 0);
		spr.a.onEachLoop = function() {
			cd.unset("persistWalk");
		}
		spr.a.applyStateAnims();
	}


	override function get_handY() return yy - hei*0.35;

	override function postUpdate() {
		super.postUpdate();
		//spr.rotation = isWalking() ? 0 : Math.cos(offset + time*0.1)*0.15;
	}

	override function update() {
		super.update();

		if( isWalking() )
			cd.set("persistWalk", 30);

		//spr.rotation = Math.cos(offset + time*0.1)*0.1;
	}

}

