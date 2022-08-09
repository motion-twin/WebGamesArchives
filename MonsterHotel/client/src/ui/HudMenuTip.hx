package ui;

import mt.deepnight.Tweenie;
import mt.deepnight.Color;
import mt.MLib;
import mt.data.GetText;
import b.Room;
import com.Protocol;

class HudMenuTip extends H2dProcess {
	public static var ALL : Array<HudMenuTip> = [];

	var sb				: h2d.SpriteBatch;
	var tsb				: h2d.SpriteBatch;
	public var important: Bool;
	public var btId		: String;
	public var btPt		: {x:Float, y:Float};
	var closing			: Bool;
	var wid				: Float;
	var hei				: Float;

	public function new(bt:String, ?col:Int, title:String, ?body:String, ?iconId:String, ?important=false) {
		if( important )
			clear(bt);

		super(Game.ME);

		btId = bt;
		closing = false;
		Main.ME.uiWrapper.add(root, Const.DP_NOTIFICATION);
		this.important = important;

		ALL.push(this);
		var maxWid = 320;
		var px = 20;
		var py = 10;
		if( col==null )
			col = Const.BLUE;

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;

		tsb = new h2d.SpriteBatch(Assets.fontHuge.tile, root);
		tsb.filter = true;

		var bg = Assets.tiles.addBatchElement(sb, "popUpBg", 0);
		bg.color = h3d.Vector.fromColor( alpha(Color.clampBrightnessInt(col, 0, 0.2)) );
		var top = Assets.tiles.addBatchElement(sb, "popUpTop", 0);
		var bottom = Assets.tiles.addBatchElement(sb, "popUpBottom", 0);

		// Title
		var tf = Assets.createBatchText(tsb, Assets.fontHuge, body!=null?24:20, title);
		tf.textColor = important ? Color.clampBrightnessInt(col, 0.9, 1) : 0xFFFFFF;
		tf.x = px;
		tf.y = py;
		tf.maxWidth = maxWid/tf.scaleX;
		tf.dropShadow = { color:0x0, alpha:0.8, dx:0, dy:3 }
		var ttf = tf;

		// Body
		var tf = Assets.createBatchText(tsb, Assets.fontHuge, 20, body==null?cast "":body);
		tf.textColor = 0xCDD0E9;
		tf.x = px;
		tf.y = ttf.visible ? ttf.y + 6 + ttf.textHeight*ttf.scaleY : 0;
		tf.maxWidth = maxWid/tf.scaleX;
		tf.dropShadow = { color:0x0, alpha:0.8, dx:0, dy:3 }
		var btf = tf;

		wid = MLib.fmax( 150, MLib.fmax( ttf.textWidth*ttf.scaleX, tf.textWidth*tf.scaleX ) ) + px*2;
		hei = tsb.height + py*2;
		bg.width = wid;
		bg.height = hei;
		bg.alpha = important ? 1 : 0.7;

		// Icon
		if( iconId!=null ) {
			var e = Assets.tiles.addBatchElement(sb, iconId, 0);
			e.tile.setCenterRatio(0, 0.5);
			e.x = 0;
			e.y = hei*0.5;
			e.setScale( MLib.fmin(64/e.width, 64/e.height) );
			var d = e.width + 5;
			wid+=d;
			btf.x+=d;
			ttf.x+=d;
			bg.width+=d;
		}

		bottom.y = bg.height;
		top.width = bottom.width = bg.width;

		if( !important ) {
			cd.set("alive", Const.seconds(2));
			cd.onComplete("alive", hide);
		}

		root.x = getHiddenX();
		onResize();
	}

	function isLeft() return btId.indexOf("quest")>=0;
	function getHiddenX() return isLeft() ? -wid-50 : w()+50;

	public static function updateCoords() {
		for(e in ALL ) {
			switch( e.btId) {
				case "quests" : if( ui.side.Quests.CURRENT.isOpen ) e.hide();
				case "custom" : if( ui.side.CustomizeMenu.CURRENT.isOpen ) e.hide();
			}
			e.onResize();
		}
	}

