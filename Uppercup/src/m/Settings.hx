package m;

import flash.display.Sprite;
import mt.deepnight.mui.VGroup;
import mt.deepnight.mui.HGroup;
import mt.deepnight.slb.BSprite;
import mt.MLib;
import mt.Metrics;
import ui.*;

class Settings extends MenuBase {
	var menu		: VGroup;
	var cornerMenu	: VGroup;
	#if !prod
	var adminMenu	: VGroup;
	#end
	var back		: Null<Button>;
	var music		: Button;
	var crowd		: Button;
	var quality		: Button;
	var leftHand	: Button;
	var sfx			: Button;
	var isOverGame	: Bool;

	public function new(isOverGame) {
		super(!isOverGame);

		this.isOverGame = isOverGame;
		if( isOverGame )
			bg.alpha = 0.8;
		musicOnActivate = !isOverGame;

		#if !prod
		adminMenu = new VGroup(wrapper);
		adminMenu.removeBorders();
		#end

		menu = new VGroup(wrapper);
		menu.removeBorders();
		menu.margin = 1;

		cornerMenu = new VGroup(wrapper);
		cornerMenu.removeBorders();
		cornerMenu.margin = 1;

		root.addEventListener( flash.events.MouseEvent.CLICK, onClickBg );

		var on = " ON";
		var off = " off";

		function gaOnOff(v) {
			return v?"on":"off";
		}

		// Music
		var str = StringTools.trim(Lang.Music);
		music = new BigMenuButton(menu, str + (Global.ME.hasMusic() ? on : off), function() {
			if( Global.ME.toggleMusic(!isOverGame) )
				music.setBitmapLabel( str + on );
			else
				music.setBitmapLabel( str + off );
			Global.SBANK.UI_select(1);
			Ga.event("settings","toggleMusic", gaOnOff(Global.ME.hasMusic() ));
		});

		// Crowd sounds
		var str = StringTools.trim(Lang.CrowdSfx);
		crowd = new BigMenuButton(menu, str + (Global.ME.hasCrowdSfx() ? on : off), function() {
			if( Global.ME.toggleCrowdSfx() )
				crowd.setBitmapLabel( str+on );
			else
				crowd.setBitmapLabel( str + off );
			Global.SBANK.UI_select(1);
			Ga.event("settings","toggleCrowdSfx", gaOnOff(Global.ME.hasCrowdSfx() ));
		});

		// Sounds
		var str = StringTools.trim(Lang.Sfx);
		sfx = new BigMenuButton(menu, str + (Global.ME.hasSfx() ? on : off), function() {
			if( Global.ME.toggleSfx() )
				sfx.setBitmapLabel( str+on );
			else
				sfx.setBitmapLabel( str + off );
			Global.SBANK.UI_select(1);
			Ga.event("settings","toggleSfx", gaOnOff(Global.ME.hasSfx() ));
		});

		if( !isOverGame ) {
			// Credits
			new SmallMenuButton(cornerMenu, Lang.Credits, onCredits);

			// Twinoid codes
			#if !webDemo
			new SmallMenuButton(cornerMenu, "Twinoid", onTwinoid);
			#end

			// Change language
			function getLangName() {
				return Lang.Language;
			}
			new SmallMenuButton(cornerMenu, getLangName(), onLangs);
		}


		// Quality
		var high = " "+Lang.High;
		var low = " "+Lang.Low;
		var str = StringTools.trim(Lang.Quality);
		quality = new BigMenuButton(menu, str + (Global.ME.isLowQuality() ? low : high), function() {
			if( Global.ME.toggleQuality() )
				quality.setBitmapLabel( str+low );
			else
				quality.setBitmapLabel( str + high );
			Global.SBANK.UI_select(1);
			Ga.event("settings","toggleQuality", (Global.ME.isLowQuality() ? "low" : "high" ) );
		});

		// Left handed
		var on = " "+Lang.LeftHanded;
		var off = " "+Lang.RightHanded;
		var str = StringTools.trim(Lang.Controls);
		leftHand = new BigMenuButton(menu, str + (playerCookie.data.leftHanded ? on : off), function() {
			playerCookie.data.leftHanded = !playerCookie.data.leftHanded;
			playerCookie.save();
			leftHand.setBitmapLabel( str + (playerCookie.data.leftHanded?on:off) );
			Global.SBANK.UI_select(1);
		});

		// Resume game
		if( isOverGame )
			new BigMenuButton(menu, Lang.Continue, onBack);

		// Restore
		#if( !webDemo && !press )
		if( !isOverGame && !isUnlocked() ){
			new BigMenuButton(menu, Lang.RestorePurchase, onRestore);
			Ga.event("settings","restorePurchase","done" );
		}
		#end

		if( !isOverGame ) {
			#if !prod
			// Clear
			new SmallMenuButton(adminMenu, "Clear data", function() {
				playerCookie.resetAndSave();
				Global.ME.setLang(playerCookie.data.lang);
				Global.ME.run(this, function() new Logo(), true);
			});
			// Fake buy
			new SmallMenuButton(adminMenu, "Fake buy", function() {
				IapMan.ME.unlock();
				Global.ME.run(this, function() new Thanks(true), false);
			});
			// Consume
			//new SmallMenuButton(adminMenu, "Consume", function() {
				//IapMan.ME.consumeUnlock();
				//playerCookie.resetAndSave();
				//Global.ME.setLang(playerCookie.data.lang);
				//Global.ME.run(this, function() new Logo(), true);
			//});
			#end

			back = new BackButton( wrapper, onBack );
		}

		// Version
		//if( mt.deepnight.Lib.isAir() ) {
			//var xml = flash.desktop.NativeApplication.nativeApplication.applicationDescriptor;
			//var c = xml.children();
			//var fast = new haxe.xml.Fast( Xml.parse(xml.toXMLString()) );
			//trace("ok fast");
			//trace(fast.nodes.versionNumber);
			//trace("ok all");
		//}

		onResize();
	}

