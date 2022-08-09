package en.it;

class SmallTime extends en.Item {
	public function new() {
		super();

		color = 0xB4BFCD;
		spr.set("chrono");
		spr.setCenter(0.5,0.5);
	}

	public override function pickUp() {
		super.pickUp();
		fx.popTime(xx,yy, 30);
		game.addTime(30);
		m.Global.SBANK.bonus_temps(1);
	}
}
