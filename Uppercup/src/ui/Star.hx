package ui;

import mt.deepnight.slb.*;
import mt.deepnight.mui.Component;
import m.MenuBase;

class Star extends Component {
	var on			: BSprite;
	var menu		: MenuBase;

	public function new(p, menu:MenuBase) {
		super(p);
		this.menu = menu;

		on = menu.tiles.get("bigStar");
		content.addChild(on);
		on.visible = false;
		on.setCenter(0.5, 0.5);

		hasBackground = false;
		setSize(50,50);
	}

	override function destroy() {
		super.destroy();

		on.dispose();
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		on.x = Std.int(w*0.5);
		on.y = Std.int(h*0.5);
	}

	public function activate() {
		on.visible = true;
		var pt = getGlobalCoord();
		menu.fx.star(pt.x+on.width*0.5, pt.y+on.height*0.5);
	}

	override function update() {
		super.update();
	}
}

