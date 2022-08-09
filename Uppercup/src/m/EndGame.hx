package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import mt.deepnight.Color;
import mt.deepnight.mui.Window;
import mt.deepnight.Lib;
import mt.deepnight.FParticle;
import mt.deepnight.Tweenie;
import mt.deepnight.slb.*;
import mt.flash.Sfx;
import mt.MLib;
import mt.Metrics;
import ui.*;
import Const;

class EndGame extends MenuBase {
	var bg2				: Bitmap;
	var creditBmps		: Array<Bitmap>;
	var credits			: Array<String>;
	var cm				: mt.deepnight.Cinematic;
	var loop			: Sfx;
	var button			: Button;

	public function new() {
		super();
		credits = [];
		creditBmps = [];

		loop = Global.SBANK.public_loop();
		loop.playLoopOnChannel(Crowd.CHANNEL);

		Global.SBANK.public_but().playOnChannel(Crowd.CHANNEL);

		var s = new Sprite();
		var m = new flash.geom.Matrix();
		m.createGradientBox(bg.bitmapData.width, bg.bitmapData.height, MLib.PI/2);
		s.graphics.beginGradientFill(LINEAR, [0xFFFF80,0xFF6600,0x9A0E0E], [1,1,0.2], [0,80,255], m);
		s.graphics.drawRect(0,0,bg.bitmapData.width, bg.bitmapData.height);
		bg2 = Lib.flatten(bg);
		root.addChildAt(bg2, bg.parent.getChildIndex(bg)+1);
		var bd = bg2.bitmapData;
		bd.draw(s, new flash.geom.ColorTransform(1,1,1,0.7), BlendMode.OVERLAY);
		bd.applyFilter(bd, bd.rect, pt0, Color.getContrastFilter(0.3));

		cm = new mt.deepnight.Cinematic(Const.FPS);

		button = new SmallMenuButton(wrapper, Lang.Continue, onContinue);

		startCredits();

		onResize();
		var sendEvent = false;
		switch( Global.ME.variant ) {
			case Normal :
				if( ! playerCookie.data.wonNormal ) {
					playerCookie.data.wonNormal = true;
					playerCookie.save();
					sendEvent = true;
				}
			case Hard :
				if( ! playerCookie.data.wonHard ) {
					playerCookie.data.wonHard = true;
					playerCookie.save();
					sendEvent = true;
				}
			case Epic :
				if( ! playerCookie.data.wonEpic ) {
					playerCookie.data.wonEpic = true;
					playerCookie.save();
					sendEvent = true;
				}
		}
		if( sendEvent )
			Ga.event("play", "winGame", Std.string(Global.ME.variant));
	}

	function startCredits() {
		cm.create({
			showCredit( Lang.Credits1 ) > end;
			Global.SBANK.public_content1().playOnChannel(Crowd.CHANNEL);

			showCredit( Lang.Credits2 ) > end;
			Global.SBANK.public_content3().playOnChannel(Crowd.CHANNEL);

			showCredit( Lang.Credits3 ) > end;
			Global.SBANK.public_content2().playOnChannel(Crowd.CHANNEL);

			showCredit( Lang.Credits4 ) > end;
			Global.SBANK.public_corne().playOnChannel(Crowd.CHANNEL);
			2500;
			startCredits();
		});

	}


	override function unregister() {
		super.unregister();

		cm.destroy();

		while( MenuEntity.ALL.length>0 )
			MenuEntity.ALL[0].destroy();

		for( bmp in creditBmps ) {
			bmp.parent.removeChild(bmp);
			bmp.bitmapData.dispose();
			bmp.bitmapData = null;
		}
		creditBmps = null;

		bg2.bitmapData.dispose(); bg2.bitmapData = null;
	}

	//override function onActivate() {
		//super.onActivate();
		//if( loop!=null )
			//loop.playLoop();
	//}
	//override function onDeactivate() {
		//super.onDeactivate();
		//if( loop!=null )
			//loop.stop();
	//}


	function showCredit(str:String) {
		var tf = Global.ME.createField(str,FBig,true);
		tf.textColor = 0xFFFFB7;
		tf.filters = [
			new flash.filters.DropShadowFilter(1,90, 0xFF7900,1, 0,0),
			new flash.filters.GlowFilter(0x711A00,1, 2,2,6),
			//new flash.filters.GlowFilter(0xFF6000,0.5, 16,16,1),
		];
		var bmp = Lib.flatten(tf, 8);
		wrapper.addChild(bmp);
		bmp.bitmapData = Lib.scaleBitmap(bmp.bitmapData, 2, true);
		creditBmps.push(bmp);

		bmp.x = Std.int( getWidth()*0.5-bmp.width*0.5 );
		bmp.y = Std.int( getHeight()*0.3-bmp.height*0.5 );
		fx.textLine(bmp.y+32, 1);

		bmp.alpha = 0;
		tw.create(bmp.alpha, 1, 1000);

		delayer.add(function() {
			bmp.blendMode = ADD;
			tw.create(bmp.y, bmp.y-70, TEaseIn, 2000);
			tw.create(bmp.alpha, 0, 2000).onEnd = function() {
				bmp.parent.removeChild(bmp);
				bmp.bitmapData.dispose();
				bmp.bitmapData = null;
				creditBmps.remove(bmp);
			}
			cm.signal();
		}, 5000);
	}


	function onContinue() {
		Global.SBANK.UI_valide(1);
		loop.stop();
		Global.ME.switchMusic_intro();
		if( Global.ME.variant==Hard )
			Global.ME.run(this, function() new Unlocked(Lang.UnlockedEpic), false);
		else
			Global.ME.run(this, function() new StageSelect(-1,false), true);
	}

	override function onResize() {
		super.onResize();

		if( bg2==null )
			return;

		var w = getWidth();
		var h = getHeight();
		bg2.x = bg.x;
		bg2.y = bg.y;
		bg2.width = bg.width;
		bg2.height = bg.height;

		button.x = w*0.5-button.getWidth()*0.5;
		button.y = h-button.getHeight()-5;
	}


	//override function render() {
		//super.render();
		//BSprite.updateAll();
	//}


	override function update() {
		super.update();

		cm.update();

		if( Std.random(100)<10 && me.Ball.ALL.length<16 ) {
			new me.Ball(this);

			// ZSort
			me.Ball.ALL.sort(function(a,b) return Reflect.compare(a.z, b.z));
			for(e in me.Ball.ALL)
				e.spr.parent.addChildAt(e.spr, 0);
			button.wrapper.parent.addChild(button.wrapper);

		}


		fx.photoSparks(bg, true);
		fx.confettis(false);

		for(e in MenuEntity.ALL)
			e.update();
	}
}
