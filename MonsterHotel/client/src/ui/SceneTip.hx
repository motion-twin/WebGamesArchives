package ui;

import mt.data.GetText;
import mt.deepnight.Tweenie;
import mt.MLib;
import b.Room;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

class SceneTip extends mt.Process {
	public static var CURRENT : SceneTip;

	var bg				: BatchElement;
	var tf				: TextBatchElement;

	private function new(x:Float, y:Float, str:LocaleString, ?col:Int) {
		clear();
		super(Game.ME);

		if( col==null )
			col = 0xFFFFFF;

		CURRENT = this;
		name = "SceneTip";
		y-=120;

		var scale = 1;

		bg = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, -100, "sceneNotifBg", 0, 0, 0);

		tf = Assets.createBatchText(Game.ME.textSbHuge, Assets.fontHuge, str);
		tf.scale(0.5*scale);
		tf.textColor = col;
		tf.maxWidth = 800/tf.scaleX;
		tf.x = x - tf.textWidth*tf.scaleX*0.5;
		tf.y = y - tf.textHeight*tf.scaleY - 30;
		tf.dropShadow = { dx:0, dy:5, color:0x0, alpha:0.8 }

		var p = 20;
		bg.setPos(tf.x-p, tf.y-p);
		bg.width = tf.textWidth*tf.scaleX + 20 + p*2;
		bg.height = tf.textHeight*tf.scaleY+2 + p*2;

		tw.create(tf.y, bg.y-30, TLoop, 500);
		tw.create(bg.y, bg.y-30, TLoop, 500);

		onResize();

		delayer.add( function() {
			tw.create(tf.alpha, 0, 1000).end(destroy).update(function() {
				bg.alpha = tf.alpha;
			});
		}, 3000);
	}

	public static function clear() {
		if( CURRENT!=null && !CURRENT.destroyed )
			CURRENT.destroy();
	}

	override function onDispose() {
		super.onDispose();

		tf.dispose();
		tf = null;

		bg.remove();
		bg = null;

		if( CURRENT==this )
			CURRENT = null;
	}

	override function onResize() {
		super.onResize();
	}
}

