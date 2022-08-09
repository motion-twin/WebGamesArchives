package page;

import mt.data.GetText;
import mt.MLib;
import com.Protocol;
import mt.deepnight.Tweenie;
import mt.deepnight.slb.*;
import Data;
import com.*;

class IntroCinematic extends H2dProcess {
	var cm			: mt.deepnight.Cinematic;
	var fx			: Fx;
	var ctrap		: h2d.Interactive;
	var twrapper	: h2d.Sprite;
	var lastSay		: Null<h2d.Sprite>;
	var city1		: HSprite;
	var city2		: HSprite;
	var car			: HSprite;
	var carLight	: HSprite;
	var buttons		: Array<h2d.Interactive>;

	var groom		: h2d.Sprite;
	var groomBody	: HSprite;
	var groomHead	: HSprite;
	var groomEyes	: HSprite;
	var groomMouth	: HSprite;
	var groomHat	: HSprite;

	var tx			: Float;
	var lookX		: Float;
	var lookY		: Float;
	var blinkFrame	: Int;
	var carSpeed	: Float;
	var chosenColor	: UInt;
	var walkFactor	: Float;

	var wrapperWid = 1000;
	var wrapperHei(get,never) : Float; inline function get_wrapperHei() return h()/twrapper.scaleX;

	public function new() {
		super(Main.ME);

		Main.ME.uiWrapper.add(root, Const.DP_INTRO);

		cm = new mt.deepnight.Cinematic(Const.FPS);

		var s = new h2d.Layers(root);
		fx = new Fx(this,s);

		walkFactor = 0;
		chosenColor = 0;
		carSpeed = 1;
		buttons = [];
		lookX = lookY = 0;
		tx = 0.2;

		ctrap = new h2d.Interactive(4,4, root);
		ctrap.backgroundColor = alpha(Const.BLUE);
		ctrap.cursor = hxd.System.Cursor.Default;
		ctrap.onClick = onClick;

		city1 = Assets.intro.h_get("bgScroll",0, 0,1, root);
		city1.filter = true;

		city2 = Assets.intro.h_get("bgScroll",0, 0,1,  root);
		city2.filter = true;

		car = Assets.intro.h_get("limo",root);
		car.filter = true;

		carLight = Assets.intro.h_get("limoLight", 0.5,0.5, root);
		carLight.blendMode = Add;
		carLight.filter = true;

		groom = new h2d.Sprite(root);
		groomBody = Assets.intro.h_get("groomBody", true, groom);
		groomBody.setCenterRatio(0.5,1);

		groomHead = Assets.intro.h_get("groomHead", true, groom);
		groomHead.setCenterRatio(0.5,0.9);
		groomHead.x = -20;
		groomHead.y = -groomBody.height*0.88;

		groomHat = Assets.intro.h_get("groomHat", true, groomHead);
		groomHat.setCenterRatio(0.5,0.6);

		groomEyes = Assets.intro.h_get("groomEyes", true, groomHead);
		groomEyes.setCenterRatio(0.5,0.5);

		groomMouth = Assets.intro.h_get("groomMouth", true, groomHead);
		groomMouth.setCenterRatio(0.5,0.5);
		groomMouth.setPos(70,-25);

		Game.ME.pause();
		Main.ME.gameWrapper.visible = false;

		twrapper = new h2d.Sprite(root);

		onResize();
		if( SoundMan.ME!=null ) {
			SoundMan.ME.introMusic();
			SoundMan.ME.stopAmbiant();
		}

		tx = -0.3;
		cm.create({
			500;
			moveTo(0.27, 2000);
			2000;
			say(Lang.t._("Hello boss!||Keep this gender independent (should apply for both male & female players)")) > end;

			clear();
			lookAt(-1,0);
			say(Lang.t._("We are about to arrive at YOUR new hotel.")) > end;

			clear();
			lookAt(1,0);
			say(Lang.t._("You will be in charge of taking care of our clients and decide our future expansions!")) > end;

			clear();
			lookAt();
			moveTo(0.2, 1000);
			say(Lang.t._("But first of all, let's talk about your tastes! What COLOR would you like for your first hotel BEDROOMS?"), false);
			700;
			addButton(Data.WallColorKind.coldBlue, Data.WallColorKind.blue2, Lang.t._("Blue"), Lang.t._("Like the sky..."), prepare.bind(0));
			addButton(Data.WallColorKind.pink2, Data.WallColorKind.pink3, Lang.t._("Pink"), Lang.t._("Because it's pretty!"), prepare.bind(1));
			addButton(Data.WallColorKind.coldGreen, Data.WallColorKind.green2, Lang.t._("Green"), Lang.t._("For the win!"), prepare.bind(2));
			addButton(Data.WallColorKind.red0, Data.WallColorKind.red1, Lang.t._("Red"), Lang.t._("Classy."), prepare.bind(3));
			end("prepare");

			clear();
			100;
			Assets.SBANK.happy(1);
			moveTo(0.26, 1000);
			600;
			say( Lang.t._("Great choice!") ) > end;

			clear();
			tw.create(carSpeed, 0.05, 1000);
			//Assets.SBANK.carArrive().play(0.5,-1);
			1200;
			say( Lang.t._("Oh, looks like we arrived.") );
			lookAt(-1,0);
			end("wait");

			close();
		});
	}

