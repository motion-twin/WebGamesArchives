package m;

import flash.display.Sprite;
import mt.deepnight.mui.VGroup;
import mt.deepnight.slb.BSprite;
import mt.MLib;
import mt.Metrics;
import mt.deepnight.Lib;
import ui.*;
import googleAnalytics.Stats;

class Thanks extends MenuBase {
	var beer		: BSprite;
	var label		: MenuLabel;

	public function new(isNewPurchase:Bool) {
		super();

		beer = Global.ME.tiles.get("beerEdition");
		wrapper.addChild(beer);

		label = new MenuLabel(wrapper, Lang.ThankYou);

		root.addEventListener( flash.events.MouseEvent.CLICK, function(_) onContinue());

		onResize();

		if( isNewPurchase )
			gaPageName = "/buy/"+m.Global.ME.getVersion();
		else
			gaPageName = "/restore/"+m.Global.ME.getVersion();

		m.Global.SBANK.public_but().playOnChannel(Crowd.CHANNEL);
		fx.flashBang(0xFFFF00, 0.5, 2000);
	}

	override function unregister() {
		super.unregister();

		beer.dispose();
		label.destroy();
	}

	function onContinue() {
		Global.ME.run(this, function() new Customize(false), false);
	}

	override function onResize() {
		super.onResize();

		if( beer!=null ) {
			var w = getWidth();
			var h = getHeight();
			var sy = getHeight()*0.4/beer.getBitmapDataReadOnly().height;
			beer.scaleX = beer.scaleY = sy;
			beer.x = Std.int(w*0.5 - beer.width*0.5);
			beer.y = Std.int(h*0.4 - beer.height*0.5);
			label.setPos( Std.int(w*0.5-label.getWidth()*0.5), Std.int(h*0.7 - label.getHeight()*0.5) );
		}
	}


	override function update() {
		super.update();

		fx.photoSparks(bg);

		beer.y += Math.cos(time*0.1)*1;
		label.y += Math.sin(time*0.15)*0.5;
		fx.confettis();
		if( time%2==0 )
			fx.blingBling(beer.x, beer.y, beer.width, beer.height);

		if( time%3==0 )
			fx.godLight();
	}
}

