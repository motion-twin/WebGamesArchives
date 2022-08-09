package data;

import hxd.res.FontBuilder;

import Common;
import Protocol;

import process.Game;
import manager.AssetManager;

/**
 * ...
 * @author Tipyx
 */
class Settings
{
	static var INITED = false;
	
	public static var INITIAL_WIDTH		= 1080;
	public static var INITIAL_HEIGHT	= 1920;
	public static var STAGE_WIDTH		= 0;
	public static var STAGE_HEIGHT		= 0;
	
	public static var STAGE_SCALE		= 1.;
	
	//public static var FPS				= 60;
	public static var FPS				= 30;
	
	//public static var GRID_WIDTH		= 7;
	//public static var GRID_HEIGHT		= 8;
	
	public static var GRID_WIDTH		= 9;
	public static var GRID_HEIGHT		= 10;
	
	public static var INIT_CLIENT		: InitClient;
	
	public static var IS_FPS_INIT_DONE	: Bool						= false;
	public static var IS_FPS_END_DONE	: Bool						= false;
	
	static var num						= 0;
	public static var DM_BG				= num++;
	public static var DM_WALL			= num++;
	public static var DM_HOLE			= num++;
	public static var DM_GELAT			= num++;
	public static var DM_GRID			= num++;
	public static var DM_ROLLOVER		= num++;
	public static var DM_GRIP			= num++;
	public static var DM_TAUPI			= num++;
	public static var DM_FX				= num++;
	public static var DM_UI				= num++;
	public static var DM_FX_UI			= num++;
	public static var DM_BLACK_BG		= num++;
	
	public static var SLB_GRID			: mt.deepnight.slb.BLib;
	public static var SLB_TAUPI			: mt.deepnight.slb.BLib;
	public static var SLB_UI			: mt.deepnight.slb.BLib;
	public static var SLB_UI2			: mt.deepnight.slb.BLib;
	public static var SLB_FX			: mt.deepnight.slb.BLib;
	public static var SLB_FX2			: mt.deepnight.slb.BLib;
	public static var SLB_UNIVERS1		: mt.deepnight.slb.BLib;
	public static var SLB_UNIVERS2		: mt.deepnight.slb.BLib;
	public static var SLB_UNIVERS3		: mt.deepnight.slb.BLib;
	public static var SLB_LEVELS1		: mt.deepnight.slb.BLib;
	public static var SLB_LEVELS2		: mt.deepnight.slb.BLib;
	public static var SLB_NOTRIM		: mt.deepnight.slb.BLib;
	
	public static var SLB_LANG			: mt.deepnight.slb.BLib;
	public static var SLB_LANG_IS_DL	: Bool						= false;
	
	public static var SLB_FONT_BIRM		: mt.deepnight.slb.BLib;
	public static var SLB_FONT_BENCH	: mt.deepnight.slb.BLib;

	public static var TILE_LOADER_INGAME : h2d.Tile;
	
	public static var FONT_BENCH_NINE_40	: h2d.Font;
	public static var FONT_BENCH_NINE_50	: h2d.Font;
	public static var FONT_BENCH_NINE_70	: h2d.Font;
	public static var FONT_BENCH_NINE_90	: h2d.Font;
	
	public static var FONT_BENCH_NINE_BMF_30	: h2d.Font;
	public static var FONT_BENCH_NINE_BMF_50	: h2d.Font;
	public static var FONT_BENCH_NINE_BMF_70	: h2d.Font;
	public static var FONT_BENCH_NINE_BMF_90	: h2d.Font;
	public static var FONT_BENCH_NINE_BMF_120	: h2d.Font;
	public static var FONT_BENCH_NINE_BMF_150	: h2d.Font;
	
	public static var FONT_MOUSE_DECO_26	: h2d.Font;
	public static var FONT_MOUSE_DECO_32	: h2d.Font;
	public static var FONT_MOUSE_DECO_36	: h2d.Font;
	public static var FONT_MOUSE_DECO_50	: h2d.Font;
	public static var FONT_MOUSE_DECO_66	: h2d.Font;
	public static var FONT_MOUSE_DECO_80	: h2d.Font;
	public static var FONT_MOUSE_DECO_100	: h2d.Font;
	
	public static var FONT_BIRMINGHAM_BMF_120	: h2d.Font;
	
	public static var BASE_SCORE			: Int 					= 100;
	