	function onClick(_) {
		if( !destroyed && !cd.has("click") )
			cm.signal("wait");
	}

	function close() {
		var mask = Assets.tiles.getColoredH2dBitmap("white", Const.BLUE);
		Main.ME.uiWrapper.add(mask, Const.DP_INTRO);
		mask.width = w();
		mask.height = h();
		Game.ME.tw.create(mask.alpha, 0>1, 1500).end( function() {
			destroy();
		}).chain(0, 1500).end( function() {
			mask.dispose();
		});

		Main.ME.gameWrapper.visible = true;
		Game.ME.resume();
	}

	function clear() {
		if( lastSay!=null ) {
			var s = lastSay;
			lastSay = null;
			s.dispose();
			//tw.create(s.scaleY, 0, 200).end( s.dispose );
		}

		for(b in buttons)
			b.dispose();
		buttons = [];
	}

	function prepare(c:Int) {
		Game.ME.runSolverCommand( DoPrepareHotel(c) );
		cm.signal("prepare");
	}


	function say(?col=0xFFF7C4, str:LocaleString, ?skippable=true) {
		cd.set("talking", rnd(50,80));
		cd.set("click", Const.seconds(0.2));
		Assets.SBANK.slide1(1);
		var px = 120;
		var py = 50;
		var maxWid = wrapperWid-px*2;
		var s = new h2d.Sprite(twrapper);
		lastSay = s;

		var outline = Assets.intro.h_get("dialBubble", 0.5,0.5, true, s);
		outline.colorize(col);
		var bg = Assets.intro.h_get("dialBubbleBg", 0.5,0.5, true, s);

		var tf = Assets.createText(isSmall() ? 53 : 48, 0xFFE280, str, s);
		tf.maxWidth = maxWid/tf.scaleX;
		tf.setPos(px,py);
		tf.dropShadow = { color:0xB03900, alpha:0.6, dx:0, dy:3 }

		bg.width = MLib.fmax( maxWid*0.75, px*2 + ( skippable ? tf.textWidth*tf.scaleX : maxWid ) );
		bg.height = tf.textHeight*tf.scaleY + py*2 + (skippable?50:0);
		bg.setPos( tf.x+tf.textWidth*tf.scaleX*0.5, tf.y + tf.textHeight*tf.scaleY*0.5 );

		outline.scaleX = bg.scaleX;
		outline.scaleY = bg.scaleY;
		outline.setPos( bg.x, bg.y );

		if( skippable ) {
			var tap = Assets.tiles.h_get("tutoHand", true, s);
			tap.setPivotCoord(10,10);
			tap.alpha = 0;
			createChildProcess( function(p) {
				if( p.ftime>=Const.seconds(2.1) && tap.alpha<1 )
					tap.alpha+=0.1;
				var r = MLib.fabs( Math.cos(ftime*0.16) );
				tap.setPos(bg.width*0.5 + r*35, bg.height*0.6 + r*20);
				tap.setScale( 1.6 + MLib.fabs(r*0.3) );
			}, true);
			//#if responsive
			//var label = Lang.t._("Tap anywhere to continue");
			//#else
			//var label = Lang.t._("Click anywhere to continue");
			//#end
			//var ctf = Assets.createText(24, Const.TEXT_GRAY, label, s);
			//ctf.alpha = 0.6;
			////ctf.setPos(bg.width*0.5-tf.textWidth*tf.scaleX*0.5, bg.height-tf.textHeight*tf.scaleY-py);
			//ctf.setPos(tf.x + tf.textWidth*tf.scaleX*0.5 - ctf.textWidth*ctf.scaleX*0.5, tf.y + tf.textHeight*tf.scaleY+ 10);
		}

		if( skippable )
			s.setPos( wrapperWid*0.5-bg.width*0.5, wrapperHei*rnd(0.35,0.40) );
		else
			s.setPos( wrapperWid*0.5-bg.width*0.5, wrapperHei*0.3 - 20 - bg.height );

		tw.create(s.scaleX, 0>s.scaleX, 300);
		tw.create(s.x, s.x-200>s.x, 300, TEaseOut);
		tw.create(s.y, s.y+120>s.y, 300, TEase);
	}

