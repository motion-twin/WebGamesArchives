package m;

import flash.display.Sprite;
import mt.deepnight.mui.Group;
import mt.deepnight.mui.VGroup;
import mt.deepnight.mui.HGroup;
import mt.deepnight.Tweenie;
import mt.deepnight.slb.BSprite;
import mt.MLib;
import mt.Metrics;
import ui.*;

class Intro extends MenuBase {
	var menu		: Group;
	var logoFront	: BSprite;
	var sunShines	: Array<BSprite>;
	var logoBg		: BSprite;
	var logoCup		: BSprite;
	var boy			: BSprite;
	var ball		: BSprite;
	var beat		: Bool;
	var socials		: Group;
	var build		: Null<MenuLabel>;

	public function new() {
		super();
		sunShines = [];
		beat = false;

		logoBg = tiles.get("logo", 2);
		wrapper.addChild(logoBg);
		logoBg.setCenter(0.5, 0.5);

		for( i in 0...2 ) {
			var s = tiles.get("fxSunshine");
			wrapper.addChild(s);
			s.setCenter(0.5, 0.5);
			s.blendMode = ADD;
			s.scaleX = s.scaleY = 0;
			sunShines.push(s);
		}

		logoCup = tiles.get("logo", 1);
		wrapper.addChild(logoCup);
		logoCup.setCenter(0.5, 0.55);

		logoFront = tiles.get("logo", 0);
		wrapper.addChild(logoFront);
		logoFront.setCenter(0.5, 0.5);

		menu = new VGroup(wrapper);
		menu.removeBorders();
		menu.margin = 3;

		new BigMenuButton( menu, Lang.Start, onPlay );
		#if !webDemo
		if( isUnlocked() ) {
			#if v110
				#if v120
				var g = new HGroup(menu);
				g.removeBorders();
				new MediumMenuButton( g, "Multiplayer", onMultiplayer ); // HACK multi
				new MediumMenuButton( g, Lang.QuickMatch, onQuickMatch );
				#else
				new BigMenuButton( menu, Lang.QuickMatch, onQuickMatch );
				#end
			#else
			new BigMenuButton( menu, Lang.CustomizeTeam, onCustomize );
			#end
		}
		else {
			var b = new BigMenuButton( menu, Lang.BuyPage, onBuy );
			b.addPromoFlag();
		}
		#end

		#if (v105 && !webDemo)
		var g = new HGroup(menu);
		g.removeBorders();
		new MediumMenuButton( g, Lang.OurGames, onMoreGames );
		new MediumMenuButton( g, Lang.Options, onSettings );
		#elseif webDemo
		var g = new HGroup(menu);
		g.removeBorders();
		new MediumMenuButton( g, "iPhone/iPad", onIos);
		new MediumMenuButton( g, "Android", onAndroid );
		new BigMenuButton( menu, Lang.Options, onSettings );
		#else
		new BigMenuButton( menu, Lang.Options, onSettings );
		#end

		//new ExitButton(wrapper);

		boy = tiles.get("fafiBoy");
		wrapper.addChild(boy);
		boy.mouseChildren = boy.mouseEnabled = false;
		boy.setCenter(0.5, 0.5);

		ball = tiles.get("baloon");
		wrapper.addChild(ball);
		ball.mouseChildren = ball.mouseEnabled = false;
		ball.setCenter(0.5, 0.5);

		boy.x = getWidth()+100;
		boy.y = getHeight();
		ball.x = getWidth()-10;
		ball.y = getHeight()-40;
		//if( Global.ME.hasMusic() )
			//cd.set("boy", 9999);
		//else
			cd.set("boy", Const.seconds(0.6));
		cd.onComplete("boy", function() {
			fx.flashBang(0x0080FF, 0.5, 1000);
			Global.SBANK.joueur_tir(1);
			//if( !Global.ME.hasMusic() )
				//Global.SBANK.joueur_tir(0.6);
		});

		cd.set("sunshines", Const.seconds(0.1));
		cd.onComplete("sunshines", function() {
			var i = 0;
			for( s in sunShines ) {
				tw.create(s.scaleX, 2, TEaseOut, 800).onUpdate = function() {
					s.scaleY = s.scaleX;
				}
				i++;
			}
		});
		cd.set("godLights", Const.seconds(0.6));

		#if !prod
		new SmallMenuButton(wrapper, "Reboot", function() {
			Global.ME.run(this, function() new Logo(), false);
		});
		#end

		socials = new VGroup(wrapper);
		socials.removeBorders();
		socials.padding = 3;
		socials.margin = 1;
		new TwitterButton(socials, Lang.ShareTwitter);
		new FacebookButton(socials, "Uppercup Football");
		#if (!webDemo && !press)
		new RateTinyButton(socials, tiles.get("btnLike"), this);
		#end

		#if !prod
		build = new MenuLabel(wrapper, m.Global.ME.getVersion());
		#end

		onResize();
	}

