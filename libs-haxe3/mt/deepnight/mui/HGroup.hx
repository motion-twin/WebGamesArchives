package mt.deepnight.mui;

class HGroup extends Group {
	var fitChildren		: Bool;

	public function new(p, ?margin, ?padding, ?fitChildren=true) {
		super(p, margin, padding);

		this.fitChildren = fitChildren;
	}

	override function prepareRender() {
		// Children resizing
		if( fitChildren ) {
			for(c in children )
				c.forcedHeight = null;

			var h = mt.MLib.fmin( maxHeight, mt.MLib.fmax( minHeight, getContentHeight() ) ) - vpadding*2;

			for(c in children )
				c.forcedHeight = h;
		}

		super.prepareRender();

		// Children position
		var x : Float = hpadding;
		var y = getContentHeight()*0.5;
		for(c in children) {
			if( !c.isVisible() )
				continue;

			c.setPos(x, y-c.getHeight()*0.5);
			x += c.getWidth() + margin;
		}
	}

	override function getContentHeight() {
		var v = super.getContentHeight();

		for(c in children)
			v = mt.MLib.fmax(v, c.getHeight());

		v += vpadding*2;

		if( forcedHeight!=null && forcedHeight>v )
			v = forcedHeight;

		return v;
	}

	override function getContentWidth() {
		var w = super.getContentWidth();

		for(c in children)
			if( c.isVisible() )
				w+=c.getWidth() + margin;

		w -= margin;
		w += hpadding*2;

		return w;
	}

	override function separator(?col, ?transp) {
		var s = super.separator(col, transp);
		s.setVertical();
		return s;
	}


}