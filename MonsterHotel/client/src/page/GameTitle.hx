package page;

import mt.data.GetText;
import mt.MLib;
import mt.deepnight.Tweenie;
import mt.deepnight.slb.*;
import mt.device.GameCenter;

@:bitmap("assets/titleLogoMask.png") class GfxTitleLogo extends flash.display.BitmapData { }

enum GameTitleMode {
	M_ClickToPlay;
	M_Loading;
	M_Menu;
}


class GameTitle extends H2dProcess {
	static var CITY_BG_HEI = 572;
	static var ME : GameTitle;

	var skipped		: Bool;
	var bg			: h2d.Bitmap;
	var logo		: HSprite;
	var logoBd		: flash.display.BitmapData;
	var city		: h2d.Bitmap;
	var dark		: HSprite;
	var click		: h2d.Text;
	var loading		: h2d.Text;
	var version		: h2d.Text;
	var wrapper		: h2d.Sprite;
	var cm			: mt.deepnight.Cinematic;
	var mode        : GameTitleMode;
	var ctrap		: h2d.Interactive;

	var bwid = 400;
	var bhei = 65;
	var buttons		: Array<h2d.Interactive>;

	var fx			: Fx;

	public static function show( mode : GameTitleMode ) {
		if ( ME == null || ME.destroyed )
			Main.ME.transition( function() return new page.GameTitle( mode ) );
		else
			ME.setMode( mode );
	}

