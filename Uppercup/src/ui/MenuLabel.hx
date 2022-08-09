package ui;

import flash.display.Bitmap;
import mt.deepnight.slb.BSprite;

enum LabelStyle {
	LS_Default;
	LS_Gold;
	LS_GoldDark;
}

class MenuLabel extends mt.deepnight.mui.Label {
	var label			: Bitmap;
	var upscale			: Int;
	var style			: LabelStyle;

	public function new(p, str, ?upscale=2) {
		this.upscale = upscale;
		style = LS_Default;
		super(p, str);
	}

	public function setStyle(s:LabelStyle) {
		style = s;
		setText(tf.text);
	}

	override function setText(str:Dynamic) {
		setFont(m.Global.ME.getFont().id, m.Global.ME.getFont().size);

		switch( style ) {
			case LS_Default :
				setFontColor(0xFFFFFF);

			case LS_Gold :
				setFontColor(0xFFFF00);

			case LS_GoldDark :
				setFontColor(0xDF8600);
		}
		super.setText( str );

		tf.width = tf.textWidth+3;
		tf.height = tf.textHeight+3;

		if( label!=null ) {
			label.bitmapData.dispose();
			label.bitmapData = null;
		}

		label = mt.deepnight.Lib.flatten(tf);
		content.addChild(label);
		var bd = label.bitmapData;
		var pt0 = new flash.geom.Point();
		switch( style ) {
			case LS_Default :
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0x5A6F8D,1, 0,0));
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x27313F,1, 2,2,10));

			case LS_Gold :
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0xB34700,1, 0,0));
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x461000,1, 2,2,10));

			case LS_GoldDark :
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0x7D2000,1, 0,0));
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x2F0B00,1, 2,2,10));
		}
		label.bitmapData = mt.deepnight.Lib.scaleBitmap(bd, upscale*2, LOW, true);
		label.scaleX = label.scaleY = 0.5;

		setSize(label.width, label.height);

		return this;
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		tf.visible = false;
		if( label!=null ) {
			switch(halign) {
				case Left :
					label.x = 0;

				case Center :
					label.x = Std.int( w*0.5 - label.width*0.5 );

				case Right :
					label.x = Std.int( w - label.width );

				case Top, Bottom :
			}
		}

		label.y = Std.int( h*0.5 - label.height*0.5 - 3 );
	}

	override function getContentHeight() {
		return label.height;
	}


	override function destroy() {
		super.destroy();

		label.bitmapData.dispose();
		label.bitmapData = null;
	}
}