	function addButton(col1:Data.WallColorKind, col2:Data.WallColorKind, label:LocaleString, sub:LocaleString, cb:Void->Void) {
		var col1 = DataTools.getWallColorCode(col1.toString());
		var col2 = DataTools.getWallColorCode(col2.toString());

		var bwid = Std.int( wrapperWid );
		var bhei = Std.int( bwid*0.14 );
		var isize = bhei*1.22;

		var i = new h2d.Interactive(bwid, bhei, twrapper);
		buttons.push(i);
		i.onClick = function(_) {
			if( destroyed || cd.has("btLock") )
				return;

			Assets.SBANK.item(1);
			chosenColor = col1;
			cd.set("btLock", 99999);
			cb();
		}

		var bg = Assets.tiles.getH2dBitmap("btnAction",i);
		bg.x = isize*0.5;
		bg.width = bwid - isize*0.5;
		bg.height = bhei;

		// Color 1
		var disc = Assets.tiles.h_get("halfWhiteCircle",0, 1,0.5, true, i);
		disc.constraintSize(isize*0.9);
		disc.colorize(col1);
		disc.rotate(0.2);
		disc.setPos(isize*0.5, bhei*0.5);

		// Color 2
		var disc = Assets.tiles.h_get("halfWhiteCircle",0, 1,0.5, true, i);
		disc.constraintSize(isize*0.9);
		disc.colorize(col2);
		disc.rotate(MLib.PI+0.2);
		disc.setPos(isize*0.5, bhei*0.5);

		// Circlet
		var icon = Assets.tiles.h_get("circletGold",0, 0.5,0.5, true, i);
		icon.constraintSize(isize);
		icon.setPos(disc.x, disc.y);

		// Label
		var th = 0.;
		var tf = Assets.createText(70, Const.BLUE, label, i);
		tf.x = icon.x + isize*0.5 + 10;
		th+=tf.textHeight*tf.scaleY;

		// Sub label
		var stf = Assets.createText(36, Const.BLUE, sub, i);
		stf.x = icon.x + isize*0.5 + 10;
		stf.alpha = 0.7;
		th+=stf.textHeight*stf.scaleY;

		tf.y = bhei*0.5 - th*0.5;
		stf.y = tf.y + tf.textHeight*tf.scaleY*0.9;

		// Rollovers
		i.onOver = function(_) {
			bg.color = h3d.Vector.fromColor(alpha(0xFFFFAA),1.5);
		}
		i.onOut = function(_) {
			bg.color.one();
		}

		var i = 0;
		for(b in buttons) {
			tw.create(b.x, i*200 | wrapperWid+50>0, 300).start( function() {
				Assets.SBANK.slide2(0.3);
			});
			b.y = wrapperHei*0.3 + i*isize;
			i++;
		}
	}


