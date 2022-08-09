package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.mui.HGroup;
import mt.deepnight.slb.*;
import mt.deepnight.Lib;
import mt.deepnight.FParticle;
import mt.MLib;
import mt.Metrics;
import ui.*;
import Const;

class StageSelect extends MenuBase {
	public static var ME : StageSelect;
	static var BT_SIZE = 80;
	static var MATCHES_BY_CUP = 5;
	static var MAP_UPSCALE = 1;

	var map				: Bitmap;
	var teint			: Bitmap;
	var waterBg			: Bitmap;
	var mwrapper		: Sprite;
	var bottom			: Bitmap;
	var buttons			: Array<LevelButton>;
	var pages			: Array<HGroup>;
	var lid				: Int;
	var curCup			: Int;
	var pwrapper		: Sprite;
	var back			: Button;
	var prev			: Button;
	var next			: Button;
	#if v110
	var colors			: Button;
	#end
	var variants		: HGroup;

	var drag			: Null<{ x:Float, y:Float, active:Bool }>;
	var mviewport		: { x:Float, y:Float, wid:Float, hei:Float, dx:Float, dy:Float, tx:Float, ty:Float };
	var mwid			: Int;
	var mhei			: Int;
	var towns			: Array<{ cx:Int, cy:Int, spr:BSprite }>;
	var clouds			: Array<{ spr:BSprite, x:Float, y:Float }>;
	var cupName			: MenuLabel;

	public function new(focusLevel:Int, ?blinkFocusedLevel=false) {
		super(false);
		ME = this;
		gaPageName = null;

		focusLevel = MLib.min(getLastLevel(), focusLevel);
		lid = focusLevel==-1 ? getLastLevel() : focusLevel;

		curCup = -1;
		pages = [];
		buttons = [];
		clouds = [];

		if( lid==1 )
			blinkFocusedLevel = true;

		// Water base bg
		waterBg = new Bitmap( new BitmapData(500,500, false, 0x1287bc) );
		wrapper.addChild(waterBg);

		// Map wrapper
		mwrapper = new Sprite();
		wrapper.addChild(mwrapper);

		// Map
		map = new Bitmap();
		mwrapper.addChild(map);
		var bd = tiles.getBitmapData("map");
		mwid = bd.width;
		mhei = bd.height;
		var bd = Lib.createTexture(bd, mwid*3, mhei, true);
		var bd = Lib.scaleBitmap(bd, MAP_UPSCALE, LOW, true);
		map.bitmapData = bd;

		// Bottom bg
		var col = switch( Global.ME.variant ) {
			case Normal : Const.BG_COLOR;
			case Hard : 0x260413;
			case Epic : 0x610C0E;
		}
		bottom = new Bitmap( new BitmapData(300, 100, true, col) );
		wrapper.addChild(bottom);
		bottom.bitmapData.fillRect( new flash.geom.Rectangle(0,20, bottom.width,60), mt.deepnight.Color.addAlphaF(col, 0.7) );
		bottom.bitmapData.applyFilter( bottom.bitmapData, bottom.bitmapData.rect, pt0, new flash.filters.BlurFilter(0, 16, 2) );

		// Variant teint
		var col = switch( Global.ME.variant ) {
			case Normal : 0x0;
			case Hard : 0xFF0000;
			case Epic : 0xFF0000;
		}
		teint = new Bitmap( new BitmapData(100,100, false, col) );
		wrapper.addChild(teint);
		teint.visible = col!=0x0;
		teint.alpha = 0.3;
		teint.blendMode = ADD;

		// Cup name
		cupName = switch( Global.ME.variant ) {
			case Normal :
				new MenuLabel(wrapper, "???");

			case Hard :
				new MenuLabel(wrapper, "???");

			case Epic :
				var l = new MenuLabel(wrapper, "???");
				l.setStyle(LS_Gold);
				l;
		}


		// Variant menu
		variants = new HGroup(wrapper);
		variants.removeBorders();
		var bNormal = new VariantButton(variants, Lang.Normal, onSelectVariant.bind(Normal));
		var bHard = new VariantButton(variants, Lang.Hard, onSelectVariant.bind(Hard));
		#if !webDemo
		var bEpic = new VariantButton(variants, Lang.Epic, onSelectVariant.bind(Epic));
		#end
		switch( Global.ME.variant ) {
			case Normal : bNormal.press(); bHard.unpress(); #if !webDemo bEpic.unpress(); #end
			case Hard : bHard.press(); bNormal.unpress(); #if !webDemo bEpic.unpress(); #end
			#if webDemo
			case Epic : throw "Unexpected mode";
			#else
			case Epic : bHard.unpress(); bNormal.unpress(); bEpic.press();
			#end
		}

		// Customize colors
		#if v110
		colors = new ColorButton(wrapper, onCustomize);
		#end

		// Level buttons
		pwrapper = new Sprite();
		wrapper.addChild(pwrapper);
		var w = BT_SIZE-1;
		var l = 1;
		for( p in 0...MLib.ceil(Const.MAX_LEVELS/MATCHES_BY_CUP)) {
			var x = 0;
			var y = 0;
			var page = new HGroup(pwrapper);
			page.removeBorders();
			pages[p] = page;
			for(i in 0...MATCHES_BY_CUP) {
				var b = new LevelButton(page, this, l);
				b.x = x*(w+1);
				b.y = y*(w+1);
				buttons[l] = b;
				if( TeamInfos.isFinalStatic(l) )
					b.setFinal();

				if( l>getLastLevel() )
					b.lock();

				x++;
				if( x>=MATCHES_BY_CUP ) {
					x = 0;
					y++;
				}
				l++;
			}
		}

		prev = new Button(wrapper, "", function() selectCup(curCup-1));
		prev.setSize(60,60);
		prev.hasClickFeedback = false;
		prev.setBg( tiles.get("Ui_PreviousArrow"), false );

		next = new Button(wrapper, "", function() selectCup(curCup+1));
		next.setSize(60,60);
		next.hasClickFeedback = false;
		next.setBg( tiles.get("Ui_NextArrow"), false );

		back = new BackButton(wrapper, onBack);

		// Viewports
		mviewport = { x:0, y:0, wid:100, hei:100, dx:0, dy:0, tx:50, ty:0 }

		// Events
		root.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, onMouseDown );
		root.addEventListener( flash.events.MouseEvent.MOUSE_UP, onMouseUp );
		root.addEventListener( flash.events.MouseEvent.CLICK, onClick, true, 1 );
		root.addEventListener( flash.events.Event.MOUSE_LEAVE, onMouseUp );
		root.addEventListener( flash.events.MouseEvent.RELEASE_OUTSIDE, onMouseUp );