	public function new( ?pMode : GameTitleMode ) {
		super(Main.ME, Main.ME.uiWrapper);

		ME = this;
		name = "GameTitle";

		buttons = [];
		skipped = false;
		cm = new mt.deepnight.Cinematic(Const.FPS);

		bg = new h2d.Bitmap( h2d.Tile.fromColor(alpha(#if trailer 0x0 #else 0x29032a #end)), root );
		bg.width = w();
		bg.height = h();

		city = new h2d.Bitmap( Assets.getDirectTexture("city"), root );
		city.filter = true;

		ctrap = new h2d.Interactive(4,4, root);
		ctrap.onClick = function(_) {
			if( mode == M_ClickToPlay )
				onComplete();
		}


		//#if debug
		//bg.alpha = city.alpha = 0.3;
		//#end

		wrapper = new h2d.Sprite(root);

		var glow = Assets.tiles.getH2dBitmap("glowOverlay", 0.5,0.5, true, wrapper);
		glow.blendMode = SoftOverlay;
		glow.scaleX = 13;
		glow.scaleY = glow.scaleX*0.7;
		glow.alpha = 0.2;

		var glow = Assets.tiles.getH2dBitmap("glowOverlay", 0.5,0.5, true, wrapper);
		glow.blendMode = SoftOverlay;
		glow.scaleX = 22;
		glow.scaleY = glow.scaleX*0.9;
		glow.alpha = 0.2;

		var shadow = Assets.tiles1.getH2dBitmap("logo", 0.5,0.5, true, wrapper);
		shadow.y += 10;
		var m = new h3d.Matrix();
		m.set(
			0,0,0, 0,
			0,0,0, 0,
			0,0,0, 0,
			0,0,0, 0.3
		);
		shadow.colorMatrix = m;

		logo = Assets.tiles1.h_get("logo", 0.5, 0.5, true,wrapper);
		logoBd = new page.GameTitle.GfxTitleLogo(0,0, true, 0x0);

		for(i in 0...1) {
			var b = Assets.tiles1.h_get("logoBloom", 0.5, 0.5, true, wrapper);
			b.blendMode = Add;
			b.y = 24;
			b.scale(2);
		}


		dark = Assets.tiles.h_get("darkMask", root);
		dark.alpha = 0.3;

		click = Assets.createText(64, 0xFFF0B3, "???", root);
		click.scale( Main.getScale( click.textHeight*click.scaleY, 0.4 ) );

		loading = Assets.createText(64, 0xFFFFFF, Lang.t._("Connecting..."), root);
		loading.scale( Main.getScale( loading.textHeight*loading.scaleY, 0.3 ) );
		loading.dropShadow = { color:Const.BLUE, alpha:0.5, dx:0, dy:3 }
		loading.visible = false;

		var s = new h2d.Layers(root);
		fx = new Fx(this,s);

		#if mBase
		version = Assets.createText(24, "version "+App.current.config.version+" ("+com.Protocol.DATA_VERSION+")", root);
		#else
		version = Assets.createText(24, "version "+com.Protocol.DATA_VERSION, root);
		#end

		//shine();

		if ( pMode == null )
			pMode = M_ClickToPlay;

		setMode( pMode );

		cd.set("shine", Const.seconds(0.8));
		//delayer.add( function() {
			//fx.titleExplosion(w()*0.5, h()*0.3, wrapper.scaleX);
		//}, 800);

		var y = wrapper.y;
		wrapper.y = -300;
		tw.create(wrapper.y, y, 800);

		var y = city.y;
		city.y = h();
		tw.create(city.y, y, 800);

		if( SoundMan.ME!=null ) {
			SoundMan.ME.introMusic();
			SoundMan.ME.stopAmbiant();
		}

		#if trailer
		city.visible = false;
		click.visible = false;
		#end
	}

	function setMode( m ) {
		mode = m;
		switch( mode ) {
			case M_ClickToPlay:
				removeButtons();
				click.visible = true;
				loading.visible = false;
				if( Main.TOUCH )
					click.text = Lang.t._("TAP TO PLAY");
				else
					click.text = Lang.t._("CLICK TO PLAY");

			case M_Loading:
				removeButtons();
				click.visible = false;
				loading.visible = true;

			case M_Menu:
				removeButtons();
				click.visible = false;
				loading.visible = false;
				var icon = !GameCenter.isAvailable() ? null : switch( GameCenter.service() ) {
					case GooglePlayGames : "iconBadgePad";
					case AppleGameCenter : null;
				}
				createButton( Lang.t._("Play"), icon, function() {
					setMode( M_Loading );
					mt.device.User.play("/start/");
				} );
				createButton( Lang.t._("Sign in"), function() {
					setMode( M_Loading );
					mt.device.User.login();
				});
		}
		onResize();
	}

	//function shine() {
		//var mask = new h2d.Mask(200,450, wrapper);
		//mask.y = -logo.height*0.5;
		//mask.visible = false;
//
		//var l = Assets.tiles1.getH2dBitmap("logo", mask);
		//l.colorMatrix = mt.deepnight.Color.getColorizeMatrixH2d(0xFFFFC6, 0.5, 0.5);
//
		//var a = tw.create(mask.x, -logo.width*0.5-mask.width>logo.width*0.5, TEaseIn, 1000);
		//a.onUpdate = function() {
			//mask.visible = true;
			//l.x = -mask.x - logo.width*0.5;
		//}
		//a.onEnd = function() {
			//mask.dispose();
		//}
	//}


	function createButton(label:LocaleString, ?iconId:String, cb:Void->Void) {
		var i = new h2d.Interactive(bwid, bhei, root);
		i.onClick = function(_) {
			Assets.SBANK.click1(1);
			cb();
		}

		var bg = Assets.tiles.getH2dBitmap("btnAction",i);
		bg.width = bwid;
		bg.height = bhei;

		var tf = Assets.createText(40, Const.BLUE, label, i);
		tf.x = bwid*0.5 - tf.textWidth*tf.scaleX*0.5;
		tf.y = bhei*0.5 - tf.textHeight*tf.scaleY*0.5;

		if( iconId!=null ) {
			var e = Assets.tiles.h_get(iconId,0, 0.5,0.5, true, i);
			e.constraintSize(bhei*0.85);
			e.x = tf.x - 5;
			e.y = bhei*0.5;
			tf.x+=e.width*0.5 + 10;
		}

		buttons.push(i);

		i.onOver = function(_) {
			bg.color = h3d.Vector.fromColor(alpha(0xFFFFAA),1.5);
		}
		i.onOut = function(_) {
			bg.color.one();
		}
	}


	function removeButtons() {
		for ( b in buttons )
			b.dispose();
		buttons = [];
	}

	//override function onEvents(e) {
		//super.onEvents(e);
//
		//switch( e.kind ) {
			//case ERelease :
				//if( mode == M_ClickToPlay )
					//onComplete();
			//default :
		//}
	//}

	function onComplete() {
		if( skipped || Main.ME.isTransitioning )
			return;

		skipped = true;
		var d = 600;
		fx.clearAll();
		//fx.titleExplosion(w()*0.5, h()*0.4, wrapper.scaleX);

		Assets.SBANK.happy(1);
		Assets.SBANK.click1(1);

		click.visible = false;
		//wrapper.visible = false;
		tw.create(wrapper.y, wrapper.y+80, TEaseIn, d);
		tw.create(city.y, city.y+120, TEaseIn, d);

		var mask = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0x22032c)), root );
		mask.width = w();
		mask.height = h();
		mask.alpha = 0;
		tw.create(mask.alpha, 1, TEaseIn, d);

		delayer.add( function() {
			Main.ME.transition(function() return new Game());
		}, d);
	}


