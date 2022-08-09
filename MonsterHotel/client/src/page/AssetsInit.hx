package page;

import mt.MLib;
import mt.deepnight.Tweenie;

class AssetsInit extends H2dProcess {
	var bg			: h2d.Bitmap;
	var wrapper		: h2d.Sprite;

	public function new(onComplete:Void->Void) {
		super(Main.ME, Main.ME.uiWrapper);

		onNextUpdate = function() {
			Preloader.destroy();
		}

		var bwid = 500;
		var bhei = 5;

		bg = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0x0)), root );

		wrapper = new h2d.Sprite(root);

		var logo = Assets.preloader.getH2dBitmap("motionTwin",0, 0.5,0, true, wrapper);
		logo.scale( bwid / logo.tile.width );

		var bwrapper = new h2d.Sprite(wrapper);
		bwrapper.x = Std.int(-bwid*0.5);
		bwrapper.y = logo.y + logo.height + 30;

		var bg = new h2d.Bitmap( h2d.Tile.fromColor(alpha(#if debug 0x530055 #elseif mobile 0x26264A #else 0xD93022 #end), bwid, bhei), bwrapper );
		var bar = new h2d.Bitmap( h2d.Tile.fromColor(alpha(#if debug 0xFF00FF #elseif mobile 0xD93022 #else 0x0 #end), bwid, bhei), bwrapper );
		bar.scaleX = 0;

		createChildProcess( function(p) {
			if( !Assets.READY && !Main.ME.isTransitioning && !cd.has("init") ) {
				if( !cd.hasSet("once",99999) )
					Assets.init();

				var r = Assets.progressiveInit();
				#if flash
				cd.set("init", Const.seconds(0.125));
				tw.create(bar.scaleX, r, TLinear, 125);
				#else
				cd.set("init", Const.seconds(0.050));
				tw.create(bar.scaleX, r, TLinear, 50);
				#end
			}

			if( Assets.READY && !cd.hasSet("endOnce",9999) ) {
				tw.terminateWithoutCallbacks(bar.scaleX);
				bar.scaleX = 1;
				tw.create(bwrapper.y, h()*0.6, 400);
				tw.create(bg.alpha, 200|0, 400);
				tw.create(bar.alpha, 200|0, 400);
				tw.create(logo.alpha, 200|0, 400);
				tw.create(logo.y, 200|h()*0.6, 400).onEnd = function(){
					bwrapper.visible = false;
					Main.ME.cd.set("autoScale", Const.seconds(1));

					onComplete();
					p.destroy();
				}
			}
		});

		onResize();
	}

	override function onDispose() {
		super.onDispose();

		bg = null;
		wrapper = null;
	}


	override function onResize() {
		super.onResize();

		wrapper.x = Std.int( w()*0.5 );
		wrapper.y = Std.int( h()*0.5 - 50 );
		bg.width = w();
		bg.height = h();
		wrapper.setScale( Main.getScale(wrapper.width, 4) );
	}
}