	public function addItemIcon(i:Item, ?hasBg=false) {
		var bg = Assets.tiles.addColoredBatchElement(sb, "popUpBg", Const.BLUE);
		bg.tile.setCenterRatio(1, 0.5);

		var bmp : h2d.Bitmap = switch( i ) {
			case I_Bath(f) : Assets.custo0.getH2dBitmap("bath", f);
			case I_Bed(f) : Assets.custo0.getH2dBitmap("bed", f);
			case I_Ceil(f) : Assets.custo0.getH2dBitmap("ceil", f);
			case I_Furn(f) : Assets.custo0.getH2dBitmap("furn", f);
			case I_Wall(f) : Assets.custo0.getH2dBitmap("wall", f);
			case I_Cold, I_Heat, I_Odor, I_Noise, I_Light :
				Assets.tiles.getH2dBitmap(Assets.getItemIcon(i));
			default : Assets.tiles.getH2dBitmap("iconTodoRed");
		}
		root.addChild(bmp);
		bmp.filter = true;
		bmp.tile.setCenterRatio(1, 0.5);
		bmp.setScale( MLib.fmin(90/bmp.tile.width, 60/bmp.tile.height) );
		bmp.x = -10;
		bmp.y = hei*0.5;

		bg.x = bmp.x+10;
		bg.y = bmp.y;
		bg.width = bmp.width+20;
		bg.height = bmp.height+20;
		bg.visible = hasBg;

		onResize();
	}

	function hide() {
		if( closing )
			return;

		closing = true;
		tw.create( root.x, getHiddenX(), 250 ).onEnd = destroy;
	}

	public static function item(i:Item, ?n=1) {
		var sub = Lang.t._("New item obtained!");
		switch( i ) {
			case I_Cold, I_Heat, I_Odor, I_Noise, I_Light :
				var e = new ui.HudMenuTip("items", Const.TEXT_GOLD, cast Lang.getItem(i).name+" (x"+n+")", sub);
				e.addItemIcon(i);

			case I_Bath(_), I_Bed(_), I_Ceil(_), I_Furn(_), I_Wall(_) :
				var e = new ui.HudMenuTip("custom", Const.TEXT_GOLD, cast Lang.getItem(i).name+" (x"+n+")", sub);
				e.addItemIcon(i, true);

			case I_Color(_) :
				var e = new ui.HudMenuTip("custom", Const.TEXT_GOLD, cast Lang.getItem(i).name+" (x"+n+")", sub, "iconPaint");

			case I_Texture(_) :
				var e = new ui.HudMenuTip("custom", Const.TEXT_GOLD, cast Lang.getItem(i).name+" (x"+n+")", sub, "iconPaint");

			default :
		}
	}

	public static function clear(?btId:String, ?immediate=false) {
		for(e in ALL)
			if( btId==null || e.btId==btId )
				if( immediate )
					e.destroy();
				else
					e.hide();
	}

	override function onDispose() {
		super.onDispose();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		ALL.remove(this);
	}

	override function onResize() {
		super.onResize();

		if( closing )
			return;

		root.setScale( Main.getScale(hei, 0.6) );

		if( btId.indexOf("quest_")==0 )
			btPt = ui.QuestLog.CURRENT.getQuestCoord(btId.substr(6));
		else
			btPt = ui.HudMenu.CURRENT.getButtonCoord(btId);

		if( btPt!=null ) {
			root.visible = true;
			root.y = MLib.fmax( 10, btPt.y - root.scaleY*hei*0.5 );
		}
		else
			root.visible = false;
	}

	override function update() {
		super.update();

		if( !closing && btPt!=null ) {
			var x = btPt.x + (important ? (isLeft()?1:-1) * MLib.fabs(Math.cos(ftime*0.13)*25) : 0);
			root.x += ( (x + (isLeft() ? 120 : -wid-60)*root.scaleX) - root.x )*0.35;
		}

		if( Game.ME.tuto.isRunning() && root.visible )
			root.visible = false;

		if( !Game.ME.tuto.isRunning() && !root.visible && ftime%30==0 )
			onResize();
	}
}

