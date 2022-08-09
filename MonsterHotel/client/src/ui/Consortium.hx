package ui;

import mt.MLib;
import mt.data.GetText;
import com.Protocol;
import com.GameData;
import com.*;
import mt.deepnight.Tweenie;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

class Consortium extends H2dProcess {
	public static var CURRENT : Consortium;

	public var ctrap		: h2d.Interactive;
	var mask				: h2d.Bitmap;
	var wrapper				: h2d.Sprite;
	var sb					: h2d.SpriteBatch;
	var tsb					: h2d.SpriteBatch;
	var bg					: BatchElement;
	var shotel(get,never)	: com.SHotel; inline function get_shotel() return Game.ME.shotel;
	var texts				: Array<TextBatchElement>;
	var delayButtons		: Bool;

	public function new(?delayButtons=false) {
		CURRENT = this;
		super();

		Game.ME.pause();
		Main.ME.uiWrapper.add(root, Const.DP_POP_UP);

		Assets.SBANK.slide1(0.5);

		this.delayButtons = delayButtons;
		texts = [];
		name = 'Reward';

		ctrap = new h2d.Interactive(8,8,root);
		//ctrap.onClick = function(_) {
			//destroy();
		//}

		mask = new h2d.Bitmap( h2d.Tile.fromColor(alpha(Const.BLUE, 0.93)), root );
		mask.alpha = 0;
		tw.create(mask.alpha, 1, 300);


		wrapper = new h2d.Sprite(root);

		sb = new h2d.SpriteBatch(Assets.tiles1.tile, wrapper);
		sb.filter = true;

		tsb = new h2d.SpriteBatch(Assets.fontHuge.tile, wrapper);
		tsb.filter = true;

		bg = Assets.tiles1.addBatchElement(sb, "consortium",0, 0.5,0.5);

		createButton(0,110, Lang.t._("Ok"),0, function() {
			destroy();
		});

		wrapper.visible = false;
		onNextUpdate = function() {
			wrapper.visible = true;
			onResize();
			var s = wrapper.scaleX;
			wrapper.setScale(0.2);
			tw.create(wrapper.scaleX, s, TElasticEnd, 600).update( function() wrapper.scaleY = wrapper.scaleX );
		}
	}

	public function addLine(str:LocaleString, ?col=0x703518, ?alpha=1.0) {
		var tf = Assets.createBatchText(tsb, Assets.fontHuge, 19, col, Lang.addNbsps(str));
		texts.push(tf);
		tf.maxWidth = bg.width*0.8/tf.scaleX;
		//tf.text = Lang.t._("If you think you can handle it, we can send you a Consortium Inspector. Make him happy (like in \"VERY happy\") and we will grant your hotel a new STAR and unlock new content!");
		tf.dropShadow = { color:0xfbdaa8, alpha:0.7, dx:0, dy:4 }
		tf.x = -bg.width*0.4;
		tf.alpha = alpha;
		updateTexts();
	}

	function updateTexts() {
		var th = 0.;
		for(tf in texts)
			th+=tf.textHeight*tf.scaleY;

		var m = 10;
		var y = -th*0.5 - (texts.length-1)*m;
		for(tf in texts) {
			tf.y = y;
			y += tf.textHeight*tf.scaleY + m;
		}
	}

	function createButton(x:Float,y:Float, label:LocaleString, frame:Int, ?icon:String, cb:Void->Void) {
		var s = Assets.tiles1.addBatchElement(sb, "btnConsortium",frame);
		s.setPos(x-s.width*0.5, y);
		s.scaleX = 1.2;
		var i = new h2d.Interactive(s.width,s.height, wrapper);
		i.setPos(s.x, s.y);
		i.setSize(s.width, s.height);
		i.onClick = function(_) {
			Assets.SBANK.click1(1);
			cb();
		}

		var tf = Assets.createBatchText(tsb, Assets.fontHuge, label.length>10 ? 22 : 25, 0xffffff, label );
		tf.x = s.x + s.width*0.5 - tf.textWidth*tf.scaleX*0.5;
		tf.y = s.y + s.height*0.5 - tf.textHeight*tf.scaleY*0.5;

		if( icon!=null ) {
			var s = Assets.tiles.getH2dBitmap(icon, 0.5,0.5, true, wrapper);
			s.x = tf.x + tf.textWidth*tf.scaleX;
			s.y = tf.y + tf.textHeight*tf.scaleY*0.5;
			s.scale(0.6);
			tf.x-=s.width*0.5 + 5;
		}

		if( delayButtons ) {
			s.alpha = 0;
			tf.alpha = 0;
			i.visible = false;
			tw.create(s.alpha, 1500|1, 400).start( function() {
				i.visible = true;
			}).update( function() {
				tf.alpha = s.alpha;
			});
		}

		//if( cost>0 ) {
			//tf.y-=15;
//
			//var c = Assets.createBatchText(tsb, Assets.fontHuge, 22, Const.BLUE, Lang.t._("Costs ::n::", {n:Game.ME.prettyMoney(cost)}) );
			//c.x = s.x + s.width*0.5 - c.textWidth*c.scaleX*0.5;
			//c.y = s.y + s.height*0.5 - c.textHeight*c.scaleY*0.5 + 15;
		//}
	}

	override function onResize() {
		super.onResize();

		wrapper.x = Std.int( w()*0.5 );
		wrapper.y = Std.int( h()*0.5 );
		if( hcm()>=10 )
			wrapper.setScale( MLib.fmin( w()*0.5/bg.width, h()*0.8/bg.height ) );
		else {
			var tw = tsb.width;
			wrapper.setScale( w()*0.6/(tw==0?1:tw) );
		}

		mask.width = w();
		mask.height = h();

		ctrap.width = w();
		ctrap.height = h();
	}


	override function onDispose() {
		super.onDispose();

		texts = null;
		Game.ME.resume();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		bg = null;
		mask = null;
		ctrap = null;
		wrapper = null;

		CURRENT = null;
	}

}