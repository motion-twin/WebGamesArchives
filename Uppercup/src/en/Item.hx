package en;

class Item extends Entity {
	public static var ALL : Array<Item> = [];

	public var locked	: Bool;
	var color			: Int;

	public function new() {
		super();
		ALL.push(this);

		color = 0xFFFF17;
		locked = false;
		frict = 0.88;
		fl_collide = false;

		var m = 4; // en nb de cases!
		var pt = {cx:0., cy:0.}
		do {
			pt.cx = rnd(Const.FPADDING+m, Const.FPADDING+Const.FWID-m);
			pt.cy = rnd(Const.FPADDING+m, Const.FPADDING+Const.FHEI-m);
		} while( pt.cx<=Const.FPADDING+8 && pt.cy>=Const.FPADDING+Const.FHEI*0.3 && pt.cy<= Const.FPADDING+Const.FHEI*0.7 );
		xx = Const.GRID * pt.cx;
		yy = Const.GRID * pt.cy;
		updateFromScreenCoords();

		cd.set("shine", Const.FPS * (Math.random()*3));
	}

	public override function unregister() {
		super.unregister();
		ALL.remove(this);
	}

	//public function onRepop() {
		//if( killOnRepop )
			//if( locked )
				//pickUp();
			//else {
				//fx.smokePop(xx, yy);
				//destroy();
			//}
	//}

	public function pickUp() {
		destroy();
		fx.hit(xx,yy, 1);
	}

	public override function update() {
		super.update();

		var b = game.ball;

		var d = mt.deepnight.Lib.distanceSqr(xx,yy, b.xx,b.yy);
		if( !locked ) {
			var grabDist = 100;
			var minZ = 999;
			if( game.isPlaying() && b.z<=minZ && !locked ) {
				if( d<=grabDist*grabDist )
					if( Math.sqrt(d)<=grabDist ) {
						spr.blendMode = flash.display.BlendMode.ADD;
						locked = true;
						removeShadow();
					}
			}
		}

		if( locked ) {
			var a = Math.atan2(b.yy-yy, b.xx-xx);
			dx += Math.cos(a)*0.11;
			dy += Math.sin(a)*0.11;
			if( Math.sqrt(d)<=10 )
				pickUp();
		}

		if( !game.lowq && !cd.has("spark") && onScreen() ) {
			cd.set("spark", mt.deepnight.Lib.rnd(10,20));
			fx.itemSpark(xx,yy);
		}
	}
}
