import flash.display.Sprite;
import flash.display.Bitmap;
import flash.text.TextField;
import flash.display.BitmapData;

import mt.deepnight.Lib;
import mt.deepnight.Tweenie;
import mt.deepnight.slb.*;
import mt.MLib;
import mt.Metrics;

class Hud {
	static var BMARGIN = 30;

	var game				: m.Game;
	public var wrapper		: Sprite;
	var chronoField			: TextField;
	var chronoBg			: BSprite;
	var scoreTarget			: Bitmap;
	var timeWarning			: Bitmap;

	var menuBt				: BSprite;
	public var button0		: BSprite;

	var side0				: Null<Bitmap>;
	var side1				: Null<Bitmap>;

	public function new() {
		game = m.Game.ME;

		wrapper = new Sprite();
		game.gdm.add(wrapper, Const.DP_INTERF);
		wrapper.mouseEnabled = false;

		// Time warning
		var s = new Sprite();
		var w = game.getWidth()*0.8;
		var h = game.getHeight()*0.6;
		var m = new flash.geom.Matrix();
		m.createGradientBox(w,h*2, 0, 0,-h);
		s.graphics.beginGradientFill(flash.display.GradientType.RADIAL, [0xFF0000,0xFF0000], [1,0], [0,255], m);
		s.graphics.drawRect(0,0, w,h);
		timeWarning = mt.deepnight.Lib.flatten(s);
		wrapper.addChild(timeWarning);
		timeWarning.visible = false;


		// Timer bg
		chronoBg = game.tiles.get("bgTime");
		wrapper.addChild(chronoBg);
		chronoBg.mouseChildren = chronoBg.mouseEnabled = false;
		chronoBg.scaleX = chronoBg.scaleY = 2;

		chronoField = game.createField("0:00", FTime);
		wrapper.addChild(chronoField);
		chronoField.filters = [];
		chronoField.scaleX = chronoField.scaleY = 3;
		chronoField.mouseEnabled = false;

		scoreTarget = new Bitmap( new BitmapData(200, 25, true, 0x0) );
		wrapper.addChild(scoreTarget);
		scoreTarget.x = 5;
		scoreTarget.y = 5;
		updateScore();

		// Menu button
		menuBt = game.tiles.get("pauseButton");
		wrapper.addChild(menuBt);
		menuBt.graphics.beginFill(0x00FF00, 0);
		menuBt.graphics.drawCircle(menuBt.width*0.5, menuBt.height*0.5, 40);
		menuBt.addEventListener( flash.events.MouseEvent.CLICK, function(_) onMenu());

		// Action button 0
		button0 = game.tiles.get("buttonShoot");
		wrapper.addChild(button0);
		button0.mouseChildren = button0.mouseEnabled = false;
		button0.visible = !game.isMulti();

		if( game.isMulti() ) {
			var pt0 = new flash.geom.Point();
			var s = new Sprite();
			s.graphics.beginFill(0x0080FF,1);
			s.graphics.drawCircle(0,0,50);
			side0 = Lib.flatten(s, 64);
			side0.bitmapData.applyFilter(side0.bitmapData, side0.bitmapData.rect, pt0, new flash.filters.BlurFilter(64,64));
			wrapper.addChild(side0);

			var s = new Sprite();
			s.graphics.beginFill(0xE01F24,1);
			s.graphics.drawCircle(0,0,50);
			side1 = Lib.flatten(s, 64);
			side1.bitmapData.applyFilter(side1.bitmapData, side1.bitmapData.rect, pt0, new flash.filters.BlurFilter(64,64));
			wrapper.addChild(side1);
		}

		onResize();
	}

	public inline function setPassButton() {
		button0.set("buttonShoot");
	}

	public inline function setDefendButton() {
		button0.set("buttonTacle");
	}

	//function onButtonPress(_) {
		//game.onMouseDown(null);
	//}
//
	//function onButtonRelease(_) {
		//game.onMouseUp(null);
	//}


	function onMenu() {
		game.onMenu();
	}


