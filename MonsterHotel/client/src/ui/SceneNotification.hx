package ui;

import mt.data.GetText;
import mt.deepnight.Tweenie;
import mt.MLib;
import b.Room;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

class SceneNotification extends mt.Process {
	public static var ALL : Array<SceneNotification> = [];

	var group			: BatchGroup;
	var room			: Null<b.Room>;
	var entity			: Null<Entity>;
	var icon			: Null<BatchElement>;
	var bg				: BatchElement;
	var tf				: TextBatchElement;
	var dy				: Float;
	//var xx				: Float;
	//var yy				: Float;

	public static inline function onRoom(r:b.Room, str:LocaleString, ?c, ?i, ?b) {
		return new ui.SceneNotification(r, null, str, c, i, b);
	}
	public static inline function onEntity(e:Entity, str:LocaleString, ?c, ?i, ?b) {
		return new ui.SceneNotification(null, e, str, c, i, b);
	}

	private function new(r:b.Room, e:Entity, str:LocaleString, ?col=0xFFFFFF, ?iconId:String, ?big=false) {
		super(Game.ME);

		group = BatchGroup.createSceneGroup();

		var scale = big ? 2 : 1;

		// Push existing notifs upward
		for( n in ALL )
			if( !n.destroyed && (e!=null && n.entity==e) || (r!=null && n.room==r) )
				n.dy-=11*scale;

		ALL.push(this);
		dy = -20;
		name = "SNotif("+str.substr(0,15)+")";
		room = r;
		entity = e;

		bg = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, -100, "sceneNotifBg", 0, 0, 0.5);
		group.add(bg);

		tf = Assets.createBatchText(Game.ME.textSbHuge, Assets.fontHuge, str);
		tf.scale(0.5*scale);
		tf.textColor = col;
		tf.x+=10;
		tf.y-=tf.textHeight*tf.scaleY*0.5;
		group.add(tf);

		bg.width = tf.textWidth*tf.scaleX + 20;
		bg.height = tf.textHeight*tf.scaleY+2;

		if( iconId!=null ) {
			icon = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, -101, iconId,0, 0.5,0.5);
			icon.setScale(scale*70/icon.height);
			tf.x+=icon.width*0.5 + 5;
			bg.width += icon.width*0.5 + 5;
			group.add(icon);
		}


		if( room!=null ) {
			group.x = room.xx + room.wid*0.5 - bg.width*0.5;
			group.y = room.yy + room.hei*0.5 - bg.height*0.5;
		}

		if( entity!=null ) {
			group.x = entity.centerX - bg.width*0.5;
			group.y = entity.centerY - entity.hei*0.5 - bg.height*0.5;
		}
		onResize();

		cd.set("alive", Const.seconds(1.9)+str.length*1.2);
	}

	override function onDispose() {
		super.onDispose();

		group.dispose();

		tf = null;
		icon = null;
		bg = null;

		room = null;
		entity = null;

		ALL.remove(this);
	}

	public static function clear() {
		for(n in ALL)
			n.destroy();
	}

	override function onResize() {
		super.onResize();
	}

	override function update() {
		super.update();

		group.y+=dy;
		dy*=0.8;

		if( !cd.has("alive") ) {
			group.alpha-=0.04;

			if( group.alpha<=0 )
				destroy();
		}
	}
}