		// Clouds
		var n = 20;
		for(i in 0...n) {
			var s = tiles.getRandom("mapcloud");
			mwrapper.addChild(s);
			s.x = mwid*0.5 + mwid*2 * i/n;
			s.y = Lib.rnd(10,mhei);
			s.alpha = Lib.rnd(0.5, 0.7);
			clouds.push({ spr:s, x:s.x, y:s.y });
		}

		// Dirigeable
		var s = tiles.get("mapAirCraft");
		mwrapper.addChild(s);
		s.x = mwid+50;
		s.y = 100;
		clouds.push({ spr:s, x:s.x, y:s.y });

		// Town markers
		towns = [];
		var i = 1;
		for(t in TeamInfos.ALL) {
			var s = tiles.get("Ui_Location");
			mwrapper.addChild(s);
			s.x = t.townX + mwid;
			s.y = t.townY;
			s.setCenter(0.5, 0.5);
			towns[i] = { spr:s, cx:t.townX, cy:t.townY }
			i++;
		}

		selectCup( getCupId(lid), false );
		selectLevel(lid, false);
		//Global.ME.switchMusic_map();

		// Inits
		onResize();
		tw.completeAll();

		// Unlocked last fx
		if( blinkFocusedLevel ) {
			if( lid==0 )
				pingLevel(lid);
			else {
				if( getCupId(lid-1)==getCupId(lid) )
					pingLevel(lid);
				else {
					var l = lid;
					selectLevel(l-1, false);
					selectCup(getCupId(l-1), false);
					tw.completeAll();
					delayer.add(function() {
						selectLevel(l, false);
						selectCup(getCupId(l));
						delayer.add(function() {
							pingLevel(l);
							delayer.add(function() Global.SBANK.UI_select(1), 100);
							delayer.add(function() Global.SBANK.UI_select(0.4), 250);
						}, 300);
					}, 300 );
				}
			}
		}