	public function onResize() {
		chronoField.y = 2;

		//menuBt.width = menuBt.height = MLib.fmax( Metrics.cm2px(1) / Const.UPSCALE, game.getHeight()*0.1 );
		menuBt.x = game.getWidth() - 35;
		menuBt.y = 3;

		button0.y = game.getHeight()-button0.height-BMARGIN;

		chronoBg.x = Std.int( menuBt.x  - 5 - chronoBg.width );
		chronoBg.y = 0;

		if( side0!=null ) {
			side0.width = 200;
			side0.height = game.getHeight()*1.2;
			side0.x = -side0.width*0.5;
			side0.y = game.getHeight()*0.5 - side0.height*0.5;
		}

		if( side1!=null ) {
			side1.width = 200;
			side1.height = game.getHeight()*1.2;
			side1.x = game.getWidth()-side1.width*0.5;
			side1.y = game.getHeight()*0.5 - side1.height*0.5;
		}
	}


	public function destroy() {
		wrapper.parent.removeChild(wrapper);

		chronoBg.dispose();
		menuBt.dispose();
		button0.dispose();

		timeWarning.bitmapData.dispose(); timeWarning.bitmapData = null;

		//button0.removeEventListener( flash.events.MouseEvent.MOUSE_DOWN, onButtonPress );
		//button0.removeEventListener( flash.events.MouseEvent.MOUSE_UP, onButtonRelease );
	}


	public function updateValues() {
		updateChrono();
		updateScore();
	}

	function updateChrono() {
		var c = Std.int( game.chrono/Const.FPS );
		var mins = Std.int( c/60 );
		var sec = Std.int( c-mins*60 );
		if( mins<0 ) mins = 0;
		if( sec<0 ) sec = 0;
		chronoField.text = mins+":"+mt.deepnight.Lib.leadingZeros(sec,2);
		chronoField.x = Std.int( chronoBg.x + chronoBg.width*0.5 - chronoField.textWidth*chronoField.scaleX*0.5 - 3 );

		if( chronoField.scaleX!=3 && mins==0 && sec<=20 )
			chronoField.textColor = 0xFF8600;

		if( mins<=0 && sec>0 ) {
			timeWarning.x = chronoField.x - timeWarning.width*0.5;
			if( sec<=10 ) {
				game.tw.terminateWithoutCallbacks(timeWarning.alpha);
				timeWarning.visible = true;
				timeWarning.alpha = 1;
				game.tw.create(timeWarning.alpha, 0, TEaseIn, 600);
				game.tw.create(chronoField.y, chronoField.y-4, TLoop, 200);
				m.Global.SBANK.compte_a_rebour(0.2 + 0.8*(1-sec/10));
			}
			else if( sec<=20 ) {
				game.tw.terminateWithoutCallbacks(timeWarning.alpha);
				timeWarning.visible = true;
				timeWarning.alpha = 0.6;
				game.tw.create(timeWarning.alpha, 0, TEaseIn, 300);
			}
		}
	}


	function updateScore() {
		var tf = m.Global.ME.createField(Lang.ScoreTarget({ _cur:game.score, _target:game.getScoreTarget() }), FBig, true);
		tf.filters = [];
		tf.scaleX = tf.scaleY = 2;
		tf.y = -9;
		scoreTarget.bitmapData.fillRect( scoreTarget.bitmapData.rect, 0x0 );
		scoreTarget.bitmapData.draw(tf, tf.transform.matrix);
	}


	public function update() {
		var isActive = en.Player.getActive(0)!=null;
		if( isActive && button0.alpha<0.8 )
			button0.alpha += (0.8-button0.alpha)*0.2;

		if( !isActive && button0.alpha>0.2 )
			button0.alpha += (0.2-button0.alpha)*0.2;

		button0.x = m.Global.ME.playerCookie.data.leftHanded ? BMARGIN : game.getWidth()-button0.width-BMARGIN;

		//if( game.matchStarted() && game.isPlaying() )
			//chronoBg.alpha = chronoField.alpha = 1;
		//else
			//chronoBg.alpha = chronoField.alpha = 0.3;
	}
}
