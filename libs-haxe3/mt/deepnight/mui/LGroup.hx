package mt.deepnight.mui;

class LGroup extends Group {
	var lastWidth		: Float;

	public function new(p, ?margin, ?padding) {
		super(p, margin, padding);
		lastWidth = 0;
		minWidth = 100;
	}

	override function prepareRender() {
		super.prepareRender();

		// Children position
		var x : Float = hpadding;
		var y : Float = vpadding;
		var maxHei = 0.;
		var limit = forcedWidth!=null ? forcedWidth : maxWidth;
		for(c in children) {
			if( !c.isVisible() )
				continue;

			if( x - hpadding > limit-c.getWidth() ) {
				x = hpadding;
				y += margin + maxHei;
			}
			maxHei = mt.MLib.fmax(maxHei, c.getHeight());
			c.setPos(x, y);
			x += c.getWidth() + margin;
		}
	}

	override function getContentWidth() {
		var w = super.getContentWidth();

		for(c in children)
			w = mt.MLib.fmax(w, c.x + c.getWidth());

		w += hpadding;

		return w;
	}

	override function getContentHeight() {
		var h = super.getContentHeight();

		for(c in children)
			h = mt.MLib.fmax(h, c.y + c.getHeight());

		h += vpadding;

		return h;
	}

	override function separator(?col, ?transp) {
		var s = super.separator(col, transp);
		s.setVertical();
		return s;
	}
}