package en.c;

import com.Protocol;
import mt.MLib;
import b.*;
import com.*;

import mt.deepnight.slb.*;

class Emitter extends en.Client {
	var liquid			: h2d.SpriteBatch.BatchElement;
	public function new(cid:Int, ?r) {
		super(cid,r);

		hei = 150;
		floating = false;

		spr.a.unsync();
		spr.setCenterRatio(0.5, 1);

		spr.a.registerStateAnim("monsterFormolSleep", 2, function() return isSleeping() );
		spr.a.registerStateAnim("monsterFormolIdle", 0);
		spr.a.applyStateAnims();
	}


	override function refreshEmitIcon() {
		super.refreshEmitIcon();

		if( liquid!=null ) {
			liquid.remove();
			liquid = null;
		}

		if( sclient.emit==null )
			return;

		var k = switch( sclient.emit ) {
			case Noise : "Noise";
			case Odor : "Odor";
			case Heat : "Heat";
			case Cold : "Cold";
			case SunLight : "Heat"; // TODO
		}
		if( k!=null ) {
			liquid = Assets.monsters0.addBatchElement(game.monstersSb0, "liquid"+k, 0, 0.5,1);
			liquid.visible = false;
		}
	}

	override function postUpdate() {
		super.postUpdate();

		spr.rotation += (( isWalking() ? -dir*0.15 : Math.cos(offset + time*0.1)*0.04 ) - spr.rotation )*0.2;

		if( liquid!=null ) {
			liquid.visible = true;
			liquid.width = 55;
			liquid.height = 108 + Math.cos( time*(isWalking()?0.3:0.07) )*4;
			liquid.alpha = spr.alpha*0.7;
			liquid.scaleX *= spr.scaleX;
			liquid.scaleY *= spr.scaleY;
			if( Assets.SCALE != 1 ){
				liquid.scaleX*=1/Assets.SCALE;
				liquid.scaleY*=1/Assets.SCALE;
			}
			liquid.x = spr.x + Math.cos(spr.rotation-1.57)*35;
			liquid.y = spr.y + Math.sin(spr.rotation-1.57)*35;
			liquid.rotation = spr.rotation;
		}
	}

	override function unregister() {
		super.unregister();

		if( liquid!=null ) {
			liquid.remove();
			liquid = null;
		}
	}

	override function update() {
		super.update();
	}

}

