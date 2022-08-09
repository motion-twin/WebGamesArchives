package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Gifter extends en.Client {
	public function new(cid:Int, ?r) {
		super(cid,r);

		hei = 130;
		floating = false;

		spr.a.unsync();
		spr.a.setGeneralSpeed(0.75);

		spr.a.registerStateAnim("monsterMaruSleep", 2, function() return isSleeping() );
		spr.a.registerStateAnim("monsterMaruWalk", 1, function() return isWalking() || cd.has("persistWalk") );
		spr.a.registerStateAnim("monsterMaruIdle", 0);
		spr.a.onEachLoop = function() {
			cd.unset("persistWalk");
		}
		spr.a.applyStateAnims();
	}


	override function postUpdate() {
		super.postUpdate();
		spr.rotation = isWalking() ? 0 : Math.cos(offset + time*0.1)*0.06;
	}

	override function update() {
		super.update();

		if( isWalking() )
			cd.set("persistWalk", 30);

		spr.rotation = Math.cos(offset + time*0.1)*0.1;
	}

}

