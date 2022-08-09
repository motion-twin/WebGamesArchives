package en;

class Mine extends Entity {
	var timer		: Int;
	public function new() {
		super();

		timer = -1;

		spr.set("mine");
		spr.setCenter(0.5, 0.5);
		removeShadow();

		cx = Const.FPADDING + rseed.irange(8, Const.FWID-8);
		cy = Const.FPADDING + rseed.irange(3, Const.FHEI-3);
	}

	override public function unregister() {
		super.unregister();
	}

	public override function update() {
		super.update();

		var b = game.ball;

		if( timer>0 ) {
			timer--;
			var blink = timer%3==0;
			spr.setFrame(blink ? 1 : 0);

			if( timer<=0 )
				explode(100);
		}

		if( game.isPlaying() && timer<0 )
			if( b.z<=6 && distance(b)<=30 ) {
				m.Global.SBANK.mine_active(1);
				timer = 15;
			}
	}
}