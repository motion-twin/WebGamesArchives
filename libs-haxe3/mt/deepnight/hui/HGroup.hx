package mt.deepnight.hui;

class HGroup extends Group {
	public var fitChildrenVerticaly(default,set)		: Bool;

	public function new(p, ?margin, ?fitChildrenVerticaly=true) {
		super(p, margin);

		this.fitChildrenVerticaly = fitChildrenVerticaly;
	}


	function set_fitChildrenVerticaly(v) {
		askRender(true);
		return fitChildrenVerticaly = v;
	}


	override function prepareRender() {
		// Children resizing
		if( fitChildrenVerticaly ) {
			var h = minHeight;
			for(c in children ) {
				c.forcedHeight = null;
				h = MLib.fmax(h, c.getHeight());
			}
			if( forcedHeight!=null )
				h = MLib.fmax(forcedHeight, h);
			h = MLib.fmin(h, maxHeight);

			for(c in children )
				c.forcedHeight = h - (c.style.paddingExpandsBox ? c.style.vpadding*2 : 0);
		}

		super.prepareRender();

		// Children position
		var x : Float = style.hpadding;
		var ch = getHeight();
		for(c in children) {
			if( !c.isVisible() )
				continue;

			c.x = x;
			switch( style.contentVAlign ) {
				case None :
				case Top : c.y = style.vpadding;
				case Center : c.y = ch*0.5 - c.getHeight()*0.5;
				case Bottom : c.y = ch - style.vpadding - c.getHeight();
			}

			x += c.getWidth() + margin;
		}
	}

	override function getContentHeight() {
		var v = super.getContentHeight();

		for(c in children)
			v = MLib.fmax(v, c.getHeight());

		//if( forcedHeight!=null && forcedHeight>v )
			//v = forcedHeight;

		return v;
	}

	override function getContentWidth() {
		var w = super.getContentWidth();

		for(c in children)
			if( c.isVisible() )
				w+=c.getWidth() + margin;

		w -= margin;

		return w;
	}

	override function separator(?col, ?alpha, ?transp) {
		var s = super.separator(col, alpha, transp);
		s.setVertical();
		return s;
	}
}