	override function unregister() {
		super.unregister();

		menu.destroy();
		if( build!=null )
			build.destroy();

		logoCup.dispose();
		logoBg.dispose();
		logoFront.dispose();
		boy.dispose();
		ball.dispose();

		for(s in sunShines)
			s.dispose();
		sunShines = null;
	}

	function onIos() {
		flash.Lib.getURL( new flash.net.URLRequest("https://itunes.apple.com/fr/app/id881006708?mt=8") );
	}

	function onAndroid() {
		flash.Lib.getURL( new flash.net.URLRequest("https://play.google.com/store/apps/details?id=air.com.motiontwin.UppercupFootball&referrer=utm_source%3Dsite_upper%26utm_medium%3Dweb%26utm_content%3Dbtn_android%26utm_campaign%3Dorganic") );
	}

	override function onBackKey() {
		super.onBackKey();
		Global.ME.exitApp();
	}

	override function onMenuKey() {
		super.onMenuKey();
		onSettings();
	}

	function onBuy() {
		Global.ME.run(this, function() new BuyScreen(), false);
		Global.SBANK.UI_select(1);
	}

	function onPlay() {
		Global.ME.run(this, function() new StageSelect(-1,true), false);
		Global.SBANK.UI_valide(1);
	}

	function onQuickMatch() {
		Global.ME.run(this, function() new CustomMatch(), false);
		Global.SBANK.UI_valide(1);
	}

	#if v120
	function onMultiplayer() {
		Global.ME.run(this, function() new Multiplayer(), true);
		Global.SBANK.UI_valide(1);
	}
	#end

	function onCustomize() {
		Global.ME.run(this, function() new Customize(false), false);
		Global.SBANK.UI_select(1);
	}

	function onSettings() {
		Global.ME.run(this, function() new Settings(false), false);
		Global.SBANK.UI_select(1);
	}

	function onMoreGames() {
		Global.ME.run(this, function() new MoreGames(), false);
		Global.SBANK.UI_select(1);
	}

	override function onResize() {
		super.onResize();

		if( menu==null )
			return;

		menu.x = Std.int(getWidth()*0.5-menu.getWidth()*0.5);
		menu.y = Std.int(getHeight()*0.75-menu.getHeight()*0.5);

		socials.x = Std.int(0);
		socials.y = Std.int(getHeight()-socials.getHeight());

		logoFront.x = logoBg.x = logoCup.x = Std.int(getWidth()*0.5);
		logoFront.y = logoBg.y = logoCup.y = Std.int(getHeight()*0.25);

		if( build!=null ) {
			build.x = getWidth()-build.getWidth()-2;
			build.y = -2;
			//build.y = getHeight()-build.getHeight()-2;
		}

		for(s in sunShines) {
			s.x = Std.int(getWidth()*0.5);
			s.y = Std.int(getHeight()*0.25);
		}
	}

	override function update() {
		super.update();

		//fx.godSparks()
		if( time%2==0 && !cd.has("godLights") )
			fx.godLight();

		if( !cd.has("sunshines") ) {
			var i = 0;
			for(s in sunShines)
				if( time%(i+1)==0 ) {
					s.rotation += (i%2==0 ? 1 : -1) * 0.2;
					while( s.rotation>180 ) s.rotation-=360;
					while( s.rotation<-180 ) s.rotation+=360;
					s.alpha = 0.7 + Math.cos(i*2 + time*0.1)*0.3;
					i++;
				}
		}

		// Uppercup
		if( time%3==0 )
			fx.blingBling(logoFront.x-85, logoFront.y, 160, 20);
		// Football
		fx.blingBling(logoFront.x-135, logoFront.y+25, 270, 40);


		if( !cd.has("boy") ) {
			// Boy arrives
			var w = getWidth();
			var h = getHeight();
			var s = 0.3;
			ball.x += (w*0.15-ball.x)*s;
			ball.y += (h*0.5-ball.y)*s;
			var s = 0.4;
			boy.x += (w*0.9-boy.x)*s;
			boy.y += (h*0.65-boy.y)*s;
		}

		// Logo bouncing
		if( Global.ME.isBeatFrame() ) {
			beat = !beat;
			tw.terminateWithoutCallbacks(logoFront.x);
			tw.terminateWithoutCallbacks(logoFront.y);
			tw.create(logoCup.x, logoCup.x + 2*(beat?-1:1), TEaseOut, 150);
			tw.create(logoCup.y, logoCup.y - 5, TLoop, 350);

			tw.create(logoFront.x, logoFront.x + 1*(beat?1:-1), TEaseOut, 150);
			tw.create(logoFront.y, logoFront.y - 3, TLoop, 350);

			tw.terminateWithoutCallbacks(menu.y);
			//tw.create(menu, "x", menu.x + 3, TLoop, 150);
			tw.create(menu.y, menu.y + (beat ? 3 : -3), TEaseOut,150);
		}

	}
}