
import Const;
import TitleLogo;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Lib;
import mt.deepnight.Color;
import mt.deepnight.slb.BLib;
import mt.deepnight.slb.BSprite;
import mt.deepnight.mui.*;

@:bitmap("assets/sheet.png") class GfxTiles extends flash.display.BitmapData {}

class Mode extends mt.deepnight.Process {
	public static var ME : Mode;

	public var dm			: mt.flash.DepthManager;
	public var level		: Level;
	public var fx			: Fx;
	public var cine			: mt.deepnight.Cinematic;
	public var seed			: Int;
	public var rseed		: mt.Rand;
	public var hud			: Hud;
	public var hero			: en.Hero;
	public var diff			: Int;
	public var skill(default, set)	: Float;
	public var nextPowerUp	: Float;

	public var tiles		: BLib;
	public var bgs			: BLib;
	var wtut				: Null<Window>;
	public var phaseMask	: Bitmap;

	public function new(g:Game) {
		super();
		#if dev
		trace("--");
		#end
		ME = this;
		g.addChild(root);

		dm = new mt.flash.DepthManager(root);

		var raw = haxe.Resource.getString( api.AKApi.getLang() );
		if( raw==null )
			raw = haxe.Resource.getString("en");
		Lang.init(raw);

		seed = api.AKApi.getSeed();
		diff = 0;
		skill = 0;
		nextPowerUp = 0;
		cd.set("autoDiff", Const.AUTODIFF);

		tiles = mt.deepnight.slb.assets.ShoeBox.importXml("assets/sheet.xml");
		tiles.setDefaultCenter(0,0);

		bgs = mt.deepnight.slb.assets.TexturePacker.importXml("assets/backgrounds.xml");

		// Init outils divers
		cine = new mt.deepnight.Cinematic(Const.FPS);
		fx = new Fx();

		rseed = new mt.Rand(0);
		rseed.initSeed(seed);

		// HUD
		hud = new Hud();

		// Phase mask
		var s = new Sprite();
		s.graphics.beginFill(0x1B0F3C, 0.8);
		s.graphics.drawRect(0,0, Const.WID, Const.HEI);
		phaseMask = Lib.flatten(s);
		dm.add(phaseMask, Const.DP_PHASE);
		phaseMask.visible = false;

		var perlin = new BitmapData(Const.WID, Const.HEI, false, 0x0);
		perlin.perlinNoise(128, 64, 3, 1866, false, true, 1, true);
		phaseMask.bitmapData.draw(perlin, new flash.geom.ColorTransform(1,1,1, 0.5), flash.display.BlendMode.OVERLAY);
		perlin.dispose();

		// Level
		newLevel();

		hud.refresh();

		/*
		var l = new TitleLogo();
		dm.add(l, Const.DP_INTERF);
		*/
	}


	function addKPoints() {
		var spots = level.getGroundSpotsCopy();
		for( kp in api.AKApi.getInGamePrizeTokens() )
			new en.it.KPoint(0,0, kp);
	}


	public inline function hasTutorial() {
		return wtut!=null;
	}

	public function tutorial(cx,cy, str:String) {
		closeTutorial();

		fx.clear();
		fx.tutorialPointer(cx,cy);

		var s = new Sprite();
		dm.add(s, Const.DP_INTERF);

		wtut = new Window(s, false);
		wtut.padding = 7;
		wtut.setWidth(300);
		wtut.color = 0xEA7500;

		var l = wtut.label(str);
		l.setFont("def", 32);
		l.multiline = true;
		l.setHAlign(Center);
		l.wrapper.filters = [ new flash.filters.DropShadowFilter(2, 90, 0x0,0.2, 0,0) ];

		wtut.separator();
		var l = wtut.label(Lang.CloseTutorial);
		l.setFont("def", 16);
		l.wrapper.filters = [ new flash.filters.DropShadowFilter(1, 90, 0x0,0.2, 0,0) ];

		wtut.x = (cx+0.5)*Const.GRID - wtut.getWidth()*0.5;
		if( cy<Const.LHEI*0.5 )
			wtut.y = cy*Const.GRID+80;
		else
			wtut.y = cy*Const.GRID - wtut.getHeight()-80;
	}


	function closeTutorial() {
		if( wtut!=null ) {
			wtut.wrapper.parent.parent.removeChild( wtut.wrapper.parent );
			wtut.destroy();
			wtut = null;
			resume();
		}
	}


	override function unregister() {
		super.unregister();
		fx.destroy();
	}


	function set_skill(s:Float) {
		if( s>1 ) s = 1;
		if( s<0 ) s = 0;
		return skill = s;
	}


	public function isProgression() {
		return false;
	}
	public function isLeague() {
		return false;
	}

	public function asProgression() : mode.Progression {
		return cast this;
	}
	public function asLeague() : mode.League {
		return cast this;
	}


	public function newLevel() {
		nextPowerUp = Const.seconds( rseed.irange(2, 5) );
	}


	public function createField(str:Dynamic, ?col=0xFFFFFF, ?adjustSize=false) {
		var f = new flash.text.TextFormat();
		f.font = "def";
		f.size = 16;
		f.color = col;

		var tf = new flash.text.TextField();
		tf.width = adjustSize ? 500 : 300;
		tf.height = 50;
		tf.mouseEnabled = tf.selectable = false;
		tf.defaultTextFormat = f;
		tf.embedFonts = true;
		tf.htmlText = Std.string(str);
		tf.multiline = tf.wordWrap = true;
		if( adjustSize ) {
			tf.width = tf.textWidth+5;
			tf.height = tf.textHeight+5;
		}

		tf.filters = [
			new flash.filters.GlowFilter(0x0,1, 4,4,4),
		];

		return tf;
	}

	public function addPowerUp() {
	}

	public inline function countRealMobs() {
		var n = 0;
		for(e in en.Mob.ALL)
			if( e.countAsMob )
				n++;
		return n;
	}

	public function gameOver(win:Bool) {
		if( paused )
			return;
		pause();
		api.AKApi.gameOver(win);
	}

	public function onHeroDeath() {
		delayer.add( function() {
			gameOver(false);
		}, 1000);
	}

	override function update() {
		super.update();

		// Entités
		if( !hasTutorial() ) {
			BSprite.updateAll();
			for(e in Entity.ALL)
				e.update();
			for(e in Entity.TOKILL)
				e.unregister();
			Entity.TOKILL = new Array();


			// Power-ups
			if( nextPowerUp--<=0 )
				addPowerUp();

			skill -= 0.001;
		}
		else {
			// Tutorial
			if( api.AKApi.isToggled(flash.ui.Keyboard.SPACE) || api.AKApi.isToggled(flash.ui.Keyboard.ESCAPE) ) {
				cine.signal();
				closeTutorial();
			}
		}


		cine.update();
		fx.update();
		hud.update();
	}

}