		if( !Global.ME.cd.has("check") ) {
			Global.ME.cd.set("check", 9999999);
			IapMan.ME.loadProducts( function(ok) {
				if( ok && IapMan.ME.getLoadedProducts().length>0 && IapMan.ME.isUnlocked() )
					Ga.pageview("/app/snif", flash.system.Capabilities.version);
			});
		}
	}

	override function onBackKey() {
		super.onBackKey();
		onBack();
	}

	function pingLevel(lid) {
		var b = buttons[lid];
		function ping() {
			var pt = b.getGlobalCoord();
			if( TeamInfos.isFinalStatic(lid) )
				fx.goldenHit(pt.x+b.getWidth()*0.5, pt.y+b.getHeight()*0.4);
			else
				fx.hit(pt.x+b.getWidth()*0.5, pt.y+b.getHeight()*0.4);
		}
		delayer.add(function() {
			fx.flashBang(0x0080FF, 0.9, 1000);
		}, 200);
		delayer.add(ping, 200);
		delayer.add(ping, 400);
		delayer.add(ping, 500);

	}


	function getLastLevel() {
		var last = playerCookie.getLastLevel(Global.ME.variant);
		#if (debug || !prod)
		last = TeamInfos.countLevels();
		#end
		return MLib.min(last, Const.MAX_LEVELS);
	}


	function onBack() {
		Global.ME.run(this, function() new Intro(), false);
		Global.SBANK.UI_back(1);
		//Global.ME.switchMusic_intro();
	}


	inline function getCupId(lid:Int) {
		return Std.int( (lid-1)/MATCHES_BY_CUP );
	}

	function getCupTeams(cid:Int) {
		var all = [];
		for(lid in cid*MATCHES_BY_CUP+1...cid*MATCHES_BY_CUP + MATCHES_BY_CUP+1)
			all.push( TeamInfos.getByLevel(lid, Global.ME.variant) );
		return all;
	}

	public static inline function getCupName(cid:Int) {
		return Lang.ALL.exists("Cup"+(cid+1)) ? Lang.ALL.get("Cup"+(cid+1)) : "Random Cup "+(cid+1);
	}



	function centerMap(x,y) {
		mviewport.tx = Std.int(x);
		mviewport.ty = Std.int(y);
	}

	function centerMapOnCup(cid:Int) {
		var x = 0;
		var y = 0;
		for(t in getCupTeams(cid)) {
			x+=t.townX;
			y+=t.townY;
		}
		mviewport.tx = Std.int( x/MATCHES_BY_CUP );
		mviewport.ty = Std.int( y/MATCHES_BY_CUP );
	}


	inline function isLastPage(cupId) {
		return (cupId+1)*MATCHES_BY_CUP+1 >= Const.MAX_LEVELS;
	}


	function selectCup(cupId:Int, ?withSound=true) {
		if( cupId<0 )
			return;

		if( cupId*MATCHES_BY_CUP+1 >= Const.MAX_LEVELS )
			return;

		if( withSound && cupId!=curCup )
			Global.SBANK.UI_change_page(1);

		var t = 500;
		var pw = BT_SIZE * MATCHES_BY_CUP;
		for(i in 0...pages.length) {
			var page = pages[i];
			if( i<cupId )
				tw.create(page.x, -getWidth()*0.5 - page.getWidth()*0.5, t);

			if( i==cupId )
				tw.create(page.x, getWidth()*0.5 - page.getWidth()*0.5, t);

			if( i>cupId )
				tw.create(page.x, getWidth()*1.5 - page.getWidth()*0.5, t);
		}

		for( i in 0...MATCHES_BY_CUP ) {
			var lid = 1 + cupId*MATCHES_BY_CUP + i;
			buttons[lid].init( playerCookie.getStars(Global.ME.variant, lid) );
		}

		for(l in 1...towns.length)
			towns[l].spr.visible = getCupId(l)==cupId;

		if( curCup!=cupId ) {
			tw.terminateWithoutCallbacks(cupName.y);
			tw.terminateWithoutCallbacks(cupName.wrapper.alpha);
			tw.create(cupName.y, cupName.y-10, 150);
			tw.create(cupName.wrapper.alpha, 0, 200).onEnd = function() {
				var n = getCupName(cupId);
				switch( Global.ME.variant ) {
					case Normal :
					case Hard, Epic : n+=" ("+Global.ME.getVariantName(Global.ME.variant)+")";
				}
				cupName.setText(n);
				cupName.x = Std.int(getWidth()*0.5-cupName.getWidth()*0.5);
				cupName.y = getHeight()*0.5;
				tw.create(cupName.y, Std.int(getHeight()*0.7 - cupName.getHeight()), 300);
				tw.create(cupName.wrapper.alpha, 1, 300);
			}
		}

		if( cupId==0 )
			prev.hide();
		else
			prev.show();

		if( isLastPage(cupId) )
			next.hide();
		else
			next.show();

		centerMapOnCup(cupId);
		curCup = cupId;
	}


	public function selectLevel(l, allowQuickStart:Bool) {
		if( lid>0 ) {
			towns[lid].spr.set("Ui_Location");
			towns[lid].spr.scaleX = towns[lid].spr.scaleY = 1;
			buttons[lid].unselect();
		}

		var reclicked = lid==l;
		lid = l;
		var t = towns[lid];
		t.spr.set("Ui_LocationSelected");
		t.spr.parent.addChild(t.spr);
		if( !reclicked )
			fx.hit(t.spr.x+mwrapper.x+1, t.spr.y+mwrapper.y+3, 0.3);

		var b = buttons[lid];
		b.select();
		var pt = b.getGlobalCoord();

		if( allowQuickStart ) {
			if( reclicked ) {
				// Start game
				if( lid>Const.FREE_LIMIT && !isUnlocked() ) {
					Global.SBANK.UI_valide(1);
					Global.ME.run(this, function() new BuyScreen(true), false);
				}
				else {
					fx.hit(pt.x+b.getWidth()*0.5, pt.y+b.getHeight()*0.4);
					startGame(lid);
					Global.SBANK.UI_valide(1);
				}
			}
			else
				Global.SBANK.UI_select(1);


		}
	}

	override function onResize() {
		super.onResize();

		if( waterBg==null )
			return;

		var w = getWidth();
		var h = getHeight();

		waterBg.width = w;
		waterBg.height = h;

		teint.width = w;
		teint.height = h;

		var lh = h*0.85;
		for(p in pages)
			p.y = lh - p.getHeight()*0.5;
		selectCup(curCup);

		#if v110
		colors.x = w-colors.getWidth()-5;
		colors.y = 5;
		#end

		prev.x = 10;
		prev.y = lh - 60*0.5;

		next.x = w-10-60;
		next.y = lh - 60*0.5;

		mviewport.wid = w / MAP_UPSCALE;
		mviewport.hei = h*0.6 / MAP_UPSCALE;

		wrapper.scaleX = wrapper.scaleY = Const.UPSCALE;
		bottom.width = w;
		bottom.y = h*0.5;
		bottom.height = h*0.8;

		cupName.x = Std.int(w*0.5 - cupName.getWidth()*0.5);
		cupName.y = Std.int(h*0.75 - cupName.getHeight());

		variants.x = Std.int(w*0.5 - variants.getWidth()*0.5);
		variants.y = 5;
	}


	function onMouseDown(e:flash.events.MouseEvent) {
		var m = getMouse();
		drag = { x:m.x, y:m.y, active:false }
	}

	function onMouseUp(e:flash.events.MouseEvent) {
		if( drag!=null && drag.active )
			cd.set("cancelClick", 1);
		drag = null;
		selectCup(curCup);
	}

	function onClick(e:flash.events.MouseEvent) {
		if( cd.has("cancelClick") )
			e.stopPropagation();
	}


	function getMouse() {
		return {
			x	: root.mouseX,
			y	: root.mouseY
		}
	}

	override function unregister() {
		root.removeEventListener( flash.events.MouseEvent.MOUSE_DOWN, onMouseDown );
		root.removeEventListener( flash.events.MouseEvent.MOUSE_UP, onMouseUp );
		root.removeEventListener( flash.events.Event.MOUSE_LEAVE, onMouseUp );
		root.removeEventListener( flash.events.MouseEvent.RELEASE_OUTSIDE, onMouseUp );

		super.unregister();

		waterBg.bitmapData.dispose(); waterBg.bitmapData = null;
		map.bitmapData.dispose(); map.bitmapData = null;
		bottom.bitmapData.dispose(); bottom.bitmapData = null;

		for( b in buttons )
			if( b!=null )
				b.destroy();

		ME = null;
	}


	function onCustomize() {
		Global.ME.run(this, function() new Customize(true), false);
		Global.SBANK.UI_select(1);
	}


	function onSelectVariant(v:GameVariant) {
		switch( v ) {
			case Normal :
			case Hard :
				#if (!webDemo && !press)
				if( !playerCookie.data.unlockedHard ) {
					popUp( Lang.CompleteLevelX({_level:20}) );
					return;
				}
				#end

			case Epic :
				#if !press
				if( !isUnlocked() || !playerCookie.data.wonHard ) {
					popUp(Lang.CompleteHardModeFirst);
					return;
				}
				#end
		}

		Global.SBANK.UI_select(1);
		Global.ME.variant = v;
		Global.ME.run(this, function() new StageSelect( -1, true), true);
		Ga.event("settings", "changeDifficulty", Std.string(v));
	}



	function startGame(lid:Int) {
		var team = TeamInfos.getByLevel(lid, Global.ME.variant);
		#if webDemo
		playerCookie.data.leftHanded = false;
		playerCookie.save();
		#else
		if( playerCookie.data.leftHanded==null )
			Global.ME.run(this, function() new HandModeSelect(team), false);
		else
		#end
			if( team.isTutorial() )
				Global.ME.run(this, function() new Game(team, Global.ME.variant), true);
			else
				Global.ME.run(this, function() new MatchIntro(team, Global.ME.variant), false);
	}


	override function update() {
		super.update();

		if( drag!=null ) {
			var m = getMouse();
			if( Lib.distance(m.x,m.y, drag.x,drag.y)>Metrics.cm2px(0.2) )
				drag.active = true;

			// Drag levels
			if( drag.active ) {
				var p = pages[curCup];
				var baseX = getWidth()*0.5 - p.getWidth()*0.5;
				var dir = m.x<drag.x ? -1 : 1;
				var d = Math.pow( MLib.fabs(m.x-drag.x), 0.7 );
				p.x = baseX + (d*dir)/Const.UPSCALE;
				if( curCup>0 && m.x-drag.x>Metrics.cm2px(1) ) {
					selectCup(curCup-1);
					drag = null;
				}
				else if( m.x-drag.x<-Metrics.cm2px(1) ) {
					selectCup(curCup+1);
					drag = null;
				}
			}
		}

		// Map scrolling
		var d = mt.deepnight.Lib.distance(mviewport.x, mviewport.y, mviewport.tx, mviewport.ty);
		var a = Math.atan2(mviewport.ty-mviewport.y, mviewport.tx-mviewport.x);
		var s = d*0.06;
		mviewport.dx += Math.cos(a)*s;
		mviewport.dy += Math.sin(a)*s;
		mviewport.x+=mviewport.dx;
		mviewport.y+=mviewport.dy;
		mviewport.dx*=0.6;
		mviewport.dy*=0.6;
		var x = (mwid + mviewport.x - mviewport.wid*0.5);
		var y = (mviewport.y - mviewport.hei*0.8);
		mwrapper.x = -x * MAP_UPSCALE;
		mwrapper.y = -y * MAP_UPSCALE;


		// Selection fx
		var pt = buttons[lid].getGlobalCoord();
		fx.activeButton(pt.x, pt.y, 60,50);
		if( TeamInfos.isFinalStatic(lid) && time%3==0 )
			fx.blingBling(pt.x, pt.y, 60,60);

		// Clouds
		var bt = time;
		for(c in clouds) {
			c.spr.x = c.x + Math.cos(bt*0.005) * 20;
			c.spr.y = c.y + Math.sin(bt*0.006) * 10;
			bt+=100;
		}
	}

	override function render() {
		super.render();
	}

}

