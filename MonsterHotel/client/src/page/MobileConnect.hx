package page;

import mt.MLib;
import mt.deepnight.Tweenie;

class MobileConnect extends H2dProcess {
	var skipped		: Bool;
	var bg			: h2d.Bitmap;
	var logo		: h2d.Bitmap;
	var click		: h2d.Text;
	var wrapper		: h2d.Sprite;
	var cm			: mt.deepnight.Cinematic;

	var btns 		: Array<h2d.Interactive>;

	public function new() {
		super(Main.ME, Main.ME.uiWrapper);

		skipped = false;
		cm = new mt.deepnight.Cinematic(Const.FPS);

		bg = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0x141221)), root );
		bg.width = w();
		bg.height = h();

		wrapper = new h2d.Sprite(root);

		var glow = Assets.tiles.getH2dBitmap("glowOverlay", 0.5,0.5, true, wrapper);
		glow.blendMode = SoftOverlay;
		glow.scaleX = 13;
		glow.scaleY = glow.scaleX*0.7;
		glow.alpha = 0.2;

		var glow = Assets.tiles.getH2dBitmap("glowOverlay", 0.5,0.5, true, wrapper);
		glow.blendMode = SoftOverlay;
		glow.scaleX = 22;
		glow.scaleY = glow.scaleX*0.9;
		glow.alpha = 0.2;

		var shadow = Assets.tiles1.getH2dBitmap("logo", 0.5,0.5, true, wrapper);
		shadow.y += 10;
		var m = new h3d.Matrix();
		m.set(
			0,0,0, 0,
			0,0,0, 0,
			0,0,0, 0,
			0,0,0, 0.3
		);
		shadow.colorMatrix = m;

		logo = Assets.tiles1.getH2dBitmap("logo", 0.5,0.5, true, wrapper);

		for(i in 0...1) {
			var b = Assets.tiles1.getH2dBitmap("logoBloom", 0.5,0.5, true, wrapper);
			b.blendMode = Add;
			b.setPos(-3,5);
			b.scale(2);
		}

		mkButton(Lang.t._("Play"), function() {
			mt.device.User.play("/start/");
		});

		mkButton(Lang.t._("Log in"), function() {
			mt.device.User.login();
		});

		shine();

		onResize();
	}

	function mkButton( text:String, onClick : Void->Void ) {
		var b = new h2d.Interactive(100, 100, root);
		b.onClick = function(_) onClick();

		var t = new h2d.Text(Assets.fontNormal, b);
		t.textColor = 0xFFCC00;
		t.filter = true;
		t.scale(0.7);
		t.text = text;
		if( btns == null )
			btns = [];
		b.width = t.textWidth * t.scaleX;
		b.height = t.textHeight * t.scaleY;
		btns.push( b );
	}

	function shine() {
		var mask = new h2d.Mask(200,450, wrapper);
		mask.y = -logo.height*0.5;
		mask.visible = false;

		var l = Assets.tiles1.getH2dBitmap("logo", mask);
		l.colorMatrix = mt.deepnight.Color.getColorizeMatrixH2d(0xFFFFC6, 0.5, 0.5);

		var a = tw.create(mask.x, -logo.width*0.5-mask.width>logo.width*0.5, TEaseIn, 1000);
		a.onUpdate = function() {
			mask.visible = true;
			l.x = -mask.x - logo.width*0.5;
		}
		a.onEnd = function() {
			mask.dispose();
		}
		//var s = new h2d.Bitmap(h2d.Tile.fromColor(alpha(0xFFFFFF)), mask);
		//s.tile.setCenterRatio(0.5,0.5);
		//s.width = 100;
		//s.height = 400;
		//var t = logo.tile.clone();
		//t.scale(1/s.scaleX, 1/s.scaleY);
		//s.alphaMap = t;
//
		//tw.create(s.x, -600>600).onEnd = function() {
			//s.dispose();
		//}
	}

	override function unregister() {
		super.unregister();

		bg = null;
		wrapper = null;
	}


	override function onResize() {
		super.onResize();

		var s = MLib.fclamp( (w()*0.5) / logo.width, 0.2, 1.5 );
		wrapper.setScale(s);

		wrapper.x = Std.int( w()*0.5 );
		wrapper.y = Std.int( h()*0.2 );

		var y = Std.int( h()*0.5 );
		if( btns != null )
			for( b in btns ) {
				b.x = Std.int( w() * 0.5 - b.width * b.scaleX * 0.5 );
				b.y = y;
				y += Std.int(b.height * b.scaleY *  1.2);
			}

		bg.width = w();
		bg.height = h();
	}


	override function update() {
		super.update();
		cm.update();

		if( time%60==0 )
			shine();
	}
}
