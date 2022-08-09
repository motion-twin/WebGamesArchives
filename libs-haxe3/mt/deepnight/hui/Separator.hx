package mt.deepnight.hui;

import mt.deepnight.hui.Style;

class Separator extends Component {
	var bmp			: h2d.Bitmap;
	
	public static var STYLE : Style = {
		var s = new Style();
		s.bg = Col(0xFFFFFF, 0.1);
		s;
	}

	var vertical(default,set)		: Bool;

	public function new(p, verticalLine:Bool) {
		super(p);
		vertical = verticalLine;
		setCursor(Default);

		style = new Style(Component.BASE_STYLE, this);
		style.copyValues(STYLE);

		disableInteractive();
	}


	public function setHorizontal() {
		vertical = false;
	}

	public function setVertical() {
		vertical = true;
	}

	inline function set_vertical(v) {
		vertical = v;
		if( vertical ) {
			minWidth = 1;
			minHeight = 10;
		}
		else {
			minWidth = 10;
			minHeight = 1;
		}

		return vertical;
	}


	override function renderBackground(w:Float,h:Float) {
		//bg.clear();
		//switch( style.bg ) {
			//case None :
//
			//case Col(c,a) : bg.beginFill(c, a);
//
			//case Texture(t) :
				//bg.tile = t;
				//bg.tile.setCenterRatio(0.5, 0.5);
		//}
//
		//if( vertical )
			//bg.drawRect(w*0.5, 0, 1, h);
		//else
			//bg.drawRect(0, h*0.5, w, 1);
			
		if (bmp != null)
			bmp.dispose();
		bmp = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFFFF, Std.int(vertical ? 1 : h), Std.int(vertical ? h : 1)));
		if (vertical)
			bmp.x = w * 0.5;
		else {
			bmp.x = (w - h) * 0.5;
			bmp.y = h * 0.5;			
		}
		wrapper.addChild(bmp);
	}
	
	override public function destroy() {
		bmp.dispose();
		bmp = null;
		
		super.destroy();
	}
}