package en.it;

class Gold extends en.Item {
	static var VALUES = api.AKApi.aconst([500, 250, 100, 50, 10]);
	var bounce			: Int;
	var value			: api.AKConst;
	var skillValue		: Float;

	public function new(x,y, floor) {
		super(x,y);
		bounce = 0;
		radius = 20;
		floating = false;
		push();

		value = VALUES[floor];

		skillValue = switch( floor ) {
			case 0 : 0.05;
			case 1 : 0.02;
			default : 0;
		}

		var s = switch( floor ) {
			case 0 : 1;
			case 1 : 0.85;
			case 2 : 0.70;
			case 3 : 0.55;
			default : 0.40;
		}
		sprite.a.playAndLoop("coin");
		sprite.scaleX = sprite.scaleY = s;
	}

	public function push(?power=1.0) {
		dx = power * rnd(0.01, 0.20, true);
		dy = rnd(-0.3, -0.6);
	}

	override function onPick() {
		super.onPick();
		api.AKApi.addScore( value );
		fx.popScore(xx,yy, value.get());
		mode.skill += skillValue;
	}

	override function onLand() {
		super.onLand();
		if( bounce++ < 15 )
			dy = -(0.2 + 0.1/bounce);
		else
			dy = -0.2;
	}

	override function update() {
		super.update();
	}
}