package en.it;

#error "deprecated"

class Score extends en.Item {
	var value			: Int;
	var big				: Bool;

	public function new(big:Bool) {
		super();
		this.big = big;

		fl_repop = !big;

		var mc = new lib.Bonus();
		mc.y+=2;

		var frame = 1;
		if( !big ) {
			// truc banal
			var rlist = new mt.RandList();
			rlist.add(1, 100);
			rlist.add(2, 40);
			frame = rlist.draw(rseed.random);

			color = switch(frame) {
				case 1 : 0x6FB5FB;
				case 2 : 0xE81785;
				default : 0x0;
			}

			value = switch(frame) {
				case 1 : 50;
				case 2 : 250;
				default : 0;
			}
		}
		else {
			// gros bonus
			color = 0xFFFF00;
			var rlist = new mt.RandList();
			rlist.add(3, 100);
			rlist.add(4, 60);
			rlist.add(5, 30);
			rlist.add(6, 8);
			rlist.add(7, 2);
			frame = rlist.draw(rseed.random);
			value = switch( frame ) {
				//case 3 : api.AKApi.const(1000);
				//case 4 : api.AKApi.const(1250);
				//case 5 : api.AKApi.const(1500);
				//case 6 : api.AKApi.const(1750);
				//case 7 : api.AKApi.const(2000);
				//default : api.AKApi.const(1500);
				case 3 : 500;
				case 4 : 750;
				case 5 : 1000;
				case 6 : 1500;
				case 7 : 2000;
				default : 500;
			}
			mc.filters = [
				new flash.filters.GlowFilter(0xFFFF00, 0.9, 8,8,1, 2),
				new flash.filters.GlowFilter(0xFFCC00, 0.9, 32,32,2, 2),
			];
		}

		mc.gotoAndStop(frame);
		spr.addChild( mt.deepnight.Lib.flatten(mc,40) );

		delayPop(35 + rseed.random(20));
	}

	public function delayPop(frames:Int) {
		fl_active = false;
		spr.visible = false;
		spr.alpha = 0;
		cd.set("spawn", frames);
		cd.onComplete("spawn", function() {
			activate();
		});
	}

	override public function activate() {
		super.activate();
		spr.alpha = 0;
	}

	public override function pickUp() {
		super.pickUp();
		game.addStat("bonus", 1);
		game.addScore(value, "item_"+big);
		fx.popScore(xx,yy, value, color, big);
		fx.pick(xx,yy, color);
		destroy();
	}

	public override function update() {
		if( !cd.has("spawn") && spr.alpha<1 ) {
			spr.alpha+=0.1;
			if( spr.alpha>1 )
				spr.alpha = 1;
		}

		super.update();
	}
}
