package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import mt.deepnight.*;
import mt.deepnight.mui.HGroup;
import mt.deepnight.slb.*;
import mt.flash.Sfx;
import mt.MLib;
import mt.Metrics;
import ui.*;
import Const;

class Rate extends MenuBase {
	var icon			: BSprite;
	var tg				: TextGroup;
	var buttons			: HGroup;
	var skip			: Button;
	var rate			: Button;

	var lid				: Int;
	var victory			: Bool;

	public function new(l:Int,?v=false) {
		super();
		lid = l;
		victory = v;

		icon = tiles.get("star");
		wrapper.addChild(icon);
		icon.addEventListener( flash.events.MouseEvent.CLICK, function(_) onRate() );

		rate = new BigRateButton(wrapper, Lang.Rate, onRate);
		rate.hasClickFeedback = false;

		buttons = new HGroup(wrapper);
		buttons.removeBorders();
		buttons.margin = 10;
		new TwitterButton(buttons, Lang.ShareTwitter);
		new FacebookButton(buttons, "Uppercup Football");
		skip = new SmallMenuButton(buttons, Lang.SkipRating, onSkip);


		tg = new TextGroup(wrapper);
		for( line in Lang.PleaseRateUs.split("|") ) {
			line = StringTools.trim(line);
			tg.addLine(line);
		}

		onResize();
	}


	override function unregister() {
		super.unregister();

		icon.dispose();
		skip.destroy();
		rate.destroy();
		tg.destroy();
	}


	function onRate() {
		Global.SBANK.UI_valide(1);
		flash.Lib.getURL( new flash.net.URLRequest(Const.getRateUrl()) );
		playerCookie.data.ratedUs = true;
		playerCookie.save();
		onContinue();
	}

	function onSkip() {
		Global.SBANK.UI_select(1);
		onContinue();
	}

	override function onBackKey() {
		super.onBackKey();
		if( lid<0 )
			onContinue();
	}

	function onContinue() {
		if( lid<0 )
			Global.ME.run(this, function() new Intro(), true);
		else
			Global.ME.run(this, function() new StageSelect(lid, victory), true);
	}

	override function onResize() {
		super.onResize();

		if( skip==null )
			return;

		var w = getWidth();
		var h = getHeight();

		tg.x = w*0.5 - tg.getWidth()*0.5;
		tg.y = h*0.35 - tg.getHeight()*0.5;

		icon.x = w*0.5 - icon.width*0.5;
		icon.y = tg.y - icon.height;

		rate.x = w*0.5 - rate.getWidth()*0.5;
		rate.y = h*0.68 - rate.getHeight()*0.5;

		buttons.x = w*0.5 - buttons.getWidth()*0.5;
		buttons.y = rate.y+rate.getHeight()+2;
	}



	override function update() {
		super.update();

		fx.blingBling(icon.x, icon.y, icon.width, icon.height);
		//fx.blingBling(rate.x+150, rate.y, rate.getWidth()-300, rate.getHeight()-10);
		fx.godLight();
	}
}
