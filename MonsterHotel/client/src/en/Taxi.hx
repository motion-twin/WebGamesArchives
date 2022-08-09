package en;

import mt.MLib;
import b.*;
import com.*;
import com.Protocol;
import h2d.SpriteBatch;

import mt.deepnight.slb.*;

class Taxi extends Entity {
	var tx			: Float;
	var sx			: Float;
	var sy			: Float;
	var light0		: BatchElement;
	var light1		: BatchElement;

	public function new(?dx=0.) {
		super();

		var r = game.hotelRender.getLobby();
		tx = r.getQueueEndX()-150 + dx;
		xx = game.hotelRender.right;
		dir = -1;
		baseSpeed*=2;
		wid = 90;
		hei = 160;
		physics = false;
		sx = 1.4;
		sy = 1;
		frict = 0.9;

		light0 = Assets.tiles.addBatchElement(Game.ME.addSb, "fxTaxiLight",0, 0.5, 0.5);
		light0.scale(2.5*sx);


		light1 = Assets.tiles.addBatchElement(Game.ME.addSb, "fxTaxiLight",0, 0.5, 0.5);
		light1.scale(2*sx);

		cd.set("leave", Const.seconds(2));
		cd.onComplete("leave", function() {
			var s = Assets.SBANK.carLeave(0.4);
			s.setPanning(0);
			s.pan(0.6,1500);
		});

		var s = Assets.SBANK.carArrive(0.6);
		s.setPanning(1);
		s.pan(0,1500);
	}

	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.tilesFrontSb, Assets.tiles, "taxi");
	}

	function toString() return 'Taxi';


	override function unregister() {
		super.unregister();

		light0.remove();
		light0 = null;

		light1.remove();
		light1 = null;
	}

	override function postUpdate() {
		// No super call
		spr.x = Std.int(xx);
		spr.y = Std.int(yy);

		spr.rotation = -MLib.fabs(dx*0.0005)  *dir;
		spr.y -= MLib.fabs(dx*0.05);

		light0.setPos( spr.x+100*dir, spr.y-90 );
		light1.setPos( spr.x+160*dir, spr.y-90 );
		light0.scaleX = MLib.fabs(light0.scaleX) * MLib.sign(spr.scaleX);
		light1.scaleX = MLib.fabs(light1.scaleX) * MLib.sign(spr.scaleX);
	}


	override function update() {
		var d = MLib.fabs(tx-xx);
		if( cd.has("leave") )
			dx = (tx-xx)*0.15;
		else {
			// Leaving
			dir = 1;
			dx+=4;
		}

		if( yy<0 )
			dy+=1;
		else {
			yy = 0;
			dy = 0;
		}

		if( d>100 )
			game.fx.carSmoke(xx+100, yy-30);

		if( d>200 && yy==0 )
			dy = -rnd(5,10);


		if( d<=600 && !cd.hasSet("brake", 9999) )
			sx = sy = 1;

		if( !cd.has("leave") && xx>=game.hotelRender.right+100 )
			destroy();

		sx = dir*MLib.fabs(sx);

		spr.scaleX += (sx-spr.scaleX)*0.2;
		spr.scaleY += (sy-spr.scaleY)*0.15;

		super.update();
	}
}

