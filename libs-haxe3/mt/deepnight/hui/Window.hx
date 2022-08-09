package mt.deepnight.hui;

import h2d.Interactive;

class Window extends VGroup {
	var clickTrap	: Null<Interactive>;

	var autoCenterX	: Bool;
	var autoCenterY	: Bool;

	public function new(container:h2d.Sprite, ?hasClipTrap=true, ?onClickTrap:Window->Void) {
		if( hasClipTrap ) {
			clickTrap = new h2d.Interactive(10,10, container);
			container.addChild(clickTrap);
			clickTrap.cursor = Default;
			if( onClickTrap!=null )
				this.onClickTrap = onClickTrap;
			clickTrap.onClick = function(_) this.onClickTrap(this);
		}

		super(container);

		style.clickTrap = Col(0x0, 0.8);
		autoCenterX = autoCenterY = true;
		wrapper.visible = false;
	}

	public dynamic function onClickTrap(w:Window) {}

	public function setAutoCenter(horizontal:Bool, vertical:Bool) {
		autoCenterX = horizontal;
		autoCenterY = vertical;
		askRender(false);
	}

	override function set_x(v) {
		autoCenterX = false;
		return super.set_x(v);
	}

	override function set_y(v) {
		autoCenterY = false;
		return super.set_y(v);
	}

	override function prepareRender() {
		super.prepareRender();

		var w = getWidth();
		var h = getHeight();
		var e = h3d.Engine.getCurrent();
		var sw = e.width; // TODO: calculer véritable width en fonction des scales des parents
		var sh = e.height;

		if( clickTrap!=null ) {
			switch( style.clickTrap ) {
				case None :
					clickTrap.backgroundColor = 0x0;

				case Col(c,a) :
					clickTrap.backgroundColor = mt.deepnight.Color.addAlphaF(c, a);

				case Texture(_) :
					throw "unsupported yet: "+style.clickTrap;
			}
			clickTrap.width = sw;
			clickTrap.height = sh;
		}

		// Alignment
		if( autoCenterX ) {
			x = sw*0.5-w*0.5;
			autoCenterX = true;
		}
		if( autoCenterY ) {
			y = sh*0.5-h*0.5;
			autoCenterY = true;
		}
	}

	override function show() {
		super.show();
		if( clickTrap!=null )
			clickTrap.visible = true;
	}

	override function hide() {
		super.hide();
		if( clickTrap!=null )
			clickTrap.visible = false;
	}

	override function destroy() {
		super.destroy();

		if( clickTrap!=null ) {
			clickTrap.dispose();
			clickTrap = null;
		}
	}
}