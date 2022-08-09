package mt.deepnight.hui;

class VGroup extends Group {
	public var fitChildrenHorizontaly(default,set)		: Bool;

	public function new(p, ?margin, ?fitChildrenHorizontaly=true) {
		super(p, margin);

		this.fitChildrenHorizontaly = fitChildrenHorizontaly;
	}


	function set_fitChildrenHorizontaly(v) {
		askRender(true);
		return fitChildrenHorizontaly = v;
	}


	override function prepareRender() {
		// Children resizing
		if( fitChildrenHorizontaly ) {
			var w = minWidth;
			for(c in children ) {
				c.forcedWidth = null;
				w = MLib.fmax(w, c.getWidth());
			}
			if( forcedWidth!=null )
				w = MLib.fmax(forcedWidth, w);
			w = MLib.fmin(w, maxWidth);

			for(c in children )
				c.forcedWidth = w - (c.style.paddingExpandsBox ? c.style.hpadding*2 : 0);
		}

		super.prepareRender();

		// Children position
		var y : Float = style.vpadding;
		var cw = getWidth();
		for(c in children) {
			if( !c.isVisible() )
				continue;

			switch( style.contentHAlign ) {
				case None :
				case Left : c.x = style.hpadding;
				case Center : c.x = cw*0.5 - c.getWidth()*0.5;
				case Right : c.x = cw - style.hpadding - c.getWidth();
			}
			c.y = y;
			y += c.getHeight() + margin;
		}
	}

	override function getContentWidth() {
		var v = super.getContentWidth();

		for(c in children)
			v = MLib.fmax(v, c.getWidth());

		//if( forcedWidth!=null && forcedWidth>v )
			//v = forcedWidth;

		return v;
	}

	override function getContentHeight() {
		var h = super.getContentHeight();

		for(c in children)
			if( c.isVisible() )
				h+=c.getHeight() + margin;

		h -= margin;

		return h;
	}

	override function separator(?col, ?alpha, ?transp) {
		var s = super.separator(col, alpha, transp);
		s.setHorizontal();
		return s;
	}
}
