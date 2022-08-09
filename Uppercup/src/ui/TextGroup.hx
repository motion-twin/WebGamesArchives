package ui;

import flash.display.Bitmap;
import mt.deepnight.slb.BSprite;

class TextGroup extends mt.deepnight.mui.Group {
	public function new(p, ?txt:String) {
		super(p);
		removeBorders();
		margin = -9;
		if( txt!=null )
			addText(txt);
	}

	public function addLine(str:String) {
		new MenuLabel(this, str);
	}

	public function addText(txt:String, ?maxCharsByLine=35) {
		for(c in ["!", ":", "?"])
			txt = StringTools.replace(txt, " "+c, "_"+c);
		var words = txt.split(" ");
		var lines = [""];
		for(i in 0...words.length) {
			if( (lines[lines.length-1] + words[i]).length > maxCharsByLine-1 )
				lines.push(words[i])
			else
				lines[lines.length-1]+=" "+words[i];
		}

		for(l in lines)
			new MenuLabel(this, StringTools.replace(l, "_", " "));
	}

	override function prepareRender() {
		// Children resizing
		for(c in children )
			c.setWidth( getWidth() );

		super.prepareRender();

		// Children position
		var y : Float = vpadding;
		for(c in children) {
			c.setPos(hpadding, y);
			y += c.getHeight() + margin;
		}
	}


	override function getContentHeight() {
		var h = super.getContentHeight();

		for(c in children)
			if( c.isVisible() )
				h+=c.getHeight() + margin;

		h -= margin;
		h += vpadding*2;

		return h;
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		//tf.visible = false;
		//label.x = Std.int( w*0.5 - label.width*0.5 );
		//label.y = Std.int( h*0.5 - label.height*0.5 );
	}


	override function destroy() {
		super.destroy();

		//label.bitmapData.dispose();
		//label.bitmapData = null;
	}
}
