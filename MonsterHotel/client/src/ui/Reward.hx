package ui;

import mt.data.GetText;
import mt.MLib;
import com.Protocol;
import com.GameData;
import mt.deepnight.Tweenie;

class Reward extends H2dProcess {
	public var ctrap		: h2d.Interactive;
	var mask				: h2d.Bitmap;
	var wrapper				: h2d.Sprite;
	var fx					: Fx;

	public function new() {
		super();
		Main.ME.uiWrapper.add(root, Const.DP_POP_UP);

		Assets.SBANK.cashRegister(1);

		name = 'Reward';

		ctrap = new h2d.Interactive(8,8,root);
		ctrap.onClick = function(_) {
			close();
		}

		mask = new h2d.Bitmap( h2d.Tile.fromColor(alpha(Const.BLUE, 0.93)), root );
		mask.alpha = 0;
		tw.create(mask.alpha, 1, 300);

		wrapper = new h2d.Sprite(root);

		wrapper.setScale(0.5);
		tw.create(wrapper.scaleX, 1, 300).onUpdate = function() wrapper.scaleY = wrapper.scaleX;
		delayer.add( function() {
			tw.create(wrapper.scaleX, 1.25, 1500).onUpdate = function() wrapper.scaleY = wrapper.scaleX;
		}, 500);

		delayer.add(close, 2000);

		fx = new Fx(this, root);

		cd.set("click", Const.seconds(0.5));
		onResize();
	}

	public function addItem(item:Item, n:Int) {
		n *= switch( item ) {
			case I_Money(v) : v;
			default : 1;
		}

		var tf = new h2d.Text(Assets.fontNormal, wrapper);
		tf.text = Lang.t._("You received:");
		tf.textColor = switch( item ) {
			case I_Gem : Const.TEXT_GEM;
			case I_Money(_) : Const.TEXT_GOLD;
			default : 0xffffff;
		}
		tf.filter = true;
		tf.scale(0.8);
		tf.x = Std.int( -tf.width*tf.scaleX*0.5 );
		tf.y = Std.int( -tf.height*tf.scaleY*0.5 - 75 );

		var s = new h2d.Sprite(wrapper);
		var tf = new h2d.Text(Assets.fontHuge, s);
		tf.text = "+"+Game.ME.prettyNumber(n);
		tf.textColor = 0xffffff;
		tf.filter = true;

		var i = Assets.tiles.getH2dBitmap(Assets.getItemIcon(item), true, s);
		i.setScale( MLib.fmin(100/i.width, 100/i.height) );
		i.x = tf.width*tf.scaleX + 10;
		tf.y = i.height*0.5 - tf.height*tf.scaleY*0.5;
		s.x = Std.int( -s.width*0.5 );
		s.y = Std.int( -s.height*0.5 );

		fx.rewardItem( w()*0.5, h()*0.5, true );
	}

	public function addText(small:LocaleString, str:LocaleString, ?col=0xFFD648) {
		var tf = Assets.createText(24, Const.TEXT_GRAY, small, wrapper);
		tf.x = Std.int( -tf.width*tf.scaleX*0.5 );
		tf.y = Std.int( -tf.height*tf.scaleY*0.5-30 );

		var tf = Assets.createText(60, col, str, wrapper);
		tf.x = Std.int( -tf.width*tf.scaleX*0.5 );
		tf.y = Std.int( -tf.height*tf.scaleY*0.5+30 );

		fx.rewardItem( w()*0.5, h()*0.5, true );
	}

	//public function newStar(l:Int) {
		//Game.ME.pause();
//
		//var tf = new h2d.Text(Assets.fontNormal, wrapper);
		//tf.text = Lang.t._("New hotel star!");
		//tf.textColor = Const.TEXT_GOLD;
		//tf.filter = true;
		//tf.scale(0.8);
		//tf.x = Std.int( -tf.width*tf.scaleX*0.5 );
		//tf.y = Std.int( -tf.height*tf.scaleY*0.5 - 75 );
//
		//var i = Assets.tiles.getH2dBitmap("star",0, 0.5,0.5, true, wrapper);
		//i.setScale( MLib.fmin(100/i.width, 100/i.height) );
//
		//fx.rewardMaxedHappiness(w()*0.5, h()*0.5);
	//}


	//public function maxHappiness(c:en.Client) {
		//Game.ME.pause();
//
		//var tf = Assets.createText(60, Const.TEXT_GOLD, Lang.t._("Client happiness maxed!"), wrapper);
		//tf.x = Std.int( -tf.width*tf.scaleX*0.5 );
		//tf.y = Std.int( -145 );
//
		//var all = [
			//Lang.t._("Best hotel ever! I love it!"),
			//Lang.t._("Such a lovely place!"),
			//Lang.t._("I will definitely recommend this hotel!"),
			//Lang.t._("Take my money! NOW!"),
			//Lang.t._("OMG OMG OMG! Such an amazing place!"),
			//Lang.t._("This hotel is totally EPIC!"),
		//];
		//var quote = all[Std.random(all.length)];
		//var tf = Assets.createText(22, Const.TEXT_GEM, "\""+quote+"\"", wrapper);
		//tf.x = Std.int( -tf.width*tf.scaleX*0.5 );
		//tf.y = Std.int( -80 );
//
		//var i = Assets.getClientIcon(c.type, wrapper);
		//i.x = -i.width*0.5;
		//i.y = -40;
//
		//fx.rewardMaxedHappiness(w()*0.5, h()*0.5);
	//}

	function close() {
		if( cd.has("click") )
			return;

		cd.set("click", 99999);
		ctrap.visible = false;
		tw.create(wrapper.scaleX, 0.01, 600).onUpdate = function() wrapper.scaleY = wrapper.scaleX;
		tw.create(mask.alpha, 0, 600).onEnd = destroy;

		if( Game.ME.paused )
			Game.ME.resume();
	}


	override function onResize() {
		super.onResize();

		wrapper.x = Std.int( w()*0.5 );
		wrapper.y = Std.int( h()*0.5 );

		mask.width = w();
		mask.height = h();

		ctrap.width = w();
		ctrap.height = h();
	}


	override function onDispose() {
		super.onDispose();

		fx.destroy();
		fx = null;

		mask = null;
		ctrap = null;
		wrapper = null;
	}

}