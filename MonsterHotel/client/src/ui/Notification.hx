package ui;

import mt.deepnight.Tweenie;
import mt.data.GetText;
import mt.MLib;
import b.Room;
import h2d.SpriteBatch;

class NotificationManager extends H2dProcess {
	public static var CURRENT : NotificationManager;
	public var all				: Array<Notification>;
	public var sb				: SpriteBatch;
	public var tsb				: SpriteBatch;

	public function new() {
		super( Game.ME );

		Main.ME.uiWrapper.add(root, Const.DP_NOTIFICATION);

		name = "NotificationManager";
		CURRENT = this;
		all = [];

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;

		tsb = new h2d.SpriteBatch(Assets.fontHuge.tile, root);
		tsb.filter = true;
	}

	override function onDispose() {
		super.onDispose();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		all = null;

		if( CURRENT==this )
			CURRENT = null;
	}

	public function updatePositions() {
		var y = Main.ME.h()*0.5;
		for( n in all ) {
			if( n.group.y==0 )
				n.group.y = Std.int(y);
			else
				n.tw.create(n.group.y, Std.int(y), 300).pixel();
			y-=80;
		}
	}

	override function onResize() {
		super.onResize();
		updatePositions();
	}


	public static function clearAll() {
		if( CURRENT!=null )
			for(n in CURRENT.all)
				n.destroy();
	}

}


class Notification extends mt.Process {
	public var group		: BatchGroup;

	public function new(str:LocaleString, ?col=0xFFFFFF, ?iconId:String) {
		var man = NotificationManager.CURRENT;
		super(man);

		var str = Std.string(str);
		man.all.insert(0, this);
		group = new BatchGroup(man.sb, man.tsb);

		var scale = Main.getScale(32,0.3);

		var bg = Assets.tiles.addBatchElement(man.sb, "notifBg",0);
		bg.x = -20;
		group.add(bg);

		var tf = Assets.createBatchText(man.tsb, Assets.fontHuge, str);
		tf.scale( scale * (str.length>=15 ? 0.4 : 0.55) );
		tf.maxWidth = (w()*0.4) / tf.scaleX;
		tf.dropShadow = { color:0x0, alpha:0.8, dx:1, dy:5 }
		tf.textColor = col;
		group.add(tf);

		bg.width = tf.textWidth*tf.scaleX + 20 + 40;
		bg.height = tf.textHeight*tf.scaleY;

		var e = Assets.tiles.addBatchElement(man.sb, "enluminure",0);
		e.tile.setCenter(9,9);
		e.rotation = -1.57;
		e.x = -24;
		e.setScale(scale);
		group.add(e);

		var e = Assets.tiles.addBatchElement(man.sb, "enluminure",0);
		e.tile.setCenter(9,9);
		e.rotation = -1.57;
		e.scaleX = -1;
		e.x = -24;
		e.y = bg.height;
		e.setScale(scale);
		group.add(e);

		if( iconId!=null ) {
			var icon = Assets.tiles.addBatchElement(man.sb, iconId,0, 0,0.5);
			icon.x = tf.textWidth*tf.scaleX + 5;
			icon.y = Std.int( tf.textHeight*tf.scaleY*0.5 );
			icon.setScale( scale * 50 / icon.height );
			group.add(icon);
		}

		group.x = -bg.width;
		tw.create(group.x, 20, 350).pixel();

		delayer.add( function() {
			tw.create(group.x, -bg.width*0.5, 200).onEnd = destroy;
		}, 3800+str.length*25);

		NotificationManager.CURRENT.updatePositions();
	}

	override function onDispose() {
		super.onDispose();

		group.dispose();
		group = null;

		NotificationManager.CURRENT.all.remove(this);
	}
}


