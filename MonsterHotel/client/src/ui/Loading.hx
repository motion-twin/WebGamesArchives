package ui;

import mt.deepnight.Tweenie;
import mt.MLib;
import b.Room;
import h2d.SpriteBatch;

class Loading extends H2dProcess {
	static var CURRENT : Loading;

	var sb				: h2d.SpriteBatch;
	var tsb				: h2d.SpriteBatch;
	var ctrap			: h2d.Interactive;
	var mask			: BatchElement;
	var icon1			: BatchElement;
	//var icon2			: BatchElement;
	var onCancel		: Null<Void->Void>;

	public function new(?cb:Void->Void, ?onCancel:Void->Void) {
		cancel();

		super(Game.ME);

		CURRENT = this;
		Main.ME.uiWrapper.add(root, Const.DP_POP_UP);
		this.onCancel = onCancel;

		name = "Loading";
		root.name = name;

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;
		sb.name = name+".sb";

		tsb = new h2d.SpriteBatch(Assets.fontHuge.tile, root);
		tsb.filter = true;
		tsb.name = name+".tsb";

		mask = Assets.tiles.addColoredBatchElement(sb, "white", Const.BLUE, 0.8);
		tw.create(mask.alpha, 0>1, 300);

		icon1 = Assets.tiles.addBatchElement(sb, "loading",0, 0.5,0.5);
		icon1.x = icon1.width*0.5;

		var tf = Assets.createBatchText(tsb, Assets.fontHuge, 48, Lang.t._("Loading..."));
		tf.x = icon1.width+10;
		icon1.y = tf.textHeight*tf.scaleY*0.5;
		//icon2.y = icon1.y;

		ctrap = new h2d.Interactive(4,4);
		Main.ME.uiWrapper.add(ctrap, Const.DP_POP_UP_BG);
		ctrap.onClick = function(_) {
			if( isCancellable() && !cd.has("skip") )
				cancel();
		}

		if( cb!=null )
			delayer.add( function() {
				cb();
			}, 400);

		// Cancel button
		cd.set("skip", 9999);
		if( isCancellable() ) {
			delayer.add( function() {
				cd.unset("skip");
				var tf = Assets.createBatchText(tsb, Assets.fontHuge, 16, Const.TEXT_GOLD, Lang.t._("It takes some time... Click anywhere to cancel."));
				tf.x = icon1.width+10;
				tf.y = 50;
				tf.maxWidth = 350/tf.scaleX;
				tw.create(tf.alpha, 0>1);
			}, #if debug 0 #else 3500 #end);
		}

		onResize();
	}

	override function onDispose() {
		super.onDispose();

		icon1 = null;
		//icon2 = null;

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		ctrap.dispose();
		ctrap = null;

		mask = null;

		if( CURRENT==this )
			CURRENT = null;
	}

	override function onResize() {
		super.onResize();

		root.x = w()*0.5 - root.width*0.5;
		root.y = h()*0.5 - root.height*0.5;
		mask.width = ctrap.width = w();
		mask.height = ctrap.height = h();
		mask.x = -root.x;
		mask.y = -root.y;
	}


	public static function exists() {
		return CURRENT!=null;
	}


	public static function isCancellable() {
		return CURRENT!=null && CURRENT.onCancel!=null;
	}

	public static function cancel() {
		if( CURRENT!=null ) {
			if( CURRENT.onCancel!=null )
				CURRENT.onCancel();
			CURRENT.destroy();
			CURRENT = null;
		}
	}

	override function update() {
		super.update();

		icon1.rotation+=0.23;
		//icon2.rotation+=0.20;
	}
}