	public static var MAX_LOOT_BY_GRID		: Int	= 3;
	
	public static function SET() {
		var w = mt.Metrics.w();
		var h = mt.Metrics.h();

		if( STAGE_WIDTH == w && STAGE_HEIGHT == h )
			return false;

		STAGE_WIDTH = w;
		STAGE_HEIGHT = h;
		
		#if standalone
			STAGE_SCALE = Math.min(STAGE_WIDTH / 747, STAGE_HEIGHT / 1144);
		#else
			//STAGE_SCALE = Math.min(STAGE_WIDTH / 1150, STAGE_HEIGHT / 1760);
			STAGE_SCALE = Math.min(STAGE_WIDTH / 1408, STAGE_HEIGHT / 1760);
		#end
		
		#if debug
		trace(STAGE_WIDTH + " " + STAGE_HEIGHT);
		trace(STAGE_SCALE);
		#end

		return true;
	}
	
	public static function RESIZE( ?onComplete : Void->Void, force = false ) {
		if( !SET() && INITED && !force ){
			if( onComplete!=null ) onComplete();
			return;
		}

		INITED = true;
		
		Main.ME.destroyTextFPS();
		
		var scaleFont = STAGE_SCALE #if standalone * 0.65 #end;
		
		hxd.Charset.DEFAULT_CHARS += "$€¢£¥₩₪฿₫₴₹";
		
	// FONT CLASSIC
		if (FONT_BENCH_NINE_40 != null) FontBuilder.deleteFont(FONT_BENCH_NINE_40);
		if (FONT_BENCH_NINE_50 != null) FontBuilder.deleteFont(FONT_BENCH_NINE_50);
		if (FONT_BENCH_NINE_70 != null) FontBuilder.deleteFont(FONT_BENCH_NINE_70);
		if (FONT_BENCH_NINE_90 != null) FontBuilder.deleteFont(FONT_BENCH_NINE_90);
		
		if (FONT_MOUSE_DECO_26 != null) FontBuilder.deleteFont(FONT_MOUSE_DECO_26);
		if (FONT_MOUSE_DECO_32 != null) FontBuilder.deleteFont(FONT_MOUSE_DECO_32);
		if (FONT_MOUSE_DECO_36 != null) FontBuilder.deleteFont(FONT_MOUSE_DECO_36);
		if (FONT_MOUSE_DECO_50 != null) FontBuilder.deleteFont(FONT_MOUSE_DECO_50);
		if (FONT_MOUSE_DECO_66 != null) FontBuilder.deleteFont(FONT_MOUSE_DECO_66);
		if (FONT_MOUSE_DECO_80 != null) FontBuilder.deleteFont(FONT_MOUSE_DECO_80);
		if (FONT_MOUSE_DECO_100 != null) FontBuilder.deleteFont(FONT_MOUSE_DECO_100);
		
		if (FONT_BENCH_NINE_BMF_30 != null) FontBuilder.deleteFont(FONT_BENCH_NINE_BMF_30);
		if (FONT_BENCH_NINE_BMF_50 != null) FontBuilder.deleteFont(FONT_BENCH_NINE_BMF_50);
		if (FONT_BENCH_NINE_BMF_70 != null) FontBuilder.deleteFont(FONT_BENCH_NINE_BMF_70);
		if (FONT_BENCH_NINE_BMF_90 != null) FontBuilder.deleteFont(FONT_BENCH_NINE_BMF_90);
		if (FONT_BENCH_NINE_BMF_120 != null) FontBuilder.deleteFont(FONT_BENCH_NINE_BMF_120);
		if (FONT_BENCH_NINE_BMF_150 != null) FontBuilder.deleteFont(FONT_BENCH_NINE_BMF_150);
		
		if (FONT_BIRMINGHAM_BMF_120 != null) FontBuilder.deleteFont(FONT_BIRMINGHAM_BMF_120);
		
		h3d.Engine.getCurrent().mem.startTextureGC();
		h3d.Engine.getCurrent().mem.cleanBuffers();
		#if cpp
		cpp.vm.Gc.run( true );
		#end

		var buf = [];

		var options = {
			antiAliasing : false,
			chars : hxd.Charset.DEFAULT_CHARS,
			noRetain: true, 
		};
		
		var openflFontBenchNine = openfl.Assets.getFont("assets/BenchNine-Regular.ttf");

		buf.push( function(){ FONT_BENCH_NINE_40 = FontBuilder.getFont(openflFontBenchNine.fontName, Std.int(35 * scaleFont), options ); } );
		buf.push( function(){ FONT_BENCH_NINE_50 = FontBuilder.getFont(openflFontBenchNine.fontName, Std.int(44 * scaleFont), options ); } );
		buf.push( function(){ FONT_BENCH_NINE_70 = FontBuilder.getFont(openflFontBenchNine.fontName, Std.int(68 * scaleFont), options ); } );
		buf.push( function(){ FONT_BENCH_NINE_90 = FontBuilder.getFont(openflFontBenchNine.fontName, Std.int(89 * scaleFont), options ); } );
		
		var openflFontMouseDeco = openfl.Assets.getFont("assets/Mouse_Deco.ttf");
		buf.push( function(){ FONT_MOUSE_DECO_26 = FontBuilder.getFont(openflFontMouseDeco.fontName, Std.int(23 * scaleFont), options ); } );
		buf.push( function(){ FONT_MOUSE_DECO_32 = FontBuilder.getFont(openflFontMouseDeco.fontName, Std.int(28 * scaleFont), options ); } );
		buf.push( function(){ FONT_MOUSE_DECO_36 = FontBuilder.getFont(openflFontMouseDeco.fontName, Std.int(32 * scaleFont), options ); } );
		buf.push( function(){ FONT_MOUSE_DECO_50 = FontBuilder.getFont(openflFontMouseDeco.fontName, Std.int(44 * scaleFont), options ); } );
		buf.push( function(){ FONT_MOUSE_DECO_66 = FontBuilder.getFont(openflFontMouseDeco.fontName, Std.int(58 * scaleFont), options ); } );
		buf.push( function(){ FONT_MOUSE_DECO_80 = FontBuilder.getFont(openflFontMouseDeco.fontName, Std.int(70 * scaleFont), options ); } );
		buf.push( function(){ FONT_MOUSE_DECO_100 = FontBuilder.getFont(openflFontMouseDeco.fontName, Std.int(88 * scaleFont), options ); } );
		
	// BITMAP FONT
		buf.push( function(){
			if (SLB_FONT_BENCH != null) {
				FONT_BENCH_NINE_BMF_30 = getBenchNineFont(Std.int(30 * Settings.STAGE_SCALE));
				FONT_BENCH_NINE_BMF_50 = getBenchNineFont(Std.int(50 * Settings.STAGE_SCALE));
				FONT_BENCH_NINE_BMF_70 = getBenchNineFont(Std.int(70 * Settings.STAGE_SCALE));
				FONT_BENCH_NINE_BMF_90 = getBenchNineFont(Std.int(90 * Settings.STAGE_SCALE));
				FONT_BENCH_NINE_BMF_120 = getBenchNineFont(Std.int(120 * Settings.STAGE_SCALE));
				FONT_BENCH_NINE_BMF_150 = getBenchNineFont(Std.int(150 * Settings.STAGE_SCALE));
			}
		} );

		buf.push( function(){		
			if (SLB_FONT_BIRM != null) {
				FONT_BIRMINGHAM_BMF_120 = getBirminghamFont(Std.int(120 * Settings.STAGE_SCALE));
			}
		} );

		
		#if cpp
		buf.push( function(){
			cpp.vm.Gc.run( true );
		} );
		#end

		if( onComplete != null ){
			trace("Start!");
			var t = new haxe.Timer( 20 );
			t.run = function(){
				if( buf.length == 0 ){
					trace("End!");
					t.stop();
					onComplete();
				}else{
					buf.shift()();
				}
			}
		}else{
			while( buf.length > 0 )
				buf.shift()();
		}

	}
	
	public static function getBirminghamFont(desired) {
		var fnt = mt.heaps.TileFont.fromSlb("birmingham", SLB_FONT_BIRM , 115, Std.int(150 #if standalone * 0.65 #end));
		fnt.resizeTo( desired );
		return fnt;
	}
	
	public static function getBenchNineFont(desired) {
		var fnt = mt.heaps.TileFont.fromSlb("benchNine", SLB_FONT_BENCH , 115, Std.int(150 #if standalone * 0.65 #end));
		fnt.resizeTo( desired );
		return fnt;
	}
}
