package mt.deepnight.hui;

class LGroup extends Group {
	var lastWidth		: Float;

	public function new(p, ?padding) {
		super(p, padding);
		lastWidth = 0;
		minWidth = 100;
	}

	override function prepareRender() {
		super.prepareRender();

		// Children position
		var x : Float = style.hpadding;
		var y : Float = style.vpadding;
		var maxHei = 0.;
		var limit = forcedWidth!=null ? forcedWidth : maxWidth;
		for(c in children) {
			if( !c.isVisible() )
				continue;

			if( x - style.hpadding > limit-c.getWidth() ) {
				x = style.hpadding;
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

		w -= style.hpadding;

		return w;
	}

	override function getContentHeight() {
		var h = super.getContentHeight();

		for(c in children)
			h = mt.MLib.fmax(h, c.y + c.getHeight());

		h -= style.vpadding;

		return h;
	}

	override function separator(?col, ?alpha, ?transp) {
		var s = super.separator(col, alpha, transp);
		s.setVertical();
		return s;
	}
}