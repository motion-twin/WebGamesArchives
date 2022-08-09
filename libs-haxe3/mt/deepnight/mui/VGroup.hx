package mt.deepnight.mui;

class VGroup extends Group {
	var fitChildren		: Bool;

	public function new(p, ?margin, ?padding, ?fitChildren=true) {
		super(p, margin, padding);

		this.fitChildren = fitChildren;
	}


	override function prepareRender() {
		// Children resizing
		if( fitChildren ) {
			for(c in children )
				c.forcedWidth = null;

			var w = mt.MLib.fmin( maxWidth, mt.MLib.fmax( minWidth, getContentWidth() ) ) - hpadding*2;

			for(c in children )
				c.forcedWidth = w;
		}

		super.prepareRender();

		// Children position
		var y : Float = vpadding;
		for(c in children) {
			if( !c.isVisible() )
				continue;

			c.setPos(hpadding, y);
			y += c.getHeight() + margin;
		}
	}

	override function getContentWidth() {
		var v = super.getContentWidth();

		for(c in children)
			v = mt.MLib.fmax(v, c.getWidth());

		v += hpadding*2;

		if( forcedWidth!=null && forcedWidth>v )
			v = forcedWidth;

		return v;
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

	override function separator(?col, ?transp) {
		var s = super.separator(col, transp);
		s.setHorizontal();
		return s;
	}
}