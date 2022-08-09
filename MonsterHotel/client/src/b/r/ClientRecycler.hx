package b.r;

import com.Protocol;
import com.SRoom;
import mt.MLib;
import mt.deepnight.slb.*;
import b.Room;

class ClientRecycler extends b.Room {
	var bg			: h2d.SpriteBatch.BatchElement;
	var mixer		: HSpriteBE;
	var cm			: mt.deepnight.Cinematic;

	public function new(x,y) {
		super(x,y);
		cm = new mt.deepnight.Cinematic(Const.FPS);
	}


	override function onClientUse(c:en.Client) {
		super.onClientUse(c);

		c.spr.visible = false;
		c.goToRoomTemporarily(this);
		c.setPos(globalLeft+mixer.x, globalBottom);

		// Client
		var client = c.spr.clone();
		client.setScale( c.scale*0.85 );
		client.setCenterRatio(0.5, 1);
		client.setPos(mixer.x, mixer.y-100);
		client.rotation = 0;
		client.visible = true;
		client.alpha = 1;
		//client.x = mixer.x;
		//client.y = mixer.y - 100;

		// Bubble
		//var wrapper = new h2d.Sprite();
		//Game.ME.scroller.add(wrapper, Const.DP_CTX_UI);
//
		//var p = 5;
		//var bg = Assets.tiles.getH2dBitmap("uiDialBox", wrapper);
		//var arrow = Assets.tiles.getH2dBitmap("uiDialArrow", 0.5, 0, wrapper);
//
		//var tf = new h2d.Text(Assets.fontTiny, wrapper);
		//tf.text = Lang.t._("Hey, that's not my bedroom!");
		//tf.scale(0.8/Game.ME.totalScale);
		//tf.filter = true;
		//tf.x = tf.y = p;
		//tf.maxWidth = 200;
		//tf.textColor = 0x35316C;
//
		//bg.width = Std.int( tf.width*tf.scaleX + p*2 );
		//bg.height = Std.int( tf.height*tf.scaleY + p*2 );
		//arrow.x = bg.width*0.5;
		//arrow.y = bg.height;
//
		//wrapper.x = Std.int( globalLeft + client.x-wrapper.width*0.5 );
		//wrapper.y = Std.int( globalTop + client.y-wrapper.height-140 );
		//wrapper.visible = false;


		var s = c.scale;
		function _blend() {
			Assets.SBANK.recycle(1);
			var t = tw.create(client.y, mixer.y-40, 2000);
			t.onUpdateT = function(t) {
				client.x = mixer.x + rnd(0,8,true);
				client.y += rnd(0,2,true);
				client.setScale( s-t*0.5 );
				Game.ME.fx.blender(mixer.x+20, mixer.y-65, this);
				mixer.rotation = rnd(0, 0.04, true);
			}
			t.onEnd = function() {
				mixer.rotation = 0;
				client.dispose();
				client = null;
			}
		}

		cm.create({
			200;
			//wrapper.visible = true;
			600;
			//tw.create(wrapper.y, wrapper.y+40, 2000);
			//delayer.add( function() {
				//wrapper.dispose();
				//wrapper = null;
			//}, 3000 );
			_blend();
		});
	}

	override function updateGiftPositions(?m) {
		super.updateGiftPositions(100);
		for(e in gifts)
			e.tx+=190;
	}



	override function clearContent() {
		super.clearContent();

		bg = null;

		if( mixer!=null ) {
			mixer.dispose();
			mixer = null;
		}
	}

	override function renderContent() {
		super.renderContent();

		mixer = Assets.tiles.hbe_get(Game.ME.tilesFrontSb, "roomRecycleGrinder");
		mixer.setCenterRatio(0.5, 1);
		mixer.visible = false;
	}

	override function renderWall() {
		super.renderWall();
		wall.tile = Assets.rooms.getTile("roomRecycle");
	}


	override function onDispose() {
		super.onDispose();

		bg = null;
		mixer = null;

		cm.destroy();
		cm = null;
	}

	override function update() {
		super.update();

		cm.update();

		setBarWorking();

		mixer.visible = true;
		mixer.x = globalLeft + Std.int(wid*0.32);
		if( isWorking() ) {
			if( mixer!=null )
				mixer.y = globalBottom - rnd(0,3);

			//if( time%5==0 )
				//Game.ME.fx.refine(this);
		}
		else
			mixer.y = globalBottom;
	}
}
