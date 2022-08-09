package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Color;
import mt.deepnight.mui.VGroup;
import mt.deepnight.slb.BSprite;
import mt.MLib;
import mt.Metrics;
import ui.*;

class Customize extends MenuBase {
	var runGame			: Bool;
	var dolls			: Array<{ body:BSprite, clothes:Bitmap }>;
	var clothes			: BitmapData;

	var confirm			: Button;
	var shirtPicker		: ColorPicker;
	var pantPicker		: ColorPicker;
	var stripePicker	: ColorPicker;
	var title			: MenuLabel;


	public function new(runGameOnConfirm:Bool) {
		super();
		runGame = runGameOnConfirm;
		dolls = [];

		clothes = tiles.getBitmapData("customShirt");
		for(i in 0...2) {
			var body = tiles.get("customCharacter", i);
			var bmp = new Bitmap(clothes);
			wrapper.addChild(body);
			wrapper.addChild(bmp);
			if( i==1 )
				body.scaleX = bmp.scaleX = -1;
			dolls.push({ body:body, clothes:bmp });
		}

		title = new MenuLabel(wrapper, Lang.CustomizeYourColors);
		title.setPos(getWidth()*0.5-title.getWidth()*0.5, 5);

		shirtPicker = new ColorPicker(this, Const.PALETTE, refresh);
		shirtPicker.select(playerCookie.data.shirtColor);

		stripePicker = new ColorPicker(this, Const.PALETTE, refresh);
		stripePicker.select(playerCookie.data.stripeColor);

		pantPicker = new ColorPicker(this, Const.PALETTE, refresh);
		pantPicker.select(playerCookie.data.pantColor);

		confirm = new SmallMenuButton(wrapper, Lang.Confirm, onConfirm);

		onResize();
		refresh();
	}


	function refresh() {
		paintClothes( shirtPicker.getColor(), pantPicker.getColor(), stripePicker.getColor() );
	}


	override function onResize() {
		super.onResize();

		if( dolls!=null ) {
			var w = getWidth();
			var h = getHeight();
			var y = h*0.15;
			shirtPicker.wrapper.x = Std.int( w*0.5 - shirtPicker.getWidth()*0.5 );
			shirtPicker.wrapper.y = y;
			y+=shirtPicker.getHeight() + 5;

			stripePicker.wrapper.x = Std.int( w*0.5 - stripePicker.getWidth()*0.5 );
			stripePicker.wrapper.y = y;
			y+=stripePicker.getHeight() + 5;

			pantPicker.wrapper.x = Std.int( w*0.5 - pantPicker.getWidth()*0.5 );
			pantPicker.wrapper.y = y;
			y+=pantPicker.getHeight() + 15;

			confirm.x = Std.int( w*0.5 - confirm.getWidth()*0.5 );
			confirm.y = y;

			var d = dolls[0];
			d.body.x = w*0.2 - d.body.width*0.5;
			d.body.y = h*0.6 - d.body.height*0.5;
			d.clothes.x = d.body.x;
			d.clothes.y = d.body.y;

			var d = dolls[1];
			d.body.x = w*0.8 - d.body.width*0.5 + d.body.width;
			d.body.y = h*0.6 - d.body.height*0.5;
			d.clothes.x = d.body.x;
			d.clothes.y = d.body.y;
		}
	}



	function paintClothes(shirt:Int, pant:Int, stripe:Int) {
		function makePal(c:Int) {
			return Color.makePaletteCustom([
				{ ratio:0.0,	col:Color.setLuminosityInt(c, 0) },
				{ ratio:0.6,	col:c},
			]);
		}

		var bd = clothes;
		var pt0 = new flash.geom.Point();
		tiles.drawIntoBitmap(clothes, 0,0, "customShirt",0);
		Color.paintBitmap(bd, makePal(pant), makePal(shirt), Color.makeNicePalette(stripe));
	}

	override function unregister() {
		super.unregister();

		shirtPicker.destroy();
		pantPicker.destroy();
		title.destroy();

		for( doll in dolls ) {
			doll.body.dispose();
			doll.clothes.bitmapData.dispose(); doll.clothes.bitmapData = null;
		}
	}

	function onConfirm() {
		m.Global.SBANK.UI_valide(1);
		playerCookie.data.shirtColor = shirtPicker.getColorId();
		playerCookie.data.pantColor = pantPicker.getColorId();
		playerCookie.data.stripeColor = stripePicker.getColorId();
		playerCookie.save();
		if( runGame )
			Global.ME.run(this, function() new StageSelect(-1), true);
		else
			Global.ME.run(this, function() new Intro(), true);
	}


	override function update() {
		super.update();

		fx.godLight();
	}
}

