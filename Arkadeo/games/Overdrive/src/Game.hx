package ;
import anim.FrameManager;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.Firebug;
import haxe.Resource;
import mt.gx.time.FTimer;
import mt.Rand;
import Road;
import utils.IntRect;
import api.AKApi;
import TitleLogo;

/**
 * ...
 * @author 01101101
 */

@:bitmap("gfx/img/sprites.png")		class SpritesBM extends BitmapData { }
@:bitmap("gfx/img/sprites_bg.png")	class SpritesBgBM extends BitmapData { }
@:bitmap("gfx/img/transitions.png")	class SpritesTransBM extends BitmapData { }
@:bitmap("gfx/img/light.png")	class LightBM extends BitmapData { }

@:build(mt.data.Texts.build("xml/texts.fr.xml"))	class Text {}

typedef K = flash.ui.Keyboard;

class Game extends Sprite, implements game.IGame {
	
	static public var SHEET_SPRITES:String = "sheet_sprites";
	static public var SHEET_ROAD:String = "sheet_road";
	static public var SHEET_TRANS:String = "sheet_trans";
	static public var SHEET_UI:String = "sheet_ui";
	
	static public var TAP:Point = new Point();//throwaway point
	static public var TAR:Rectangle = new Rectangle();//throwaway rectangle
	static public var TAM:Matrix = new Matrix();//throwaway matrix
	
	static public var SIZE:IntRect = new IntRect(0, 0, 600, 460);
	static public var TILE_SIZE:Int = 32;
	static public var GRID_SIZE:Int = 8;// DO NOT CHANGE THIS (or to 16 and change >>3 in getKeys and all)
	static public var BIT_OFFSET:Int = 9;
	static public var BIT_MASK:Int = 0x1FF;
	
	static public var RAND:Rand;
	static public var OBJ_RAND:Rand;
	
	static public var RATIO:Float = 1;
	static public var SPEED:Int;
	static public var BASE_SPEED:Int = 18;//18;
	
	static public var COL_BLUE:UInt =	0x00E4FF;
	static public var COL_GREEN:UInt =	0xBAFF00;
	static public var COL_YELLOW:UInt =	0xFFC000;
	static public var COL_ORANGE:UInt =	0xFF8000;
	static public var COL_RED:UInt =	0xFF4200;
	
	static public var MOUSE_MODE:Bool = false;
	
	static public var DBGTCK:Int = 0;
	static public var DBGCNT:Int = 0;
	static public var isRender=true;
	
	//static public var STACK:Array<String> = new Array<String>();
	static public var me : Game;
	public var level:Level;
	
	public function new () {
		super();
		
		#if dev
		Firebug.redirectTraces();
		#end
		
		FM.store(SHEET_SPRITES, new SpritesBM(0, 0), Resource.getString("spritesJson"));
		FM.store(SHEET_ROAD, new SpritesBgBM(0, 0), Resource.getString("spritesBgJson"));
		FM.store(SHEET_TRANS, new SpritesTransBM(0, 0), Resource.getString("spritesTransJson"));
		
		Data.init();
		
		RAND = new Rand(AKApi.getSeed());
		OBJ_RAND = new Rand(AKApi.getSeed());
		// Set ratio depending on level
		if (AKApi.getGameMode() == GM_PROGRESSION)	RATIO = 1 + AKApi.getLevel() / 50;
		// Init localization
		var raw = Resource.getString("xml/texts." + AKApi.getLang() + ".xml");
		if (raw == null)	raw = haxe.Resource.getString("xml/texts.en.xml");
		Text.init(raw);
		
		SPEED = Std.int(BASE_SPEED * RATIO);
		
		init();
		me = this;
	}
	
	function init () {
		level = new Level();
		addChild(level);
	}
	
	public function update (render:Bool) {
		isRender = render;
		if (level.gameIsOver)	return;
		DBGTCK++;
		level.update();
		FTimer.update();
	}
	
	static public function randStd (min:Int, max:Int, s:Bool = false) :Int {
		if (!s)	return min + Std.random(max - min);
		else	return min + Std.random(max - min) * signStd();
	}
	static public function rand (min:Int, max:Int, s:Bool = false) :Int {
		if (!s)	return min + RAND.random(max - min);
		else	return min + RAND.random(max - min) * sign();
	}
	static public function randObj (min:Int, max:Int, s:Bool = false) :Int {
		if (!s)	return min + OBJ_RAND.random(max - min);
		else	return min + OBJ_RAND.random(max - min) * sign();
	}
	
	static public function signStd () :Int {
		return Std.random(2) * 2 - 1;
	}
	static public function sign () :Int {
		return RAND.random(2) * 2 - 1;
	}
	static public function signObj () :Int {
		return OBJ_RAND.random(2) * 2 - 1;
	}
	
}










