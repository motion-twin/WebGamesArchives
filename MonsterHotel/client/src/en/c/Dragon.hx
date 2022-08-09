package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Dragon extends en.Client {
	public function new(cid:Int, ?r) {
		super(cid,r);

		hei = 150;
		floating = false;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);

		spr.a.registerStateAnim("monsterPyroSleep", 2, function() return isSleeping() );
		spr.a.registerStateAnim("monsterPyroWalk", 1, function() return isWalking() );
		spr.a.registerStateAnim("monsterPyroIdle", 0);
		spr.a.applyStateAnims();
	}

	override function get_handX() return xx+dir*15;

	override function postUpdate() {
		super.postUpdate();
	}

	override function update() {
		super.update();
	}

}