	override function onDispose() {
		super.onDispose();

		if( ME==this )
			ME = null;

		fx = null;

		cm.destroy();
		cm = null;

		logoBd.dispose();
		logoBd = null;

		buttons = null;

		bg = null;
		city = null;
		logo = null;
		click = null;
		dark = null;
		wrapper = null;
	}


	override function onResize() {
		super.onResize();

		var s = MLib.fmin( 0.7*w()/logo.tile.width, 0.5*h()/logo.tile.height );
		wrapper.setScale(s);

		wrapper.x = Std.int( w()*0.5 );
		wrapper.y = Std.int( h()*0.3 );

		click.x = Std.int( w()*0.5 - click.textWidth*click.scaleX*0.5 );
		click.y = Std.int( h()*0.6 - click.textHeight*click.scaleY*0.5 );
		loading.x = Std.int( w()*0.5 - loading.textWidth*loading.scaleX*0.5 );
		loading.y = Std.int( h()*0.7 - loading.textHeight*loading.scaleY*0.5 );

		version.x = w()-version.width*version.scaleX - 10;
		version.y = h()-version.height*version.scaleY - 10;

		dark.width = w();
		dark.height = h();

		ctrap.setSize(w(), h());

		var s = MLib.fmax(
			w() / city.tile.width,
			h() / CITY_BG_HEI
		);
		city.setScale(s);
		city.x = Std.int( w()*0.5 - city.width*0.5 );
		city.y = h()-CITY_BG_HEI*s;

		var i = 0;
		var s = Main.getScale(bhei, 0.8);
		for(e in buttons) {
			e.setScale(s);
			e.x = w()*0.5 - e.width*s*0.5;
			e.y = h()*0.75 - buttons.length*bhei*s*0.5 + i*(bhei+10)*s;
			i++;
		}

		bg.width = w();
		bg.height = h();
	}


	override function update() {
		super.update();

		cm.update();

		//fx.titleDust(wrapper.scaleX);

		if( !skipped && !cd.has("shine") ) {
			fx.updateTitleShineX();
			var fdata = Assets.tiles1.getFrameData("logo");
			for(i in 0...3)
				fx.titleShine(wrapper.x, wrapper.y, fdata.realFrame.realWid*wrapper.scaleX, fdata.realFrame.realHei*wrapper.scaleY, wrapper.scaleX, logoBd);
		}

		click.alpha = 1 - MLib.fabs( Math.cos(ftime*0.2)*0.7 );
	}
}
