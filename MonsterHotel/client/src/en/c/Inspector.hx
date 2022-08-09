package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Inspector extends en.Client {
	var delayer			: mt.Delayer;

	public function new(cid:Int, ?r) {
		super(cid,r);

		delayer = new mt.Delayer(Const.FPS);
		hei = 150;
		floating = false;
		scale = 0.78;

		cd.set("anim", 30);

		spr.a.registerStateAnim("monsterInspectorSleep", 2, function() return isSleeping() );
		spr.a.registerStateAnim("monsterInspectorWalk", 1, function() return isWalking() );
		spr.a.registerStateAnim("monsterInspectorIdle", 0);
		spr.a.applyStateAnims();
	}


	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb1, Assets.monsters1, "monsterInspectorIdle");
	}


	override function postUpdate() {
		super.postUpdate();
		if( isWalking() )
			spr.scaleY += Math.cos(time*0.3)*0.035;
	}

	override function update() {
		super.update();
		delayer.update();

		if( time%2==0 )
			game.fx.inspector(this);

		// Reset anim
		if( !spr.a.isPlayingAnim("monsterInspectorIdle") && !spr.a.isPlayingAnim("monsterInspectorWalk") )
			if( isWalking() || isSleeping() )
				spr.a.stop();

		if( !isSleeping() ) {
			// Writing
			if( !cd.has("anim") && !isWalking() && !cd.has("write") ) {
				var d = Const.seconds( rnd(1,3) );
				cd.set("wait", d);
				cd.set("write", d + Const.seconds(rnd(2,4)));
				cd.set("anim", d + Const.seconds(rnd(1,3)));
				spr.a.play("monsterInspectorWrite").chainAndLoop("monsterInspectorWriting");
				delayer.addFrameBased( function() {
					spr.a.play("monsterInspectorStopWrite");
				}, d-spr.lib.getAnimDuration("monsterInspectorStopWrite"));
			}

			// Look around
			if( !cd.has("anim") && !isWalking() && !cd.has("look") ) {
				var d = Const.seconds( rnd(0.4, 1.2) );
				cd.set("look", d + Const.seconds(rnd(0.3,2)));
				cd.set("wait", d);
				cd.set("anim", d + Const.seconds(rnd(0.5,2)));
				var all = ["A", "B", "C"];
				var id = all[ Std.random(all.length) ];
				spr.a.play("monsterInspectorTrans"+id, 2).chainAndLoop("monsterInspectorInspect"+id);
				delayer.addFrameBased( function() spr.a.play("monsterInspectorTrans"+id, 2), d-2 );
				delayer.addFrameBased( function() spr.a.stop(), d );
			}
		}
	}

}

