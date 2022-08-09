package en.it;

class SuperPower extends en.Item {
	public function new(x,y) {
		super(x,y);
		setDuration(30);

		sprite.a.playAndLoop("super");
		addGlow("glow_super");
	}

	override function onPick() {
		super.onPick();
		mode.hero.cd.set("superPower", 30*15);
		fx.pop(xx, yy, "Super power!!");
		fx.flashBang(0x00FFFF, 0.5);
	}
}
