package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.mui.VGroup;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Color;
import mt.MLib;
import mt.Metrics;
import ui.*;

class GameMenu extends mt.deepnight.FProcess {
	var wrapper		: Sprite;
	var bg			: Bitmap;
	var menu		: VGroup;

	public function new() {
		super();

		wrapper = new Sprite();
		root.addChild(wrapper);

		var bgWrapper = new Sprite();
		wrapper.addChild(bgWrapper);
		bgWrapper.addEventListener( flash.events.MouseEvent.CLICK, function(_) onResume() );

		bg = new Bitmap( new BitmapData(150,150, true, Color.addAlphaF(Const.BG_COLOR,0.8)) );
		bgWrapper.addChild(bg);

		menu = new VGroup(wrapper);
		menu.removeBorders();

		Global.SBANK.UI_select(1);

		try {
			flash.desktop.NativeApplication.nativeApplication.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onSoftKeyDown, true );
		} catch(e:Dynamic) {}

		new BigMenuButton( menu, Lang.Options, onOptions);
		new BigMenuButton( menu, Lang.Restart, onRestart);
		new BigMenuButton( menu, Lang.Abandon, onQuit);
		new BigMenuButton( menu, Lang.Continue, onResume);

		#if !prod
		new BigMenuButton( menu, "Win", function() {
			Global.ME.run(Game.ME, function() new MatchEnd(Game.ME.oppTeam,true, 0), false);
		});
		new BigMenuButton( menu, "Lose", function() {
			Global.ME.run(Game.ME, function() new MatchEnd(Game.ME.oppTeam,false, 0), false);
		});
		#end

		onResize();
	}

	override function unregister() {
		super.unregister();

		bg.bitmapData.dispose();
		bg.bitmapData = null;
		menu.destroy();

		try {
			flash.desktop.NativeApplication.nativeApplication.removeEventListener( flash.events.KeyboardEvent.KEY_DOWN, onSoftKeyDown, true);
		} catch(e:Dynamic) {}
	}

	function onSoftKeyDown(e:flash.events.KeyboardEvent) {
		if( destroyAsked )
			return;

		switch( e.keyCode ) {
			case flash.ui.Keyboard.BACK :
				e.preventDefault();
				onResume();
		}
	}


	function onResume() {
		Game.ME.resume();
		Global.SBANK.UI_back(1);
		destroy();
	}

	function onQuit() {
		destroy();
		Global.SBANK.UI_back(1);
		mt.flash.Sfx.terminateTweens();
		Global.ME.startMusic();
		if( Game.ME.oppTeam.isCustom )
			Global.ME.run(Game.ME, function() new CustomMatch(), true);
		else
			Global.ME.run(Game.ME, function() new StageSelect(Game.ME.oppTeam.lid), true);
	}

	function onRestart() {
		destroy();
		Global.SBANK.UI_valide(1);
		Global.ME.run(Game.ME, function() new MatchIntro(Game.ME.oppTeam, Game.ME.getVariant()), true);
	}

	function onOptions() {
		destroy();
		Global.SBANK.UI_select(1);
		new Settings(true);
	}

	override function onResize() {
		super.onResize();

		if( menu==null )
			return;

		wrapper.scaleX = wrapper.scaleY = Const.UPSCALE;

		bg.width = Const.WID;
		bg.height = Const.HEI;
		menu.x = Std.int(Const.WID/Const.UPSCALE*0.5-menu.getWidth()*0.5);
		menu.y = Std.int(Const.HEI/Const.UPSCALE*0.5-menu.getHeight()*0.5);
	}

	override function update() {
		super.update();
	}
}