import mt.deepnight.slb.*;
import mt.deepnight.*;

class MenuEntity {
	public static var ALL : Array<MenuEntity> = [];

	public var spr			: BSprite;
	var process				: m.MenuBase;
	public var xx			: Float;
	public var yy			: Float;
	public var dx			: Float;
	public var dy			: Float;
	public var frict		: Float;

	public function new(p) {
		process = p;
		frict = 0.96;
		dx = dy = 0;
		spr = new BSprite(process.tiles);
		process.wrapper.addChild(spr);
		ALL.push(this);
		setPos(50,50);
	}

	function setPos(x,y) {
		xx = x;
		yy = y;
		updateSprite();
	}

	function updateSprite() {
		spr.x = Std.int(xx);
		spr.y = Std.int(yy);
	}

	inline function irnd(min, max, ?sign) { return Lib.irnd(min, max, sign); }
	inline function rnd(min, max, ?sign) { return Lib.rnd(min, max, sign); }

	public function destroy() {
		spr.dispose();
		ALL.remove(this);
		process = null;
	}

	public function update() {
		xx+=dx;
		yy+=dy;
		dx*=frict;
		updateSprite();
	}
}
