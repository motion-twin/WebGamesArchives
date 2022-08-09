package ui;

import mt.MLib;
import com.Protocol;
import com.GameData;
import Data;
import mt.deepnight.Tweenie;

class LunchBox extends H2dProcess {
	public var ctrap		: h2d.Interactive;
	var mask				: h2d.Bitmap;
	var wrapper				: h2d.Sprite;
	var fx					: Fx;
	var item				: Item;
	var cm					: mt.deepnight.Cinematic;

	public function new(i:Item, isNew:Bool, ?isEventGift=false) {
		super();

		var scale = Main.getScale(128,1.8);

		Main.ME.uiWrapper.add(root, Const.DP_POP_UP);

		item = i;
		name = 'LunchBox';
		cm = new mt.deepnight.Cinematic(Const.FPS);

		ctrap = new h2d.Interactive(8,8,root);
		ctrap.onClick = function(_) onClick();

		mask = new h2d.Bitmap( h2d.Tile.fromColor(alpha(Const.BLUE, 0.93)), root );
		mask.alpha = 0;
		tw.create(mask.alpha, 1, 300);

		wrapper = new h2d.Sprite(root);

		var iwrapper = new h2d.Sprite(wrapper);
		var tdy = 0.;
		switch( item ) {
			case I_Gem :
				var i = Assets.tiles.getH2dBitmap("moneyGem", 0.5,0.5, true, iwrapper);
				i.scale(2);

			case I_Money(n) :
				var tf = new h2d.Text(Assets.fontHuge, iwrapper);
				tf.text = Game.ME.prettyNumber(n);
				tf.textColor = Const.TEXT_GOLD;
				tf.filter = true;
				tf.x = -tf.width*0.5;
				tf.y = -tf.height*0.5;
				var i = Assets.tiles.getH2dBitmap("moneyGold", 0.5,0.5, true, iwrapper);
				i.scale(1.25);
				i.x = tf.x;
				tf.x+=i.width*0.5 + 10;

			case I_Bath(_), I_Bed(_), I_Ceil(_), I_Furn(_), I_Wall(_) :
				var icon = switch( item ) {
					case I_Bath(f) : Assets.custo0.getH2dBitmap("bath", f);
					case I_Bed(f) : Assets.custo0.getH2dBitmap("bed", f);
					case I_Ceil(f) : Assets.custo0.getH2dBitmap("ceil", f);
					case I_Furn(f) : Assets.custo0.getH2dBitmap("furn", f);
					case I_Wall(f) : Assets.custo0.getH2dBitmap("wall", f);
					default : null;
				}
				iwrapper.addChild(icon);
				icon.tile.setCenterRatio(0.5,0.5);
				icon.filter = true;
				icon.setScale(1.5);
				tdy = icon.height*0.5;

			case I_Color(id) :
				var c = DataTools.getWallColorCode(id);
				var e = Assets.tiles.getColoredH2dBitmap("whiteCircle", c, iwrapper);
				e.tile.setCenterRatio(0.5,0.5);
				var bg = Assets.tiles.getH2dBitmap("circlet", 0.5,0.5, iwrapper);
				e.width = bg.width-10;
				e.height = bg.height-10;
				tdy = bg.height*0.5;
				//var tf = new h2d.Text(Assets.fontHuge, iwrapper);
				//tf.text = Lang.getItem(item).name;
				//tf.textColor = Const.TEXT_GOLD;
				//tf.filter = true;
				//tf.x = -tf.width*0.5;
				//tf.y = bg.height*0.5 + 10;

			case I_Texture(f) :
				var w = 128;
				var e = Assets.tiles.getColoredH2dBitmap("white", 0x677EB4, iwrapper);
				e.tile.setCenterRatio(0.5,0.5);
				e.width = e.height = w;
				var sb = new h2d.SpriteBatch(Assets.custo0.tile, iwrapper);
				sb.filter = true;
				var t = new TiledTexture(sb, Assets.custo0, -w*0.5, -w*0.5, w,w);
				t.fill("wallPaper", f, 0.6, 0.85);
				tdy = w*0.5;

			default :
		}

		// Item name
		switch( item ) {
			case I_Color(_), I_Texture(_), I_Bath(_), I_Bed(_), I_Ceil(_), I_Furn(_), I_Wall(_) :
				var label = Lang.getItem(item).name;
				switch( DataTools.getCustomItemRarity(item) ) {
					case Data.RarityKind.Uncommon : label+= cast " ("+Lang.t._("Rare")+")";
					case Data.RarityKind.Rare : label+= cast " ("+Lang.t._("Very rare")+")";
					default :
				}
				var tf = Assets.createText(28, Const.TEXT_GRAY, label, iwrapper);
				tf.x = -tf.textWidth*tf.scaleX*0.5;
				tf.y = tdy+10;

				if( isNew ) {
					var tf = Assets.createText(18, Const.TEXT_GOLD, Lang.t._("New item unlocked!"), iwrapper);
					tf.x = -tf.textWidth*tf.scaleX*0.5;
					tf.y = tdy+40;
				}

			default :
		}


		iwrapper.visible = false;
		iwrapper.setScale(scale);

		var ratio = 0;

		var box = Assets.tiles.h_getAndPlay(isEventGift ? "chest" : "giftTurn", wrapper);
		//box.blendMode = Add;
		box.filter = true;
		box.scale(scale);
		box.setCenterRatio(0.5, 0.5);
		box.rotation = 0.2;
		createChildProcess(function(_) {
			if( box.visible ) {
				box.a.update();
				//box.y = Math.cos(time*(0.2+0.6*ratio)) * 10;
				box.rotation *= 0.95;
				if( isEventGift )
					box.rotation = Math.cos(itime*0.7)*0.2;
			}
		});

		function blinkBox() {
			var b = true;
			var white = h3d.Vector.fromColor(alpha(0xFFFFFF), 1.5);
			createChildProcess(function(_) {
				if( b )
					box.color = white;
				else
					box.color = null;
				if( itime%2==0 )
					b = !b;
			});
		}

		cd.set("click", Const.seconds(0.25));
		cd.set("close", 999999);
		wrapper.setScale(0.25);

		Assets.SBANK.item(0.6);
		cm.create({
			300>>Assets.SBANK.giftPreOpen(0.3);
			tw.create(ratio, 0>1, 2500).update( function() box.a.setGeneralSpeed(0.7+0.7*ratio) ).end( cm.signal.bind("click") );
			tw.create(wrapper.scaleX, 1.5, TElasticEnd, 1500).onUpdate = function() wrapper.scaleY = wrapper.scaleX;
			2100>>blinkBox();
			end("click");
			fx.clearAll();
			box.visible = false;
			iwrapper.visible = true;
			tw.create(wrapper.scaleX, 0.6>1, TElasticEnd, 500).onUpdate = function() wrapper.scaleY = wrapper.scaleX;
			Assets.SBANK.giftOpen(0.6);
			Assets.SBANK.explode(0.2);
			Assets.SBANK.happy(1);
			fx.lunchBoxExplosion(w()*0.5, h()*0.5, item, scale);
			cd.unset("click");
			400;
			cd.unset("close");
			2600;
			close();
		});

		fx = new Fx(this, root);
		fx.lunchBoxCharge( w()*0.5, h()*0.5, scale );

		onNextUpdate = Game.ME.pause;
		ui.Notification.NotificationManager.clearAll();
		ui.HudMenuTip.clear(true);
		onResize();
	}

	function onClick() {
		if( cd.has("click") )
			return;

		if( !cd.has("close") )
			close();
		else
			cm.persistantSignal("click");
	}

	function close() {
		if( cd.has("close") )
			return;

		cm.cancelEverything();
		cd.set("close", 99999);
		ctrap.visible = false;
		Game.ME.resume();
		tw.create(wrapper.scaleX, 0.01, 600).onUpdate = function() wrapper.scaleY = wrapper.scaleX;
		tw.create(mask.alpha, 0, 600).onEnd = destroy;
	}


	override function onResize() {
		super.onResize();

		wrapper.x = Std.int( w()*0.5 );
		wrapper.y = Std.int( h()*0.5 );

		mask.width = w();
		mask.height = h();

		ctrap.width = w();
		ctrap.height = h();
	}


	override function onDispose() {
		super.onDispose();

		fx.destroy();
		fx = null;

		cm.destroy();
		cm = null;

		mask = null;
		ctrap = null;
		wrapper = null;
	}


	override function update() {
		super.update();

		cm.update();
	}
}