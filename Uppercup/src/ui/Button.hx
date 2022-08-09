package ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.slb.BSprite;

class Button extends mt.deepnight.mui.Button {
	var sprBg			: Null<BSprite>;
	var label			: Null<Bitmap>;
	var scale			: Int;
	public var hasClickFeedback	: Bool;
	var pt0				: flash.geom.Point;

	public function new(p, str:String, cb, ?scale=2) {
		super(p, str, cb);

		pt0 = new flash.geom.Point();
		hasClickFeedback = true;
		this.scale = scale;
		hasBackground = false;
		mouseOverable = false;
		color = 0xe6d6aa;
		setFontColor(0x311c14);

		textFieldSettings.sharpen = true;
		setFont(m.Global.ME.getFont().id, m.Global.ME.getFont().size);
		if( str!="" )
			setBitmapLabel(str);
	}


	override function onButtonClick(e) {
		if( MenuFx.ME!=null && hasClickFeedback )
			MenuFx.ME.buttonHit(this);

		super.onButtonClick(e);
	}


	public function setBitmapLabel(s:String) {
		setLabel(s.toUpperCase());
		tf.width = tf.textWidth+3;
		tf.height = tf.textHeight+3;
		tf.visible = false;

		if( label!=null ) {
			label.bitmapData.dispose();
			label.bitmapData = null;
			label.parent.removeChild(label);
		}
		label = mt.deepnight.Lib.flatten(tf);
		content.addChild(label);
		applyLabelFilters(label.bitmapData);
		label.bitmapData = mt.deepnight.Lib.scaleBitmap(label.bitmapData, scale*2, LOW, true);
		label.scaleX = label.scaleY = 0.5;
	}

	function applyLabelFilters(bd:BitmapData) {
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0xc89268,1, 0,0,1));
		//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0xf8f1db,0.5, 2,2,10));
		//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0x5A6F8D,1, 0,0));
		//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x0,1, 2,2,10));
		//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0xFFFFFF,0.1, 2,2,10));
	}

	public function setBg(s:BSprite, ?keepLabel=true) {
		if( sprBg!=null )
			sprBg.dispose();

		sprBg = s;
		bg.addChild(sprBg);
		sprBg.setCenter(0.5, 0.5);

		sprBg.x = Std.int( getWidth()*0.5 );
		sprBg.y = Std.int( getHeight()*0.5 );

		if( !keepLabel ) {
			if( label!=null )
				label.visible = false;
			tf.visible = false;
		}

		askRender(true);
	}

	override function applyStates() {
	}


	override function renderContent(w,h) {
		super.renderContent(w,h);

		if( label!=null ) {
			label.x = Std.int( w*0.5 - label.width*0.5 );
			label.y = Std.int( h*0.5 - label.height*0.5-4 );
		}

		if( sprBg!=null ) {
			sprBg.x = Std.int(w*0.5);
			sprBg.y = Std.int(h*0.5);
		}
	}

	override function destroy() {
		super.destroy();

		if( label!=null ) {
			label.bitmapData.dispose();
			label.bitmapData = null;
		}

		if( sprBg!=null )
			sprBg.dispose();
	}
}