	override function onDispose() {
		clear();

		super.onDispose();

		buttons = null;

		cm.destroy();
		cm = null;

		fx = null;
		city1 = null;
		city2 = null;
		car = null;

		twrapper = null;
	}

	inline function isSmall() return hcm()<=7;

	override function onResize() {
		super.onResize();
		ctrap.setSize(w(), h());
		car.setScale( MLib.fmax( (w()+10)/car.tile.width, (h()+10)/car.tile.height ) );

		city1.setScale( h()*0.9/city1.tile.height );
		city2.setScale( city1.scaleX );
		updateCity();

		groom.setScale( h()*0.4/groomBody.height );
		var r = isSmall() ? 0.41 : 0.52;
		twrapper.x = w()*r;
		twrapper.setScale( w()*0.95*(1-r)/wrapperWid );
	}

	function lookAt(?x=0.,?y=0.) {
		tw.create(lookX, x, 250, TEaseOut);
		tw.create(lookY, y, 250, TEaseOut);
	}

	function moveTo(x:Float, d:Float) {
		tw.create(tx, x, d);
		tw.create(walkFactor, 0>1, TLoop, d);
	}


	function updateCity() {
		var s = carSpeed * w()*0.033;
		city1.x+=s;
		city1.y = h()*0.7 + Math.sin(ftime*0.3)*5 + Math.cos(ftime*0.01)*50;
		while( city1.x>=0 )
			city1.x-=city1.width;
		city2.x = city1.x + city1.width;
		city2.y = city1.y;
	}


	override function update() {
		super.update();

		cm.update();
		car.x = -5 + carSpeed * Math.cos(ftime*0.06)*5 + rnd(0,1);
		car.y = -5 + carSpeed * Math.cos(ftime*0.6)*3 + rnd(0,4);

		carLight.setPos(car.x + car.scaleX*car.tile.width*0.7, car.y + car.scaleY*car.tile.height*0.28);
		carLight.setScale( 3*car.scaleX + Math.cos(ftime*0.03)*0.3 );
		carLight.alpha = Math.sin(ftime*0.15)*0.1 + 0.9;

		groom.x = w()*tx + carSpeed * Math.cos(ftime*0.06)*5 + rnd(0,1);
		groom.y = h() + 20 + carSpeed * Math.cos(ftime*0.6)*2 + rnd(0,2) + walkFactor*Math.cos(ftime*0.8)*10;
		groom.rotation = Math.cos(ftime*0.06)*0.02 - walkFactor*0.07;

		groomHead.rotation = Math.cos(ftime*0.1)*0.06;

		groomHat.x = 95 + carSpeed * Math.sin(ftime*0.1)*4;
		groomHat.y = -310 - carSpeed * MLib.fabs( Math.cos(ftime*0.2)*5 );

		groomEyes.setPos(60+lookX*20, -120+lookY*40);

		if( !cd.has("blink") ) {
			cd.set("blink", rnd(40,100));
			groomEyes.visible = false;
			groomHead.setFrame(1);
			delayer.addFrameBased( function() groomHead.setFrame(2), 2);
			delayer.addFrameBased( function() {
				groomEyes.visible = true;
				groomHead.setFrame(0);
			}, 3);
		}

		if( cd.has("talking") ) {
			if( !cd.has("talkFrame") ) {
				groomMouth.setFrame( Assets.intro.getRandomFrame(groomMouth.groupName) );
				cd.set("talkFrame", irnd(2,3));
			}
		}
		else
			groomMouth.setFrame(4);

		updateCity();
	}
}