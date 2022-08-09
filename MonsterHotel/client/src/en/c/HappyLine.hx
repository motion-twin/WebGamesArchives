package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class HappyLine extends en.Client {
	public function new(cid:Int, ?r) {
		super(cid,r);

		hei = 150;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);

		spr.a.registerStateAnim("ghostMaskSleep", 1, function() return isSleeping());
		spr.a.registerStateAnim("ghostMaskIdle", 0);
		spr.a.applyStateAnims();
	}


	override function get_handX() return xx+dir*55;


	override function update() {
		super.update();
	}

}

