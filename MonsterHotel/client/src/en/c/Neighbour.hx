package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Neighbour extends en.Client {

	public function new(cid:Int, ?r) {
		super(cid,r);

		hei = 125;
		floating = true;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);

		spr.a.registerStateAnim("monsterEyeSleep", 1, function() return isSleeping() );
		spr.a.registerStateAnim("monsterEyeIdle", 0);
		spr.a.applyStateAnims();
	}

	override function get_handY() return yy - hei*0.35;

	override function postUpdate() {
		super.postUpdate();
		spr.rotation = isWalking() ? 0 : Math.cos(offset + time*0.1)*0.15;
	}

	override function update() {
		super.update();

		spr.rotation = Math.cos(offset + time*0.1)*0.1;
	}

}

