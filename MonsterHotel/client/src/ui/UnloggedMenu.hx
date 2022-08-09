package ui;

import mt.MLib;
import mt.data.GetText;
import com.*;
import com.Protocol;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

#if !connected
#error "Requires connection"
#end

class UnloggedMenu extends H2dProcess {
	public static var CURRENT : UnloggedMenu;

	var shotel(get,null)	: com.SHotel; inline function get_shotel() return Game.ME.shotel;
	var sb					: SpriteBatch;
	var tsb					: SpriteBatch;
	var iwrapper			: h2d.Sprite;
	var isize = 128;
	var bwid = 700;

	public function new() {
		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_UNLOGGED);

		CURRENT = this;
		name = "VisitMenu";
		root.y = h();
		iwrapper = new h2d.Sprite(root);

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;

		tsb = new h2d.SpriteBatch(Assets.fontHuge.tile, root);
		tsb.filter = true;

		createButton( Lang.t._("You are not connected"), Lang.t._("You should log in if you want to save your progression."), "iconUse", function() {
			if( !cd.hasSet("click", Const.seconds(1)) )
				mt.device.User.login();
		});
	}


	function createButton(label:String, subLabel:Null<String>, icon:String, ?counter=0, ?cb:Void->Void) {
		// Ask to play again (long absence)
		var dark = Assets.tiles.addBatchElement(sb, "notifBg",0);
		dark.x = isize*0.5;
		dark.y = 10;
		dark.width = bwid-dark.x;
		dark.height = isize-dark.y*2;
		dark.alpha = 0.9;

		if( cb!=null ) {
			var bg = Assets.tiles.addBatchElement(sb, "btnBlankBig",1);
			bg.setScale( isize/bg.width );
		}

		var icon = Assets.tiles.addBatchElement(sb, icon,0, 0.5,0.5);
		icon.setScale( isize*(cb==null?1:0.65)/icon.width );
		icon.x = isize*0.5;
		icon.y = isize*0.5 + (cb==null?0:-3);

		if( counter>0 ) {
			var tf = Assets.createBatchText(tsb, Assets.fontHuge, 40, 0xFFFFFF, cast Std.string(counter));
			tf.x = icon.x - tf.textWidth*tf.scaleX*0.5;
			tf.y = icon.y - tf.textHeight*tf.scaleY*0.5;
		}

		var tf = Assets.createBatchText(tsb, Assets.fontHuge, 28, subLabel==null ? Const.TEXT_GRAY : 0xFFFFFF, cast label);
		tf.dropShadow = { color:0x0, alpha:1, dx:2, dy:3 }
		tf.x = isize + 5;
		tf.y = isize*0.5 - tf.textHeight*tf.scaleY * (subLabel==null?0.5:1);
		tf.maxWidth = (bwid - tf.x) / tf.scaleX;
		var tf1 = tf;

		if( subLabel!=null ) {
			var tf = Assets.createBatchText(tsb, Assets.fontHuge, 19, Const.TEXT_GRAY, cast subLabel);
			tf.dropShadow = { color:0x0, alpha:1, dx:2, dy:3 }
			tf.x = isize + 5;
			tf.maxWidth = (bwid - tf.x) / tf.scaleX;
			var h = tf1.textHeight*tf1.scaleY + tf.textHeight*tf.scaleY;
			tf1.y = isize*0.5 - h*0.5;
			tf.y = tf1.y + tf1.textHeight*tf1.scaleY;
		}

		if( cb!=null ) {
			var i = new h2d.Interactive(bwid, isize, iwrapper);
			i.onClick = function(_) {
				Assets.SBANK.click1(1);
				cb();
			}

			createChildProcess(function(_) {
				if( itime%30==0 )
					Game.ME.uiFx.ping(root.x + icon.x, root.y + icon.y, "fxNovaBlue");
			});
		}


		return tf1;
	}


	override function onDispose() {
		super.onDispose();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		iwrapper = null;

		if( CURRENT==this )
			CURRENT = null;
	}

	override function onResize() {
		super.onResize();

		root.setScale( Main.getScale(50, 0.55) );

		root.x = w()*0.5 - root.width*0.5;
		root.y = h()*0.85 - root.height*0.5;
	}
}
