package page;

import mt.MLib;
import h2d.SpriteBatch;
import h2d.TextBatchElement;
import mt.deepnight.Tweenie;

class Test extends H2dProcess {

	public function new() {
		super(Main.ME, Main.ME.uiWrapper);

		var e = Assets.tiles.getH2dBitmap("moneyLove", root);
		e.x = 200;
		e.y = 200;

		var sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		var tsb = new h2d.SpriteBatch(Assets.fontNormal.tile, root);

		var g = new BatchGroup(sb,tsb);
		var e = Assets.tiles.addBatchElement(sb, "moneyLove",0);
		e.y = 200;
		g.addChild(e);

		var e = Assets.tiles.addBatchElement(sb, "moneyLove",0);
		e.x = 50;
		e.y = 200;
		g.addChild(e);

		createTinyProcess(function(_) {
			g.x = rnd(0,1);
			//if( !cd.hasSet("tick", Const.seconds(1)) )
				//g.x+=10;
		});


		onResize();
	}

	override function unregister() {
		super.unregister();
	}


	override function onResize() {
		super.onResize();
	}


	override function update() {
		super.update();
	}
}