	override function onBackKey() {
		super.onBackKey();
		onBack();
	}


	function onLangs() {
		Global.SBANK.UI_select(1);
		Global.ME.run(this, function() new LangSelect(), true);
	}



	function onCredits() {
		Global.SBANK.UI_select(1);
		Global.ME.run(this, function() new Credits(), false);
	}



	function onTwinoid() {
		Global.SBANK.UI_select(1);
		Global.ME.run(this, function() new Twinoid(), false);
	}


	function onRestore() {
		new Restore(this);
		//IapMan.ME.tryToRestore(function(productId:String) {
			//Global.ME.run(this, function() new Thanks(false), false);
		//});
	}

	override function unregister() {
		root.removeEventListener( flash.events.MouseEvent.CLICK, onClickBg );

		super.unregister();

		menu.destroy();
		if( back!=null )
			back.destroy();
	}

	function onClickBg(_) {
		if( isOverGame )
			onBack();
	}

	function onBack() {
		Global.SBANK.UI_back(1);
		if( isOverGame ) {
			destroy();
			Game.ME.resume();
		}
		else
			Global.ME.run(this, function() new Intro(), false);
	}

	override function onResize() {
		super.onResize();

		if( menu==null )
			return;

		if( isOverGame )
			menu.x = Std.int(getWidth()*0.5-menu.getWidth()*0.5);
		else
			menu.x = Std.int(getWidth()*0.48-menu.getWidth()*0.5);
		menu.y = Std.int(getHeight()*0.5-menu.getHeight()*0.5);

		cornerMenu.x = Std.int(getWidth() - cornerMenu.getWidth()-2 );
		cornerMenu.y = Std.int(getHeight() - cornerMenu.getHeight()-2 );

		#if !prod
		adminMenu.x = getWidth()-adminMenu.getWidth()-2;
		adminMenu.y = 2;
		#end
	}

	override function update() {
		super.update();
	}
}